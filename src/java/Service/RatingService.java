package Service;

import DAO.RatingDAO;
import DAO.RentalOrderDAO;
import Model.Rating;
import Model.RentalOrder;
import java.util.List;

public class RatingService {
    
    public static int submitRating(int rentalOrderID, int ratingFromUserID, int rating, String comment) {
        if (rating < 1 || rating > 5) {
            return -1; // Invalid rating
        }
        
        // Verify that ratingFromUserID is not the product manager (owner)
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) {
            return -2; // Order not found
        }
        
        // Only allow rating when the order is COMPLETED; block all other states
        String status = order.getStatus();
        if (status != null) status = status.trim().toUpperCase();
        if (!"COMPLETED".equals(status)) {
            return -4; // Not allowed until COMPLETED
        }
        
        // If ratingFromUserID equals the product manager/owner, deny the rating
        if (ratingFromUserID == order.getManagerID()) {
            return -3; // Manager cannot rate their own product
        }
        
        Rating ratingModel = new Rating(rentalOrderID, ratingFromUserID, rating, comment);
        return RatingDAO.addRating(ratingModel);
    }

    public static Rating getRatingByOrder(int rentalOrderID) {
        return RatingDAO.getRatingByRentalOrder(rentalOrderID);
    }

    public static List<Rating> getRenterRatings(int renterID) {
        return RatingDAO.getRatingsByRenter(renterID);
    }

    public static List<Rating> getClothingRatings(int clothingID) {
        return RatingDAO.getRatingsByClothing(clothingID);
    }

    public static double getAverageRating(int clothingID) {
        return RatingDAO.getAverageRatingForClothing(clothingID);
    }

    public static int getTotalRatings(int clothingID) {
        return RatingDAO.getRatingsByClothing(clothingID).size();
    }

    public static boolean deleteRating(int ratingID) {
        return RatingDAO.deleteRating(ratingID);
    }
}
