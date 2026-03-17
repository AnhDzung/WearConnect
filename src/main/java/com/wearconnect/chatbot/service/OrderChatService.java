package com.wearconnect.chatbot.service;

import com.wearconnect.chatbot.dto.OrderStatusResponse;

public interface OrderChatService {

    OrderStatusResponse getOrderStatus(String orderCode);
}
