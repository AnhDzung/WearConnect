package com.wearconnect.boot.scheduler;

import DAO.RentalOrderDAO;
import DAO.ClothingDAO;
import DAO.AccountDAO;
import Model.RentalOrder;
import Model.Clothing;
import Model.Account;
import Service.NotificationService;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class OverdueRentalNotificationScheduler {

    private static final String USER_OVERDUE_TITLE = "Đơn hàng quá hạn trả";
    private static final String MANAGER_OVERDUE_TITLE = "Đơn hàng quá hạn cần xử lý";
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Scheduled(cron = "${app.notifications.overdue.cron:0 */15 * * * *}")
    public void notifyOverdueOrders() {
        try {
            processOverdueEndDates();
            processUnshippedVerifiedOrders();
        } catch (Exception e) {
            System.err.println("[OverdueRentalNotificationScheduler] Error in notification scheduler: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void processOverdueEndDates() {
        try {
            List<RentalOrder> overdueOrders = RentalOrderDAO.getOverdueOrdersForNotification();
            if (overdueOrders == null || overdueOrders.isEmpty()) {
                return;
            }

            for (RentalOrder order : overdueOrders) {
                if (order == null || order.getRentalOrderID() <= 0) {
                    continue;
                }

                String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                String clothingInfo = order.getClothingName() != null
                        ? order.getClothingName()
                        : "ID: " + order.getClothingID();
                String endDateText = order.getRentalEndDate() != null
                        ? order.getRentalEndDate().format(DATE_TIME_FORMATTER)
                        : "không xác định";

                // Determine if it's a sale order
                boolean isForSale = false;
                Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                if (clothing != null) {
                    Account owner = AccountDAO.findById(clothing.getRenterID());
                    if (owner != null && "Seller".equals(owner.getUserRole())) {
                        isForSale = true;
                    }
                }

                if (isForSale) {
                    // For sale orders: Buyer should not get overdue return notifications.
                    // Notify seller (Seller role) that the shipment/delivery is overdue.
                    if (order.getManagerID() > 0) {
                        String managerMessage = "Đơn hàng " + orderCode + " (" + clothingInfo 
                                + ") đã quá hạn giao hàng (" + endDateText + ") nhưng chưa được giao/nhận thành công. Vui lòng kiểm tra và hoàn tất giao hàng sớm cho khách hàng.";
                        NotificationService.createNotificationOnceByOrderAndTitle(
                                order.getManagerID(),
                                order.getRentalOrderID(),
                                "Đơn bán chưa giao quá hạn",
                                managerMessage
                        );
                    }
                } else {
                    // For rental orders
                    boolean isRented = "RENTED".equalsIgnoreCase(order.getStatus());
                    if (isRented) {
                        // Notify Renter to return the item
                        if (order.getRenterUserID() > 0) {
                            String userMessage = "Đơn hàng " + orderCode + " (" + clothingInfo + ") đã quá hạn từ "
                                    + endDateText + ". Vui lòng thực hiện trả hàng sớm để tránh phát sinh phí trễ hạn.";
                            NotificationService.createNotificationOnceByOrderAndTitle(
                                    order.getRenterUserID(),
                                    order.getRentalOrderID(),
                                    USER_OVERDUE_TITLE,
                                    userMessage
                            );
                        }

                        // Notify Manager to track the return
                        if (order.getManagerID() > 0) {
                            String renterName = order.getRenterFullName() != null
                                    ? order.getRenterFullName()
                                    : "Khách hàng ID " + order.getRenterUserID();
                            String managerMessage = "Đơn hàng " + orderCode + " (" + clothingInfo + ") của "
                                    + renterName + " đã quá hạn từ " + endDateText
                                    + ". Vui lòng theo dõi và hỗ trợ xử lý trả hàng.";
                            NotificationService.createNotificationOnceByOrderAndTitle(
                                    order.getManagerID(),
                                    order.getRentalOrderID(),
                                    MANAGER_OVERDUE_TITLE,
                                    managerMessage
                            );
                        }
                    } else {
                        // Rental order but status is not RENTED (e.g. PAYMENT_VERIFIED, SHIPPING)
                        // Notify Manager (Seller) that the order is past rental date but not yet shipped/received.
                        if (order.getManagerID() > 0) {
                            String managerMessage = "Đơn hàng " + orderCode + " (" + clothingInfo 
                                    + ") đã quá hạn thời gian thuê (" + endDateText + ") nhưng chưa được giao/nhận thành công. Vui lòng kiểm tra và liên hệ với khách hàng để xử lý.";
                            NotificationService.createNotificationOnceByOrderAndTitle(
                                    order.getManagerID(),
                                    order.getRentalOrderID(),
                                    "Đơn thuê chưa giao quá hạn thuê",
                                    managerMessage
                            );
                        }
                    }
                }
            }

            System.out.println("[OverdueRentalNotificationScheduler] Processed overdue end dates: "
                    + overdueOrders.size() + " at " + LocalDateTime.now());
        } catch (Exception e) {
            System.err.println("[OverdueRentalNotificationScheduler] Error processing overdue end dates: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void processUnshippedVerifiedOrders() {
        try {
            List<RentalOrder> verifiedOrders = RentalOrderDAO.getRentalOrdersByStatus("PAYMENT_VERIFIED");
            if (verifiedOrders == null || verifiedOrders.isEmpty()) {
                return;
            }

            LocalDateTime now = LocalDateTime.now();
            int warningCount = 0;
            int cancelCount = 0;

            for (RentalOrder order : verifiedOrders) {
                if (order == null || order.getRentalOrderID() <= 0 || order.getPaymentProcessedDate() == null) {
                    continue;
                }

                String orderCode = "WRC" + String.format("%05d", order.getRentalOrderID());
                String clothingInfo = order.getClothingName() != null
                        ? order.getClothingName()
                        : "ID: " + order.getClothingID();

                int sellerID = order.getManagerID();
                
                // Determine if it's a sale order
                boolean isForSale = false;
                Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
                if (clothing != null) {
                    Account owner = AccountDAO.findById(clothing.getRenterID());
                    if (owner != null && "Seller".equals(owner.getUserRole())) {
                        isForSale = true;
                    }
                }

                String sellerRoleName = isForSale ? "Seller" : "Manager";
                LocalDateTime verifiedDate = order.getPaymentProcessedDate();
                
                // 3 days (72 hours) -> Auto-cancel
                if (now.isAfter(verifiedDate.plusDays(3))) {
                    double refundAmount = order.getTotalPrice() + order.getDepositAmount();
                    double penaltyAmount = order.getTotalPrice() * 0.05;
                    
                    boolean cancelled = RentalOrderDAO.cancelOverdueUnshippedOrder(order.getRentalOrderID(), penaltyAmount, refundAmount);
                    if (cancelled) {
                        cancelCount++;
                        // Notify Seller/Manager
                        if (sellerID > 0) {
                            String warningMessage = "Đơn hàng " + orderCode + " (" + clothingInfo 
                                    + ") đã tự động hủy do quá 3 ngày kể từ khi xác thực thanh toán nhưng bạn chưa giao hàng. Phân quyền " + sellerRoleName + " của bạn bị phạt 5% giá trị đơn hàng ("
                                    + String.format("%,.0f", penaltyAmount) + " đ) và không được nhận tiền thanh toán.";
                            NotificationService.createNotificationOnceByOrderAndTitle(
                                    sellerID,
                                    order.getRentalOrderID(),
                                    "Đơn hàng bị tự động hủy do quá hạn giao",
                                    warningMessage
                            );
                        }

                        // Notify Buyer/Renter
                        if (order.getRenterUserID() > 0) {
                            String renterMessage = "Đơn hàng " + orderCode + " (" + clothingInfo 
                                    + ") đã tự động hủy do người bán không giao hàng đúng hạn (quá 3 ngày kể từ khi xác thực thanh toán). Bạn sẽ được hoàn trả toàn bộ số tiền "
                                    + String.format("%,.0f", refundAmount) + " đ.";
                            NotificationService.createNotificationOnceByOrderAndTitle(
                                    order.getRenterUserID(),
                                    order.getRentalOrderID(),
                                    "Đơn hàng bị tự động hủy do quá hạn giao",
                                    renterMessage
                            );
                        }
                    }
                }
                // 2 days (48 hours) -> Send warning notification
                else if (now.isAfter(verifiedDate.plusDays(2))) {
                    if (sellerID > 0) {
                        String warningMessage = "Đơn hàng " + orderCode + " (" + clothingInfo 
                                + ") đã quá 2 ngày kể từ khi xác thực thanh toán nhưng chưa được giao đi. Vui lòng giao hàng trong vòng 24h tới để tránh bị tự động hủy đơn và chịu phạt 5% phí hệ thống.";
                        int res = NotificationService.createNotificationOnceByOrderAndTitle(
                                sellerID,
                                order.getRentalOrderID(),
                                "Cảnh báo quá hạn giao hàng",
                                warningMessage
                        );
                        if (res > 0) {
                            warningCount++;
                        }
                    }
                }
            }

            if (warningCount > 0 || cancelCount > 0) {
                System.out.println("[OverdueRentalNotificationScheduler] Unshipped verified orders processed: warnings=" 
                        + warningCount + ", cancellations=" + cancelCount + " at " + LocalDateTime.now());
            }
        } catch (Exception e) {
            System.err.println("[OverdueRentalNotificationScheduler] Error processing unshipped verified orders: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
