package com.wearconnect.boot.controller;

import Controller.RatingController;
import Controller.RentalOrderController;
import DAO.AccountDAO;
import DAO.OrderIssueDAO;
import DAO.RatingDAO;
import DAO.RentalOrderDAO;
import Model.Account;
import Model.OrderIssue;
import Model.Rating;
import Model.RentalOrder;
import Service.DashboardService;
import Service.NotificationService;
import Service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/manager")
public class ManagerPageController {

    @RequestMapping
    public void handleRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("account") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String userRole = (String) session.getAttribute("userRole");
            if (userRole != null) userRole = userRole.trim();
            if (!("Manager".equals(userRole))) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Object accountIDObj = session.getAttribute("accountID");
            if (accountIDObj == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            int managerId = (accountIDObj instanceof Integer)
                    ? (Integer) accountIDObj
                    : Integer.parseInt(accountIDObj.toString());

            Account manager = (Account) session.getAttribute("account");
            String action = request.getParameter("action");

            if ("saveManagerRating".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    int ratingValue = Integer.parseInt(request.getParameter("rating"));
                    String managerNotes = request.getParameter("managerNotes");
                    int ratingID = RatingController.submitRating(rentalOrderID, managerId, ratingValue, managerNotes);
                    response.setStatus(ratingID > 0 ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                } catch (Exception e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                }
                return;
            }

            if ("confirmReturnReceived".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "RETURNED");
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            NotificationService.createNotification(
                                    order.getRenterUserID(),
                                    "Manager đã nhận hàng trả về",
                                    "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Manager đã xác nhận nhận hàng trả về.",
                                    rentalOrderID);
                            List<Account> admins = AccountDAO.findByRole("Admin");
                            for (Account admin : admins) {
                                NotificationService.createNotification(
                                        admin.getAccountID(),
                                        "Đơn hàng đã trả về - Cần xử lý hoàn tiền",
                                        "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã được trả về. Vui lòng kiểm tra và xử lý hoàn tiền cọc cho khách hàng.",
                                        rentalOrderID);
                            }
                        }
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnConfirmed=true");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnConfirmed=false");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                }
                return;
            }

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
                                NotificationService.createNotification(
                                        order.getRenterUserID(),
                                        "Phương thức trả hàng",
                                        "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Manager sẽ đến lấy hàng trực tiếp.",
                                        rentalOrderID);
                            } else if ("SHIP_TO_MANAGER".equals(returnMethod)) {
                                Account managerAccount = AccountDAO.findById(order.getManagerID());
                                if (managerAccount != null) {
                                    String managerInfo = "📍 Địa chỉ: " + (managerAccount.getAddress() != null ? managerAccount.getAddress() : "Chưa cập nhật")
                                            + "\n📞 SĐT: " + (managerAccount.getPhoneNumber() != null ? managerAccount.getPhoneNumber() : "Chưa cập nhật")
                                            + "\n👤 Người nhận: " + (managerAccount.getFullName() != null ? managerAccount.getFullName() : managerAccount.getUsername());
                                    NotificationService.createNotification(
                                            order.getRenterUserID(),
                                            "Vui lòng gửi hàng về địa chỉ",
                                            "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Vui lòng gửi hàng về địa chỉ sau:\n" + managerInfo,
                                            rentalOrderID);
                                }
                            }
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID);
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                }
                return;
            }

            if ("replaceItem".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    int issueID = Integer.parseInt(request.getParameter("issueID"));
                    OrderIssueDAO.updateIssueStatus(issueID, "RESOLVED", "Đã xử lý: Đổi hàng mới cho khách hàng");
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "PAYMENT_VERIFIED");
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            NotificationService.createNotification(
                                    order.getRenterUserID(), "Đổi hàng mới",
                                    "Đơn hàng " + orderCode + " (" + clothingInfo + ") sẽ được đổi hàng mới. Sản phẩm mới sẽ được gửi đến bạn sớm.",
                                    rentalOrderID);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&replaced=true");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                }
                return;
            }

            if ("cancelOrderIssue".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    int issueID = Integer.parseInt(request.getParameter("issueID"));
                    OrderIssueDAO.updateIssueStatus(issueID, "REJECTED", "Đơn hàng đã hủy - Hoàn tiền 100%");
                    RentalOrderDAO.updateReturnMethod(rentalOrderID, "SHIP_TO_MANAGER");
                    boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "RETURN_REQUESTED");
                    if (updated) {
                        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                        if (order != null) {
                            String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                            String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                            Account managerAccount = AccountDAO.findById(order.getManagerID());
                            String managerInfo = "";
                            if (managerAccount != null) {
                                managerInfo = "\n\n📦 Vui lòng gửi hàng về địa chỉ:\n📍 "
                                        + (managerAccount.getAddress() != null ? managerAccount.getAddress() : "Chưa cập nhật")
                                        + "\n📞 " + (managerAccount.getPhoneNumber() != null ? managerAccount.getPhoneNumber() : "Chưa cập nhật")
                                        + "\n👤 " + (managerAccount.getFullName() != null ? managerAccount.getFullName() : managerAccount.getUsername());
                            }
                            NotificationService.createNotification(
                                    order.getRenterUserID(),
                                    "Đơn hàng đã hủy - Hoàn tiền 100%",
                                    "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã được hủy do sản phẩm có vấn đề. Bạn sẽ được hoàn lại 100% tiền thuê và tiền cọc." + managerInfo,
                                    rentalOrderID);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&cancelled=true");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=true");
                }
                return;
            }

            if ("updateStatus".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    String status = request.getParameter("status");
                    if ("RENTED".equals(status) || "RETURNED".equals(status) || "COMPLETED".equals(status) || "CANCELLED".equals(status)) {
                        boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, status);
                        if (updated && "COMPLETED".equals(status)) {
                            RentalOrder completedOrder = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                            if (completedOrder != null) {
                                String orderCode = "WRC" + String.format("%05d", completedOrder.getRentalOrderID());
                                String renterName = completedOrder.getRenterFullName() != null ? completedOrder.getRenterFullName() : "Khách hàng";
                                String clothingInfo = completedOrder.getClothingName() != null ? completedOrder.getClothingName() : "ID: " + completedOrder.getClothingID();
                                List<Account> admins = AccountDAO.findByRole("Admin");
                                for (Account admin : admins) {
                                    NotificationService.createNotification(
                                            admin.getAccountID(), "Đơn thuê hoàn thành",
                                            "Đơn hàng " + orderCode + " (" + clothingInfo + ") thuê thành công. Tiến hành hoàn lại cọc cho " + renterName + ".",
                                            rentalOrderID);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/manager?action=orders&success=true");
                return;
            }

            if ("shipOrder".equals(action)) {
                try {
                    int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                    String trackingNumber = request.getParameter("trackingNumber");
                    if (trackingNumber != null && !trackingNumber.trim().isEmpty()) {
                        RentalOrderController.setTrackingNumber(rentalOrderID, trackingNumber.trim());
                        boolean updated = RentalOrderController.updateOrderStatus(rentalOrderID, "SHIPPING");
                        if (updated) {
                            RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                            if (order != null) {
                                String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                                NotificationService.createNotification(
                                        order.getRenterUserID(), "Đơn hàng đã được gửi",
                                        "Đơn hàng " + orderCode + " (" + (order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID()) + ") đã được gửi đi. Mã vận đơn: " + trackingNumber + ".",
                                        rentalOrderID);
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/manager?action=orders&success=true");
                return;
            }

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
                                    order.getRenterUserID(), "Đơn hàng đã đến",
                                    "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã đến. Vui lòng nhận hàng và xác nhận.",
                                    rentalOrderID);
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
                        if (issue.getCreatedAt() != null) createdAtDate = Timestamp.valueOf(issue.getCreatedAt());
                        if (issue.getResolvedAt() != null) resolvedAtDate = Timestamp.valueOf(issue.getResolvedAt());
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

                    OrderIssue issue = OrderIssueDAO.getIssueByID(issueID);
                    int rentalOrderID = issue != null ? issue.getRentalOrderID() : 0;
                    RentalOrder issueOrder = rentalOrderID > 0 ? RentalOrderDAO.getRentalOrderByID(rentalOrderID) : null;
                    if (issueOrder != null) {
                        String orderCode = "WRC" + String.format("%05d", issueOrder.getRentalOrderID());
                        String clothingInfo = issueOrder.getClothingName() != null ? issueOrder.getClothingName() : "ID: " + issueOrder.getClothingID();
                        String statusText = "ACKNOWLEDGED".equals(issueStatus) ? "đã xác nhận vấn đề"
                                : "RESOLVED".equals(issueStatus) ? "đã giải quyết vấn đề"
                                : "REJECTED".equals(issueStatus) ? "đã từ chối vấn đề"
                                : "đã cập nhật vấn đề";
                        String noteText = (notes != null && !notes.trim().isEmpty())
                                ? "\n\nCách xử lý từ manager:\n" + notes.trim()
                                : "\n\nManager chưa thêm ghi chú xử lý.";
                        NotificationService.createNotification(
                                issueOrder.getRenterUserID(),
                                "Cập nhật xử lý vấn đề đơn hàng",
                                "Đơn hàng " + orderCode + " (" + clothingInfo + ") " + statusText + "." + noteText,
                                rentalOrderID);
                    }
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
                List<RentalOrder> rentalOrders = RentalOrderController.getRentalOrdersByManager(managerId);
                int newConfirmedCount = 0;
                if (rentalOrders != null) {
                    for (RentalOrder ro : rentalOrders) {
                        if ("PAYMENT_VERIFIED".equals(ro.getStatus())) newConfirmedCount++;
                    }
                }
                Map<Integer, Boolean> ratedMap = new HashMap<>();
                if (rentalOrders != null) {
                    for (RentalOrder ro : rentalOrders) {
                        try {
                            Rating existing = RatingController.getRatingByOrder(ro.getRentalOrderID());
                            if (existing != null) ratedMap.put(ro.getRentalOrderID(), true);
                        } catch (Exception e) { /* ignore */ }
                    }
                }
                request.setAttribute("newConfirmedCount", newConfirmedCount);
                request.setAttribute("rentalOrders", rentalOrders);
                request.setAttribute("ratedMap", ratedMap);
                request.getRequestDispatcher("/WEB-INF/jsp/manager/manage-orders.jsp").forward(request, response);
            } else {
                // Default dashboard
                request.setAttribute("manager", manager);
                double totalRevenue = DashboardService.getTotalRevenue(managerId);
                int completedOrders = DashboardService.getCompletedOrderCount(managerId);
                int pendingOrders = DashboardService.getPendingOrderCount(managerId);
                int confirmedOrders = DashboardService.getConfirmedOrderCount(managerId);
                int activeProducts = DashboardService.getActiveProductCount(managerId);
                List<Map<String, Object>> topRatedProducts = DashboardService.getTopRatedProducts(managerId, 3);
                List<Map<String, Object>> topRevenueProducts = DashboardService.getTopRevenueProducts(managerId, 3);
                List<Map<String, Object>> revenueByDate = DashboardService.getRevenueByDate(managerId, 0);

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

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Account manager)
            throws ServletException, IOException {
        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");
            String bankAccountNumber = request.getParameter("bankAccountNumber");
            String bankName = request.getParameter("bankName");

            if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&error=invalid");
                return;
            }

            manager.setFullName(fullName);
            manager.setEmail(email);
            manager.setPhoneNumber(phoneNumber);
            manager.setAddress(address);
            manager.setBankAccountNumber(bankAccountNumber);
            manager.setBankName(bankName);

            if (UserService.updateProfile(manager)) {
                HttpSession session = request.getSession();
                session.setAttribute("account", manager);
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

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, Account manager, int accountID)
            throws ServletException, IOException {
        try {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (oldPassword == null || oldPassword.isEmpty() || newPassword == null || newPassword.isEmpty()
                    || confirmPassword == null || confirmPassword.isEmpty()) {
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
            if (!AccountDAO.verifyPassword(accountID, oldPassword)) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=wrongold");
                return;
            }
            if (AccountDAO.changePassword(accountID, oldPassword, newPassword)) {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdSuccess=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/manager?action=profile&pwdError=exception");
        }
    }

    private void checkAndMarkProfileNotificationAsRead(Account manager) {
        try {
            boolean isComplete = manager.getPhoneNumber() != null && !manager.getPhoneNumber().trim().isEmpty()
                    && manager.getAddress() != null && !manager.getAddress().trim().isEmpty();
            try {
                if (manager.getBankAccountNumber() == null || manager.getBankAccountNumber().trim().isEmpty()) isComplete = false;
                if (manager.getBankName() == null || manager.getBankName().trim().isEmpty()) isComplete = false;
            } catch (Exception e) {
                isComplete = false;
            }
            if (isComplete) {
                List<Model.Notification> unreadNotifs = NotificationService.getUnreadNotifications(manager.getAccountID());
                if (unreadNotifs != null) {
                    for (Model.Notification notif : unreadNotifs) {
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
