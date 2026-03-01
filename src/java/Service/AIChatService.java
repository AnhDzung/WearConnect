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

    public static AIChatReply handleUserMessage(int userID, Integer conversationID, String userMessage) {
        String normalizedMessage = userMessage == null ? "" : userMessage.trim();
        if (normalizedMessage.isEmpty()) {
            AIChatReply invalidReply = new AIChatReply();
            invalidReply.setAssistantMessage("Bạn vui lòng nhập nội dung cần hỗ trợ.");
            invalidReply.setIntent("INVALID");
            invalidReply.setConfidence(new BigDecimal("0.0000"));
            return invalidReply;
        }

        int resolvedConversationID = resolveConversationID(userID, conversationID);
        if (resolvedConversationID <= 0) {
            AIChatReply failedReply = new AIChatReply();
            failedReply.setAssistantMessage("Hệ thống tạm thời không thể mở hội thoại. Bạn vui lòng thử lại sau ít phút.");
            failedReply.setIntent("SYSTEM_ERROR");
            failedReply.setConfidence(new BigDecimal("0.0000"));
            return failedReply;
        }

        IntentAnalysis intentAnalysis = analyzeIntent(normalizedMessage);
        RedirectDecision redirectDecision = determineRedirect(normalizedMessage, intentAnalysis.intent);
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
            List<AIMessage> contextMessages = AIChatDAO.getRecentMessages(resolvedConversationID, LLM_CONTEXT_MESSAGE_LIMIT);
            retrievedDocs = AIKnowledgeService.getTopDocsForChat(normalizedMessage, intentAnalysis.intent, 3);
            String knowledgeContext = AIKnowledgeService.buildKnowledgeContextFromDocs(retrievedDocs);
            String llmReply = LLMClientService.generateReply(
                buildSystemPrompt(intentAnalysis.intent, knowledgeContext),
                    contextMessages,
                    normalizedMessage
            );

            if (llmReply != null && !llmReply.isBlank()) {
                assistantMessage = llmReply;
                responseSource = "LLM";
            } else {
                assistantMessage = buildRuleBasedAssistantMessage(intentAnalysis.intent, normalizedMessage);
                responseSource = "RULE";
            }
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
        reply.setProductSuggestions(buildProductSuggestions(normalizedMessage));
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
            "ao dai", "thue ao dai", "thue trang phuc", "tim trang phuc", "can thue do", "muon thue do")) {
            return new IntentAnalysis("RENTAL_ADVICE", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "tu van", "goi y", "phoi do", "phong cach", "style", "chon do",
            "di du tiec", "du tiec", "trang phuc", "outfit", "set do", "bo de thue", "thue di")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.9000"));
        }

        if (containsAny(normalizedMessage, "hoan tien", "refund", "tra hang", "return", "khieu nai")) {
            return new IntentAnalysis("RETURN_REFUND", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage, "don hang", "order", "trang thai", "giao hang")) {
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

        if ("SIZE_ADVICE".equals(intent)) {
            return "Để tư vấn size chính xác, bạn cho mình chiều cao, cân nặng và số đo cơ bản. Mình sẽ gợi ý size phù hợp ngay.";
        }

        if ("RENTAL_ADVICE".equals(intent)) {
            return "Mình hỗ trợ thuê áo dài nhé. Bạn cho mình thêm 3 thông tin: giới tính/mẫu mong muốn, chiều cao-cân nặng, và ngân sách thuê. Mình sẽ gợi ý các mẫu phù hợp đang có.";
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

    private static String buildRuleBasedAssistantMessage(String intent, String message) {
        if ("SIZE_ADVICE".equals(intent)) {
            return buildSizeAdviceMessage(message);
        }

        if ("RENTAL_ADVICE".equals(intent)) {
            return buildRentalAdviceMessage(message);
        }

        if ("CONSULT_ADVICE".equals(intent)) {
            return buildConsultAdviceMessage(message);
        }

        return buildAssistantMessage(intent, false);
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

    private static String buildConsultAdviceMessage(String message) {
        UserProfile profile = extractUserProfile(message);
        String normalizedMessage = normalizeForMatching(message);
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

        List<String> missing = new ArrayList<>();
        if (profile.heightCm == null || profile.weightKg == null) {
            missing.add("chiều cao-cân nặng");
        }
        if (profile.budgetVnd == null) {
            missing.add("ngân sách thuê");
        }

        if (missing.isEmpty()) {
            return "Mình đã có đủ thông tin cơ bản. Bạn cho mình thêm tông màu và phong cách mong muốn để mình chốt 2-3 bộ phù hợp nhất.";
        }

        return "Mình có thể tư vấn ngay. Bạn cho mình thêm " + String.join(" và ", missing)
                + " để mình gợi ý 2-3 bộ phù hợp nhất theo sản phẩm hiện có.";
    }

    private static String buildRentalAdviceMessage(String message) {
        UserProfile profile = extractUserProfile(message);
        String normalizedMessage = normalizeForMatching(message);
        boolean isAoDai = containsAny(normalizedMessage, "ao dai");

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

        return "Mình hỗ trợ thuê áo dài nhé. Bạn cho mình thêm chiều cao-cân nặng, ngân sách thuê và kiểu mong muốn (truyền thống/cách tân) để mình gợi ý mẫu phù hợp.";
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

    private static List<AIProductSuggestion> buildProductSuggestions(String message) {
        String normalizedMessage = normalizeForMatching(message);
        if (!shouldSuggestProducts(normalizedMessage)) {
            return Collections.emptyList();
        }

        String keyword = extractProductKeyword(normalizedMessage);
        if (keyword == null || keyword.isBlank()) {
            return Collections.emptyList();
        }

        UserProfile profile = extractUserProfile(message);
        BigDecimal maxDailyPrice = profile.budgetVnd == null ? null : BigDecimal.valueOf(profile.budgetVnd);

        List<Clothing> products = ClothingDAO.searchProductsForAI(keyword, 6, maxDailyPrice);
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

    private static boolean shouldSuggestProducts(String normalizedMessage) {
        return containsAny(normalizedMessage,
                "xem", "goi y", "de xuat", "san pham", "mau", "lien quan", "co san");
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

    private static RedirectDecision determineRedirect(String message, String intent) {
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
}
