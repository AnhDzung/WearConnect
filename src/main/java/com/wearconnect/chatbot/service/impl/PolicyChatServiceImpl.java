package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.dto.PolicyResponse;
import com.wearconnect.chatbot.service.PolicyChatService;
import org.springframework.stereotype.Service;

@Service
public class PolicyChatServiceImpl implements PolicyChatService {

    @Override
    public PolicyResponse getPolicy(String topic) {
        String normalizedTopic = topic == null ? "general" : topic.trim().toLowerCase();

        String content = switch (normalizedTopic) {
            case "return", "refund" -> "Chinh sach doi tra: bao cao trong 24h, hoan tien theo quy trinh kiem tra.";
            case "deposit" -> "Chinh sach tien coc: coc truoc de giu do, hoan coc sau khi hoan tat don thue.";
            case "rental" -> "Chinh sach thue: dat lich truoc, tra do dung han de tranh phat.";
            default -> "Chinh sach chung: vui long lien he CSKH de duoc huong dan chi tiet.";
        };

        return new PolicyResponse(topic, content);
    }
}
