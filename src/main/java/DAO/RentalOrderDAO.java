package DAO;

import config.DatabaseConnection;
import Model.PaymentVerificationCandidate;
import Model.RentalOrder;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class RentalOrderDAO {
    
    public static int addRentalOrder(RentalOrder rentalOrder) {
        String sql = "INSERT INTO RentalOrder (ClothingID, RenterUserID, RentalStartDate, RentalEndDate, TotalPrice, DepositAmount, Status, SelectedSize, ColorID, UserRating, TrustBasedMultiplier, AdjustedDepositAmount) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            
            ps.setDouble(10, rentalOrder.getUserRating());
            ps.setDouble(11, rentalOrder.getTrustBasedMultiplier());
            ps.setDouble(12, rentalOrder.getAdjustedDepositAmount());
            
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
        String sql = "SELECT ro.*, c.ClothingName, c.RenterID, " +
                 "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                 "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
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
        String sql = "SELECT ro.*, c.ClothingName, " +
                 "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                 "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
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
        String sql = "SELECT ro.*, c.ClothingName, " +
                 "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                 "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
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
        String sql = "SELECT ro.*, c.ClothingName, " +
                 "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                 "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
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
        String sql = "SELECT ro.*, c.ClothingName, " +
                     "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                     "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
                     "FROM RentalOrder ro " +
                     "INNER JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                     "WHERE c.RenterID = ? " +
                     "ORDER BY ro.CreatedAt DESC";
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
        try { order.setRenterFullName(rs.getString("RenterFullName")); } catch (SQLException ignore) {}
        try { order.setRenterEmail(rs.getString("RenterEmail")); } catch (SQLException ignore) {}
        try { order.setRenterPhone(rs.getString("RenterPhone")); } catch (SQLException ignore) {}
        try { order.setRenterAddress(rs.getString("RenterAddress")); } catch (SQLException ignore) {}
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
        try { order.setPaymentProofImageData(rs.getBytes("PaymentProofImageData")); } catch (SQLException ignore) {}
        try { order.setReceivedProofImageData(rs.getBytes("ReceivedProofImageData")); } catch (SQLException ignore) {}
        try { order.setTrackingNumber(rs.getString("TrackingNumber")); } catch (SQLException ignore) {}   
        try { order.setReturnMethod(rs.getString("ReturnMethod")); } catch (SQLException ignore) {}
        try { order.setReturnTrackingNumber(rs.getString("ReturnTrackingNumber")); } catch (SQLException ignore) {}
        try { order.setRefundProofImage(rs.getString("RefundProofImage")); } catch (SQLException ignore) {}
        try { order.setManagerPaymentProofImage(rs.getString("ManagerPaymentProofImage")); } catch (SQLException ignore) {}
        try { order.setRefundProofImageData(rs.getBytes("RefundProofImageData")); } catch (SQLException ignore) {}
        try { order.setManagerPaymentProofImageData(rs.getBytes("ManagerPaymentProofImageData")); } catch (SQLException ignore) {}
        
        // Map new fields for trust-based deposit
        try { order.setUserRating(rs.getDouble("UserRating")); } catch (SQLException ignore) {}
        try { order.setTrustBasedMultiplier(rs.getDouble("TrustBasedMultiplier")); } catch (SQLException ignore) {}
        try { order.setAdjustedDepositAmount(rs.getDouble("AdjustedDepositAmount")); } catch (SQLException ignore) {}
        
        // Map return/refund fields
        try { 
            Timestamp actualReturnTs = rs.getTimestamp("ActualReturnDate");
            if (actualReturnTs != null) {
                order.setActualReturnDate(actualReturnTs.toLocalDateTime());
            }
        } catch (SQLException ignore) {}
        try { order.setReturnStatus(rs.getString("ReturnStatus")); } catch (SQLException ignore) {}
        try { order.setDamagePercentage(rs.getDouble("DamagePercentage")); } catch (SQLException ignore) {}
        try { order.setLateFees(rs.getDouble("LateFees")); } catch (SQLException ignore) {}
        try { order.setCompensationAmount(rs.getDouble("CompensationAmount")); } catch (SQLException ignore) {}
        try { order.setRefundAmount(rs.getDouble("RefundAmount")); } catch (SQLException ignore) {}
        
        return order;
    }

    public static boolean updatePaymentProofPath(int rentalOrderID, String path) {
        return updatePaymentProofPath(rentalOrderID, path, null);
    }

    public static boolean updatePaymentProofPath(int rentalOrderID, String path, byte[] imageData) {
        String sql = "UPDATE RentalOrder SET PaymentProofImage = ?, PaymentProofImageData = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            ps.setBytes(2, imageData);
            ps.setInt(3, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            String fallbackSql = "UPDATE RentalOrder SET PaymentProofImage = ? WHERE RentalOrderID = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setString(1, path);
                ps.setInt(2, rentalOrderID);
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return false;
    }

    public static boolean updateReceivedProofPath(int rentalOrderID, String path) {
        return updateReceivedProofPath(rentalOrderID, path, null);
    }

    public static boolean updateReceivedProofPath(int rentalOrderID, String path, byte[] imageData) {
        String sql = "UPDATE RentalOrder SET ReceivedProofImage = ?, ReceivedProofImageData = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            ps.setBytes(2, imageData);
            ps.setInt(3, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            String fallbackSql = "UPDATE RentalOrder SET ReceivedProofImage = ? WHERE RentalOrderID = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setString(1, path);
                ps.setInt(2, rentalOrderID);
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
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
    
    public static boolean updateReturnMethod(int rentalOrderID, String returnMethod) {
        String sql = "UPDATE RentalOrder SET ReturnMethod = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, returnMethod);
            ps.setInt(2, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public static boolean updateReturnTrackingNumber(int rentalOrderID, String returnTrackingNumber) {
        String sql = "UPDATE RentalOrder SET ReturnTrackingNumber = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, returnTrackingNumber);
            ps.setInt(2, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean markPaymentProcessed(int rentalOrderID) {
        String sql = "UPDATE RentalOrder SET PaymentProcessedDate = GETDATE() WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updateRefundProofImage(int rentalOrderID, String path) {
        return updateRefundProofImage(rentalOrderID, path, null);
    }

    public static boolean updateRefundProofImage(int rentalOrderID, String path, byte[] imageData) {
        String sql = "UPDATE RentalOrder SET RefundProofImage = ?, RefundProofImageData = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            ps.setBytes(2, imageData);
            ps.setInt(3, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            String fallbackSql = "UPDATE RentalOrder SET RefundProofImage = ? WHERE RentalOrderID = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setString(1, path);
                ps.setInt(2, rentalOrderID);
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return false;
    }

    public static boolean updateManagerPaymentProofImage(int rentalOrderID, String path) {
        return updateManagerPaymentProofImage(rentalOrderID, path, null);
    }

    public static boolean updateManagerPaymentProofImage(int rentalOrderID, String path, byte[] imageData) {
        String sql = "UPDATE RentalOrder SET ManagerPaymentProofImage = ?, ManagerPaymentProofImageData = ? WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            ps.setBytes(2, imageData);
            ps.setInt(3, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            String fallbackSql = "UPDATE RentalOrder SET ManagerPaymentProofImage = ? WHERE RentalOrderID = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setString(1, path);
                ps.setInt(2, rentalOrderID);
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return false;
    }

    public static byte[] getAnyProofImageDataByPath(String path) {
        byte[] data = getProofBytesByColumn("PaymentProofImage", "PaymentProofImageData", path);
        if (data != null) return data;
        data = getProofBytesByColumn("ReceivedProofImage", "ReceivedProofImageData", path);
        if (data != null) return data;
        data = getProofBytesByColumn("RefundProofImage", "RefundProofImageData", path);
        if (data != null) return data;
        return getProofBytesByColumn("ManagerPaymentProofImage", "ManagerPaymentProofImageData", path);
    }

    private static byte[] getProofBytesByColumn(String pathColumn, String dataColumn, String path) {
        String sql = "SELECT TOP 1 " + dataColumn + " FROM RentalOrder WHERE " + pathColumn + " = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBytes(dataColumn);
                }
            }
        } catch (SQLException e) {
            // Ignore when column is not migrated yet
        }
        return null;
    }
    
    /**
     * Update return information and calculate refund
     * Cập nhật thông tin trả hàng và tính toán hoàn lại
     */
    public static boolean updateReturnInfo(int rentalOrderID, LocalDateTime actualReturnDate, 
                                          String returnStatus, double damagePercentage,
                                          double lateFees, double compensationAmount,
                                          double refundAmount, double additionalCharges) {
        String sql = "UPDATE RentalOrder SET ActualReturnDate = ?, ReturnStatus = ?, " +
                    "DamagePercentage = ?, LateFees = ?, CompensationAmount = ?, " +
                    "RefundAmount = ?, AdditionalCharges = ?, Status = 'RETURNED' " +
                    "WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(actualReturnDate));
            ps.setString(2, returnStatus);
            ps.setDouble(3, damagePercentage);
            ps.setDouble(4, lateFees);
            ps.setDouble(5, compensationAmount);
            ps.setDouble(6, refundAmount);
            ps.setDouble(7, additionalCharges);
            ps.setInt(8, rentalOrderID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get rental orders ready for return (status = DELIVERED_PENDING_CONFIRMATION)
     */
    public static List<RentalOrder> getReadyForReturnOrders(int userID) {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, " +
                    "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                    "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
                    "FROM RentalOrder ro " +
                    "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                    "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                    "WHERE ro.RenterUserID = ? AND ro.Status = 'DELIVERED_PENDING_CONFIRMATION' " +
                    "ORDER BY ro.RentalEndDate DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
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
    
    /**
     * Get rental orders with return status (for manager to review)
     */
    public static List<RentalOrder> getReturnedOrdersByManager(int managerID) {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, " +
                    "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                    "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
                    "FROM RentalOrder ro " +
                    "INNER JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                    "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                    "WHERE c.RenterID = ? AND ro.Status = 'RETURNED' " +
                    "ORDER BY ro.ActualReturnDate DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerID);
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

    public static List<RentalOrder> getOverdueOrdersForNotification() {
        List<RentalOrder> list = new ArrayList<>();
        String sql = "SELECT ro.*, c.ClothingName, c.RenterID, " +
                     "a.Username AS RenterUsername, a.FullName AS RenterFullName, " +
                     "a.Email AS RenterEmail, a.PhoneNumber AS RenterPhone, a.Address AS RenterAddress " +
                     "FROM RentalOrder ro " +
                     "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "LEFT JOIN Accounts a ON ro.RenterUserID = a.AccountID " +
                     "WHERE ro.RentalEndDate < GETDATE() " +
                     "AND ro.ActualReturnDate IS NULL " +
                     "AND UPPER(TRIM(ro.Status)) NOT IN ('RETURNED', 'CANCELLED', 'COMPLETED') " +
                     "ORDER BY ro.RentalEndDate ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToRentalOrder(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RentalOrderDAO] Error fetching overdue orders: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public static List<PaymentVerificationCandidate> getPaymentSubmittedCandidatesForAIVerification(int timeoutHours, int limit) {
        List<PaymentVerificationCandidate> list = new ArrayList<>();
        int safeTimeoutHours = Math.max(1, timeoutHours);
        int safeLimit = Math.max(1, Math.min(limit, 200));

        String transferContentSelect = "'' AS TransferContentProvided";
        String paymentApplyRefColumn = "'' AS bankTransactionRef";

        try (Connection conn = DatabaseConnection.getConnection()) {
            if (hasColumn(conn, "Payment", "bankTransactionRef")) {
                transferContentSelect = "ISNULL(p.bankTransactionRef, '') AS TransferContentProvided";
                paymentApplyRefColumn = "bankTransactionRef";
            }

            String sql = "SELECT TOP " + safeLimit + " "
                    + "ro.RentalOrderID, ro.RenterUserID, c.RenterID AS ManagerID, "
                    + "CAST((ISNULL(ro.TotalPrice, 0) + ISNULL(ro.DepositAmount, 0)) AS DECIMAL(18,2)) AS ExpectedAmount, "
                    + "ISNULL(p.PaymentID, 0) AS PaymentID, ISNULL(p.Amount, 0) AS PaidAmount, "
                    + "COALESCE(p.PaymentDate, p.CreatedAt, ro.CreatedAt) AS TransferTime, "
                    + "ro.CreatedAt AS SubmittedAt, "
                    + "CASE WHEN ro.PaymentProofImage IS NULL OR LTRIM(RTRIM(ro.PaymentProofImage)) = '' THEN 0 ELSE 1 END AS HasProofImage, "
                    + "ISNULL(ro.PaymentProofImage, '') AS ProofImagePath, "
                    + "('WRC' + RIGHT('00000' + CAST(ro.RentalOrderID AS VARCHAR(20)), 5)) AS ExpectedTransferContent, "
                    + transferContentSelect + " "
                    + "FROM RentalOrder ro "
                    + "LEFT JOIN Clothing c ON ro.ClothingID = c.ClothingID "
                    + "OUTER APPLY ( "
                    + "  SELECT TOP 1 PaymentID, Amount, PaymentDate, CreatedAt, " + paymentApplyRefColumn + " "
                    + "  FROM Payment "
                    + "  WHERE RentalOrderID = ro.RentalOrderID "
                    + "  ORDER BY PaymentID DESC "
                    + ") p "
                    + "WHERE UPPER(LTRIM(RTRIM(ro.Status))) = 'PAYMENT_SUBMITTED' "
                    + "AND COALESCE(p.PaymentDate, p.CreatedAt, ro.CreatedAt) <= DATEADD(HOUR, -?, GETDATE()) "
                    + "ORDER BY COALESCE(p.PaymentDate, p.CreatedAt, ro.CreatedAt) ASC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeTimeoutHours);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentVerificationCandidate candidate = new PaymentVerificationCandidate();
                    candidate.setRentalOrderID(rs.getInt("RentalOrderID"));
                    candidate.setRenterUserID(rs.getInt("RenterUserID"));
                    candidate.setManagerID(rs.getInt("ManagerID"));
                    candidate.setPaymentID(rs.getInt("PaymentID"));
                    candidate.setExpectedAmount(rs.getDouble("ExpectedAmount"));
                    candidate.setPaidAmount(rs.getDouble("PaidAmount"));

                    Timestamp transferTs = rs.getTimestamp("TransferTime");
                    if (transferTs != null) {
                        candidate.setTransferTime(transferTs.toLocalDateTime());
                    }

                    Timestamp submittedTs = rs.getTimestamp("SubmittedAt");
                    if (submittedTs != null) {
                        candidate.setSubmittedAt(submittedTs.toLocalDateTime());
                    }

                    candidate.setHasProofImage(rs.getInt("HasProofImage") == 1);
                    candidate.setProofImagePath(rs.getString("ProofImagePath"));
                    candidate.setExpectedTransferContent(rs.getString("ExpectedTransferContent"));
                    candidate.setProvidedTransferContent(rs.getString("TransferContentProvided"));
                    list.add(candidate);
                }
            }
            }
        } catch (SQLException e) {
            System.err.println("[RentalOrderDAO] Error fetching AI payment verification candidates: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    private static boolean hasColumn(Connection conn, String tableName, String columnName) {
        String sql = "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt("cnt") > 0;
            }
        } catch (SQLException e) {
            return false;
        }
    }
}
