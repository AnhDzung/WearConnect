package DAO;

import config.DatabaseConnection;
import Model.Clothing;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class ClothingDAO {
    
    public static int addClothing(Clothing clothing) {
        String sql = "INSERT INTO Clothing (RenterID, ClothingName, Category, Style, Occasion, Size, Description, HourlyPrice, DailyPrice, ImagePath, ImageData, AvailableFrom, AvailableTo, Quantity, DepositAmount, ClothingStatus) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, clothing.getRenterID());
            ps.setString(2, clothing.getClothingName());
            ps.setString(3, clothing.getCategory());
            ps.setString(4, clothing.getStyle());
            ps.setString(5, clothing.getOccasion());
            ps.setString(6, clothing.getSize());
            ps.setString(7, clothing.getDescription());
            ps.setBigDecimal(8, clothing.getHourlyPriceBigDecimal());
            ps.setBigDecimal(9, clothing.getDailyPriceBigDecimal());
            ps.setString(10, clothing.getImagePath());
            ps.setBytes(11, clothing.getImageData());
            ps.setTimestamp(12, Timestamp.valueOf(clothing.getAvailableFrom()));
            ps.setTimestamp(13, Timestamp.valueOf(clothing.getAvailableTo()));
            ps.setInt(14, clothing.getQuantity() > 0 ? clothing.getQuantity() : 1);
            ps.setBigDecimal(15, clothing.getDepositAmountBigDecimal());
            ps.setString(16, clothing.getClothingStatus() != null ? clothing.getClothingStatus() : "ACTIVE");
            
            int row = ps.executeUpdate();
            if (row > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static List<Clothing> getAllActiveClothing() {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToClothing(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static Clothing getClothingByID(int clothingID) {
        String sql = "SELECT * FROM Clothing WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToClothing(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<Clothing> searchByCategory(String category) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Category = ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchByStyle(String style) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Style LIKE ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + style + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchByOccasion(String occasion) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Occasion LIKE ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + occasion + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchByName(String name) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE ClothingName LIKE ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + name + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> getClothingByRenter(int renterID) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE RenterID = ? AND IsActive = 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean updateClothing(Clothing clothing) {
        String sql = "UPDATE Clothing SET ClothingName = ?, Category = ?, Style = ?, Occasion = ?, Size = ?, Description = ?, HourlyPrice = ?, DailyPrice = ?, ImagePath = ?, ImageData = ?, AvailableFrom = ?, AvailableTo = ?, Quantity = ?, DepositAmount = ? WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clothing.getClothingName());
            ps.setString(2, clothing.getCategory());
            ps.setString(3, clothing.getStyle());
            ps.setString(4, clothing.getOccasion());
            ps.setString(5, clothing.getSize());
            ps.setString(6, clothing.getDescription());
            ps.setBigDecimal(7, clothing.getHourlyPriceBigDecimal());
            ps.setBigDecimal(8, clothing.getDailyPriceBigDecimal());
            ps.setString(9, clothing.getImagePath());
            ps.setBytes(10, clothing.getImageData());
            ps.setTimestamp(11, Timestamp.valueOf(clothing.getAvailableFrom()));
            ps.setTimestamp(12, Timestamp.valueOf(clothing.getAvailableTo()));
            ps.setInt(13, clothing.getQuantity());
            ps.setBigDecimal(14, clothing.getDepositAmountBigDecimal());
            ps.setInt(15, clothing.getClothingID());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean deleteClothing(int clothingID) {
        String sql = "UPDATE Clothing SET IsActive = 0 WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static Clothing mapRowToClothing(ResultSet rs) throws SQLException {
        Clothing clothing = new Clothing();
        clothing.setClothingID(rs.getInt("ClothingID"));
        clothing.setRenterID(rs.getInt("RenterID"));
        clothing.setClothingName(rs.getString("ClothingName"));
        clothing.setCategory(rs.getString("Category"));
        clothing.setStyle(rs.getString("Style"));
        clothing.setOccasion(rs.getString("Occasion"));
        clothing.setSize(rs.getString("Size"));
        clothing.setDescription(rs.getString("Description"));
        clothing.setHourlyPrice(rs.getBigDecimal("HourlyPrice"));
        BigDecimal dailyPrice = rs.getBigDecimal("DailyPrice");
        if (dailyPrice == null) {
            // Nếu DailyPrice NULL, set mặc định = HourlyPrice * 24
            BigDecimal hourlyPrice = rs.getBigDecimal("HourlyPrice");
            dailyPrice = hourlyPrice != null ? hourlyPrice.multiply(new java.math.BigDecimal(24)) : new java.math.BigDecimal(0);
        }
        clothing.setDailyPrice(dailyPrice);
        clothing.setImagePath(rs.getString("ImagePath"));
        clothing.setImageData(rs.getBytes("ImageData"));
        clothing.setAvailableFrom(rs.getTimestamp("AvailableFrom").toLocalDateTime());
        clothing.setAvailableTo(rs.getTimestamp("AvailableTo").toLocalDateTime());
        clothing.setActive(rs.getBoolean("IsActive"));
        
        // Set quantity with default value of 1 if not present
        int quantity = rs.getInt("Quantity");
        clothing.setQuantity(quantity > 0 ? quantity : 1);
        
        // Set deposit amount
        BigDecimal depositAmount = rs.getBigDecimal("DepositAmount");
        if (depositAmount != null) {
            clothing.setDepositAmount(depositAmount);
        }
        
        // Set clothing status
        String clothingStatus = rs.getString("ClothingStatus");
        clothing.setClothingStatus(clothingStatus != null ? clothingStatus : "ACTIVE");
        
        clothing.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
        return clothing;
    }
    
    /**
     * Get all cosplay products by status
     */
    public static List<Clothing> getCosplayByStatus(String status) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Category = 'Cosplay' AND ClothingStatus = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToClothing(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Update clothing status
     */
    public static boolean updateClothingStatus(int clothingID, String status) {
        String sql = "UPDATE Clothing SET ClothingStatus = ? WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, clothingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Set clothing active status
     */
    public static boolean setClothingActive(int clothingID, boolean isActive) {
        String sql = "UPDATE Clothing SET IsActive = ? WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, isActive ? 1 : 0);
            ps.setInt(2, clothingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
