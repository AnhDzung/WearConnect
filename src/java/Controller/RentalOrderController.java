package Controller;

import Service.RentalOrderService;
import Service.ClothingService;
import Model.RentalOrder;
import Model.Clothing;
import java.time.LocalDateTime;
import java.util.List;

public class RentalOrderController {
    
    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize) {
        return RentalOrderService.createRentalOrder(clothingID, renterUserID, startDate, endDate, selectedSize);
    }

    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize, Integer colorID) {
        return RentalOrderService.createRentalOrder(clothingID, renterUserID, startDate, endDate, selectedSize, colorID);
    }

    public static RentalOrder getRentalOrderDetails(int rentalOrderID) {
        return RentalOrderService.getRentalOrderDetails(rentalOrderID);
    }

    public static List<RentalOrder> getMyRentalOrders(int userID) {
        return RentalOrderService.getMyRentalOrders(userID);
    }

    public static List<RentalOrder> getOrdersByClothing(int clothingID) {
        return RentalOrderService.getOrdersByClothing(clothingID);
    }

    public static boolean confirmOrder(int rentalOrderID) {
        return RentalOrderService.confirmOrder(rentalOrderID);
    }

    public static boolean markAsRented(int rentalOrderID) {
        return RentalOrderService.markAsRented(rentalOrderID);
    }

    public static boolean markAsReturned(int rentalOrderID) {
        return RentalOrderService.markAsReturned(rentalOrderID);
    }

    public static boolean cancelOrder(int rentalOrderID) {
        return RentalOrderService.cancelOrder(rentalOrderID);
    }

    public static List<RentalOrder> getAllPendingOrders() {
        return RentalOrderService.getAllPendingOrders();
    }

    public static boolean isAvailable(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        return RentalOrderService.isAvailable(clothingID, startDate, endDate);
    }

    public static List<RentalOrder> getConflictingOrders(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        return RentalOrderService.getConflictingOrders(clothingID, startDate, endDate);
    }
    
    public static int getAvailableQuantity(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        return RentalOrderService.getAvailableQuantity(clothingID, startDate, endDate);
    }

    public static double calculateTotalPrice(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        return RentalOrderService.calculateTotalPrice(clothingID, startDate, endDate);
    }

    public static Clothing getClothingDetails(int clothingID) {
        return ClothingService.getClothingDetails(clothingID);
    }

    public static List<RentalOrder> getRentalOrdersByManager(int managerID) {
        return RentalOrderService.getRentalOrdersByManager(managerID);
    }
    
    public static boolean updateOrderStatus(int rentalOrderID, String status) {
        return RentalOrderService.updateOrderStatus(rentalOrderID, status);
    }

    public static RentalOrder getRentalOrderByID(int rentalOrderID) {
        return RentalOrderService.getRentalOrderByID(rentalOrderID);
    }
}
