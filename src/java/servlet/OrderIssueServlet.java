package servlet;

import DAO.OrderIssueDAO;
import DAO.RentalOrderDAO;
import DAO.ClothingDAO;
import Model.OrderIssue;
import Model.RentalOrder;
import Model.Clothing;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/orderissue")
public class OrderIssueServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountID") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String rentalOrderIDStr = request.getParameter("rentalOrderID");
        
        if (rentalOrderIDStr != null && !rentalOrderIDStr.isEmpty()) {
            try {
                int rentalOrderID = Integer.parseInt(rentalOrderIDStr);
                
                // Lấy thông tin issue
                OrderIssue issue = OrderIssueDAO.getIssueByRentalOrder(rentalOrderID);
                
                // Lấy thông tin order
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                
                if (issue != null && order != null) {
                    // Lấy thông tin clothing
                    Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                    
                    request.setAttribute("issue", issue);
                    request.setAttribute("order", order);
                    request.setAttribute("clothing", clothing);
                    
                    // Forward to view-issue.jsp based on user role
                    String userRole = (String) session.getAttribute("userRole");
                    if ("Manager".equals(userRole) || "Admin".equals(userRole)) {
                        request.getRequestDispatcher("/WEB-INF/jsp/manager/view-issue.jsp").forward(request, response);
                    } else {
                        // User can also view their issue
                        request.getRequestDispatcher("/WEB-INF/jsp/manager/view-issue.jsp").forward(request, response);
                    }
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
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
