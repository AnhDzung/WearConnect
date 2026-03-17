package com.wearconnect.chatbot.dto;

import java.math.BigDecimal;

public record DepositStatusResponse(
        Long orderId,
        BigDecimal depositAmount,
        String depositStatus,
        boolean refundEligible,
        BigDecimal refundAmount
) {
}
