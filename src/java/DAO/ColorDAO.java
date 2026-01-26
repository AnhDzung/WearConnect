package DAO;

import config.DatabaseConnection;
import Model.Color;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ColorDAO {

    /**
     * Lấy tất cả màu toàn cục và màu riêng của manager
     */
    public static List<Color> getColorsByManager(int managerID) {
        List<Color> colors = new ArrayList<>();
        String sql = "SELECT * FROM Color WHERE IsGlobal = 1 OR ManagerID = ? ORDER BY IsGlobal DESC, ColorName ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    colors.add(mapResultSetToColor(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return colors;
    }

    /**
     * Lấy tất cả màu toàn cục
     */
    public static List<Color> getGlobalColors() {
        List<Color> colors = new ArrayList<>();
        String sql = "SELECT * FROM Color WHERE IsGlobal = 1 ORDER BY ColorName ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                colors.add(mapResultSetToColor(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return colors;
    }

    /**
     * Lấy màu riêng của manager
     */
    public static List<Color> getManagerCustomColors(int managerID) {
        List<Color> colors = new ArrayList<>();
        String sql = "SELECT * FROM Color WHERE ManagerID = ? ORDER BY ColorName ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    colors.add(mapResultSetToColor(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return colors;
    }

    /**
     * Tìm hoặc tạo mới màu sắc
     * - Nếu tên màu đã tồn tại toàn cục, trả về ID
     * - Nếu tên màu đã tồn tại của manager, trả về ID
     * - Nếu chưa tồn tại, tạo mới và trả về ID
     */
    public static int upsertColor(String colorName, String hexCode, Integer managerID) {
        String trimmedName = colorName.trim();
        
        // Kiểm tra màu toàn cục trước
        Color existingGlobalColor = getColorByName(trimmedName, null);
        if (existingGlobalColor != null) {
            return existingGlobalColor.getColorID();
        }

        // Kiểm tra màu riêng của manager
        if (managerID != null) {
            Color existingManagerColor = getColorByName(trimmedName, managerID);
            if (existingManagerColor != null) {
                return existingManagerColor.getColorID();
            }
        }

        // Tạo màu mới
        Color newColor = new Color(trimmedName, hexCode, managerID, managerID == null);
        return addColor(newColor);
    }

    /**
     * Tìm màu theo tên
     */
    public static Color getColorByName(String colorName, Integer managerID) {
        String sql;
        if (managerID == null) {
            sql = "SELECT * FROM Color WHERE LOWER(RTRIM(LTRIM(ColorName))) = LOWER(RTRIM(LTRIM(?))) AND ManagerID IS NULL";
        } else {
            sql = "SELECT * FROM Color WHERE LOWER(RTRIM(LTRIM(ColorName))) = LOWER(RTRIM(LTRIM(?))) AND ManagerID = ?";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, colorName.trim());
            if (managerID != null) {
                ps.setInt(2, managerID);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToColor(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm màu mới
     */
    public static int addColor(Color color) {
        String sql = "INSERT INTO Color (ColorName, HexCode, ManagerID, IsGlobal) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, color.getColorName().trim());
            ps.setString(2, color.getHexCode());
            if (color.getManagerID() != null) {
                ps.setInt(3, color.getManagerID());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setBoolean(4, color.isGlobal());

            int row = ps.executeUpdate();
            if (row > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Lấy màu theo ID
     */
    public static Color getColorByID(int colorID) {
        String sql = "SELECT * FROM Color WHERE ColorID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, colorID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToColor(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách màu của một sản phẩm
     */
    public static List<Color> getColorsByClothing(int clothingID) {
        List<Color> colors = new ArrayList<>();
        String sql = "SELECT c.* FROM Color c " +
                     "INNER JOIN ClothingColor cc ON c.ColorID = cc.ColorID " +
                     "WHERE cc.ClothingID = ? " +
                     "ORDER BY c.ColorName ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    colors.add(mapResultSetToColor(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return colors;
    }

    /**
     * Thêm màu cho sản phẩm
     */
    public static boolean addColorToClothing(int clothingID, int colorID) {
        String sql = "INSERT INTO ClothingColor (ClothingID, ColorID) VALUES (?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            ps.setInt(2, colorID);
            
            int row = ps.executeUpdate();
            return row > 0;
        } catch (SQLException e) {
            // Bỏ qua nếu duplicate
            if (e.getMessage().contains("UNIQUE")) {
                return true;
            }
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa tất cả màu của sản phẩm
     */
    public static boolean removeAllColorsFromClothing(int clothingID) {
        String sql = "DELETE FROM ClothingColor WHERE ClothingID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa màu
     */
    public static boolean deleteColor(int colorID) {
        String sql = "DELETE FROM Color WHERE ColorID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, colorID);
            int row = ps.executeUpdate();
            return row > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Helper method: Map ResultSet to Color object
     */
    private static Color mapResultSetToColor(ResultSet rs) throws SQLException {
        Color color = new Color();
        color.setColorID(rs.getInt("ColorID"));
        color.setColorName(rs.getString("ColorName"));
        color.setHexCode(rs.getString("HexCode"));
        
        int managerID = rs.getInt("ManagerID");
        color.setManagerID(rs.wasNull() ? null : managerID);
        
        color.setGlobal(rs.getBoolean("IsGlobal"));
        
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) {
            color.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        return color;
    }
}
