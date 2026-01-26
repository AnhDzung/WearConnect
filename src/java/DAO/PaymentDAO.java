package DAO;

import config.DatabaseConnection;
import Model.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {
    
    public static int addPayment(Payment payment) {
        String sql = "INSERT INTO Payment (RentalOrderID, Amount, PaymentMethod, PaymentStatus) " +
                     "VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, payment.getRentalOrderID());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getPaymentMethod());
            ps.setString(4, payment.getPaymentStatus());
            
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

    public static Payment getPaymentByID(int paymentID) {
        String sql = "SELECT * FROM Payment WHERE PaymentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToPayment(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Payment getPaymentByRentalOrder(int rentalOrderID) {
        String sql = "SELECT * FROM Payment WHERE RentalOrderID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rentalOrderID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToPayment(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<Payment> getPaymentsByStatus(String status) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT * FROM Payment WHERE PaymentStatus = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToPayment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean updatePaymentStatus(int paymentID, String newStatus) {
        String sql = "UPDATE Payment SET PaymentStatus = ?, PaymentDate = GETDATE() WHERE PaymentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, paymentID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static List<Payment> getAllPayments() {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT * FROM Payment ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToPayment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private static Payment mapRowToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentID(rs.getInt("PaymentID"));
        payment.setRentalOrderID(rs.getInt("RentalOrderID"));
        payment.setAmount(rs.getDouble("Amount"));
        payment.setPaymentMethod(rs.getString("PaymentMethod"));
        payment.setPaymentStatus(rs.getString("PaymentStatus"));
        Timestamp paymentDate = rs.getTimestamp("PaymentDate");
        if (paymentDate != null) payment.setPaymentDate(paymentDate.toLocalDateTime());
        payment.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
        
        // Get payment proof image if exists
        try {
            String proofImage = rs.getString("PaymentProofImage");
            if (proofImage != null) {
                payment.setPaymentProofImage(proofImage);
            }
        } catch (SQLException e) {
            // Column doesn't exist yet - will be added in migration
        }
        
        return payment;
    }
    
    public static boolean updatePaymentProof(int paymentID, String proofImagePath) {
        String sql = "UPDATE Payment SET PaymentProofImage = ? WHERE PaymentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, proofImagePath);
            ps.setInt(2, paymentID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PaymentDAO] Error updating payment proof: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
