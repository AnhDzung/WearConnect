# Bank Account and Payment Processing Feature

## Overview
This feature adds bank account information for users and managers, along with a complete admin payment processing system for completed rental orders.

## Implementation Summary

### 1. Database Changes

**File:** `ADD_BANK_ACCOUNT_NUMBER.sql`
- Added `BankAccountNumber` (NVARCHAR(50)) to Accounts table
- Added `BankName` (NVARCHAR(100)) to Accounts table

**File:** `ADD_PAYMENT_PROOF_FIELDS.sql`
- Added `RefundProofImage` (NVARCHAR(255)) to RentalOrder table
- Added `ManagerPaymentProofImage` (NVARCHAR(255)) to RentalOrder table
- Added `PaymentProcessedDate` (DATETIME) to RentalOrder table

### 2. Model Updates

**Account.java**
- Added fields:
  - `private String bankAccountNumber`
  - `private String bankName`
- Added getters and setters for both fields

**RentalOrder.java**
- Added fields:
  - `private String refundProofImage` - Proof of deposit refund to user
  - `private String managerPaymentProofImage` - Proof of rental payment to manager
  - `private LocalDateTime paymentProcessedDate` - Admin processing timestamp
- Added getters and setters for all three fields

### 3. DAO Updates

**AccountDAO.java**
- Updated `mapResultSetToAccount()` method:
  - Added try-catch wrapped reading of BankAccountNumber and BankName for backward compatibility
- Updated `update()` method:
  - Changed from 5 parameters to 7 parameters
  - Now includes BankAccountNumber and BankName in UPDATE query

### 4. Controller/Servlet Updates

**UserServlet.java**
- Updated `handleUpdateProfile()` method:
  - Now retrieves bankAccountNumber and bankName from request parameters
  - Sets these values on user object before calling UserService.updateProfile()

**AdminServlet.java**
- Added new action: `payments`
- Implemented `showPaymentsPage()` method:
  - Retrieves all orders with status "RETURNED"
  - Loads user and manager account details with bank information
  - Loads clothing details for each order
  - Forwards to dashboard.jsp with "payments" view
- Updated `doPost()` method:
  - Added handling for "confirmPayment" action
- Implemented `handleConfirmPayment()` method:
  - Updates order status to "COMPLETED"
  - Sends notification to user about deposit refund
  - Sends notification to manager about rental fee payment
  - Redirects with success/error message

### 5. View Updates

**profile.jsp**
- Added bank account display in info grid:
  - Shows "Số tài khoản ngân hàng" with value or "Chưa cập nhật"
  - Shows "Tên ngân hàng" with value or "Chưa cập nhật"
- Added bank account input fields in edit modal:
  - Text input for bank account number with placeholder
  - Text input for bank name with example placeholder
- Added profile completion notification:
  - Checks if phoneNumber, address, bankAccountNumber, or bankName are missing
  - Displays yellow info box with message: "Cảm ơn bạn đã tin tưởng và sử dụng WearConnect. Hãy cập nhật đầy đủ thông tin của bạn trong profile để trải nghiệm tốt hơn!"
  - Lists specific missing fields
  - Only shows on page load (not after successful update)

**dashboard.jsp (Admin)**
- Added "Xử lý thanh toán" tab button in navigation
- Implemented payments view section:
  - Table displaying all RETURNED orders
  - Columns:
    - Order ID
    - Product name
    - Renter name and bank account info
    - Manager name and bank account info
    - Deposit amount
    - Rental fee amount
    - Action button
  - Shows "Chưa cập nhật" if bank account info is missing
- Added payment confirmation modal:
  - Displays deposit amount to refund
  - File upload for refund proof image
  - Displays rental fee amount to pay manager
  - File upload for manager payment proof image
  - Submit button to confirm payment processed
- Added JavaScript function `openPaymentModal()`:
  - Sets order ID, deposit amount, and rental fee in modal
  - Formats numbers with Vietnamese locale
  - Opens modal
- Added success/error message display for payment confirmation

## User Flow

### User/Manager Profile Completion
1. User logs in and navigates to their profile
2. If bank account information is missing, sees yellow notification
3. Clicks "Chỉnh sửa thông tin" button
4. Fills in "Số tài khoản ngân hàng" and "Tên ngân hàng" fields
5. Clicks "Cập nhật" button
6. Information is saved to database
7. Success message appears

### Admin Payment Processing
1. Admin navigates to Admin Dashboard
2. Clicks "Xử lý thanh toán" tab
3. Sees list of all RETURNED orders
4. Reviews user and manager bank account information
5. Clicks "Xác nhận thanh toán" button for an order
6. Modal opens showing:
   - Deposit amount to refund to user
   - Rental fee amount to pay manager
7. Admin uploads proof of deposit refund (bank transfer screenshot)
8. Admin uploads proof of manager payment (bank transfer screenshot)
9. Clicks "Xác nhận đã thanh toán"
10. Order status changes to COMPLETED
11. User receives notification: "Tiền cọc XXX VND của đơn hàng #YYY đã được hoàn lại vào tài khoản ngân hàng của bạn"
12. Manager receives notification: "Tiền thuê XXX VND của đơn hàng #YYY đã được chuyển vào tài khoản ngân hàng của bạn"

## Database Schema Changes

### Accounts Table (Before)
```sql
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(255),
    UserRole NVARCHAR(20) DEFAULT 'User',
    Status BIT DEFAULT 1,
    ...
);
```

### Accounts Table (After)
```sql
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(255),
    BankAccountNumber NVARCHAR(50),
    BankName NVARCHAR(100),
    UserRole NVARCHAR(20) DEFAULT 'User',
    Status BIT DEFAULT 1,
    ...
);
```

### RentalOrder Table (New Fields)
```sql
ALTER TABLE RentalOrder ADD RefundProofImage NVARCHAR(255);
ALTER TABLE RentalOrder ADD ManagerPaymentProofImage NVARCHAR(255);
ALTER TABLE RentalOrder ADD PaymentProcessedDate DATETIME;
```

## Files Modified

1. `ADD_BANK_ACCOUNT_NUMBER.sql` - Created
2. `ADD_PAYMENT_PROOF_FIELDS.sql` - Created
3. `src/java/Model/Account.java` - Updated
4. `src/java/Model/RentalOrder.java` - Updated
5. `src/java/DAO/AccountDAO.java` - Updated
6. `src/java/servlet/UserServlet.java` - Updated
7. `src/java/servlet/AdminServlet.java` - Updated
8. `web/WEB-INF/jsp/user/profile.jsp` - Updated
9. `web/WEB-INF/jsp/admin/dashboard.jsp` - Updated

## Testing Checklist

- [ ] Run ADD_BANK_ACCOUNT_NUMBER.sql on database
- [ ] Run ADD_PAYMENT_PROOF_FIELDS.sql on database
- [ ] Test user profile page displays bank account fields
- [ ] Test profile completion notification appears when fields are missing
- [ ] Test updating bank account information in profile
- [ ] Test admin can view payments page
- [ ] Test admin can see user and manager bank accounts
- [ ] Test admin can open payment confirmation modal
- [ ] Test payment confirmation creates COMPLETED order
- [ ] Test user receives deposit refund notification
- [ ] Test manager receives rental fee payment notification

## Next Steps (Future Enhancements)

1. **File Upload Handling**: Implement actual file upload for payment proof images
2. **Payment History**: Add view for users/managers to see payment history
3. **Bank Account Validation**: Add validation for bank account number format
4. **Payment Proof Display**: Allow users/managers to view payment proof images
5. **Payment Reports**: Generate financial reports for admin
6. **Automated Payments**: Integrate with payment gateway API
7. **Refund Tracking**: Track refund status (pending, processing, completed)

## Notes

- Bank account fields are optional (can be empty)
- Profile completion notification is non-intrusive (yellow info box)
- Payment proof upload currently accepts any image format
- File upload functionality will be fully implemented in future iteration
- For now, admin confirmation marks order as COMPLETED and sends notifications
