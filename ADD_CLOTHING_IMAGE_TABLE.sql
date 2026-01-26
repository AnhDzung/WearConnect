-- Migration: Create ClothingImage table to store multiple images per clothing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ClothingImage')
BEGIN
    CREATE TABLE ClothingImage (
        ImageID INT IDENTITY(1,1) PRIMARY KEY,
        ClothingID INT NOT NULL,
        ImagePath NVARCHAR(MAX) NULL,
        ImageData VARBINARY(MAX) NULL,
        IsPrimary BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_ClothingImage_Clothing FOREIGN KEY (ClothingID) REFERENCES Clothing(ClothingID)
    );
END
GO

-- Ensure index for lookup by ClothingID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ClothingImage_ClothingID' AND object_id = OBJECT_ID('ClothingImage'))
BEGIN
    CREATE INDEX IX_ClothingImage_ClothingID ON ClothingImage(ClothingID, IsPrimary DESC, CreatedAt DESC);
END
GO

PRINT 'ClothingImage table migration completed.';
