-- Update OrderIssue table to support images
ALTER TABLE OrderIssue ADD 
    ImagePath NVARCHAR(MAX),
    ImageData VARBINARY(MAX);

-- Alternative: Create OrderIssueImage table for multiple images per issue
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderIssueImage')
CREATE TABLE OrderIssueImage (
    ImageID INT PRIMARY KEY IDENTITY(1,1),
    IssueID INT NOT NULL,
    ImagePath NVARCHAR(MAX),
    ImageData VARBINARY(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IssueID) REFERENCES OrderIssue(IssueID)
);

-- Add ISSUE status to order status enum documentation
-- Status values: PENDING, VERIFYING, CONFIRMED, RENTED, RETURNED, COMPLETED, ISSUE, CANCELLED
