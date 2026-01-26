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
            
            // Debug log
            System.out.println("=== Login Debug ===");
            System.out.println("Username: " + account.getUsername());
            System.out.println("UserRole: '" + account.getUserRole() + "'");
            System.out.println("UserRole is null: " + (account.getUserRole() == null));
            System.out.println("==================");
            
            // Redirect dựa trên role
            String role = account.getUserRole();
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
}
