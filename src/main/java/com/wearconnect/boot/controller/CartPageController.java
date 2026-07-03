package com.wearconnect.boot.controller;

import DAO.ClothingDAO;
import DAO.ClothingImageDAO;
import DAO.ColorDAO;
import DAO.CartDAO;
import Model.CartItem;
import Model.Clothing;
import Model.ClothingImage;
import Model.Color;
import Controller.RentalOrderController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/cart")
public class CartPageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleRequest(request, response);
    }

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleRequest(request, response);
    }

    private void handleRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        if (session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "view";
        }

        if ("view".equals(action)) {
            int userID = (int) session.getAttribute("accountID");
            List<CartItem> cart = CartDAO.getCartByAccountID(userID);
            session.setAttribute("cart", cart);
            request.setAttribute("cart", cart);
            request.getRequestDispatcher("/WEB-INF/jsp/user/cart.jsp").forward(request, response);
            return;
        }

        if ("add".equals(action)) {
            try {
                int clothingID = Integer.parseInt(request.getParameter("clothingID"));
                String rentalType = request.getParameter("rentalType");
                String selectedSize = request.getParameter("selectedSize");
                String selectedColorStr = request.getParameter("selectedColor");
                
                LocalDateTime startDate = null;
                LocalDateTime endDate = null;
                if ("hourly".equals(rentalType)) {
                    startDate = LocalDateTime.parse(request.getParameter("startDate"), DateTimeFormatter.ISO_DATE_TIME);
                    endDate = LocalDateTime.parse(request.getParameter("endDate"), DateTimeFormatter.ISO_DATE_TIME);
                } else if ("daily".equals(rentalType)) {
                    startDate = LocalDateTime.parse(request.getParameter("dailyStartDate") + "T00:00:00");
                    endDate = LocalDateTime.parse(request.getParameter("dailyEndDate") + "T23:59:59");
                } else {
                    // For purchase (rentalType == "buy")
                    startDate = LocalDateTime.now();
                    endDate = LocalDateTime.now();
                }

                Clothing clothing = ClothingDAO.getClothingByID(clothingID);
                if (clothing == null) {
                    response.sendRedirect(request.getContextPath() + "/home?error=product_not_found");
                    return;
                }

                Integer colorID = null;
                String colorName = null;
                if (selectedColorStr != null && !selectedColorStr.trim().isEmpty()) {
                    try {
                        colorID = Integer.parseInt(selectedColorStr);
                        Color color = ColorDAO.getColorByID(colorID);
                        if (color != null) {
                            colorName = color.getColorName();
                        }
                    } catch (NumberFormatException e) {
                        colorID = null;
                    }
                }

                // Add to cart list in session
                List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
                if (cart == null) {
                    cart = new ArrayList<>();
                }

                CartItem item = new CartItem();
                item.setClothingID(clothingID);
                item.setClothingName(clothing.getClothingName());
                item.setCategory(clothing.getCategory());
                item.setHourlyPrice(clothing.getHourlyPrice());
                item.setDailyPrice(clothing.getDailyPrice());
                item.setItemValue(clothing.getItemValue());
                item.setRentalType(rentalType);
                item.setStartDate(startDate);
                item.setEndDate(endDate);
                item.setSelectedSize(selectedSize);
                item.setColorID(colorID);
                item.setColorName(colorName);

                List<ClothingImage> imgs = ClothingImageDAO.getImagesByClothing(clothingID);
                if (imgs != null && !imgs.isEmpty()) {
                    item.setImageID(imgs.get(0).getImageID());
                }

                int userID = (int) session.getAttribute("accountID");
                CartDAO.addCartItem(userID, item);

                cart.add(item);
                session.setAttribute("cart", cart);
                response.sendRedirect(request.getContextPath() + "/cart?added=true");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/home?error=add_to_cart_failed");
            }
            return;
        }

        if ("remove".equals(action)) {
            try {
                int cartItemId = Integer.parseInt(request.getParameter("cartItemId"));
                int userID = (int) session.getAttribute("accountID");
                CartDAO.removeCartItem(userID, cartItemId);

                List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
                if (cart != null) {
                    Iterator<CartItem> it = cart.iterator();
                    while (it.hasNext()) {
                        if (it.next().getCartItemId() == cartItemId) {
                            it.remove();
                            break;
                        }
                    }
                    session.setAttribute("cart", cart);
                }
                response.sendRedirect(request.getContextPath() + "/cart?removed=true");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/cart?error=true");
            }
            return;
        }

        if ("checkout".equals(action)) {
            String[] selectedItemIdsStr = request.getParameterValues("selectedItems");
            if (selectedItemIdsStr == null || selectedItemIdsStr.length == 0) {
                response.sendRedirect(request.getContextPath() + "/cart?error=no_items_selected");
                return;
            }

            List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
            if (cart == null || cart.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart?error=empty_cart");
                return;
            }

            int userID = (int) session.getAttribute("accountID");
            List<CartItem> itemsToCheckout = new ArrayList<>();
            
            for (String idStr : selectedItemIdsStr) {
                int itemId = Integer.parseInt(idStr);
                for (CartItem item : cart) {
                    if (item.getCartItemId() == itemId) {
                        itemsToCheckout.add(item);
                        break;
                    }
                }
            }

            // 1. Verify availability for all items first (prevent partial checkouts)
            for (CartItem item : itemsToCheckout) {
                if (!RentalOrderController.isAvailable(item.getClothingID(), item.getStartDate(), item.getEndDate())) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=not_available&conflictItem=" + java.net.URLEncoder.encode(item.getClothingName(), "UTF-8"));
                    return;
                }
            }

            // 2. Create rental orders
            List<Integer> createdOrderIDs = new ArrayList<>();
            try {
                for (CartItem item : itemsToCheckout) {
                    int orderID = RentalOrderController.createRentalOrder(
                            item.getClothingID(),
                            userID,
                            item.getStartDate(),
                            item.getEndDate(),
                            item.getSelectedSize(),
                            item.getColorID()
                    );
                    if (orderID > 0) {
                        createdOrderIDs.add(orderID);
                    } else {
                        throw new Exception("Lỗi khi tạo đơn thuê cho sản phẩm: " + item.getClothingName());
                    }
                }
                
                // Keep items in the cart until the payment is processed successfully.
                // They will be removed in PaymentPageController.java upon payment submission/success.

                // Build comma-separated order IDs
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < createdOrderIDs.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append(createdOrderIDs.get(i));
                }

                response.sendRedirect(request.getContextPath() + "/payment?rentalOrderIDs=" + sb.toString());
            } catch (Exception e) {
                e.printStackTrace();
                // Cancel successfully created orders in this failed batch
                for (int oid : createdOrderIDs) {
                    RentalOrderController.cancelOrder(oid);
                }
                response.sendRedirect(request.getContextPath() + "/cart?error=checkout_failed&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }
}
