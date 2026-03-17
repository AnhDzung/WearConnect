package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.dto.DepositStatusResponse;
import com.wearconnect.chatbot.service.DepositChatService;
import java.math.BigDecimal;
import org.springframework.stereotype.Service;

@Service
public class DepositChatServiceImpl implements DepositChatService {

    @Override
    public DepositStatusResponse getDepositStatus(String orderCode) {
        return new DepositStatusResponse(
                1001L,
                new BigDecimal("300000"),
                "PENDING",
                true,
                new BigDecimal("300000")
        );
    }
}
