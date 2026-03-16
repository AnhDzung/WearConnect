package com.wearconnect.boot.controller;

import Controller.AuthController;
import Model.Account;
import Service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class AuthPageController {

    @GetMapping("/login")
    public void loginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
    }

    @PostMapping("/login")
    public void loginPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        Account account = AuthController.handleLogin(username, password);

        if (account != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("account", account);
            session.setAttribute("accountID", account.getAccountID());
            session.setAttribute("userRole", account.getUserRole());
            session.setMaxInactiveInterval(30 * 60);

            String role = account.getUserRole();
            if ("User".equals(role) || "Manager".equals(role)) {
                checkProfileCompletionAndNotify(account);
            }

            if (role != null) {
                role = role.trim();
            }
            if ("Admin".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else if ("Manager".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/manager");
            } else if ("User".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
        }
    }

    @GetMapping("/register")
    public void registerPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
    }

    @PostMapping("/register")
    public void registerPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String userRole = request.getParameter("userRole");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (!email.contains("@")) {
            request.setAttribute("error", "Email không hợp lệ!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (username.length() < 3) {
            request.setAttribute("error", "Tên đăng nhập phải ít nhất 3 ký tự!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải ít nhất 6 ký tự!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (AuthController.checkUsernameExists(username)) {
            request.setAttribute("error", "Tên đăng nhập đã tồn tại!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (AuthController.checkEmailExists(email)) {
            request.setAttribute("error", "Email đã tồn tại!");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
            return;
        }
        if (AuthController.handleRegister(username, password, email, fullName, userRole)) {
            request.setAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
        } else {
            request.setAttribute("error", "Đăng ký thất bại!");
        }
        request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
    }

    @GetMapping("/logout")
    public void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void checkProfileCompletionAndNotify(Account account) {
        try {
            boolean isIncomplete = false;
            StringBuilder missingFields = new StringBuilder();
            if (account.getPhoneNumber() == null || account.getPhoneNumber().trim().isEmpty()) {
                isIncomplete = true;
                missingFields.append("Số điện thoại, ");
            }
            if (account.getAddress() == null || account.getAddress().trim().isEmpty()) {
                isIncomplete = true;
                missingFields.append("Địa chỉ, ");
            }
            try {
                if (account.getBankAccountNumber() == null || account.getBankAccountNumber().trim().isEmpty()) {
                    isIncomplete = true;
                    missingFields.append("Số tài khoản ngân hàng, ");
                }
            } catch (Exception e) {
                isIncomplete = true;
                missingFields.append("Số tài khoản ngân hàng, ");
            }
            try {
                if (account.getBankName() == null || account.getBankName().trim().isEmpty()) {
                    isIncomplete = true;
                    missingFields.append("Tên ngân hàng, ");
                }
            } catch (Exception e) {
                isIncomplete = true;
                missingFields.append("Tên ngân hàng, ");
            }
            if (isIncomplete && missingFields.length() > 0) {
                String fields = missingFields.substring(0, missingFields.length() - 2);
                String role = account.getUserRole() == null ? "" : account.getUserRole().trim();
                String chatbotGuidance = "Manager".equals(role)
                        ? "Bên cạnh đó nếu bạn muốn tìm hiểu về quy trình đăng tải quần áo lên website thì có thể vào phần chatbot và hỏi về quy trình đăng tải quần áo."
                        : "Bên cạnh đó nếu bạn muốn tìm hiểu về quy trình thuê hàng thì có thể vào phần chatbot và hỏi về quy trình đặt thuê.";
                String message = "Cảm ơn bạn đã tin tưởng và sử dụng WearConnect. Hãy cập nhật đầy đủ thông tin của bạn trong profile để trải nghiệm tốt hơn!"
                        + "\n\nThông tin chưa đầy đủ: " + fields + "\n\n" + chatbotGuidance;
                NotificationService.createNotificationOnceByTitle(account.getAccountID(), "Cập nhật thông tin Profile", message);
            }
        } catch (Exception e) {
            System.err.println("Error checking profile completion: " + e.getMessage());
        }
    }
}
