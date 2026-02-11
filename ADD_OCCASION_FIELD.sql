-- Migration: Add Occasion column to Clothing
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Clothing' AND COLUMN_NAME = 'Occasion'
)
BEGIN
    ALTER TABLE Clothing ADD Occasion NVARCHAR(100) NULL;
END;
