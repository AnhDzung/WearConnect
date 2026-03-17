package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.dto.OrderStatusResponse;
import com.wearconnect.chatbot.service.OrderChatService;
import org.springframework.stereotype.Service;

@Service
public class OrderChatServiceImpl implements OrderChatService {

    @Override
    public OrderStatusResponse getOrderStatus(String orderCode) {
        return new OrderStatusResponse(
                1001L,
                "PROCESSING",
                "PAID",
                "2025-03-01 10:00",
                "2025-03-03 10:00",
                "2025-03-04 10:00"
        );
    }
}
