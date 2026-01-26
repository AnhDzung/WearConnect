-- SQL Migration: Add Color Management Feature
-- Tạo bảng Color để quản lý màu sắc
CREATE TABLE Color (
    ColorID INT PRIMARY KEY IDENTITY(1,1),
    ColorName NVARCHAR(100) NOT NULL,
    HexCode NVARCHAR(20), -- Mã màu hex (optional)
    ManagerID INT, -- NULL nếu là màu cơ bản toàn cục
    IsGlobal BIT DEFAULT 1, -- 1 = toàn cục, 0 = riêng manager
    CreatedAt DATETIME DEFAULT GETDATE(),
    UNIQUE(ColorName, ManagerID),
    FOREIGN KEY (ManagerID) REFERENCES Accounts(AccountID)
);

-- Tạo bảng ClothingColor để liên kết quần áo với màu sắc
CREATE TABLE ClothingColor (
    ClothingColorID INT PRIMARY KEY IDENTITY(1,1),
    ClothingID INT NOT NULL,
    ColorID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UNIQUE(ClothingID, ColorID),
    FOREIGN KEY (ClothingID) REFERENCES Clothing(ClothingID),
    FOREIGN KEY (ColorID) REFERENCES Color(ColorID) ON DELETE CASCADE
);

-- Thêm cột ColorID vào RentalOrder để lưu màu sắc được chọn
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ColorID')
    ALTER TABLE RentalOrder ADD ColorID INT NULL, FOREIGN KEY (ColorID) REFERENCES Color(ColorID);

-- Seed các màu cơ bản toàn cục
SET IDENTITY_INSERT Color ON;
INSERT INTO Color (ColorID, ColorName, HexCode, ManagerID, IsGlobal, CreatedAt) VALUES 
    (1, N'Đen', '#000000', NULL, 1, GETDATE()),
    (2, N'Trắng', '#FFFFFF', NULL, 1, GETDATE()),
    (3, N'Đỏ', '#FF0000', NULL, 1, GETDATE()),
    (4, N'Xanh dương', '#0000FF', NULL, 1, GETDATE()),
    (5, N'Xanh lá', '#00AA00', NULL, 1, GETDATE()),
    (6, N'Vàng', '#FFFF00', NULL, 1, GETDATE()),
    (7, N'Nâu', '#8B4513', NULL, 1, GETDATE()),
    (8, N'Xám', '#808080', NULL, 1, GETDATE()),
    (9, N'Hồng', '#FFC0CB', NULL, 1, GETDATE()),
    (10, N'Tím', '#800080', NULL, 1, GETDATE()),
    (11, N'Cam', '#FFA500', NULL, 1, GETDATE());
SET IDENTITY_INSERT Color OFF;

-- Tạo index để tối ưu hiệu suất
CREATE INDEX idx_color_manager ON Color(ManagerID);
CREATE INDEX idx_clothing_color_clothing ON ClothingColor(ClothingID);
CREATE INDEX idx_color_is_global ON Color(IsGlobal);
