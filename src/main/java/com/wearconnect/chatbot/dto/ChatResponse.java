package com.wearconnect.chatbot.dto;

import java.util.Map;

public record ChatResponse(
        String reply,
        String intent,
        Map<String, Object> metadata
) {
    public static ChatResponse fallback() {
    return fallback("He thong chatbot dang ban. Vui long thu lai sau it phut.", "Unknown chatbot error");
    }

    public static ChatResponse fallback(String reason) {
        return fallback("He thong chatbot dang ban. Vui long thu lai sau it phut.", reason);
    }

    public static ChatResponse fallback(String reply, String reason) {
        return new ChatResponse(
                reply,
                "FALLBACK",
        Map.of(
            "source", "spring-fallback",
            "reason", reason
        )
        );
    }
}
