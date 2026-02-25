package Service;

import DAO.AIChatDAO;
import Model.AIChatReply;
import Model.AIConversation;
import Model.AIKnowledgeDoc;
import Model.AIMessage;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

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
                assistantMessage = buildAssistantMessage(intentAnalysis.intent, false);
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
        String lowerCaseMessage = message.toLowerCase(Locale.ROOT);

        if (containsAny(lowerCaseMessage,
                "tư vấn", "tu van", "gợi ý", "goi y", "phối đồ", "phoi do", "phong cách", "style", "chọn đồ", "chon do")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.9000"));
        }

        if (containsAny(lowerCaseMessage, "hoàn tiền", "refund", "trả hàng", "return", "khiếu nại")) {
            return new IntentAnalysis("RETURN_REFUND", new BigDecimal("0.8600"));
        }

        if (containsAny(lowerCaseMessage, "đơn hàng", "order", "trạng thái", "giao hàng")) {
            return new IntentAnalysis("ORDER_SUPPORT", new BigDecimal("0.8200"));
        }

        if (containsAny(lowerCaseMessage, "size", "kích cỡ", "vòng", "cao", "nặng")) {
            return new IntentAnalysis("SIZE_ADVICE", new BigDecimal("0.7800"));
        }

        if (containsAny(lowerCaseMessage, "thanh toán", "payment", "chuyển khoản", "cọc")) {
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

        if ("CONSULT_ADVICE".equals(intent)) {
            return "Đây là câu hỏi tư vấn chuyên sâu, mình sẽ chuyển bạn sang trang tư vấn AI để hỗ trợ đầy đủ hơn.";
        }

        if ("PAYMENT_SUPPORT".equals(intent)) {
            return "Với thanh toán và tiền cọc, bạn vui lòng cung cấp mã đơn để mình kiểm tra trạng thái xác nhận chi tiết.";
        }

        if ("RETURN_REFUND".equals(intent)) {
            return "Mình có thể hỗ trợ quy trình trả đồ và hoàn tiền. Bạn cho mình mã đơn và tình trạng hiện tại để xử lý đúng chính sách.";
        }

        return "Mình có thể hỗ trợ về đơn hàng, size cosplay, thanh toán, trả hàng và hoàn tiền. Bạn nói rõ nhu cầu để mình hỗ trợ nhanh hơn nhé.";
    }

    private static String buildSystemPrompt(String intent, String knowledgeContext) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Bạn là trợ lý CSKH của WearConnect. ")
                .append("Luôn trả lời bằng tiếng Việt, ngắn gọn, lịch sự, đúng chính sách thuê cosplay. ")
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
        String lowerCaseMessage = message.toLowerCase(Locale.ROOT);
        if (containsAny(lowerCaseMessage, "gặp nhân viên", "nhân viên", "không hài lòng", "khẩn cấp", "lừa đảo")) {
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
}
