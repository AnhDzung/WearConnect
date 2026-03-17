package com.wearconnect.chatbot.dto;

import java.time.Instant;
import java.util.Map;

public record ErrorResponse(
        String code,
        String message,
        Instant timestamp,
        String path,
        Map<String, Object> details
) {
}
