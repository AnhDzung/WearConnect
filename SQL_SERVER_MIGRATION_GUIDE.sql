-- ===================================================================
-- SQL SERVER SYNTAX GUIDE - BANK TRANSFER INTEGRATION
-- ===================================================================
-- This file provides SQL Server compatible syntax
-- Previous MySQL syntax has been corrected
-- ===================================================================

-- ===================================================================
-- SECTION 1: ALTER TABLE - ADD COLUMNS (SQL Server)
-- ===================================================================

-- Option 1: Add columns one by one (Recommended for SQL Server)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME='Payment' AND COLUMN_NAME='bankTransactionRef')
    ALTER TABLE Payment ADD bankTransactionRef VARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME='Payment' AND COLUMN_NAME='bankTransferredAt')
    ALTER TABLE Payment ADD bankTransferredAt DATETIME NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME='Payment' AND COLUMN_NAME='senderAccount')
    ALTER TABLE Payment ADD senderAccount VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME='Payment' AND COLUMN_NAME='senderName')
    ALTER TABLE Payment ADD senderName VARCHAR(100) NULL;

-- ===================================================================
-- SECTION 2: CREATE INDEXES (SQL Server)
-- ===================================================================

IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'idx_bankTransactionRef' 
               AND object_id = OBJECT_ID('Payment'))
    CREATE INDEX idx_bankTransactionRef ON Payment(bankTransactionRef);

IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'idx_paymentStatus' 
               AND object_id = OBJECT_ID('Payment'))
    CREATE INDEX idx_paymentStatus ON Payment(paymentStatus);

IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'idx_paymentMethod' 
               AND object_id = OBJECT_ID('Payment'))
    CREATE INDEX idx_paymentMethod ON Payment(paymentMethod);

-- ===================================================================
-- SECTION 3: CREATE TABLE WITH IDENTITY (SQL Server)
-- ===================================================================

-- SQL Server uses IDENTITY instead of AUTO_INCREMENT
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BankConfig')
CREATE TABLE BankConfig (
    bankConfigID INT PRIMARY KEY IDENTITY(1,1),
    bankCode VARCHAR(10) UNIQUE NOT NULL,
    bankName VARCHAR(100) NOT NULL,
    accountNumber VARCHAR(50) NOT NULL,
    accountHolderName VARCHAR(100) NOT NULL,
    branch VARCHAR(100) NOT NULL,
    isActive BIT DEFAULT 1,
    createdAt DATETIME DEFAULT GETDATE(),
    updatedAt DATETIME DEFAULT GETDATE()
);

-- ===================================================================
-- SECTION 4: INSERT DATA (Same in both)
-- ===================================================================

IF NOT EXISTS (SELECT * FROM BankConfig WHERE bankCode = 'MBB')
INSERT INTO BankConfig (bankCode, bankName, accountNumber, accountHolderName, branch) 
VALUES ('MBB', 'MB Bank', '1406200368', 'WearConnect', 'Chi nhánh Hà Nội');

-- ===================================================================
-- SECTION 5: CREATE AUDIT TABLE (SQL Server)
-- ===================================================================

-- TEXT -> VARCHAR(MAX) for SQL Server
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentAuditLog')
CREATE TABLE PaymentAuditLog (
    auditID INT PRIMARY KEY IDENTITY(1,1),
    paymentID INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    oldStatus VARCHAR(50),
    newStatus VARCHAR(50),
    changedBy VARCHAR(100),
    changedAt DATETIME DEFAULT GETDATE(),
    details VARCHAR(MAX),
    FOREIGN KEY (paymentID) REFERENCES Payment(paymentID)
);

-- ===================================================================
-- SECTION 6: STORED PROCEDURE (SQL Server)
-- ===================================================================

-- SQL Server uses CREATE PROCEDURE (not DELIMITER, BEGIN/END)
IF EXISTS (SELECT * FROM sys.objects 
           WHERE type = 'P' AND name = 'sp_verify_bank_transfer')
    DROP PROCEDURE sp_verify_bank_transfer;
GO

CREATE PROCEDURE sp_verify_bank_transfer
    @p_paymentID INT,
    @p_transactionRef VARCHAR(100),
    @p_senderAccount VARCHAR(50),
    @p_senderName VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if payment exists
        IF NOT EXISTS (SELECT 1 FROM Payment WHERE paymentID = @p_paymentID)
        BEGIN
            ROLLBACK;
            SELECT 'PAYMENT_NOT_FOUND' as status;
        END
        ELSE
        BEGIN
            -- Update payment
            UPDATE Payment 
            SET 
                paymentStatus = 'COMPLETED',
                bankTransactionRef = @p_transactionRef,
                bankTransferredAt = GETDATE(),
                senderAccount = @p_senderAccount,
                senderName = @p_senderName
            WHERE paymentID = @p_paymentID;
            
            -- Update rental order status
            UPDATE RentalOrder
            SET status = 'CONFIRMED'
            WHERE rentalOrderID = (SELECT rentalOrderID FROM Payment WHERE paymentID = @p_paymentID);
            
            COMMIT;
            SELECT 'SUCCESS' as status;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT 'ERROR' as status;
    END CATCH
END;
GO

-- Usage:
-- EXEC sp_verify_bank_transfer @p_paymentID=5, @p_transactionRef='MB-TXN-12345', 
--                               @p_senderAccount='1234567890', @p_senderName='Nguyen Van B';

-- ===================================================================
-- SECTION 7: USEFUL QUERIES (SQL Server)
-- ===================================================================

-- Query 1: Get all pending bank transfers
SELECT 
    p.paymentID,
    p.rentalOrderID,
    p.amount,
    p.paymentMethod,
    p.paymentStatus,
    p.createdAt,
    ro.rentDate,
    ro.returnDate,
    a.accountName
FROM Payment p
JOIN RentalOrder ro ON p.rentalOrderID = ro.rentalOrderID
JOIN Account a ON ro.accountID = a.accountID
WHERE p.paymentMethod = 'BANK_TRANSFER' 
  AND p.paymentStatus = 'PENDING'
ORDER BY p.createdAt DESC;

-- Query 2: Revenue by payment method
SELECT 
    p.paymentMethod,
    COUNT(*) as transaction_count,
    SUM(p.amount) as total_amount,
    AVG(p.amount) as average_amount
FROM Payment p
WHERE p.paymentStatus = 'COMPLETED'
GROUP BY p.paymentMethod
ORDER BY total_amount DESC;

-- Query 3: Daily bank transfer summary
SELECT 
    CAST(p.createdAt AS DATE) as transaction_date,
    COUNT(*) as count,
    SUM(p.amount) as total_amount
FROM Payment p
WHERE p.paymentMethod = 'BANK_TRANSFER'
  AND p.paymentStatus = 'COMPLETED'
GROUP BY CAST(p.createdAt AS DATE)
ORDER BY transaction_date DESC;

-- Query 4: Payment history by customer
SELECT 
    p.paymentID,
    p.amount,
    p.paymentMethod,
    p.paymentStatus,
    p.createdAt,
    ro.rentalOrderID
FROM Payment p
JOIN RentalOrder ro ON p.rentalOrderID = ro.rentalOrderID
WHERE ro.accountID = 1
ORDER BY p.createdAt DESC;

-- ===================================================================
-- SECTION 8: KEY DIFFERENCES - MySQL vs SQL Server
-- ===================================================================

/*
MySQL Syntax              →  SQL Server Syntax
─────────────────────────────────────────────────────

AUTO_INCREMENT            →  IDENTITY(1,1)
BOOLEAN                   →  BIT
CURRENT_TIMESTAMP         →  GETDATE()
DEFAULT CURRENT_TIMESTAMP →  DEFAULT GETDATE()
TEXT COMMENT 'x'          →  VARCHAR(MAX)
DELIMITER $$              →  GO
CREATE PROCEDURE ... IN   →  CREATE PROCEDURE ... @
IF NOT EXISTS ... THEN    →  IF ... BEGIN ... END
NOW()                     →  GETDATE()
COLUMN COMMENT            →  No comment syntax (use sp_addextendedproperty)

MySQL:
ALTER TABLE t ADD COLUMN (
    col1 TYPE,
    col2 TYPE
);

SQL Server:
ALTER TABLE t ADD col1 TYPE;
ALTER TABLE t ADD col2 TYPE;
-- OR use IF NOT EXISTS for safety
*/

-- ===================================================================
-- SECTION 9: CREATE VIEW (SQL Server)
-- ===================================================================

IF EXISTS (SELECT * FROM sys.views WHERE name = 'v_payment_summary')
    DROP VIEW v_payment_summary;
GO

CREATE VIEW v_payment_summary AS
SELECT 
    p.paymentID,
    p.rentalOrderID,
    CONCAT('WRC', RIGHT('00000' + CAST(p.rentalOrderID AS VARCHAR(5)), 5)) as order_code,
    p.amount,
    p.paymentMethod,
    p.paymentStatus,
    p.createdAt,
    p.paymentDate,
    a.accountName as customer_name,
    a.email,
    c.clothingName,
    ro.rentDate,
    ro.returnDate,
    DATEDIFF(DAY, ro.rentDate, ro.returnDate) as rental_days
FROM Payment p
LEFT JOIN RentalOrder ro ON p.rentalOrderID = ro.rentalOrderID
LEFT JOIN Account a ON ro.accountID = a.accountID
LEFT JOIN Clothing c ON ro.clothingID = c.clothingID;

-- Usage:
-- SELECT * FROM v_payment_summary WHERE paymentMethod = 'BANK_TRANSFER';

-- ===================================================================
-- SUMMARY
-- ===================================================================

-- All MySQL syntax has been converted to SQL Server
-- Key changes:
-- ✓ AUTO_INCREMENT → IDENTITY(1,1)
-- ✓ ADD COLUMN (multiple) → ADD one at a time
-- ✓ Removed COMMENT (use extended properties if needed)
-- ✓ Stored procedure syntax updated
-- ✓ GETDATE() instead of NOW()
-- ✓ BIT instead of BOOLEAN
-- ✓ VARCHAR(MAX) instead of TEXT
-- ✓ Added IF EXISTS checks for safety

-- All queries are now SQL Server compatible!
