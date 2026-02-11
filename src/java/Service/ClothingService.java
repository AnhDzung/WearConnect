package Service;

import DAO.ClothingDAO;
import DAO.ClothingImageDAO;
import Model.Clothing;
import Model.ClothingImage;
import java.util.List;

public class ClothingService {
    
    public static int uploadClothing(Clothing clothing) {
        if (clothing.getClothingName() == null || clothing.getClothingName().isEmpty()) {
            return -1; // Invalid input
        }
        return ClothingDAO.addClothing(clothing);
    }

    public static List<Clothing> getAllClothing() {
        return ClothingDAO.getAllActiveClothing();
    }

    public static Clothing getClothingDetails(int clothingID) {
        return ClothingDAO.getClothingByID(clothingID);
    }

    public static List<Clothing> searchByCategory(String category) {
        return ClothingDAO.searchByCategory(category);
    }

    public static List<Clothing> searchByStyle(String style) {
        return ClothingDAO.searchByStyle(style);
    }

    public static List<Clothing> searchByOccasion(String occasion) {
        return ClothingDAO.searchByOccasion(occasion);
    }

    public static List<Clothing> searchClothing(String keyword) {
        return ClothingDAO.searchByName(keyword);
    }

    public static List<Clothing> getMyClothing(int renterID) {
        return ClothingDAO.getClothingByRenter(renterID);
    }

    public static List<ClothingImage> getImagesByClothing(int clothingID) {
        return ClothingImageDAO.getImagesByClothing(clothingID);
    }

    public static int addClothingImage(ClothingImage image) {
        return ClothingImageDAO.addClothingImage(image);
    }

    public static void clearPrimaryImages(int clothingID) {
        ClothingImageDAO.clearPrimary(clothingID);
    }

    public static boolean updateClothing(Clothing clothing) {
        return ClothingDAO.updateClothing(clothing);
    }

    public static boolean deleteClothing(int clothingID) {
        return ClothingDAO.deleteClothing(clothingID);
    }

    public static List<Clothing> searchClothing(String keyword, String category, String style, String occasion) {
        List<Clothing> results = ClothingDAO.getAllActiveClothing();
        
        if (category != null && !category.isEmpty()) {
            results.retainAll(ClothingDAO.searchByCategory(category));
        }
        
        if (style != null && !style.isEmpty()) {
            results.retainAll(ClothingDAO.searchByStyle(style));
        }

        if (occasion != null && !occasion.isEmpty()) {
            results.retainAll(ClothingDAO.searchByOccasion(occasion));
        }
        
        return results;
    }
}
