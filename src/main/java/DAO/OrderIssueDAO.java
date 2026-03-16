package DAO;

import config.DatabaseConnection;
import Model.OrderIssue;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class OrderIssueDAO {
    
    public static int addOrderIssue(OrderIssue issue) {
        String sql = "INSERT INTO OrderIssue (RentalOrderID, RenterUserID, IssueType, Description, Status, ImagePath, ImageData) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, issue.getRentalOrderID());
            ps.setInt(2, issue.getRenterUserID());
            ps.setString(3, issue.getIssueType());
            ps.setString(4, issue.getDescription());
            ps.setString(5, issue.getStatus());
            ps.setString(6, issue.getImagePath());
            ps.setBytes(7, issue.getImageData());
            
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
    
    public static List<OrderIssue> getIssuesByRentalOrder(int rentalOrderID) {
        List<OrderIssue> list = new ArrayList<>();
        String sql = "SELECT * FROM OrderIssue WHERE RentalOrderID = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
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
    
    public static OrderIssue getIssueByID(int issueID) {
        String sql = "SELECT * FROM OrderIssue WHERE IssueID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, issueID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public static OrderIssue getIssueByRentalOrder(int rentalOrderID) {
        String sql = "SELECT TOP 1 * FROM OrderIssue WHERE RentalOrderID = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public static List<OrderIssue> getIssuesByStatus(String status) {
        List<OrderIssue> list = new ArrayList<>();
        String sql = "SELECT * FROM OrderIssue WHERE Status = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
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
    
    public static boolean updateIssueStatus(int issueID, String status, String notes) {
        String sql = "UPDATE OrderIssue SET Status = ?, Notes = ?, ResolvedAt = ? WHERE IssueID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, notes);
            ps.setTimestamp(3, "RESOLVED".equals(status) || "REJECTED".equals(status) ? 
                    Timestamp.valueOf(LocalDateTime.now()) : null);
            ps.setInt(4, issueID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    private static OrderIssue mapRow(ResultSet rs) throws SQLException {
        OrderIssue issue = new OrderIssue();
        issue.setIssueID(rs.getInt("IssueID"));
        issue.setRentalOrderID(rs.getInt("RentalOrderID"));
        issue.setRenterUserID(rs.getInt("RenterUserID"));
        issue.setIssueType(rs.getString("IssueType"));
        issue.setDescription(rs.getString("Description"));
        issue.setStatus(rs.getString("Status"));
        Timestamp createdTs = rs.getTimestamp("CreatedAt");
        if (createdTs != null) issue.setCreatedAt(createdTs.toLocalDateTime());
        Timestamp resolvedTs = rs.getTimestamp("ResolvedAt");
        if (resolvedTs != null) issue.setResolvedAt(resolvedTs.toLocalDateTime());
        issue.setNotes(rs.getString("Notes"));
        try { issue.setImagePath(rs.getString("ImagePath")); } catch (SQLException ignore) {}
        try { issue.setImageData(rs.getBytes("ImageData")); } catch (SQLException ignore) {}
        return issue;
    }
}
