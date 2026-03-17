package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.dto.ChatRequest;
import com.wearconnect.chatbot.dto.ChatResponse;
import com.wearconnect.chatbot.service.ChatService;
import java.util.LinkedHashMap;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ChatServiceImpl implements ChatService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ChatServiceImpl.class);

    private final ChatClient chatClient;
    private final String systemPrompt;

    public ChatServiceImpl(ChatClient.Builder chatClientBuilder,
                           @Value("${app.chatbot.system-prompt}") String systemPrompt) {
        this.chatClient = chatClientBuilder.build();
        this.systemPrompt = systemPrompt;
    }

    @Override
    public ChatResponse process(ChatRequest request) {
        try {
            String reply = chatClient.prompt()
                    .system(systemPrompt)
                    .user(request.message())
                    .call()
                    .content();

            Map<String, Object> metadata = new LinkedHashMap<>();
            metadata.put("source", "spring-ai-gemini");
            metadata.put("sessionId", request.sessionId());
            metadata.put("userId", request.userId());

            return new ChatResponse(reply, detectIntent(request.message()), metadata);
        }
        catch (Exception ex) {
            LOGGER.error("Gemini call failed for session {}", request.sessionId(), ex);
            return ChatResponse.fallback();
        }
    }

    private String detectIntent(String message) {
        String normalizedMessage = message == null ? "" : message.toLowerCase();

        if (normalizedMessage.contains("doi") || normalizedMessage.contains("tra") || normalizedMessage.contains("hoan")) {
            return "POLICY_RETURN";
        }
        if (normalizedMessage.contains("coc") || normalizedMessage.contains("dat coc")) {
            return "DEPOSIT";
        }
        if (normalizedMessage.contains("chinh sach") || normalizedMessage.contains("quy dinh")) {
            return "POLICY";
        }
        if (normalizedMessage.contains("ao dai")
                || normalizedMessage.contains("size")
                || normalizedMessage.contains("mau")
                || normalizedMessage.contains("san pham")
                || normalizedMessage.contains("tu van")) {
            return "PRODUCT_AVAILABILITY";
        }
        return "GENERAL_SUPPORT";
    }
}
