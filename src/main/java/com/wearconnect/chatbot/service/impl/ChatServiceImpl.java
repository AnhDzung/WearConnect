package com.wearconnect.chatbot.service.impl;

import com.wearconnect.chatbot.dto.ChatRequest;
import com.wearconnect.chatbot.dto.ChatResponse;
import com.wearconnect.chatbot.dto.DepositStatusResponse;
import com.wearconnect.chatbot.dto.OrderStatusResponse;
import com.wearconnect.chatbot.dto.PolicyResponse;
import com.wearconnect.chatbot.dto.ProductAvailabilityResponse;
import com.wearconnect.chatbot.service.ChatService;
import com.wearconnect.chatbot.service.DepositChatService;
import com.wearconnect.chatbot.service.OrderChatService;
import com.wearconnect.chatbot.service.PolicyChatService;
import com.wearconnect.chatbot.service.ProductChatService;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ChatServiceImpl implements ChatService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ChatServiceImpl.class);
    private static final int MAX_HISTORY_MESSAGES = 6;

    private final ChatClient chatClient;
    private final String systemPrompt;
    private final OrderChatService orderChatService;
    private final DepositChatService depositChatService;
    private final ProductChatService productChatService;
    private final PolicyChatService policyChatService;
    private final Map<String, ArrayDeque<String>> sessionHistory = new ConcurrentHashMap<>();

    public ChatServiceImpl(ChatClient.Builder chatClientBuilder,
                           @Value("${app.chatbot.system-prompt}") String systemPrompt,
                           OrderChatService orderChatService,
                           DepositChatService depositChatService,
                           ProductChatService productChatService,
                           PolicyChatService policyChatService) {
        this.chatClient = chatClientBuilder.build();
        this.systemPrompt = systemPrompt;
        this.orderChatService = orderChatService;
        this.depositChatService = depositChatService;
        this.productChatService = productChatService;
        this.policyChatService = policyChatService;
    }

    @Override
    public ChatResponse process(ChatRequest request) {
        String intent = detectIntent(request.message());
        String historyContext = buildHistoryContext(request.sessionId(), request.message());
        String businessContext = buildBusinessContext(intent, request.message());

        try {
            String reply = chatClient.prompt()
                    .system(systemPrompt)
                    .user(buildUserPrompt(request.message(), intent, historyContext, businessContext))
                    .call()
                    .content();

            if (reply == null || reply.isBlank()) {
                LOGGER.warn("Gemini returned empty content for session {}", request.sessionId());
                return ChatResponse.fallback("Gemini returned empty content");
            }

            Map<String, Object> metadata = new LinkedHashMap<>();
            metadata.put("source", "spring-ai-gemini");
            metadata.put("sessionId", request.sessionId());
            metadata.put("userId", request.userId());
            metadata.put("intent", intent);
            metadata.put("historySize", sessionHistory.getOrDefault(request.sessionId(), new ArrayDeque<>()).size());

            appendAssistantMessage(request.sessionId(), reply);

            return new ChatResponse(reply, intent, metadata);
        }
        catch (Exception ex) {
            LOGGER.error("Gemini call failed for session {}", request.sessionId(), ex);
            String errorDetail = ex.getClass().getSimpleName() + ": " + safeMessage(ex);
            String normalizedError = errorDetail.toLowerCase();

            if (normalizedError.contains("quota")
                    || normalizedError.contains("resource_exhausted")
                    || normalizedError.contains("429")) {
                return ChatResponse.fallback(
                        "He thong AI tam het han muc su dung. Vui long thu lai sau it phut hoac lien he admin de nang quota Gemini.",
                        errorDetail
                );
            }

            if (normalizedError.contains("api key")
                    || normalizedError.contains("permission")
                    || normalizedError.contains("unauthorized")
                    || normalizedError.contains("403")
                    || normalizedError.contains("401")) {
                return ChatResponse.fallback(
                        "Cau hinh AI key chua hop le hoac khong du quyen. Vui long kiem tra GEMINI_API_KEY.",
                        errorDetail
                );
            }

            if (normalizedError.contains("model") && normalizedError.contains("not found")) {
                return ChatResponse.fallback(
                        "Model AI cau hinh khong ton tai. Vui long kiem tra bien GEMINI_MODEL.",
                        errorDetail
                );
            }

            return ChatResponse.fallback(errorDetail);
        }
    }

    private String safeMessage(Exception ex) {
        String message = deepestMessage(ex);
        if (message == null || message.isBlank()) {
            return "No detail message";
        }
        return message.length() > 200 ? message.substring(0, 200) + "..." : message;
    }

    private String deepestMessage(Throwable throwable) {
        Throwable current = throwable;
        String candidate = throwable == null ? null : throwable.getMessage();
        int guard = 0;

        while (current != null && guard < 10) {
            if (current.getMessage() != null && !current.getMessage().isBlank()) {
                candidate = current.getMessage();
            }
            current = current.getCause();
            guard++;
        }

        return candidate;
    }

    private String buildUserPrompt(String userMessage,
                                   String intent,
                                   String historyContext,
                                   String businessContext) {
        return "Ngu canh hoi thoai gan day:\n" + historyContext
                + "\n\nNgu canh nghiep vu lien quan:\n" + businessContext
                + "\n\nIntent suy luan: " + intent
                + "\nCau hoi hien tai cua khach: " + userMessage
                + "\n\nHay tra loi tieng Viet, ngan gon, dung trong pham vi WearConnect.";
    }

    private String buildHistoryContext(String sessionId, String currentMessage) {
        ArrayDeque<String> history = sessionHistory.computeIfAbsent(sessionId, key -> new ArrayDeque<>());
        synchronized (history) {
            history.addLast("USER: " + currentMessage);
            while (history.size() > MAX_HISTORY_MESSAGES) {
                history.removeFirst();
            }
            return String.join("\n", new ArrayList<>(history));
        }
    }

    private void appendAssistantMessage(String sessionId, String assistantReply) {
        ArrayDeque<String> history = sessionHistory.computeIfAbsent(sessionId, key -> new ArrayDeque<>());
        synchronized (history) {
            history.addLast("ASSISTANT: " + assistantReply);
            while (history.size() > MAX_HISTORY_MESSAGES) {
                history.removeFirst();
            }
        }
    }

    private String buildBusinessContext(String intent, String message) {
        List<String> lines = new ArrayList<>();
        String normalizedMessage = message == null ? "" : message.toLowerCase();

        if ("PRODUCT_AVAILABILITY".equals(intent)) {
            ProductAvailabilityResponse product = productChatService.getAvailability("AO-DAI-001");
            lines.add("San pham mau: " + product.productName() + ", con hang=" + product.available()
                    + ", thoi diem san sang=" + product.nextAvailableTime());
        }

        if ("POLICY".equals(intent) || "POLICY_RETURN".equals(intent)) {
            String topic = normalizedMessage.contains("doi") || normalizedMessage.contains("tra") || normalizedMessage.contains("hoan")
                    ? "return"
                    : "rental";
            PolicyResponse policy = policyChatService.getPolicy(topic);
            lines.add("Chinh sach lien quan: " + policy.content());
        }

        if ("DEPOSIT".equals(intent)) {
            DepositStatusResponse deposit = depositChatService.getDepositStatus("ORDER-1001");
            lines.add("Thong tin coc: trang thai=" + deposit.depositStatus()
                    + ", so tien=" + deposit.depositAmount()
                    + ", duoc hoan=" + deposit.refundEligible());
        }

        if (normalizedMessage.contains("don") || normalizedMessage.contains("order")) {
            OrderStatusResponse order = orderChatService.getOrderStatus("ORDER-1001");
            lines.add("Thong tin don: status=" + order.status()
                    + ", coc=" + order.depositStatus()
                    + ", bat dau=" + order.rentalStart()
                    + ", ket thuc=" + order.rentalEnd());
        }

        if (lines.isEmpty()) {
            lines.add("Khong co du lieu bo sung dac thu cho truy van nay.");
        }

        return String.join("\n", lines);
    }

    private String detectIntent(String message) {
        String normalizedMessage = message == null ? "" : message.toLowerCase();

        if (normalizedMessage.contains("doi") || normalizedMessage.contains("tra") || normalizedMessage.contains("hoan")) {
            return "POLICY_RETURN";
        }
        if (normalizedMessage.contains("coc") || normalizedMessage.contains("dat coc")) {
            return "DEPOSIT";
        }
        if (normalizedMessage.contains("chinh sach") || normalizedMessage.contains("quy dinh")) {
            return "POLICY";
        }
        if (normalizedMessage.contains("ao dai")
                || normalizedMessage.contains("size")
                || normalizedMessage.contains("mau")
                || normalizedMessage.contains("san pham")
                || normalizedMessage.contains("tu van")) {
            return "PRODUCT_AVAILABILITY";
        }
        return "GENERAL_SUPPORT";
    }
}
