-- Migration: Normalize existing Category and Style values to new labels
UPDATE Clothing SET Category = N'Váy' WHERE Category = 'Dress';
UPDATE Clothing SET Category = N'Áo' WHERE Category = 'Shirt';
UPDATE Clothing SET Category = N'Quần' WHERE Category = 'Pants';
UPDATE Clothing SET Category = N'Áo khoác' WHERE Category = 'Jacket';
UPDATE Clothing SET Category = N'Phụ kiện' WHERE Category = 'Accessories';

UPDATE Clothing SET Style = N'Thường ngày' WHERE Style = 'Casual';
UPDATE Clothing SET Style = N'Trang trọng' WHERE Style = 'Formal';
UPDATE Clothing SET Style = N'Dự tiệc' WHERE Style = 'Party';
UPDATE Clothing SET Style = N'Thể thao' WHERE Style = 'Sport';
-- Keep existing 'Vintage' values as-is for the new Vintage option
