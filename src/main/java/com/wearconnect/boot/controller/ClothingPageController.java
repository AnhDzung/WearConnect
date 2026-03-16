package com.wearconnect.boot.controller;

import Controller.ClothingController;
import DAO.CosplayDetailDAO;
import DAO.RatingDAO;
import Model.Clothing;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;

@Controller
@RequestMapping("/clothing")
public class ClothingPageController {

    @GetMapping(params = {"action=view", "id"})
    public String viewClothing(@RequestParam("id") int clothingId, Model model) {
        Clothing clothing = ClothingController.getClothingDetails(clothingId);
        if (clothing == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found");
        }

        model.addAttribute("clothing", clothing);
        model.addAttribute("images", ClothingController.getClothingImages(clothingId));
        model.addAttribute("avgRating", RatingDAO.getAverageRatingForClothing(clothingId));
        model.addAttribute("ratings", RatingDAO.getRatingsByClothing(clothingId));
        if ("Cosplay".equals(clothing.getCategory())) {
            model.addAttribute("cosplayDetail", CosplayDetailDAO.getCosplayDetailByClothingID(clothingId));
        }
        return "user/clothing-details";
    }

    @GetMapping(params = {"id", "!action"}, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> getClothingSummary(@RequestParam("id") int clothingId) {
        Clothing clothing = ClothingController.getClothingDetails(clothingId);
        if (clothing == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found");
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("clothingID", clothing.getClothingID());
        response.put("clothingName", clothing.getClothingName());
        response.put("hourlyPrice", clothing.getHourlyPrice());
        response.put("dailyPrice", clothing.getDailyPrice());
        response.put("category", clothing.getCategory());
        response.put("style", clothing.getStyle());
        response.put("occasion", clothing.getOccasion());
        return response;
    }
}