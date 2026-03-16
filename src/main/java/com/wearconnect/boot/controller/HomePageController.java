package com.wearconnect.boot.controller;

import Controller.ClothingController;
import DAO.RatingDAO;
import Model.Clothing;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomePageController {

    @GetMapping({"/", "/home"})
    public String showHome(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false, defaultValue = "1") int page,
            Model model) {
        int pageSize = 20;
        int currentPage = Math.max(page, 1);

        List<Clothing> products;
        if (query != null && !query.isBlank()) {
            if ("category".equals(type)) {
                products = ClothingController.searchByCategory(query);
            } else if ("style".equals(type)) {
                products = ClothingController.searchByStyle(query);
            } else if ("occasion".equals(type)) {
                products = ClothingController.searchByOccasion(query);
            } else {
                products = ClothingController.searchClothing(query);
            }
        } else {
            products = ClothingController.getAllClothing();
        }

        products.removeIf(product -> (product.getCategory() != null
                && "Cosplay".equalsIgnoreCase(product.getCategory().trim()))
                || !product.isActive()
                || (product.getClothingStatus() != null
                && !"ACTIVE".equalsIgnoreCase(product.getClothingStatus().trim())));

        Map<Integer, Double> avgRatings = new HashMap<>();
        for (Clothing clothing : products) {
            avgRatings.put(clothing.getClothingID(), RatingDAO.getAverageRatingForClothing(clothing.getClothingID()));
        }

        if (sort != null && !sort.isBlank()) {
            products = new ArrayList<>(products);
            if ("rating_desc".equals(sort)) {
                products.sort((left, right) -> Double.compare(
                        avgRatings.getOrDefault(right.getClothingID(), 0.0),
                        avgRatings.getOrDefault(left.getClothingID(), 0.0)));
            } else if ("price_desc".equals(sort)) {
                products.sort((left, right) -> Double.compare(right.getDailyPrice(), left.getDailyPrice()));
            } else if ("price_asc".equals(sort)) {
                products.sort((left, right) -> Double.compare(left.getDailyPrice(), right.getDailyPrice()));
            }
        }

        int totalItems = products.size();
        int totalPages = Math.max((int) Math.ceil(totalItems / (double) pageSize), 1);
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
        model.addAttribute("products", pagedProducts);
        model.addAttribute("avgRatings", avgRatings);
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        return "home";
    }
}