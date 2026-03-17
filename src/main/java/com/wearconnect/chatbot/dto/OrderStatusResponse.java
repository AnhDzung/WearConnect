package com.wearconnect.chatbot.dto;

public record OrderStatusResponse(
        Long orderId,
        String status,
        String depositStatus,
        String rentalStart,
        String rentalEnd,
        String returnDeadline
) {
}
