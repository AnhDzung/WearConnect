package Service;

import DAO.RatingDAO;
import DAO.RentalOrderDAO;
import Model.Rating;
import Model.RentalOrder;
import java.util.List;

public class RatingService {
    
    public static int submitRating(int rentalOrderID, int ratingFromUserID, int rating, String comment) {
        System.out.println("[RatingService] submitRating called - rentalOrderID: " + rentalOrderID + 
                         ", ratingFromUserID: " + ratingFromUserID + ", rating: " + rating);
        
        if (rating < 1 || rating > 5) {
            System.out.println("[RatingService] Invalid rating value: " + rating);
            return -1; // Invalid rating
        }
        
        // Verify that ratingFromUserID is not the product manager (owner)
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) {
            System.out.println("[RatingService] Order not found for ID: " + rentalOrderID);
            return -2; // Order not found
        }
        
        System.out.println("[RatingService] Order found - Status: " + order.getStatus() + 
                         ", ManagerID: " + order.getManagerID() + ", RenterUserID: " + order.getRenterUserID());
        
        // Only allow rating when the order is COMPLETED; block all other states
        String status = order.getStatus();
        if (status != null) status = status.trim().toUpperCase();
        if (!"COMPLETED".equals(status)) {
            System.out.println("[RatingService] Order status is not COMPLETED: " + status);
            return -4; // Not allowed until COMPLETED
        }
        // Only participants of the order may rate: renter or manager (product owner)
        int managerID = order.getManagerID();
        int renterID = order.getRenterUserID();
        System.out.println("[RatingService] Checking authorization - ratingFromUserID: " + ratingFromUserID + 
                         ", managerID: " + managerID + ", renterID: " + renterID);
        
        if (ratingFromUserID != managerID && ratingFromUserID != renterID) {
            System.out.println("[RatingService] User not authorized to rate this order");
            return -6; // Not authorized to rate this order
        }

        // Prevent duplicate rating by the same user for the same order
        Rating existing = RatingDAO.getRatingByRentalOrderAndUser(rentalOrderID, ratingFromUserID);
        if (existing != null) {
            System.out.println("[RatingService] User already rated this order");
            return -5; // Already rated by this user for this order
        }

        Rating ratingModel = new Rating(rentalOrderID, ratingFromUserID, rating, comment);
        int ratingID = RatingDAO.addRating(ratingModel);
        System.out.println("[RatingService] Rating saved successfully with ID: " + ratingID);
        return ratingID;
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

    public static int getFiveStarCountForUser(int userID) {
        return RatingDAO.getFiveStarCountForUser(userID);
    }

    public static java.util.Map<String, Object> getBadgeForUser(int userID) {
        int count = getFiveStarCountForUser(userID);
        java.util.Map<String,Object> result = new java.util.HashMap<>();
        result.put("count", count);

        // Define thresholds and labels
        int[] thresholds = new int[] {800,700,600,500,400,300,200,50};
        String[] labels = new String[] {
            "Khách Hàng Uy tín Vĩnh VIễn",
            "Khách Hàng Uy tín Lục Bảo",
            "Khách Hàng Uy tín Kim Cương",
            "Khách Hàng Uy tín Bạch Kim",
            "Khách Hàng Uy tín Vàng",
            "Khách Hàng Uy tín Bạc",
            "Khách Hàng Uy tín đồng",
            "Khách Hàng Uy tín"
        };
        int[] discounts = new int[] {40,35,30,25,20,15,10,5};

        String badge = null;
        Integer discount = null;
        for (int i = 0; i < thresholds.length; i++) {
            if (count >= thresholds[i]) {
                badge = labels[i];
                discount = discounts[i];
                break;
            }
        }
        result.put("badge", badge);
        result.put("discount", discount);
        return result;
    }

    public static boolean deleteRating(int ratingID) {
        return RatingDAO.deleteRating(ratingID);
    }
}
