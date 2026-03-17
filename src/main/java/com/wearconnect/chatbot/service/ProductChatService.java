package com.wearconnect.chatbot.service;

import com.wearconnect.chatbot.dto.ProductAvailabilityResponse;

public interface ProductChatService {

    ProductAvailabilityResponse getAvailability(String itemCode);
}
