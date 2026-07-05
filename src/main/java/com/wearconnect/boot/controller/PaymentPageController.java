package com.wearconnect.boot.controller;

import Controller.PaymentController;
import Controller.RentalOrderController;
import Controller.RatingController;
import Model.Payment;
import Model.RentalOrder;
import Model.Account;
import Model.CartItem;
import DAO.CartDAO;
import Service.BankTransferService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/payment")
public class PaymentPageController {

    private static final Gson GSON = new Gson();

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");

            if ("checkStatus".equals(action)) {
                handleCheckStatus(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            if (session.getAttribute("account") == null) {
                Account testAccount = new Account();
                testAccount.setAccountID(3);
                testAccount.setUsername("testuser");
                testAccount.setUserRole("User");
                session.setAttribute("account", testAccount);
                session.setAttribute("accountID", 3);
                session.setAttribute("userRole", "User");
            }

            String rentalOrderIDParam = request.getParameter("rentalOrderID");
            String rentalOrderIDsParam = request.getParameter("rentalOrderIDs");
            String idsParam = rentalOrderIDsParam != null ? rentalOrderIDsParam : rentalOrderIDParam;

            if (idsParam == null || idsParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/rental");
                return;
            }

            List<Integer> orderIDs = new ArrayList<>();
            for (String part : idsParam.split(",")) {
                if (!part.trim().isEmpty()) {
                    orderIDs.add(Integer.parseInt(part.trim()));
                }
            }

            if (orderIDs.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/rental");
                return;
            }

            int firstOrderID = orderIDs.get(0);
            Payment payment = PaymentController.getPaymentStatus(firstOrderID);
            
            List<RentalOrder> rentalOrders = new ArrayList<>();
            double totalRentPrice = 0.0;
            double totalDepositAmount = 0.0;
            for (int id : orderIDs) {
                RentalOrder order = RentalOrderController.getRentalOrderDetails(id);
                if (order != null) {
                    if ("CANCELLED".equalsIgnoreCase(order.getStatus())) {
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + id + "&error=cancelled");
                        return;
                    }
                    if ("PAYMENT_VERIFIED".equalsIgnoreCase(order.getStatus()) || 
                        "DELIVERED_PENDING_CONFIRMATION".equalsIgnoreCase(order.getStatus()) || 
                        "RENTED".equalsIgnoreCase(order.getStatus()) || 
                        "COMPLETED".equalsIgnoreCase(order.getStatus())) {
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + id + "&paymentSuccess=true");
                        return;
                    }
                    rentalOrders.add(order);
                    totalRentPrice += order.getTotalPrice();
                    totalDepositAmount += order.getAdjustedDepositAmount();
                }
            }

            if (rentalOrders.isEmpty()) {
                request.setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendError(404, "Rental orders not found");
                return;
            }

            int currentUserID = (int) session.getAttribute("accountID");
            Map<String, Object> badge = RatingController.getBadgeForUser(currentUserID);
            request.setAttribute("userBadge", badge);
            request.setAttribute("payment", payment);
            long createdAtMillis = java.sql.Timestamp.valueOf(rentalOrders.get(0).getCreatedAt()).getTime();
            request.setAttribute("createdAtMillis", createdAtMillis);
            request.setAttribute("rentalOrder", rentalOrders.get(0)); // compatibility for single details
            request.setAttribute("rentalOrders", rentalOrders);
            request.setAttribute("totalRentPrice", totalRentPrice);
            request.setAttribute("totalDepositAmount", totalDepositAmount);
            request.setAttribute("rentalOrderID", firstOrderID); // compatibility for single ID logic
            request.setAttribute("rentalOrderIDsStr", idsParam); // List of IDs as string

            boolean isForSale = false;
            if (!rentalOrders.isEmpty()) {
                RentalOrder firstOrder = rentalOrders.get(0);
                Model.Clothing clothing = DAO.ClothingDAO.getClothingByID(firstOrder.getClothingID());
                if (clothing != null) {
                    Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
                    if (owner != null && "Renter".equals(owner.getUserRole())) {
                        isForSale = true;
                    }
                }
            }
            request.setAttribute("isForSale", isForSale);

            // Tính toán số tiền cuối cùng và tạo mã QR động
            double baseAmount = totalRentPrice + totalDepositAmount;
            Integer discount = null;
            try { discount = (Integer) badge.get("discount"); } catch (Exception ex) {}
            double discountPercent = discount != null ? discount.doubleValue() : 0.0;
            double finalAmount = baseAmount * (1.0 - discountPercent / 100.0);
            
            String qrUrl = BankTransferService.generateVietQRUrl(firstOrderID, finalAmount);
            request.setAttribute("qrUrl", qrUrl);
            
            request.getRequestDispatcher("/WEB-INF/jsp/user/payment.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid rental order ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Error processing payment: " + e.getMessage());
        }
    }

    private void handleCheckStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, Object> jsonResponse = new HashMap<>();
        try {
            String rentalOrderIDParam = request.getParameter("rentalOrderID");
            if (rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("error", "Missing rentalOrderID");
                response.getWriter().write(GSON.toJson(jsonResponse));
                return;
            }
            int rentalOrderID = Integer.parseInt(rentalOrderIDParam.split(",")[0].trim());
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
            RentalOrder rentalOrder = RentalOrderController.getRentalOrderDetails(rentalOrderID);
            
            jsonResponse.put("success", true);
            jsonResponse.put("paymentStatus", payment != null ? payment.getPaymentStatus() : "PENDING");
            jsonResponse.put("orderStatus", rentalOrder != null ? rentalOrder.getStatus() : "PENDING_PAYMENT");
            if (payment != null) {
                jsonResponse.put("paymentMethod", payment.getPaymentMethod());
                jsonResponse.put("paymentID", payment.getPaymentID());
            }
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", e.getMessage());
        }
        response.getWriter().write(GSON.toJson(jsonResponse));
    }

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("processPayment".equals(action)) {
            String rentalOrderIDParam = request.getParameter("rentalOrderID");
            String paymentMethod = request.getParameter("paymentMethod");

            if (rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/rental");
                return;
            }

            List<Integer> orderIDs = new ArrayList<>();
            for (String part : rentalOrderIDParam.split(",")) {
                if (!part.trim().isEmpty()) {
                    orderIDs.add(Integer.parseInt(part.trim()));
                }
            }

            if (orderIDs.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/rental");
                return;
            }

            int firstOrderID = orderIDs.get(0);

            if (!isValidPaymentMethod(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderIDParam + "&error=true");
                return;
            }

            int currentUserID = (int) session.getAttribute("accountID");
            Map<String, Object> badge = RatingController.getBadgeForUser(currentUserID);
            Integer discount = null;
            try { discount = (Integer) badge.get("discount"); } catch (Exception ex) { discount = null; }
            double discountPercent = discount != null ? discount.doubleValue() : 0.0;

            if ("BANK_TRANSFER".equals(paymentMethod)) {
                Part filePart = request.getPart("paymentProof");
                if (filePart != null && filePart.getSize() > 0) {
                    String proofPath = buildPaymentProofKey(firstOrderID, filePart);
                    byte[] proofData = readPartBytes(filePart);
                    if (proofPath != null && proofData != null) {
                        for (int id : orderIDs) {
                            RentalOrder ro = RentalOrderController.getRentalOrderDetails(id);
                            double base = ro != null ? (ro.getTotalPrice() + ro.getAdjustedDepositAmount()) : 0.0;
                            double amount = base * (1.0 - discountPercent / 100.0);
                            int paymentID = PaymentController.createPaymentOnly(id, paymentMethod, amount);
                            if (paymentID > 0) {
                                PaymentController.updatePaymentProof(paymentID, proofPath, proofData);
                                RentalOrderController.setPaymentProofPath(id, proofPath, proofData);
                                RentalOrderController.updateOrderStatus(id, "PAYMENT_SUBMITTED");
                                 
                                // Trigger AI verification immediately & asynchronously
                                Service.AIPaymentVerificationService.verifyOrderAsync(id);

                                // Remove matching item from database cart
                                if (ro != null) {
                                    CartDAO.removeCartItemByProduct(currentUserID, ro.getClothingID(), ro.getSelectedSize(), ro.getColorID());
                                }
                            }
                        }
                           // Update session cart
                        List<CartItem> cart = CartDAO.getCartByAccountID(currentUserID);
                        session.setAttribute("cart", cart);

                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderIDParam + "&paymentSubmitted=true");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderIDParam + "&error=uploadfailed");
                    }
                } else {
                    for (int id : orderIDs) {
                        RentalOrder ro2 = RentalOrderController.getRentalOrderDetails(id);
                        double base2 = ro2 != null ? (ro2.getTotalPrice() + ro2.getAdjustedDepositAmount()) : 0.0;
                        double amount2 = base2 * (1.0 - discountPercent / 100.0);
                        PaymentController.createPaymentOnly(id, paymentMethod, amount2);
                    }
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderIDParam + "&bankTransferPending=true");
                }
            } else {
                boolean allSuccess = true;
                for (int id : orderIDs) {
                    RentalOrder ro3 = RentalOrderController.getRentalOrderDetails(id);
                    double base3 = ro3 != null ? (ro3.getTotalPrice() + ro3.getAdjustedDepositAmount()) : 0.0;
                    double amount3 = base3 * (1.0 - discountPercent / 100.0);
                    int paymentID = PaymentController.processPayment(id, paymentMethod, amount3);
                    if (paymentID <= 0) {
                        allSuccess = false;
                    } else {
                        // Remove matching item from database cart
                        if (ro3 != null) {
                            CartDAO.removeCartItemByProduct(currentUserID, ro3.getClothingID(), ro3.getSelectedSize(), ro3.getColorID());
                        }
                    }
                }
                if (allSuccess) {
                    // Update session cart
                    List<CartItem> cart = CartDAO.getCartByAccountID(currentUserID);
                    session.setAttribute("cart", cart);

                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderIDParam + "&paymentSuccess=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderIDParam + "&error=true");
                }
            }
        }
    }

    private String buildPaymentProofKey(int rentalOrderID, Part filePart) {
        try {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = getFileExtension(fileName);
            if (!isValidFileType(ext) || filePart.getSize() > 10 * 1024 * 1024) return null;
            return "payment_" + rentalOrderID + "_" + System.currentTimeMillis() + "." + ext;
        } catch (Exception e) { return null; }
    }

    private byte[] readPartBytes(Part filePart) {
        try (InputStream is = filePart.getInputStream(); ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
            byte[] chunk = new byte[8192];
            int read;
            while ((read = is.read(chunk)) != -1) buffer.write(chunk, 0, read);
            return buffer.toByteArray();
        } catch (Exception e) { return null; }
    }

    private String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        return lastDot > 0 ? fileName.substring(lastDot + 1).toLowerCase() : "";
    }

    private boolean isValidFileType(String ext) {
        return "jpg".equals(ext) || "jpeg".equals(ext) || "png".equals(ext) || "pdf".equals(ext);
    }

    private boolean isValidPaymentMethod(String method) {
        return "BANK_TRANSFER".equals(method) || "CREDIT_CARD".equals(method)
                || "MOMO".equals(method) || "CASH".equals(method);
    }
}
