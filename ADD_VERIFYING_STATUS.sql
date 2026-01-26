-- =====================================================================
-- ADD VERIFYING STATUS TO RENTALORDER TABLE
-- =====================================================================
-- Script này thêm VERIFYING status vào RentalOrder
-- Không cần ALTER TABLE vì Status là VARCHAR - chỉ cần application update value
-- Execute: Chọn tất cả (Ctrl+A) → F5 hoặc Ctrl+Shift+E

USE [WearConnect];  -- Thay [WearConnect] bằng tên database của bạn nếu khác
GO

-- =====================================================================
-- 1. ADD PAYMENTPROOFIMAGE COLUMN TO PAYMENT TABLE
-- =====================================================================
PRINT '========== STEP 1: ADDING PAYMENT PROOF COLUMN ==========';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Payment' AND COLUMN_NAME='PaymentProofImage')
BEGIN
    ALTER TABLE Payment ADD PaymentProofImage VARCHAR(500) NULL;
    PRINT 'SUCCESS: Column PaymentProofImage added to Payment table';
END
ELSE
BEGIN
    PRINT 'INFO: Column PaymentProofImage already exists';
END;
GO

-- =====================================================================
-- 2. CREATE INDEX FOR PAYMENT PROOF
-- =====================================================================
PRINT '';
PRINT '========== STEP 2: CREATING INDEX FOR PERFORMANCE ==========';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_paymentProofImage' AND object_id = OBJECT_ID('Payment'))
BEGIN
    CREATE INDEX idx_paymentProofImage ON Payment(PaymentProofImage);
    PRINT 'SUCCESS: Index idx_paymentProofImage created';
END
ELSE
BEGIN
    PRINT 'INFO: Index idx_paymentProofImage already exists';
END;
GO

-- =====================================================================
-- 3. DISPLAY CURRENT PAYMENT STATUS VALUES
-- =====================================================================
PRINT '';
PRINT '========== STEP 3: CURRENT PAYMENT STATUS VALUES ==========';

SELECT DISTINCT PaymentStatus as [Current Status] FROM Payment ORDER BY PaymentStatus;
GO

-- =====================================================================
-- 4. DISPLAY CURRENT RENTALORDER STATUS VALUES
-- =====================================================================
PRINT '';
PRINT '========== STEP 4: CURRENT RENTALORDER STATUS VALUES ==========';

SELECT DISTINCT Status as [Current Status] FROM RentalOrder ORDER BY Status;
GO

-- =====================================================================
-- 5. TEST: UPDATE A SINGLE ORDER TO VERIFYING STATUS (Optional)
-- =====================================================================
PRINT '';
PRINT '========== STEP 5: TESTING VERIFYING STATUS ==========';

-- Tìm một đơn hàng PENDING để test
DECLARE @testOrderID INT;
SELECT TOP 1 @testOrderID = RentalOrderID FROM RentalOrder WHERE Status = 'PENDING' ORDER BY RentalOrderID;

IF @testOrderID IS NOT NULL
BEGIN
    PRINT 'Found test order ID: ' + CAST(@testOrderID AS VARCHAR(10));
    PRINT 'Current status: PENDING';
    PRINT 'Updating to: VERIFYING';
    
    -- UNCOMMENT dòng dưới để thực hiện UPDATE (tạm thời comment để an toàn)
    -- UPDATE RentalOrder SET Status = 'VERIFYING' WHERE RentalOrderID = @testOrderID;
    
    PRINT 'NOTE: Uncomment the UPDATE statement above to test (remove -- from line with UPDATE)';
END
ELSE
BEGIN
    PRINT 'No PENDING orders found to test';
END;
GO

-- =====================================================================
-- 6. VERIFY PAYMENT TABLE STRUCTURE
-- =====================================================================
PRINT '';
PRINT '========== STEP 6: PAYMENT TABLE STRUCTURE ==========';

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME='Payment' 
ORDER BY ORDINAL_POSITION;
GO

-- =====================================================================
-- 7. SUMMARY & NEXT STEPS
-- =====================================================================
PRINT '';
PRINT '===================================================================';
PRINT 'MIGRATION COMPLETE - SUMMARY';
PRINT '===================================================================';
PRINT '';
PRINT 'Database Changes:';
PRINT '  ✓ Column Added: PaymentProofImage (VARCHAR 500) to Payment table';
PRINT '  ✓ Index Created: idx_paymentProofImage';
PRINT '';
PRINT 'RentalOrder Status Flow:';
PRINT '  1. PENDING → User submits payment';
PRINT '  2. PENDING → VERIFYING (User uploads payment proof)';
PRINT '  3. VERIFYING → CONFIRMED (Admin verifies payment)';
PRINT '  4. CONFIRMED → RENTED (Clothing handed to renter)';
PRINT '  5. RENTED → RETURNED (Clothing returned)';
PRINT '';
PRINT 'Payment Status Values:';
PRINT '  • PENDING: Payment not yet made';
PRINT '  • COMPLETED: Payment successful';
PRINT '  • FAILED: Payment failed';
PRINT '  • REFUNDED: Payment refunded';
PRINT '';
PRINT 'How it works:';
PRINT '  1. User goes to payment page';
PRINT '  2. User selects Bank Transfer';
PRINT '  3. User uploads receipt image';
PRINT '  4. Application: Sets RentalOrder Status = VERIFYING';
PRINT '  5. Admin reviews payment proof image';
PRINT '  6. Admin confirms → RentalOrder Status = CONFIRMED';
PRINT '';
PRINT '===================================================================';
GO
