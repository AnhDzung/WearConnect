package com.wearconnect.chatbot.controller;

import com.wearconnect.chatbot.dto.DepositStatusResponse;
import com.wearconnect.chatbot.dto.OrderStatusResponse;
import com.wearconnect.chatbot.dto.PolicyResponse;
import com.wearconnect.chatbot.dto.ProductAvailabilityResponse;
import com.wearconnect.chatbot.service.DepositChatService;
import com.wearconnect.chatbot.service.OrderChatService;
import com.wearconnect.chatbot.service.PolicyChatService;
import com.wearconnect.chatbot.service.ProductChatService;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/internal/chat")
public class InternalChatController {

    private final OrderChatService orderChatService;
    private final DepositChatService depositChatService;
    private final ProductChatService productChatService;
    private final PolicyChatService policyChatService;

    public InternalChatController(OrderChatService orderChatService,
                                  DepositChatService depositChatService,
                                  ProductChatService productChatService,
                                  PolicyChatService policyChatService) {
        this.orderChatService = orderChatService;
        this.depositChatService = depositChatService;
        this.productChatService = productChatService;
        this.policyChatService = policyChatService;
    }

    @GetMapping("/order-status")
    public ResponseEntity<OrderStatusResponse> getOrderStatus(
            @RequestParam("orderCode") @NotBlank String orderCode) {
        return ResponseEntity.ok(orderChatService.getOrderStatus(orderCode));
    }

    @GetMapping("/deposit-status")
    public ResponseEntity<DepositStatusResponse> getDepositStatus(
            @RequestParam("orderCode") @NotBlank String orderCode) {
        return ResponseEntity.ok(depositChatService.getDepositStatus(orderCode));
    }

    @GetMapping("/product-availability")
    public ResponseEntity<ProductAvailabilityResponse> getProductAvailability(
            @RequestParam("itemCode") @NotBlank String itemCode) {
        return ResponseEntity.ok(productChatService.getAvailability(itemCode));
    }

    @GetMapping("/policy")
    public ResponseEntity<PolicyResponse> getPolicy(@RequestParam("topic") @NotBlank String topic) {
        return ResponseEntity.ok(policyChatService.getPolicy(topic));
    }
}
