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
    private double totalPrice;
    private double depositAmount;
    private String status; // PENDING, CONFIRMED, RENTED, RETURNED, CANCELLED
    private LocalDateTime createdAt;
    private String selectedSize;
    private Integer colorID; // Màu sắc được chọn

    // Display helpers
    private String clothingName;
    private String renterUsername;
    private String selectedColorName;

    public RentalOrder() {}

    public RentalOrder(int clothingID, int renterUserID, LocalDateTime rentalStartDate, 
                       LocalDateTime rentalEndDate, double totalPrice, double depositAmount) {
        this.clothingID = clothingID;
        this.renterUserID = renterUserID;
        this.rentalStartDate = rentalStartDate;
        this.rentalEndDate = rentalEndDate;
        this.totalPrice = totalPrice;
        this.depositAmount = depositAmount;
        this.status = "PENDING";
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

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public double getDepositAmount() { return depositAmount; }
    public void setDepositAmount(double depositAmount) { this.depositAmount = depositAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getClothingName() { return clothingName; }
    public void setClothingName(String clothingName) { this.clothingName = clothingName; }

    public String getRenterUsername() { return renterUsername; }
    public void setRenterUsername(String renterUsername) { this.renterUsername = renterUsername; }

    public String getSelectedSize() { return selectedSize; }
    public void setSelectedSize(String selectedSize) { this.selectedSize = selectedSize; }

    public Integer getColorID() { return colorID; }
    public void setColorID(Integer colorID) { this.colorID = colorID; }

    public String getSelectedColorName() { return selectedColorName; }
    public void setSelectedColorName(String selectedColorName) { this.selectedColorName = selectedColorName; }

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
