package Service;

import DAO.NotificationDAO;
import Model.Notification;
import java.util.List;

public class NotificationService {

    public static int createNotification(int userID, String title, String message) {
        return createNotification(userID, title, message, null);
    }

    public static int createNotification(int userID, String title, String message, Integer orderID) {
        Notification n = new Notification(userID, title, message, orderID);
        return NotificationDAO.addNotification(n);
    }

    public static int createNotificationOnceByTitle(int userID, String title, String message) {
        if (userID <= 0 || title == null || title.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            return -1;
        }

        if (NotificationDAO.existsByUserAndTitle(userID, title.trim())) {
            return 0;
        }

        return createNotification(userID, title.trim(), message.trim());
    }

    public static List<Notification> getUnreadNotifications(int userID) {
        return NotificationDAO.getUnreadNotificationsByUser(userID);
    }

    public static List<Notification> getAllNotifications(int userID) {
        return NotificationDAO.getAllNotificationsByUser(userID);
    }

    public static boolean markAsRead(int notificationID) {
        return NotificationDAO.markAsRead(notificationID);
    }
    
    public static boolean markAllAsReadForUser(int userID) {
        return NotificationDAO.markAllAsReadForUser(userID);
    }
}
