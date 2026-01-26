package DAO;

import Model.ClothingImage;
import config.DatabaseConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ClothingImageDAO {

    public static int addClothingImage(ClothingImage image) {
        String sql = "INSERT INTO ClothingImage (ClothingID, ImagePath, ImageData, IsPrimary, CreatedAt) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, image.getClothingID());
            ps.setString(2, image.getImagePath());
            ps.setBytes(3, image.getImageData());
            ps.setBoolean(4, image.isPrimary());
            ps.setTimestamp(5, Timestamp.valueOf(image.getCreatedAt() != null ? image.getCreatedAt() : LocalDateTime.now()));
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

    public static List<ClothingImage> getImagesByClothing(int clothingID) {
        List<ClothingImage> list = new ArrayList<>();
        String sql = "SELECT * FROM ClothingImage WHERE ClothingID = ? ORDER BY IsPrimary DESC, CreatedAt DESC, ImageID DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static ClothingImage getImageByID(int imageID) {
        String sql = "SELECT * FROM ClothingImage WHERE ImageID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void clearPrimary(int clothingID) {
        String sql = "UPDATE ClothingImage SET IsPrimary = 0 WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static ClothingImage mapRow(ResultSet rs) throws SQLException {
        ClothingImage img = new ClothingImage();
        img.setImageID(rs.getInt("ImageID"));
        img.setClothingID(rs.getInt("ClothingID"));
        img.setImagePath(rs.getString("ImagePath"));
        img.setImageData(rs.getBytes("ImageData"));
        img.setPrimary(rs.getBoolean("IsPrimary"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        if (ts != null) img.setCreatedAt(ts.toLocalDateTime());
        return img;
    }
}
