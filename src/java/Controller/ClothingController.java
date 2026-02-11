package Controller;

import Service.ClothingService;
import Service.RatingService;
import Model.Clothing;
import Model.ClothingImage;
import Model.Rating;
import java.util.List;

public class ClothingController {
    
    public static int uploadClothing(Clothing clothing) {
        return ClothingService.uploadClothing(clothing);
    }

    public static List<Clothing> getAllClothing() {
        return ClothingService.getAllClothing();
    }

    public static Clothing getClothingDetails(int clothingID) {
        return ClothingService.getClothingDetails(clothingID);
    }

    public static List<Clothing> searchByCategory(String category) {
        return ClothingService.searchByCategory(category);
    }

    public static List<Clothing> searchByStyle(String style) {
        return ClothingService.searchByStyle(style);
    }

    public static List<Clothing> searchByOccasion(String occasion) {
        return ClothingService.searchByOccasion(occasion);
    }

    public static List<Clothing> searchClothing(String keyword) {
        return ClothingService.searchClothing(keyword);
    }

    public static List<Clothing> getMyClothing(int renterID) {
        return ClothingService.getMyClothing(renterID);
    }

    public static List<ClothingImage> getClothingImages(int clothingID) {
        return ClothingService.getImagesByClothing(clothingID);
    }

    public static int addClothingImage(ClothingImage image) {
        return ClothingService.addClothingImage(image);
    }

    public static void clearPrimaryImages(int clothingID) {
        ClothingService.clearPrimaryImages(clothingID);
    }

    public static boolean updateClothing(Clothing clothing) {
        return ClothingService.updateClothing(clothing);
    }

    public static boolean deleteClothing(int clothingID) {
        return ClothingService.deleteClothing(clothingID);
    }

    public static List<Rating> getClothingRatings(int clothingID) {
        return RatingService.getClothingRatings(clothingID);
    }

    public static double getAverageRating(int clothingID) {
        return RatingService.getAverageRating(clothingID);
    }
}
