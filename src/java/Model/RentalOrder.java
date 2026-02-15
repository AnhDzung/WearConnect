package Model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class RentalOrder {
    private int rentalOrderID;
    private int clothingID;
    private int renterUserID;
    private int managerID; // RenterID from Clothing table (product owner)
    private LocalDateTime rentalStartDate;
    private LocalDateTime rentalEndDate;
    private LocalDateTime actualReturnDate; // Actual return date/time (for late fee calculation)
    private double totalPrice;
    private double depositAmount;
    private double userRating; // User's average rating (for trust-based deposit adjustment)
    private double trustBasedMultiplier; // Multiplier applied (0.8, 1.0, or 1.2)
    private double adjustedDepositAmount; // Deposit after trust-based adjustment
    private String status; // PENDING_PAYMENT, PAYMENT_SUBMITTED, PAYMENT_VERIFIED, SHIPPING, DELIVERED_PENDING_CONFIRMATION, RENTED, RETURNED, CANCELLED
    private String returnStatus; // NO_DAMAGE, LATE_RETURN, MINOR_DAMAGE, LOST (set when returning)
    private double damagePercentage; // Percentage of damage (0.0 - 1.0 for minor damage)
    private double lateFees; // Late return fees
    private double compensationAmount; // Compensation for damage/loss
    private double refundAmount; // Amount to refund to renter
    private LocalDateTime createdAt;
    private String selectedSize;
    private Integer colorID; // Màu sắc được chọn

    // Display helpers
    private String clothingName;
    private String renterUsername;
    private String renterFullName;
    private String renterEmail;
    private String renterPhone;
    private String renterAddress;
    private String selectedColorName;
    private String paymentProofImage;
    private String receivedProofImage;
    private String trackingNumber;

    public RentalOrder() {}

    public RentalOrder(int clothingID, int renterUserID, LocalDateTime rentalStartDate, 
                       LocalDateTime rentalEndDate, double totalPrice, double depositAmount) {
        this.clothingID = clothingID;
        this.renterUserID = renterUserID;
        this.rentalStartDate = rentalStartDate;
        this.rentalEndDate = rentalEndDate;
        this.totalPrice = totalPrice;
        this.depositAmount = depositAmount;
        this.status = "PENDING_PAYMENT";
    }

    // Getters and Setters
    public int getRentalOrderID() { return rentalOrderID; }
    public void setRentalOrderID(int rentalOrderID) { this.rentalOrderID = rentalOrderID; }

    public int getClothingID() { return clothingID; }
    public void setClothingID(int clothingID) { this.clothingID = clothingID; }

    public int getRenterUserID() { return renterUserID; }
    public void setRenterUserID(int renterUserID) { this.renterUserID = renterUserID; }

    public int getManagerID() { return managerID; }
    public void setManagerID(int managerID) { this.managerID = managerID; }

    public LocalDateTime getRentalStartDate() { return rentalStartDate; }
    public void setRentalStartDate(LocalDateTime rentalStartDate) { this.rentalStartDate = rentalStartDate; }

    public LocalDateTime getRentalEndDate() { return rentalEndDate; }
    public void setRentalEndDate(LocalDateTime rentalEndDate) { this.rentalEndDate = rentalEndDate; }

    public LocalDateTime getActualReturnDate() { return actualReturnDate; }
    public void setActualReturnDate(LocalDateTime actualReturnDate) { this.actualReturnDate = actualReturnDate; }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public double getDepositAmount() { return depositAmount; }
    public void setDepositAmount(double depositAmount) { this.depositAmount = depositAmount; }
    
    public double getUserRating() { return userRating; }
    public void setUserRating(double userRating) { this.userRating = userRating; }
    
    public double getTrustBasedMultiplier() { return trustBasedMultiplier; }
    public void setTrustBasedMultiplier(double trustBasedMultiplier) { this.trustBasedMultiplier = trustBasedMultiplier; }
    
    public double getAdjustedDepositAmount() { return adjustedDepositAmount; }
    public void setAdjustedDepositAmount(double adjustedDepositAmount) { this.adjustedDepositAmount = adjustedDepositAmount; }
    
    public String getReturnStatus() { return returnStatus; }
    public void setReturnStatus(String returnStatus) { this.returnStatus = returnStatus; }
    
    public double getDamagePercentage() { return damagePercentage; }
    public void setDamagePercentage(double damagePercentage) { this.damagePercentage = damagePercentage; }
    
    public double getLateFees() { return lateFees; }
    public void setLateFees(double lateFees) { this.lateFees = lateFees; }
    
    public double getCompensationAmount() { return compensationAmount; }
    public void setCompensationAmount(double compensationAmount) { this.compensationAmount = compensationAmount; }
    
    public double getRefundAmount() { return refundAmount; }
    public void setRefundAmount(double refundAmount) { this.refundAmount = refundAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getClothingName() { return clothingName; }
    public void setClothingName(String clothingName) { this.clothingName = clothingName; }

    public String getRenterUsername() { return renterUsername; }
    public void setRenterUsername(String renterUsername) { this.renterUsername = renterUsername; }
    public String getRenterFullName() { return renterFullName; }
    public void setRenterFullName(String renterFullName) { this.renterFullName = renterFullName; }
    public String getRenterEmail() { return renterEmail; }
    public void setRenterEmail(String renterEmail) { this.renterEmail = renterEmail; }
    public String getRenterPhone() { return renterPhone; }
    public void setRenterPhone(String renterPhone) { this.renterPhone = renterPhone; }
    public String getRenterAddress() { return renterAddress; }
    public void setRenterAddress(String renterAddress) { this.renterAddress = renterAddress; }

    public String getSelectedSize() { return selectedSize; }
    public void setSelectedSize(String selectedSize) { this.selectedSize = selectedSize; }

    public Integer getColorID() { return colorID; }
    public void setColorID(Integer colorID) { this.colorID = colorID; }

    public String getSelectedColorName() { return selectedColorName; }
    public void setSelectedColorName(String selectedColorName) { this.selectedColorName = selectedColorName; }

    public String getPaymentProofImage() { return paymentProofImage; }
    public void setPaymentProofImage(String paymentProofImage) { this.paymentProofImage = paymentProofImage; }

    public String getReceivedProofImage() { return receivedProofImage; }
    public void setReceivedProofImage(String receivedProofImage) { this.receivedProofImage = receivedProofImage; }

    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }

    // Format order code as WRC + 5-digit ID (e.g., WRC00001)
    public String getOrderCode() {
        return String.format("WRC%05d", rentalOrderID);
    }

    // Format dates for JSP display
    public String getFormattedStartDate() {
        if (rentalStartDate == null) return "";
        return rentalStartDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedEndDate() {
        if (rentalEndDate == null) return "";
        return rentalEndDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
