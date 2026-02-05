CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    OrderID INT NULL,
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Optional: add FK if Accounts table exists named Accounts(AccountID)
-- ALTER TABLE Notifications ADD CONSTRAINT FK_Notifications_User FOREIGN KEY (UserID) REFERENCES Accounts(AccountID);
