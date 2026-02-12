-- Script để admin duyệt cosplay thủ công trong SQL Server
-- Sử dụng script này cho đến khi có giao diện admin review

-- 1. XEM TẤT CẢ COSPLAY ĐANG CHỜ DUYỆT
SELECT 
    c.ClothingID,
    c.ClothingName,
    c.ClothingStatus,
    cd.CharacterName,
    cd.Series,
    cd.CosplayType,
    cd.AccuracyLevel,
    cd.AccessoryList,
    c.CreatedAt
FROM Clothing c
LEFT JOIN CosplayDetail cd ON c.ClothingID = cd.ClothingID
WHERE c.Category = 'Cosplay' 
  AND c.ClothingStatus = 'PENDING_COSPLAY_REVIEW'
ORDER BY c.CreatedAt DESC;

-- 2. DUYỆT MỘT COSPLAY CỤ THỂ (thay {ClothingID} bằng ID thực tế)
-- Ví dụ: UPDATE Clothing SET ClothingStatus = 'APPROVED_COSPLAY' WHERE ClothingID = 123;
UPDATE Clothing 
SET ClothingStatus = 'APPROVED_COSPLAY' 
WHERE ClothingID = {ClothingID};

-- 3. TỪ CHỐI COSPLAY (đặt về INACTIVE)
-- UPDATE Clothing SET ClothingStatus = 'INACTIVE', IsActive = 0 WHERE ClothingID = {ClothingID};

-- 4. DUYỆT TẤT CẢ COSPLAY ĐANG CHỜ (cẩn thận!)
-- UPDATE Clothing SET ClothingStatus = 'APPROVED_COSPLAY' WHERE ClothingStatus = 'PENDING_COSPLAY_REVIEW';

-- 5. XEM THỐNG KÊ COSPLAY THEO TRẠNG THÁI
SELECT 
    ClothingStatus,
    COUNT(*) as SoLuong
FROM Clothing
WHERE Category = 'Cosplay'
GROUP BY ClothingStatus;

-- 6. XEM TẤT CẢ COSPLAY ĐÃ ĐƯỢC DUYỆT
SELECT 
    c.ClothingID,
    c.ClothingName,
    cd.CharacterName,
    cd.Series,
    c.HourlyPrice,
    c.ClothingStatus
FROM Clothing c
LEFT JOIN CosplayDetail cd ON c.ClothingID = cd.ClothingID
WHERE c.Category = 'Cosplay' 
  AND c.ClothingStatus = 'APPROVED_COSPLAY'
ORDER BY c.CreatedAt DESC;
