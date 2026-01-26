-- Migration Script: Add Quantity field to Clothing table
-- This allows shops to have multiple items of the same clothing design

-- Add Quantity column to Clothing table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Clothing' AND COLUMN_NAME='Quantity')
BEGIN
    ALTER TABLE Clothing ADD Quantity INT NOT NULL DEFAULT 1;
    PRINT 'Added Quantity column to Clothing table';
END
ELSE
BEGIN
    PRINT 'Quantity column already exists';
END
GO

-- Update existing records to have quantity of 1 (backward compatibility)
UPDATE Clothing SET Quantity = 1 WHERE Quantity IS NULL OR Quantity = 0;
GO

-- Add check constraint to ensure quantity is always positive
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_Clothing_Quantity_Positive')
BEGIN
    ALTER TABLE Clothing ADD CONSTRAINT CHK_Clothing_Quantity_Positive CHECK (Quantity > 0);
    PRINT 'Added check constraint for positive quantity';
END
GO

PRINT 'Migration completed successfully!';
PRINT 'Now you can have multiple items of the same clothing design.';
PRINT 'Example: "Áo sơ mi trắng size M" can have Quantity = 5';
