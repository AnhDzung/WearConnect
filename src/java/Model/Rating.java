package Model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Rating {
    private int ratingID;
    private int rentalOrderID;
    private int ratingFromUserID;
    private int rating; // 1-5 stars
    private String comment;
    private LocalDateTime createdAt;

    // Display helpers
    private String ratingFromUsername;
    private String clothingName;

    public Rating() {}

    public Rating(int rentalOrderID, int ratingFromUserID, int rating, String comment) {
        this.rentalOrderID = rentalOrderID;
        this.ratingFromUserID = ratingFromUserID;
        this.rating = rating;
        this.comment = comment;
    }

    // Getters and Setters
    public int getRatingID() { return ratingID; }
    public void setRatingID(int ratingID) { this.ratingID = ratingID; }

    public int getRentalOrderID() { return rentalOrderID; }
    public void setRentalOrderID(int rentalOrderID) { this.rentalOrderID = rentalOrderID; }

    public int getRatingFromUserID() { return ratingFromUserID; }
    public void setRatingFromUserID(int ratingFromUserID) { this.ratingFromUserID = ratingFromUserID; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "Không rõ thời gian";
        return createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getRatingFromUsername() { return ratingFromUsername; }
    public void setRatingFromUsername(String ratingFromUsername) { this.ratingFromUsername = ratingFromUsername; }

    public String getClothingName() { return clothingName; }
    public void setClothingName(String clothingName) { this.clothingName = clothingName; }
}
