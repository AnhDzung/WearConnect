package DAO;

import config.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavoritesDAO {
    
    /**
     * Thêm sản phẩm vào danh sách yêu thích
     */
    public static boolean addFavorite(int userID, int clothingID) {
        // Kiểm tra xem sản phẩm đã yêu thích chưa
        if (isFavorited(userID, clothingID)) {
            return true; // Đã yêu thích rồi, không cần thêm
        }
        
        String query = "INSERT INTO Favorites (UserID, ClothingID, CreatedAt) VALUES (?, ?, GETDATE())";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, userID);
            ps.setInt(2, clothingID);
            
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("Lỗi thêm yêu thích: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Xóa sản phẩm khỏi danh sách yêu thích
     */
    public static boolean removeFavorite(int userID, int clothingID) {
        String query = "DELETE FROM Favorites WHERE UserID = ? AND ClothingID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, userID);
            ps.setInt(2, clothingID);
            
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("Lỗi xóa yêu thích: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Kiểm tra sản phẩm có được yêu thích không
     */
    public static boolean isFavorited(int userID, int clothingID) {
        String query = "SELECT COUNT(*) FROM Favorites WHERE UserID = ? AND ClothingID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, userID);
            ps.setInt(2, clothingID);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kiểm tra yêu thích: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Lấy danh sách ID sản phẩm yêu thích của người dùng
     */
    public static List<Integer> getFavoriteClothingIDs(int userID) {
        List<Integer> favorites = new ArrayList<>();
        String query = "SELECT ClothingID FROM Favorites WHERE UserID = ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                favorites.add(rs.getInt("ClothingID"));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy danh sách yêu thích: " + e.getMessage());
            e.printStackTrace();
        }
        
        return favorites;
    }
    
    /**
     * Xóa tất cả yêu thích của người dùng (nếu cần)
     */
    public static boolean clearAllFavorites(int userID) {
        String query = "DELETE FROM Favorites WHERE UserID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, userID);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("Lỗi xóa tất cả yêu thích: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
