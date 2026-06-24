package Model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class CartItem {
    private int cartItemId; // Unique ID to identify item in session cart
    private int clothingID;
    private String clothingName;
    private String category;
    private double hourlyPrice;
    private double dailyPrice;
    private double itemValue;
    private String rentalType; // "hourly" or "daily"
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String selectedSize;
    private Integer colorID;
    private String colorName;
    private Integer imageID; // Primary image ID for displaying thumbnail

    public CartItem() {}

    public int getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(int cartItemId) {
        this.cartItemId = cartItemId;
    }

    public int getClothingID() {
        return clothingID;
    }

    public void setClothingID(int clothingID) {
        this.clothingID = clothingID;
    }

    public String getClothingName() {
        return clothingName;
    }

    public void setClothingName(String clothingName) {
        this.clothingName = clothingName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getHourlyPrice() {
        return hourlyPrice;
    }

    public void setHourlyPrice(double hourlyPrice) {
        this.hourlyPrice = hourlyPrice;
    }

    public double getDailyPrice() {
        return dailyPrice;
    }

    public void setDailyPrice(double dailyPrice) {
        this.dailyPrice = dailyPrice;
    }

    public double getItemValue() {
        return itemValue;
    }

    public void setItemValue(double itemValue) {
        this.itemValue = itemValue;
    }

    public String getRentalType() {
        return rentalType;
    }

    public void setRentalType(String rentalType) {
        this.rentalType = rentalType;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }

    public String getSelectedSize() {
        return selectedSize;
    }

    public void setSelectedSize(String selectedSize) {
        this.selectedSize = selectedSize;
    }

    public Integer getColorID() {
        return colorID;
    }

    public void setColorID(Integer colorID) {
        this.colorID = colorID;
    }

    public String getColorName() {
        return colorName;
    }

    public void setColorName(String colorName) {
        this.colorName = colorName;
    }

    public Integer getImageID() {
        return imageID;
    }

    public void setImageID(Integer imageID) {
        this.imageID = imageID;
    }

    // Display helpers for JSP
    public String getFormattedStartDate() {
        if (startDate == null) return "";
        if ("daily".equals(rentalType)) {
            return startDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        }
        return startDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedEndDate() {
        if (endDate == null) return "";
        if ("daily".equals(rentalType)) {
            return endDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        }
        return endDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
