package DAO;

import config.DatabaseConnection;
import Model.RentalOrder;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RentalOrderDAO {
    
    public static int addRentalOrder(RentalOrder rentalOrder) {
        String sql = "INSERT INTO RentalOrder (ClothingID, RenterUserID, RentalStartDate, RentalEndDate, TotalPrice, DepositAmount, Status, SelectedSize, ColorID) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, rentalOrder.getClothingID());
            ps.setInt(2, rentalOrder.getRenterUserID());
            ps.setTimestamp(3, Timestamp.valueOf(rentalOrder.getRentalStartDate()));
            ps.setTimestamp(4, Timestamp.valueOf(rentalOrder.getRentalEndDate()));
            ps.setDouble(5, rentalOrder.getTotalPrice());
            ps.setDouble(6, rentalOrder.getDepositAmount());
            ps.setString(7, rentalOrder.getStatus());
            ps.setString(8, rentalOrder.getSelectedSize());
            
            if (rentalOrder.getColorID() != null) {
                ps.setInt(9, rentalOrder.getColorID());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            
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

    public static RentalOrder getRentalOrderByID(int rentalOrderID) {
        String sql = "SELECT ro.*, c.ClothingName, c.RenterID, a.Username AS RenterUsername " +
                 "FROM RentalOrder ro " +
                 "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                 "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                 "WHERE ro.RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("[DEBUG] getRentalOrderByID: Found order " + rentalOrderID);
                    return mapRowToRentalOrder(rs);
                } else {
                    System.out.println("[DEBUG] getRentalOrderByID: Order " + rentalOrderID + " not found");
                }
            }
        } catch (SQLException e) {
            System.err.println("[ERROR] getRentalOrderByID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public static List<RentalOrder> getRentalOrdersByUser(int userID) {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, a.Username AS RenterUsername " +
                 "FROM RentalOrder ro " +
                 "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                 "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                 "WHERE ro.RenterUserID = ? ORDER BY ro.CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            System.out.println("[RentalOrderDAO] getRentalOrdersByUser - userID: " + userID + ", SQL: " + sql);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRentalOrder(rs));
                }
                System.out.println("[RentalOrderDAO] getRentalOrdersByUser - Found " + list.size() + " orders for user " + userID);
            }
        } catch (SQLException e) {
            System.err.println("[ERROR] getRentalOrdersByUser: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public static List<RentalOrder> getRentalOrdersByClothing(int clothingID) {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, a.Username AS RenterUsername " +
                 "FROM RentalOrder ro " +
                 "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                 "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                 "WHERE ro.ClothingID = ? ORDER BY ro.RentalStartDate";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRentalOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean updateRentalOrderStatus(int rentalOrderID, String newStatus) {
        String sql = "UPDATE RentalOrder SET Status = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, rentalOrderID);
            
            if (ps.executeUpdate() > 0) {
                // Add history
                addRentalHistory(rentalOrderID, newStatus, null);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updateRentalOrderStatusWithNotes(int rentalOrderID, String newStatus, String notes) {
        String sql = "UPDATE RentalOrder SET Status = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, rentalOrderID);

            if (ps.executeUpdate() > 0) {
                // Add history with notes (e.g., proof image path)
                addRentalHistory(rentalOrderID, newStatus, notes);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static int cancelExpiredPendingPayments(int hours) {
        String sql = "UPDATE RentalOrder SET Status = 'CANCELLED' " +
                     "WHERE Status = 'PENDING_PAYMENT' AND CreatedAt < ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            long cutoffMillis = System.currentTimeMillis() - hours * 3600L * 1000L;
            ps.setTimestamp(1, new Timestamp(cutoffMillis));
            int updated = ps.executeUpdate();
            return updated;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static List<RentalOrder> getRentalOrdersByStatus(String status) {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, a.Username AS RenterUsername " +
                 "FROM RentalOrder ro " +
                 "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                 "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                 "WHERE ro.Status = ? ORDER BY ro.CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRentalOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static int countRentalOrdersByStatus(String status) {
        // Normalize status for comparison
        String normalizedStatus = (status != null) ? status.trim().toUpperCase() : "";
        String sql = "SELECT COUNT(*) AS cnt FROM RentalOrder WHERE UPPER(TRIM(Status)) = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedStatus);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("cnt");
                    System.out.println("[RentalOrderDAO] countRentalOrdersByStatus('" + normalizedStatus + "'): " + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            System.err.println("[RentalOrderDAO] countRentalOrdersByStatus Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    public static List<RentalOrder> getRentalOrdersByManager(int managerID) {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, a.Username AS RenterUsername FROM RentalOrder ro " +
                     "INNER JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                     "WHERE c.RenterID = ? ORDER BY ro.CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerID);
            System.out.println("[RentalOrderDAO] Getting rental orders for manager: " + managerID);
            System.out.println("[RentalOrderDAO] SQL: " + sql);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRentalOrder(rs));
                }
                System.out.println("[RentalOrderDAO] Found " + list.size() + " orders");
            }
        } catch (SQLException e) {
            System.out.println("[RentalOrderDAO] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    private static void addRentalHistory(int rentalOrderID, String status, String notes) {
        String sql = "INSERT INTO RentalHistory (RentalOrderID, Status, Notes) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            ps.setString(2, status);
            ps.setString(3, notes);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static RentalOrder mapRowToRentalOrder(ResultSet rs) throws SQLException {
        RentalOrder order = new RentalOrder();
        order.setRentalOrderID(rs.getInt("RentalOrderID"));
        order.setClothingID(rs.getInt("ClothingID"));
        order.setRenterUserID(rs.getInt("RenterUserID"));
        try { order.setManagerID(rs.getInt("RenterID")); } catch (SQLException ignore) {}
        order.setRentalStartDate(rs.getTimestamp("RentalStartDate").toLocalDateTime());
        order.setRentalEndDate(rs.getTimestamp("RentalEndDate").toLocalDateTime());
        order.setTotalPrice(rs.getDouble("TotalPrice"));
        order.setDepositAmount(rs.getDouble("DepositAmount"));
        order.setStatus(rs.getString("Status"));
        order.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
        try { order.setClothingName(rs.getString("ClothingName")); } catch (SQLException ignore) {}
        try { order.setRenterUsername(rs.getString("RenterUsername")); } catch (SQLException ignore) {}
        try { order.setSelectedSize(rs.getString("SelectedSize")); } catch (SQLException ignore) {}
        
        // Map colorID
        try { 
            int colorID = rs.getInt("ColorID");
            if (!rs.wasNull()) {
                order.setColorID(colorID);
            }
        } catch (SQLException ignore) {}
        try { order.setPaymentProofImage(rs.getString("PaymentProofImage")); } catch (SQLException ignore) {}
        try { order.setReceivedProofImage(rs.getString("ReceivedProofImage")); } catch (SQLException ignore) {}
        try { order.setTrackingNumber(rs.getString("TrackingNumber")); } catch (SQLException ignore) {}
        
        return order;
    }

    public static boolean updatePaymentProofPath(int rentalOrderID, String path) {
        String sql = "UPDATE RentalOrder SET PaymentProofImage = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            ps.setInt(2, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updateReceivedProofPath(int rentalOrderID, String path) {
        String sql = "UPDATE RentalOrder SET ReceivedProofImage = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            ps.setInt(2, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updateTrackingNumber(int rentalOrderID, String trackingNumber) {
        String sql = "UPDATE RentalOrder SET TrackingNumber = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingNumber);
            ps.setInt(2, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
