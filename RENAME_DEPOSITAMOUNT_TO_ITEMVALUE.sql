-- SQL Migration: Rename DepositAmount column to ItemValue in Clothing table
-- This script renames the DepositAmount column to ItemValue in the Clothing table
-- ItemValue represents the product value that users must pay when renting

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Clothing' AND COLUMN_NAME='DepositAmount')
BEGIN
    -- Rename the column from DepositAmount to ItemValue
    EXEC sp_rename 'Clothing.DepositAmount', 'ItemValue', 'COLUMN';
    PRINT 'Column DepositAmount renamed to ItemValue successfully.';
END
ELSE IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Clothing' AND COLUMN_NAME='ItemValue')
BEGIN
    PRINT 'Column ItemValue already exists. Migration already completed.';
END
ELSE
BEGIN
    PRINT 'Neither DepositAmount nor ItemValue column found. Please check the database schema.';
END
GO

PRINT 'Migration completed! The column has been renamed from DepositAmount to ItemValue.';
PRINT 'This value represents the product item value that users must pay when renting.';
