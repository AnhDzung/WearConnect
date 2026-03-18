package com.wearconnect.boot.controller;

import Controller.AIChatController;
import Model.AIChatReply;
import Model.AIConversation;
import Model.AIMessage;
import Model.AIProductSuggestion;
import com.google.gson.Gson;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.ServletException;
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

@Controller
public class ChatPageController {

    private static final Gson GSON = new Gson();
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @RequestMapping("/advisor-chat")
    public void advisorChat(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/user/ai-advisor.jsp").forward(request, response);
    }

    @RequestMapping("/chat")
    public void chat(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            handleGetChat(request, response);
            return;
        }
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            handlePostChat(request, response);
            return;
        }
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void handleGetChat(HttpServletRequest request, HttpServletResponse response) throws IOException {
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

        int conversationID = parseInteger(request.getParameter("conversationID"), -1);
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

    private void handlePostChat(HttpServletRequest request, HttpServletResponse response) throws IOException {
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

        if ("delete_all_conversations".equals(action)) {
            boolean cleared = AIChatController.clearUserHistory(userID);
            if (!cleared) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.put("success", false);
                result.put("error", "DELETE_ALL_CONVERSATIONS_FAILED");
                result.put("detail", "Khong the xoa toan bo hoi thoai o thoi diem hien tai");
                response.getWriter().write(GSON.toJson(result));
                return;
            }

            result.put("success", true);
            result.put("message", "ALL_CONVERSATIONS_DELETED");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        if ("delete_conversation".equals(action)) {
            Integer conversationIDToDelete = parseNullableInteger(requestData.get("conversationID"));
            if (conversationIDToDelete == null || conversationIDToDelete <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("success", false);
                result.put("error", "conversationID is required");
                response.getWriter().write(GSON.toJson(result));
                return;
            }

            boolean deleted = AIChatController.deleteConversation(userID, conversationIDToDelete);
            if (!deleted) {
                boolean stillExists = AIChatController.conversationExistsForUser(userID, conversationIDToDelete);
                if (!stillExists) {
                    result.put("success", true);
                    result.put("message", "CONVERSATION_ALREADY_REMOVED");
                    response.getWriter().write(GSON.toJson(result));
                    return;
                }

                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.put("success", false);
                result.put("error", "DELETE_CONVERSATION_FAILED");
                result.put("detail", "Khong the xoa hoi thoai o thoi diem hien tai");
                response.getWriter().write(GSON.toJson(result));
                return;
            }

            result.put("success", true);
            result.put("message", "CONVERSATION_DELETED");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        String message = requestData.get("message") == null ? null : requestData.get("message").toString();
        Integer conversationID = parseNullableInteger(requestData.get("conversationID"));
        String userRole = getSessionUserRole(request.getSession(false));

        AIChatReply reply = AIChatController.sendUserMessage(userID, userRole, conversationID, message);

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
        payload.put("productSuggestions", mapProductSuggestions(reply.getProductSuggestions()));

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

    private String getSessionUserRole(HttpSession session) {
        if (session == null || session.getAttribute("userRole") == null) {
            return "";
        }
        String role = session.getAttribute("userRole").toString().trim();
        return role.isEmpty() ? "" : role;
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
        return data == null ? new HashMap<>() : data;
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

    private String formatDateTime(LocalDateTime dateTime) {
        if (dateTime == null) {
            return null;
        }
        return dateTime.format(DATE_TIME_FORMATTER);
    }

    private List<Map<String, Object>> mapProductSuggestions(List<AIProductSuggestion> suggestions) {
        List<Map<String, Object>> payloadSuggestions = new ArrayList<>();
        if (suggestions == null) {
            return payloadSuggestions;
        }

        for (AIProductSuggestion suggestion : suggestions) {
            Map<String, Object> payload = new HashMap<>();
            payload.put("clothingID", suggestion.getClothingID());
            payload.put("clothingName", suggestion.getClothingName());
            payload.put("category", suggestion.getCategory());
            payload.put("style", suggestion.getStyle());
            payload.put("dailyPrice", suggestion.getDailyPrice() == null ? "" : suggestion.getDailyPrice().toPlainString());
            payloadSuggestions.add(payload);
        }
        return payloadSuggestions;
    }
}
