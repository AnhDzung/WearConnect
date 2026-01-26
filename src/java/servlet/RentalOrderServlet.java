package servlet;

import Controller.RentalOrderController;
import Controller.PaymentController;
import Model.RentalOrder;
import DAO.ClothingImageDAO;
import DAO.OrderIssueDAO;
import Model.ClothingImage;
import Model.OrderIssue;
import Model.Payment;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@MultipartConfig
public class RentalOrderServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");
        
        // Allow access to booking page when logged in
        if ("booking".equals(action)) {
            if (session == null || session.getAttribute("account") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            try {
                int clothingID = Integer.parseInt(request.getParameter("clothingID"));
                double hourlyPrice = Double.parseDouble(request.getParameter("hourlyPrice"));
                double dailyPrice = Double.parseDouble(request.getParameter("dailyPrice"));
                request.setAttribute("clothingID", clothingID);
                request.setAttribute("hourlyPrice", hourlyPrice);
                request.setAttribute("dailyPrice", dailyPrice);
                
                // Check for error and pass conflicting orders info
                String error = request.getParameter("error");
                if ("notAvailable".equals(error)) {
                    request.setAttribute("error", "notAvailable");
                    List<RentalOrder> conflictingOrders = (List<RentalOrder>) session.getAttribute("conflictingOrders");
                    LocalDateTime requestedStartDate = (LocalDateTime) session.getAttribute("requestedStartDate");
                    LocalDateTime requestedEndDate = (LocalDateTime) session.getAttribute("requestedEndDate");
                    Integer availableQty = (Integer) session.getAttribute("availableQuantity");

                    if (conflictingOrders != null) {
                        request.setAttribute("conflictingOrders", conflictingOrders);
                    }

                    if (requestedStartDate != null) {
                        request.setAttribute("requestedStartDateDate", java.sql.Timestamp.valueOf(requestedStartDate));
                        request.setAttribute("requestedStartDate", requestedStartDate);
                    }
                    if (requestedEndDate != null) {
                        request.setAttribute("requestedEndDateDate", java.sql.Timestamp.valueOf(requestedEndDate));
                        request.setAttribute("requestedEndDate", requestedEndDate);
                    }
                    request.setAttribute("availableQuantity", availableQty != null ? availableQty : 0);

                    // Clear from session after using
                    session.removeAttribute("conflictingOrders");
                    session.removeAttribute("requestedStartDate");
                    session.removeAttribute("requestedEndDate");
                    session.removeAttribute("availableQuantity");
                }
                
                request.getRequestDispatcher("/WEB-INF/jsp/user/booking.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }
        
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int userID = (int) session.getAttribute("accountID");
        
        if ("myOrders".equals(action)) {
            List<RentalOrder> myOrders = RentalOrderController.getMyRentalOrders(userID);
            request.setAttribute("myOrders", myOrders);
            request.getRequestDispatcher("/WEB-INF/jsp/user/my-orders.jsp").forward(request, response);
        } else if ("viewOrder".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("id"));
            RentalOrder order = RentalOrderController.getRentalOrderDetails(rentalOrderID);
            Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
            
            System.out.println("[RentalOrderServlet] Viewing order " + rentalOrderID + " - Status: " + (order != null ? order.getStatus() : "null"));
            
            request.setAttribute("order", order);
            request.setAttribute("payment", payment);
            
            // Load images for the product
            if (order != null) {
                List<ClothingImage> images = ClothingImageDAO.getImagesByClothing(order.getClothingID());
                request.setAttribute("clothingImages", images);
            }
            
            request.getRequestDispatcher("/WEB-INF/jsp/user/order-details.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int userID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");
        
        if ("createOrder".equals(action)) {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            String rentalType = request.getParameter("rentalType");
            String selectedSize = request.getParameter("selectedSize");
            String selectedColorStr = request.getParameter("selectedColor");
            LocalDateTime startDate, endDate;
            
            try {
                if ("hourly".equals(rentalType)) {
                    // Parse datetime-local for hourly rental
                    startDate = LocalDateTime.parse(request.getParameter("startDate"), 
                            DateTimeFormatter.ISO_DATE_TIME);
                    endDate = LocalDateTime.parse(request.getParameter("endDate"), 
                            DateTimeFormatter.ISO_DATE_TIME);
                } else {
                    // Parse date and convert to datetime (midnight) for daily rental
                    String dailyStartDateStr = request.getParameter("dailyStartDate");
                    String dailyEndDateStr = request.getParameter("dailyEndDate");
                    
                    startDate = LocalDateTime.parse(dailyStartDateStr + "T00:00:00");
                    endDate = LocalDateTime.parse(dailyEndDateStr + "T23:59:59");
                }
                
                // Check availability
                if (!RentalOrderController.isAvailable(clothingID, startDate, endDate)) {
                    // Get conflicting orders and available quantity for detailed error message
                    List<RentalOrder> conflictingOrders = RentalOrderController.getConflictingOrders(clothingID, startDate, endDate);
                    int availableQty = RentalOrderController.getAvailableQuantity(clothingID, startDate, endDate);
                    
                    session.setAttribute("conflictingOrders", conflictingOrders);
                    session.setAttribute("requestedStartDate", startDate);
                    session.setAttribute("requestedEndDate", endDate);
                    session.setAttribute("availableQuantity", availableQty);
                    
                    // Redirect back to booking page with error
                    response.sendRedirect(request.getContextPath() + "/rental?action=booking&clothingID=" + clothingID 
                            + "&hourlyPrice=" + request.getParameter("hourlyPrice") 
                            + "&dailyPrice=" + request.getParameter("dailyPrice") 
                            + "&error=notAvailable");
                    return;
                }
                
                if (selectedSize == null || selectedSize.trim().isEmpty()) {
                    throw new IllegalArgumentException("Vui lòng chọn size");
                }

                // Parse color ID if provided
                Integer colorID = null;
                if (selectedColorStr != null && !selectedColorStr.trim().isEmpty()) {
                    try {
                        colorID = Integer.parseInt(selectedColorStr);
                    } catch (NumberFormatException e) {
                        colorID = null;
                    }
                }

                int rentalOrderID = RentalOrderController.createRentalOrder(clothingID, userID, startDate, endDate, selectedSize.trim(), colorID);
                
                if (rentalOrderID > 0) {
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID);
                } else {
                    response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&error=true");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Lỗi khi tạo đơn thuê: " + e.getMessage());
            }
        } else if ("cancelOrder".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            if (RentalOrderController.cancelOrder(rentalOrderID)) {
                response.sendRedirect(request.getContextPath() + "/rental?action=myOrders&success=true");
            }
        } else if ("requestReturn".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            // User requests to mark the order as returned (manager will see status change)
            boolean ok = RentalOrderController.updateOrderStatus(rentalOrderID, "RETURNED");
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnRequested=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnRequested=false");
            }
        } else if ("reportIssue".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            String issueType = request.getParameter("issueType");
            String description = request.getParameter("description");
            
            OrderIssue issue = new OrderIssue(rentalOrderID, userID, issueType, description);
            
            // Handle file upload if present
            try {
                Part filePart = request.getPart("issueImage");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    byte[] fileData = new byte[(int) filePart.getSize()];
                    filePart.getInputStream().read(fileData);
                    
                    String storedName = System.currentTimeMillis() + "_" + fileName;
                    issue.setImagePath(storedName);
                    issue.setImageData(fileData);
                }
            } catch (Exception e) {
                System.out.println("File upload error: " + e.getMessage());
            }
            
            int issueID = OrderIssueDAO.addOrderIssue(issue);
            
            if (issueID > 0) {
                // Auto-update order status to ISSUE
                RentalOrderController.updateOrderStatus(rentalOrderID, "ISSUE");
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&issueReported=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&issueReported=false");
            }
        }
    }
}
