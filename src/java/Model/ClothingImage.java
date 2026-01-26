package Model;

import java.time.LocalDateTime;

public class ClothingImage {
    private int imageID;
    private int clothingID;
    private String imagePath;
    private byte[] imageData;
    private boolean isPrimary;
    private LocalDateTime createdAt;

    public int getImageID() { return imageID; }
    public void setImageID(int imageID) { this.imageID = imageID; }

    public int getClothingID() { return clothingID; }
    public void setClothingID(int clothingID) { this.clothingID = clothingID; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public byte[] getImageData() { return imageData; }
    public void setImageData(byte[] imageData) { this.imageData = imageData; }

    public boolean isPrimary() { return isPrimary; }
    public boolean getPrimary() { return isPrimary; }
    public void setPrimary(boolean primary) { isPrimary = primary; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
