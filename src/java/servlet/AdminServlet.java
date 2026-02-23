package servlet;

import Model.Account;
import Model.Clothing;
import Model.CosplayDetail;
import Model.RentalOrder;
import Controller.UserController;
import Controller.PaymentController;
import Controller.ClothingController;
import DAO.AccountDAO;
import DAO.ClothingDAO;
import DAO.CosplayDetailDAO;
import Service.NotificationService;
import Service.DashboardService;
import Service.RentalOrderService;
import java.util.HashMap;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdminServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Kiểm tra session
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Kiểm tra role
        String userRole = (String) session.getAttribute("userRole");
        System.out.println("=== Admin Servlet Debug ===");
        System.out.println("UserRole from session: '" + userRole + "'");
        System.out.println("UserRole is null: " + (userRole == null));
        System.out.println("===========================");
        
        if (userRole != null) {
            userRole = userRole.trim(); // Xóa khoảng trắng
        }
        if (!("Admin".equals(userRole))) {
            System.out.println("Not Admin! Role: " + userRole);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Xử lý các action
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            int accountID = Integer.parseInt(request.getParameter("id"));
            UserController.deleteUser(accountID);
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        } else if ("toggleStatus".equals(action)) {
            int accountID = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");
            boolean newStatus = "active".equals(status) ? false : true;
            UserController.toggleUserStatus(accountID, newStatus);
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        } else if ("orders".equals(action)) {
            showOrdersPage(request, response);
            return;
        } else if ("verifyPayment".equals(action)) {
            verifyPayment(request, response);
            return;
        } else if ("rejectPayment".equals(action)) {
            rejectPayment(request, response);
            return;
        } else if ("statistics".equals(action)) {
            showStatistics(request, response);
            return;
        } else if ("reviewCosplay".equals(action)) {
            showCosplayReviewPage(request, response);
            return;
        } else if ("deactivateProduct".equals(action)) {
            deactivateProduct(request, response);
            return;
        } else if ("approveProduct".equals(action)) {
            approveProduct(request, response);
            return;
        } else if ("approveCosplay".equals(action)) {
            approveCosplay(request, response);
            return;
        } else if ("rejectCosplay".equals(action)) {
            rejectCosplay(request, response);
            return;
        } else if ("users".equals(action)) {
            showUsersPage(request, response);
            return;
        } else if ("ratings".equals(action)) {
            showRatingsPage(request, response);
            return;
        } else if ("payments".equals(action)) {
            showPaymentsPage(request, response);
            return;
        }

        // Admin home: danh sach san pham (default view)
        List<Clothing> products = ClothingDAO.getAllClothingAdmin();
        Map<Integer, Account> managerMap = new HashMap<>();
        for (Clothing clothing : products) {
            int renterID = clothing.getRenterID();
            if (!managerMap.containsKey(renterID)) {
                Account acc = AccountDAO.findById(renterID);
                managerMap.put(renterID, acc);
            }
        }
        request.setAttribute("products", products);
        request.setAttribute("managerMap", managerMap);
        request.setAttribute("view", "products");

        // Thông báo đơn cần xác nhận (PENDING_PAYMENT hoặc PAYMENT_SUBMITTED)
        int pendingCount = RentalOrderService.countOrdersByStatus("PENDING_PAYMENT");
        int verifyingCount = RentalOrderService.countOrdersByStatus("PAYMENT_SUBMITTED");
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("verifyingCount", verifyingCount);
        request.setAttribute("newOrdersCount", pendingCount + verifyingCount);
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(request, response);
    }

    private void deactivateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            String reason = request.getParameter("reason");
            String note = request.getParameter("note");

            Clothing clothing = ClothingDAO.getClothingByID(clothingID);
            boolean statusOk = ClothingDAO.updateClothingStatus(clothingID, "INACTIVE");
            boolean activeOk = ClothingDAO.setClothingActive(clothingID, false);

            if (statusOk && activeOk && clothing != null) {
                StringBuilder msg = new StringBuilder();
                msg.append("San pham '").append(clothing.getClothingName()).append("' da bi tam ngung hoat dong. Ly do: ");
                msg.append(reason != null ? reason : "Khac");
                if (note != null && !note.trim().isEmpty()) {
                    msg.append(". Ghi chu: ").append(note.trim());
                }
                NotificationService.createNotification(
                        clothing.getRenterID(),
                        "San pham bi tam ngung",
                        msg.toString()
                );
            }
            response.sendRedirect(request.getContextPath() + "/admin");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?error=true");
        }
    }

    private void approveProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            Clothing clothing = ClothingDAO.getClothingByID(clothingID);
            if (clothing == null) {
                response.sendRedirect(request.getContextPath() + "/admin?error=true");
                return;
            }

            String status = clothing.getClothingStatus();
            boolean statusOk;
            if ("Cosplay".equals(clothing.getCategory())) {
                statusOk = ClothingDAO.updateClothingStatus(clothingID, "APPROVED_COSPLAY");
            } else {
                statusOk = ClothingDAO.updateClothingStatus(clothingID, "ACTIVE");
            }
            boolean activeOk = ClothingDAO.setClothingActive(clothingID, true);

            if (statusOk && activeOk) {
                NotificationService.createNotification(
                        clothing.getRenterID(),
                        "San pham da duoc duyet",
                        "San pham '" + clothing.getClothingName() + "' da duoc admin duyet va hoat dong lai."
                );
            }
            response.sendRedirect(request.getContextPath() + "/admin");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?error=true");
        }
    }
    
    /**
     * Show all orders page with filters
     */
    private void showOrdersPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        if (statusFilter == null) {
            statusFilter = "ALL";
        }
        
        System.out.println("[AdminServlet] showOrdersPage - Status filter (raw): " + statusFilter);

        // Map friendly UI status values to actual DB status codes
        String dbStatusFilter = statusFilter;
        if ("PENDING".equalsIgnoreCase(statusFilter)) {
            dbStatusFilter = "PENDING_PAYMENT";
        } else if ("VERIFYING".equalsIgnoreCase(statusFilter)) {
            dbStatusFilter = "PAYMENT_SUBMITTED";
        } else if (statusFilter == null || statusFilter.isEmpty() || "ALL".equalsIgnoreCase(statusFilter)) {
            dbStatusFilter = "ALL";
        }

        System.out.println("[AdminServlet] showOrdersPage - Status filter (db): " + dbStatusFilter);

        List<Map<String, Object>> orders = DashboardService.getAllOrdersWithDetails(dbStatusFilter);
        
        System.out.println("[AdminServlet] Orders retrieved: " + (orders != null ? orders.size() : "null"));
        if (orders != null && !orders.isEmpty()) {
            System.out.println("[AdminServlet] First order: " + orders.get(0));
        }
        
        request.setAttribute("orders", orders);
        request.setAttribute("statusFilter", statusFilter);
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/orders.jsp").forward(request, response);
    }

    private void showRatingsPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> ratings = DashboardService.getAllRatingsWithDetails();
        request.setAttribute("ratings", ratings);
        request.getRequestDispatcher("/WEB-INF/jsp/admin/ratings.jsp").forward(request, response);
    }
    
    /**
     * Verify payment (change status from VERIFYING to CONFIRMED)
     */
    private void verifyPayment(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int orderID = Integer.parseInt(request.getParameter("orderID"));
            
            // Update order status to PAYMENT_VERIFIED
            RentalOrderService.updateOrderStatus(orderID, "PAYMENT_VERIFIED");
            
            System.out.println("[AdminServlet] Order " + orderID + " verified - Status changed to PAYMENT_VERIFIED");

            // Notify the manager (product owner) that the order was confirmed
            try {
                Model.RentalOrder ro = Controller.RentalOrderController.getRentalOrderByID(orderID);
                if (ro != null) {
                    int managerUserID = ro.getManagerID();
                    if (managerUserID > 0) {
                        String title = "Đơn hàng đã được xác nhận";
                        String message = "Đơn hàng #" + orderID + " đã được xác nhận bởi quản trị viên.";
                        Controller.NotificationController.createNotification(managerUserID, title, message, orderID);
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            
            // Redirect back to ALL to show all orders and newly confirmed one
            // This avoids showing empty page if last VERIFYING order was confirmed
            response.sendRedirect(request.getContextPath() + "/admin?action=orders&status=ALL&verified=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=orders&error=true");
        }
    }

    /**
     * Reject payment and return order to PENDING_PAYMENT
     */
    private void rejectPayment(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int orderID = Integer.parseInt(request.getParameter("orderID"));
            // Get rejection reason (if provided)
            String reason = request.getParameter("reason");
            if (reason == null) reason = "Lý do không được cung cấp";
            // Optionally clear stored payment proof on RentalOrder
            Controller.RentalOrderController.setPaymentProofPath(orderID, null);
            // Set order back to PENDING_PAYMENT and save notes
            Controller.RentalOrderController.updateOrderStatusWithNotes(orderID, "PENDING_PAYMENT", reason);
            // If payment record exists, mark as failed (best-effort)
            Model.Payment payment = PaymentController.getPaymentStatus(orderID);
            if (payment != null) {
                PaymentController.failPayment(payment.getPaymentID());
            }

            // Create an in-app notification for renter
            try {
                Model.RentalOrder ro = Controller.RentalOrderController.getRentalOrderByID(orderID);
                if (ro != null) {
                    int renterUserID = ro.getRenterUserID();
                    String title = "Đơn hàng bị từ chối";
                    String message = "Đơn hàng #" + orderID + " của bạn đã bị từ chối. Lý do: " + reason;
                    Controller.NotificationController.createNotification(renterUserID, title, message, orderID);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            response.sendRedirect(request.getContextPath() + "/admin?action=orders&status=ALL&rejected=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=orders&error=true");
        }
    }
    
    /**
     * Show statistics page
     */
    private void showStatistics(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get top rated managers
        List<Map<String, Object>> topManagers = DashboardService.getTopRatedManagers(10);
        request.setAttribute("topManagers", topManagers);
        
        // Get most rented products
        List<Map<String, Object>> topProducts = DashboardService.getMostRentedProducts(10);
        request.setAttribute("topProducts", topProducts);
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/statistics.jsp").forward(request, response);
    }
    
    /**
     * Show cosplay review page with pending cosplay products
     */
    private void showCosplayReviewPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get all pending cosplay products
        List<Clothing> pendingCosplay = ClothingDAO.getCosplayByStatus("PENDING_COSPLAY_REVIEW");
        
        // Attach cosplay details to each product
        for (Clothing clothing : pendingCosplay) {
            CosplayDetail detail = CosplayDetailDAO.getCosplayDetailByClothingID(clothing.getClothingID());
            request.setAttribute("cosplayDetail_" + clothing.getClothingID(), detail);
        }
        
        request.setAttribute("pendingCosplay", pendingCosplay);
        request.getRequestDispatcher("/WEB-INF/jsp/admin/review-cosplay.jsp").forward(request, response);
    }
    
    /**
     * Approve a cosplay product
     */
    private void approveCosplay(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int clothingID = Integer.parseInt(request.getParameter("id"));
            
            // Lấy thông tin sản phẩm để gửi thông báo
            Clothing clothing = ClothingDAO.getClothingByID(clothingID);
            
            boolean success = ClothingDAO.updateClothingStatus(clothingID, "APPROVED_COSPLAY");
            
            if (success && clothing != null) {
                // Gửi thông báo cho manager
                Service.NotificationService.createNotification(
                    clothing.getRenterID(),
                    "Sản phẩm Cosplay đã được xác thực",
                    "Sản phẩm '" + clothing.getClothingName() + "' (SP#" + clothing.getClothingID() + ") đã được Admin duyệt và hiện đang hiển thị trên trang Cosplay."
                );
                
                response.sendRedirect(request.getContextPath() + "/admin?action=reviewCosplay&success=approved");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=reviewCosplay&error=true");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=reviewCosplay&error=true");
        }
    }
    
    /**
     * Reject a cosplay product
     */
    private void rejectCosplay(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int clothingID = Integer.parseInt(request.getParameter("id"));
            
            // Lấy thông tin sản phẩm để gửi thông báo
            Clothing clothing = ClothingDAO.getClothingByID(clothingID);
            
            // Set to INACTIVE and mark as not active
            boolean success = ClothingDAO.updateClothingStatus(clothingID, "INACTIVE");
            if (success) {
                ClothingDAO.setClothingActive(clothingID, false);
                
                // Gửi thông báo cho manager
                if (clothing != null) {
                    Service.NotificationService.createNotification(
                        clothing.getRenterID(),
                        "Sản phẩm Cosplay không được duyệt",
                        "Sản phẩm '" + clothing.getClothingName() + "' (SP#" + clothing.getClothingID() + ") đã bị từ chối bởi Admin. Vui lòng kiểm tra lại thông tin và chất lượng sản phẩm."
                    );
                }
            }
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=reviewCosplay&success=rejected");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=reviewCosplay&error=true");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=reviewCosplay&error=true");
        }
    }
    
    private void showUsersPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get all users
        List<Account> users = UserController.getAllUsers();
        request.setAttribute("users", users);
        request.setAttribute("view", "users");
        
        // Thông báo đơn cần xác nhận (PENDING_PAYMENT hoặc PAYMENT_SUBMITTED)
        int pendingCount = RentalOrderService.countOrdersByStatus("PENDING_PAYMENT");
        int verifyingCount = RentalOrderService.countOrdersByStatus("PAYMENT_SUBMITTED");
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("verifyingCount", verifyingCount);
        request.setAttribute("newOrdersCount", pendingCount + verifyingCount);
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(request, response);
    }
    
    private void showPaymentsPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get all RETURNED orders that need payment processing
            List<Model.RentalOrder> returnedOrders = Service.RentalOrderService.getOrdersByStatus("RETURNED");
            
            // Get user and manager account details for each order
            Map<Integer, Account> accountMap = new HashMap<>();
            Map<Integer, Clothing> clothingMap = new HashMap<>();
            
            for (Model.RentalOrder order : returnedOrders) {
                // Get renter (user)
                if (!accountMap.containsKey(order.getRenterUserID())) {
                    Account renter = AccountDAO.findById(order.getRenterUserID());
                    accountMap.put(order.getRenterUserID(), renter);
                }
                
                // Get clothing and manager
                if (!clothingMap.containsKey(order.getClothingID())) {
                    Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                    clothingMap.put(order.getClothingID(), clothing);
                    
                    if (clothing != null && !accountMap.containsKey(clothing.getRenterID())) {
                        Account manager = AccountDAO.findById(clothing.getRenterID());
                        accountMap.put(clothing.getRenterID(), manager);
                    }
                }
            }
            
            request.setAttribute("returnedOrders", returnedOrders);
            request.setAttribute("accountMap", accountMap);
            request.setAttribute("clothingMap", clothingMap);
            request.setAttribute("view", "payments");
            
            // Thông báo đơn cần xác nhận
            int pendingCount = RentalOrderService.countOrdersByStatus("PENDING_PAYMENT");
            int verifyingCount = RentalOrderService.countOrdersByStatus("PAYMENT_SUBMITTED");
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("verifyingCount", verifyingCount);
            request.setAttribute("newOrdersCount", pendingCount + verifyingCount);
            
            request.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?error=true");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Check authentication
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("confirmPayment".equals(action)) {
            handleConfirmPayment(request, response);
            return;
        }
        
        doGet(request, response);
    }
    
    private void handleConfirmPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Note: For now, we'll just mark the order as COMPLETED
            // File upload handling will be added later
            int orderID = Integer.parseInt(request.getParameter("orderID"));
            
            // Update order status to COMPLETED
            boolean success = Service.RentalOrderService.updateOrderStatus(orderID, "COMPLETED");
            
            if (success) {
                // Get order details for notifications
                Model.RentalOrder order = Service.RentalOrderService.getRentalOrderDetails(orderID);
                if (order != null) {
                    // Notify user that deposit has been refunded
                    Service.NotificationService.createNotification(
                        order.getRenterUserID(),
                        "Hoàn tiền cọc",
                        "Tiền cọc " + String.format("%,.0f", order.getDepositAmount()) + " VND của đơn hàng #" + orderID + " đã được hoàn lại vào tài khoản ngân hàng của bạn. Cảm ơn bạn đã sử dụng WearConnect!"
                    );
                    
                    // Notify manager that rental fee has been paid
                    Model.Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                    if (clothing != null) {
                        Service.NotificationService.createNotification(
                            clothing.getRenterID(),
                            "Thanh toán tiền thuê",
                            "Tiền thuê " + String.format("%,.0f", order.getTotalPrice()) + " VND của đơn hàng #" + orderID + " đã được chuyển vào tài khoản ngân hàng của bạn. Cảm ơn bạn đã sử dụng WearConnect!"
                        );
                    }
                }
                response.sendRedirect(request.getContextPath() + "/admin?action=payments&success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=payments&error=true");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=payments&error=true");
        }
    }
}
