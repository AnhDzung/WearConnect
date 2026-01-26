package Service;

import config.BankTransferConfig;
import Model.Payment;
import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
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
}
