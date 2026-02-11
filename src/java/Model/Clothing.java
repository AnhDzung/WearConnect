package Model;

import java.time.LocalDateTime;
import java.math.BigDecimal;

public class Clothing {
    private int clothingID;
    private int renterID;
    private String clothingName;
    private String category;
    private String style;
    private String occasion;
    private String size;
    private String description;
    private BigDecimal hourlyPrice;
    private BigDecimal dailyPrice;
    private String imagePath;
    private byte[] imageData;
    private LocalDateTime availableFrom;
    private LocalDateTime availableTo;
    private boolean isActive;
    private int quantity; // Số lượng sản phẩm có sẵn
    private BigDecimal depositAmount; // Số tiền đặt cọc do manager định
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Clothing() {}

    public Clothing(int renterID, String clothingName, String category, String style, 
                    String size, String description, double hourlyPrice, String imagePath,
                    LocalDateTime availableFrom, LocalDateTime availableTo) {
        this.renterID = renterID;
        this.clothingName = clothingName;
        this.category = category;
        this.style = style;
        this.size = size;
        this.description = description;
        this.hourlyPrice = new BigDecimal(hourlyPrice);
        this.imagePath = imagePath;
        this.availableFrom = availableFrom;
        this.availableTo = availableTo;
        this.isActive = true;
    }

    // Getters and Setters
    public int getClothingID() { return clothingID; }
    public void setClothingID(int clothingID) { this.clothingID = clothingID; }

    public int getRenterID() { return renterID; }
    public void setRenterID(int renterID) { this.renterID = renterID; }

    public String getClothingName() { return clothingName; }
    public void setClothingName(String clothingName) { this.clothingName = clothingName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getStyle() { return style; }
    public void setStyle(String style) { this.style = style; }

    public String getOccasion() { return occasion; }
    public void setOccasion(String occasion) { this.occasion = occasion; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getHourlyPrice() { return hourlyPrice != null ? hourlyPrice.doubleValue() : 0.0; }
    public BigDecimal getHourlyPriceBigDecimal() { return hourlyPrice; }
    public void setHourlyPrice(double hourlyPrice) { this.hourlyPrice = new BigDecimal(hourlyPrice); }
    public void setHourlyPrice(BigDecimal hourlyPrice) { this.hourlyPrice = hourlyPrice; }

    public double getDailyPrice() { return dailyPrice != null ? dailyPrice.doubleValue() : 0.0; }
    public BigDecimal getDailyPriceBigDecimal() { return dailyPrice; }
    public void setDailyPrice(double dailyPrice) { this.dailyPrice = new BigDecimal(dailyPrice); }
    public void setDailyPrice(BigDecimal dailyPrice) { this.dailyPrice = dailyPrice; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public byte[] getImageData() { return imageData; }
    public void setImageData(byte[] imageData) { this.imageData = imageData; }

    public LocalDateTime getAvailableFrom() { return availableFrom; }
    public void setAvailableFrom(LocalDateTime availableFrom) { this.availableFrom = availableFrom; }

    public LocalDateTime getAvailableTo() { return availableTo; }
    public void setAvailableTo(LocalDateTime availableTo) { this.availableTo = availableTo; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getDepositAmount() { return depositAmount != null ? depositAmount.doubleValue() : 0.0; }
    public BigDecimal getDepositAmountBigDecimal() { return depositAmount; }
    public void setDepositAmount(double depositAmount) { this.depositAmount = new BigDecimal(depositAmount); }
    public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
