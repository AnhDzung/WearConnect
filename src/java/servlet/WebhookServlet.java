package servlet;

import Controller.PaymentController;
import Model.Payment;
import Service.BankTransferService;
import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.BufferedReader;
import java.util.HashMap;
import java.util.Map;

/**
 * Webhook receiver for MB Bank transfer notifications
 * Receives transfer notifications and updates payment status
 */
public class WebhookServlet extends HttpServlet {
    
    private static final String WEBHOOK_SECRET = "your-secret-key"; // Should be stored in config
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> jsonResponse = new HashMap<>();
        
        try {
            // Read request body
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String requestBody = sb.toString();
            
            System.out.println("[WEBHOOK] Received: " + requestBody);
            
            // Parse JSON webhook data
            Gson gson = new Gson();
            Map<String, Object> webhookData = gson.fromJson(requestBody, Map.class);
            
            // Validate webhook signature (optional but recommended)
            // String signature = request.getHeader("X-Signature");
            // if (!validateSignature(requestBody, signature)) {
            //     jsonResponse.put("success", false);
            //     jsonResponse.put("error", "Invalid signature");
            //     response.getWriter().write(gson.toJson(jsonResponse));
            //     return;
            // }
            
            // Extract webhook data
            String transactionRef = (String) webhookData.get("transactionRef");
            String orderReference = (String) webhookData.get("orderReference");
            double amount = Double.parseDouble(webhookData.get("amount").toString());
            String senderName = (String) webhookData.get("senderName");
            String senderAccount = (String) webhookData.get("senderAccount");
            String transactionTime = (String) webhookData.get("transactionTime");
            
            System.out.println("[WEBHOOK] Processing - Ref: " + transactionRef + ", Amount: " + amount + ", Reference: " + orderReference);
            
            // Validate and process
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
    
    /**
     * Verify transfer and update payment status
     * Extract rentalOrderID from orderReference (format: WRCXXXXX)
     */
    private boolean verifyAndProcessTransfer(String transactionRef, String orderReference, 
                                            double amount, String senderName, String senderAccount) {
        try {
            // Extract rental order ID from reference (e.g., "WRC00009" -> 9)
            if (!orderReference.startsWith("WRC")) {
                System.out.println("[WEBHOOK] Invalid order reference format: " + orderReference);
                return false;
            }
            
            String orderIdStr = orderReference.substring(3);
            int rentalOrderID = Integer.parseInt(orderIdStr);
            
            // Get payment record
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
            
            if (payment == null) {
                System.out.println("[WEBHOOK] Payment not found for order: " + rentalOrderID);
                return false;
            }
            
            // Verify amount matches
            if (Math.abs(payment.getAmount() - amount) > 0.01) {
                System.out.println("[WEBHOOK] Amount mismatch. Expected: " + payment.getAmount() + ", Got: " + amount);
                return false;
            }
            
            // Verify payment method is BANK_TRANSFER
            if (!payment.getPaymentMethod().equals("BANK_TRANSFER")) {
                System.out.println("[WEBHOOK] Payment method is not BANK_TRANSFER: " + payment.getPaymentMethod());
                return false;
            }
            
            // Verify payment is still PENDING
            if (!payment.getPaymentStatus().equals("PENDING")) {
                System.out.println("[WEBHOOK] Payment is not PENDING: " + payment.getPaymentStatus());
                return false;
            }
            
            // Update payment status to COMPLETED
            boolean updated = PaymentDAO.updatePaymentStatus(payment.getPaymentID(), "COMPLETED");
            
            if (updated) {
                System.out.println("[WEBHOOK] Payment marked as COMPLETED. PaymentID: " + payment.getPaymentID() + 
                                 ", RentalOrderID: " + rentalOrderID + ", Sender: " + senderName + " (" + senderAccount + ")");
                return true;
            } else {
                System.out.println("[WEBHOOK] Failed to update payment status");
                return false;
            }
            
        } catch (NumberFormatException e) {
            System.err.println("[WEBHOOK] Invalid number format: " + e.getMessage());
            return false;
        } catch (Exception e) {
            System.err.println("[WEBHOOK] Error processing transfer: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Validate webhook signature (recommended for production)
     */
    private boolean validateSignature(String body, String signature) {
        // Implement HMAC-SHA256 validation here
        // String expectedSignature = HmacSHA256(body, WEBHOOK_SECRET);
        // return expectedSignature.equals(signature);
        return true; // TODO: Implement in production
    }
}
