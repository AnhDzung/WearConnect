-- SQL Script to create OrderIssue table if it doesn't exist
-- Run this script to set up the OrderIssue table for issue reporting

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderIssue]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[OrderIssue] (
        [IssueID] [int] IDENTITY(1,1) PRIMARY KEY,
        [RentalOrderID] [int] NOT NULL,
        [RenterUserID] [int] NOT NULL,
        [IssueType] [nvarchar](50) NOT NULL, -- WRONG_ITEM, DAMAGED, WRONG_SIZE, COLOR_MISMATCH, OTHER
        [Description] [nvarchar](max) NOT NULL,
        [Status] [nvarchar](20) NOT NULL DEFAULT 'PENDING', -- PENDING, ACKNOWLEDGED, RESOLVED, REJECTED
        [CreatedAt] [datetime] NOT NULL DEFAULT GETDATE(),
        [ResolvedAt] [datetime],
        [Notes] [nvarchar](max),
        [ImagePath] [nvarchar](255),
        [ImageData] [varbinary](max),
        
        FOREIGN KEY ([RentalOrderID]) REFERENCES [dbo].[RentalOrder]([RentalOrderID]),
        FOREIGN KEY ([RenterUserID]) REFERENCES [dbo].[Account]([AccountID])
    );
    
    PRINT 'OrderIssue table created successfully';
END
ELSE
BEGIN
    -- If table exists, add columns if they don't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[OrderIssue]') AND name = N'ImagePath')
    BEGIN
        ALTER TABLE [dbo].[OrderIssue] ADD [ImagePath] [nvarchar](255);
        PRINT 'Added ImagePath column to OrderIssue table';
    END;
    
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[OrderIssue]') AND name = N'ImageData')
    BEGIN
        ALTER TABLE [dbo].[OrderIssue] ADD [ImageData] [varbinary](max);
        PRINT 'Added ImageData column to OrderIssue table';
    END;
END;

-- Create index for faster queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderIssue_RentalOrderID' AND object_id = OBJECT_ID(N'[dbo].[OrderIssue]'))
BEGIN
    CREATE INDEX [IX_OrderIssue_RentalOrderID] ON [dbo].[OrderIssue]([RentalOrderID]);
END;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderIssue_Status' AND object_id = OBJECT_ID(N'[dbo].[OrderIssue]'))
BEGIN
    CREATE INDEX [IX_OrderIssue_Status] ON [dbo].[OrderIssue]([Status]);
END;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderIssue_CreatedAt' AND object_id = OBJECT_ID(N'[dbo].[OrderIssue]'))
BEGIN
    CREATE INDEX [IX_OrderIssue_CreatedAt] ON [dbo].[OrderIssue]([CreatedAt]);
END;

PRINT 'OrderIssue table setup complete';
