-- Migration Script: Add DepositAmount field to Clothing table
-- This allows managers to set custom deposit amount (not always 20%)

-- Add DepositAmount column to Clothing table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Clothing' AND COLUMN_NAME='DepositAmount')
BEGIN
    ALTER TABLE Clothing ADD DepositAmount DECIMAL(10, 2) NULL;
    PRINT 'Added DepositAmount column to Clothing table';
END
ELSE
BEGIN
    PRINT 'DepositAmount column already exists';
END
GO

-- Update existing records: calculate 20% of hourly price * 24 hours as default deposit
UPDATE Clothing 
SET DepositAmount = ROUND(HourlyPrice * 24 * 0.2, 2) 
WHERE DepositAmount IS NULL;
GO

PRINT 'Migration completed successfully!';
PRINT 'Managers can now set custom deposit amount when uploading clothing.';
PRINT 'Users will pay 100% of rental price (not just deposit).';
