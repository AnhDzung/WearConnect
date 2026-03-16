package com.wearconnect.boot.controller;

import DAO.RentalOrderDAO;
import Model.RentalOrder;
import Service.NotificationService;
import Service.ReturnOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import util.RefundCalculationUtil.RefundDetails;

@Controller
@RequestMapping("/return")
public class ReturnPageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountID") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");

        if ("list".equals(action)) {
            List<RentalOrder> readyForReturn = ReturnOrderService.getReadyForReturnOrders(userID);
            request.setAttribute("orders", readyForReturn);
            request.getRequestDispatcher("/WEB-INF/jsp/user/return-list.jsp").forward(request, response);

        } else if ("details".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("id"));
            RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);

            if (order == null || order.getRenterUserID() != userID) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (!"DELIVERED_PENDING_CONFIRMATION".equals(order.getStatus())
                    && !"RENTED".equals(order.getStatus())) {
                request.setAttribute("error", "Đơn hàng này không thể trả lại");
                request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
                return;
            }
            request.setAttribute("order", order);
            request.getRequestDispatcher("/WEB-INF/jsp/user/return-item.jsp").forward(request, response);

        } else if ("refundDetails".equals(action)) {
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

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
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
                String returnStatus = request.getParameter("returnStatus");
                String damagePercentageStr = request.getParameter("damagePercentage");

                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                if (order == null || order.getRenterUserID() != userID) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                double damagePercentage = 0;
                if (damagePercentageStr != null && !damagePercentageStr.isEmpty()) {
                    damagePercentage = Double.parseDouble(damagePercentageStr);
                    damagePercentage = Math.min(1.0, Math.max(0, damagePercentage / 100.0));
                }

                boolean success = ReturnOrderService.processReturn(
                        rentalOrderID, LocalDateTime.now(), returnStatus, damagePercentage);

                if (success) {
                    RentalOrder returnedOrder = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                    if (returnedOrder != null) {
                        String orderCode = "WRC" + String.format("%05d", returnedOrder.getRentalOrderID());
                        String renterName = returnedOrder.getRenterFullName() != null
                                ? returnedOrder.getRenterFullName() : "Khách hàng";
                        NotificationService.createNotification(
                                returnedOrder.getManagerID(),
                                "Khách hàng đang trả hàng",
                                renterName + " đang trả hàng cho đơn " + orderCode
                                + " (" + (returnedOrder.getClothingName() != null
                                        ? returnedOrder.getClothingName()
                                        : "ID: " + returnedOrder.getClothingID())
                                + "). Vui lòng xác nhận khi nhận được hàng.",
                                rentalOrderID);
                    }
                    response.sendRedirect(request.getContextPath() + "/return?action=refundDetails&id=" + rentalOrderID);
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
