package Controller;

import Service.PaymentService;
import Model.Payment;

public class PaymentController {
    
    public static int processPayment(int rentalOrderID, String paymentMethod) {
        return PaymentService.processPayment(rentalOrderID, paymentMethod);
    }

    public static int processPayment(int rentalOrderID, String paymentMethod, double amount) {
        return PaymentService.processPayment(rentalOrderID, paymentMethod, amount);
    }

    public static int processDepositPayment(int rentalOrderID, String paymentMethod) {
        return PaymentService.processDepositPayment(rentalOrderID, paymentMethod);
    }

    public static int processDepositPayment(int rentalOrderID, String paymentMethod, double amount) {
        return PaymentService.processDepositPayment(rentalOrderID, paymentMethod, amount);
    }

    public static Payment getPaymentStatus(int rentalOrderID) {
        return PaymentService.getPaymentStatus(rentalOrderID);
    }

    public static boolean completePayment(int paymentID) {
        return PaymentService.completePayment(paymentID);
    }

    public static boolean failPayment(int paymentID) {
        return PaymentService.failPayment(paymentID);
    }

    public static boolean refundPayment(int paymentID) {
        return PaymentService.refundPayment(paymentID);
    }

    public static Payment getPaymentDetails(int paymentID) {
        return PaymentService.getPaymentDetails(paymentID);
    }
    
    public static Payment getPaymentByOrderID(int rentalOrderID) {
        return PaymentService.getPaymentByOrderID(rentalOrderID);
    }
    
    public static boolean updatePaymentProof(int paymentID, String proofImagePath) {
        return PaymentService.updatePaymentProof(paymentID, proofImagePath);
    }
    
    public static int createPaymentOnly(int rentalOrderID, String paymentMethod) {
        return PaymentService.createPaymentOnly(rentalOrderID, paymentMethod);
    }

    public static int createPaymentOnly(int rentalOrderID, String paymentMethod, double amount) {
        return PaymentService.createPaymentOnly(rentalOrderID, paymentMethod, amount);
    }
}
