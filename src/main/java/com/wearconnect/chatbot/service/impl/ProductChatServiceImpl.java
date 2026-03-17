package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.dto.ProductAvailabilityResponse;
import com.wearconnect.chatbot.service.ProductChatService;
import org.springframework.stereotype.Service;

@Service
public class ProductChatServiceImpl implements ProductChatService {

    @Override
    public ProductAvailabilityResponse getAvailability(String itemCode) {
        return new ProductAvailabilityResponse(
                2001L,
                "Ao dai truyen thong",
                true,
                "Now"
        );
    }
}
