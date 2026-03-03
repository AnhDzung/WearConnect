package servlet;

import Controller.AuthController;
import Model.Account;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        Account account = AuthController.handleLogin(username, password);
        
        if (account != null) {
            // Lưu thông tin vào session
            HttpSession session = request.getSession(true);
            session.setAttribute("account", account);
            session.setAttribute("accountID", account.getAccountID());
            session.setAttribute("userRole", account.getUserRole());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            
            // Check for incomplete profile and create notification
            String role = account.getUserRole();
            if ("User".equals(role) || "Manager".equals(role)) {
                checkProfileCompletionAndNotify(account);
            }
            
            // Debug log
            System.out.println("=== Login Debug ===");
            System.out.println("Username: " + account.getUsername());
            System.out.println("UserRole: '" + account.getUserRole() + "'");
            System.out.println("UserRole is null: " + (account.getUserRole() == null));
            System.out.println("==================");
            
            // Redirect dựa trên role
            if (role != null) {
                role = role.trim(); // Xóa khoảng trắng
            }
            if ("Admin".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else if ("Manager".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/manager");
            } else if ("User".equals(role)) {
                // User vào thẳng cửa hàng (home)
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                // Nếu role không khớp, redirect về login
                System.out.println("Role không khớp: " + role);
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return;
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
        }
    }
    
    /**
     * Check if user/manager profile is incomplete and create notification
     */
    private void checkProfileCompletionAndNotify(Account account) {
        try {
            boolean isIncomplete = false;
            StringBuilder missingFields = new StringBuilder();
            
            // Check phone number
            if (account.getPhoneNumber() == null || account.getPhoneNumber().trim().isEmpty()) {
                isIncomplete = true;
                missingFields.append("Số điện thoại, ");
            }
            
            // Check address
            if (account.getAddress() == null || account.getAddress().trim().isEmpty()) {
                isIncomplete = true;
                missingFields.append("Địa chỉ, ");
            }
            
            // Check bank account number
            try {
                if (account.getBankAccountNumber() == null || account.getBankAccountNumber().trim().isEmpty()) {
                    isIncomplete = true;
                    missingFields.append("Số tài khoản ngân hàng, ");
                }
            } catch (Exception e) {
                isIncomplete = true;
                missingFields.append("Số tài khoản ngân hàng, ");
            }
            
            // Check bank name
            try {
                if (account.getBankName() == null || account.getBankName().trim().isEmpty()) {
                    isIncomplete = true;
                    missingFields.append("Tên ngân hàng, ");
                }
            } catch (Exception e) {
                isIncomplete = true;
                missingFields.append("Tên ngân hàng, ");
            }
            
            // If profile is incomplete, create notification
            if (isIncomplete && missingFields.length() > 0) {
                String fields = missingFields.substring(0, missingFields.length() - 2); // Remove last ", "
                String role = account.getUserRole() == null ? "" : account.getUserRole().trim();

                String chatbotGuidance;
                if ("Manager".equals(role)) {
                    chatbotGuidance = "Bên cạnh đó nếu bạn muốn tìm hiểu về quy trình đăng tải quần áo lên website thì có thể vào phần chatbot và hỏi về quy trình đăng tải quần áo.";
                } else {
                    chatbotGuidance = "Bên cạnh đó nếu bạn muốn tìm hiểu về quy trình thuê hàng thì có thể vào phần chatbot và hỏi về quy trình đặt thuê.";
                }

                String message = "Cảm ơn bạn đã tin tưởng và sử dụng WearConnect. Hãy cập nhật đầy đủ thông tin của bạn trong profile để trải nghiệm tốt hơn!"
                        + "\n\nThông tin chưa đầy đủ: " + fields
                        + "\n\n" + chatbotGuidance;

                Service.NotificationService.createNotificationOnceByTitle(
                    account.getAccountID(),
                    "Cập nhật thông tin Profile",
                    message
                );
            }
        } catch (Exception e) {
            System.err.println("Error checking profile completion: " + e.getMessage());
        }
    }
}
