package servlet;

import Controller.RatingController;
import Controller.RentalOrderController;
import Model.Rating;
import Model.RentalOrder;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class RatingServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("viewRatings".equals(action)) {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            List<Rating> ratings = RatingController.getClothingRatings(clothingID);
            double avgRating = RatingController.getAverageRating(clothingID);
            int totalRatings = RatingController.getTotalRatings(clothingID);
            
            request.setAttribute("ratings", ratings);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("totalRatings", totalRatings);
            request.setAttribute("clothingID", clothingID);
            request.getRequestDispatcher("/WEB-INF/jsp/user/ratings.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");
        
        if ("submitRating".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            
            RentalOrder order = RentalOrderController.getRentalOrderDetails(rentalOrderID);
            
            if (order != null) {
                int ratingID = RatingController.submitRating(rentalOrderID, userID, rating, comment);
                
                if (ratingID > 0) {
                    response.sendRedirect(request.getContextPath() + "/rating?action=viewRatings&clothingID=" + order.getClothingID() + "&success=true");
                } else if (ratingID == -3) {
                    // Manager cannot rate their own product
                    response.sendRedirect(request.getContextPath() + "/user?action=orders&error=manager_cannot_rate");
                } else if (ratingID == -4) {
                    // Order not yet eligible (not COMPLETED)
                    response.sendRedirect(request.getContextPath() + "/rating?action=viewRatings&clothingID=" + order.getClothingID() + "&error=not_completed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/rating?action=viewRatings&clothingID=" + order.getClothingID() + "&error=true");
                }
            }
        }
    }
}
