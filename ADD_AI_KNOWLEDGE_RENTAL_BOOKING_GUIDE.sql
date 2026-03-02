-- =============================================
-- Add/Update AI Knowledge: Quy trình đặt thuê
-- Run this script once on your SQL Server database
-- =============================================

DECLARE @Title NVARCHAR(300) = N'Hướng dẫn quy trình đặt thuê trang phục';
DECLARE @Category VARCHAR(50) = 'BOOKING_PROCESS';
DECLARE @Content NVARCHAR(MAX) = N'Quy trình đặt thuê tại WearConnect gồm 6 bước: (1) Tìm sản phẩm phù hợp theo dịp/phong cách, (2) Xem chi tiết sản phẩm và chọn kích cỡ, (3) Chọn thời gian thuê và xác nhận thông tin đơn, (4) Thanh toán/đặt cọc theo hướng dẫn hệ thống, (5) Chờ shop xác nhận và theo dõi trạng thái đơn tại mục Đơn thuê của tôi, (6) Nhận trang phục và trả đúng hạn theo quy định để hoàn cọc nhanh chóng. Nếu cần hỗ trợ trong quá trình đặt thuê, khách có thể cung cấp mã đơn để được xử lý nhanh hơn.';
DECLARE @Tags NVARCHAR(300) = N'quy trình đặt thuê,booking process,đặt thuê,thuê trang phục,hướng dẫn đặt thuê';

IF EXISTS (SELECT 1 FROM AIKnowledgeDocs WHERE Title = @Title)
BEGIN
    UPDATE AIKnowledgeDocs
    SET Category = @Category,
        Content = @Content,
        Tags = @Tags,
        IsActive = 1,
        UpdatedAt = GETDATE()
    WHERE Title = @Title;

    PRINT N'Updated existing knowledge doc: ' + @Title;
END
ELSE
BEGIN
    INSERT INTO AIKnowledgeDocs(Title, Category, Content, Tags, IsActive, UpdatedAt)
    VALUES (@Title, @Category, @Content, @Tags, 1, GETDATE());

    PRINT N'Inserted new knowledge doc: ' + @Title;
END
GO
