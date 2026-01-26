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
    
    // Lấy doanh thu tổng cộng của manager
    public static double getTotalRevenue(int renterID) {
        String sql = "SELECT SUM(ro.TotalPrice) as TotalRevenue FROM RentalOrder ro " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? AND ro.Status = 'RETURNED'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
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
                     "WHERE c.RenterID = ? AND ro.Status = 'RETURNED'";
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
                     "WHERE c.RenterID = ? AND ro.Status IN ('PENDING', 'CONFIRMED')";
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
                     "WHERE c.RenterID = ? AND ro.Status = 'CONFIRMED'";
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
    
    // Lấy top 3 sản phẩm có doanh thu cao nhất
    public static List<Map<String, Object>> getTopRevenueProducts(int renterID, int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " c.ClothingID, c.ClothingName, c.HourlyPrice, " +
                     "SUM(ro.TotalPrice) as TotalRevenue, COUNT(ro.RentalOrderID) as OrderCount " +
                     "FROM Clothing c " +
                     "LEFT JOIN RentalOrder ro ON c.ClothingID = ro.ClothingID " +
                     "WHERE c.RenterID = ? AND c.IsActive = 1 " +
                     "GROUP BY c.ClothingID, c.ClothingName, c.HourlyPrice " +
                     "ORDER BY TotalRevenue DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
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
    
    // Lấy doanh thu theo ngày (30 ngày gần nhất) cho biểu đồ
    public static List<Map<String, Object>> getRevenueByDate(int renterID, int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT CAST(p.PaymentDate AS DATE) as PaymentDate, " +
                     "SUM(p.Amount) as DailyRevenue " +
                     "FROM Payment p " +
                     "JOIN RentalOrder ro ON p.RentalOrderID = ro.RentalOrderID " +
                     "JOIN Clothing c ON ro.ClothingID = c.ClothingID " +
                     "WHERE c.RenterID = ? AND p.PaymentStatus = 'Completed' " +
                     "AND p.PaymentDate >= DATEADD(DAY, -" + days + ", GETDATE()) " +
                     "GROUP BY CAST(p.PaymentDate AS DATE) " +
                     "ORDER BY PaymentDate ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getDate("PaymentDate").toString());
                    row.put("revenue", rs.getDouble("DailyRevenue"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    // ===================================================================
    // ADMIN STATISTICS METHODS
    // ===================================================================
    
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
                     "WHERE ro.Status IN ('CONFIRMED', 'RENTED', 'RETURNED') " +
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
                     "ro.RentalOrderID, ro.Status, ro.TotalPrice, ro.CreatedAt, " +
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
            sql += "WHERE ro.Status = ? ";
        }
        
        sql += "ORDER BY ro.CreatedAt DESC";
        
        System.out.println("[DashboardService] SQL Query: " + sql);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("ALL")) {
                ps.setString(1, statusFilter);
                System.out.println("[DashboardService] Setting status filter parameter: " + statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("rentalOrderID", rs.getInt("RentalOrderID"));
                    row.put("status", rs.getString("Status"));
                    row.put("totalPrice", rs.getDouble("TotalPrice"));
                    row.put("createdAt", rs.getTimestamp("CreatedAt"));
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
        return getAllOrdersWithDetails("VERIFYING");
    }
}
