package Model;

public class Color {
    private int colorID;
    private String colorName;
    private String hexCode;
    private Integer managerID; // nullable
    private boolean isGlobal;
    private java.time.LocalDateTime createdAt;

    // Constructor
    public Color() {}

    public Color(String colorName, String hexCode, Integer managerID, boolean isGlobal) {
        this.colorName = colorName;
        this.hexCode = hexCode;
        this.managerID = managerID;
        this.isGlobal = isGlobal;
    }

    public Color(int colorID, String colorName, String hexCode, Integer managerID, boolean isGlobal) {
        this.colorID = colorID;
        this.colorName = colorName;
        this.hexCode = hexCode;
        this.managerID = managerID;
        this.isGlobal = isGlobal;
    }

    // Getters and Setters
    public int getColorID() {
        return colorID;
    }

    public void setColorID(int colorID) {
        this.colorID = colorID;
    }

    public String getColorName() {
        return colorName;
    }

    public void setColorName(String colorName) {
        this.colorName = colorName;
    }

    public String getHexCode() {
        return hexCode;
    }

    public void setHexCode(String hexCode) {
        this.hexCode = hexCode;
    }

    public Integer getManagerID() {
        return managerID;
    }

    public void setManagerID(Integer managerID) {
        this.managerID = managerID;
    }

    public boolean isGlobal() {
        return isGlobal;
    }

    public void setGlobal(boolean global) {
        isGlobal = global;
    }

    public java.time.LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(java.time.LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Color{" +
                "colorID=" + colorID +
                ", colorName='" + colorName + '\'' +
                ", hexCode='" + hexCode + '\'' +
                ", managerID=" + managerID +
                ", isGlobal=" + isGlobal +
                ", createdAt=" + createdAt +
                '}';
    }
}
