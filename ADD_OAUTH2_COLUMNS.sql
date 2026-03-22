-- Migration Script: Add OAuth2 Support to Account Table
-- Safe to run multiple times (idempotent)

-- Step 1: Add OAuth2 columns if missing
IF COL_LENGTH('dbo.Accounts', 'OAuthProvider') IS NULL
BEGIN
    ALTER TABLE dbo.Accounts ADD OAuthProvider NVARCHAR(50) NULL;
    PRINT 'Added OAuthProvider column';
END
ELSE
BEGIN
    PRINT 'OAuthProvider column already exists';
END
GO

IF COL_LENGTH('dbo.Accounts', 'OAuthID') IS NULL
BEGIN
    ALTER TABLE dbo.Accounts ADD OAuthID NVARCHAR(255) NULL;
    PRINT 'Added OAuthID column';
END
ELSE
BEGIN
    PRINT 'OAuthID column already exists';
END
GO

IF COL_LENGTH('dbo.Accounts', 'GoogleID') IS NULL
BEGIN
    ALTER TABLE dbo.Accounts ADD GoogleID NVARCHAR(255) NULL;
    PRINT 'Added GoogleID column';
END
ELSE
BEGIN
    PRINT 'GoogleID column already exists';
END
GO

IF COL_LENGTH('dbo.Accounts', 'Avatar') IS NULL
BEGIN
    ALTER TABLE dbo.Accounts ADD Avatar NVARCHAR(500) NULL;
    PRINT 'Added Avatar column';
END
ELSE
BEGIN
    PRINT 'Avatar column already exists';
END
GO

-- Step 2: Create indexes (only after columns are guaranteed to exist)
IF COL_LENGTH('dbo.Accounts', 'GoogleID') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.indexes
       WHERE object_id = OBJECT_ID('dbo.Accounts')
         AND name = 'IX_Accounts_GoogleID'
   )
BEGIN
    CREATE UNIQUE INDEX IX_Accounts_GoogleID
    ON dbo.Accounts (GoogleID)
    WHERE GoogleID IS NOT NULL;
    PRINT 'Created unique index on GoogleID';
END
ELSE
BEGIN
    PRINT 'Index IX_Accounts_GoogleID already exists or GoogleID not found';
END
GO

IF COL_LENGTH('dbo.Accounts', 'OAuthProvider') IS NOT NULL
   AND COL_LENGTH('dbo.Accounts', 'OAuthID') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.indexes
       WHERE object_id = OBJECT_ID('dbo.Accounts')
         AND name = 'IX_Accounts_OAuthProvider_OAuthID'
   )
BEGIN
    CREATE UNIQUE INDEX IX_Accounts_OAuthProvider_OAuthID
    ON dbo.Accounts (OAuthProvider, OAuthID)
    WHERE OAuthProvider IS NOT NULL AND OAuthID IS NOT NULL;
    PRINT 'Created unique index on OAuthProvider and OAuthID';
END
ELSE
BEGIN
    PRINT 'Index IX_Accounts_OAuthProvider_OAuthID already exists or columns not found';
END
GO

-- Step 3: Verify
PRINT '';
PRINT 'Account table schema after migration:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Accounts'
  AND COLUMN_NAME IN ('OAuthProvider', 'OAuthID', 'GoogleID', 'Avatar')
ORDER BY ORDINAL_POSITION;
