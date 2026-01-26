package Controller;

import Service.RatingService;
import Model.Rating;
import java.util.List;

public class RatingController {
    
    public static int submitRating(int rentalOrderID, int ratingFromUserID, int rating, String comment) {
        return RatingService.submitRating(rentalOrderID, ratingFromUserID, rating, comment);
    }

    public static Rating getRatingByOrder(int rentalOrderID) {
        return RatingService.getRatingByOrder(rentalOrderID);
    }

    public static List<Rating> getRenterRatings(int renterID) {
        return RatingService.getRenterRatings(renterID);
    }

    public static List<Rating> getClothingRatings(int clothingID) {
        return RatingService.getClothingRatings(clothingID);
    }

    public static double getAverageRating(int clothingID) {
        return RatingService.getAverageRating(clothingID);
    }

    public static int getTotalRatings(int clothingID) {
        return RatingService.getTotalRatings(clothingID);
    }

    public static boolean deleteRating(int ratingID) {
        return RatingService.deleteRating(ratingID);
    }
}
