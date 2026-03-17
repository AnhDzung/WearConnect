package com.wearconnect.chatbot.client;

import com.wearconnect.chatbot.config.N8nProperties;
import com.wearconnect.chatbot.dto.ChatRequest;
import com.wearconnect.chatbot.dto.ChatResponse;
import java.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Component
public class N8nChatClient {

    private static final Logger LOGGER = LoggerFactory.getLogger(N8nChatClient.class);

    private final WebClient n8nWebClient;
    private final N8nProperties n8nProperties;

    public N8nChatClient(WebClient n8nWebClient, N8nProperties n8nProperties) {
        this.n8nWebClient = n8nWebClient;
        this.n8nProperties = n8nProperties;
    }

    public ChatResponse send(ChatRequest request) {
        return n8nWebClient.post()
                .uri(n8nProperties.getWebhookUrl())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ChatResponse.class)
                .timeout(Duration.ofMillis(n8nProperties.getTimeoutMs()))
                .onErrorResume(ex -> {
                    LOGGER.error("n8n call failed for session {}", request.sessionId(), ex);
                    return Mono.just(ChatResponse.fallback());
                })
                .block();
    }
}
