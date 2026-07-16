package Service;

import config.BankTransferConfig;
import Model.Payment;
import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
import Service.NotificationService;
import Model.RentalOrder;
import java.util.List;

/**
 * Service for handling bank transfer payments
 */
public class BankTransferService {
    
    /**
     * Get bank transfer details for a payment
     */
    public static BankTransferConfig.BankDetails getBankTransferDetails(int rentalOrderID, double amount) {
        return BankTransferConfig.getMBBankDetails(amount, rentalOrderID);
    }
    
    /**
     * Verify bank transfer payment
     * In a real system, this would integrate with the bank's API or payment gateway
     */
    public static boolean verifyBankTransfer(int paymentID, String transactionReference) {
        Payment payment = PaymentDAO.getPaymentByID(paymentID);
        
        if (payment == null || !payment.getPaymentMethod().equals("BANK_TRANSFER")) {
            return false;
        }
        
        // Mark payment as completed
        return PaymentDAO.updatePaymentStatus(paymentID, "COMPLETED");
    }
    
    /**
     * Process bank transfer payment
     */
    public static int processBankTransfer(int rentalOrderID, boolean isDeposit) {
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) return -1;
        
        double amount = isDeposit ? order.getDepositAmount() : order.getTotalPrice();
        Payment payment = new Payment(rentalOrderID, amount, "BANK_TRANSFER");
        
        int paymentID = PaymentDAO.addPayment(payment);
        
        if (paymentID > 0) {
            // Payment status remains PENDING until bank transfer is verified
            // In production, you would trigger bank reconciliation here
        }
        
        return paymentID;
    }
    
    /**
     * Get bank details for displaying to user
     */
    public static BankTransferConfig.BankDetails getDisplayBankDetails(int rentalOrderID, double amount) {
        BankTransferConfig.BankDetails details = BankTransferConfig.getMBBankDetails(amount, rentalOrderID);
        Model.RentalOrder order = DAO.RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order != null && order.getOrderCode() != null && !order.getOrderCode().isEmpty()) {
            details.setOrderReference(order.getOrderCode());
        }
        return details;
    }
    
    /**
     * Tạo URL mã QR động qua API VietQR
     */
    public static String generateVietQRUrl(int rentalOrderID, double amount) {
        try {
            // Tên viết tắt ngân hàng (Do bạn đang dùng MB Bank trong BankTransferConfig)
            String bankId = "MB"; 
            
            // Loại bỏ khoảng trắng ở số tài khoản (nếu có) để tránh lỗi link
            String accountNo = BankTransferConfig.BANK_ACCOUNT_NUMBER.replaceAll("\\s+", "");
            
            // Đảm bảo số tiền không bị dính dấu phẩy do cấu hình Locale (Ví dụ: "500,000" -> lỗi mã QR)
            String formattedAmount = String.valueOf(Math.round(amount));
            
            // Tạo nội dung chuyển khoản chuẩn với giao diện (VD: WRC00001)
            String orderReference = "WRC" + String.format("%05d", rentalOrderID);
            Model.RentalOrder order = DAO.RentalOrderDAO.getRentalOrderByID(rentalOrderID);
            if (order != null && order.getOrderCode() != null && !order.getOrderCode().isEmpty()) {
                orderReference = order.getOrderCode();
            }
            
            String addInfo = java.net.URLEncoder.encode(orderReference, "UTF-8").replace("+", "%20");
            String accountName = java.net.URLEncoder.encode(BankTransferConfig.ACCOUNT_HOLDER_NAME, "UTF-8").replace("+", "%20");
            
            String qrUrl = String.format("https://img.vietqr.io/image/%s-%s-compact2.png?amount=%s&addInfo=%s&accountName=%s",
                    bankId, accountNo, formattedAmount, addInfo, accountName);
                    
            System.out.println("[VietQR] Link QR động: " + qrUrl);
            return qrUrl;
        } catch (Exception e) {
            System.err.println("[VietQR] Lỗi khi tạo link QR: " + e.getMessage());
            return "";
        }
    }

    /**
     * Generate bank transfer instruction
     */
    public static String generateBankTransferInstruction(int rentalOrderID, double amount) {
        BankTransferConfig.BankDetails details = getDisplayBankDetails(rentalOrderID, amount);
        StringBuilder instruction = new StringBuilder();
        
        instruction.append("=== HƯỚNG DẪN CHUYỂN KHOẢN ===\n\n");
        instruction.append("Ngân hàng: ").append(details.getBankName()).append("\n");
        instruction.append("Số tài khoản: ").append(details.getAccountNumber()).append("\n");
        instruction.append("Chủ tài khoản: ").append(details.getAccountHolderName()).append("\n");
        instruction.append("Chi nhánh: ").append(details.getBranch()).append("\n");
        instruction.append("Số tiền: ").append(String.format("%.0f", details.getAmount())).append(" VNĐ\n");
        instruction.append("Nội dung: ").append(details.getOrderReference()).append("\n\n");
        instruction.append("Vui lòng chuyển khoản đúng nội dung để đơn hàng được xác nhận.");
        
        return instruction.toString();
    }

    /**
     * Xử lý xác nhận thanh toán tự động thông qua Webhook
     */
    public static boolean processAutomaticWebhook(String transferContent, double transferAmount) {
        try {
            // 1. Trích xuất ID đơn hàng từ nội dung chuyển khoản
            // Logic này phụ thuộc vào cấu trúc OrderReference bạn sinh ra.
            // Giả sử khách nhập nội dung có chứa mã số đơn hàng (VD: "Thanh toan don 123")
            int rentalOrderID = extractOrderIdFromContent(transferContent);
            if (rentalOrderID <= 0) {
                System.out.println("[Webhook] Không tìm thấy mã đơn hàng trong nội dung: " + transferContent);
                return false;
            }

            // 2. Lấy thông tin đơn hàng từ DB
            RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
            if (order == null) {
                System.out.println("[Webhook] Không tìm thấy đơn hàng ID: " + rentalOrderID);
                return false;
            }

            // Nếu đơn hàng đã được xác nhận rồi thì bỏ qua
            if ("PAYMENT_VERIFIED".equals(order.getStatus()) || "COMPLETED".equals(order.getStatus())) {
                return true;
            }

            // 3. Kiểm tra số tiền chuyển có đủ không (tính cả giảm giá nếu có)
            double expectedAmount = order.getTotalPrice() + order.getAdjustedDepositAmount();
            try {
                java.util.Map<String, Object> badge = Controller.RatingController.getBadgeForUser(order.getRenterUserID());
                if (badge != null && badge.get("discount") != null) {
                    double discountPercent = Double.parseDouble(badge.get("discount").toString());
                    expectedAmount = expectedAmount * (1.0 - discountPercent / 100.0);
                }
            } catch (Exception ex) {
                System.err.println("[Webhook] Lỗi tính discount: " + ex.getMessage());
            }

            // Chấp nhận sai số làm tròn 1000 VNĐ
            if (transferAmount < expectedAmount - 1000) {
                System.out.println("[Webhook] Giao dịch thất bại: Khách chuyển thiếu. Nhận: " + transferAmount + " / Yêu cầu: " + expectedAmount);
                String errorNotes = "AUTO_WEBHOOK_FAIL | Chuyển thiếu. Cần: " + expectedAmount + ", Nhận: " + transferAmount;
                RentalOrderDAO.updateRentalOrderStatusWithNotes(rentalOrderID, order.getStatus(), errorNotes);
                return false;
            }

            // 4. Cập nhật trạng thái tự động
            String notes = "AUTO_WEBHOOK | amount=" + transferAmount + " | content=" + transferContent;
            
            boolean statusUpdated = RentalOrderDAO.updateRentalOrderStatusWithNotes(rentalOrderID, "PAYMENT_VERIFIED", notes);
            if (statusUpdated) {
                RentalOrderDAO.markPaymentProcessed(rentalOrderID);
                
                // Cập nhật hoặc tạo mới bảng Payment thành COMPLETED
                Payment payment = PaymentDAO.getPaymentByRentalOrder(rentalOrderID);
                if (payment != null) {
                    PaymentDAO.updatePaymentStatus(payment.getPaymentID(), "COMPLETED");
                } else {
                    Payment newPayment = new Payment(rentalOrderID, transferAmount, "BANK_TRANSFER");
                    int newPaymentID = PaymentDAO.addPayment(newPayment);
                    if (newPaymentID > 0) PaymentDAO.updatePaymentStatus(newPaymentID, "COMPLETED");
                }
                
                // Gửi thông báo cho khách hàng
                if (order.getRenterUserID() > 0) {
                    NotificationService.createNotification(
                            order.getRenterUserID(),
                            "Thanh toán thành công",
                            "Hệ thống đã nhận được khoản thanh toán tự động cho đơn hàng #" + rentalOrderID + ". Đơn hàng đã được xác nhận!",
                            rentalOrderID
                    );
                }

                // Xử lý xác nhận tự động các đơn hàng khác thuộc cùng lô đặt hàng (cùng user, tạo cách nhau dưới 60s)
                try {
                    List<RentalOrder> userOrders = RentalOrderDAO.getRentalOrdersByUser(order.getRenterUserID());
                    if (userOrders != null) {
                        for (RentalOrder ro : userOrders) {
                            if (ro.getRentalOrderID() != rentalOrderID && 
                                ("PENDING_PAYMENT".equals(ro.getStatus()) || "PAYMENT_SUBMITTED".equals(ro.getStatus()))) {
                                
                                long diffSeconds = java.time.Duration.between(order.getCreatedAt(), ro.getCreatedAt()).abs().getSeconds();
                                if (diffSeconds <= 60) {
                                    System.out.println("[Webhook] Auto-verifying batch related order ID: " + ro.getRentalOrderID());
                                    String batchNotes = "AUTO_WEBHOOK_BATCH | parentOrder=" + rentalOrderID + " | content=" + transferContent;
                                    if (RentalOrderDAO.updateRentalOrderStatusWithNotes(ro.getRentalOrderID(), "PAYMENT_VERIFIED", batchNotes)) {
                                        RentalOrderDAO.markPaymentProcessed(ro.getRentalOrderID());
                                        Payment batchPayment = PaymentDAO.getPaymentByRentalOrder(ro.getRentalOrderID());
                                        if (batchPayment != null) {
                                            PaymentDAO.updatePaymentStatus(batchPayment.getPaymentID(), "COMPLETED");
                                        } else {
                                            Payment newBatchPayment = new Payment(ro.getRentalOrderID(), ro.getTotalPrice() + ro.getAdjustedDepositAmount(), "BANK_TRANSFER");
                                            int newPId = PaymentDAO.addPayment(newBatchPayment);
                                            if (newPId > 0) PaymentDAO.updatePaymentStatus(newPId, "COMPLETED");
                                        }
                                        NotificationService.createNotification(
                                                ro.getRenterUserID(),
                                                "Thanh toán thành công",
                                                "Đơn hàng #" + ro.getRentalOrderID() + " đã được xác nhận thanh toán tự động trong nhóm đơn hàng.",
                                                ro.getRentalOrderID()
                                        );
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception ex) {
                    System.err.println("[Webhook] Lỗi xử lý xác thực nhóm đơn hàng: " + ex.getMessage());
                }

                System.out.println("[Webhook] Xác nhận thành công đơn hàng: " + rentalOrderID);
                return true;
            }
        } catch (Exception e) {
            System.err.println("[Webhook] Lỗi xử lý tự động: " + e.getMessage());
        }
        return false;
    }

    private static int extractOrderIdFromContent(String content) {
        if (content == null || content.trim().isEmpty()) return -1;
        
        // 1. Tìm chuỗi có dạng WRC kèm theo chữ số (VD: "MB1234 WRC00001" sẽ lấy ra số 1)
        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("WRC\\s*0*(\\d+)").matcher(content.toUpperCase());
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        
        // 2. Dự phòng: Lấy tất cả các chữ số có trong chuỗi
        String digits = content.replaceAll("[^0-9]", "");
        return digits.isEmpty() ? -1 : Integer.parseInt(digits);
    }
}
