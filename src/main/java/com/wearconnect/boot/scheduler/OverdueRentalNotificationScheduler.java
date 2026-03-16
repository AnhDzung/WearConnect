package com.wearconnect.boot.scheduler;

import DAO.RentalOrderDAO;
import Model.RentalOrder;
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
            }

            System.out.println("[OverdueRentalNotificationScheduler] Processed overdue orders: "
                    + overdueOrders.size() + " at " + LocalDateTime.now());
        } catch (Exception e) {
            System.err.println("[OverdueRentalNotificationScheduler] Error processing overdue notifications: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
