package com.wearconnect.boot.controller;

import Controller.NotificationController;
import DAO.AccountDAO;
import DAO.FavoritesDAO;
import DAO.NotificationDAO;
import Model.Account;
import Model.Notification;
import Service.NotificationService;
import Service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/user")
public class UserPageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleRequest(request, response);
    }

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleRequest(request, response);
    }

    private void handleRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("account") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            String userRole = (String) session.getAttribute("userRole");
            if (userRole != null) userRole = userRole.trim();
            if (!("User".equals(userRole) || "Manager".equals(userRole) || "Admin".equals(userRole))) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Account user = (Account) session.getAttribute("account");
            int userID = (int) session.getAttribute("accountID");
            String action = request.getParameter("action");
            request.setAttribute("user", user);

            if ("addFavorite".equals(action)) {
                handleAddFavorite(request, response, userID);
            } else if ("removeFavorite".equals(action)) {
                handleRemoveFavorite(request, response, userID);
            } else if ("checkFavorite".equals(action)) {
                handleCheckFavorite(request, response, userID);
            } else if ("getFavoritesJSON".equals(action)) {
                handleGetFavoritesJSON(request, response, userID);
            } else if ("profile".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/user/profile.jsp").forward(request, response);
            } else if ("updateProfile".equals(action)) {
                handleUpdateProfile(request, response, user);
            } else if ("changePassword".equals(action)) {
                handleChangePassword(request, response, user, userID);
            } else if ("rentalHistory".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/user/rental-history.jsp").forward(request, response);
            } else if ("notifications".equals(action)) {
                try {
                    List<Notification> notes = NotificationController.getAllNotifications(userID);
                    request.setAttribute("notifications", notes);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                request.getRequestDispatcher("/WEB-INF/jsp/user/notifications.jsp").forward(request, response);
            } else if ("markNotificationRead".equals(action)) {
                handleMarkNotificationRead(request, response, session);
            } else if ("markAllNotificationsRead".equals(action)) {
                handleMarkAllNotificationsRead(request, response, session);
            } else if ("favorites".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/user/favorites.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/rental?action=myOrders");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }

    private void handleMarkNotificationRead(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            if (session == null || session.getAttribute("account") == null) {
                out.print("{\"success\":false,\"error\":\"Not authenticated\"}");
                return;
            }
            String nid = request.getParameter("notificationID");
            if (nid == null) {
                out.print("{\"success\":false,\"error\":\"Missing notificationID\"}");
                return;
            }
            boolean ok = NotificationController.markAsRead(Integer.parseInt(nid));
            out.print("{\"success\":" + ok + "}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            out.flush();
        }
    }

    private void handleMarkAllNotificationsRead(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            if (session == null || session.getAttribute("account") == null) {
                out.print("{\"success\":false,\"error\":\"Not authenticated\"}");
                return;
            }
            Account account = (Account) session.getAttribute("account");
            boolean ok = NotificationDAO.markAllAsReadForUser(account.getAccountID());
            out.print("{\"success\":" + ok + "}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            out.flush();
        }
    }

    private void handleAddFavorite(HttpServletRequest request, HttpServletResponse response, int userID)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            boolean success = FavoritesDAO.addFavorite(userID, clothingID);
            out.print("{\"success\":" + success + ",\"message\":\"" + (success ? "Đã thêm vào yêu thích" : "Lỗi thêm vào yêu thích") + "\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    private void handleRemoveFavorite(HttpServletRequest request, HttpServletResponse response, int userID)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            boolean success = FavoritesDAO.removeFavorite(userID, clothingID);
            out.print("{\"success\":" + success + ",\"message\":\"" + (success ? "Đã xóa khỏi yêu thích" : "Lỗi xóa khỏi yêu thích") + "\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    private void handleCheckFavorite(HttpServletRequest request, HttpServletResponse response, int userID)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            boolean isFavorited = FavoritesDAO.isFavorited(userID, clothingID);
            out.print("{\"isFavorited\":" + isFavorited + "}");
        } catch (Exception e) {
            out.print("{\"isFavorited\":false,\"error\":\"Lỗi: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    private void handleGetFavoritesJSON(HttpServletRequest request, HttpServletResponse response, int userID)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            List<Integer> favorites = FavoritesDAO.getFavoriteClothingIDs(userID);
            StringBuilder jsonArray = new StringBuilder("[");
            for (int i = 0; i < favorites.size(); i++) {
                if (i > 0) jsonArray.append(",");
                jsonArray.append(favorites.get(i));
            }
            jsonArray.append("]");
            out.print("{\"favorites\":" + jsonArray + "}");
        } catch (Exception e) {
            out.print("{\"favorites\":[],\"error\":\"Lỗi: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Account user)
            throws IOException {
        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");
            String bankAccountNumber = request.getParameter("bankAccountNumber");
            String bankName = request.getParameter("bankName");

            if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&error=invalid");
                return;
            }
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhoneNumber(phoneNumber);
            user.setAddress(address);
            user.setBankAccountNumber(bankAccountNumber);
            user.setBankName(bankName);

            if (UserService.updateProfile(user)) {
                request.getSession().setAttribute("account", user);
                checkAndMarkProfileNotificationAsRead(user);
                response.sendRedirect(request.getContextPath() + "/user?action=profile&success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&error=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user?action=profile&error=exception");
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, Account user, int accountID)
            throws IOException {
        try {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (oldPassword == null || oldPassword.isEmpty() || newPassword == null || newPassword.isEmpty()
                    || confirmPassword == null || confirmPassword.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=empty");
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=notmatch");
                return;
            }
            if (newPassword.length() < 6) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=short");
                return;
            }
            if (!AccountDAO.verifyPassword(accountID, oldPassword)) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=wrongold");
                return;
            }
            if (AccountDAO.changePassword(accountID, oldPassword, newPassword)) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdSuccess=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=exception");
        }
    }

    private void checkAndMarkProfileNotificationAsRead(Account user) {
        try {
            boolean isComplete = true;
            if (user.getPhoneNumber() == null || user.getPhoneNumber().trim().isEmpty()) isComplete = false;
            if (user.getAddress() == null || user.getAddress().trim().isEmpty()) isComplete = false;
            try {
                if (user.getBankAccountNumber() == null || user.getBankAccountNumber().trim().isEmpty()) isComplete = false;
            } catch (Exception e) { isComplete = false; }
            try {
                if (user.getBankName() == null || user.getBankName().trim().isEmpty()) isComplete = false;
            } catch (Exception e) { isComplete = false; }

            if (isComplete) {
                List<Notification> unreadNotifs = NotificationService.getUnreadNotifications(user.getAccountID());
                if (unreadNotifs != null) {
                    for (Notification notif : unreadNotifs) {
                        if ("Cập nhật thông tin Profile".equals(notif.getTitle())) {
                            NotificationService.markAsRead(notif.getNotificationID());
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error marking profile notification as read: " + e.getMessage());
        }
    }
}
