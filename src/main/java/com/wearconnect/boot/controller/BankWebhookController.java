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
            System.out.println("\n[Webhook] === ĐÃ NHẬN ĐƯỢC REQUEST TỪ PAYOS ===");
            System.out.println("[Webhook] Dữ liệu Payload: " + payload);
            // Lưu ý: Cấu trúc payload sẽ phụ thuộc vào dịch vụ bạn dùng (PayOS/Casso).
            // Dưới đây là ví dụ trích xuất dữ liệu cơ bản.
            
            // Lấy nội dung chuyển khoản và số tiền từ payload
            // Ví dụ với giả định payload có dạng { "description": "WC 123", "amount": 500000 }
            String description = "";
            double amount = 0.0;

            if (payload != null) {
                Map<String, Object> targetMap = payload;
                
                // PayOS thường bọc dữ liệu thực tế bên trong object "data"
                if (payload.containsKey("data") && payload.get("data") instanceof Map) {
                    targetMap = (Map<String, Object>) payload.get("data");
                }
                
                Object descObj = targetMap.get("description");
                if (descObj != null) {
                    description = String.valueOf(descObj);
                }
                
                Object amountObj = targetMap.get("amount");
                if (amountObj != null) {
                    try {
                        amount = Double.parseDouble(String.valueOf(amountObj));
                    } catch (NumberFormatException ex) {
                        System.err.println("[Webhook] Parse số tiền thất bại, bỏ qua: " + amountObj);
                    }
                }
            }

            if (!description.isEmpty() && amount > 0) {
                // Gửi dữ liệu sang Service để xử lý tự động xác nhận đơn hàng
                BankTransferService.processAutomaticWebhook(description, amount);
            } else {
                System.out.println("[Webhook] Dữ liệu mẫu kiểm tra kết nối từ PayOS, không xử lý.");
            }

            // Trả về 200 OK để bên dịch vụ biết server đã nhận được thành công
            return ResponseEntity.ok("{\"status\": \"success\"}");
        } catch (Exception e) {
            e.printStackTrace();
            // QUAN TRỌNG: Luôn trả về 200 OK để PayOS chấp nhận URL cấu hình
            return ResponseEntity.ok("{\"status\": \"error\", \"message\": \"Internal Server Error\"}");
        }
    }
}