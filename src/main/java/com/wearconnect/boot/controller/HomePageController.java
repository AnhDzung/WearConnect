package com.wearconnect.boot.controller;

import DAO.ClothingDAO;
import Model.Clothing;
import java.util.Collections;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomePageController {

    @GetMapping("/home")
    public String showHome(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) List<String> categories,
            @RequestParam(required = false) String dateFrom,
            @RequestParam(required = false) String dateTo,
            @RequestParam(required = false, defaultValue = "1") int page,
            Model model) {
        int pageSize = 20;
        int currentPage = Math.max(page, 1);

        int totalItems = ClothingDAO.countHomeProducts(type, query, categories, dateFrom, dateTo);
        int totalPages = Math.max((int) Math.ceil(totalItems / (double) pageSize), 1);
        if (currentPage > totalPages) currentPage = totalPages;

        List<Clothing> products = ClothingDAO.getHomeProducts(
                type,
                query,
                categories,
                dateFrom,
                dateTo,
                sort,
                currentPage,
                pageSize
        );

        model.addAttribute("products", products);
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("selectedCategories", categories != null ? categories : Collections.emptyList());
        model.addAttribute("dateFrom", dateFrom != null ? dateFrom : "");
        model.addAttribute("dateTo", dateTo != null ? dateTo : "");
        model.addAttribute("currentSort", sort != null ? sort : "newest");
        return "home";
    }
}