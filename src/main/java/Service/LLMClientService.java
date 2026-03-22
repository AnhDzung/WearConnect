package Service;

import Model.AIMessage;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import config.AIProviderConfig;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.time.Duration;
import java.util.List;

public class LLMClientService {

    private static final Gson GSON = new Gson();

    public static String generateReply(String systemPrompt, List<AIMessage> recentMessages, String userMessage) {
        if (!AIProviderConfig.isEnabled()) {
            return null;
        }

        String provider = AIProviderConfig.getProvider();
        try {
            if ("gemini".equals(provider)) {
                return callGemini(systemPrompt, recentMessages, userMessage);
            }
            return callOpenAI(systemPrompt, recentMessages, userMessage);
        } catch (Exception exception) {
            System.err.println("[LLMClientService] LLM call failed: " + exception.getMessage());
            return null;
        }
    }

    public static String generateReplyWithImage(String systemPrompt, String userMessage, byte[] imageBytes, String mimeType) {
        if (!AIProviderConfig.isEnabled() || imageBytes == null || imageBytes.length == 0) {
            return null;
        }

        String provider = AIProviderConfig.getProvider();
        try {
            if ("gemini".equals(provider)) {
                return callGeminiWithImage(systemPrompt, userMessage, imageBytes, mimeType);
            }
            return null;
        } catch (Exception exception) {
            System.err.println("[LLMClientService] Vision LLM call failed: " + exception.getMessage());
            return null;
        }
    }

    private static String callOpenAI(String systemPrompt, List<AIMessage> recentMessages, String userMessage)
            throws IOException, InterruptedException {
        JsonObject payload = new JsonObject();
        payload.addProperty("model", AIProviderConfig.getModel());
        payload.addProperty("temperature", AIProviderConfig.getTemperature());
        payload.addProperty("max_tokens", AIProviderConfig.getMaxTokens());

        JsonArray messages = new JsonArray();
        messages.add(createMessage("system", systemPrompt));

        if (recentMessages != null) {
            for (AIMessage message : recentMessages) {
                String mappedRole = mapRoleToLLM(message.getRole());
                if ("system".equals(mappedRole) || message.getContent() == null || message.getContent().isBlank()) {
                    continue;
                }
                messages.add(createMessage(mappedRole, message.getContent()));
            }
        }

        messages.add(createMessage("user", userMessage));
        payload.add("messages", messages);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(AIProviderConfig.getEndpoint()))
                .timeout(Duration.ofSeconds(AIProviderConfig.getTimeoutSeconds()))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + AIProviderConfig.getApiKey())
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(payload)))
                .build();

        HttpResponse<String> response = createClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            System.err.println("[LLMClientService] OpenAI HTTP " + response.statusCode() + " body=" + response.body());
            return null;
        }

        JsonObject responseJson = GSON.fromJson(response.body(), JsonObject.class);
        if (responseJson == null || !responseJson.has("choices") || responseJson.getAsJsonArray("choices").isEmpty()) {
            return null;
        }

        JsonObject firstChoice = responseJson.getAsJsonArray("choices").get(0).getAsJsonObject();
        JsonObject message = firstChoice.getAsJsonObject("message");
        if (message == null || !message.has("content")) {
            return null;
        }

        return sanitizeReply(message.get("content").getAsString());
    }

    private static String callGemini(String systemPrompt, List<AIMessage> recentMessages, String userMessage)
            throws IOException, InterruptedException {
        JsonObject payload = new JsonObject();

        JsonObject systemInstruction = new JsonObject();
        JsonArray systemParts = new JsonArray();
        JsonObject systemText = new JsonObject();
        systemText.addProperty("text", systemPrompt);
        systemParts.add(systemText);
        systemInstruction.add("parts", systemParts);
        payload.add("systemInstruction", systemInstruction);

        JsonArray contents = new JsonArray();
        if (recentMessages != null) {
            for (AIMessage message : recentMessages) {
                if (message.getContent() == null || message.getContent().isBlank()) {
                    continue;
                }
                JsonObject content = new JsonObject();
                content.addProperty("role", "ASSISTANT".equalsIgnoreCase(message.getRole()) ? "model" : "user");
                JsonArray parts = new JsonArray();
                JsonObject textPart = new JsonObject();
                textPart.addProperty("text", message.getContent());
                parts.add(textPart);
                content.add("parts", parts);
                contents.add(content);
            }
        }

        JsonObject userContent = new JsonObject();
        userContent.addProperty("role", "user");
        JsonArray userParts = new JsonArray();
        JsonObject userText = new JsonObject();
        userText.addProperty("text", userMessage);
        userParts.add(userText);
        userContent.add("parts", userParts);
        contents.add(userContent);

        payload.add("contents", contents);

        JsonObject generationConfig = new JsonObject();
        generationConfig.addProperty("temperature", AIProviderConfig.getTemperature());
        generationConfig.addProperty("maxOutputTokens", AIProviderConfig.getMaxTokens());
        payload.add("generationConfig", generationConfig);

        String endpoint = AIProviderConfig.getEndpoint() + "?key=" + URLEncoder.encode(AIProviderConfig.getApiKey(), StandardCharsets.UTF_8);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(endpoint))
                .timeout(Duration.ofSeconds(AIProviderConfig.getTimeoutSeconds()))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(payload)))
                .build();

        HttpResponse<String> response = createClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            System.err.println("[LLMClientService] Gemini HTTP " + response.statusCode() + " body=" + response.body());
            return null;
        }

        JsonObject responseJson = GSON.fromJson(response.body(), JsonObject.class);
        if (responseJson == null || !responseJson.has("candidates") || responseJson.getAsJsonArray("candidates").isEmpty()) {
            return null;
        }

        JsonObject candidate = responseJson.getAsJsonArray("candidates").get(0).getAsJsonObject();
        if (!candidate.has("content")) {
            return null;
        }

        JsonObject content = candidate.getAsJsonObject("content");
        if (!content.has("parts") || content.getAsJsonArray("parts").isEmpty()) {
            return null;
        }

        JsonObject firstPart = content.getAsJsonArray("parts").get(0).getAsJsonObject();
        if (!firstPart.has("text")) {
            return null;
        }

        return sanitizeReply(firstPart.get("text").getAsString());
    }

    private static String callGeminiWithImage(String systemPrompt, String userMessage, byte[] imageBytes, String mimeType)
            throws IOException, InterruptedException {
        JsonObject payload = new JsonObject();

        JsonObject systemInstruction = new JsonObject();
        JsonArray systemParts = new JsonArray();
        JsonObject systemText = new JsonObject();
        systemText.addProperty("text", systemPrompt);
        systemParts.add(systemText);
        systemInstruction.add("parts", systemParts);
        payload.add("systemInstruction", systemInstruction);

        JsonArray contents = new JsonArray();
        JsonObject userContent = new JsonObject();
        userContent.addProperty("role", "user");

        JsonArray userParts = new JsonArray();
        JsonObject userText = new JsonObject();
        userText.addProperty("text", userMessage);
        userParts.add(userText);

        JsonObject imagePart = new JsonObject();
        JsonObject inlineData = new JsonObject();
        inlineData.addProperty("mimeType", (mimeType == null || mimeType.isBlank()) ? "image/png" : mimeType);
        inlineData.addProperty("data", Base64.getEncoder().encodeToString(imageBytes));
        imagePart.add("inlineData", inlineData);
        userParts.add(imagePart);

        userContent.add("parts", userParts);
        contents.add(userContent);
        payload.add("contents", contents);

        JsonObject generationConfig = new JsonObject();
        generationConfig.addProperty("temperature", Math.min(0.2, AIProviderConfig.getTemperature()));
        generationConfig.addProperty("maxOutputTokens", AIProviderConfig.getMaxTokens());
        payload.add("generationConfig", generationConfig);

        String endpoint = AIProviderConfig.getEndpoint() + "?key=" + URLEncoder.encode(AIProviderConfig.getApiKey(), StandardCharsets.UTF_8);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(endpoint))
                .timeout(Duration.ofSeconds(Math.max(25, AIProviderConfig.getTimeoutSeconds())))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(payload)))
                .build();

        HttpResponse<String> response = createClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            System.err.println("[LLMClientService] Gemini Vision HTTP " + response.statusCode() + " body=" + response.body());
            return null;
        }

        JsonObject responseJson = GSON.fromJson(response.body(), JsonObject.class);
        if (responseJson == null || !responseJson.has("candidates") || responseJson.getAsJsonArray("candidates").isEmpty()) {
            return null;
        }

        JsonObject candidate = responseJson.getAsJsonArray("candidates").get(0).getAsJsonObject();
        if (!candidate.has("content")) {
            return null;
        }

        JsonObject content = candidate.getAsJsonObject("content");
        if (!content.has("parts") || content.getAsJsonArray("parts").isEmpty()) {
            return null;
        }

        JsonObject firstPart = content.getAsJsonArray("parts").get(0).getAsJsonObject();
        if (!firstPart.has("text")) {
            return null;
        }

        return sanitizeReply(firstPart.get("text").getAsString());
    }

    private static HttpClient createClient() {
        return HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(AIProviderConfig.getTimeoutSeconds()))
                .build();
    }

    private static JsonObject createMessage(String role, String content) {
        JsonObject message = new JsonObject();
        message.addProperty("role", role);
        message.addProperty("content", content);
        return message;
    }

    private static String mapRoleToLLM(String role) {
        if ("ASSISTANT".equalsIgnoreCase(role)) {
            return "assistant";
        }
        if ("USER".equalsIgnoreCase(role)) {
            return "user";
        }
        return "system";
    }

    private static String sanitizeReply(String rawReply) {
        if (rawReply == null) {
            return null;
        }

        String reply = rawReply.trim();
        if (reply.isBlank()) {
            return null;
        }

        if (reply.length() > 1200) {
            return reply.substring(0, 1200).trim() + "...";
        }

        return reply;
    }
}
