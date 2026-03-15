-- Add binary columns for storing uploaded proof images directly in DB

-- Payment table: customer payment proof image bytes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Payment' AND COLUMN_NAME='PaymentProofImageData')
BEGIN
    ALTER TABLE Payment ADD PaymentProofImageData VARBINARY(MAX) NULL;
    PRINT 'Added Payment.PaymentProofImageData';
END

-- RentalOrder table: proof image bytes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='PaymentProofImageData')
BEGIN
    ALTER TABLE RentalOrder ADD PaymentProofImageData VARBINARY(MAX) NULL;
    PRINT 'Added RentalOrder.PaymentProofImageData';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ReceivedProofImageData')
BEGIN
    ALTER TABLE RentalOrder ADD ReceivedProofImageData VARBINARY(MAX) NULL;
    PRINT 'Added RentalOrder.ReceivedProofImageData';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='RefundProofImageData')
BEGIN
    ALTER TABLE RentalOrder ADD RefundProofImageData VARBINARY(MAX) NULL;
    PRINT 'Added RentalOrder.RefundProofImageData';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='RentalOrder' AND COLUMN_NAME='ManagerPaymentProofImageData')
BEGIN
    ALTER TABLE RentalOrder ADD ManagerPaymentProofImageData VARBINARY(MAX) NULL;
    PRINT 'Added RentalOrder.ManagerPaymentProofImageData';
END

PRINT 'Proof image binary column migration completed.';
