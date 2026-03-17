package com.wearconnect.chatbot.service;

import com.wearconnect.chatbot.dto.PolicyResponse;

public interface PolicyChatService {

    PolicyResponse getPolicy(String topic);
}
