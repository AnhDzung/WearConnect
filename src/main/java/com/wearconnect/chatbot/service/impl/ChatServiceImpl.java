package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.client.N8nChatClient;
import com.wearconnect.chatbot.dto.ChatRequest;
import com.wearconnect.chatbot.dto.ChatResponse;
import com.wearconnect.chatbot.service.ChatService;
import org.springframework.stereotype.Service;

@Service
public class ChatServiceImpl implements ChatService {

    private final N8nChatClient n8nChatClient;

    public ChatServiceImpl(N8nChatClient n8nChatClient) {
        this.n8nChatClient = n8nChatClient;
    }

    @Override
    public ChatResponse process(ChatRequest request) {
        return n8nChatClient.send(request);
    }
}
