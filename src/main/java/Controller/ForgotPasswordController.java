package Controller;

import Service.AuthService;
import Service.EmailService;
import Service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

@WebServlet("/forgot-password")
public class ForgotPasswordController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("otp".equals(action)) {
            request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password-otp.jsp").forward(request, response);
        } else if ("reset".equals(action)) {
            request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password-reset.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("sendOTP".equals(action)) {
            String email = request.getParameter("email");
            if (AuthService.isEmailExists(email)) {
                String otp = String.format("%06d", new Random().nextInt(999999));
                if (EmailService.sendOTP(email, otp)) {
                    session.setAttribute("resetEmail", email);
                    session.setAttribute("resetOTP", otp);
                    session.setAttribute("otpExpireTime", System.currentTimeMillis() + 5 * 60 * 1000); // Lưu 5 phút
                    session.setAttribute("otpAttempts", 0); // Khởi tạo đếm số lần nhập sai
                    response.sendRedirect(request.getContextPath() + "/forgot-password?action=otp");
                } else {
                    request.setAttribute("error", "Lỗi gửi email. Vui lòng thử lại sau.");
                    request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Email không tồn tại trong hệ thống.");
                request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password.jsp").forward(request, response);
            }
            
        } else if ("verifyOTP".equals(action)) {
            String userOtp = request.getParameter("otp");
            String sessionOtp = (String) session.getAttribute("resetOTP");
            Long expireTime = (Long) session.getAttribute("otpExpireTime");
            Integer attempts = (Integer) session.getAttribute("otpAttempts");

            if (attempts == null) attempts = 0;

            if (sessionOtp != null && expireTime != null && System.currentTimeMillis() < expireTime) {
                if (sessionOtp.equals(userOtp)) {
                    session.setAttribute("otpVerified", true); // Đánh dấu đã qua bước OTP
                    session.removeAttribute("otpAttempts"); // Xóa biến đếm khi nhập đúng
                    response.sendRedirect(request.getContextPath() + "/forgot-password?action=reset");
                } else {
                    attempts++;
                    session.setAttribute("otpAttempts", attempts);
                    if (attempts >= 3) {
                        session.removeAttribute("resetOTP");
                        session.removeAttribute("otpExpireTime");
                        request.setAttribute("error", "Bạn đã nhập sai mã OTP quá 3 lần. Vui lòng yêu cầu gửi lại mã mới.");
                        request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password.jsp").forward(request, response);
                    } else {
                        request.setAttribute("error", "Mã OTP không chính xác. Bạn còn " + (3 - attempts) + " lần thử.");
                        request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password-otp.jsp").forward(request, response);
                    }
                }
            } else {
                request.setAttribute("error", "Mã OTP đã hết hạn hoặc không hợp lệ. Vui lòng gửi lại.");
                request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password-otp.jsp").forward(request, response);
            }
            
        } else if ("resetPassword".equals(action)) {
            Boolean verified = (Boolean) session.getAttribute("otpVerified");
            String email = (String) session.getAttribute("resetEmail");

            if (Boolean.TRUE.equals(verified) && email != null) {
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (newPassword != null && newPassword.equals(confirmPassword)) {
                    if (UserService.resetPassword(email, newPassword)) {
                        session.invalidate(); // Xóa các lưu trữ tạm
                        response.sendRedirect(request.getContextPath() + "/login?msg=ResetSuccess");
                    } else {
                        request.setAttribute("error", "Lỗi cập nhật mật khẩu.");
                        request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password-reset.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
                    request.getRequestDispatcher("/WEB-INF/jsp/user/forgot-password-reset.jsp").forward(request, response);
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/forgot-password");
            }
        }
    }
}