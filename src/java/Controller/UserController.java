package Controller;

import Model.Account;
import Service.UserService;
import java.util.List;

public class UserController {
    
    /**
     * Lấy tất cả người dùng (chỉ Admin)
     */
    public static List<Account> getAllUsers() {
        return UserService.getAllUsers();
    }

    /**
     * Lấy người dùng theo ID
     */
    public static Account getUserByID(int accountID) {
        return UserService.getUserByID(accountID);
    }

    /**
     * Cập nhật thông tin người dùng
     */
    public static boolean updateUser(Account account) {
        if (account == null || account.getAccountID() <= 0) {
            System.err.println("Thông tin người dùng không hợp lệ!");
            return false;
        }
        
        return UserService.updateUser(account);
    }

    /**
     * Khóa/Mở khóa tài khoản
     */
    public static boolean toggleUserStatus(int accountID, boolean status) {
        if (accountID <= 0) {
            System.err.println("ID người dùng không hợp lệ!");
            return false;
        }
        
        return UserService.toggleUserStatus(accountID, status);
    }

    /**
     * Lấy danh sách người dùng theo role
     */
    public static List<Account> getUsersByRole(String role) {
        if (role == null || role.trim().isEmpty()) {
            System.err.println("Role không hợp lệ!");
            return null;
        }
        
        return UserService.getUsersByRole(role);
    }

    /**
     * Xóa tài khoản
     */
    public static boolean deleteUser(int accountID) {
        if (accountID <= 0) {
            System.err.println("ID người dùng không hợp lệ!");
            return false;
        }
        
        return UserService.deleteUser(accountID);
    }

    /**
     * Đổi mật khẩu
     */
    public static boolean changePassword(int accountID, String oldPassword, String newPassword) {
        if (accountID <= 0 || oldPassword == null || oldPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty()) {
            System.err.println("Thông tin không hợp lệ!");
            return false;
        }
        
        if (oldPassword.equals(newPassword)) {
            System.err.println("Mật khẩu mới không được giống mật khẩu cũ!");
            return false;
        }
        
        return UserService.changePassword(accountID, oldPassword, newPassword);
    }
}
