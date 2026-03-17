package com.wearconnect.chatbot.dto;

public record ProductAvailabilityResponse(
        Long productId,
        String productName,
        boolean available,
        String nextAvailableTime
) {
}
