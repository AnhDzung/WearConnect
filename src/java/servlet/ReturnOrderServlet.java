package servlet;

import Service.ReturnOrderService;
import DAO.RentalOrderDAO;
import Model.RentalOrder;
import util.RefundCalculationUtil.RefundDetails;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

/**
 * Servlet for handling return item processing and refund calculation
 * Xử lý trả hàng và tính toán hoàn lại
 */
@WebServlet("/return")
public class ReturnOrderServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountID") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");
        
        if ("list".equals(action)) {
            // Show list of rentals ready for return
            List<RentalOrder> readyForReturn = ReturnOrderService.getReadyForReturnOrders(userID);
            request.setAttribute("orders", readyForReturn);
            request.getRequestDispatcher("/WEB-INF/jsp/user/return-list.jsp").forward(request, response);
            
        } else if ("details".equals(action)) {
            // Show return form for specific order
            int rentalOrderID = Integer.parseInt(request.getParameter("id"));
            RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
            
            if (order == null || order.getRenterUserID() != userID) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            // Check if order is eligible for return
            if (!"DELIVERED_PENDING_CONFIRMATION".equals(order.getStatus()) && 
                !"RENTED".equals(order.getStatus())) {
                request.setAttribute("error", "Đơn hàng này không thể trả lại");
                request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("order", order);
            request.getRequestDispatcher("/WEB-INF/jsp/user/return-item.jsp").forward(request, response);
            
        } else if ("refundDetails".equals(action)) {
            // Show refund details (after return submitted)
            int rentalOrderID = Integer.parseInt(request.getParameter("id"));
            RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
            
            if (order == null || order.getRenterUserID() != userID) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            if (!"RETURNED".equals(order.getStatus())) {
                request.setAttribute("error", "Thông tin trả hàng không khả dụng");
                request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
                return;
            }
            
            RefundDetails refundDetails = ReturnOrderService.getRefundDetails(rentalOrderID);
            request.setAttribute("order", order);
            request.setAttribute("refundDetails", refundDetails);
            request.getRequestDispatcher("/WEB-INF/jsp/user/return-details.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountID") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");
        
        if ("submitReturn".equals(action)) {
            try {
                int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                String returnStatus = request.getParameter("returnStatus"); // NO_DAMAGE, LATE_RETURN, MINOR_DAMAGE, LOST
                String damagePercentageStr = request.getParameter("damagePercentage");
                
                // Validate ownership
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                if (order == null || order.getRenterUserID() != userID) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                
                // Parse damage percentage
                double damagePercentage = 0;
                if (damagePercentageStr != null && !damagePercentageStr.isEmpty()) {
                    damagePercentage = Double.parseDouble(damagePercentageStr);
                    damagePercentage = Math.min(1.0, Math.max(0, damagePercentage / 100.0));
                }
                
                // Process return
                boolean success = ReturnOrderService.processReturn(
                    rentalOrderID,
                    LocalDateTime.now(),
                    returnStatus,
                    damagePercentage
                );
                
                if (success) {
                    // Redirect to refund details
                    response.sendRedirect(request.getContextPath() + 
                        "/return?action=refundDetails&id=" + rentalOrderID);
                } else {
                    request.setAttribute("error", "Không thể xử lý trả hàng. Vui lòng thử lại.");
                    request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
                }
                
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Dữ liệu không hợp lệ");
                request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
            }
        }
    }
}
