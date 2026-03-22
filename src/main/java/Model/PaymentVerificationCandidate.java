package Model;

import java.time.LocalDateTime;

public class PaymentVerificationCandidate {

    private int rentalOrderID;
    private int renterUserID;
    private int managerID;
    private int paymentID;
    private double expectedAmount;
    private double paidAmount;
    private LocalDateTime transferTime;
    private LocalDateTime submittedAt;
    private boolean hasProofImage;
    private String expectedTransferContent;
    private String providedTransferContent;

    public int getRentalOrderID() {
        return rentalOrderID;
    }

    public void setRentalOrderID(int rentalOrderID) {
        this.rentalOrderID = rentalOrderID;
    }

    public int getRenterUserID() {
        return renterUserID;
    }

    public void setRenterUserID(int renterUserID) {
        this.renterUserID = renterUserID;
    }

    public int getManagerID() {
        return managerID;
    }

    public void setManagerID(int managerID) {
        this.managerID = managerID;
    }

    public int getPaymentID() {
        return paymentID;
    }

    public void setPaymentID(int paymentID) {
        this.paymentID = paymentID;
    }

    public double getExpectedAmount() {
        return expectedAmount;
    }

    public void setExpectedAmount(double expectedAmount) {
        this.expectedAmount = expectedAmount;
    }

    public double getPaidAmount() {
        return paidAmount;
    }

    public void setPaidAmount(double paidAmount) {
        this.paidAmount = paidAmount;
    }

    public LocalDateTime getTransferTime() {
        return transferTime;
    }

    public void setTransferTime(LocalDateTime transferTime) {
        this.transferTime = transferTime;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public boolean isHasProofImage() {
        return hasProofImage;
    }

    public void setHasProofImage(boolean hasProofImage) {
        this.hasProofImage = hasProofImage;
    }

    public String getExpectedTransferContent() {
        return expectedTransferContent;
    }

    public void setExpectedTransferContent(String expectedTransferContent) {
        this.expectedTransferContent = expectedTransferContent;
    }

    public String getProvidedTransferContent() {
        return providedTransferContent;
    }

    public void setProvidedTransferContent(String providedTransferContent) {
        this.providedTransferContent = providedTransferContent;
    }

    public String getOrderCode() {
        return String.format("WRC%05d", rentalOrderID);
    }
}
