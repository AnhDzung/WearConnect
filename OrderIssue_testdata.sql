-- Test Data for Issue Reporting System
-- This script populates sample data to test the issue reporting workflow

-- First, ensure OrderIssue table exists
EXEC sp_executesql N'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[OrderIssue]'') AND type in (N''U''))
BEGIN
    CREATE TABLE [dbo].[OrderIssue] (
        [IssueID] [int] IDENTITY(1,1) PRIMARY KEY,
        [RentalOrderID] [int] NOT NULL,
        [RenterUserID] [int] NOT NULL,
        [IssueType] [nvarchar](50) NOT NULL,
        [Description] [nvarchar](max) NOT NULL,
        [Status] [nvarchar](20) NOT NULL DEFAULT ''PENDING'',
        [CreatedAt] [datetime] NOT NULL DEFAULT GETDATE(),
        [ResolvedAt] [datetime],
        [Notes] [nvarchar](max),
        [ImagePath] [nvarchar](255),
        [ImageData] [varbinary](max),
        FOREIGN KEY ([RentalOrderID]) REFERENCES [dbo].[RentalOrder]([RentalOrderID]),
        FOREIGN KEY ([RenterUserID]) REFERENCES [dbo].[Account]([AccountID])
    );
    PRINT ''OrderIssue table created'';
END
';

-- Find a rental order that is in ISSUE status for testing
-- If no ISSUE orders exist, you can manually change an order status to ISSUE first
-- Or you can create sample issues with this script

-- Sample issue #1: Damaged item
INSERT INTO [dbo].[OrderIssue] 
([RentalOrderID], [RenterUserID], [IssueType], [Description], [Status], [CreatedAt], [Notes], [ImagePath])
SELECT TOP 1 
    ro.RentalOrderID, 
    ro.RenterUserID, 
    'DAMAGED', 
    'The dress has a small tear near the hem. The quality is not as expected.',
    'PENDING',
    DATEADD(DAY, -1, GETDATE()),
    NULL,
    'issues/damaged_dress_1.jpg'
FROM RentalOrder ro
WHERE ro.Status = 'RENTED' AND ro.RentalOrderID > 0
AND NOT EXISTS (SELECT 1 FROM OrderIssue WHERE RentalOrderID = ro.RentalOrderID)
PRINT 'Sample damaged item issue created (if rental order found)';

-- Sample issue #2: Wrong size
INSERT INTO [dbo].[OrderIssue] 
([RentalOrderID], [RenterUserID], [IssueType], [Description], [Status], [CreatedAt], [Notes], [ImagePath])
SELECT TOP 1 
    ro.RentalOrderID, 
    ro.RenterUserID, 
    'WRONG_SIZE', 
    'The size is much smaller than advertised. It does not fit at all.',
    'ACKNOWLEDGED',
    DATEADD(DAY, -2, GETDATE()),
    'We apologize for this error. Please return the item and we will provide a replacement.',
    'issues/wrong_size_1.jpg'
FROM RentalOrder ro
WHERE ro.Status = 'RENTED' AND ro.RentalOrderID > 1
AND NOT EXISTS (SELECT 1 FROM OrderIssue WHERE RentalOrderID = ro.RentalOrderID)
PRINT 'Sample wrong size issue created (if rental order found)';

-- Sample issue #3: Resolved issue
INSERT INTO [dbo].[OrderIssue] 
([RentalOrderID], [RenterUserID], [IssueType], [Description], [Status], [CreatedAt], [ResolvedAt], [Notes], [ImagePath])
SELECT TOP 1 
    ro.RentalOrderID, 
    ro.RenterUserID, 
    'COLOR_MISMATCH', 
    'The color is not as shown in the pictures. It appears more pink than red.',
    'RESOLVED',
    DATEADD(DAY, -5, GETDATE()),
    DATEADD(DAY, -4, GETDATE()),
    'Customer approved color adjustment. Full refund of 50% applied.',
    'issues/color_mismatch_1.jpg'
FROM RentalOrder ro
WHERE ro.Status IN ('RETURNED', 'COMPLETED') AND ro.RentalOrderID > 2
AND NOT EXISTS (SELECT 1 FROM OrderIssue WHERE RentalOrderID = ro.RentalOrderID)
PRINT 'Sample resolved issue created (if rental order found)';

-- View all issues
SELECT * FROM OrderIssue ORDER BY CreatedAt DESC;

PRINT '
==================================================
Issue Reporting System Test Data
==================================================
Note: To test the complete workflow:
1. Create a rental order and mark status as RENTED
2. Use the web interface to report an issue with image upload
3. The order status will auto-change to ISSUE
4. Manager can then view and handle the issue

To view created issues, run:
SELECT * FROM OrderIssue ORDER BY CreatedAt DESC;

To check order status:
SELECT RentalOrderID, OrderCode, Status FROM RentalOrder WHERE Status = ''ISSUE'';
';
