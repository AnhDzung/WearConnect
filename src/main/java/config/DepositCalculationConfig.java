package config;

/**
 * Configuration for deposit calculation based on rental duration
 * Cấu hình tính toán tiền cọc dựa trên thời gian thuê
 */
public class DepositCalculationConfig {
    
    // ==================== HOURLY RENTAL (Thuê theo giờ) ====================
    /** Deposit percentage for hourly rental: 40% of item value */
    public static final double HOURLY_DEPOSIT_PERCENTAGE = 0.40;
    
    /** Deposit multiplier for hourly rental: 2x rental fee */
    public static final double HOURLY_DEPOSIT_MULTIPLIER = 2.0;
    
    // ==================== DAILY RENTAL (Thuê theo ngày) ====================
    /** Deposit percentage for daily rental: 30% of item value */
    public static final double DAILY_DEPOSIT_PERCENTAGE = 0.30;
    
    /** Deposit multiplier for daily rental: 0.5x rental fee */
    public static final double DAILY_DEPOSIT_MULTIPLIER = 0.5;
    
    // ==================== THRESHOLD (Ngưỡng xác định giờ/ngày) ====================
    /**
     * Threshold in hours to determine hourly vs daily pricing
     * If rental duration >= 24 hours, use daily pricing
     * Nếu thời gian thuê >= 24 giờ, sử dụng giá theo ngày
     */
    public static final long HOURLY_TO_DAILY_THRESHOLD = 24;
    
    // ==================== TRUST-BASED DISCOUNT/SURCHARGE ====================
    /** 
     * Discount multiplier for high-rating users (rating >= 4.0)
     * High reputation users pay 80% of calculated deposit
     * Người dùng uy tín cao được giảm 20%
     */
    public static final double HIGH_RATING_MULTIPLIER = 0.80;
    
    /** 
     * Surcharge multiplier for new/low-rating users (rating < 3.0 or no rating)
     * New/low reputation users pay 120% of calculated deposit
     * Người dùng mới/uy tín thấp phải trả 20% thêm
     */
    public static final double NEW_USER_MULTIPLIER = 1.20;
    
    /** 
     * Normal multiplier for regular users (rating 3.0 - 3.9)
     * Regular users pay 100% of calculated deposit
     */
    public static final double NORMAL_USER_MULTIPLIER = 1.0;
    
    /** Threshold for high rating (rating >= this value) */
    public static final double HIGH_RATING_THRESHOLD = 4.0;
    
    /** Threshold for low rating (rating < this value) */
    public static final double LOW_RATING_THRESHOLD = 3.0;
    
    /**
     * Calculate deposit for hourly rental
     * 
     * Formula: Deposit = MAX(ItemValue × 40%, 2 × RentalFee)
     * 
     * @param itemValue - Item value in VND (Giá trị sản phẩm)
     * @param rentalFee - Total rental fee in VND (Tổng tiền thuê)
     * @return Calculated deposit amount
     */
    public static double calculateHourlyDeposit(double itemValue, double rentalFee) {
        double depositFromItemValue = itemValue * HOURLY_DEPOSIT_PERCENTAGE;
        double depositFromRentalFee = rentalFee * HOURLY_DEPOSIT_MULTIPLIER;
        return Math.max(depositFromItemValue, depositFromRentalFee);
    }
    
    /**
     * Calculate deposit for daily rental
     * 
     * Formula: Deposit = MAX(ItemValue × 30%, 0.5 × RentalFee)
     * 
     * @param itemValue - Item value in VND (Giá trị sản phẩm)
     * @param rentalFee - Total rental fee in VND (Tổng tiền thuê)
     * @return Calculated deposit amount
     */
    public static double calculateDailyDeposit(double itemValue, double rentalFee) {
        double depositFromItemValue = itemValue * DAILY_DEPOSIT_PERCENTAGE;
        double depositFromRentalFee = rentalFee * DAILY_DEPOSIT_MULTIPLIER;
        return Math.max(depositFromItemValue, depositFromRentalFee);
    }
    
    /**
     * Determine if rental duration should use daily pricing
     * 
     * @param durationHours - Rental duration in hours
     * @return true if duration >= 24 hours (use daily pricing), false otherwise (use hourly pricing)
     */
    public static boolean shouldUseDailyPricing(long durationHours) {
        return durationHours >= HOURLY_TO_DAILY_THRESHOLD;
    }
    
    /**
     * Calculate trust-based deposit multiplier based on user rating
     * 
     * HIGH RATING (>= 4.0): 80% discount → pay 80% of deposit
     * NORMAL RATING (3.0 - 3.9): No adjustment → pay 100%
     * LOW RATING (< 3.0): 20% surcharge → pay 120%
     * NO RATING: Same as low rating → pay 120%
     * 
     * @param userRating - User's average rating (null or 0 = no rating)
     * @return Multiplier to apply to calculated deposit
     */
    public static double getTrustBasedMultiplier(Double userRating) {
        if (userRating == null || userRating <= 0) {
            // No rating = new user = surcharge
            return NEW_USER_MULTIPLIER;
        }
        
        if (userRating >= HIGH_RATING_THRESHOLD) {
            // High rating = discount
            return HIGH_RATING_MULTIPLIER;
        } else if (userRating < LOW_RATING_THRESHOLD) {
            // Low rating = surcharge
            return NEW_USER_MULTIPLIER;
        } else {
            // Normal rating = no adjustment
            return NORMAL_USER_MULTIPLIER;
        }
    }
    
    /**
     * Get Vietnamese description of trust-based rating
     * 
     * @param userRating - User's average rating
     * @return Description string
     */
    public static String getTrustRatingDescription(Double userRating) {
        if (userRating == null || userRating <= 0) {
            return "Người dùng mới (cọc +20%)";
        }
        
        if (userRating >= HIGH_RATING_THRESHOLD) {
            return "Uy tín cao (cọc -20%)";
        } else if (userRating < LOW_RATING_THRESHOLD) {
            return "Uy tín thấp (cọc +20%)";
        } else {
            return "Uy tín bình thường (cọc 100%)";
        }
    }
}
