-- Add BankAccountNumber field to Accounts table
-- For users and managers to receive payments/refunds

-- BankAccountNumber: Số tài khoản ngân hàng để nhận tiền
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Accounts' AND COLUMN_NAME='BankAccountNumber')
    ALTER TABLE Accounts ADD BankAccountNumber NVARCHAR(50) NULL;

-- BankName: Tên ngân hàng
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Accounts' AND COLUMN_NAME='BankName')
    ALTER TABLE Accounts ADD BankName NVARCHAR(100) NULL;

-- Create index for performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_bank_account' AND object_id = OBJECT_ID('Accounts'))
    CREATE INDEX idx_bank_account ON Accounts(BankAccountNumber);

PRINT 'BankAccountNumber and BankName fields added successfully to Accounts table.';
