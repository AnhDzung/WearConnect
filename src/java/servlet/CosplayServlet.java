package servlet;

import Controller.ClothingController;
import DAO.CosplayDetailDAO;
import DAO.RatingDAO;
import Model.Clothing;
import Model.CosplayDetail;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet for handling cosplay-related requests
 * Provides specialized landing page and filtering for cosplay products
 */
public class CosplayServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("[CosplayServlet] doGet called");
        
        String searchType = request.getParameter("searchType");
        String searchValue = request.getParameter("searchValue");
        String sortBy = request.getParameter("sortBy");
        
        List<Clothing> clothingList;
        
        // Get cosplay category products only (status = APPROVED_COSPLAY or ACTIVE)
        if (searchType != null && searchValue != null && !searchValue.isEmpty()) {
            // Handle specific search types for cosplay
            switch (searchType) {
                case "character":
                    clothingList = searchCosplayByCharacter(searchValue);
                    break;
                case "series":
                    clothingList = searchCosplayBySeries(searchValue);
                    break;
                case "type":
                    clothingList = searchCosplayByType(searchValue);
                    break;
                default:
                    clothingList = getAllApprovedCosplay();
                    break;
            }
        } else {
            // Get all approved cosplay products
            clothingList = getAllApprovedCosplay();
        }
        
        // Apply sorting
        if (sortBy != null) {
            switch (sortBy) {
                case "rating":
                    clothingList.sort((a, b) -> {
                        double ratingA = RatingDAO.getAverageRatingForClothing(a.getClothingID());
                        double ratingB = RatingDAO.getAverageRatingForClothing(b.getClothingID());
                        return Double.compare(ratingB, ratingA);
                    });
                    break;
                case "priceAsc":
                    clothingList.sort((a, b) -> Double.compare(a.getHourlyPrice(), b.getHourlyPrice()));
                    break;
                case "priceDesc":
                    clothingList.sort((a, b) -> Double.compare(b.getHourlyPrice(), a.getHourlyPrice()));
                    break;
            }
        }
        
        // Attach cosplay details to each clothing item
        List<CosplayDetail> cosplayDetails = new ArrayList<>();
        for (Clothing clothing : clothingList) {
            CosplayDetail detail = CosplayDetailDAO.getCosplayDetailByClothingID(clothing.getClothingID());
            if (detail != null) {
                cosplayDetails.add(detail);
            }
        }
        
        request.setAttribute("clothingList", clothingList);
        request.setAttribute("cosplayDetails", cosplayDetails);
        request.setAttribute("searchType", searchType);
        request.setAttribute("searchValue", searchValue);
        request.setAttribute("sortBy", sortBy);
        
        request.getRequestDispatcher("/WEB-INF/jsp/user/cosplay.jsp").forward(request, response);
    }
    
    /**
     * Get all cosplay products with APPROVED_COSPLAY status
     */
    private List<Clothing> getAllApprovedCosplay() {
        List<Clothing> allClothing = ClothingController.searchByCategory("Cosplay");
        List<Clothing> approved = new ArrayList<>();
        
        for (Clothing clothing : allClothing) {
            String status = clothing.getClothingStatus();
            // Show APPROVED_COSPLAY or ACTIVE status cosplay items
            if ("APPROVED_COSPLAY".equals(status) || "ACTIVE".equals(status)) {
                approved.add(clothing);
            }
        }
        
        return approved;
    }
    
    /**
     * Search cosplay by character name
     */
    private List<Clothing> searchCosplayByCharacter(String characterName) {
        List<CosplayDetail> details = CosplayDetailDAO.searchByCharacterName(characterName);
        return getApprovedClothingFromDetails(details);
    }
    
    /**
     * Search cosplay by series
     */
    private List<Clothing> searchCosplayBySeries(String series) {
        List<CosplayDetail> details = CosplayDetailDAO.searchBySeries(series);
        return getApprovedClothingFromDetails(details);
    }
    
    /**
     * Search cosplay by type (Anime/Game/Movie)
     */
    private List<Clothing> searchCosplayByType(String type) {
        List<CosplayDetail> details = CosplayDetailDAO.searchByType(type);
        return getApprovedClothingFromDetails(details);
    }
    
    /**
     * Helper method to get approved clothing items from cosplay details
     */
    private List<Clothing> getApprovedClothingFromDetails(List<CosplayDetail> details) {
        List<Clothing> clothingList = new ArrayList<>();
        
        for (CosplayDetail detail : details) {
            Clothing clothing = ClothingController.getClothingDetails(detail.getClothingID());
            if (clothing != null) {
                String status = clothing.getClothingStatus();
                // Only include approved or active cosplay items
                if ("APPROVED_COSPLAY".equals(status) || "ACTIVE".equals(status)) {
                    clothingList.add(clothing);
                }
            }
        }
        
        return clothingList;
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
