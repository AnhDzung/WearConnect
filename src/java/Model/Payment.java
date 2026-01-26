package Model;

import java.time.LocalDateTime;

public class Payment {
    private int paymentID;
    private int rentalOrderID;
    private double amount;
    private String paymentMethod; // CREDIT_CARD, BANK_TRANSFER, CASH
    private String paymentStatus; // PENDING, COMPLETED, FAILED, REFUNDED
    private String paymentProofImage; // Path to uploaded payment proof image
    private LocalDateTime paymentDate;
    private LocalDateTime createdAt;

    public Payment() {}

    public Payment(int rentalOrderID, double amount, String paymentMethod) {
        this.rentalOrderID = rentalOrderID;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = "PENDING";
    }

    // Getters and Setters
    public int getPaymentID() { return paymentID; }
    public void setPaymentID(int paymentID) { this.paymentID = paymentID; }

    public int getRentalOrderID() { return rentalOrderID; }
    public void setRentalOrderID(int rentalOrderID) { this.rentalOrderID = rentalOrderID; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getPaymentProofImage() { return paymentProofImage; }
    public void setPaymentProofImage(String paymentProofImage) { this.paymentProofImage = paymentProofImage; }
}
