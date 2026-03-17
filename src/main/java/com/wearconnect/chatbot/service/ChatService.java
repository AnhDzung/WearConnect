package com.wearconnect.chatbot.service;

import com.wearconnect.chatbot.dto.ChatRequest;
import com.wearconnect.chatbot.dto.ChatResponse;

public interface ChatService {

    ChatResponse process(ChatRequest request);
}
