package servlet;

import Controller.PaymentController;
import Controller.RentalOrderController;
import Model.Payment;
import Model.RentalOrder;
import Model.Account;
import Service.BankTransferService;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.Map;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.io.File;
import java.nio.file.StandardCopyOption;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 15 * 1024 * 1024
)
public class PaymentServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");
            System.out.println("[PaymentServlet] GET request - action: " + action);
            
            // Handle payment status check (for AJAX polling)
            if ("checkStatus".equals(action)) {
                handleCheckStatus(request, response);
                return;
            }
            
            // Handle normal page load
            HttpSession session = request.getSession(true);
            
            // Auto-create test account if not logged in (for testing)
            if (session.getAttribute("account") == null) {
                System.out.println("[PaymentServlet] No session account - creating test account for payment testing");
                Account testAccount = new Account();
                testAccount.setAccountID(3); // Test user ID from database
                testAccount.setUsername("testuser");
                testAccount.setUserRole("User");
                session.setAttribute("account", testAccount);
                session.setAttribute("accountID", 3);
                session.setAttribute("userRole", "User");
                System.out.println("[PaymentServlet] Test account created for session");
            }
            
            String rentalOrderIDParam = request.getParameter("rentalOrderID");
            if (rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) {
                System.out.println("[PaymentServlet] No rentalOrderID - redirecting to rental");
                response.sendRedirect(request.getContextPath() + "/rental");
                return;
            }
            
            int rentalOrderID = Integer.parseInt(rentalOrderIDParam);
            System.out.println("[PaymentServlet] Loading payment for rentalOrderID: " + rentalOrderID);
            
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
            RentalOrder rentalOrder = RentalOrderController.getRentalOrderDetails(rentalOrderID);
            
            System.out.println("[PaymentServlet] Payment: " + (payment != null ? "FOUND" : "NULL"));
            System.out.println("[PaymentServlet] RentalOrder: " + (rentalOrder != null ? "FOUND" : "NULL"));
            
            // Null-safety: ensure rentalOrder exists before proceeding
            if (rentalOrder == null) {
                System.out.println("[PaymentServlet] RentalOrder is NULL - sending 404");
                request.setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendError(404, "Rental order not found");
                return;
            }
            
            request.setAttribute("payment", payment);
            request.setAttribute("rentalOrder", rentalOrder);
            request.setAttribute("rentalOrderID", rentalOrderID);
            System.out.println("[PaymentServlet] Forwarding to payment.jsp");
            request.getRequestDispatcher("/WEB-INF/jsp/user/payment.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            System.err.println("[PaymentServlet] NumberFormatException: " + e.getMessage());
            e.printStackTrace();
            response.sendError(400, "Invalid rental order ID");
        } catch (Exception e) {
            System.err.println("[PaymentServlet] Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendError(500, "Error processing payment: " + e.getMessage());
        }
    }
    
    /**
     * Handle payment status check for AJAX polling
     */
    private void handleCheckStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> jsonResponse = new HashMap<>();
        
        try {
            String rentalOrderIDParam = request.getParameter("rentalOrderID");
            if (rentalOrderIDParam == null || rentalOrderIDParam.isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("error", "Missing rentalOrderID");
                response.getWriter().write(new Gson().toJson(jsonResponse));
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
        } catch (NumberFormatException e) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", "Invalid rental order ID");
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", e.getMessage());
        }
        
        response.getWriter().write(new Gson().toJson(jsonResponse));
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
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
            
            // Validate payment method
            if (!isValidPaymentMethod(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                return;
            }
            
            if ("BANK_TRANSFER".equals(paymentMethod)) {
                // Check if user uploaded payment proof
                Part filePart = request.getPart("paymentProof");
                
                System.out.println("[PaymentServlet] Bank transfer payment - File part: " + (filePart != null ? "exists" : "null"));
                if (filePart != null) {
                    System.out.println("[PaymentServlet] File size: " + filePart.getSize());
                }
                
                if (filePart != null && filePart.getSize() > 0) {
                    // User uploaded payment proof - create payment WITHOUT auto-confirming
                    int paymentID = PaymentController.createPaymentOnly(rentalOrderID, paymentMethod);
                    
                    System.out.println("[PaymentServlet] Created payment ID: " + paymentID);
                    
                    if (paymentID > 0) {
                        // Upload file
                        String proofPath = handleFileUpload(request, rentalOrderID, filePart);
                        
                        System.out.println("[PaymentServlet] File upload result: " + proofPath);
                        
                        if (proofPath != null) {
                            // Update payment with proof image
                            boolean updated = PaymentController.updatePaymentProof(paymentID, proofPath);
                            System.out.println("[PaymentServlet] Payment proof updated: " + updated);
                            // Also store payment proof path directly on the rental order
                            boolean storedOnOrder = Controller.RentalOrderController.setPaymentProofPath(rentalOrderID, proofPath);
                            System.out.println("[PaymentServlet] Stored payment proof on RentalOrder: " + storedOnOrder);
                            
                            // Update order status to PAYMENT_SUBMITTED (waiting admin verification)
                            boolean statusUpdated = RentalOrderController.updateOrderStatus(rentalOrderID, "PAYMENT_SUBMITTED");
                            System.out.println("[PaymentServlet] Order status updated to PAYMENT_SUBMITTED: " + statusUpdated);
                            
                            // Redirect to order detail page with success message
                            response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&paymentSubmitted=true");
                            return;
                        } else {
                            // File upload failed
                            System.err.println("[PaymentServlet] File upload failed");
                            response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=uploadfailed");
                            return;
                        }
                    } else {
                        System.err.println("[PaymentServlet] Failed to create payment");
                        response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                        return;
                    }
                } else {
                    // No file uploaded - create payment and keep as PENDING
                    int paymentID = PaymentController.createPaymentOnly(rentalOrderID, paymentMethod);
                    if (paymentID > 0) {
                        response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&bankTransferPending=true");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                    }
                    return;
                }
            } else {
                // Credit card or other methods - use normal processPayment (auto-confirms)
                int paymentID = PaymentController.processPayment(rentalOrderID, paymentMethod);
                
                if (paymentID > 0) {
                    PaymentController.completePayment(paymentID);
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&paymentSuccess=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                }
                return;
            }
        } else if ("processDeposit".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            String paymentMethod = request.getParameter("paymentMethod");
            
            // Validate payment method
            if (!isValidPaymentMethod(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
                return;
            }
            
            int paymentID = PaymentController.processDepositPayment(rentalOrderID, paymentMethod);
            
            if (paymentID > 0) {
                if ("BANK_TRANSFER".equals(paymentMethod)) {
                    response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&bankTransferPending=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&depositSuccess=true");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/payment?rentalOrderID=" + rentalOrderID + "&error=true");
            }
        } else if ("verifyBankTransfer".equals(action)) {
            // Handle bank transfer verification (for webhook or manual verification)
            int paymentID = Integer.parseInt(request.getParameter("paymentID"));
            String transactionRef = request.getParameter("transactionRef");
            
            boolean verified = BankTransferService.verifyBankTransfer(paymentID, transactionRef);
            
            if (verified) {
                Payment payment = PaymentController.getPaymentDetails(paymentID);
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + payment.getRentalOrderID() + "&paymentSuccess=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/payment?error=true");
            }
        }
    }
    
    /**
     * Validate payment method
     */
    private boolean isValidPaymentMethod(String method) {
        return method != null && (method.equals("CREDIT_CARD") || method.equals("BANK_TRANSFER") || method.equals("CASH"));
    }
    
    /**
     * Handle file upload - extracted as helper method
     */
    private String handleFileUpload(HttpServletRequest request, int rentalOrderID, Part filePart) {
        try {
            // Validate file
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String fileExtension = getFileExtension(fileName);
            
            if (!isValidFileType(fileExtension)) {
                System.err.println("[PaymentServlet] Invalid file type: " + fileExtension);
                return null;
            }
            
            if (filePart.getSize() > 10 * 1024 * 1024) {
                System.err.println("[PaymentServlet] File too large: " + filePart.getSize());
                return null;
            }
            
            // Create uploads directory if doesn't exist
            String appPath = request.getServletContext().getRealPath("");
            String uploadPath = appPath + File.separator + "uploads" + File.separator + "payment-proof";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Generate unique file name
            String uniqueFileName = "payment_" + rentalOrderID + "_" + System.currentTimeMillis() + "." + fileExtension;
            String filePath = uploadPath + File.separator + uniqueFileName;
            
            // Save file
            filePart.write(filePath);
            
            // Return relative path for database storage
            return "uploads/payment-proof/" + uniqueFileName;
            
        } catch (Exception e) {
            System.err.println("[PaymentServlet] Error uploading file: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get file extension
     */
    private String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        return lastDot > 0 ? fileName.substring(lastDot + 1).toLowerCase() : "";
    }
    
    /**
     * Validate file type
     */
    private boolean isValidFileType(String extension) {
        return extension.equals("jpg") || extension.equals("jpeg") || 
               extension.equals("png") || extension.equals("pdf");
    }
}
