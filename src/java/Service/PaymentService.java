package Service;

import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
import Model.Payment;
import Model.RentalOrder;

public class PaymentService {
    
    public static int processPayment(int rentalOrderID, String paymentMethod) {
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) return -1;
        
        Payment payment = new Payment(rentalOrderID, order.getTotalPrice(), paymentMethod);
        int paymentID = PaymentDAO.addPayment(payment);
        
        if (paymentID > 0) {
            RentalOrderDAO.updateRentalOrderStatus(rentalOrderID, "PAYMENT_VERIFIED");
        }
        
        return paymentID;
    }
    
    /**
     * Create payment without auto-confirming order (for bank transfer with proof upload)
     */
    public static int createPaymentOnly(int rentalOrderID, String paymentMethod) {
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) return -1;
        
        Payment payment = new Payment(rentalOrderID, order.getTotalPrice(), paymentMethod);
        return PaymentDAO.addPayment(payment);
    }

    public static int processDepositPayment(int rentalOrderID, String paymentMethod) {
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) return -1;
        
        Payment payment = new Payment(rentalOrderID, order.getDepositAmount(), paymentMethod);
        int paymentID = PaymentDAO.addPayment(payment);
        
        if (paymentID > 0) {
            PaymentDAO.updatePaymentStatus(paymentID, "COMPLETED");
        }
        
        return paymentID;
    }

    public static Payment getPaymentStatus(int rentalOrderID) {
        return PaymentDAO.getPaymentByRentalOrder(rentalOrderID);
    }

    public static boolean completePayment(int paymentID) {
        return PaymentDAO.updatePaymentStatus(paymentID, "COMPLETED");
    }

    public static boolean failPayment(int paymentID) {
        return PaymentDAO.updatePaymentStatus(paymentID, "FAILED");
    }

    public static boolean refundPayment(int paymentID) {
        return PaymentDAO.updatePaymentStatus(paymentID, "REFUNDED");
    }

    public static Payment getPaymentDetails(int paymentID) {
        return PaymentDAO.getPaymentByID(paymentID);
    }
    
    public static Payment getPaymentByOrderID(int rentalOrderID) {
        return PaymentDAO.getPaymentByRentalOrder(rentalOrderID);
    }
    
    public static boolean updatePaymentProof(int paymentID, String proofImagePath) {
        return PaymentDAO.updatePaymentProof(paymentID, proofImagePath);
    }
}
