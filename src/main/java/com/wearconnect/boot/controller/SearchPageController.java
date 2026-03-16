package com.wearconnect.boot.controller;

import Controller.ClothingController;
import Model.Clothing;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/search")
public class SearchPageController {

    @GetMapping
    public void search(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchType = request.getParameter("type");
        String query = request.getParameter("query");
        List<Clothing> results;

        if ("category".equals(searchType)) {
            results = ClothingController.searchByCategory(query);
        } else if ("style".equals(searchType)) {
            results = ClothingController.searchByStyle(query);
        } else if ("occasion".equals(searchType)) {
            results = ClothingController.searchByOccasion(query);
        } else {
            results = ClothingController.getAllClothing();
        }

        request.setAttribute("searchResults", results);
        request.setAttribute("searchType", searchType);
        request.setAttribute("query", query);
        request.getRequestDispatcher("/WEB-INF/jsp/user/search-results.jsp").forward(request, response);
    }
}
