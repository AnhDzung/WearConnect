package Model;

import java.time.LocalDateTime;

public class OrderIssue {
    private int issueID;
    private int rentalOrderID;
    private int renterUserID;
    private String issueType;
    private String description;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime resolvedAt;
    private String notes;
    private String imagePath;
    private byte[] imageData;

    public OrderIssue() {}

    public OrderIssue(int rentalOrderID, int renterUserID, String issueType, String description) {
        this.rentalOrderID = rentalOrderID;
        this.renterUserID = renterUserID;
        this.issueType = issueType;
        this.description = description;
        this.status = "PENDING";
    }

    public int getIssueID() { return issueID; }
    public void setIssueID(int issueID) { this.issueID = issueID; }

    public int getRentalOrderID() { return rentalOrderID; }
    public void setRentalOrderID(int rentalOrderID) { this.rentalOrderID = rentalOrderID; }

    public int getRenterUserID() { return renterUserID; }
    public void setRenterUserID(int renterUserID) { this.renterUserID = renterUserID; }

    public String getIssueType() { return issueType; }
    public void setIssueType(String issueType) { this.issueType = issueType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public byte[] getImageData() { return imageData; }
    public void setImageData(byte[] imageData) { this.imageData = imageData; }

    }
