package DAO;

import config.DatabaseConnection;
import Model.Voucher;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO {

    public static boolean addVoucher(Voucher voucher) {
        String sql = "INSERT INTO Voucher (VoucherCode, DiscountType, DiscountValue, MinOrderValue, MaxDiscountAmount, StartDate, EndDate, IsActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucher.getVoucherCode());
            ps.setString(2, voucher.getDiscountType());
            ps.setDouble(3, voucher.getDiscountValue());
            ps.setDouble(4, voucher.getMinOrderValue());
            if (voucher.getMaxDiscountAmount() != null) {
                ps.setDouble(5, voucher.getMaxDiscountAmount());
            } else {
                ps.setNull(5, Types.DOUBLE);
            }
            if (voucher.getStartDate() != null) {
                ps.setTimestamp(6, Timestamp.valueOf(voucher.getStartDate()));
            } else {
                ps.setNull(6, Types.TIMESTAMP);
            }
            if (voucher.getEndDate() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(voucher.getEndDate()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            ps.setBoolean(8, voucher.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static List<Voucher> getAllVouchers() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM Voucher ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToVoucher(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static Voucher getVoucherByCode(String code) {
        if (code == null) return null;
        String sql = "SELECT * FROM Voucher WHERE VoucherCode = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static boolean toggleVoucherStatus(int voucherId, boolean isActive) {
        String sql = "UPDATE Voucher SET IsActive = ? WHERE VoucherID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, voucherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean deleteVoucher(int voucherId) {
        String sql = "DELETE FROM Voucher WHERE VoucherID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static Voucher mapRowToVoucher(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherID(rs.getInt("VoucherID"));
        v.setVoucherCode(rs.getString("VoucherCode"));
        v.setDiscountType(rs.getString("DiscountType"));
        v.setDiscountValue(rs.getDouble("DiscountValue"));
        v.setMinOrderValue(rs.getDouble("MinOrderValue"));
        double maxDisc = rs.getDouble("MaxDiscountAmount");
        if (!rs.wasNull()) {
            v.setMaxDiscountAmount(maxDisc);
        }
        Timestamp startTs = rs.getTimestamp("StartDate");
        if (startTs != null) {
            v.setStartDate(startTs.toLocalDateTime());
        }
        Timestamp endTs = rs.getTimestamp("EndDate");
        if (endTs != null) {
            v.setEndDate(endTs.toLocalDateTime());
        }
        v.setActive(rs.getBoolean("IsActive"));
        Timestamp createdTs = rs.getTimestamp("CreatedAt");
        if (createdTs != null) {
            v.setCreatedAt(createdTs.toLocalDateTime());
        }
        return v;
    }
}
