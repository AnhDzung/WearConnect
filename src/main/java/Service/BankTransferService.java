package Service;

import config.BankTransferConfig;
import Model.Payment;
import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
import Service.NotificationService;
import Model.RentalOrder;

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
        return details;
    }
    
    /**
     * Tạo URL mã QR động qua API VietQR
     */
    public static String generateVietQRUrl(int rentalOrderID, double amount) {
        BankTransferConfig.BankDetails details = getDisplayBankDetails(rentalOrderID, amount);
        try {
            // Tên viết tắt ngân hàng (Do bạn đang dùng MB Bank trong BankTransferConfig)
            String bankId = "MB"; 
            String accountNo = details.getAccountNumber();
            // Đảm bảo số tiền không bị dính dấu phẩy do cấu hình Locale (Ví dụ: "500,000" -> lỗi mã QR)
            String formattedAmount = String.valueOf(Math.round(details.getAmount()));
            String addInfo = java.net.URLEncoder.encode(details.getOrderReference(), "UTF-8");
            String accountName = java.net.URLEncoder.encode(details.getAccountHolderName(), "UTF-8");
            
            return String.format("https://img.vietqr.io/image/%s-%s-compact2.png?amount=%s&addInfo=%s&accountName=%s",
                    bankId, accountNo, formattedAmount, addInfo, accountName);
        } catch (Exception e) {
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

            // 3. Cập nhật trạng thái tự động
            // Chấp nhận thanh toán nếu số tiền chuyển >= số tiền cần thanh toán
            String notes = "AUTO_WEBHOOK | amount=" + transferAmount + " | content=" + transferContent;
            
            boolean statusUpdated = RentalOrderDAO.updateRentalOrderStatusWithNotes(rentalOrderID, "PAYMENT_VERIFIED", notes);
            if (statusUpdated) {
                RentalOrderDAO.markPaymentProcessed(rentalOrderID);
                
                // Cập nhật trạng thái bảng Payment thành COMPLETED nếu có
                // (Bạn cần tự bổ sung hàm lấy PaymentID theo RentalOrderID nếu cần thiết)
                
                // Gửi thông báo cho khách hàng
                if (order.getRenterUserID() > 0) {
                    NotificationService.createNotification(
                            order.getRenterUserID(),
                            "Thanh toán thành công",
                            "Hệ thống đã nhận được khoản thanh toán tự động cho đơn hàng #" + rentalOrderID + ". Đơn hàng đã được xác nhận!",
                            rentalOrderID
                    );
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
        // Lấy tất cả các chữ số có trong chuỗi (Cách đơn giản nhất)
        String digits = content.replaceAll("[^0-9]", "");
        return digits.isEmpty() ? -1 : Integer.parseInt(digits);
    }
}
