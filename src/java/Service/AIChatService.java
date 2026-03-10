package Service;

import DAO.AIChatDAO;
import DAO.ClothingDAO;
import Model.AIChatReply;
import Model.AIConversation;
import Model.AIKnowledgeDoc;
import Model.AIMessage;
import Model.AIProductSuggestion;
import Model.Clothing;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AIChatService {

    private static final int LLM_CONTEXT_MESSAGE_LIMIT = 8;
    private static final int PROFILE_CONTEXT_MESSAGE_LIMIT = 30;
    private static final String USER_ROLE_RESTRICTION_NOTIFICATION_TITLE = "Giới hạn nội dung tư vấn theo vai trò";
    private static final String USER_ROLE_RESTRICTION_NOTIFICATION_MESSAGE = "Tài khoản User không có quyền truy cập quy trình đăng tải trang phục. Bạn có thể hỏi về quy trình thuê, thanh toán, theo dõi đơn hoặc hoàn tiền.";

    public static AIChatReply handleUserMessage(int userID, String userRole, Integer conversationID, String userMessage) {
        String normalizedMessage = userMessage == null ? "" : userMessage.trim();
        if (normalizedMessage.isEmpty()) {
            AIChatReply invalidReply = new AIChatReply();
            invalidReply.setAssistantMessage("Bạn vui lòng nhập nội dung cần hỗ trợ.");
            invalidReply.setIntent("INVALID");
            invalidReply.setConfidence(new BigDecimal("0.0000"));
            return invalidReply;
        }

        String normalizedRole = normalizeRole(userRole);
        RoleRestriction roleRestriction = evaluateRoleRestriction(normalizeForMatching(normalizedMessage), normalizedRole);
        if (roleRestriction.blocked) {
            if ("USER_UPLOAD_PROCESS_BLOCKED".equals(roleRestriction.code)) {
                NotificationService.createNotificationOnceByTitle(
                        userID,
                        USER_ROLE_RESTRICTION_NOTIFICATION_TITLE,
                        USER_ROLE_RESTRICTION_NOTIFICATION_MESSAGE
                );
            }

            AIChatReply blockedReply = new AIChatReply();
            blockedReply.setAssistantMessage(roleRestriction.message);
            blockedReply.setIntent("ROLE_RESTRICTED");
            blockedReply.setConfidence(new BigDecimal("1.0000"));
            blockedReply.setResponseSource("RULE");
            blockedReply.setHandedOff(false);
            blockedReply.setRedirectToAdvisor(false);
            return blockedReply;
        }

        int resolvedConversationID = resolveConversationID(userID, conversationID);
        if (resolvedConversationID <= 0) {
            AIChatReply failedReply = new AIChatReply();
            failedReply.setAssistantMessage("Hệ thống tạm thời không thể mở hội thoại. Bạn vui lòng thử lại sau ít phút.");
            failedReply.setIntent("SYSTEM_ERROR");
            failedReply.setConfidence(new BigDecimal("0.0000"));
            return failedReply;
        }

        List<AIMessage> contextMessages = AIChatDAO.getRecentMessages(resolvedConversationID, PROFILE_CONTEXT_MESSAGE_LIMIT);
        List<AIMessage> llmContextMessages = AIChatDAO.getRecentMessages(resolvedConversationID, LLM_CONTEXT_MESSAGE_LIMIT);
        String normalizedForMatching = normalizeForMatching(normalizedMessage);
        IntentAnalysis intentAnalysis = analyzeIntent(normalizedMessage);
        RedirectDecision redirectDecision = determineRedirect(normalizedMessage, intentAnalysis.intent);
        boolean directProductBrowseRequest = isDirectProductBrowseRequest(normalizedForMatching);
        List<AIProductSuggestion> productSuggestions = buildProductSuggestions(normalizedMessage, intentAnalysis.intent, contextMessages);
        int userMessageID = AIChatDAO.addMessage(resolvedConversationID, "USER", normalizedMessage, intentAnalysis.intent, intentAnalysis.confidence, "USER_INPUT");

        boolean needsHandoff = shouldHandoff(normalizedMessage, intentAnalysis);
        String assistantMessage;
        String responseSource;
        String handoffReason = null;
        List<AIKnowledgeDoc> retrievedDocs = new ArrayList<>();

        if (needsHandoff) {
            assistantMessage = buildAssistantMessage(intentAnalysis.intent, true);
            responseSource = "RULE";
            handoffReason = "LOW_CONFIDENCE_OR_SENSITIVE";
            int ticketID = AIChatDAO.createHandoffTicket(resolvedConversationID, userID, handoffReason, "NORMAL");
            if (ticketID > 0) {
                assistantMessage = assistantMessage + " Mã phiếu hỗ trợ của bạn là #" + ticketID + ".";
            }
        } else {
            boolean hasConsultPurposeFromHistory = hasConsultPurposeFromHistory(contextMessages);
            UserProfile profileFromHistory = extractUserProfileFromHistory(contextMessages);
            boolean hasConsultStyleFromHistory = hasConsultStyleFromHistory(contextMessages);

            if ("CONSULT_ADVICE".equals(intentAnalysis.intent)
                    && shouldAskConsultPurposeFirst(normalizedMessage)
                    && !hasConsultPurposeFromHistory) {
                assistantMessage = buildConsultPurposeFirstMessage();
                responseSource = "RULE";
            } else {
                retrievedDocs = AIKnowledgeService.getTopDocsForChat(normalizedMessage, intentAnalysis.intent, 3);
                String knowledgeContext = AIKnowledgeService.buildKnowledgeContextFromDocs(retrievedDocs);
                String llmReply = LLMClientService.generateReply(
                    buildSystemPrompt(intentAnalysis.intent, knowledgeContext),
                        llmContextMessages,
                        normalizedMessage
                );

                if (llmReply != null && !llmReply.isBlank()) {
                    assistantMessage = llmReply;
                    responseSource = "LLM";
                } else {
                    assistantMessage = buildRuleBasedAssistantMessage(
                            intentAnalysis.intent,
                            normalizedMessage,
                            hasConsultPurposeFromHistory,
                            hasConsultStyleFromHistory,
                            profileFromHistory
                    );
                    responseSource = "RULE";
                }
            }
        }

        if (needsHandoff) {
            productSuggestions = Collections.emptyList();
        }

        if (!needsHandoff && directProductBrowseRequest) {
            if (!productSuggestions.isEmpty()) {
                assistantMessage = buildDirectBrowseResponse(normalizedMessage);
                responseSource = "RULE";
            } else {
                assistantMessage = "Mình chưa tìm thấy sản phẩm phù hợp ngay lúc này. Bạn cho mình thêm chiều cao, cân nặng và ngân sách để mình lọc chính xác hơn nhé.";
                responseSource = "RULE";
            }
        }

        if (!productSuggestions.isEmpty() && looksLikeNoProductInfoResponse(assistantMessage)) {
            assistantMessage = buildProductAvailabilityMessage(productSuggestions);
            responseSource = "RULE";
        }

        int assistantMessageID = AIChatDAO.addMessage(resolvedConversationID, "ASSISTANT", assistantMessage, intentAnalysis.intent, intentAnalysis.confidence, responseSource);

        if (userMessageID > 0 && assistantMessageID > 0) {
            AIChatDAO.addRetrievalLog(
                    resolvedConversationID,
                    userMessageID,
                    assistantMessageID,
                    intentAnalysis.intent,
                    normalizedMessage,
                    joinDocIds(retrievedDocs),
                    joinDocTitles(retrievedDocs),
                    responseSource
            );
        }

        AIChatReply reply = new AIChatReply();
        reply.setConversationID(resolvedConversationID);
        reply.setUserMessageID(userMessageID);
        reply.setAssistantMessageID(assistantMessageID);
        reply.setAssistantMessage(assistantMessage);
        reply.setIntent(intentAnalysis.intent);
        reply.setConfidence(intentAnalysis.confidence);
        reply.setHandedOff(needsHandoff);
        reply.setHandoffReason(handoffReason);
        reply.setResponseSource(responseSource);
        reply.setRedirectToAdvisor(redirectDecision.redirectToAdvisor);
        reply.setRedirectReason(redirectDecision.redirectReason);
        reply.setProductSuggestions(productSuggestions);
        return reply;
    }

    public static boolean submitAssistantFeedback(int userID, int assistantMessageID, int rating, boolean isHelpful, String note) {
        if (userID <= 0 || assistantMessageID <= 0 || rating < 1 || rating > 5) {
            return false;
        }

        int feedbackID = AIChatDAO.addMessageFeedback(assistantMessageID, userID, rating, note);
        if (feedbackID <= 0) {
            return false;
        }

        return AIChatDAO.updateRetrievalFeedbackByAssistantMessage(assistantMessageID, isHelpful, note);
    }

    public static List<AIMessage> getConversationHistory(int userID, int conversationID, int limit) {
        AIConversation conversation = AIChatDAO.getConversationByIdAndUser(conversationID, userID);
        if (conversation == null) {
            return Collections.emptyList();
        }
        return AIChatDAO.getRecentMessages(conversationID, limit);
    }

    public static List<AIConversation> getRecentConversations(int userID, int limit) {
        if (userID <= 0) {
            return Collections.emptyList();
        }
        return AIChatDAO.getRecentConversationsByUser(userID, limit);
    }

    public static Integer createNewConversation(int userID) {
        if (userID <= 0) {
            return null;
        }
        return AIChatDAO.createConversation(userID, "WEB");
    }

    public static boolean clearUserHistory(int userID) {
        if (userID <= 0) {
            return false;
        }
        return AIChatDAO.clearUserHistory(userID);
    }

    public static boolean deleteConversation(int userID, int conversationID) {
        if (userID <= 0 || conversationID <= 0) {
            return false;
        }
        return AIChatDAO.deleteConversationForUser(userID, conversationID);
    }

    private static int resolveConversationID(int userID, Integer conversationID) {
        if (conversationID != null && conversationID > 0) {
            AIConversation conversation = AIChatDAO.getConversationByIdAndUser(conversationID, userID);
            if (conversation != null) {
                return conversation.getConversationID();
            }
        }

        AIConversation openConversation = AIChatDAO.getLatestOpenConversationByUser(userID);
        if (openConversation != null) {
            return openConversation.getConversationID();
        }

        Integer createdConversationID = AIChatDAO.createConversation(userID, "WEB");
        return createdConversationID == null ? -1 : createdConversationID;
    }

    private static IntentAnalysis analyzeIntent(String message) {
        String normalizedMessage = normalizeForMatching(message);

        if (containsAny(normalizedMessage,
                "quy trinh dang tai", "dang tai quan ao", "dang san pham", "them trang phuc", "listing", "dang bai")) {
            return new IntentAnalysis("LISTING_SUPPORT", new BigDecimal("0.8800"));
        }

        if (containsAny(normalizedMessage,
            "ao dai", "thue ao dai", "ao dai truyen thong", "ao dai cach tan")) {
            return new IntentAnalysis("RENTAL_ADVICE", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "tu van", "goi y", "phoi do", "phong cach", "style", "chon do",
            "di du tiec", "du tiec", "tiec", "tiec sang trong", "sang trong", "thanh lich", "ca tinh", "vui nhon",
            "tiec sinh nhat", "tiec cong ty", "chup anh", "di chup anh", "quay phim", "concept",
            "trang phuc", "outfit", "set do", "bo de thue", "thue di")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.9000"));
        }

        if (containsAny(normalizedMessage,
                "tim san pham", "muon tim san pham", "tim ao", "tim dam", "tim vest", "tim ao khoac", "tim ao dai")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.8200"));
        }

        if (containsAny(normalizedMessage,
                "ngan sach", "budget", "trieu", "nghin", "khoang", "tam", "duoi", "tren")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.7600"));
        }

        if (containsAny(normalizedMessage, "hoan tien", "refund", "tra hang", "return", "khieu nai")) {
            return new IntentAnalysis("RETURN_REFUND", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "quy trinh", "dat thue", "quy trinh thue", "quy trinh dat thue", "thu tuc thue", "thue do")) {
            return new IntentAnalysis("BOOKING_SUPPORT", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "don hang", "order", "trang thai", "giao hang")) {
            return new IntentAnalysis("ORDER_SUPPORT", new BigDecimal("0.8200"));
        }

        if (containsAny(normalizedMessage, "size", "kich co", "vong", "cao", "nang")) {
            return new IntentAnalysis("SIZE_ADVICE", new BigDecimal("0.7800"));
        }

        if (containsAny(normalizedMessage, "thanh toan", "payment", "chuyen khoan", "coc")) {
            return new IntentAnalysis("PAYMENT_SUPPORT", new BigDecimal("0.8000"));
        }

        return new IntentAnalysis("GENERAL_FAQ", new BigDecimal("0.5500"));
    }

    private static String buildAssistantMessage(String intent, boolean handoff) {
        if (handoff) {
            return "Mình đã ghi nhận yêu cầu và đang chuyển đến nhân viên CSKH để hỗ trợ chi tiết hơn.";
        }

        if ("ORDER_SUPPORT".equals(intent)) {
            return "Bạn có thể kiểm tra trạng thái đơn tại mục Đơn thuê của tôi. Nếu cần, hãy gửi mã đơn để mình hỗ trợ nhanh hơn.";
        }

        if ("BOOKING_SUPPORT".equals(intent)) {
            return "Mình có thể hướng dẫn quy trình đặt thuê chi tiết theo từng bước để bạn thao tác nhanh hơn.";
        }

        if ("LISTING_SUPPORT".equals(intent)) {
            return "Mình có thể hướng dẫn quy trình đăng tải quần áo lên hệ thống theo từng bước.";
        }

        if ("SIZE_ADVICE".equals(intent)) {
            return "Để tư vấn size chính xác, bạn cho mình chiều cao, cân nặng và số đo cơ bản. Mình sẽ gợi ý size phù hợp ngay.";
        }

        if ("RENTAL_ADVICE".equals(intent)) {
            return "Mình hỗ trợ thuê trang phục theo nhu cầu của bạn. Bạn cho mình thêm 3 thông tin: dịp sử dụng, chiều cao-cân nặng, và ngân sách thuê. Mình sẽ gợi ý các mẫu phù hợp đang có.";
        }

        if ("CONSULT_ADVICE".equals(intent)) {
            return "Mình có thể tư vấn ngay. Với đi dự tiệc, bạn cho mình thêm 4 thông tin: giới tính/phong cách mong muốn, tông màu bạn thích, vóc dáng (chiều cao-cân nặng), và ngân sách thuê. Dựa trên sản phẩm hiện có, mình sẽ gợi ý 2-3 bộ phù hợp nhất.";
        }

        if ("PAYMENT_SUPPORT".equals(intent)) {
            return "Với thanh toán và tiền cọc, bạn vui lòng cung cấp mã đơn để mình kiểm tra trạng thái xác nhận chi tiết.";
        }

        if ("RETURN_REFUND".equals(intent)) {
            return "Mình có thể hỗ trợ quy trình trả đồ và hoàn tiền. Bạn cho mình mã đơn và tình trạng hiện tại để xử lý đúng chính sách.";
        }

        return "Mình có thể hỗ trợ về đơn hàng, tư vấn size/trang phục, thanh toán, trả hàng và hoàn tiền. Bạn nói rõ nhu cầu để mình hỗ trợ nhanh hơn nhé.";
    }

    private static String buildRuleBasedAssistantMessage(String intent, String message,
                                                         boolean hasConsultPurposeFromHistory,
                                                         boolean hasConsultStyleFromHistory,
                                                         UserProfile profileFromHistory) {
        if ("SIZE_ADVICE".equals(intent)) {
            return buildSizeAdviceMessage(message);
        }

        if ("ORDER_SUPPORT".equals(intent)) {
            return buildOrderSupportMessage(message);
        }

        if ("BOOKING_SUPPORT".equals(intent)) {
            return buildBookingSupportMessage();
        }

        if ("LISTING_SUPPORT".equals(intent)) {
            return buildListingSupportMessage();
        }

        if ("RENTAL_ADVICE".equals(intent)) {
            return buildRentalAdviceMessage(message, profileFromHistory);
        }

        if ("CONSULT_ADVICE".equals(intent)) {
            return buildConsultAdviceMessage(message, hasConsultPurposeFromHistory, hasConsultStyleFromHistory, profileFromHistory);
        }

        return buildAssistantMessage(intent, false);
    }

    private static String buildOrderSupportMessage(String message) {
        return "Bạn có thể kiểm tra trạng thái đơn tại mục Đơn thuê của tôi. Nếu cần, hãy gửi mã đơn để mình hỗ trợ nhanh hơn.";
    }

    private static String buildBookingSupportMessage() {
        return "Quy trình đặt thuê tại WearConnect gồm 6 bước: "
                + "(1) Tìm trang phục phù hợp theo dịp/phong cách, "
                + "(2) Xem chi tiết và chọn kích cỡ, "
                + "(3) Chọn thời gian thuê và xác nhận thông tin đơn, "
                + "(4) Thanh toán/đặt cọc theo hướng dẫn hệ thống, "
                + "(5) Chờ shop xác nhận và theo dõi trạng thái tại mục Đơn thuê của tôi, "
                + "(6) Nhận trang phục và trả đúng hạn để hoàn cọc nhanh chóng. "
                + "Nếu bạn cần, mình có thể hướng dẫn chi tiết từng bước theo màn hình hiện tại của bạn.";
    }

    private static String buildListingSupportMessage() {
        return "Quy trình đăng tải quần áo trên WearConnect gồm 6 bước: "
                + "(1) Vào mục Quản lý trang phục, "
                + "(2) Chọn Thêm trang phục mới, "
                + "(3) Nhập đầy đủ thông tin bắt buộc (tên, danh mục, phong cách, dịp, size, số lượng, giá thuê, giá trị sản phẩm), "
                + "(4) Tải ảnh rõ nét của sản phẩm, "
                + "(5) Thiết lập thời gian có thể cho thuê và kiểm tra lại thông tin, "
                + "(6) Gửi đăng tải để hệ thống lưu và chờ duyệt/hiển thị. "
                + "Nếu cần, mình có thể hướng dẫn chi tiết từng bước theo màn hình bạn đang thao tác.";
    }

    private static String buildSizeAdviceMessage(String message) {
        UserProfile profile = extractUserProfile(message);
        if (profile.heightCm != null && profile.weightKg != null) {
            String size = suggestGenericSize(profile.heightCm, profile.weightKg);
            return "Mình đã ghi nhận số đo của bạn: cao " + profile.heightCm + "cm, nặng " + profile.weightKg
                    + "kg. Với form phổ thông, bạn có thể bắt đầu thử size " + size
                    + ". Nếu muốn mặc ôm hơn thì giảm 1 size, muốn thoải mái thì tăng 1 size. "
                    + "Nếu bạn muốn, mình sẽ gợi ý luôn 2-3 kiểu outfit phù hợp cho dịp của bạn.";
        }

        if (profile.heightCm != null) {
            return "Mình đã nhận chiều cao " + profile.heightCm
                    + "cm. Bạn cho mình thêm cân nặng để mình chốt size chính xác hơn nhé.";
        }

        if (profile.weightKg != null) {
            return "Mình đã nhận cân nặng " + profile.weightKg
                    + "kg. Bạn cho mình thêm chiều cao để mình chốt size chính xác hơn nhé.";
        }

        return "Để tư vấn size chính xác, bạn cho mình chiều cao, cân nặng và số đo cơ bản. Mình sẽ gợi ý size phù hợp ngay.";
    }

    private static String buildConsultAdviceMessage(String message,
                                                    boolean hasConsultPurposeFromHistory,
                                                    boolean hasConsultStyleFromHistory,
                                                    UserProfile profileFromHistory) {
        UserProfile profile = mergeUserProfile(extractUserProfile(message), profileFromHistory);
        String normalizedMessage = normalizeForMatching(message);
        if (shouldAskConsultPurposeFirst(normalizedMessage) && !hasConsultPurposeFromHistory) {
            return buildConsultPurposeFirstMessage();
        }

        if (profile.heightCm == null || profile.weightKg == null) {
            return "Cảm ơn bạn! Mình đã ghi nhận nhu cầu về dịp/phong cách. "
                    + "Bây giờ bạn cho mình chiều cao và cân nặng để mình gợi ý size và sản phẩm phù hợp nhé.";
        }

        boolean isParty = containsAny(normalizedMessage, "du tiec", "di tiec", "party", "su kien");

        if (isParty && profile.heightCm != null && profile.weightKg != null && profile.budgetVnd != null) {
            String size = suggestGenericSize(profile.heightCm, profile.weightKg);
            String budgetText = formatBudgetVnd(profile.budgetVnd);
            return "Dựa trên thông tin bạn cung cấp (" + profile.heightCm + "cm, " + profile.weightKg + "kg, ngân sách "
                    + budgetText + "), mình gợi ý 3 hướng đồ dự tiệc dễ thuê:\n"
                    + "1) Blazer tối màu + áo sơ mi sáng + quần tây, size tham khảo " + size + ".\n"
                    + "2) Set vest basic tông đen/xanh navy, ưu tiên form vừa vai để lên dáng gọn.\n"
                    + "3) Smart-casual: blazer + áo cổ lọ/áo thun trơn + quần tây ống đứng.\n"
                    + "Nếu bạn chọn tông màu muốn mặc (đen, navy, be...), mình sẽ chốt phương án phù hợp nhất ngay.";
        }

        if (profile.budgetVnd == null) {
            return "Mình đã có chiều cao/cân nặng của bạn. Bạn cho mình thêm ngân sách thuê để mình lọc đúng các sản phẩm phù hợp nhé.";
        }

        boolean hasStyleNow = extractStyleHint(normalizedMessage) != null || hasConsultStyleFromHistory;
        if (!hasStyleNow) {
            return "Mình đã có chiều cao/cân nặng và ngân sách của bạn. Bạn cho mình thêm phong cách hoặc tông màu mong muốn để mình chốt 2-3 bộ phù hợp nhất nhé.";
        }

        return "Mình đã có đủ thông tin để gợi ý sản phẩm phù hợp. Bạn xem các sản phẩm gợi ý ngay bên dưới, nếu muốn mình sẽ chốt nhanh 2-3 mẫu nổi bật nhất cho bạn.";
    }

    private static UserProfile mergeUserProfile(UserProfile primary, UserProfile fallback) {
        if (primary == null && fallback == null) {
            return new UserProfile(null, null, null);
        }
        if (primary == null) {
            return fallback;
        }
        if (fallback == null) {
            return primary;
        }

        Integer mergedHeight = primary.heightCm != null ? primary.heightCm : fallback.heightCm;
        Integer mergedWeight = primary.weightKg != null ? primary.weightKg : fallback.weightKg;
        Long mergedBudget = primary.budgetVnd != null ? primary.budgetVnd : fallback.budgetVnd;
        return new UserProfile(mergedHeight, mergedWeight, mergedBudget);
    }

    private static String buildRentalAdviceMessage(String message, UserProfile profileFromHistory) {
        UserProfile profile = mergeUserProfile(extractUserProfile(message), profileFromHistory);
        String normalizedMessage = normalizeForMatching(message);
        boolean isAoDai = containsAny(normalizedMessage, "ao dai");
        boolean asksViewProducts = containsAny(normalizedMessage, "xem", "goi y", "san pham", "mau", "cho toi xem");

        if (isAoDai && asksViewProducts) {
            if (profile.heightCm != null && profile.weightKg != null && profile.budgetVnd != null) {
                return "Mình đã lọc sản phẩm áo dài theo thông tin của bạn ("
                        + profile.heightCm + "cm, " + profile.weightKg + "kg, ngân sách " + formatBudgetVnd(profile.budgetVnd)
                        + "). Bạn xem các sản phẩm ngay bên dưới, nếu muốn mình sẽ chốt 2-3 mẫu nổi bật nhất theo phong cách bạn thích.";
            }

            return "Mình đã tìm các sản phẩm áo dài liên quan để bạn tham khảo ngay bên dưới. "
                    + "Nếu bạn muốn lọc chuẩn hơn, bạn cho mình thêm chiều cao-cân nặng và ngân sách thuê nhé.";
        }

        if (isAoDai && profile.heightCm != null && profile.weightKg != null) {
            String size = suggestGenericSize(profile.heightCm, profile.weightKg);
            if (profile.budgetVnd != null) {
                return "Với áo dài và số đo của bạn (" + profile.heightCm + "cm, " + profile.weightKg
                        + "kg), bạn có thể thử size " + size + ". Ngân sách " + formatBudgetVnd(profile.budgetVnd)
                        + " là phù hợp để chọn mẫu basic đến premium tùy chất liệu. Bạn muốn kiểu truyền thống hay cách tân để mình gợi ý cụ thể hơn?";
            }

            return "Với áo dài và số đo của bạn (" + profile.heightCm + "cm, " + profile.weightKg
                    + "kg), bạn có thể thử size " + size
                    + ". Bạn cho mình thêm ngân sách thuê và màu sắc mong muốn để mình gợi ý mẫu phù hợp nhất.";
        }

        return "Mình hỗ trợ thuê trang phục theo nhu cầu của bạn. Bạn cho mình thêm dịp sử dụng, chiều cao-cân nặng và ngân sách thuê để mình gợi ý mẫu phù hợp nhất.";
    }

    private static String buildSystemPrompt(String intent, String knowledgeContext) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Bạn là trợ lý CSKH của WearConnect. ")
            .append("Luôn trả lời bằng tiếng Việt, ngắn gọn, lịch sự, đúng chính sách thuê trang phục của hệ thống. ")
            .append("Không được mặc định cửa hàng chỉ có cosplay; hãy tư vấn theo nhiều nhóm trang phục có sẵn, cosplay chỉ là một nhóm trong số đó. ")
                .append("Không bịa thông tin về giá, khuyến mãi, thời gian, trạng thái đơn. ")
                .append("Nếu thiếu dữ liệu, hãy hỏi tối đa 2 câu làm rõ. ")
                .append("Nếu liên quan hoàn tiền/khiếu nại nhạy cảm, đề xuất chuyển nhân viên. ")
                .append("Ưu tiên tuyệt đối thông tin trong tri thức nội bộ bên dưới; nếu chưa đủ dữ liệu thì nói rõ chưa đủ thông tin. ")
                .append("Intent hiện tại: ").append(intent).append(". ");

        if (knowledgeContext != null && !knowledgeContext.isBlank()) {
            prompt.append("\n\n").append(knowledgeContext);
        } else {
            prompt.append("\n\nHiện chưa tìm thấy tri thức nội bộ phù hợp với câu hỏi này.");
        }

        return prompt.toString();
    }

    private static boolean shouldHandoff(String message, IntentAnalysis intentAnalysis) {
        String normalizedMessage = normalizeForMatching(message);
        if (containsAny(normalizedMessage, "gap nhan vien", "nhan vien", "khong hai long", "khan cap", "lua dao")) {
            return true;
        }

        if (containsAny(normalizedMessage,
                "quy trinh", "dat thue", "quy trinh thue", "quy trinh dat thue", "thu tuc thue",
                "don hang", "trang thai", "thanh toan", "hoan tien", "tra hang", "size",
                "ngan sach", "budget", "trieu", "nghin", "ao dai", "xem san pham", "goi y",
                "dang tai", "dang san pham", "listing", "them trang phuc") ) {
            return false;
        }

        return intentAnalysis.confidence.setScale(4, RoundingMode.HALF_UP).compareTo(new BigDecimal("0.6000")) < 0;
    }

    private static boolean containsAny(String source, String... keywords) {
        for (String keyword : keywords) {
            if (source.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private static String joinDocIds(List<AIKnowledgeDoc> docs) {
        if (docs == null || docs.isEmpty()) {
            return null;
        }

        StringBuilder builder = new StringBuilder();
        for (AIKnowledgeDoc doc : docs) {
            if (doc == null) {
                continue;
            }
            if (builder.length() > 0) {
                builder.append(",");
            }
            builder.append(doc.getDocID());
        }
        return builder.length() == 0 ? null : builder.toString();
    }

    private static String normalizeForMatching(String text) {
        if (text == null || text.isBlank()) {
            return "";
        }

        String lower = text.toLowerCase(Locale.ROOT)
                .replace('đ', 'd')
                .replace('Đ', 'd');

        String normalized = Normalizer.normalize(lower, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .replaceAll("\\s+", " ")
                .trim();

        return normalized;
    }

    private static String normalizeRole(String userRole) {
        if (userRole == null || userRole.isBlank()) {
            return "";
        }
        return userRole.trim().toLowerCase(Locale.ROOT);
    }

    private static RoleRestriction evaluateRoleRestriction(String normalizedMessage, String normalizedRole) {
        if (normalizedMessage == null || normalizedMessage.isBlank()) {
            return RoleRestriction.allow();
        }

        boolean asksUploadProcess = containsAny(normalizedMessage,
                "quy trinh dang tai", "dang tai quan ao", "dang san pham", "them trang phuc", "listing", "quan ly trang phuc");
        boolean asksRentalProcess = containsAny(normalizedMessage,
                "quy trinh thue", "quy trinh dat thue", "thu tuc thue", "dat thue", "thue trang phuc");

        if ("user".equals(normalizedRole) && asksUploadProcess) {
            return RoleRestriction.block(
                    "USER_UPLOAD_PROCESS_BLOCKED",
                    "Nội dung quy trình đăng tải trang phục dành cho tài khoản Manager/Admin. Bạn có thể hỏi mình về quy trình thuê, thanh toán, theo dõi đơn hoặc hoàn tiền."
            );
        }

        if ("manager".equals(normalizedRole) && asksRentalProcess) {
            return RoleRestriction.block(
                    "MANAGER_RENTAL_PROCESS_BLOCKED",
                    "Nội dung quy trình thuê dành cho khách thuê (User). Với tài khoản Manager, mình có thể hỗ trợ quy trình đăng tải/trạng thái duyệt trang phục và quản lý đơn liên quan."
            );
        }

        return RoleRestriction.allow();
    }

    private static UserProfile extractUserProfile(String message) {
        String normalized = normalizeForMatching(message);
        Integer heightCm = extractHeightCm(normalized);
        Integer weightKg = extractWeightKg(normalized);
        Long budgetVnd = extractBudgetVnd(normalized);
        return new UserProfile(heightCm, weightKg, budgetVnd);
    }

    private static Integer extractHeightCm(String normalizedMessage) {
        Matcher metricMatcher = Pattern.compile("\\b(1|2)\\s*(?:m|met)\\s*(\\d{1,2})?\\b").matcher(normalizedMessage);
        if (metricMatcher.find()) {
            int meter = Integer.parseInt(metricMatcher.group(1));
            String centimeterPart = metricMatcher.group(2);
            if (centimeterPart == null || centimeterPart.isBlank()) {
                return meter * 100;
            }

            int centimeter = Integer.parseInt(centimeterPart);
            if (centimeterPart.length() == 1) {
                centimeter = centimeter * 10;
            }
            return meter * 100 + centimeter;
        }

        Matcher cmMatcher = Pattern.compile("\\b(1\\d{2}|2\\d{2})\\s*cm\\b").matcher(normalizedMessage);
        if (cmMatcher.find()) {
            return Integer.parseInt(cmMatcher.group(1));
        }

        return null;
    }

    private static Integer extractWeightKg(String normalizedMessage) {
        Matcher weightMatcher = Pattern.compile("\\b(3\\d|[4-9]\\d|1\\d{2})\\s*(?:kg|kilogram|ky|can)\\b").matcher(normalizedMessage);
        if (weightMatcher.find()) {
            return Integer.parseInt(weightMatcher.group(1));
        }
        return null;
    }

    private static Long extractBudgetVnd(String normalizedMessage) {
        Matcher millionAndThousandMatcher = Pattern.compile("\\b(\\d{1,2})\\s*trieu\\s*(\\d{1,3})\\s*nghin\\b").matcher(normalizedMessage);
        if (millionAndThousandMatcher.find()) {
            long million = Long.parseLong(millionAndThousandMatcher.group(1));
            long thousand = Long.parseLong(millionAndThousandMatcher.group(2));
            return million * 1_000_000L + thousand * 1_000L;
        }

        Matcher millionMatcher = Pattern.compile("\\b(\\d+(?:[\\.,]\\d+)?)\\s*trieu\\b").matcher(normalizedMessage);
        if (millionMatcher.find()) {
            double million = Double.parseDouble(millionMatcher.group(1).replace(',', '.'));
            return Math.round(million * 1_000_000L);
        }

        Matcher thousandMatcher = Pattern.compile("\\b(\\d{2,4})\\s*nghin\\b").matcher(normalizedMessage);
        if (thousandMatcher.find()) {
            long thousand = Long.parseLong(thousandMatcher.group(1));
            return thousand * 1_000L;
        }

        return null;
    }

    private static String suggestGenericSize(int heightCm, int weightKg) {
        if (heightCm >= 175 && weightKg >= 75) {
            return "L";
        }
        if (heightCm >= 170 && weightKg >= 68) {
            return "M-L";
        }
        if (heightCm >= 165 && weightKg >= 58) {
            return "M";
        }
        return "S-M";
    }

    private static String formatBudgetVnd(long budgetVnd) {
        if (budgetVnd >= 1_000_000L) {
            long million = budgetVnd / 1_000_000L;
            long thousandPart = (budgetVnd % 1_000_000L) / 1_000L;
            if (thousandPart == 0) {
                return million + " triệu";
            }
            return million + " triệu " + thousandPart + " nghìn";
        }

        return (budgetVnd / 1_000L) + " nghìn";
    }

    private static String joinDocTitles(List<AIKnowledgeDoc> docs) {
        if (docs == null || docs.isEmpty()) {
            return null;
        }

        StringBuilder builder = new StringBuilder();
        for (AIKnowledgeDoc doc : docs) {
            if (doc == null || doc.getTitle() == null || doc.getTitle().isBlank()) {
                continue;
            }
            if (builder.length() > 0) {
                builder.append(" | ");
            }
            builder.append(doc.getTitle());
        }
        return builder.length() == 0 ? null : builder.toString();
    }

    private static List<AIProductSuggestion> buildProductSuggestions(String message, String intent, List<AIMessage> contextMessages) {
        String normalizedMessage = normalizeForMatching(message);
        if (!shouldSuggestProducts(normalizedMessage, intent)) {
            return Collections.emptyList();
        }

        ProductSearchContext context = extractProductSearchContext(normalizedMessage);
        if (context.isEmpty()) {
            context = extractProductSearchContextFromHistory(contextMessages);
        }
        if (context.isEmpty()) {
            return Collections.emptyList();
        }

        UserProfile profile = mergeUserProfile(extractUserProfile(message), extractUserProfileFromHistory(contextMessages));
        BigDecimal maxDailyPrice = profile.budgetVnd == null ? null : BigDecimal.valueOf(profile.budgetVnd);

        List<Clothing> products = ClothingDAO.searchProductsForAI(
                context.keyword,
                context.occasion,
                context.style,
                context.category,
                6,
                maxDailyPrice
        );

        if ((products == null || products.isEmpty()) && maxDailyPrice != null) {
            products = ClothingDAO.searchProductsForAI(
                context.keyword,
                context.occasion,
                context.style,
                context.category,
                6,
                null
            );
        }

        if ((products == null || products.isEmpty())
            && shouldSuggestProducts(normalizedMessage, intent)
            && context.isEmpty()) {
            products = ClothingDAO.getLatestActiveProductsForAI(6, maxDailyPrice);
        }
        if (products == null || products.isEmpty()) {
            return Collections.emptyList();
        }

        List<AIProductSuggestion> suggestions = new ArrayList<>();
        for (Clothing product : products) {
            if (product == null) {
                continue;
            }

            AIProductSuggestion suggestion = new AIProductSuggestion();
            suggestion.setClothingID(product.getClothingID());
            suggestion.setClothingName(product.getClothingName());
            suggestion.setCategory(product.getCategory());
            suggestion.setStyle(product.getStyle());
            suggestion.setDailyPrice(product.getDailyPriceBigDecimal());
            suggestions.add(suggestion);
        }
        return suggestions;
    }

    private static boolean shouldSuggestProducts(String normalizedMessage, String intent) {
        if ("CONSULT_ADVICE".equals(intent) || "RENTAL_ADVICE".equals(intent)) {
            return true;
        }
        return containsAny(normalizedMessage,
                "xem", "goi y", "de xuat", "san pham", "mau", "lien quan", "co san", "phu hop", "tim", "muon tim");
    }

    private static ProductSearchContext extractProductSearchContext(String normalizedMessage) {
        String keyword = extractProductKeyword(normalizedMessage);
        String occasion = extractOccasionHint(normalizedMessage);
        String style = extractStyleHint(normalizedMessage);
        String category = extractCategoryHint(normalizedMessage);
        return new ProductSearchContext(keyword, occasion, style, category);
    }

    private static String extractProductKeyword(String normalizedMessage) {
        if (containsAny(normalizedMessage, "ao dai")) {
            return "ao dai";
        }
        if (containsAny(normalizedMessage, "cosplay")) {
            return "Cosplay";
        }
        if (containsAny(normalizedMessage, "du tiec", "party")) {
            return "du tiec";
        }
        if (containsAny(normalizedMessage, "vest", "blazer")) {
            return "vest";
        }

        String[] phrasePatterns = new String[] {
            "cho toi xem\\s+([a-z0-9\\s]{2,})$",
            "(?:san pham|mau)\\s+([a-z0-9\\s]{2,})$",
            "(?:xem|goi y|de xuat|tim)\\s+([a-z0-9\\s]{2,})$",
            "(?:toi muon tim|muon tim|de xuat cho toi|goi y cho toi|cho toi xem)\\s+(?:san pham|mau)?\\s*([a-z0-9\\s]{2,})$",
            "(?:cac san pham|nhung san pham)\\s+([a-z0-9\\s]{2,})$"
        };

        for (String pattern : phrasePatterns) {
            Matcher matcher = Pattern.compile(pattern).matcher(normalizedMessage);
            if (!matcher.find()) {
                continue;
            }

            String candidate = matcher.group(1)
                    .replaceAll("\\b(san pham|mau|cho toi|toi|nhe|di|a|nha|nao|voi|giup)\\b", " ")
                    .replaceAll("\\s+", " ")
                    .trim();
            if (!candidate.isBlank()) {
                return candidate;
            }
        }

        String compact = normalizedMessage.replaceAll("[^a-z0-9\\s]", " ").trim();
        if (compact.isBlank()) {
            return "";
        }

        String[] words = compact.split("\\s+");
        StringBuilder builder = new StringBuilder();
        for (String word : words) {
            if (word.length() < 3 || containsAny(word, "cho", "toi", "xem", "cac", "san", "pham", "lien", "quan", "nhe")) {
                continue;
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(word);
            if (builder.length() >= 20) {
                break;
            }
        }

        return builder.toString().trim();
    }

    private static String extractOccasionHint(String normalizedMessage) {
        if (containsAny(normalizedMessage, "tet", "tet nguyen dan", "nam moi", "xuan")) {
            return "tet";
        }
        if (containsAny(normalizedMessage, "du tiec", "party", "tiec", "su kien", "dam cuoi")) {
            return "du tiec";
        }
        if (containsAny(normalizedMessage, "halloween")) {
            return "halloween";
        }
        if (containsAny(normalizedMessage, "giang sinh", "christmas", "noel")) {
            return "giang sinh";
        }
        if (containsAny(normalizedMessage, "chup anh", "quay phim", "concept")) {
            return "chup anh";
        }
        return null;
    }

    private static String extractStyleHint(String normalizedMessage) {
        if (containsAny(normalizedMessage, "sang trong", "thanh lich", "quy phai")) {
            return "sang";
        }
        if (containsAny(normalizedMessage, "ca tinh", "cool", "ngau")) {
            return "ca tinh";
        }
        if (containsAny(normalizedMessage, "truyen thong")) {
            return "truyen thong";
        }
        if (containsAny(normalizedMessage, "cach tan")) {
            return "cach tan";
        }
        return null;
    }

    private static String extractCategoryHint(String normalizedMessage) {
        if (containsAny(normalizedMessage, "cosplay")) {
            return "cosplay";
        }
        if (containsAny(normalizedMessage, "vest", "blazer")) {
            return "vest";
        }
        return null;
    }

    private static ProductSearchContext extractProductSearchContextFromHistory(List<AIMessage> contextMessages) {
        if (contextMessages == null || contextMessages.isEmpty()) {
            return new ProductSearchContext(null, null, null, null);
        }

        String keyword = null;
        String occasion = null;
        String style = null;
        String category = null;

        for (AIMessage message : contextMessages) {
            if (message == null || message.getContent() == null || message.getContent().isBlank()) {
                continue;
            }
            if (!"USER".equalsIgnoreCase(message.getRole())) {
                continue;
            }

            ProductSearchContext derived = extractProductSearchContext(normalizeForMatching(message.getContent()));
            if (derived.keyword != null && !derived.keyword.isBlank()) {
                keyword = derived.keyword;
            }
            if (derived.occasion != null && !derived.occasion.isBlank()) {
                occasion = derived.occasion;
            }
            if (derived.style != null && !derived.style.isBlank()) {
                style = derived.style;
            }
            if (derived.category != null && !derived.category.isBlank()) {
                category = derived.category;
            }
        }

        return new ProductSearchContext(keyword, occasion, style, category);
    }

    private static boolean looksLikeNoProductInfoResponse(String text) {
        if (text == null || text.isBlank()) {
            return true;
        }

        String normalized = normalizeForMatching(text);
        boolean genericNoInfo = containsAny(normalized,
            "khong co thong tin", "khong co du lieu", "khong the de xuat", "khong biet san pham");
        boolean cannotDisplayProducts = containsAny(normalized, "khong the", "khong co the")
            && containsAny(normalized, "hien thi", "xem")
            && containsAny(normalized, "san pham", "hinh anh", "anh");
        return genericNoInfo || cannotDisplayProducts;
    }

    private static String buildProductAvailabilityMessage(List<AIProductSuggestion> suggestions) {
        StringBuilder builder = new StringBuilder("Mình đã tìm thấy một số sản phẩm phù hợp hiện có trên WearConnect: ");
        int count = Math.min(3, suggestions.size());
        for (int i = 0; i < count; i++) {
            AIProductSuggestion suggestion = suggestions.get(i);
            if (suggestion == null || suggestion.getClothingName() == null || suggestion.getClothingName().isBlank()) {
                continue;
            }
            if (builder.charAt(builder.length() - 1) != ' ') {
                builder.append(", ");
            }
            builder.append(suggestion.getClothingName());
        }
        builder.append(". Bạn xem danh sách sản phẩm ngay bên dưới để chọn mẫu phù hợp nhé.");
        return builder.toString();
    }

    private static String buildDirectBrowseResponse(String normalizedMessage) {
        String category = extractCategoryHint(normalizedMessage);
        if (category != null && !category.isBlank()) {
            return "Mình đã hiển thị các sản phẩm " + category + " hiện có ngay bên dưới. "
                    + "Nếu bạn muốn mình tư vấn chuẩn hơn theo dáng người, bạn cho mình thêm chiều cao và cân nặng nhé.";
        }

        return "Mình đã hiển thị một số sản phẩm hiện có ngay bên dưới để bạn tham khảo. "
                + "Nếu cần tư vấn phù hợp vóc dáng, bạn cho mình thêm chiều cao và cân nặng nhé.";
    }

    private static boolean isDirectProductBrowseRequest(String normalizedMessage) {
        return containsAny(normalizedMessage,
                "cho toi xem", "cho xem", "xem san pham", "xem cac san pham", "goi y san pham", "de xuat san pham",
                "hien thi san pham", "xem mau", "xem ao dai", "xem vest",
                "tim san pham", "muon tim san pham", "toi muon tim san pham", "tim ao", "tim dam", "tim vest", "tim ao khoac", "tim ao dai");
    }

    private static boolean shouldAskConsultPurposeFirst(String message) {
        String normalizedMessage = normalizeForMatching(message);
        String occasion = extractOccasionHint(normalizedMessage);
        String style = extractStyleHint(normalizedMessage);
        String category = extractCategoryHint(normalizedMessage);
        return occasion == null && style == null && category == null;
    }

    private static String buildConsultPurposeFirstMessage() {
        return "Chào bạn, để WearConnect có thể tư vấn trang phục phù hợp nhất, bạn vui lòng cho biết:\n\n"
                + "1. Bạn đang tìm trang phục cho dịp nào (ví dụ: sự kiện, tiệc tùng, chụp ảnh, biểu diễn, Halloween, cosplay)?\n"
                + "2. Bạn có phong cách hoặc chủ đề nào muốn hướng tới không (ví dụ: cổ trang, hiện đại, nhân vật cụ thể, trang phục dạ hội)?\n\n"
                + "Sau khi có thông tin này, WearConnect sẽ gợi ý những lựa chọn phù hợp cho bạn.";
    }

    private static boolean hasConsultPurposeFromHistory(List<AIMessage> contextMessages) {
        if (contextMessages == null || contextMessages.isEmpty()) {
            return false;
        }

        for (AIMessage message : contextMessages) {
            if (message == null || message.getContent() == null || message.getContent().isBlank()) {
                continue;
            }

            if (!"USER".equalsIgnoreCase(message.getRole())) {
                continue;
            }

            String normalized = normalizeForMatching(message.getContent());
            if (extractOccasionHint(normalized) != null
                    || extractStyleHint(normalized) != null
                    || extractCategoryHint(normalized) != null) {
                return true;
            }
        }

        return false;
    }

    private static UserProfile extractUserProfileFromHistory(List<AIMessage> contextMessages) {
        if (contextMessages == null || contextMessages.isEmpty()) {
            return new UserProfile(null, null, null);
        }

        Integer heightCm = null;
        Integer weightKg = null;
        Long budgetVnd = null;

        for (AIMessage message : contextMessages) {
            if (message == null || message.getContent() == null || message.getContent().isBlank()) {
                continue;
            }

            if (!"USER".equalsIgnoreCase(message.getRole())) {
                continue;
            }

            UserProfile profile = extractUserProfile(message.getContent());
            if (profile.heightCm != null) {
                heightCm = profile.heightCm;
            }
            if (profile.weightKg != null) {
                weightKg = profile.weightKg;
            }
            if (profile.budgetVnd != null) {
                budgetVnd = profile.budgetVnd;
            }
        }

        return new UserProfile(heightCm, weightKg, budgetVnd);
    }

    private static boolean hasConsultStyleFromHistory(List<AIMessage> contextMessages) {
        if (contextMessages == null || contextMessages.isEmpty()) {
            return false;
        }

        for (AIMessage message : contextMessages) {
            if (message == null || message.getContent() == null || message.getContent().isBlank()) {
                continue;
            }

            if (!"USER".equalsIgnoreCase(message.getRole())) {
                continue;
            }

            String normalized = normalizeForMatching(message.getContent());
            if (extractStyleHint(normalized) != null) {
                return true;
            }
        }

        return false;
    }

    private static RedirectDecision determineRedirect(String message, String intent) {
        String normalizedMessage = normalizeForMatching(message);
        if (isDirectProductBrowseRequest(normalizedMessage)) {
            return new RedirectDecision(false, null);
        }

        if ("CONSULT_ADVICE".equals(intent)) {
            return new RedirectDecision(true, "CONSULT_ADVICE");
        }

        return new RedirectDecision(false, null);
    }

    private static class IntentAnalysis {
        private final String intent;
        private final BigDecimal confidence;

        private IntentAnalysis(String intent, BigDecimal confidence) {
            this.intent = intent;
            this.confidence = confidence;
        }
    }

    private static class RedirectDecision {
        private final boolean redirectToAdvisor;
        private final String redirectReason;

        private RedirectDecision(boolean redirectToAdvisor, String redirectReason) {
            this.redirectToAdvisor = redirectToAdvisor;
            this.redirectReason = redirectReason;
        }
    }

    private static class UserProfile {
        private final Integer heightCm;
        private final Integer weightKg;
        private final Long budgetVnd;

        private UserProfile(Integer heightCm, Integer weightKg, Long budgetVnd) {
            this.heightCm = heightCm;
            this.weightKg = weightKg;
            this.budgetVnd = budgetVnd;
        }
    }

    private static class ProductSearchContext {
        private final String keyword;
        private final String occasion;
        private final String style;
        private final String category;

        private ProductSearchContext(String keyword, String occasion, String style, String category) {
            this.keyword = keyword;
            this.occasion = occasion;
            this.style = style;
            this.category = category;
        }

        private boolean isEmpty() {
            return (keyword == null || keyword.isBlank())
                    && (occasion == null || occasion.isBlank())
                    && (style == null || style.isBlank())
                    && (category == null || category.isBlank());
        }
    }

    private static class RoleRestriction {
        private final boolean blocked;
        private final String code;
        private final String message;

        private RoleRestriction(boolean blocked, String code, String message) {
            this.blocked = blocked;
            this.code = code;
            this.message = message;
        }

        private static RoleRestriction allow() {
            return new RoleRestriction(false, null, null);
        }

        private static RoleRestriction block(String code, String message) {
            return new RoleRestriction(true, code, message);
        }
    }
}
