package Service;

import DAO.RentalOrderDAO;
import DAO.ClothingDAO;
import Model.RentalOrder;
import Model.Clothing;
import util.RefundCalculationUtil;
import util.RefundCalculationUtil.RefundDetails;
import util.RefundCalculationUtil.RefundStatus;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Service class for handling rental return and refund calculations
 * Lớp service để xử lý trả hàng và tính toán hoàn lại
 */
public class ReturnOrderService {
    
    /**
     * Process return item and calculate refund
     * 
     * @param rentalOrderID - Rental order ID
     * @param actualReturnDate - Actual return date/time
     * @param returnStatus - Status: NO_DAMAGE, LATE_RETURN, MINOR_DAMAGE, LOST
     * @param damagePercentage - Damage percentage (only for MINOR_DAMAGE, 0.0-1.0)
     * @return true if update successful
     */
    public static boolean processReturn(int rentalOrderID, LocalDateTime actualReturnDate, 
                                       String returnStatus, double damagePercentage) {
        // Get rental order
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) return false;
        
        // Get clothing for item value
        Clothing clothing = ClothingDAO.getClothingByID(order.getClothingID());
        if (clothing == null) return false;
        
        double itemValue = clothing.getItemValue();
        if (itemValue <= 0) {
            itemValue = clothing.getDailyPrice() * 0.2;
        }
        
        // Calculate late fee if applicable
        double lateFee = 0;
        if ("LATE_RETURN".equals(returnStatus)) {
            long lateHours = ChronoUnit.HOURS.between(order.getRentalEndDate(), actualReturnDate);
            if (lateHours > 0) {
                lateFee = RefundCalculationUtil.calculateLateFee(clothing.getHourlyPrice(), lateHours);
            }
        }
        
        // Calculate compensation if applicable
        double compensation = 0;
        RefundStatus status;
        
        if ("NO_DAMAGE".equals(returnStatus)) {
            status = RefundStatus.NO_DAMAGE;
            compensation = 0;
        } else if ("LATE_RETURN".equals(returnStatus)) {
            status = RefundStatus.LATE_RETURN;
            compensation = 0;
        } else if ("MINOR_DAMAGE".equals(returnStatus)) {
            status = RefundStatus.MINOR_DAMAGE;
            compensation = RefundCalculationUtil.calculateMinorDamageCompensation(itemValue, damagePercentage);
        } else if ("LOST".equals(returnStatus)) {
            status = RefundStatus.LOST;
            compensation = RefundCalculationUtil.calculateLostItemCompensation(itemValue);
        } else {
            status = RefundStatus.NO_DAMAGE;
            compensation = 0;
        }
        
        // Calculate refund details
        double depositAmount = order.getAdjustedDepositAmount();
        if (depositAmount <= 0) {
            depositAmount = order.getDepositAmount();
        }
        
        RefundDetails refundDetails = RefundCalculationUtil.calculateRefund(
            depositAmount, 
            status, 
            lateFee, 
            compensation
        );
        
        // Update rental order with return info
        return RentalOrderDAO.updateReturnInfo(
            rentalOrderID,
            actualReturnDate,
            returnStatus,
            damagePercentage,
            refundDetails.getLateFee(),
            refundDetails.getCompensationAmount(),
            refundDetails.getRefundAmount(),
            refundDetails.getAdditionalCharges()
        );
    }
    
    /**
     * Get detailed refund information for display
     * 
     * @param rentalOrderID - Rental order ID
     * @return Refund details object
     */
    public static RefundDetails getRefundDetails(int rentalOrderID) {
        RentalOrder order = RentalOrderDAO.getRentalOrderByID(rentalOrderID);
        if (order == null) return null;
        
        // Determine status
        RefundStatus status = RefundStatus.NO_DAMAGE;
        if ("LATE_RETURN".equals(order.getReturnStatus())) {
            status = RefundStatus.LATE_RETURN;
        } else if ("MINOR_DAMAGE".equals(order.getReturnStatus())) {
            status = RefundStatus.MINOR_DAMAGE;
        } else if ("LOST".equals(order.getReturnStatus())) {
            status = RefundStatus.LOST;
        }
        
        RefundDetails details = new RefundDetails();
        details.setOriginalDeposit(order.getAdjustedDepositAmount() > 0 ? 
                                   order.getAdjustedDepositAmount() : order.getDepositAmount());
        details.setStatus(status);
        details.setLateFee(order.getLateFees());
        details.setCompensationAmount(order.getCompensationAmount());
        details.setTotalDeduction(order.getLateFees() + order.getCompensationAmount());
        details.setRefundAmount(order.getRefundAmount());
        details.setAdditionalCharges(0); // Will be calculated if needed
        
        return details;
    }
    
    /**
     * Get rental orders ready for return processing
     * 
     * @param userID - User ID
     * @return List of rental orders
     */
    public static List<RentalOrder> getReadyForReturnOrders(int userID) {
        return RentalOrderDAO.getReadyForReturnOrders(userID);
    }
    
    /**
     * Get returned orders for manager review
     * 
     * @param managerID - Manager ID
     * @return List of returned rental orders
     */
    public static List<RentalOrder> getReturnedOrdersByManager(int managerID) {
        return RentalOrderDAO.getReturnedOrdersByManager(managerID);
    }
    
    /**
     * Calculate late hours between expected and actual return
     * 
     * @param order - Rental order
     * @return Late hours (0 if on time)
     */
    public static long calculateLateHours(RentalOrder order) {
        if (order.getActualReturnDate() == null) return 0;
        long lateHours = ChronoUnit.HOURS.between(order.getRentalEndDate(), order.getActualReturnDate());
        return Math.max(0, lateHours);
    }
    
    /**
     * Check if rental is overdue
     * 
     * @param order - Rental order
     * @return true if actual return is after expected return
     */
    public static boolean isOverdue(RentalOrder order) {
        if (order.getActualReturnDate() == null) {
            return order.getRentalEndDate().isBefore(LocalDateTime.now());
        }
        return order.getActualReturnDate().isAfter(order.getRentalEndDate());
    }
}
