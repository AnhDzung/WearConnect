package Service;

import Model.Account;
import DAO.AccountDAO;
import DAO.LoginHistoryDAO;

public class AuthService {
    
    /**
     * Đăng nhập người dùng
     * @param usernameOrEmail Tên đăng nhập hoặc Email
     * @param password Mật khẩu
     * @return Account nếu đăng nhập thành công, null nếu thất bại
     */
    public static Account login(String usernameOrEmail, String password) {
        Account account = AccountDAO.login(usernameOrEmail, password);
        
        if (account != null) {
            // Ghi lại lịch sử đăng nhập
            LoginHistoryDAO.recordLogin(account.getAccountID());
        }
        
        return account;
    }
    /**
     * Đăng ký tài khoản mới
     * @param account Thông tin tài khoản
     * @return true nếu đăng ký thành công, false nếu thất bại
     */
    public static boolean register(Account account) {
        return AccountDAO.create(account);
    }

    /**
     * Kiểm tra xem username đã tồn tại chưa
     * @param username Tên đăng nhập
     * @return true nếu tồn tại, false nếu không
     */
    public static boolean isUsernameExists(String username) {
        return AccountDAO.existsByUsername(username);
    }

    /**
     * Kiểm tra xem email đã tồn tại chưa
     * @param email Email
     * @return true nếu tồn tại, false nếu không
     */
    public static boolean isEmailExists(String email) {
        return AccountDAO.existsByEmail(email);
    }
}
