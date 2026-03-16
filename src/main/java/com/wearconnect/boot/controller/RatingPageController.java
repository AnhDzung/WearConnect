package com.wearconnect.boot.controller;

import Controller.RatingController;
import Controller.RentalOrderController;
import Model.Rating;
import Model.RentalOrder;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/rating")
public class RatingPageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("getRatingByOrder".equals(action)) {
            try {
                int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
                Rating r = RatingController.getRatingByOrder(rentalOrderID);
                response.setContentType("application/json;charset=UTF-8");
                response.resetBuffer();
                if (r != null) {
                    String comment = r.getComment() != null ? r.getComment().replace("\"", "\\\"") : "";
                    response.getWriter().write("{\"status\":\"exists\",\"rating\":" + r.getRating()
                            + ",\"comment\":\"" + comment + "\",\"ratingFromUserID\":" + r.getRatingFromUserID() + "}");
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

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        if (session == null || session.getAttribute("account") == null) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.resetBuffer();
                response.getWriter().write("{\"status\":\"error\",\"message\":\"not_logged_in\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return;
        }

        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");

        // Parse JSON body if applicable
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
                    Type t = new TypeToken<Map<String, Object>>() {}.getType();
                    jsonMap = new Gson().fromJson(jsonBody, t);
                    if ((action == null || action.isEmpty()) && jsonMap.get("action") != null) {
                        action = String.valueOf(jsonMap.get("action"));
                    }
                } catch (Exception ignore) {}
            }
        }

        if ("submitRating".equals(action)) {
            try {
                String rentalOrderIDParam = request.getParameter("rentalOrderID");
                if ((rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) && jsonMap != null && jsonMap.get("rentalOrderID") != null) {
                    rentalOrderIDParam = String.valueOf(jsonMap.get("rentalOrderID"));
                }
                String ratingParam = request.getParameter("rating");
                if ((ratingParam == null || ratingParam.isEmpty()) && jsonMap != null && jsonMap.get("rating") != null) {
                    ratingParam = String.valueOf(jsonMap.get("rating"));
                }
                String comment = request.getParameter("comment");
                if ((comment == null || comment.isEmpty()) && jsonMap != null && jsonMap.get("comment") != null) {
                    comment = String.valueOf(jsonMap.get("comment"));
                }

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
                        response.getWriter().write("{\"status\":\"success\",\"ratingID\":" + ratingID + "}");
                    } else if (ratingID == -1) {
                        response.getWriter().write("{\"status\":\"already_rated\"}");
                    } else {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"submit_failed\"}");
                    }
                } else {
                    if (ratingID > 0) {
                        response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&rated=true");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&error=rating_failed");
                    }
                }
            } catch (Exception e) {
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.resetBuffer();
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&error=true");
                }
            }
        }
    }
}
