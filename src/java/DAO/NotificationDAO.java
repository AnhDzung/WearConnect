package DAO;

import Model.Notification;
import config.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public static int addNotification(Notification n) {
        String sql = "INSERT INTO Notifications(UserID, Title, Message, OrderID, IsRead, CreatedAt) VALUES (?, ?, ?, ?, 0, GETDATE())";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, n.getUserID());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getMessage());
            // OrderID may be null
            if (n.getOrderID() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, n.getOrderID());
            }
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static List<Notification> getUnreadNotificationsByUser(int userID) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT NotificationID, UserID, Title, Message, OrderID, IsRead, CreatedAt FROM Notifications WHERE UserID = ? AND IsRead = 0 ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationID(rs.getInt("NotificationID"));
                    n.setUserID(rs.getInt("UserID"));
                    n.setTitle(rs.getString("Title"));
                    n.setMessage(rs.getString("Message"));
                    int oid = rs.getInt("OrderID");
                    if (!rs.wasNull()) n.setOrderID(oid);
                    n.setRead(rs.getBoolean("IsRead"));
                    n.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Notification> getAllNotificationsByUser(int userID) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT NotificationID, UserID, Title, Message, OrderID, IsRead, CreatedAt FROM Notifications WHERE UserID = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationID(rs.getInt("NotificationID"));
                    n.setUserID(rs.getInt("UserID"));
                    n.setTitle(rs.getString("Title"));
                    n.setMessage(rs.getString("Message"));
                    int oid = rs.getInt("OrderID");
                    if (!rs.wasNull()) n.setOrderID(oid);
                    n.setRead(rs.getBoolean("IsRead"));
                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) n.setCreatedAt(ts.toLocalDateTime());
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean markAsRead(int notificationID) {
        String sql = "UPDATE Notifications SET IsRead = 1 WHERE NotificationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Mark all unread notifications as read for a specific user
     * @param userID The user ID
     * @return true if at least one notification was marked as read
     */
    public static boolean markAllAsReadForUser(int userID) {
        String sql = "UPDATE Notifications SET IsRead = 1 WHERE UserID = ? AND IsRead = 0";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            int updated = ps.executeUpdate();
            System.out.println("[NotificationDAO] Marked " + updated + " notifications as read for user " + userID);
            return updated > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error marking all notifications as read: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
