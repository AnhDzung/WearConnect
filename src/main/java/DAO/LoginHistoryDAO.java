package DAO;

import config.DatabaseConnection;
import java.sql.*;

public class LoginHistoryDAO {
    
    /**
     * Ghi lại lịch sử đăng nhập
     */
    public static boolean recordLogin(int accountID) {
        String query = "INSERT INTO LoginHistory (AccountID, LoginTime) VALUES (?, GETDATE())";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, accountID);
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Lỗi ghi lại lịch sử đăng nhập: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Ghi lại lịch sử đăng xuất
     */
    public static boolean recordLogout(int accountID) {
        String query = "UPDATE LoginHistory SET LogoutTime = GETDATE() " +
                      "WHERE AccountID = ? AND LogoutTime IS NULL " +
                      "ORDER BY HistoryID DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, accountID);
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Lỗi ghi lại lịch sử đăng xuất: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
}
