package com.wearconnect.chatbot.service;

import com.wearconnect.chatbot.dto.DepositStatusResponse;

public interface DepositChatService {

    DepositStatusResponse getDepositStatus(String orderCode);
}
