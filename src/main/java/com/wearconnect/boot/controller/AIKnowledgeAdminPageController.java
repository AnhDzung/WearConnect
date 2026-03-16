package com.wearconnect.boot.controller;

import Controller.AIKnowledgeController;
import Model.AIKnowledgeAuditLog;
import Model.AIKnowledgeDoc;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Controller
@RequestMapping("/admin/ai-knowledge")
public class AIKnowledgeAdminPageController {

    private static final Gson GSON = new Gson();

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Integer operatorID = getAuthorizedOperatorID(request.getSession(false), response);
        if (operatorID == null) {
            return;
        }

        Map<String, Object> result = new HashMap<>();
        String action = request.getParameter("action");

        if ("audit".equalsIgnoreCase(action)) {
            handleGetAuditLogs(request, response);
            return;
        }

        int docID = parseInteger(request.getParameter("docID"), -1);
        if (docID > 0) {
            AIKnowledgeDoc doc = AIKnowledgeController.getDocById(docID);
            if (doc == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                result.put("success", false);
                result.put("error", "DOC_NOT_FOUND");
            } else {
                result.put("success", true);
                result.put("data", toPayloadDoc(doc));
            }
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        String keyword = request.getParameter("q");
        boolean includeInactive = "true".equalsIgnoreCase(request.getParameter("includeInactive"));
        int limit = parseInteger(request.getParameter("limit"), 50);

        List<AIKnowledgeDoc> docs = AIKnowledgeController.getDocsForAdmin(keyword, includeInactive, limit);
        List<Map<String, Object>> payload = new ArrayList<>();
        for (AIKnowledgeDoc doc : docs) {
            payload.add(toPayloadDoc(doc));
        }

        result.put("success", true);
        result.put("count", payload.size());
        result.put("data", payload);
        response.getWriter().write(GSON.toJson(result));
    }

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Integer operatorID = getAuthorizedOperatorID(request.getSession(false), response);
        if (operatorID == null) {
            return;
        }

        HttpSession session = request.getSession(false);
        String operatorRole = getUserRole(session);
        String ipAddress = getClientIpAddress(request);
        String userAgent = request.getHeader("User-Agent");

        Map<String, Object> body;
        try {
            body = parseRequestBody(request);
        } catch (JsonSyntaxException exception) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "INVALID_JSON_PAYLOAD");
            return;
        }

        String action = getAction(request, body);
        if ("create".equals(action)) {
            handleCreate(body, operatorID, operatorRole, ipAddress, userAgent, response);
            return;
        }
        if ("update".equals(action)) {
            handleUpdate(body, operatorID, operatorRole, ipAddress, userAgent, response);
            return;
        }
        if ("delete".equals(action) || "deactivate".equals(action)) {
            handleDeactivate(body, operatorID, operatorRole, ipAddress, userAgent, response);
            return;
        }

        Map<String, Object> result = new HashMap<>();
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        result.put("success", false);
        result.put("error", "INVALID_ACTION");
        result.put("supportedActions", List.of("create", "update", "delete"));
        response.getWriter().write(GSON.toJson(result));
    }

    private void handleGetAuditLogs(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer docID = parseNullableInteger(request.getParameter("docID"));
        Integer operatorID = parseNullableInteger(request.getParameter("operatorID"));
        String actionFilter = request.getParameter("auditAction");
        int limit = parseInteger(request.getParameter("limit"), 100);

        List<AIKnowledgeAuditLog> logs = AIKnowledgeController.getAuditLogs(docID, operatorID, actionFilter, limit);
        List<Map<String, Object>> payload = new ArrayList<>();
        for (AIKnowledgeAuditLog log : logs) {
            Map<String, Object> item = new HashMap<>();
            item.put("auditID", log.getAuditID());
            item.put("docID", log.getDocID());
            item.put("action", log.getAction());
            item.put("operatorID", log.getOperatorID());
            item.put("operatorRole", log.getOperatorRole());
            item.put("summary", log.getSummary());
            item.put("createdAt", log.getFormattedCreatedAt());
            item.put("ipAddress", log.getIpAddress());
            item.put("beforeSnapshot", compactSnapshot(log.getBeforeSnapshot()));
            item.put("afterSnapshot", compactSnapshot(log.getAfterSnapshot()));
            payload.add(item);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("count", payload.size());
        result.put("data", payload);
        response.getWriter().write(GSON.toJson(result));
    }

    private void handleCreate(Map<String, Object> body, int operatorID, String operatorRole,
                              String ipAddress, String userAgent, HttpServletResponse response) throws IOException {
        String title = getString(body, "title");
        String category = getString(body, "category");
        String content = getString(body, "content");
        String tags = getString(body, "tags");

        int createdID = AIKnowledgeController.createDoc(title, category, content, tags, operatorID, operatorRole, ipAddress, userAgent);
        Map<String, Object> result = new HashMap<>();

        if (createdID <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "INVALID_INPUT_OR_CREATE_FAILED");
            result.put("message", "Vui long kiem tra Tieu de/Noi dung va thu lai. Danh muc de trong se tu gan GENERAL.");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        AIKnowledgeDoc createdDoc = AIKnowledgeController.getDocById(createdID);
        result.put("success", true);
        result.put("message", "CREATED");
        result.put("data", createdDoc == null ? null : toPayloadDoc(createdDoc));
        response.getWriter().write(GSON.toJson(result));
    }

    private void handleUpdate(Map<String, Object> body, int operatorID, String operatorRole,
                              String ipAddress, String userAgent, HttpServletResponse response) throws IOException {
        Integer docID = parseNullableInteger(body.get("docID"));
        String title = getString(body, "title");
        String category = getString(body, "category");
        String content = getString(body, "content");
        String tags = getString(body, "tags");
        boolean isActive = parseBoolean(body.get("isActive"), true);

        Map<String, Object> result = new HashMap<>();
        if (docID == null || docID <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "docID is required");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        boolean updated = AIKnowledgeController.updateDoc(docID, title, category, content, tags, isActive, operatorID, operatorRole, ipAddress, userAgent);
        if (!updated) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "UPDATE_FAILED");
            result.put("message", "Khong the cap nhat tai lieu. Vui long kiem tra du lieu dau vao.");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        AIKnowledgeDoc updatedDoc = AIKnowledgeController.getDocById(docID);
        result.put("success", true);
        result.put("message", "UPDATED");
        result.put("data", updatedDoc == null ? null : toPayloadDoc(updatedDoc));
        response.getWriter().write(GSON.toJson(result));
    }

    private void handleDeactivate(Map<String, Object> body, int operatorID, String operatorRole,
                                  String ipAddress, String userAgent, HttpServletResponse response) throws IOException {
        Integer docID = parseNullableInteger(body.get("docID"));
        Map<String, Object> result = new HashMap<>();

        if (docID == null || docID <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "docID is required");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        boolean deactivated = AIKnowledgeController.deactivateDoc(docID, operatorID, operatorRole, ipAddress, userAgent);
        if (!deactivated) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "DELETE_FAILED");
            response.getWriter().write(GSON.toJson(result));
            return;
        }

        result.put("success", true);
        result.put("message", "DEACTIVATED");
        result.put("docID", docID);
        response.getWriter().write(GSON.toJson(result));
    }

    private Integer getAuthorizedOperatorID(HttpSession session, HttpServletResponse response) throws IOException {
        if (session == null || session.getAttribute("account") == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED");
            return null;
        }

        String userRole = session.getAttribute("userRole") == null ? "" : session.getAttribute("userRole").toString().trim();
        if (!("Admin".equals(userRole) || "Manager".equals(userRole))) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN");
            return null;
        }

        Integer accountID = parseNullableInteger(session.getAttribute("accountID"));
        if (accountID == null || accountID <= 0) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "INVALID_ACCOUNT_SESSION");
            return null;
        }

        return accountID;
    }

    private Map<String, Object> parseRequestBody(HttpServletRequest request) throws IOException {
        BufferedReader reader = request.getReader();
        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            stringBuilder.append(line);
        }

        String rawBody = stringBuilder.toString();
        if (rawBody.trim().isEmpty()) {
            return new HashMap<>();
        }

        Map<String, Object> body = GSON.fromJson(rawBody, Map.class);
        return body == null ? new HashMap<>() : body;
    }

    private String getAction(HttpServletRequest request, Map<String, Object> body) {
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = getString(body, "action");
        }
        if (action == null) {
            return "";
        }
        return action.trim().toLowerCase(Locale.ROOT);
    }

    private String getUserRole(HttpSession session) {
        if (session == null || session.getAttribute("userRole") == null) {
            return null;
        }
        String role = session.getAttribute("userRole").toString().trim();
        return role.isEmpty() ? null : role;
    }

    private String getClientIpAddress(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.trim().isEmpty()) {
            String[] parts = forwarded.split(",");
            if (parts.length > 0) {
                return parts[0].trim();
            }
        }
        return request.getRemoteAddr();
    }

    private Map<String, Object> toPayloadDoc(AIKnowledgeDoc doc) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("docID", doc.getDocID());
        payload.put("title", doc.getTitle());
        payload.put("category", doc.getCategory());
        payload.put("content", doc.getContent());
        payload.put("tags", doc.getTags());
        payload.put("isActive", doc.isActive());
        payload.put("updatedBy", doc.getUpdatedBy());
        payload.put("updatedAt", doc.getFormattedUpdatedAt());
        return payload;
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

    private boolean parseBoolean(Object value, boolean defaultValue) {
        if (value == null) {
            return defaultValue;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }

        String normalized = value.toString().trim().toLowerCase(Locale.ROOT);
        if ("true".equals(normalized) || "1".equals(normalized) || "yes".equals(normalized)) {
            return true;
        }
        if ("false".equals(normalized) || "0".equals(normalized) || "no".equals(normalized)) {
            return false;
        }
        return defaultValue;
    }

    private String getString(Map<String, Object> body, String key) {
        Object value = body.get(key);
        if (value == null) {
            return null;
        }
        String text = value.toString().trim();
        return text.isEmpty() ? null : text;
    }

    private String compactSnapshot(String snapshot) {
        if (snapshot == null || snapshot.isBlank()) {
            return null;
        }
        String normalized = snapshot.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= 300) {
            return normalized;
        }
        return normalized.substring(0, 300) + "...";
    }

    private void writeError(HttpServletResponse response, int status, String errorCode) throws IOException {
        response.setStatus(status);
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("error", errorCode);
        response.getWriter().write(GSON.toJson(result));
    }
}
