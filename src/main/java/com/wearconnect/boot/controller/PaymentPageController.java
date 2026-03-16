package com.wearconnect.boot.controller;

import Controller.PaymentController;
import Controller.RentalOrderController;
import Controller.RatingController;
import Model.Payment;
import Model.RentalOrder;
import Model.Account;
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
            if (rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/rental");
                return;
            }

            int rentalOrderID = Integer.parseInt(rentalOrderIDParam);
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
            RentalOrder rentalOrder = RentalOrderController.getRentalOrderDetails(rentalOrderID);

            if (rentalOrder == null) {
                request.setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendError(404, "Rental order not found");
                return;
            }

            int currentUserID = (int) session.getAttribute("accountID");
            Map<String, Object> badge = RatingController.getBadgeForUser(currentUserID);
            request.setAttribute("userBadge", badge);
            request.setAttribute("payment", payment);
            request.setAttribute("rentalOrder", rentalOrder);
            request.setAttribute("rentalOrderID", rentalOrderID);
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
            int rentalOrderID = Integer.parseInt(rentalOrderIDParam);
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
            if (payment != null) {
                jsonResponse.put("success", true);
                jsonResponse.put("paymentStatus", payment.getPaymentStatus());
                jsonResponse.put("paymentMethod", payment.getPaymentMethod());
                jsonResponse.put("paymentID", payment.getPaymentID());
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("error", "Payment not found");
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
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            String paymentMethod = request.getParameter("paymentMethod");

            if (!isValidPaymentMethod(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
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
                    RentalOrder ro = RentalOrderController.getRentalOrderDetails(rentalOrderID);
                    double base = ro != null ? (ro.getTotalPrice() + ro.getAdjustedDepositAmount()) : 0.0;
                    double amount = base * (1.0 - discountPercent / 100.0);
                    int paymentID = PaymentController.createPaymentOnly(rentalOrderID, paymentMethod, amount);
                    if (paymentID > 0) {
                        String proofPath = buildPaymentProofKey(rentalOrderID, filePart);
                        byte[] proofData = readPartBytes(filePart);
                        if (proofPath != null && proofData != null) {
                            PaymentController.updatePaymentProof(paymentID, proofPath, proofData);
                            RentalOrderController.setPaymentProofPath(rentalOrderID, proofPath, proofData);
                            RentalOrderController.updateOrderStatus(rentalOrderID, "PAYMENT_SUBMITTED");
                            response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&paymentSubmitted=true");
                        } else {
                            response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=uploadfailed");
                        }
                    } else {
                        response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                    }
                } else {
                    RentalOrder ro2 = RentalOrderController.getRentalOrderDetails(rentalOrderID);
                    double base2 = ro2 != null ? (ro2.getTotalPrice() + ro2.getAdjustedDepositAmount()) : 0.0;
                    double amount2 = base2 * (1.0 - discountPercent / 100.0);
                    int paymentID = PaymentController.createPaymentOnly(rentalOrderID, paymentMethod, amount2);
                    if (paymentID > 0) {
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&bankTransferPending=true");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                    }
                }
            } else {
                RentalOrder ro3 = RentalOrderController.getRentalOrderDetails(rentalOrderID);
                double base3 = ro3 != null ? (ro3.getTotalPrice() + ro3.getAdjustedDepositAmount()) : 0.0;
                double amount3 = base3 * (1.0 - discountPercent / 100.0);
                int paymentID = PaymentController.processPayment(rentalOrderID, paymentMethod, amount3);
                if (paymentID > 0) {
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&paymentSuccess=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
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
