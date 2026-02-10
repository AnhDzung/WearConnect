package servlet;

import Model.Account;
import Model.Clothing;
import Model.RentalOrder;
import Model.Rating;
import Model.OrderIssue;
import Controller.ClothingController;
import Controller.RentalOrderController;
import DAO.RatingDAO;
import DAO.OrderIssueDAO;
import Service.DashboardService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.sql.Timestamp;

public class ManagerServlet extends HttpServlet {
    
    private void handleRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            System.out.println("[ManagerServlet] Request URI: " + request.getRequestURI() + " - Action: " + request.getParameter("action"));
            
            HttpSession session = request.getSession(false);
            
            // Kiểm tra session
            if (session == null || session.getAttribute("account") == null) {
                System.out.println("[ManagerServlet] Session null or no account, redirecting to login");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            // Kiểm tra role
            String userRole = (String) session.getAttribute("userRole");
            if (userRole != null) {
                userRole = userRole.trim();
            }
            if (!("Manager".equals(userRole))) {
                System.out.println("[ManagerServlet] User role is not Manager: " + userRole + ", redirecting to login");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            Object accountIDObj = session.getAttribute("accountID");
            if (accountIDObj == null) {
                System.out.println("[ManagerServlet] accountID is null, redirecting to login");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            int managerId;
            if (accountIDObj instanceof Integer) {
                managerId = (Integer) accountIDObj;
            } else {
                managerId = Integer.parseInt(accountIDObj.toString());
            }
            
            Account manager = (Account) session.getAttribute("account");
            String action = request.getParameter("action");
            System.out.println("[ManagerServlet] Processing action: " + action + " for manager ID: " + managerId);

            // Manager saves a rating for the renter
            if ("saveManagerRating".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    int ratingValue = Integer.parseInt(request.getParameter("rating"));
                    String managerNotes = request.getParameter("managerNotes");
                    
                    System.out.println("[ManagerServlet] saveManagerRating - rentalOrderID: " + rentalOrderID + 
                                     ", managerId: " + managerId + ", rating: " + ratingValue + 
                                     ", notes: " + managerNotes);
                    
                    // Save manager's rating for the renter using RatingController
                    int ratingID = Controller.RatingController.submitRating(rentalOrderID, managerId, ratingValue, managerNotes);
                    System.out.println("[ManagerServlet] Manager rating saved with ID: " + ratingID);
                    
                    if (ratingID > 0) {
                        System.out.println("[ManagerServlet] Rating successfully saved to database");
                        response.setStatus(HttpServletResponse.SC_OK);
                    } else {
                        System.out.println("[ManagerServlet] Rating save failed, error code: " + ratingID);
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    }
                } catch (Exception e) {
                    System.err.println("[ManagerServlet] Exception in saveManagerRating: " + e.getMessage());
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                }
                return;
            }

            // Manager updates order status (e.g., mark as RENTED/RETURNED)
            if ("updateStatus".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    String status = request.getParameter("status");

                    // Only allow expected transitions from manager side
                    if ("RENTED".equals(status) || "RETURNED".equals(status) || "COMPLETED".equals(status) || "CANCELLED".equals(status)) {
                        boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, status);
                        System.out.println("[ManagerServlet] Update status to " + status + " for order " + rentalOrderID + " => " + updated);
                    } else {
                        System.out.println("[ManagerServlet] Invalid status update attempt: " + status);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/manager?action=orders&success=true");
                return;
            }
            
            // Manager ships order (set tracking number and status SHIPPING)
            if ("shipOrder".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    String trackingNumber = request.getParameter("trackingNumber");
                    if (trackingNumber != null && !trackingNumber.trim().isEmpty()) {
                        boolean stored = RentalOrderController.setTrackingNumber(rentalOrderID, trackingNumber.trim());
                        boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "SHIPPING");
                        System.out.println("[ManagerServlet] shipOrder stored=" + stored + " updated=" + updated);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/manager?action=orders&success=true");
                return;
            }

            // Manager confirms delivery (set DELIVERED_PENDING_CONFIRMATION)
            if ("confirmDelivery".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    RentalOrderController.updateOrderStatus(rentalOrderID, "DELIVERED_PENDING_CONFIRMATION");
                } catch (Exception e) {
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/manager?action=orders&success=true");
                return;
            }
            
            if ("ratings".equals(action)) {
                List<Rating> ratings = RatingDAO.getRatingsByRenter(managerId);
                double avgRating = RatingDAO.getAverageRatingForRenter(managerId);
                
                request.setAttribute("ratings", ratings);
                request.setAttribute("avgRating", avgRating);
                request.setAttribute("totalRatings", ratings != null ? ratings.size() : 0);
                
                request.getRequestDispatcher("/WEB-INF/jsp/manager/view-ratings.jsp").forward(request, response);
            } else if ("viewIssue".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("id"));
                    OrderIssue issue = OrderIssueDAO.getIssueByRentalOrder(rentalOrderID);
                    RentalOrder order = RentalOrderController.getRentalOrderByID(rentalOrderID);
                    java.util.Date createdAtDate = null;
                    java.util.Date resolvedAtDate = null;
                    if (issue != null) {
                        if (issue.getCreatedAt() != null) {
                            createdAtDate = Timestamp.valueOf(issue.getCreatedAt());
                        }
                        if (issue.getResolvedAt() != null) {
                            resolvedAtDate = Timestamp.valueOf(issue.getResolvedAt());
                        }
                    }
                    
                    request.setAttribute("issue", issue);
                    request.setAttribute("order", order);
                    request.setAttribute("issueCreatedAtDate", createdAtDate);
                    request.setAttribute("issueResolvedAtDate", resolvedAtDate);
                    request.getRequestDispatcher("/WEB-INF/jsp/manager/view-issue.jsp").forward(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders");
                }
            } else if ("updateIssue".equals(action)) {
                try {
                    int issueID = Integer.parseInt(request.getParameter("issueID"));
                    String issueStatus = request.getParameter("issueStatus");
                    String notes = request.getParameter("notes");
                    
                    OrderIssueDAO.updateIssueStatus(issueID, issueStatus, notes);
                    
                    // Get the issue to get rentalOrderID for redirect
                    OrderIssue issue = OrderIssueDAO.getIssueByID(issueID);
                    int rentalOrderID = issue != null ? issue.getRentalOrderID() : 0;
                    
                    // If resolved, update order status to COMPLETED
                    if ("RESOLVED".equals(issueStatus)) {
                        RentalOrderController.updateOrderStatus(rentalOrderID, "COMPLETED");
                    }
                    
                    response.sendRedirect(request.getContextPath() + "/manager?action=viewIssue&id=" + rentalOrderID + "&success=true");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders");
                }
            } else if ("revenue".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/manager/revenue.jsp").forward(request, response);
            } else if ("profile".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/jsp/manager/profile.jsp").forward(request, response);
            } else if ("updateProfile".equals(action)) {
                handleUpdateProfile(request, response, manager);
            } else if ("changePassword".equals(action)) {
                handleChangePassword(request, response, manager, managerId);
            } else if ("orders".equals(action)) {
                // Hiển thị các đơn đặt thuê của sản phẩm mà manager sở hữu
                System.out.println("[ManagerServlet] Getting rental orders for manager: " + managerId);
                List<RentalOrder> rentalOrders = RentalOrderController.getRentalOrdersByManager(managerId);
                System.out.println("[ManagerServlet] Found " + (rentalOrders != null ? rentalOrders.size() : "null") + " orders");
                int newConfirmedCount = 0;
                if (rentalOrders != null) {
                    for (RentalOrder ro : rentalOrders) {
                        if ("PAYMENT_VERIFIED".equals(ro.getStatus())) {
                            newConfirmedCount++;
                        }
                    }
                }
                // Build a map of rentalOrderID -> true for orders that already have ratings
                java.util.Map<Integer, Boolean> ratedMap = new java.util.HashMap<>();
                if (rentalOrders != null) {
                    for (RentalOrder ro : rentalOrders) {
                        try {
                            Rating existing = Controller.RatingController.getRatingByOrder(ro.getRentalOrderID());
                            if (existing != null) {
                                ratedMap.put(ro.getRentalOrderID(), true);
                            }
                        } catch (Exception e) {
                            // ignore
                        }
                    }
                }
                request.setAttribute("newConfirmedCount", newConfirmedCount);
                request.setAttribute("rentalOrders", rentalOrders);
                request.setAttribute("ratedMap", ratedMap);
                request.getRequestDispatcher("/WEB-INF/jsp/manager/manage-orders.jsp").forward(request, response);
            } else {
                // Default: Dashboard với thống kê
                request.setAttribute("manager", manager);
                
                // Lấy dữ liệu dashboard
                double totalRevenue = DashboardService.getTotalRevenue(managerId);
                int completedOrders = DashboardService.getCompletedOrderCount(managerId);
                int pendingOrders = DashboardService.getPendingOrderCount(managerId);
                int confirmedOrders = DashboardService.getConfirmedOrderCount(managerId);
                int activeProducts = DashboardService.getActiveProductCount(managerId);
                List<Map<String, Object>> topRatedProducts = DashboardService.getTopRatedProducts(managerId, 3);
                List<Map<String, Object>> topRevenueProducts = DashboardService.getTopRevenueProducts(managerId, 3);
                List<Map<String, Object>> revenueByDate = DashboardService.getRevenueByDate(managerId, 30);
                
                request.setAttribute("totalRevenue", totalRevenue);
                request.setAttribute("completedOrders", completedOrders);
                request.setAttribute("pendingOrders", pendingOrders);
                request.setAttribute("confirmedOrders", confirmedOrders);
                request.setAttribute("activeProducts", activeProducts);
                request.setAttribute("topRatedProducts", topRatedProducts);
                request.setAttribute("topRevenueProducts", topRevenueProducts);
                request.setAttribute("revenueByDate", revenueByDate);
                
                request.getRequestDispatcher("/WEB-INF/jsp/manager/dashboard.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        handleRequest(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        handleRequest(request, response);
    }

    /**
     * Cập nhật thông tin hồ sơ
     */
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Account manager) 
            throws ServletException, IOException {
        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");
            
            // Validate
            if (fullName == null || fullName.trim().isEmpty() || 
                email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&error=invalid");
                return;
            }
            
            // Update manager object
            manager.setFullName(fullName);
            manager.setEmail(email);
            manager.setPhoneNumber(phoneNumber);
            manager.setAddress(address);
            
            // Gọi UserService để cập nhật
            if (Service.UserService.updateProfile(manager)) {
                // Update session
                HttpSession session = request.getSession();
                session.setAttribute("account", manager);
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&error=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/manager?action=profile&error=exception");
        }
    }

    /**
     * Đổi mật khẩu
     */
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, Account manager, int accountID)
            throws ServletException, IOException {
        try {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Validate
            if (oldPassword == null || oldPassword.isEmpty() ||
                newPassword == null || newPassword.isEmpty() ||
                confirmPassword == null || confirmPassword.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=empty");
                return;
            }
            
            if (!newPassword.equals(confirmPassword)) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=notmatch");
                return;
            }
            
            if (newPassword.length() < 6) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=short");
                return;
            }
            
            // Xác nhận mật khẩu cũ
            if (!DAO.AccountDAO.verifyPassword(accountID, oldPassword)) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=wrongold");
                return;
            }
            
            // Cập nhật mật khẩu mới (non-admin, nên sẽ hash)
            if (DAO.AccountDAO.changePassword(accountID, oldPassword, newPassword)) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdSuccess=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=exception");
        }
    }}