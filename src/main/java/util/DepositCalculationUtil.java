package util;

import config.DepositCalculationConfig;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Map;

/**
 * Utility class for calculating and formatting deposit payment details
 * Lớp tiện ích để tính toán và định dạng chi tiết thanh toán tiền cọc
 */
public class DepositCalculationUtil {
    
    private static final DecimalFormat currencyFormat = new DecimalFormat("#,###");
    
    /**
     * Calculate detailed payment breakdown for display
     * @param itemValue - Item value in VND
     * @param hourlyPrice - Hourly rental price in VND
     * @param dailyPrice - Daily rental price in VND
     * @param startDate - Rental start date
     * @param endDate - Rental end date
     * @return Map containing payment details
     */
    public static Map<String, Object> calculatePaymentDetails(
            double itemValue, 
            double hourlyPrice, 
            double dailyPrice,
            LocalDateTime startDate, 
            LocalDateTime endDate) {
        
        Map<String, Object> details = new HashMap<>();
        
        // Calculate duration
        long durationHours = ChronoUnit.HOURS.between(startDate, endDate);
        long durationDays = durationHours / 24;
        long remainingHours = durationHours % 24;
        
        details.put("durationHours", durationHours);
        details.put("durationDays", durationDays);
        details.put("remainingHours", remainingHours);
        
        double rentalFee;
        String priceType;
        double depositAmount;
        double depositPercentage;
        double depositMultiplier;
        double depositFromPercentage;
        double depositFromMultiplier;
        
        if (DepositCalculationConfig.shouldUseDailyPricing(durationHours)) {
            // Daily pricing
            rentalFee = durationDays * dailyPrice;
            priceType = "Daily";
            
            depositPercentage = DepositCalculationConfig.DAILY_DEPOSIT_PERCENTAGE;
            depositMultiplier = DepositCalculationConfig.DAILY_DEPOSIT_MULTIPLIER;
            
            depositFromPercentage = itemValue * depositPercentage;
            depositFromMultiplier = rentalFee * depositMultiplier;
            depositAmount = Math.max(depositFromPercentage, depositFromMultiplier);
        } else {
            // Hourly pricing
            rentalFee = durationHours * hourlyPrice;
            priceType = "Hourly";
            
            depositPercentage = DepositCalculationConfig.HOURLY_DEPOSIT_PERCENTAGE;
            depositMultiplier = DepositCalculationConfig.HOURLY_DEPOSIT_MULTIPLIER;
            
            depositFromPercentage = itemValue * depositPercentage;
            depositFromMultiplier = rentalFee * depositMultiplier;
            depositAmount = Math.max(depositFromPercentage, depositFromMultiplier);
        }
        
        details.put("itemValue", itemValue);
        details.put("rentalFee", rentalFee);
        details.put("depositAmount", depositAmount);
        details.put("totalPayNow", rentalFee + depositAmount);
        details.put("priceType", priceType);
        details.put("depositPercentage", depositPercentage * 100); // As percentage (e.g., 40 for 40%)
        details.put("depositMultiplier", depositMultiplier);
        details.put("depositFromPercentage", depositFromPercentage);
        details.put("depositFromMultiplier", depositFromMultiplier);
        details.put("usedFormula", "max(" + formatCurrency(depositFromPercentage) + 
                                  ", " + formatCurrency(depositFromMultiplier) + 
                                  ") = " + formatCurrency(depositAmount));
        
        return details;
    }
    
    /**
     * Format number as currency (VND)
     * @param value - Value in VND
     * @return Formatted string
     */
    public static String formatCurrency(double value) {
        return currencyFormat.format(value) + " ₫";
    }
    
    /**
     * Get Vietnamese description of pricing type
     * @param priceType - "Hourly" or "Daily"
     * @return Vietnamese description
     */
    public static String getPriceTypeDescription(String priceType) {
        if ("Daily".equals(priceType)) {
            return "Giá theo ngày (≥ 24 giờ)";
        } else {
            return "Giá theo giờ (< 24 giờ)";
        }
    }
    
    /**
     * Get Vietnamese description of deposit formula
     * @param priceType - "Hourly" or "Daily"
     * @param percentage - Percentage (e.g., 40 or 30)
     * @param multiplier - Multiplier (e.g., 2.0 or 0.5)
     * @return Vietnamese description
     */
    public static String getFormulaDescription(String priceType, double percentage, double multiplier) {
        if ("Daily".equals(priceType)) {
            return "Deposit = MAX(X × " + (int)percentage + "%, " + multiplier + " × Tiền thuê)";
        } else {
            return "Deposit = MAX(X × " + (int)percentage + "%, " + multiplier + " × Tiền thuê)";
        }
    }
}
