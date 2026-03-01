package Model;

import java.math.BigDecimal;

public class AIProductSuggestion {
    private int clothingID;
    private String clothingName;
    private String category;
    private String style;
    private BigDecimal dailyPrice;

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

    public String getStyle() {
        return style;
    }

    public void setStyle(String style) {
        this.style = style;
    }

    public BigDecimal getDailyPrice() {
        return dailyPrice;
    }

    public void setDailyPrice(BigDecimal dailyPrice) {
        this.dailyPrice = dailyPrice;
    }
}