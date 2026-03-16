package Controller;

import Model.Account;
import Service.AuthService;

public class AuthController {
    
    /**
     * Xử lý đăng nhập
     */
    public static Account handleLogin(String username, String password) {
        // Kiểm tra input
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            System.err.println("Tên đăng nhập và mật khẩu không được để trống!");
            return null;
        }
        
        // Gọi service đăng nhập
        Account account = AuthService.login(username, password);
        
        if (account != null) {
            System.out.println("Đăng nhập thành công! Role: " + account.getUserRole());
        } else {
            System.err.println("Tên đăng nhập hoặc mật khẩu không chính xác!");
        }
        
        return account;
    }

    /**
     * Xử lý đăng ký
     */
    public static boolean handleRegister(String username, String password, 
                                        String email, String fullName, String userRole) {
        // Kiểm tra input
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty()) {
            System.err.println("Vui lòng điền đầy đủ thông tin!");
            return false;
        }

        // Kiểm tra tên đăng nhập đã tồn tại
        if (AuthService.isUsernameExists(username)) {
            System.err.println("Tên đăng nhập đã tồn tại!");
            return false;
        }

        // Kiểm tra email đã tồn tại
        if (AuthService.isEmailExists(email)) {
            System.err.println("Email đã tồn tại!");
            return false;
        }

        // Tạo account mới
        // Hash mật khẩu cho các role không phải Admin
        String storedPassword = password;
        if (userRole != null && !userRole.trim().equals("Admin")) {
            storedPassword = util.PasswordUtil.hashPassword(password);
        }
        Account account = new Account(username, storedPassword, email, userRole, fullName);
        
        // Gọi service đăng ký
        if (AuthService.register(account)) {
            System.out.println("Đăng ký thành công!");
            return true;
        } else {
            System.err.println("Đăng ký thất bại!");
            return false;
        }
    }

    /**
     * Kiểm tra xem username đã tồn tại
     */
    public static boolean checkUsernameExists(String username) {
        return AuthService.isUsernameExists(username);
    }

    /**
     * Kiểm tra xem email đã tồn tại
     */
    public static boolean checkEmailExists(String email) {
        return AuthService.isEmailExists(email);
    }
}
