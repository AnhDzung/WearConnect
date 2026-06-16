package com.wearconnect.boot.controller;

import Service.BankTransferService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/webhooks")
public class BankWebhookController {

    /**
     * API này sẽ được gọi tự động bởi các bên thứ 3 (Casso, PayOS, SePay)
     * khi tài khoản ngân hàng của bạn có biến động số dư.
     */
    @PostMapping("/bank-transfer")
    public ResponseEntity<String> handleBankTransferWebhook(@RequestBody Map<String, Object> payload) {
        try {
            // Lưu ý: Cấu trúc payload sẽ phụ thuộc vào dịch vụ bạn dùng (PayOS/Casso).
            // Dưới đây là ví dụ trích xuất dữ liệu cơ bản.
            
            // Lấy nội dung chuyển khoản và số tiền từ payload
            // Ví dụ với giả định payload có dạng { "description": "WC 123", "amount": 500000 }
            String description = "";
            double amount = 0.0;

            if (payload.containsKey("data")) {
                Map<String, Object> data = (Map<String, Object>) payload.get("data");
                description = String.valueOf(data.getOrDefault("description", ""));
                amount = Double.parseDouble(String.valueOf(data.getOrDefault("amount", "0")));
            } else {
                description = String.valueOf(payload.getOrDefault("description", ""));
                amount = Double.parseDouble(String.valueOf(payload.getOrDefault("amount", "0")));
            }

            if (!description.isEmpty() && amount > 0) {
                // Gửi dữ liệu sang Service để xử lý tự động xác nhận đơn hàng
                BankTransferService.processAutomaticWebhook(description, amount);
            }

            // Trả về 200 OK để bên dịch vụ biết server đã nhận được thành công
            return ResponseEntity.ok("{\"status\": \"success\"}");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("{\"status\": \"error\"}");
        }
    }
}