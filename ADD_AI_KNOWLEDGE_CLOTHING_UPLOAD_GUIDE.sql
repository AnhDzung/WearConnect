-- =============================================
-- Add/Update AI Knowledge: Quy trình đăng tải quần áo lên hệ thống
-- Run this script once on your SQL Server database
-- =============================================

DECLARE @Title NVARCHAR(300) = N'Hướng dẫn quy trình đăng tải quần áo lên hệ thống';
DECLARE @Category VARCHAR(50) = 'LISTING_SUPPORT';
DECLARE @Content NVARCHAR(MAX) = N'Quy trình đăng tải quần áo trên WearConnect gồm 6 bước: (1) Đăng nhập tài khoản cho thuê và vào mục Quản lý trang phục, (2) Chọn Thêm trang phục mới, (3) Nhập đầy đủ thông tin bắt buộc như tên trang phục, danh mục, phong cách, dịp phù hợp, mô tả, kích cỡ, số lượng, giá thuê và giá trị sản phẩm, (4) Tải ảnh rõ nét (mặt trước/mặt sau/chi tiết quan trọng) để khách dễ xem, (5) Thiết lập thời gian có thể cho thuê và kiểm tra lại toàn bộ thông tin, (6) Gửi đăng tải để hệ thống lưu và chờ trạng thái duyệt/hiển thị. Nếu đăng tải thất bại, hãy kiểm tra lại dữ liệu bắt buộc, định dạng ảnh và dung lượng ảnh trước khi thử lại.';
DECLARE @Tags NVARCHAR(300) = N'đăng tải quần áo,đăng sản phẩm,thêm trang phục,listings,listing support,quản lý trang phục';

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
