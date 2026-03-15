package Service;

import Model.Clothing;
import Model.RentalOrder;
import Model.Rating;
import DAO.ClothingDAO;
import DAO.RentalOrderDAO;
import DAO.RatingDAO;
import config.DatabaseConnection;
import java.sql.*;
import java.util.*;

public class DashboardService {
    private static final double SYSTEM_FEE_RATE = 0.10;
    
    // Lấy doanh thu thực nhận của manager (toàn thời gian, sau khi trừ 10% phí hệ thống)
    public static double getTotalRevenue(int renterID) {
        String sql = "SELECT SUM(ro.TotalPrice * ?) as TotalRevenue FROM RentalOrder ro " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? AND ro.Status = 'COMPLETED'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, 1.0 - SYSTEM_FEE_RATE);
            ps.setInt(2, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double revenue = rs.getDouble("TotalRevenue");
                    return rs.wasNull() ? 0.0 : revenue;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Lấy số lượng đơn hàng hoàn thành
    public static int getCompletedOrderCount(int renterID) {
        String sql = "SELECT COUNT(*) as CompletedCount FROM RentalOrder ro " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? AND ro.Status = 'COMPLETED'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("CompletedCount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Lấy số lượng đơn hàng đang chờ
    public static int getPendingOrderCount(int renterID) {
        String sql = "SELECT COUNT(*) as PendingCount FROM RentalOrder ro " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? AND ro.Status IN ('PENDING_PAYMENT', 'PAYMENT_VERIFIED')";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("PendingCount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy số lượng đơn hàng đã được admin xác thực (CONFIRMED)
    public static int getConfirmedOrderCount(int renterID) {
        String sql = "SELECT COUNT(*) as ConfirmedCount FROM RentalOrder ro " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? AND ro.Status = 'PAYMENT_VERIFIED'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ConfirmedCount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Lấy số lượng sản phẩm hoạt động
    public static int getActiveProductCount(int renterID) {
        String sql = "SELECT COUNT(*) as ActiveCount FROM Clothing WHERE RenterID = ? AND IsActive = 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ActiveCount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Lấy top 3 sản phẩm có đánh giá cao nhất
    public static List<Map<String, Object>> getTopRatedProducts(int renterID, int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " c.ClothingID, c.ClothingName, c.HourlyPrice, " +
                     "AVG(CAST(r.Rating AS FLOAT)) as AvgRating, COUNT(r.RatingID) as RatingCount " +
                     "FROM Clothing c " +
                     "LEFT JOIN RentalOrder ro ON c.ClothingID = ro.ClothingID " +
                     "LEFT JOIN Rating r ON ro.RentalOrderID = r.RentalOrderID " +
                     "WHERE c.RenterID = ? AND c.IsActive = 1 " +
                     "GROUP BY c.ClothingID, c.ClothingName, c.HourlyPrice " +
                     "ORDER BY AvgRating DESC, RatingCount DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("clothingID", rs.getInt("ClothingID"));
                    row.put("clothingName", rs.getString("ClothingName"));
                    row.put("hourlyPrice", rs.getDouble("HourlyPrice"));
                    row.put("avgRating", rs.getDouble("AvgRating"));
                    row.put("ratingCount", rs.getInt("RatingCount"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    // Lấy top 3 sản phẩm có doanh thu thực nhận cao nhất (chỉ đơn COMPLETED, đã trừ 10% phí)
    public static List<Map<String, Object>> getTopRevenueProducts(int renterID, int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " c.ClothingID, c.ClothingName, c.HourlyPrice, " +
                     "SUM(ro.TotalPrice * ?) as TotalRevenue, COUNT(ro.RentalOrderID) as OrderCount " +
                     "FROM Clothing c " +
                     "LEFT JOIN RentalOrder ro ON c.ClothingID = ro.ClothingID " +
                     "WHERE c.RenterID = ? AND c.IsActive = 1 AND ro.Status = 'COMPLETED' " +
                     "GROUP BY c.ClothingID, c.ClothingName, c.HourlyPrice " +
                     "ORDER BY TotalRevenue DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, 1.0 - SYSTEM_FEE_RATE);
            ps.setInt(2, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("clothingID", rs.getInt("ClothingID"));
                    row.put("clothingName", rs.getString("ClothingName"));
                    row.put("hourlyPrice", rs.getDouble("HourlyPrice"));
                    row.put("totalRevenue", rs.getDouble("TotalRevenue"));
                    row.put("orderCount", rs.getInt("OrderCount"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    // Lấy doanh thu thực nhận theo ngày cho biểu đồ.
    // Chỉ tính các đơn COMPLETED, nhóm theo ngày admin xử lý thanh toán (PaymentProcessedDate),
    // fallback về CreatedAt nếu dữ liệu cũ chưa có PaymentProcessedDate.
    public static List<Map<String, Object>> getRevenueByDate(int renterID, int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        String primaryDateExpr = "COALESCE(ro.PaymentProcessedDate, ro.CreatedAt)";
        try {
            loadRevenueByDate(result, renterID, days, primaryDateExpr);
        } catch (SQLException primaryError) {
            // Older databases may not have PaymentProcessedDate yet.
            try {
                loadRevenueByDate(result, renterID, days, "ro.CreatedAt");
            } catch (SQLException fallbackError) {
                fallbackError.printStackTrace();
            }
        }
        return result;
    }

    private static void loadRevenueByDate(List<Map<String, Object>> result, int renterID, int days, String dateExpr)
            throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT CAST(").append(dateExpr).append(
                " AS DATE) as RevenueDate, SUM(ro.TotalPrice * ?) as DailyRevenue "
        ).append("FROM RentalOrder ro ")
         .append("JOIN Clothing c ON ro.ClothingID = c.ClothingID ")
         .append("WHERE c.RenterID = ? AND ro.Status = 'COMPLETED' ");

        if (days > 0) {
            sql.append("AND ").append(dateExpr).append(" >= DATEADD(DAY, -").append(days).append(", GETDATE()) ");
        }

        sql.append("GROUP BY CAST(").append(dateExpr).append(" AS DATE) ORDER BY RevenueDate ASC");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setDouble(1, 1.0 - SYSTEM_FEE_RATE);
            ps.setInt(2, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getDate("RevenueDate").toString());
                    row.put("revenue", rs.getDouble("DailyRevenue"));
                    result.add(row);
                }
            }
        }
    }
    
    // ===================================================================
    // ADMIN STATISTICS METHODS
    // ===================================================================

    /**
     * Get all ratings with order and user details for admin
     */
    public static List<Map<String, Object>> getAllRatingsWithDetails() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT r.RatingID, r.Rating, r.Comment, r.CreatedAt, " +
                     "ro.RentalOrderID, c.ClothingName, " +
                     "rater.FullName AS RaterName, rater.UserRole AS RaterRole, " +
                     "CASE WHEN r.RatingFromUserID = c.RenterID THEN renter.FullName ELSE manager.FullName END AS RatedName, " +
                     "CASE WHEN r.RatingFromUserID = c.RenterID THEN 'User' ELSE 'Manager' END AS RatedRole " +
                     "FROM Rating r " +
                     "JOIN RentalOrder ro ON r.RentalOrderID = ro.RentalOrderID " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "JOIN Accounts manager ON c.RenterID = manager.AccountID " +
                     "JOIN Accounts renter ON ro.RenterUserID = renter.AccountID " +
                     "JOIN Accounts rater ON r.RatingFromUserID = rater.AccountID " +
                     "ORDER BY r.CreatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("ratingID", rs.getInt("RatingID"));
                row.put("rating", rs.getInt("Rating"));
                row.put("comment", rs.getString("Comment"));
                row.put("createdAt", rs.getTimestamp("CreatedAt"));
                row.put("rentalOrderID", rs.getInt("RentalOrderID"));
                row.put("clothingName", rs.getString("ClothingName"));
                row.put("raterName", rs.getString("RaterName"));
                row.put("raterRole", rs.getString("RaterRole"));
                row.put("ratedName", rs.getString("RatedName"));
                row.put("ratedRole", rs.getString("RatedRole"));
                result.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * Get top rated managers (highest average rating)
     */
    public static List<Map<String, Object>> getTopRatedManagers(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " " +
                     "a.AccountID, a.FullName, a.Email, " +
                     "AVG(CAST(r.Rating AS FLOAT)) as AvgRating, " +
                     "COUNT(r.RatingID) as RatingCount " +
                     "FROM Accounts a " +
                     "JOIN Clothing c ON a.AccountID = c.RenterID " +
                     "JOIN RentalOrder ro ON c.ClothingID = ro.ClothingID " +
                     "JOIN Rating r ON ro.RentalOrderID = r.RentalOrderID " +
                     "WHERE a.UserRole = 'MANAGER' " +
                     "GROUP BY a.AccountID, a.FullName, a.Email " +
                     "HAVING COUNT(r.RatingID) >= 1 " +
                     "ORDER BY AvgRating DESC, RatingCount DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("accountID", rs.getInt("AccountID"));
                    row.put("accountName", rs.getString("FullName"));
                    row.put("email", rs.getString("Email"));
                    row.put("avgRating", rs.getDouble("AvgRating"));
                    row.put("ratingCount", rs.getInt("RatingCount"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * Get most rented products
     */
    public static List<Map<String, Object>> getMostRentedProducts(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " " +
                     "c.ClothingID, c.ClothingName, c.Category, c.HourlyPrice, " +
                     "a.FullName as ManagerName, " +
                     "COUNT(ro.RentalOrderID) as RentalCount, " +
                 "SUM(ro.TotalPrice) as TotalRevenue " +
                 "FROM Clothing c " +
                 "JOIN Accounts a ON c.RenterID = a.AccountID " +
                 "LEFT JOIN RentalOrder ro ON c.ClothingID = ro.ClothingID " +
                 "WHERE ro.Status IN ('PAYMENT_VERIFIED', 'RENTED', 'RETURNED') " +
                     "GROUP BY c.ClothingID, c.ClothingName, c.Category, c.HourlyPrice, a.FullName " +
                     "ORDER BY RentalCount DESC, TotalRevenue DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("clothingID", rs.getInt("ClothingID"));
                    row.put("clothingName", rs.getString("ClothingName"));
                    row.put("category", rs.getString("Category"));
                    row.put("hourlyPrice", rs.getDouble("HourlyPrice"));
                    row.put("managerName", rs.getString("ManagerName"));
                    row.put("rentalCount", rs.getInt("RentalCount"));
                    row.put("totalRevenue", rs.getDouble("TotalRevenue"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * Get all orders with optional status filter
     */
    public static List<Map<String, Object>> getAllOrdersWithDetails(String statusFilter) {
        List<Map<String, Object>> result = new ArrayList<>();
        
        System.out.println("[DashboardService] getAllOrdersWithDetails - Status filter: " + statusFilter);
        
        // Use DISTINCT to avoid duplicate rows from LEFT JOIN Payment
        String sql = "SELECT DISTINCT " +
                 "ro.RentalOrderID, ro.Status, ro.TotalPrice, ro.AdjustedDepositAmount, ro.CreatedAt, " +
                     "c.ClothingName, c.Category, " +
                     "manager.FullName as ManagerName, " +
                     "renter.FullName as RenterName, " +
                     "(SELECT TOP 1 PaymentStatus FROM Payment WHERE RentalOrderID = ro.RentalOrderID ORDER BY PaymentID DESC) as PaymentStatus, " +
                     "(SELECT TOP 1 PaymentProofImage FROM Payment WHERE RentalOrderID = ro.RentalOrderID ORDER BY PaymentID DESC) as PaymentProofImage " +
                     "FROM RentalOrder ro " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "JOIN Accounts manager ON c.RenterID = manager.AccountID " +
                     "JOIN Accounts renter ON ro.RenterUserID = renter.AccountID ";
        
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("ALL")) {
            // Use normalized comparison to avoid mismatches due to casing/whitespace in DB
            sql += "WHERE UPPER(LTRIM(RTRIM(ro.Status))) = ? ";
        }
        
        sql += "ORDER BY ro.CreatedAt DESC";
        
        System.out.println("[DashboardService] SQL Query: " + sql);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("ALL")) {
                String normalized = statusFilter.trim().toUpperCase();
                ps.setString(1, normalized);
                System.out.println("[DashboardService] Setting status filter parameter (normalized): " + normalized);
            }
            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("rentalOrderID", rs.getInt("RentalOrderID"));
                    row.put("status", rs.getString("Status"));
                    row.put("totalPrice", rs.getDouble("TotalPrice"));
                    row.put("createdAt", rs.getTimestamp("CreatedAt"));
                    row.put("adjustedDepositAmount", rs.getDouble("AdjustedDepositAmount"));
                    row.put("clothingName", rs.getString("ClothingName"));
                    row.put("category", rs.getString("Category"));
                    row.put("managerName", rs.getString("ManagerName"));
                    row.put("renterName", rs.getString("RenterName"));
                    row.put("paymentStatus", rs.getString("PaymentStatus"));
                    row.put("paymentProofImage", rs.getString("PaymentProofImage"));
                    result.add(row);
                    count++;
                }
                System.out.println("[DashboardService] Total orders found: " + count);
            }
        } catch (SQLException e) {
            System.err.println("[DashboardService] SQL Error: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * Get orders that need verification (status = VERIFYING)
     */
    public static List<Map<String, Object>> getOrdersNeedingVerification() {
        return getAllOrdersWithDetails("PAYMENT_SUBMITTED");
    }
}
