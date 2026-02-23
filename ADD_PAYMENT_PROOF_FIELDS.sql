-- Add payment proof image fields to RentalOrder table
-- These fields store the proof of payment uploaded by admin

USE WearConnect;
GO

-- Add RefundProofImage field (proof of deposit refund to user)
ALTER TABLE RentalOrder
ADD RefundProofImage NVARCHAR(255);

-- Add ManagerPaymentProofImage field (proof of rental fee payment to manager)
ALTER TABLE RentalOrder
ADD ManagerPaymentProofImage NVARCHAR(255);

-- Add PaymentProcessedDate field (when admin processed the payment)
ALTER TABLE RentalOrder
ADD PaymentProcessedDate DATETIME;

GO

PRINT 'Payment proof fields added successfully to RentalOrder table';
