-- Migration: Add SelectedSize column to RentalOrder to store user's chosen size
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'RentalOrder' AND COLUMN_NAME = 'SelectedSize'
)
BEGIN
    ALTER TABLE RentalOrder ADD SelectedSize NVARCHAR(50) NULL;
END;
