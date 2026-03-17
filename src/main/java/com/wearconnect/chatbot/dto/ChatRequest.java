package com.wearconnect.chatbot.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ChatRequest(
        @NotNull(message = "userId is required")
        Long userId,

        @NotBlank(message = "sessionId is required")
        String sessionId,

        @NotBlank(message = "message is required")
        String message
) {
}
