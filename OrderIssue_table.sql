-- Table: OrderIssue (Báo cáo vấn đề với đơn thuê)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderIssue')
CREATE TABLE OrderIssue (
    IssueID INT PRIMARY KEY IDENTITY(1,1),
    RentalOrderID INT NOT NULL,
    RenterUserID INT NOT NULL,
    IssueType NVARCHAR(50), -- WRONG_ITEM, DAMAGED, WRONG_SIZE, COLOR_MISMATCH, OTHER
    Description NVARCHAR(MAX),
    Status NVARCHAR(50) DEFAULT 'PENDING', -- PENDING, ACKNOWLEDGED, RESOLVED, REJECTED
    CreatedAt DATETIME DEFAULT GETDATE(),
    ResolvedAt DATETIME NULL,
    Notes NVARCHAR(MAX),
    FOREIGN KEY (RentalOrderID) REFERENCES RentalOrder(RentalOrderID),
    FOREIGN KEY (RenterUserID) REFERENCES Accounts(AccountID)
);

-- Index
CREATE INDEX idx_orderissue_order ON OrderIssue(RentalOrderID);
CREATE INDEX idx_orderissue_status ON OrderIssue(Status);
