package servlet;

import Model.Account;
import DAO.FavoritesDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

public class UserServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            
            // Kiểm tra session
            if (session == null || session.getAttribute("account") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            // Kiểm tra role - chỉ User
            String userRole = (String) session.getAttribute("userRole");
            if (userRole != null) {
                userRole = userRole.trim();
            }
            if (!("User".equals(userRole))) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            Account user = (Account) session.getAttribute("account");
            int userID = (int) session.getAttribute("accountID");
            String action = request.getParameter("action");
            
            request.setAttribute("user", user);
            
            // Xử lý các API request cho favorites
            if ("addFavorite".equals(action)) {
                handleAddFavorite(request, response, userID);
            } else if ("removeFavorite".equals(action)) {
                handleRemoveFavorite(request, response, userID);
            } else if ("checkFavorite".equals(action)) {
                handleCheckFavorite(request, response, userID);
            } else if ("getFavoritesJSON".equals(action)) {
                handleGetFavoritesJSON(request, response, userID);
            } else if ("profile".equals(action)) {
                // Trang hồ sơ cá nhân
                request.getRequestDispatcher("/WEB-INF/jsp/user/profile.jsp").forward(request, response);
            } else if ("updateProfile".equals(action)) {
                handleUpdateProfile(request, response, user);
            } else if ("changePassword".equals(action)) {
                handleChangePassword(request, response, user, userID);
            } else if ("rentalHistory".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/user/rental-history.jsp").forward(request, response);
            } else if ("notifications".equals(action)) {
                // Show user notifications (both read and unread). Do NOT auto-mark as read here.
                try {
                    int uid = (int) session.getAttribute("accountID");
                    java.util.List<Model.Notification> notes = Controller.NotificationController.getAllNotifications(uid);
                    request.setAttribute("notifications", notes);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                request.getRequestDispatcher("/WEB-INF/jsp/user/notifications.jsp").forward(request, response);
            } else if ("favorites".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/user/favorites.jsp").forward(request, response);
            } else {
                // Không dùng dashboard nữa, chuyển thẳng sang đơn hàng của tôi
                response.sendRedirect(request.getContextPath() + "/rental?action=myOrders");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Thêm sản phẩm vào yêu thích
     */
    private void handleAddFavorite(HttpServletRequest request, HttpServletResponse response, int userID) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String clothingIDStr = request.getParameter("clothingID");
            int clothingID = Integer.parseInt(clothingIDStr);
            
            boolean success = FavoritesDAO.addFavorite(userID, clothingID);
            String message = success ? "Đã thêm vào yêu thích" : "Lỗi thêm vào yêu thích";
            
            String json = "{\"success\":" + success + ",\"message\":\"" + message + "\"}";
            out.print(json);
        } catch (Exception e) {
            String json = "{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}";
            out.print(json);
        }
        out.flush();
    }
    
    /**
     * Xóa sản phẩm khỏi yêu thích
     */
    private void handleRemoveFavorite(HttpServletRequest request, HttpServletResponse response, int userID) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String clothingIDStr = request.getParameter("clothingID");
            int clothingID = Integer.parseInt(clothingIDStr);
            
            boolean success = FavoritesDAO.removeFavorite(userID, clothingID);
            String message = success ? "Đã xóa khỏi yêu thích" : "Lỗi xóa khỏi yêu thích";
            
            String json = "{\"success\":" + success + ",\"message\":\"" + message + "\"}";
            out.print(json);
        } catch (Exception e) {
            String json = "{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}";
            out.print(json);
        }
        out.flush();
    }
    
    /**
     * Kiểm tra xem sản phẩm có được yêu thích không
     */
    private void handleCheckFavorite(HttpServletRequest request, HttpServletResponse response, int userID) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String clothingIDStr = request.getParameter("clothingID");
            int clothingID = Integer.parseInt(clothingIDStr);
            
            boolean isFavorited = FavoritesDAO.isFavorited(userID, clothingID);
            String json = "{\"isFavorited\":" + isFavorited + "}";
            out.print(json);
        } catch (Exception e) {
            String json = "{\"isFavorited\":false,\"error\":\"Lỗi: " + e.getMessage() + "\"}";
            out.print(json);
        }
        out.flush();
    }
    
    /**
     * Lấy danh sách tất cả sản phẩm yêu thích của người dùng
     */
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
            
            String json = "{\"favorites\":" + jsonArray.toString() + "}";
            out.print(json);
        } catch (Exception e) {
            String json = "{\"favorites\":[],\"error\":\"Lỗi: " + e.getMessage() + "\"}";
            out.print(json);
        }
        out.flush();
    }

    /**
     * Cập nhật thông tin hồ sơ
     */
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Account user) 
            throws ServletException, IOException {
        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");
            
            // Validate
            if (fullName == null || fullName.trim().isEmpty() || 
                email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&error=invalid");
                return;
            }
            
            // Update user object
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhoneNumber(phoneNumber);
            user.setAddress(address);
            
            // Gọi UserService để cập nhật
            if (Service.UserService.updateProfile(user)) {
                // Update session
                HttpSession session = request.getSession();
                session.setAttribute("account", user);
                response.sendRedirect(request.getContextPath() + "/user?action=profile&success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&error=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user?action=profile&error=exception");
        }
    }

    /**
     * Đổi mật khẩu
     */
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, Account user, int accountID)
            throws ServletException, IOException {
        try {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Validate
            if (oldPassword == null || oldPassword.isEmpty() ||
                newPassword == null || newPassword.isEmpty() ||
                confirmPassword == null || confirmPassword.isEmpty()) {
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
            
            // Xác nhận mật khẩu cũ
            if (!DAO.AccountDAO.verifyPassword(accountID, oldPassword)) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=wrongold");
                return;
            }
            
            // Cập nhật mật khẩu mới (non-admin, nên sẽ hash)
            if (DAO.AccountDAO.changePassword(accountID, oldPassword, newPassword)) {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdSuccess=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user?action=profile&pwdError=exception");
        }
    }}