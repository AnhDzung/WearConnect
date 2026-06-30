package com.wearconnect.boot.controller;

import DAO.AccountDAO;
import DAO.ClothingDAO;
import DAO.RatingDAO;
import Model.Account;
import Model.Clothing;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;

@Controller
@RequestMapping("/shop")
public class ShopPageController {

    @GetMapping
    public String viewShop(@RequestParam("id") int shopId, Model model) {
        Account shop = AccountDAO.findById(shopId);
        if (shop == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Shop not found");
        }
        
        double shopRating = RatingDAO.getAverageRatingForRenter(shopId);
        List<Clothing> products = ClothingDAO.getClothingByRenter(shopId);

        model.addAttribute("shop", shop);
        model.addAttribute("shopRating", shopRating);
        model.addAttribute("products", products);

        return "user/shop";
    }
}
