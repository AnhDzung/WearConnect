package servlet;

import Controller.ClothingController;
import DAO.RatingDAO;
import Model.Clothing;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HomeServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get search parameters if any
        String type = request.getParameter("type");
        String query = request.getParameter("query");
        String sort = request.getParameter("sort");
        String pageParam = request.getParameter("page");

        int pageSize = 20;
        int currentPage = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignore) {
                currentPage = 1;
            }
        }
        if (currentPage < 1) {
            currentPage = 1;
        }
        
        List<Clothing> products;
        
        if (query != null && !query.isEmpty()) {
            if ("category".equals(type)) {
                products = ClothingController.searchByCategory(query);
            } else if ("style".equals(type)) {
                products = ClothingController.searchByStyle(query);
            } else if ("occasion".equals(type)) {
                products = ClothingController.searchByOccasion(query);
            } else {
                // Search by name (default when type is empty)
                products = ClothingController.searchClothing(query);
            }
        } else {
            // Get all active clothing from all renters/managers
            products = ClothingController.getAllClothing();
        }
        
        // Remove cosplay items and inactive items from home listing
        products.removeIf(p -> (p.getCategory() != null && "Cosplay".equalsIgnoreCase(p.getCategory().trim()))
            || !p.isActive()
            || (p.getClothingStatus() != null && !"ACTIVE".equalsIgnoreCase(p.getClothingStatus().trim())));

        // Calculate average ratings
        Map<Integer, Double> avgRatings = new HashMap<>();
        for (Clothing c : products) {
            avgRatings.put(c.getClothingID(), RatingDAO.getAverageRatingForClothing(c.getClothingID()));
        }
        
        // Apply sorting
        if (sort != null && !sort.isEmpty()) {
            products = new ArrayList<>(products);
            if ("rating_desc".equals(sort)) {
                // Sort by rating descending
                products.sort((a, b) -> {
                    double ratingA = avgRatings.getOrDefault(a.getClothingID(), 0.0);
                    double ratingB = avgRatings.getOrDefault(b.getClothingID(), 0.0);
                    return Double.compare(ratingB, ratingA);
                });
            } else if ("price_desc".equals(sort)) {
                // Sort by daily price descending
                products.sort((a, b) -> Double.compare(b.getDailyPrice(), a.getDailyPrice()));
            } else if ("price_asc".equals(sort)) {
                // Sort by daily price ascending
                products.sort((a, b) -> Double.compare(a.getDailyPrice(), b.getDailyPrice()));
            }
        }
        
        // Pagination
        int totalItems = products.size();
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages == 0) {
            totalPages = 1;
        }
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }
        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalItems);
        if (fromIndex > toIndex) {
            fromIndex = 0;
            toIndex = Math.min(pageSize, totalItems);
        }
        List<Clothing> pagedProducts = products.subList(fromIndex, toIndex);

        request.setAttribute("products", pagedProducts);
        request.setAttribute("avgRatings", avgRatings);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/WEB-INF/jsp/home.jsp").forward(request, response);
    }
}
