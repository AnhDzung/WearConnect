package servlet;

import Controller.RatingController;
import Controller.RentalOrderController;
import Model.Rating;
import Model.RentalOrder;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
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
        
        if ("getRatingByOrder".equals(action)) {
            try {
                int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                Rating r = RatingController.getRatingByOrder(rentalOrderID);
                response.setContentType("application/json;charset=UTF-8");
                response.resetBuffer();
                if (r != null) {
                    String json = "{\"status\":\"exists\",\"rating\":" + r.getRating() + ",\"comment\":\"" + (r.getComment() != null ? r.getComment().replace("\"","\\\"") : "") + "\",\"ratingFromUserID\":" + r.getRatingFromUserID() + "}";
                    response.getWriter().write(json);
                } else {
                    response.getWriter().write("{\"status\":\"not_found\"}");
                }
            } catch (Exception e) {
                response.setContentType("application/json;charset=UTF-8");
                response.resetBuffer();
                response.getWriter().write("{\"status\":\"error\"}");
            }
            return;
        }

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
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

                if (session == null || session.getAttribute("account") == null) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.resetBuffer();
                response.getWriter().write("{\"status\":\"error\",\"message\":\"not_logged_in\"}");
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        }

        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");

        // Support JSON POST bodies: if Content-Type is application/json, parse it and use values
        Map<String, Object> jsonMap = null;
        String ct = request.getContentType();
        if (ct != null && ct.contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (java.io.BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) sb.append(line);
            } catch (Exception ignore) {}
            String jsonBody = sb.toString().trim();
            if (!jsonBody.isEmpty()) {
                try {
                    Type t = new TypeToken<Map<String, Object>>(){}.getType();
                    jsonMap = new Gson().fromJson(jsonBody, t);
                    if ((action == null || action.isEmpty()) && jsonMap.get("action") != null) {
                        action = String.valueOf(jsonMap.get("action"));
                    }
                } catch (Exception ignore) {}
            }
        }
        
        if ("submitRating".equals(action)) {
            try {
                // read params from form or JSON body
                String rentalOrderIDParam = request.getParameter("rentalOrderID");
                if ((rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) && jsonMap != null && jsonMap.get("rentalOrderID") != null) rentalOrderIDParam = String.valueOf(jsonMap.get("rentalOrderID"));
                String ratingParam = request.getParameter("rating");
                if ((ratingParam == null || ratingParam.isEmpty()) && jsonMap != null && jsonMap.get("rating") != null) ratingParam = String.valueOf(jsonMap.get("rating"));
                String comment = request.getParameter("comment");
                if ((comment == null || comment.isEmpty()) && jsonMap != null && jsonMap.get("comment") != null) comment = String.valueOf(jsonMap.get("comment"));

                int rentalOrderID = Integer.parseInt(rentalOrderIDParam);
                int rating = Integer.parseInt(ratingParam);

                RentalOrder order = RentalOrderController.getRentalOrderDetails(rentalOrderID);

                    if (order == null) {
                    if (isAjax) {
                        response.setContentType("application/json;charset=UTF-8");
                        response.resetBuffer();
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"order_not_found\"}");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=order_not_found");
                    }
                    return;
                }

                int ratingID = RatingController.submitRating(rentalOrderID, userID, rating, comment);
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.resetBuffer();
                    if (ratingID > 0) {
                        response.getWriter().write("{\"status\":\"success\"}");
                    } else if (ratingID == -3) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"manager_cannot_rate\"}");
                    } else if (ratingID == -4) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"not_completed\"}");
                    } else {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"unknown\"}");
                    }
                } else {
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
                } catch (NumberFormatException nfe) {
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.resetBuffer();
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"invalid_parameters\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=invalid_parameters");
                }
                return;
            } catch (Exception ex) {
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.resetBuffer();
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"server_error\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=server_error");
                }
                return;
            }
        }
        // If we reach here, action was missing or not recognized
        if (isAjax) {
            response.setContentType("application/json;charset=UTF-8");
            response.resetBuffer();
            response.getWriter().write("{\"status\":\"error\",\"message\":\"invalid_action\"}");
        } else {
            response.sendRedirect(request.getContextPath() + "/manager?action=orders&error=invalid_action");
        }
    }
}
