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
