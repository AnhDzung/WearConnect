package com.wearconnect.boot.controller;

import Service.AuthService;
import Service.EmailService;
import Service.UserService;
import util.PasswordUtil;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import java.util.Random;

@Controller
@RequestMapping("/forgot-password")
public class ForgotPasswordWebController {
    
    @GetMapping
    public String doGet(@RequestParam(value = "action", required = false) String action) {
        if ("otp".equals(action)) {
            return "forward:/WEB-INF/jsp/user/forgot-password-otp.jsp";
        } else if ("reset".equals(action)) {
            return "forward:/WEB-INF/jsp/user/forgot-password-reset.jsp";
        } else {
            return "forward:/WEB-INF/jsp/user/forgot-password.jsp";
        }
    }

    @PostMapping
    public String doPost(@RequestParam(value = "action", required = false) String action, HttpServletRequest request, HttpSession session, Model model) {

        if ("sendOTP".equals(action)) {
            String email = request.getParameter("email");
            if (AuthService.isEmailExists(email)) {
                String otp = String.format("%06d", new Random().nextInt(999999));
                if (EmailService.sendOTP(email, otp)) {
                    session.setAttribute("resetEmail", email);
                    session.setAttribute("resetOTP", otp);
                    session.setAttribute("otpExpireTime", System.currentTimeMillis() + 5 * 60 * 1000); // Lưu 5 phút
                    session.setAttribute("otpAttempts", 0); // Khởi tạo đếm số lần nhập sai
                    return "redirect:/forgot-password?action=otp";
                } else {
                    model.addAttribute("error", "Lỗi gửi email. Vui lòng kiểm tra lại cấu hình App Password.");
                    return "forward:/WEB-INF/jsp/user/forgot-password.jsp";
                }
            } else {
                model.addAttribute("error", "Email không tồn tại trong hệ thống.");
                return "forward:/WEB-INF/jsp/user/forgot-password.jsp";
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
                    return "redirect:/forgot-password?action=reset";
                } else {
                    attempts++;
                    session.setAttribute("otpAttempts", attempts);
                    if (attempts >= 3) {
                        session.removeAttribute("resetOTP");
                        session.removeAttribute("otpExpireTime");
                        model.addAttribute("error", "Bạn đã nhập sai mã OTP quá 3 lần. Vui lòng yêu cầu gửi lại mã mới.");
                        return "forward:/WEB-INF/jsp/user/forgot-password.jsp";
                    } else {
                        model.addAttribute("error", "Mã OTP không chính xác. Bạn còn " + (3 - attempts) + " lần thử.");
                        return "forward:/WEB-INF/jsp/user/forgot-password-otp.jsp";
                    }
                }
            } else {
                model.addAttribute("error", "Mã OTP đã hết hạn hoặc không hợp lệ. Vui lòng gửi lại.");
                return "forward:/WEB-INF/jsp/user/forgot-password-otp.jsp";
            }
            
        } else if ("resetPassword".equals(action)) {
            Boolean verified = (Boolean) session.getAttribute("otpVerified");
            String email = (String) session.getAttribute("resetEmail");

            if (Boolean.TRUE.equals(verified) && email != null) {
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (newPassword != null && newPassword.equals(confirmPassword)) {
                    // Mã hóa (Hash) mật khẩu mới trước khi lưu vào DB
                    String hashedPassword = PasswordUtil.hashPassword(newPassword);
                    if (UserService.resetPassword(email, hashedPassword)) {
                        session.invalidate(); // Xóa các lưu trữ tạm
                        return "redirect:/login?msg=ResetSuccess";
                    } else {
                        model.addAttribute("error", "Lỗi cập nhật mật khẩu.");
                        return "forward:/WEB-INF/jsp/user/forgot-password-reset.jsp";
                    }
                } else {
                    model.addAttribute("error", "Mật khẩu xác nhận không khớp.");
                    return "forward:/WEB-INF/jsp/user/forgot-password-reset.jsp";
                }
            } else {
                return "redirect:/forgot-password";
            }
        }
        return "redirect:/forgot-password";
    }
}