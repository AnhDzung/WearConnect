package Service;

import DAO.RentalOrderDAO;
import DAO.PaymentDAO;
import DAO.ClothingDAO;
import DAO.RatingDAO;
import Model.RentalOrder;
import Model.Clothing;
import config.DepositCalculationConfig;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.ArrayList;

public class RentalOrderService {
    
    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize) {
        return createRentalOrder(clothingID, renterUserID, startDate, endDate, selectedSize, null, null);
    }

    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize, Integer colorID) {
        return createRentalOrder(clothingID, renterUserID, startDate, endDate, selectedSize, colorID, null);
    }

    public static int createRentalOrder(int clothingID, int renterUserID, LocalDateTime startDate, LocalDateTime endDate, String selectedSize, Integer colorID, String voucherCode) {
        Clothing clothing = ClothingDAO.getClothingByID(clothingID);
        if (clothing == null) return -1;
        
        Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
        boolean isForSale = owner != null && "Renter".equals(owner.getUserRole());
        
        double totalPrice = 0.0;
        double depositAmount = 0.0;
        double userRating = 5.0;
        double trustBasedMultiplier = 1.0;
        double adjustedDepositAmount = 0.0;
        
        if (isForSale) {
            // For sale products: price is clothing.getDailyPrice(), deposit is 0
            totalPrice = clothing.getDailyPrice();
        } else {
            // Calculate rental duration in hours
            long durationHours = ChronoUnit.HOURS.between(startDate, endDate);
            if (durationHours <= 0) return -1;
            
            // Get item value (product value set by manager)
            double itemValue = clothing.getItemValue();
            if (itemValue <= 0) {
                // Fallback to 20% of daily price if not set
                itemValue = clothing.getDailyPrice() * 0.2;
            }
            
            // Determine if using daily or hourly pricing
            if (DepositCalculationConfig.shouldUseDailyPricing(durationHours)) {
                // Use daily pricing for rentals >= 24 hours
                long durationDays = durationHours / 24;
                totalPrice = durationDays * clothing.getDailyPrice();
                depositAmount = DepositCalculationConfig.calculateDailyDeposit(itemValue, totalPrice);
            } else {
                // Use hourly pricing for rentals < 24 hours
                totalPrice = durationHours * clothing.getHourlyPrice();
                depositAmount = DepositCalculationConfig.calculateHourlyDeposit(itemValue, totalPrice);
            }
            
            // Get user's average rating for trust-based deposit adjustment
            userRating = RatingDAO.getAverageRatingForUser(renterUserID);
            trustBasedMultiplier = DepositCalculationConfig.getTrustBasedMultiplier(
                userRating > 0 ? userRating : null
            );
            adjustedDepositAmount = depositAmount * trustBasedMultiplier;
        }
        
        // Apply Voucher Discount
        double discountAmount = 0.0;
        String appliedVoucherCode = null;
        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            Model.Voucher voucher = DAO.VoucherDAO.getVoucherByCode(voucherCode.trim());
            if (voucher != null && voucher.isActive() && 
                (voucher.getStartDate() == null || voucher.getStartDate().isBefore(LocalDateTime.now())) &&
                (voucher.getEndDate() == null || voucher.getEndDate().isAfter(LocalDateTime.now())) &&
                totalPrice >= voucher.getMinOrderValue()) {
                
                appliedVoucherCode = voucher.getVoucherCode();
                if ("PERCENTAGE".equals(voucher.getDiscountType())) {
                    discountAmount = totalPrice * (voucher.getDiscountValue() / 100.0);
                    if (voucher.getMaxDiscountAmount() != null && discountAmount > voucher.getMaxDiscountAmount()) {
                        discountAmount = voucher.getMaxDiscountAmount();
                    }
                } else if ("AMOUNT".equals(voucher.getDiscountType())) {
                    discountAmount = voucher.getDiscountValue();
                }
                
                if (discountAmount > totalPrice) {
                    discountAmount = totalPrice;
                }
            }
        }
        double finalTotalPrice = totalPrice - discountAmount;
        
        LocalDateTime actualStartDate = isForSale ? LocalDateTime.now() : startDate;
        LocalDateTime actualEndDate = isForSale ? LocalDateTime.now() : endDate;
        RentalOrder order = new RentalOrder(clothingID, renterUserID, actualStartDate, actualEndDate, finalTotalPrice, adjustedDepositAmount);
        order.setSelectedSize(selectedSize);
        order.setUserRating(userRating);
        order.setTrustBasedMultiplier(trustBasedMultiplier);
        order.setAdjustedDepositAmount(adjustedDepositAmount);
        order.setVoucherCode(appliedVoucherCode);
        order.setDiscountAmount(discountAmount);
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

    public static List<RentalOrder> getOrdersForPaymentProcessing() {
        return RentalOrderDAO.getOrdersForPaymentProcessing();
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
        
        Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
        boolean isForSale = owner != null && "Renter".equals(owner.getUserRole());
        
        if (!isForSale && (startDate == null || endDate == null)) {
            return false;
        }
        
        int totalQuantity = clothing.getQuantity();
        
        // Count how many items are already ordered/rented during the requested time period or total active orders for sales
        List<RentalOrder> orders = RentalOrderDAO.getRentalOrdersByClothing(clothingID);
        int rentedCount = 0;
        
        for (RentalOrder order : orders) {
            // Skip cancelled orders only. PENDING_PAYMENT should reserve the item.
            if (order.getStatus().equals("CANCELLED")) {
                continue;
            }
            
            if (isForSale) {
                rentedCount++;
            } else {
                // Check for time overlap
                if (startDate.isBefore(order.getRentalEndDate()) && endDate.isAfter(order.getRentalStartDate())) {
                    rentedCount++;
                }
            }
        }
        
        // Available if rented count is less than total quantity
        return rentedCount < totalQuantity;
    }

    public static List<RentalOrder> getConflictingOrders(int clothingID, LocalDateTime startDate, LocalDateTime endDate) {
        List<RentalOrder> conflictingOrders = new ArrayList<>();
        Clothing clothing = ClothingDAO.getClothingByID(clothingID);
        if (clothing == null) return conflictingOrders;
        
        Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
        boolean isForSale = owner != null && "Renter".equals(owner.getUserRole());
        if (isForSale) {
            // For sale items, we don't have overlapping date conflicts. They only conflict if out of stock.
            return conflictingOrders;
        }

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
        
        Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
        boolean isForSale = owner != null && "Renter".equals(owner.getUserRole());
        
        if (!isForSale && (startDate == null || endDate == null)) {
            return 0;
        }
        
        int totalQuantity = clothing.getQuantity();
        
        List<RentalOrder> orders = RentalOrderDAO.getRentalOrdersByClothing(clothingID);
        int activeCount = 0;
        for (RentalOrder order : orders) {
            if (order.getStatus().equals("CANCELLED")) {
                continue;
            }
            if (isForSale) {
                activeCount++;
            } else {
                if (startDate.isBefore(order.getRentalEndDate()) && endDate.isAfter(order.getRentalStartDate())) {
                    activeCount++;
                }
            }
        }
        
        return Math.max(0, totalQuantity - activeCount);
    }

    public static int expirePendingPayments(int hours) {
        return RentalOrderDAO.cancelExpiredPendingPayments(hours);
    }

    public static int expirePendingPaymentsInMinutes(int minutes) {
        return RentalOrderDAO.cancelExpiredPendingPaymentsInMinutes(minutes);
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

    public static boolean setPaymentProofPath(int rentalOrderID, String path, byte[] imageData) {
        return RentalOrderDAO.updatePaymentProofPath(rentalOrderID, path, imageData);
    }

    public static boolean setReceivedProofPath(int rentalOrderID, String path) {
        return RentalOrderDAO.updateReceivedProofPath(rentalOrderID, path);
    }

    public static boolean setReceivedProofPath(int rentalOrderID, String path, byte[] imageData) {
        return RentalOrderDAO.updateReceivedProofPath(rentalOrderID, path, imageData);
    }

    public static boolean setTrackingNumber(int rentalOrderID, String trackingNumber) {
        return RentalOrderDAO.updateTrackingNumber(rentalOrderID, trackingNumber);
    }

    public static boolean setRefundProofImagePath(int rentalOrderID, String path) {
        return RentalOrderDAO.updateRefundProofImage(rentalOrderID, path);
    }

    public static boolean setRefundProofImagePath(int rentalOrderID, String path, byte[] imageData) {
        return RentalOrderDAO.updateRefundProofImage(rentalOrderID, path, imageData);
    }

    public static boolean setManagerPaymentProofImagePath(int rentalOrderID, String path) {
        return RentalOrderDAO.updateManagerPaymentProofImage(rentalOrderID, path);
    }

    public static boolean setManagerPaymentProofImagePath(int rentalOrderID, String path, byte[] imageData) {
        return RentalOrderDAO.updateManagerPaymentProofImage(rentalOrderID, path, imageData);
    }

    public static RentalOrder getRentalOrderByID(int rentalOrderID) {
        return RentalOrderDAO.getRentalOrderByID(rentalOrderID);
    }

    public static boolean markPaymentProcessed(int rentalOrderID) {
        return RentalOrderDAO.markPaymentProcessed(rentalOrderID);
    }
}
