package config;

/**
 * Bank Transfer Configuration
 * Contains payment information for bank transfers
 */
public class BankTransferConfig {
    
    // MB Bank Information
    public static final String BANK_NAME = "MB Bank";
    public static final String BANK_ACCOUNT_NUMBER = "1406200368";
    public static final String ACCOUNT_HOLDER_NAME = "NGUYEN DAC ANH DUNG";
    public static final String BANK_CODE = "MBB";
    public static final String BRANCH = "Chi nhánh Hà Nội";
    
    // Bank details object
    public static class BankDetails {
        private String bankName;
        private String accountNumber;
        private String accountHolderName;
        private String bankCode;
        private String branch;
        private double amount;
        private String orderReference;
        
        public BankDetails(String bankName, String accountNumber, String accountHolderName, 
                          String bankCode, String branch) {
            this.bankName = bankName;
            this.accountNumber = accountNumber;
            this.accountHolderName = accountHolderName;
            this.bankCode = bankCode;
            this.branch = branch;
        }
        
        // Getters and Setters
        public String getBankName() { return bankName; }
        public void setBankName(String bankName) { this.bankName = bankName; }
        
        public String getAccountNumber() { return accountNumber; }
        public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }
        
        public String getAccountHolderName() { return accountHolderName; }
        public void setAccountHolderName(String accountHolderName) { this.accountHolderName = accountHolderName; }
        
        public String getBankCode() { return bankCode; }
        public void setBankCode(String bankCode) { this.bankCode = bankCode; }
        
        public String getBranch() { return branch; }
        public void setBranch(String branch) { this.branch = branch; }
        
        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }
        
        public String getOrderReference() { return orderReference; }
        public void setOrderReference(String orderReference) { this.orderReference = orderReference; }
    }
    
    /**
     * Get MB Bank details
     */
    public static BankDetails getMBBankDetails() {
        return new BankDetails(BANK_NAME, BANK_ACCOUNT_NUMBER, ACCOUNT_HOLDER_NAME, BANK_CODE, BRANCH);
    }
    
    /**
     * Get MB Bank details with amount and order reference
     */
    public static BankDetails getMBBankDetails(double amount, int rentalOrderID) {
        BankDetails details = getMBBankDetails();
        details.setAmount(amount);
        details.setOrderReference("WRC" + String.format("%05d", rentalOrderID));
        return details;
    }
    
    /**
     * Generate QR code data for bank transfer (for future integration)
     * Format: bankcode|account|amount|description
     */
    public static String generateQRCodeData(double amount, int rentalOrderID) {
        String orderRef = "WRC" + String.format("%05d", rentalOrderID);
        return BANK_CODE + "|" + BANK_ACCOUNT_NUMBER + "|" + amount + "|" + orderRef;
    }
}
