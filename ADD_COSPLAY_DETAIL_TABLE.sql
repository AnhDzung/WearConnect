-- Migration script to add CosplayDetail table for specialized cosplay products
-- This table stores extended metadata for clothing items with Category='Cosplay'

-- Create CosplayDetail table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CosplayDetail' AND xtype='U')
BEGIN
    CREATE TABLE CosplayDetail (
        DetailID INT IDENTITY(1,1) PRIMARY KEY,
        ClothingID INT NOT NULL,
        CharacterName NVARCHAR(200) NOT NULL,
        Series NVARCHAR(200) NOT NULL,
        CosplayType NVARCHAR(50) NOT NULL, -- 'Anime', 'Game', 'Movie'
        AccuracyLevel NVARCHAR(50) NOT NULL, -- 'Cao', 'Trung bình', 'Cơ bản'
        AccessoryList NVARCHAR(MAX) NULL, -- Comma-separated list or JSON
        CreatedAt DATETIME DEFAULT GETDATE(),
        UpdatedAt DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_CosplayDetail_Clothing FOREIGN KEY (ClothingID) 
            REFERENCES Clothing(ClothingID) ON DELETE CASCADE
    );
    
    PRINT 'CosplayDetail table created successfully';
END
ELSE
BEGIN
    PRINT 'CosplayDetail table already exists';
END
GO

-- Add ClothingStatus column to Clothing table if not exists
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Clothing' AND COLUMN_NAME = 'ClothingStatus')
BEGIN
    ALTER TABLE Clothing ADD ClothingStatus NVARCHAR(50) NULL;
    
    -- Update existing records to ACTIVE
    UPDATE Clothing SET ClothingStatus = 'ACTIVE';
    
    -- Make it NOT NULL with default after update
    ALTER TABLE Clothing ALTER COLUMN ClothingStatus NVARCHAR(50) NOT NULL;
    
    -- Add default constraint
    ALTER TABLE Clothing ADD CONSTRAINT DF_Clothing_ClothingStatus DEFAULT 'ACTIVE' FOR ClothingStatus;
    
    PRINT 'ClothingStatus column added to Clothing table';
END
ELSE
BEGIN
    PRINT 'ClothingStatus column already exists in Clothing table';
END
GO

-- Possible ClothingStatus values:
-- 'ACTIVE' - normal products available for rent
-- 'PENDING_COSPLAY_REVIEW' - cosplay products awaiting admin approval
-- 'APPROVED_COSPLAY' - cosplay products approved by admin
-- 'INACTIVE' - disabled products
