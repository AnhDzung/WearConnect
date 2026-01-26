package DAO;

import Model.Account;
import config.DatabaseConnection;
import util.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AccountDAO {
    
    /**
     * Lấy tài khoản theo tên đăng nhập và mật khẩu
     */
    public static Account login(String username, String password) {
        String query = "SELECT * FROM Accounts WHERE Username = ? AND Status = 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, username);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Account account = mapResultSetToAccount(rs);
                String role = account.getUserRole() != null ? account.getUserRole().trim() : "";
                String stored = account.getPassword();

                boolean ok;
                if ("Admin".equals(role)) {
                    ok = stored != null && stored.equals(password);
                } else {
                    ok = PasswordUtil.verifyPassword(password, stored);
                    // Lazy migration: if non-admin stored is plain and matches, upgrade to salted hash
                    if (ok && !PasswordUtil.isSaltedHash(stored)) {
                        String newHashed = PasswordUtil.hashPassword(password);
                        updatePassword(account.getAccountID(), newHashed);
                        account.setPassword(newHashed);
                    }
                }

                return ok ? account : null;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi đăng nhập: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Tạo tài khoản mới
     */
    public static boolean create(Account account) {
        String query = "INSERT INTO Accounts (Username, Password, Email, UserRole, FullName, Status) " +
                      "VALUES (?, ?, ?, ?, ?, 1)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, account.getUsername());
            ps.setString(2, account.getPassword());
            ps.setString(3, account.getEmail());
            ps.setString(4, account.getUserRole());
            ps.setString(5, account.getFullName());
            
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Lỗi tạo tài khoản: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Kiểm tra username tồn tại
     */
    public static boolean existsByUsername(String username) {
        String query = "SELECT COUNT(*) FROM Accounts WHERE Username = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kiểm tra username: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Kiểm tra email tồn tại
     */
    public static boolean existsByEmail(String email) {
        String query = "SELECT COUNT(*) FROM Accounts WHERE Email = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kiểm tra email: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Lấy tất cả tài khoản (không phải Admin)
     */
    public static List<Account> findAll() {
        List<Account> accounts = new ArrayList<>();
        String query = "SELECT * FROM Accounts WHERE UserRole != 'Admin'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                accounts.add(mapResultSetToAccount(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy danh sách tài khoản: " + e.getMessage());
            e.printStackTrace();
        }
        
        return accounts;
    }

    /**
     * Lấy tài khoản theo ID
     */
    public static Account findById(int accountID) {
        String query = "SELECT * FROM Accounts WHERE AccountID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, accountID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAccount(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy tài khoản: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Lấy tài khoản theo role
     */
    public static List<Account> findByRole(String role) {
        List<Account> accounts = new ArrayList<>();
        String query = "SELECT * FROM Accounts WHERE UserRole = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                accounts.add(mapResultSetToAccount(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy tài khoản theo role: " + e.getMessage());
            e.printStackTrace();
        }
        
        return accounts;
    }

    /**
     * Cập nhật tài khoản
     */
    public static boolean update(Account account) {
        String query = "UPDATE Accounts SET FullName = ?, Email = ?, PhoneNumber = ?, " +
                      "Address = ?, UpdatedDate = GETDATE() WHERE AccountID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, account.getFullName());
            ps.setString(2, account.getEmail());
            ps.setString(3, account.getPhoneNumber());
            ps.setString(4, account.getAddress());
            ps.setInt(5, account.getAccountID());
            
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Lỗi cập nhật tài khoản: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Cập nhật trạng thái tài khoản
     */
    public static boolean updateStatus(int accountID, boolean status) {
        String query = "UPDATE Accounts SET Status = ? WHERE AccountID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setBoolean(1, status);
            ps.setInt(2, accountID);
            
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Lỗi cập nhật trạng thái: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Xóa tài khoản
     */
    public static boolean delete(int accountID) {
        String query = "DELETE FROM Accounts WHERE AccountID = ? AND UserRole != 'Admin'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, accountID);
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Lỗi xóa tài khoản: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Xác nhận mật khẩu của một tài khoản
     */
    public static boolean verifyPassword(int accountID, String plainPassword) {
        String query = "SELECT Password, UserRole FROM Accounts WHERE AccountID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, accountID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("Password");
                String role = rs.getString("UserRole");
                boolean isAdmin = role != null && role.trim().equals("Admin");

                // Admin: plain comparison; Non-admin: hash verification
                return isAdmin ? storedPassword.equals(plainPassword)
                               : PasswordUtil.verifyPassword(plainPassword, storedPassword);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi xác nhận mật khẩu: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Đổi mật khẩu
     */
    public static boolean changePassword(int accountID, String oldPassword, String newPassword) {
        String checkQuery = "SELECT Password, UserRole FROM Accounts WHERE AccountID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkQuery)) {
            
            ps.setInt(1, accountID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("Password");
                String role = rs.getString("UserRole");
                boolean isAdmin = role != null && role.trim().equals("Admin");

                boolean ok = isAdmin ? storedPassword.equals(oldPassword)
                                      : PasswordUtil.verifyPassword(oldPassword, storedPassword);

                if (ok) {
                    String newStored = isAdmin ? newPassword : PasswordUtil.hashPassword(newPassword);
                    String updateQuery = "UPDATE Accounts SET Password = ?, UpdatedDate = GETDATE() WHERE AccountID = ?";
                    try (PreparedStatement updatePs = conn.prepareStatement(updateQuery)) {
                        updatePs.setString(1, newStored);
                        updatePs.setInt(2, accountID);
                        int result = updatePs.executeUpdate();
                        return result > 0;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi đổi mật khẩu: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Cập nhật mật khẩu thô trong DB (đã được chuẩn bị/hashed bên ngoài)
     */
    public static boolean updatePassword(int accountID, String newPasswordStored) {
        String updateQuery = "UPDATE Accounts SET Password = ?, UpdatedDate = GETDATE() WHERE AccountID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateQuery)) {
            ps.setString(1, newPasswordStored);
            ps.setInt(2, accountID);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi cập nhật mật khẩu: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Map ResultSet thành Account object
     */
    private static Account mapResultSetToAccount(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountID(rs.getInt("AccountID"));
        account.setUsername(rs.getString("Username"));
        account.setPassword(rs.getString("Password"));
        account.setEmail(rs.getString("Email"));
        account.setUserRole(rs.getString("UserRole"));
        account.setFullName(rs.getString("FullName"));
        account.setPhoneNumber(rs.getString("PhoneNumber"));
        account.setAddress(rs.getString("Address"));
        account.setStatus(rs.getBoolean("Status"));
        return account;
    }
}
