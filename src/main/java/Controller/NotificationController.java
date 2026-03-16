package Controller;

import Model.Notification;
import Service.NotificationService;
import java.util.List;

public class NotificationController {

    public static int createNotification(int userID, String title, String message) {
        return NotificationService.createNotification(userID, title, message);
    }

    public static int createNotification(int userID, String title, String message, Integer orderID) {
        return NotificationService.createNotification(userID, title, message, orderID);
    }

    public static List<Notification> getUnreadNotifications(int userID) {
        return NotificationService.getUnreadNotifications(userID);
    }

    public static java.util.List<Notification> getAllNotifications(int userID) {
        return NotificationService.getAllNotifications(userID);
    }

    public static boolean markAsRead(int notificationID) {
        return NotificationService.markAsRead(notificationID);
    }
    
    public static boolean markAllAsReadForUser(int userID) {
        return NotificationService.markAllAsReadForUser(userID);
    }
}
