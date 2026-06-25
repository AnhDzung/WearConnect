package DAO;

import Model.CartItem;
import config.DatabaseConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    public static List<CartItem> getCartByAccountID(int accountID) {
        List<CartItem> cartList = new ArrayList<>();
        String sql = "SELECT ci.CartItemID, ci.AccountID, ci.ClothingID, ci.RentalType, ci.StartDate, ci.EndDate, ci.SelectedSize, ci.ColorID, " +
                     "       c.ClothingName, c.Category, c.HourlyPrice, c.DailyPrice, c.ItemValue, " +
                     "       co.ColorName, " +
                     "       (SELECT TOP 1 ImageID FROM ClothingImage WHERE ClothingID = ci.ClothingID ORDER BY IsPrimary DESC, CreatedAt DESC, ImageID DESC) AS ImageID " +
                     "FROM CartItems ci " +
                     "INNER JOIN Clothing c ON ci.ClothingID = c.ClothingID " +
                     "LEFT JOIN Color co ON ci.ColorID = co.ColorID " +
                     "WHERE ci.AccountID = ? " +
                     "ORDER BY ci.CartItemID ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, accountID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getInt("CartItemID"));
                    item.setClothingID(rs.getInt("ClothingID"));
                    item.setClothingName(rs.getString("ClothingName"));
                    item.setCategory(rs.getString("Category"));
                    item.setHourlyPrice(rs.getDouble("HourlyPrice"));
                    item.setDailyPrice(rs.getDouble("DailyPrice"));
                    item.setItemValue(rs.getDouble("ItemValue"));
                    item.setRentalType(rs.getString("RentalType"));
                    
                    Timestamp startTs = rs.getTimestamp("StartDate");
                    if (startTs != null) {
                        item.setStartDate(startTs.toLocalDateTime());
                    }
                    Timestamp endTs = rs.getTimestamp("EndDate");
                    if (endTs != null) {
                        item.setEndDate(endTs.toLocalDateTime());
                    }
                    
                    item.setSelectedSize(rs.getString("SelectedSize"));
                    
                    int colorID = rs.getInt("ColorID");
                    if (!rs.wasNull()) {
                        item.setColorID(colorID);
                    }
                    item.setColorName(rs.getString("ColorName"));
                    
                    int imageID = rs.getInt("ImageID");
                    if (!rs.wasNull()) {
                        item.setImageID(imageID);
                    }
                    
                    cartList.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy giỏ hàng từ database: " + e.getMessage());
            e.printStackTrace();
        }
        return cartList;
    }

    public static boolean addCartItem(int accountID, CartItem item) {
        String sql = "INSERT INTO CartItems (AccountID, ClothingID, RentalType, StartDate, EndDate, SelectedSize, ColorID) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, accountID);
            ps.setInt(2, item.getClothingID());
            ps.setString(3, item.getRentalType());
            ps.setTimestamp(4, Timestamp.valueOf(item.getStartDate()));
            ps.setTimestamp(5, Timestamp.valueOf(item.getEndDate()));
            ps.setString(6, item.getSelectedSize());
            if (item.getColorID() != null) {
                ps.setInt(7, item.getColorID());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setCartItemId(rs.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi thêm sản phẩm vào giỏ hàng database: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public static boolean removeCartItem(int accountID, int cartItemId) {
        String sql = "DELETE FROM CartItems WHERE AccountID = ? AND CartItemID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, accountID);
            ps.setInt(2, cartItemId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi xóa sản phẩm khỏi giỏ hàng database: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public static boolean clearCart(int accountID) {
        String sql = "DELETE FROM CartItems WHERE AccountID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, accountID);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("Lỗi xóa toàn bộ giỏ hàng database: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public static boolean removeCartItemByProduct(int accountID, int clothingID, String selectedSize, Integer colorID) {
        String sql = "DELETE FROM CartItems WHERE AccountID = ? AND ClothingID = ? " +
                     "AND (SelectedSize = ? OR (SelectedSize IS NULL AND ? IS NULL)) " +
                     "AND (ColorID = ? OR (ColorID IS NULL AND ? IS NULL))";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, accountID);
            ps.setInt(2, clothingID);
            ps.setString(3, selectedSize);
            ps.setString(4, selectedSize);
            if (colorID != null) {
                ps.setInt(5, colorID);
                ps.setInt(6, colorID);
            } else {
                ps.setNull(5, Types.INTEGER);
                ps.setNull(6, Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi xóa sản phẩm giỏ hàng theo sản phẩm: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
