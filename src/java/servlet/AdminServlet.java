package servlet;

import Model.Account;
import Model.RentalOrder;
import Controller.UserController;
import Controller.PaymentController;
import Service.DashboardService;
import Service.RentalOrderService;
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
        }
        
        // Lấy danh sách người dùng (dashboard mặc định)
        List<Account> users = UserController.getAllUsers();
        request.setAttribute("users", users);

        // Thông báo đơn cần xác nhận (PENDING_PAYMENT hoặc PAYMENT_SUBMITTED)
        int pendingCount = RentalOrderService.countOrdersByStatus("PENDING_PAYMENT");
        int verifyingCount = RentalOrderService.countOrdersByStatus("PAYMENT_SUBMITTED");
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("verifyingCount", verifyingCount);
        request.setAttribute("newOrdersCount", pendingCount + verifyingCount);
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(request, response);
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
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
