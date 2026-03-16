package com.wearconnect.boot.controller;

import Controller.ClothingController;
import DAO.CosplayDetailDAO;
import DAO.RatingDAO;
import Model.Clothing;
import Model.CosplayDetail;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/cosplay")
public class CosplayPageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchType = request.getParameter("searchType");
        String searchValue = request.getParameter("searchValue");
        String sortBy = request.getParameter("sortBy");
        String pageParam = request.getParameter("page");

        int pageSize = 20;
        int currentPage = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try { currentPage = Integer.parseInt(pageParam); } catch (NumberFormatException ignore) { currentPage = 1; }
        }
        if (currentPage < 1) currentPage = 1;

        List<Clothing> clothingList;
        if (searchType != null && searchValue != null && !searchValue.isEmpty()) {
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
            clothingList = getAllApprovedCosplay();
        }

        if (sortBy != null) {
            switch (sortBy) {
                case "rating":
                    clothingList.sort((a, b) -> {
                        double rA = RatingDAO.getAverageRatingForClothing(a.getClothingID());
                        double rB = RatingDAO.getAverageRatingForClothing(b.getClothingID());
                        return Double.compare(rB, rA);
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

        int totalItems = clothingList.size();
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalItems);
        if (fromIndex > toIndex) { fromIndex = 0; toIndex = Math.min(pageSize, totalItems); }
        List<Clothing> pagedList = clothingList.subList(fromIndex, toIndex);

        List<CosplayDetail> cosplayDetails = new ArrayList<>();
        for (Clothing c : pagedList) {
            CosplayDetail detail = CosplayDetailDAO.getCosplayDetailByClothingID(c.getClothingID());
            if (detail != null) cosplayDetails.add(detail);
        }

        request.setAttribute("clothingList", pagedList);
        request.setAttribute("cosplayDetails", cosplayDetails);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("searchType", searchType);
        request.setAttribute("searchValue", searchValue);
        request.setAttribute("sortBy", sortBy);
        request.getRequestDispatcher("/WEB-INF/jsp/user/cosplay.jsp").forward(request, response);
    }

    private List<Clothing> getAllApprovedCosplay() {
        List<Clothing> all = ClothingController.searchByCategory("Cosplay");
        List<Clothing> approved = new ArrayList<>();
        for (Clothing c : all) {
            String status = c.getClothingStatus();
            if ("APPROVED_COSPLAY".equals(status) || "ACTIVE".equals(status)) {
                approved.add(c);
            }
        }
        return approved;
    }

    private List<Clothing> searchCosplayByCharacter(String characterName) {
        List<CosplayDetail> details = CosplayDetailDAO.searchByCharacterName(characterName);
        return getApprovedClothingFromDetails(details);
    }

    private List<Clothing> searchCosplayBySeries(String seriesName) {
        List<CosplayDetail> details = CosplayDetailDAO.searchBySeries(seriesName);
        return getApprovedClothingFromDetails(details);
    }

    private List<Clothing> searchCosplayByType(String type) {
        List<CosplayDetail> details = CosplayDetailDAO.searchByType(type);
        return getApprovedClothingFromDetails(details);
    }

    private List<Clothing> getApprovedClothingFromDetails(List<CosplayDetail> details) {
        List<Clothing> result = new ArrayList<>();
        if (details == null) return result;
        for (CosplayDetail d : details) {
            Clothing c = DAO.ClothingDAO.getClothingByID(d.getClothingID());
            if (c != null) {
                String status = c.getClothingStatus();
                if ("APPROVED_COSPLAY".equals(status) || "ACTIVE".equals(status)) {
                    result.add(c);
                }
            }
        }
        return result;
    }
}
