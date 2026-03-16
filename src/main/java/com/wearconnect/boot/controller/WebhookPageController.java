package com.wearconnect.boot.controller;

import Controller.PaymentController;
import DAO.PaymentDAO;
import Model.Payment;
import com.google.gson.Gson;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/webhook")
public class WebhookPageController {

    @PostMapping
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> jsonResponse = new HashMap<>();

        try {
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String requestBody = sb.toString();

            System.out.println("[WEBHOOK] Received: " + requestBody);

            Gson gson = new Gson();
            Map<String, Object> webhookData = gson.fromJson(requestBody, Map.class);

            String transactionRef = (String) webhookData.get("transactionRef");
            String orderReference = (String) webhookData.get("orderReference");
            double amount = Double.parseDouble(webhookData.get("amount").toString());
            String senderName = (String) webhookData.get("senderName");
            String senderAccount = (String) webhookData.get("senderAccount");

            System.out.println("[WEBHOOK] Processing - Ref: " + transactionRef + ", Amount: " + amount + ", Reference: " + orderReference);

            boolean verified = verifyAndProcessTransfer(transactionRef, orderReference, amount, senderName, senderAccount);

            if (verified) {
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Payment processed successfully");
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("error", "Transfer verification failed");
            }
        } catch (Exception e) {
            System.err.println("[WEBHOOK ERROR] " + e.getMessage());
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("error", e.getMessage());
        }

        response.getWriter().write(new Gson().toJson(jsonResponse));
    }

    private boolean verifyAndProcessTransfer(String transactionRef, String orderReference,
                                             double amount, String senderName, String senderAccount) {
        try {
            if (!orderReference.startsWith("WRC")) {
                System.out.println("[WEBHOOK] Invalid order reference format: " + orderReference);
                return false;
            }

            String orderIdStr = orderReference.substring(3);
            int rentalOrderID = Integer.parseInt(orderIdStr);
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);

            if (payment == null) {
                System.out.println("[WEBHOOK] Payment not found for order: " + rentalOrderID);
                return false;
            }

            if (Math.abs(payment.getAmount() - amount) > 0.01) {
                System.out.println("[WEBHOOK] Amount mismatch. Expected: " + payment.getAmount() + ", Got: " + amount);
                return false;
            }

            if (!"BANK_TRANSFER".equals(payment.getPaymentMethod())) {
                System.out.println("[WEBHOOK] Payment method is not BANK_TRANSFER: " + payment.getPaymentMethod());
                return false;
            }

            if (!"PENDING".equals(payment.getPaymentStatus())) {
                System.out.println("[WEBHOOK] Payment is not PENDING: " + payment.getPaymentStatus());
                return false;
            }

            boolean updated = PaymentDAO.updatePaymentStatus(payment.getPaymentID(), "COMPLETED");
            if (updated) {
                System.out.println("[WEBHOOK] Payment marked as COMPLETED. PaymentID: " + payment.getPaymentID()
                        + ", RentalOrderID: " + rentalOrderID + ", Sender: " + senderName + " (" + senderAccount + ")");
                return true;
            }

            System.out.println("[WEBHOOK] Failed to update payment status");
            return false;
        } catch (NumberFormatException e) {
            System.err.println("[WEBHOOK] Invalid number format: " + e.getMessage());
            return false;
        } catch (Exception e) {
            System.err.println("[WEBHOOK] Error processing transfer: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
