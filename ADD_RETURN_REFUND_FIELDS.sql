-- SQL Migration: Add Return & Refund Fields to RentalOrder table
-- This script adds fields to support dynamic deposit calculation and return handling
-- Thêm các trường để hỗ trợ tính cọc động và xử lý trả hàng

-- Add fields for trust-based deposit adjustment
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='UserRating')
BEGIN
    ALTER TABLE RentalOrder ADD UserRating DECIMAL(3,1) DEFAULT 0;
    PRINT 'Added UserRating column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='TrustBasedMultiplier')
BEGIN
    ALTER TABLE RentalOrder ADD TrustBasedMultiplier DECIMAL(3,2) DEFAULT 1.0;
    PRINT 'Added TrustBasedMultiplier column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='AdjustedDepositAmount')
BEGIN
    ALTER TABLE RentalOrder ADD AdjustedDepositAmount DECIMAL(10,2);
    PRINT 'Added AdjustedDepositAmount column';
END

-- Add fields for return handling and refund calculation
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ActualReturnDate')
BEGIN
    ALTER TABLE RentalOrder ADD ActualReturnDate DATETIME NULL;
    PRINT 'Added ActualReturnDate column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ReturnStatus')
BEGIN
    ALTER TABLE RentalOrder ADD ReturnStatus NVARCHAR(50) NULL; -- NO_DAMAGE, LATE_RETURN, MINOR_DAMAGE, LOST
    PRINT 'Added ReturnStatus column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='DamagePercentage')
BEGIN
    ALTER TABLE RentalOrder ADD DamagePercentage DECIMAL(3,2) DEFAULT 0; -- 0.0 to 1.0
    PRINT 'Added DamagePercentage column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='LateFees')
BEGIN
    ALTER TABLE RentalOrder ADD LateFees DECIMAL(10,2) DEFAULT 0;
    PRINT 'Added LateFees column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='CompensationAmount')
BEGIN
    ALTER TABLE RentalOrder ADD CompensationAmount DECIMAL(10,2) DEFAULT 0;
    PRINT 'Added CompensationAmount column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='RefundAmount')
BEGIN
    ALTER TABLE RentalOrder ADD RefundAmount DECIMAL(10,2) DEFAULT 0;
    PRINT 'Added RefundAmount column';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='AdditionalCharges')
BEGIN
    ALTER TABLE RentalOrder ADD AdditionalCharges DECIMAL(10,2) DEFAULT 0;
    PRINT 'Added AdditionalCharges column';
END

PRINT 'Migration completed successfully!';
PRINT 'All return and refund fields have been added to RentalOrder table.';
GO
