package servlet;

import Model.Account;
import Model.Clothing;
import Model.RentalOrder;
import Model.Rating;
import Model.OrderIssue;
import Controller.ClothingController;
import Controller.RentalOrderController;
import DAO.AccountDAO;
import DAO.RatingDAO;
import DAO.OrderIssueDAO;
import DAO.RentalOrderDAO;
import Service.DashboardService;
import Service.NotificationService;
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
            
            // Manager xác nhận đã nhận hàng trả về
            if ("confirmReturnReceived".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    
                    // Chuyển order sang RETURNED
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "RETURNED");
                    
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            
                            // Gửi thông báo cho user
                            NotificationService.createNotification(
                                order.getRenterUserID(),
                                "Manager đã nhận hàng trả về",
                                "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Manager đã xác nhận nhận hàng trả về. Hệ thống đang xử lý hoàn tiền cọc và tiền thuê (nếu có). Vui lòng chờ admin xác nhận.",
                                rentalOrderID
                            );
                            
                            // Gửi thông báo cho admin để xử lý hoàn tiền
                            List<Account> admins = AccountDAO.findByRole("Admin");
                            for (Account admin : admins) {
                                NotificationService.createNotification(
                                    admin.getAccountID(),
                                    "Đơn hàng đã trả về - Cần xử lý hoàn tiền",
                                    "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã được trả về. Vui lòng kiểm tra và xử lý hoàn tiền cọc cho khách hàng.",
                                    rentalOrderID
                                );
                            }
                        }
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnConfirmed=true");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnConfirmed=false");
                    }
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                    return;
                }
            }
            
            // Manager chọn phương thức nhận hàng trả về
            if ("setReturnMethod".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    String returnMethod = request.getParameter("returnMethod");
                    
                    boolean updated = RentalOrderDAO.updateReturnMethod(rentalOrderID, returnMethod);
                    
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            
                            if ("MANAGER_PICKUP".equals(returnMethod)) {
                                // Manager sẽ đến lấy hàng
                                NotificationService.createNotification(
                                    order.getRenterUserID(),
                                    "Phương thức trả hàng",
                                    "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Manager sẽ đến lấy hàng trực tiếp. Vui lòng giữ liên lạc qua SĐT: " + (order.getRenterPhone() != null ? order.getRenterPhone() : ""),
                                    rentalOrderID
                                );
                            } else if ("SHIP_TO_MANAGER".equals(returnMethod)) {
                                // User gửi hàng về địa chỉ manager
                                // Lấy thông tin manager
                                Account managerAccount = AccountDAO.findById(order.getManagerID());
                                if (managerAccount != null) {
                                    String managerInfo = "📍 Địa chỉ: " + (managerAccount.getAddress() != null ? managerAccount.getAddress() : "Chưa cập nhật") + 
                                                        "\n📞 SĐT: " + (managerAccount.getPhoneNumber() != null ? managerAccount.getPhoneNumber() : "Chưa cập nhật") +
                                                        "\n👤 Người nhận: " + (managerAccount.getFullName() != null ? managerAccount.getFullName() : managerAccount.getUsername());
                                    
                                    NotificationService.createNotification(
                                        order.getRenterUserID(),
                                        "Vui lòng gửi hàng về địa chỉ",
                                        "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Vui lòng gửi hàng về địa chỉ sau:\n" + managerInfo + "\n\nSau khi gửi, vui lòng cập nhật mã vận đơn trong chi tiết đơn hàng.",
                                        rentalOrderID
                                    );
                                }
                            }
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID);
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                    return;
                }
            }

            // Manager replaces item (đổi hàng)
            if ("replaceItem".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    int issueID = Integer.parseInt(request.getParameter("issueID"));
                    
                    // Cập nhật issue status thành RESOLVED
                    OrderIssueDAO.updateIssueStatus(issueID, "RESOLVED", "Đã xử lý: Đổi hàng mới cho khách hàng");
                    
                    // Chuyển order về PAYMENT_VERIFIED để manager có thể gửi hàng mới với tracking number
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "PAYMENT_VERIFIED");
                    
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            NotificationService.createNotification(
                                order.getRenterUserID(),
                                "Đổi hàng mới",
                                "Đơn hàng " + orderCode + " (" + clothingInfo + ") sẽ được đổi hàng mới. Sản phẩm mới sẽ được gửi đến bạn sớm. Vui lòng chờ và xác nhận khi nhận hàng.",
                                rentalOrderID
                            );
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&replaced=true");
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                    return;
                }
            }
            
            // Manager cancels order due to issue (hủy đơn hàng - yêu cầu trả)
            if ("cancelOrderIssue".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    int issueID = Integer.parseInt(request.getParameter("issueID"));
                    
                    // Cập nhật issue status thành REJECTED
                    OrderIssueDAO.updateIssueStatus(issueID, "REJECTED", "Đơn hàng đã hủy - Hoàn tiền 100%");
                    
                    // Set returnMethod thành SHIP_TO_MANAGER (user phải gửi về)
                    RentalOrderDAO.updateReturnMethod(rentalOrderID, "SHIP_TO_MANAGER");
                    
                    // Chuyển order sang RETURN_REQUESTED
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "RETURN_REQUESTED");
                    
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            
                            // Lấy thông tin manager để gửi địa chỉ
                            Account managerAccount = AccountDAO.findById(order.getManagerID());
                            String managerInfo = "";
                            if (managerAccount != null) {
                                managerInfo = "\n\n📦 Vui lòng gửi hàng về địa chỉ:\n" +
                                             "📍 " + (managerAccount.getAddress() != null ? managerAccount.getAddress() : "Chưa cập nhật") + "\n" +
                                             "📞 " + (managerAccount.getPhoneNumber() != null ? managerAccount.getPhoneNumber() : "Chưa cập nhật") + "\n" +
                                             "👤 " + (managerAccount.getFullName() != null ? managerAccount.getFullName() : managerAccount.getUsername());
                            }
                            
                            NotificationService.createNotification(
                                order.getRenterUserID(),
                                "Đơn hàng đã hủy - Hoàn tiền 100%",
                                "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã được hủy do sản phẩm có vấn đề. Bạn sẽ được hoàn lại 100% tiền thuê và tiền cọc." + managerInfo + "\n\nSau khi gửi, vui lòng cập nhật mã vận đơn.",
                                rentalOrderID
                            );
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&cancelled=true");
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                    return;
                }
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
                        
                        // Gửi thông báo cho admin khi đơn hoàn thành (manager đã nhận hàng trả về)
                        if (updated && "COMPLETED".equals(status)) {
                            RentalOrder completedOrder = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                            if (completedOrder != null) {
                                String orderCode = "WRC" + String.format("%05d", completedOrder.getRentalOrderID());
                                String renterName = completedOrder.getRenterFullName() != null ? completedOrder.getRenterFullName() : "Khách hàng";
                                String clothingInfo = completedOrder.getClothingName() != null ? completedOrder.getClothingName() : "ID: " + completedOrder.getClothingID();
                                
                                // Gửi thông báo cho tất cả admin
                                List<Account> admins = AccountDAO.findByRole("Admin");
                                for (Account admin : admins) {
                                    NotificationService.createNotification(
                                        admin.getAccountID(),
                                        "Đơn thuê hoàn thành",
                                        "Đơn hàng " + orderCode + " (" + clothingInfo + ") thuê thành công. Tiến hành hoàn lại cọc cho " + renterName + ".",
                                        rentalOrderID
                                    );
                                }
                            }
                        }
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
                        
                        // Gửi thông báo cho user
                        if (updated) {
                            RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                            if (order != null) {
                                String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                                NotificationService.createNotification(
                                    order.getRenterUserID(),
                                    "Đơn hàng đã được gửi",
                                    "Đơn hàng " + orderCode + " (" + (order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID()) + ") đã được gửi đi. Mã vận đơn: " + trackingNumber + ". Vui lòng đợi và nhận hàng.",
                                    rentalOrderID
                                );
                            }
                        }
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
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "DELIVERED_PENDING_CONFIRMATION");
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            NotificationService.createNotification(
                                order.getRenterUserID(),
                                "Đơn hàng đã đến",
                                "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã đến. Vui lòng nhận hàng và chụp ảnh đơn hàng để xác nhận bạn đã nhận được.",
                                rentalOrderID
                            );
                        }
                    }
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
            String bankAccountNumber = request.getParameter("bankAccountNumber");
            String bankName = request.getParameter("bankName");
            
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
            manager.setBankAccountNumber(bankAccountNumber);
            manager.setBankName(bankName);
            
            // Gọi UserService để cập nhật
            if (Service.UserService.updateProfile(manager)) {
                // Update session
                HttpSession session = request.getSession();
                session.setAttribute("account", manager);
                
                // Check if profile is now complete and mark notification as read
                checkAndMarkProfileNotificationAsRead(manager);
                
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
    }
    
    /**
     * Check if profile is complete and mark profile completion notification as read
     */
    private void checkAndMarkProfileNotificationAsRead(Account manager) {
        try {
            // Check if profile is complete
            boolean isComplete = true;
            
            if (manager.getPhoneNumber() == null || manager.getPhoneNumber().trim().isEmpty()) {
                isComplete = false;
            }
            if (manager.getAddress() == null || manager.getAddress().trim().isEmpty()) {
                isComplete = false;
            }
            
            try {
                if (manager.getBankAccountNumber() == null || manager.getBankAccountNumber().trim().isEmpty()) {
                    isComplete = false;
                }
            } catch (Exception e) {
                isComplete = false;
            }
            
            try {
                if (manager.getBankName() == null || manager.getBankName().trim().isEmpty()) {
                    isComplete = false;
                }
            } catch (Exception e) {
                isComplete = false;
            }
            
            // If profile is complete, mark notification as read
            if (isComplete) {
                java.util.List<Model.Notification> unreadNotifs = Service.NotificationService.getUnreadNotifications(manager.getAccountID());
                
                if (unreadNotifs != null) {
                    for (Model.Notification notif : unreadNotifs) {
                        if ("Cập nhật thông tin Profile".equals(notif.getTitle())) {
                            Service.NotificationService.markAsRead(notif.getNotificationID());
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