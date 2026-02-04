package Service;

import DAO.RentalOrderDAO;
import DAO.PaymentDAO;
import DAO.ClothingDAO;
import Model.RentalOrder;
import Model.Clothing;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.ArrayList;

public class RentalOrderService {
    
    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize) {
        return createRentalOrder(clothingID, renterUserID, startDate, endDate, selectedSize, null);
    }

    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize, Integer colorID) {
        Clothing clothing = ClothingDAO.getClothingByID(clothingID);
        if (clothing == null) return -1;
        
        // Calculate total price based on hourly rate and duration
        long hours = ChronoUnit.HOURS.between(startDate, endDate);
        double totalPrice = hours * clothing.getHourlyPrice();
        
        // Use deposit amount set by manager (not 20%)
        double depositAmount = clothing.getDepositAmount();
        if (depositAmount <= 0) {
            // Fallback to 20% if not set
            depositAmount = totalPrice * 0.2;
        }
        
        RentalOrder order = new RentalOrder(clothingID, renterUserID, startDate, endDate, totalPrice, depositAmount);
        order.setSelectedSize(selectedSize);
        if (colorID != null) {
            order.setColorID(colorID);
        }
        return RentalOrderDAO.addRentalOrder(order);
    }

    public static RentalOrder getRentalOrderDetails(int rentalOrderID) {
        return RentalOrderDAO.getRentalOrderByID(rentalOrderID);
    }

    public static List<RentalOrder> getMyRentalOrders(int userID) {
        return RentalOrderDAO.getRentalOrdersByUser(userID);
    }

    public static List<RentalOrder> getOrdersByClothing(int clothingID) {
        return RentalOrderDAO.getRentalOrdersByClothing(clothingID);
    }

    public static boolean confirmOrder(int rentalOrderID) {
        return RentalOrderDAO.updateRentalOrderStatus(rentalOrderID, "PAYMENT_VERIFIED");
    }

    public static boolean markAsRented(int rentalOrderID) {
        return RentalOrderDAO.updateRentalOrderStatus(rentalOrderID, "RENTED");
    }

    public static boolean markAsReturned(int rentalOrderID) {
        return RentalOrderDAO.updateRentalOrderStatus(rentalOrderID, "RETURNED");
    }

    public static boolean cancelOrder(int rentalOrderID) {
        return RentalOrderDAO.updateRentalOrderStatus(rentalOrderID, "CANCELLED");
    }

    public static List<RentalOrder> getAllPendingOrders() {
        return RentalOrderDAO.getRentalOrdersByStatus("PENDING");
    }

    public static List<RentalOrder> getOrdersByStatus(String status) {
        return RentalOrderDAO.getRentalOrdersByStatus(status);
    }

    public static int countOrdersByStatus(String status) {
        return RentalOrderDAO.countRentalOrdersByStatus(status);
    }

    public static List<RentalOrder> getAllConfirmedOrders() {
        return RentalOrderDAO.getRentalOrdersByStatus("PAYMENT_VERIFIED");
    }

    public static boolean isAvailable(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        // Get clothing to check total quantity
        Clothing clothing = ClothingDAO.getClothingByID(clothingID);
        if (clothing == null) return false;
        
        int totalQuantity = clothing.getQuantity();
        
        // Count how many items are already rented during the requested time period
        List<RentalOrder> orders = RentalOrderDAO.getRentalOrdersByClothing(clothingID);
        int rentedCount = 0;
        
        for (RentalOrder order : orders) {
            // Skip cancelled orders only. PENDING_PAYMENT should reserve the item.
            if (order.getStatus().equals("CANCELLED")) {
                continue;
            }
            
            // Check for time overlap
            if (startDate.isBefore(order.getRentalEndDate()) && endDate.isAfter(order.getRentalStartDate())) {
                rentedCount++;
            }
        }
        
        // Available if rented count is less than total quantity
        return rentedCount < totalQuantity;
    }

    public static List<RentalOrder> getConflictingOrders(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        List<RentalOrder> conflictingOrders = new ArrayList<>();
        List<RentalOrder> orders = RentalOrderDAO.getRentalOrdersByClothing(clothingID);
        
        for (RentalOrder order : orders) {
            // Skip cancelled orders only. PENDING_PAYMENT and PAYMENT_SUBMITTED still conflict.
            if (order.getStatus().equals("CANCELLED")) {
                continue;
            }
            
            // Check for time overlap
            if (startDate.isBefore(order.getRentalEndDate()) && endDate.isAfter(order.getRentalStartDate())) {
                conflictingOrders.add(order);
            }
        }
        return conflictingOrders;
    }
    
    public static int getAvailableQuantity(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        Clothing clothing = ClothingDAO.getClothingByID(clothingID);
        if (clothing == null) return 0;
        
        int totalQuantity = clothing.getQuantity();
        List<RentalOrder> conflictingOrders = getConflictingOrders(clothingID, startDate, endDate);
        
        return totalQuantity - conflictingOrders.size();
    }

    public static int expirePendingPayments(int hours) {
        return RentalOrderDAO.cancelExpiredPendingPayments(hours);
    }

    public static double calculateTotalPrice(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        Clothing clothing = ClothingDAO.getClothingByID(clothingID);
        if (clothing == null) return 0;
        
        long hours = ChronoUnit.HOURS.between(startDate, endDate);
        return hours * clothing.getHourlyPrice();
    }

    public static List<RentalOrder> getRentalOrdersByManager(int managerID) {
        return RentalOrderDAO.getRentalOrdersByManager(managerID);
    }
    
    public static boolean updateOrderStatus(int rentalOrderID, String status) {
        return RentalOrderDAO.updateRentalOrderStatus(rentalOrderID, status);
    }

    public static boolean updateOrderStatusWithNotes(int rentalOrderID, String status, String notes) {
        return RentalOrderDAO.updateRentalOrderStatusWithNotes(rentalOrderID, status, notes);
    }

    public static boolean setPaymentProofPath(int rentalOrderID, String path) {
        return RentalOrderDAO.updatePaymentProofPath(rentalOrderID, path);
    }

    public static boolean setReceivedProofPath(int rentalOrderID, String path) {
        return RentalOrderDAO.updateReceivedProofPath(rentalOrderID, path);
    }

    public static boolean setTrackingNumber(int rentalOrderID, String trackingNumber) {
        return RentalOrderDAO.updateTrackingNumber(rentalOrderID, trackingNumber);
    }

    public static RentalOrder getRentalOrderByID(int rentalOrderID) {
        return RentalOrderDAO.getRentalOrderByID(rentalOrderID);
    }
}
