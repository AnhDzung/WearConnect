package Model;

import java.util.Date;

/**
 * Model class for CosplayDetail table - Extended metadata for cosplay clothing items
 * Stores specialized information like character name, series, type, accuracy level
 */
public class CosplayDetail {
    
    private int detailID;
    private int clothingID;
    private String characterName;
    private String series;
    private String cosplayType; // "Anime", "Game", "Movie"
    private String accuracyLevel; // "Cao", "Trung bình", "Cơ bản"
    private String accessoryList; // Comma-separated list of accessories
    private Date createdAt;
    private Date updatedAt;

    // Constructors
    public CosplayDetail() {
    }

    public CosplayDetail(int clothingID, String characterName, String series, 
                        String cosplayType, String accuracyLevel, String accessoryList) {
        this.clothingID = clothingID;
        this.characterName = characterName;
        this.series = series;
        this.cosplayType = cosplayType;
        this.accuracyLevel = accuracyLevel;
        this.accessoryList = accessoryList;
    }

    public CosplayDetail(int detailID, int clothingID, String characterName, 
                        String series, String cosplayType, String accuracyLevel, 
                        String accessoryList, Date createdAt, Date updatedAt) {
        this.detailID = detailID;
        this.clothingID = clothingID;
        this.characterName = characterName;
        this.series = series;
        this.cosplayType = cosplayType;
        this.accuracyLevel = accuracyLevel;
        this.accessoryList = accessoryList;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getDetailID() {
        return detailID;
    }

    public void setDetailID(int detailID) {
        this.detailID = detailID;
    }

    public int getClothingID() {
        return clothingID;
    }

    public void setClothingID(int clothingID) {
        this.clothingID = clothingID;
    }

    public String getCharacterName() {
        return characterName;
    }

    public void setCharacterName(String characterName) {
        this.characterName = characterName;
    }

    public String getSeries() {
        return series;
    }

    public void setSeries(String series) {
        this.series = series;
    }

    public String getCosplayType() {
        return cosplayType;
    }

    public void setCosplayType(String cosplayType) {
        this.cosplayType = cosplayType;
    }

    public String getAccuracyLevel() {
        return accuracyLevel;
    }

    public void setAccuracyLevel(String accuracyLevel) {
        this.accuracyLevel = accuracyLevel;
    }

    public String getAccessoryList() {
        return accessoryList;
    }

    public void setAccessoryList(String accessoryList) {
        this.accessoryList = accessoryList;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "CosplayDetail{" +
                "detailID=" + detailID +
                ", clothingID=" + clothingID +
                ", characterName='" + characterName + '\'' +
                ", series='" + series + '\'' +
                ", cosplayType='" + cosplayType + '\'' +
                ", accuracyLevel='" + accuracyLevel + '\'' +
                ", accessoryList='" + accessoryList + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
