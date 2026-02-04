-- SQL Script for WearConnect Clothing Rental System
-- Database Tables

-- Table: Clothing (Quần áo)

CREATE TABLE Clothing (
    ClothingID INT PRIMARY KEY IDENTITY(1,1),
    RenterID INT NOT NULL,
    ClothingName NVARCHAR(255) NOT NULL,
    Category NVARCHAR(100),
    Style NVARCHAR(100),
    Size NVARCHAR(50),
    Description NVARCHAR(MAX),
    HourlyPrice DECIMAL(10, 2),
    DailyPrice DECIMAL(10, 2),
    ImagePath NVARCHAR(MAX),
    ImageData VARBINARY(MAX),
    AvailableFrom DATETIME,
    AvailableTo DATETIME,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RenterID) REFERENCES Accounts(AccountID)
);

-- Table: RentalOrder (Đơn thuê)
CREATE TABLE RentalOrder (
    RentalOrderID INT PRIMARY KEY IDENTITY(1,1),
    ClothingID INT NOT NULL,
    RenterUserID INT NOT NULL,
    RentalStartDate DATETIME NOT NULL,
    RentalEndDate DATETIME NOT NULL,
    TotalPrice DECIMAL(10, 2),
    DepositAmount DECIMAL(10, 2),
    SelectedSize NVARCHAR(50),
    Status NVARCHAR(50) DEFAULT 'PENDING_PAYMENT', -- PENDING_PAYMENT, PAYMENT_SUBMITTED, PAYMENT_VERIFIED, SHIPPING, DELIVERED_PENDING_CONFIRMATION, RENTED, RETURNED, CANCELLED
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClothingID) REFERENCES Clothing(ClothingID),
    FOREIGN KEY (RenterUserID) REFERENCES Accounts(AccountID)
);

-- Table: Payment (Thanh toán)
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    RentalOrderID INT NOT NULL,
    Amount DECIMAL(10, 2),
    PaymentMethod NVARCHAR(100), -- CREDIT_CARD, BANK_TRANSFER, CASH
    PaymentStatus NVARCHAR(50) DEFAULT 'PENDING', -- PENDING, COMPLETED, FAILED, REFUNDED
    PaymentDate DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RentalOrderID) REFERENCES RentalOrder(RentalOrderID)
);

-- Table: Rating (Đánh giá)
CREATE TABLE Rating (
    RatingID INT PRIMARY KEY IDENTITY(1,1),
    RentalOrderID INT NOT NULL,
    RatingFromUserID INT NOT NULL,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    Comment NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RentalOrderID) REFERENCES RentalOrder(RentalOrderID),
    FOREIGN KEY (RatingFromUserID) REFERENCES Accounts(AccountID)
);

-- Table: RentalHistory (Lịch sử thuê - để theo dõi trạng thái)
CREATE TABLE RentalHistory (
    HistoryID INT PRIMARY KEY IDENTITY(1,1),
    RentalOrderID INT NOT NULL,
    Status NVARCHAR(50),
    ChangedAt DATETIME DEFAULT GETDATE(),
    Notes NVARCHAR(MAX),
    FOREIGN KEY (RentalOrderID) REFERENCES RentalOrder(RentalOrderID)
);

-- Table: Favorites (Sản phẩm yêu thích)
CREATE TABLE Favorites (
    FavoriteID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    ClothingID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UNIQUE(UserID, ClothingID),
    FOREIGN KEY (UserID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (ClothingID) REFERENCES Clothing(ClothingID)
);
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Payment' AND COLUMN_NAME='bankTransactionRef')
    ALTER TABLE Payment ADD bankTransactionRef VARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Payment' AND COLUMN_NAME='bankTransferredAt')
    ALTER TABLE Payment ADD bankTransferredAt DATETIME NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Payment' AND COLUMN_NAME='senderAccount')
    ALTER TABLE Payment ADD senderAccount VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Payment' AND COLUMN_NAME='senderName')
    ALTER TABLE Payment ADD senderName VARCHAR(100) NULL;

-- Create indexes for performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_bankTransactionRef' AND object_id = OBJECT_ID('Payment'))
    CREATE INDEX idx_bankTransactionRef ON Payment(bankTransactionRef);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_paymentStatus' AND object_id = OBJECT_ID('Payment'))
    CREATE INDEX idx_paymentStatus ON Payment(paymentStatus);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_paymentMethod' AND object_id = OBJECT_ID('Payment'))
    CREATE INDEX idx_paymentMethod ON Payment(paymentMethod);

-- ===================================================================
-- 3. BANK CONFIGURATION TABLE (Optional - For Multiple Banks)
-- ===================================================================

-- Create table to store multiple bank configurations
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

-- Indexes for performance
CREATE INDEX idx_clothing_renter ON Clothing(RenterID);
CREATE INDEX idx_clothing_category ON Clothing(Category);
CREATE INDEX idx_rentalorder_clothing ON RentalOrder(ClothingID);
CREATE INDEX idx_rentalorder_renter ON RentalOrder(RenterUserID);
CREATE INDEX idx_rentalorder_status ON RentalOrder(Status);
CREATE INDEX idx_payment_order ON Payment(RentalOrderID);
CREATE INDEX idx_rating_order ON Rating(RentalOrderID);

-- Add columns to RentalOrder to store proof images and tracking info
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='PaymentProofImage')
    ALTER TABLE RentalOrder ADD PaymentProofImage NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ReceivedProofImage')
    ALTER TABLE RentalOrder ADD ReceivedProofImage NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='TrackingNumber')
    ALTER TABLE RentalOrder ADD TrackingNumber NVARCHAR(100) NULL;
