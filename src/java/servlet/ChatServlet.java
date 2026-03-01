package servlet;

import Controller.AIChatController;
import Model.AIChatReply;
import Model.AIConversation;
import Model.AIMessage;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatServlet extends HttpServlet {

    private static final Gson GSON = new Gson();
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> result = new HashMap<>();
        Integer userID = getSessionUserID(request.getSession(false));
        if (userID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("error", "UNAUTHORIZED");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        String action = request.getParameter("action") == null
                ? "history"
                : request.getParameter("action").trim().toLowerCase();

        if ("conversations".equals(action)) {
            int limit = parseInteger(request.getParameter("limit"), 20);
            List<AIConversation> conversations = AIChatController.getRecentConversations(userID, limit);

            List<Map<String, Object>> payloadConversations = new ArrayList<>();
            for (AIConversation conversation : conversations) {
                Map<String, Object> payloadConversation = new HashMap<>();
                payloadConversation.put("conversationID", conversation.getConversationID());
                payloadConversation.put("status", conversation.getStatus());
                payloadConversation.put("channel", conversation.getChannel());
                payloadConversation.put("startedAt", formatDateTime(conversation.getStartedAt()));
                payloadConversation.put("lastMessageAt", formatDateTime(conversation.getLastMessageAt()));
                payloadConversations.add(payloadConversation);
            }

            result.put("success", true);
            result.put("conversations", payloadConversations);
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        String conversationIDParam = request.getParameter("conversationID");
        int conversationID = parseInteger(conversationIDParam, -1);
        int limit = parseInteger(request.getParameter("limit"), 20);

        if (conversationID <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "conversationID is required");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        List<AIMessage> messages = AIChatController.getConversationHistory(userID, conversationID, limit);
        List<Map<String, Object>> payloadMessages = new ArrayList<>();
        for (AIMessage message : messages) {
            Map<String, Object> payloadMessage = new HashMap<>();
            payloadMessage.put("messageID", message.getMessageID());
            payloadMessage.put("conversationID", message.getConversationID());
            payloadMessage.put("role", message.getRole());
            payloadMessage.put("content", message.getContent());
            payloadMessage.put("intent", message.getIntent());
            payloadMessage.put("confidence", message.getConfidence());
            payloadMessage.put("responseSource", message.getResponseSource());
            payloadMessage.put("createdAt", message.getFormattedCreatedAt());
            payloadMessages.add(payloadMessage);
        }

        result.put("success", true);
        result.put("messages", payloadMessages);
        response.getWriter().write(GSON.toJson(result));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> result = new HashMap<>();
        Integer userID = getSessionUserID(request.getSession(false));
        if (userID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("error", "UNAUTHORIZED");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        Map<String, Object> requestData = parseRequestBody(request);
        String action = requestData.get("action") == null ? "chat" : requestData.get("action").toString().trim().toLowerCase();

        if ("feedback".equals(action)) {
            handleFeedback(userID, requestData, response);
            return;
        }

        if ("new_conversation".equals(action)) {
            Integer newConversationID = AIChatController.createNewConversation(userID);
            if (newConversationID == null || newConversationID <= 0) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.put("success", false);
                result.put("error", "CREATE_CONVERSATION_FAILED");
                response.getWriter().write(GSON.toJson(result));
                return;
            }

            Map<String, Object> payload = new HashMap<>();
            payload.put("conversationID", newConversationID);
            result.put("success", true);
            result.put("data", payload);
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        String message = requestData.get("message") == null ? null : requestData.get("message").toString();
        Integer conversationID = parseNullableInteger(requestData.get("conversationID"));

        AIChatReply reply = AIChatController.sendUserMessage(userID, conversationID, message);

        Map<String, Object> payload = new HashMap<>();
        payload.put("conversationID", reply.getConversationID());
        payload.put("userMessageID", reply.getUserMessageID());
        payload.put("assistantMessageID", reply.getAssistantMessageID());
        payload.put("assistantMessage", reply.getAssistantMessage());
        payload.put("intent", reply.getIntent());
        payload.put("confidence", safeConfidence(reply.getConfidence()));
        payload.put("responseSource", reply.getResponseSource());
        payload.put("handedOff", reply.isHandedOff());
        payload.put("handoffReason", reply.getHandoffReason());
        payload.put("redirectToAdvisor", reply.isRedirectToAdvisor());
        payload.put("redirectReason", reply.getRedirectReason());

        result.put("success", true);
        result.put("data", payload);
        response.getWriter().write(GSON.toJson(result));
    }

    private void handleFeedback(int userID, Map<String, Object> requestData, HttpServletResponse response) throws IOException {
        Integer assistantMessageID = parseNullableInteger(requestData.get("assistantMessageID"));
        Integer rating = parseNullableInteger(requestData.get("rating"));
        Boolean isHelpful = parseNullableBoolean(requestData.get("isHelpful"));
        String note = requestData.get("note") == null ? null : requestData.get("note").toString();

        Map<String, Object> result = new HashMap<>();
        if (assistantMessageID == null || rating == null || isHelpful == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "assistantMessageID, rating, isHelpful are required");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        boolean saved = AIChatController.submitAssistantFeedback(userID, assistantMessageID, rating, isHelpful, note);
        if (!saved) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "FEEDBACK_SAVE_FAILED");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        result.put("success", true);
        result.put("message", "FEEDBACK_SAVED");
        response.getWriter().write(GSON.toJson(result));
    }

    private Integer getSessionUserID(HttpSession session) {
        if (session == null || session.getAttribute("accountID") == null) {
            return null;
        }
        Object accountID = session.getAttribute("accountID");
        if (accountID instanceof Integer) {
            return (Integer) accountID;
        }
        return parseNullableInteger(accountID);
    }

    private Map<String, Object> parseRequestBody(HttpServletRequest request) throws IOException {
        BufferedReader reader = request.getReader();
        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            stringBuilder.append(line);
        }
        String requestBody = stringBuilder.toString();
        if (requestBody.trim().isEmpty()) {
            return new HashMap<>();
        }
        Map<String, Object> data = GSON.fromJson(requestBody, Map.class);
        if (data == null) {
            return new HashMap<>();
        }
        return data;
    }

    private Integer parseNullableInteger(Object value) {
        if (value == null) {
            return null;
        }
        try {
            if (value instanceof Number) {
                return ((Number) value).intValue();
            }
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private int parseInteger(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            return defaultValue;
        }
    }

    private String safeConfidence(BigDecimal confidence) {
        if (confidence == null) {
            return "0.0000";
        }
        return confidence.toPlainString();
    }

    private Boolean parseNullableBoolean(Object value) {
        if (value == null) {
            return null;
        }

        if (value instanceof Boolean) {
            return (Boolean) value;
        }

        String normalized = value.toString().trim().toLowerCase();
        if ("true".equals(normalized) || "1".equals(normalized) || "yes".equals(normalized)) {
            return true;
        }
        if ("false".equals(normalized) || "0".equals(normalized) || "no".equals(normalized)) {
            return false;
        }
        return null;
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return value.format(DATE_TIME_FORMATTER);
    }
}
