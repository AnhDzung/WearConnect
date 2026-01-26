package Service;

import Model.Account;
import DAO.AccountDAO;
import java.util.List;

public class UserService {
    
    /**
     * Lấy tất cả người dùng (chỉ Admin)
     */
    public static List<Account> getAllUsers() {
        return AccountDAO.findAll();
    }

    /**
     * Lấy người dùng theo ID
     */
    public static Account getUserByID(int accountID) {
        return AccountDAO.findById(accountID);
    }

    /**
     * Cập nhật thông tin người dùng
     */
    public static boolean updateUser(Account account) {
        return AccountDAO.update(account);
    }

    /**
     * Khóa/Mở khóa tài khoản (chỉ Admin)
     */
    public static boolean toggleUserStatus(int accountID, boolean status) {
        return AccountDAO.updateStatus(accountID, status);
    }

    /**
     * Lấy người dùng theo role
     */
    public static List<Account> getUsersByRole(String role) {
        return AccountDAO.findByRole(role);
    }

    /**
     * Xóa tài khoản (chỉ Admin)
     */
    public static boolean deleteUser(int accountID) {
        return AccountDAO.delete(accountID);
    }

    /**
     * Đổi mật khẩu
     */
    public static boolean changePassword(int accountID, String oldPassword, String newPassword) {
        return AccountDAO.changePassword(accountID, oldPassword, newPassword);
    }

    /**
     * Cập nhật hồ sơ cá nhân (fullName, email, phoneNumber, address)
     */
    public static boolean updateProfile(Account account) {
        return AccountDAO.update(account);
    }
}

