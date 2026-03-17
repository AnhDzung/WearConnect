package com.wearconnect.chatbot.dto;

import java.util.Map;

public record ChatResponse(
        String reply,
        String intent,
        Map<String, Object> metadata
) {
    public static ChatResponse fallback() {
    return fallback("Unknown chatbot error");
    }

    public static ChatResponse fallback(String reason) {
        return new ChatResponse(
                "He thong chatbot dang ban. Vui long thu lai sau it phut.",
                "FALLBACK",
        Map.of(
            "source", "spring-fallback",
            "reason", reason
        )
        );
    }
}
