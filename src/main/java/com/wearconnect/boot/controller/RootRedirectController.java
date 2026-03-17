package com.wearconnect.boot.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RootRedirectController {

    @GetMapping("/")
    public String root(HttpSession session) {
        String role = session == null ? null : (String) session.getAttribute("userRole");
        if (role != null) {
            role = role.trim();
        }

        if ("Admin".equals(role)) {
            return "redirect:/admin";
        }
        if ("Manager".equals(role)) {
            return "redirect:/manager";
        }
        if ("User".equals(role)) {
            return "redirect:/home";
        }
        return "redirect:/home";
    }
}
