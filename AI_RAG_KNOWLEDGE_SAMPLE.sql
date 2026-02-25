-- Sample seed data for AIKnowledgeDocs (Step 3: RAG)

INSERT INTO AIKnowledgeDocs(Title, Category, Content, Tags, IsActive, UpdatedAt)
VALUES
(N'Chính sách tiền cọc', 'PAYMENT', N'Tiền cọc được thanh toán trước khi nhận đồ. Mức cọc phụ thuộc giá trị trang phục. Sau khi trả đồ đúng hạn và đúng tình trạng, tiền cọc sẽ được hoàn theo quy trình của hệ thống.', N'cọc,deposit,thanh toán', 1, GETDATE()),
(N'Quy trình trả đồ và hoàn tiền', 'RETURN_REFUND', N'Khách hàng mang trang phục đến điểm trả hoặc gửi theo phương thức đã chọn. Hệ thống kiểm tra tình trạng đồ trong 1-3 ngày làm việc và xử lý hoàn tiền nếu đủ điều kiện.', N'trả hàng,hoàn tiền,refund', 1, GETDATE()),
(N'Hướng dẫn chọn size cosplay', 'SIZE_ADVICE', N'Khách hàng cung cấp chiều cao, cân nặng và số đo cơ bản. Nhân viên hoặc AI sẽ gợi ý size phù hợp theo bảng size nội bộ.', N'size,kích cỡ,tư vấn', 1, GETDATE()),
(N'Theo dõi trạng thái đơn thuê', 'ORDER_SUPPORT', N'Khách hàng kiểm tra trạng thái tại mục Đơn thuê của tôi. Trạng thái gồm: Chờ xác nhận, Đang chuẩn bị, Đang giao, Đã nhận, Đang xử lý trả.', N'đơn hàng,trạng thái,order', 1, GETDATE());
