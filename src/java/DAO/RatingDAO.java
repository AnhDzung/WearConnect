package DAO;

import config.DatabaseConnection;
import Model.Rating;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RatingDAO {
    
    public static int addRating(Rating rating) {
        String sql = "INSERT INTO Rating (RentalOrderID, RatingFromUserID, Rating, Comment) " +
                     "VALUES (?, ?, ?, ?)";
        System.out.println("[RatingDAO] Inserting rating - RentalOrderID: " + rating.getRentalOrderID() + 
                         ", RatingFromUserID: " + rating.getRatingFromUserID() + 
                         ", Rating: " + rating.getRating());
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, rating.getRentalOrderID());
            ps.setInt(2, rating.getRatingFromUserID());
            ps.setInt(3, rating.getRating());
            ps.setString(4, rating.getComment());
            
            int row = ps.executeUpdate();
            System.out.println("[RatingDAO] Insert result rows affected: " + row);
            if (row > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int ratingID = rs.getInt(1);
                    System.out.println("[RatingDAO] Rating inserted successfully with ID: " + ratingID);
                    return ratingID;
                }
            }
        } catch (SQLException e) {
            System.err.println("[RatingDAO] Error inserting rating: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[RatingDAO] Rating insert failed, returning -1");
        return -1;
    }

    public static Rating getRatingByID(int ratingID) {
        String sql = "SELECT * FROM Rating WHERE RatingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ratingID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToRating(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Rating getRatingByRentalOrder(int rentalOrderID) {
        String sql = "SELECT * FROM Rating WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToRating(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Rating getRatingByRentalOrderAndUser(int rentalOrderID, int userID) {
        String sql = "SELECT * FROM Rating WHERE RentalOrderID = ? AND RatingFromUserID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            ps.setInt(2, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToRating(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int getFiveStarCountForUser(int userID) {
        String sql = "SELECT COUNT(*) AS FiveCount FROM Rating r " +
                     "JOIN RentalOrder ro ON r.RentalOrderID = ro.RentalOrderID " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE r.Rating = 5 AND ( (r.RatingFromUserID = ro.RenterUserID AND c.RenterID = ?) " +
                     "OR (r.RatingFromUserID <> ro.RenterUserID AND ro.RenterUserID = ?) )";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            ps.setInt(2, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("FiveCount");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static List<Rating> getRatingsByRenter(int renterID) {
        List<Rating> list = new ArrayList<>();
        String sql = "SELECT r.* FROM Rating r " +
                     "JOIN RentalOrder ro ON r.RentalOrderID = ro.RentalOrderID " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? ORDER BY r.CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRating(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Rating> getRatingsByClothing(int clothingID) {
        List<Rating> list = new ArrayList<>();
        String sql = "SELECT r.*, a.Username AS RatingFromUsername, c.ClothingName, ro.RenterUserID AS RenterUserID, c.RenterID AS ManagerUserID " +
                 "FROM Rating r " +
                 "JOIN RentalOrder ro ON r.RentalOrderID = ro.RentalOrderID " +
                 "JOIN Accounts a ON r.RatingFromUserID = a.AccountID " +
                 "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                 "WHERE ro.ClothingID = ? ORDER BY r.CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRating(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static double getAverageRatingForClothing(int clothingID) {
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) as AvgRating FROM Rating r " +
                     "JOIN RentalOrder ro ON r.RentalOrderID = ro.RentalOrderID " +
                     "WHERE ro.ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("AvgRating");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public static double getAverageRatingForRenter(int renterID) {
        String sql = "SELECT AVG(CAST(r.Rating AS FLOAT)) as AvgRating FROM Rating r " +
                     "JOIN RentalOrder ro ON r.RentalOrderID = ro.RentalOrderID " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("AvgRating");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public static boolean deleteRating(int ratingID) {
        String sql = "DELETE FROM Rating WHERE RatingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ratingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static Rating mapRowToRating(ResultSet rs) throws SQLException {
        Rating rating = new Rating();
        rating.setRatingID(rs.getInt("RatingID"));
        rating.setRentalOrderID(rs.getInt("RentalOrderID"));
        rating.setRatingFromUserID(rs.getInt("RatingFromUserID"));
        rating.setRating(rs.getInt("Rating"));
        rating.setComment(rs.getString("Comment"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        if (ts != null) {
            rating.setCreatedAt(ts.toLocalDateTime());
        }
        // Optional joined columns
        try { rating.setRatingFromUsername(rs.getString("RatingFromUsername")); } catch (SQLException ignore) {}
        try { rating.setClothingName(rs.getString("ClothingName")); } catch (SQLException ignore) {}
        try { rating.setRentalRenterUserID(rs.getInt("RenterUserID")); } catch (SQLException ignore) {}
        try { rating.setRentalManagerUserID(rs.getInt("ManagerUserID")); } catch (SQLException ignore) {}
        return rating;
    }
}
