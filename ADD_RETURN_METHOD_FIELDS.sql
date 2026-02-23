-- Add ReturnMethod and ReturnTrackingNumber fields to RentalOrder table
-- For managing return shipping methods and tracking

-- ReturnMethod: Manager chọn phương thức nhận hàng trả về
-- Values: 'MANAGER_PICKUP' (Manager đến lấy) hoặc 'SHIP_TO_MANAGER' (User gửi về)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ReturnMethod')
    ALTER TABLE RentalOrder ADD ReturnMethod NVARCHAR(50) NULL;

-- ReturnTrackingNumber: Mã vận đơn khi user gửi hàng về cho manager
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ReturnTrackingNumber')
    ALTER TABLE RentalOrder ADD ReturnTrackingNumber NVARCHAR(100) NULL;

-- Create index for performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_return_method' AND object_id = OBJECT_ID('RentalOrder'))
    CREATE INDEX idx_return_method ON RentalOrder(ReturnMethod);

PRINT 'ReturnMethod and ReturnTrackingNumber fields added successfully to RentalOrder table.';
