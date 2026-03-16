package com.wearconnect.boot.controller;

import DAO.ClothingDAO;
import DAO.OrderIssueDAO;
import DAO.RentalOrderDAO;
import Model.Clothing;
import Model.OrderIssue;
import Model.RentalOrder;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/orderissue")
public class OrderIssuePageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountID") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String rentalOrderIDStr = request.getParameter("rentalOrderID");
        if (rentalOrderIDStr != null && !rentalOrderIDStr.isEmpty()) {
            try {
                int rentalOrderID = Integer.parseInt(rentalOrderIDStr);
                OrderIssue issue = OrderIssueDAO.getIssueByRentalOrder(rentalOrderID);
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);

                if (issue != null && order != null) {
                    int currentUserID = (int) session.getAttribute("accountID");
                    String userRole = (String) session.getAttribute("userRole");
                    boolean isAdmin = "Admin".equals(userRole);
                    boolean isManager = "Manager".equals(userRole);
                    boolean canView = isAdmin
                            || (isManager && order.getManagerID() == currentUserID)
                            || order.getRenterUserID() == currentUserID;

                    if (!canView) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }

                    Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                    request.setAttribute("issue", issue);
                    request.setAttribute("order", order);
                    request.setAttribute("clothing", clothing);
                    request.getRequestDispatcher("/WEB-INF/jsp/manager/view-issue.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&error=issue_not_found");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&error=invalid_id");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/rental?action=myOrders");
        }
    }

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleGet(request, response);
    }
}
