package com.wearconnect.boot.controller;

import Controller.PaymentController;
import Controller.RentalOrderController;
import DAO.ClothingDAO;
import DAO.ClothingImageDAO;
import DAO.OrderIssueDAO;
import DAO.RentalOrderDAO;
import Model.Clothing;
import Model.ClothingImage;
import Model.OrderIssue;
import Model.Payment;
import Model.RentalOrder;
import Service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/rental")
public class RentalPageController {

    @GetMapping(value = "/validateVoucher", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> validateVoucher(@RequestParam("code") String code, @RequestParam("totalPrice") double totalPrice) {
        Map<String, Object> result = new HashMap<>();
        if (code == null || code.trim().isEmpty()) {
            result.put("valid", false);
            result.put("message", "Mã voucher không hợp lệ.");
            return result;
        }

        Model.Voucher voucher = DAO.VoucherDAO.getVoucherByCode(code.trim());
        if (voucher == null) {
            result.put("valid", false);
            result.put("message", "Voucher không tồn tại.");
            return result;
        }

        if (!voucher.isActive()) {
            result.put("valid", false);
            result.put("message", "Voucher đã bị khóa hoặc hết hiệu lực.");
            return result;
        }

        LocalDateTime now = LocalDateTime.now();
        if (voucher.getStartDate() != null && voucher.getStartDate().isAfter(now)) {
            result.put("valid", false);
            result.put("message", "Voucher chưa đến thời gian áp dụng.");
            return result;
        }

        if (voucher.getEndDate() != null && voucher.getEndDate().isBefore(now)) {
            result.put("valid", false);
            result.put("message", "Voucher đã hết hạn.");
            return result;
        }

        if (totalPrice < voucher.getMinOrderValue()) {
            result.put("valid", false);
            java.text.DecimalFormat df = new java.text.DecimalFormat("#,###");
            result.put("message", "Đơn hàng tối thiểu " + df.format(voucher.getMinOrderValue()) + " đ để áp dụng voucher này.");
            return result;
        }

        result.put("valid", true);
        result.put("voucherCode", voucher.getVoucherCode());
        result.put("discountType", voucher.getDiscountType());
        result.put("discountValue", voucher.getDiscountValue());
        if (voucher.getMaxDiscountAmount() != null) {
            result.put("maxDiscountAmount", voucher.getMaxDiscountAmount());
        }
        return result;
    }

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");

        if ("booking".equals(action)) {
            if (session == null || session.getAttribute("account") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            try {
                int clothingID = Integer.parseInt(request.getParameter("clothingID"));
                String hourlyPriceStr = request.getParameter("hourlyPrice");
                double hourlyPrice = (hourlyPriceStr == null || hourlyPriceStr.trim().isEmpty()) ? 0 : Double.parseDouble(hourlyPriceStr);
                String dailyPriceStr = request.getParameter("dailyPrice");
                double dailyPrice = (dailyPriceStr == null || dailyPriceStr.trim().isEmpty()) ? 0 : Double.parseDouble(dailyPriceStr);
                request.setAttribute("clothingID", clothingID);
                request.setAttribute("hourlyPrice", hourlyPrice);
                request.setAttribute("dailyPrice", dailyPrice);

                Clothing clothing = ClothingDAO.getClothingByID(clothingID);
                request.setAttribute("itemValue", clothing != null ? clothing.getItemValue() : 0);

                String error = request.getParameter("error");
                if ("notAvailable".equals(error)) {
                    request.setAttribute("error", "notAvailable");
                    List<RentalOrder> conflictingOrders = (List<RentalOrder>) session.getAttribute("conflictingOrders");
                    LocalDateTime requestedStartDate = (LocalDateTime) session.getAttribute("requestedStartDate");
                    LocalDateTime requestedEndDate = (LocalDateTime) session.getAttribute("requestedEndDate");
                    Integer availableQty = (Integer) session.getAttribute("availableQuantity");
                    if (conflictingOrders != null) request.setAttribute("conflictingOrders", conflictingOrders);
                    if (requestedStartDate != null) {
                        request.setAttribute("requestedStartDateDate", java.sql.Timestamp.valueOf(requestedStartDate));
                        request.setAttribute("requestedStartDate", requestedStartDate);
                    }
                    if (requestedEndDate != null) {
                        request.setAttribute("requestedEndDateDate", java.sql.Timestamp.valueOf(requestedEndDate));
                        request.setAttribute("requestedEndDate", requestedEndDate);
                    }
                    request.setAttribute("availableQuantity", availableQty != null ? availableQty : 0);
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

        try {
            int removed = Service.RentalOrderService.expirePendingPaymentsInMinutes(30);
            if (removed > 0) System.out.println("[RentalPageController] Expired PENDING_PAYMENT orders (30 mins): " + removed);
        } catch (Exception e) {
            System.out.println("[RentalPageController] Error expiring pending payments: " + e.getMessage());
        }

        int userID = (int) session.getAttribute("accountID");

        if ("myOrders".equals(action)) {
            String filter = request.getParameter("filter");
            if (filter == null || filter.trim().isEmpty()) {
                filter = "confirmed";
            } else {
                filter = filter.trim().toLowerCase();
            }

            List<RentalOrder> myOrders = RentalOrderController.getMyRentalOrders(userID);
            if (myOrders != null) {
                if ("cancelled".equals(filter)) {
                    myOrders.removeIf(ro -> !"CANCELLED".equalsIgnoreCase(ro.getStatus()));
                } else {
                    myOrders.removeIf(ro -> "CANCELLED".equalsIgnoreCase(ro.getStatus()));
                }
            }
            request.setAttribute("myOrders", myOrders);
            request.setAttribute("activeFilter", filter);
            request.getRequestDispatcher("/WEB-INF/jsp/user/my-orders.jsp").forward(request, response);
        } else if ("viewOrder".equals(action)) {
            String idsParam = request.getParameter("id");
            if (idsParam != null && idsParam.contains(",")) {
                List<RentalOrder> orderList = new ArrayList<>();
                List<Model.Clothing> clothingList = new ArrayList<>();
                List<List<Model.ClothingImage>> imagesList = new ArrayList<>();
                
                String[] idParts = idsParam.split(",");
                for (String part : idParts) {
                    if (!part.trim().isEmpty()) {
                        try {
                            int orderId = Integer.parseInt(part.trim());
                            RentalOrder ord = RentalOrderController.getRentalOrderDetails(orderId);
                            if (ord != null) {
                                orderList.add(ord);
                                clothingList.add(ClothingDAO.getClothingByID(ord.getClothingID()));
                                imagesList.add(ClothingImageDAO.getImagesByClothing(ord.getClothingID()));
                            }
                        } catch (NumberFormatException e) {
                            e.printStackTrace();
                        }
                    }
                }
                
                request.setAttribute("isMultiple", true);
                request.setAttribute("orderList", orderList);
                request.setAttribute("clothingList", clothingList);
                request.setAttribute("imagesList", imagesList);
                
                if (!orderList.isEmpty()) {
                    request.setAttribute("order", orderList.get(0));
                    request.setAttribute("payment", PaymentController.getPaymentStatus(orderList.get(0).getRentalOrderID()));
                    Model.Clothing firstClothing = clothingList.get(0);
                    request.setAttribute("clothing", firstClothing);
                    request.setAttribute("clothingImages", imagesList.get(0));
                    
                    boolean isForSale = false;
                    if (firstClothing != null) {
                        Model.Account owner = DAO.AccountDAO.findById(firstClothing.getRenterID());
                        if (owner != null && "Seller".equals(owner.getUserRole())) {
                            isForSale = true;
                        }
                    }
                    request.setAttribute("isForSale", isForSale);
                }
            } else {
                try {
                    int rentalOrderID = Integer.parseInt(idsParam);
                    RentalOrder order = RentalOrderController.getRentalOrderDetails(rentalOrderID);
                    Payment payment = PaymentController.getPaymentStatus(rentalOrderID);
                    request.setAttribute("order", order);
                    request.setAttribute("payment", payment);
                    if (order != null) {
                        Model.Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                        request.setAttribute("clothing", clothing);
                        request.setAttribute("clothingImages", ClothingImageDAO.getImagesByClothing(order.getClothingID()));
                        
                        boolean isForSale = false;
                        if (clothing != null) {
                            Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
                            if (owner != null && "Seller".equals(owner.getUserRole())) {
                                isForSale = true;
                            }
                        }
                        request.setAttribute("isForSale", isForSale);
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/WEB-INF/jsp/user/order-details.jsp").forward(request, response);
        }
    }

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response)
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

                if (!RentalOrderController.isAvailable(clothingID, startDate, endDate)) {
                    session.setAttribute("conflictingOrders", RentalOrderController.getConflictingOrders(clothingID, startDate, endDate));
                    session.setAttribute("requestedStartDate", startDate);
                    session.setAttribute("requestedEndDate", endDate);
                    session.setAttribute("availableQuantity", RentalOrderController.getAvailableQuantity(clothingID, startDate, endDate));
                    response.sendRedirect(request.getContextPath() + "/rental?action=booking&clothingID=" + clothingID
                            + "&hourlyPrice=" + request.getParameter("hourlyPrice")
                            + "&dailyPrice=" + request.getParameter("dailyPrice")
                            + "&error=notAvailable");
                    return;
                }

                if (selectedSize == null || selectedSize.trim().isEmpty()) throw new IllegalArgumentException("Vui lòng chọn size phù hợp");
                selectedSize = selectedSize.trim();

                Integer colorID = null;
                if (selectedColorStr != null && !selectedColorStr.trim().isEmpty()) {
                    try { colorID = Integer.parseInt(selectedColorStr); } catch (NumberFormatException e) { colorID = null; }
                }

                String voucherCode = request.getParameter("voucherCode");
                int rentalOrderID = RentalOrderController.createRentalOrder(clothingID, userID, startDate, endDate, selectedSize, colorID, voucherCode);
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
            boolean ok = RentalOrderController.updateOrderStatus(rentalOrderID, "RETURN_REQUESTED");
            if (ok) {
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                if (order != null) {
                    String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                    String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                    NotificationService.createNotification(order.getManagerID(), "Khách hàng yêu cầu trả hàng",
                            "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Khách hàng "
                            + (order.getRenterFullName() != null ? order.getRenterFullName() : "ID: " + order.getRenterUserID())
                            + " yêu cầu trả hàng. Vui lòng chọn phương thức nhận hàng.", rentalOrderID);
                }
            }
            response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&returnRequested=" + ok);

        } else if ("submitReturnTracking".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            String returnTrackingNumber = request.getParameter("returnTrackingNumber");
            boolean updated = RentalOrderDAO.updateReturnTrackingNumber(rentalOrderID, returnTrackingNumber);
            if (updated) {
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                if (order != null) {
                    String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                    String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                    NotificationService.createNotification(order.getManagerID(), "Khách hàng đã gửi hàng trả",
                            "Đơn hàng " + orderCode + " (" + clothingInfo + ") - Khách hàng đã gửi hàng trả về. Mã vận đơn: " + returnTrackingNumber + ".", rentalOrderID);
                }
            }
            response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&trackingSubmitted=" + updated);

        } else if ("reportIssue".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            String issueType = request.getParameter("issueType");
            String description = request.getParameter("description");
            OrderIssue issue = new OrderIssue(rentalOrderID, userID, issueType, description);
            try {
                Part filePart = request.getPart("issueImage");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    byte[] fileData = new byte[(int) filePart.getSize()];
                    filePart.getInputStream().read(fileData);
                    issue.setImagePath(System.currentTimeMillis() + "_" + fileName);
                    issue.setImageData(fileData);
                }
            } catch (Exception e) {
                System.out.println("File upload error: " + e.getMessage());
            }
            int issueID = OrderIssueDAO.addOrderIssue(issue);
            if (issueID > 0) {
                RentalOrderController.updateOrderStatus(rentalOrderID, "ISSUE");
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                if (order != null) {
                    String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                    String clothingName = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                    NotificationService.createNotification(order.getManagerID(), "Sản phẩm có vấn đề",
                            "Đơn hàng " + orderCode + " (" + clothingName + ") có vấn đề được báo cáo. Vui lòng kiểm tra.", rentalOrderID);
                }
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&issueReported=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&issueReported=false");
            }

        } else if ("confirmReceipt".equals(action)) {
            int rentalOrderID = Integer.parseInt(request.getParameter("rentalOrderID"));
            try {
                Part filePart = request.getPart("receivedImage");
                String proofPath = null;
                byte[] proofData = null;
                if (filePart != null && filePart.getSize() > 0) {
                    proofPath = buildReceiptProofKey(rentalOrderID, filePart);
                    proofData = readPartBytes(filePart);
                }
                RentalOrderController.setReceivedProofPath(rentalOrderID, proofPath, proofData);
                
                RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
                boolean isForSale = false;
                if (order != null) {
                    Model.Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                    if (clothing != null) {
                        Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
                        if (owner != null && "Seller".equals(owner.getUserRole())) {
                            isForSale = true;
                        }
                    }
                }
                
                String nextStatus = isForSale ? "COMPLETED" : "RENTED";
                boolean ok = RentalOrderController.updateOrderStatus(rentalOrderID, nextStatus);
                if (ok) {
                    if (order != null) {
                        String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                        String clothingInfo = order.getClothingName() != null ? order.getClothingName() : "ID: " + order.getClothingID();
                        NotificationService.createNotification(order.getManagerID(), "Đơn hàng đã giao thành công",
                                "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã được giao thành công.", rentalOrderID);
                        NotificationService.createNotification(order.getRenterUserID(), "Xác nhận nhận hàng thành công",
                                "Bạn đã xác nhận nhận đơn hàng " + orderCode + " (" + clothingInfo + ").", rentalOrderID);
                    }
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&received=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + rentalOrderID + "&received=false");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/rental?action=viewOrder&id=" + request.getParameter("rentalOrderID") + "&received=false");
            }
        }
    }

    private String buildReceiptProofKey(int rentalOrderID, Part filePart) {
        try {
            String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = getFileExtension(fileName);
            if (!isValidFileType(ext) || filePart.getSize() > 5 * 1024 * 1024) return null;
            return "received_" + rentalOrderID + "_" + System.currentTimeMillis() + "." + ext;
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
}
