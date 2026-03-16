package util;

/**
 * Utility class for calculating refund based on return condition
 * Lớp tiện ích để tính toán hoàn trả dựa trên tình trạng trả hàng
 */
public class RefundCalculationUtil {
    
    /**
     * Refund status enum
     */
    public enum RefundStatus {
        NO_DAMAGE("Không hư hỏng", 1.0),
        LATE_RETURN("Trả trễ", 0),
        MINOR_DAMAGE("Hư hỏng nhẹ", 0),
        LOST("Mất đồ", 0);
        
        private final String description;
        private final double refundPercentage;
        
        RefundStatus(String description, double refundPercentage) {
            this.description = description;
            this.refundPercentage = refundPercentage;
        }
        
        public String getDescription() {
            return description;
        }
        
        public double getRefundPercentage() {
            return refundPercentage;
        }
    }
    
    /**
     * Calculate late fee
     * LateFee = HourlyPrice × LateHours × 150%
     * 
     * @param hourlyPrice - Hourly rental price in VND
     * @param lateHours - Number of hours late
     * @return Late fee amount in VND
     */
    public static double calculateLateFee(double hourlyPrice, long lateHours) {
        if (lateHours <= 0) return 0;
        return hourlyPrice * lateHours * 1.5; // 150%
    }
    
    /**
     * Calculate compensation for minor damage
     * Compensation = DamagePercentage × ItemValue
     * 
     * @param itemValue - Item value in VND
     * @param damagePercentage - Damage percentage (0.0 - 1.0, e.g., 0.2 for 20%)
     * @return Compensation amount in VND
     */
    public static double calculateMinorDamageCompensation(double itemValue, double damagePercentage) {
        if (damagePercentage < 0) damagePercentage = 0;
        if (damagePercentage > 1) damagePercentage = 1;
        return itemValue * damagePercentage;
    }
    
    /**
     * Calculate compensation for lost item
     * Compensation = ItemValue (Full replacement)
     * 
     * @param itemValue - Item value in VND
     * @return Compensation amount (full item value)
     */
    public static double calculateLostItemCompensation(double itemValue) {
        return itemValue;
    }
    
    /**
     * Calculate final refund amount
     * 
     * @param depositAmount - Original deposit paid
     * @param status - Return status
     * @param lateFee - Late fee (if any)
     * @param compensationAmount - Compensation amount (if any)
     * @return Refund details in a RefundDetails object
     */
    public static RefundDetails calculateRefund(double depositAmount, RefundStatus status, 
                                                 double lateFee, double compensationAmount) {
        RefundDetails details = new RefundDetails();
        details.setOriginalDeposit(depositAmount);
        details.setStatus(status);
        details.setLateFee(status == RefundStatus.LATE_RETURN ? lateFee : 0);
        details.setCompensationAmount(status == RefundStatus.MINOR_DAMAGE || 
                                     status == RefundStatus.LOST ? compensationAmount : 0);
        
        // Calculate refund amount
        double totalDeduction = details.getLateFee() + details.getCompensationAmount();
        double refund = depositAmount - totalDeduction;
        
        details.setTotalDeduction(totalDeduction);
        details.setRefundAmount(Math.max(refund, 0)); // No negative refund
        
        // Check if additional payment needed
        if (totalDeduction > depositAmount) {
            details.setAdditionalCharges(totalDeduction - depositAmount);
        } else {
            details.setAdditionalCharges(0);
        }
        
        return details;
    }
    
    /**
     * Inner class to hold refund calculation details
     */
    public static class RefundDetails {
        private double originalDeposit;
        private RefundStatus status;
        private double lateFee;
        private double compensationAmount;
        private double totalDeduction;
        private double refundAmount;
        private double additionalCharges; // Amount customer needs to pay if compensation > deposit
        
        // Getters and Setters
        public double getOriginalDeposit() { return originalDeposit; }
        public void setOriginalDeposit(double originalDeposit) { this.originalDeposit = originalDeposit; }
        
        public RefundStatus getStatus() { return status; }
        public void setStatus(RefundStatus status) { this.status = status; }
        
        public double getLateFee() { return lateFee; }
        public void setLateFee(double lateFee) { this.lateFee = lateFee; }
        
        public double getCompensationAmount() { return compensationAmount; }
        public void setCompensationAmount(double compensationAmount) { this.compensationAmount = compensationAmount; }
        
        public double getTotalDeduction() { return totalDeduction; }
        public void setTotalDeduction(double totalDeduction) { this.totalDeduction = totalDeduction; }
        
        public double getRefundAmount() { return refundAmount; }
        public void setRefundAmount(double refundAmount) { this.refundAmount = refundAmount; }
        
        public double getAdditionalCharges() { return additionalCharges; }
        public void setAdditionalCharges(double additionalCharges) { this.additionalCharges = additionalCharges; }
        
        /**
         * Get Vietnamese description of refund status
         */
        public String getStatusDescription() {
            return status != null ? status.getDescription() : "Không xác định";
        }
    }
}
