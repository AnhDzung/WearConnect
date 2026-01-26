<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh Giá Khách Hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
        
        .page-header {
            background: white;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .page-header h1 {
            margin: 0 0 10px 0;
            color: #333;
            font-size: 28px;
        }
        
        .page-header p {
            margin: 0;
            color: #666;
            font-size: 14px;
        }
        
        .ratings-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .rating-item {
            padding: 20px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            gap: 20px;
        }
        
        .rating-item:last-child {
            border-bottom: none;
        }
        
        .rating-header {
            flex: 1;
        }
        
        .rating-product {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .rating-customer {
            font-size: 13px;
            color: #666;
            margin-bottom: 5px;
        }
        
        .rating-date {
            font-size: 12px;
            color: #999;
        }
        
        .rating-score {
            display: flex;
            gap: 5px;
            margin-bottom: 10px;
        }
        
        .star {
            color: #ffc107;
            font-size: 18px;
        }
        
        .rating-comment {
            color: #666;
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 10px;
        }
        
        .empty-message {
            padding: 40px;
            text-align: center;
            color: #666;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />
    
    <div class="container">
        <div class="page-header">
            <h1>⭐ Đánh Giá Khách Hàng</h1>
            <p>Xem các đánh giá từ khách hàng về sản phẩm của bạn</p>
        </div>
        
        <div class="ratings-container">
            <div class="rating-item">
                <div class="rating-header">
                    <div class="rating-product">👕 Áo sơ mi xanh</div>
                    <div class="rating-customer">👤 Nguyễn Văn A</div>
                    <div class="rating-date">📅 20 Tháng 1, 2026</div>
                </div>
                <div class="rating-score">
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                </div>
            </div>
            <div class="rating-comment">
                "Sản phẩm rất tốt, chất lượng cao, giao hàng đúng hẹn. Rất hài lòng!"
            </div>
            
            <div class="rating-item">
                <div class="rating-header">
                    <div class="rating-product">👗 Váy dạo phố</div>
                    <div class="rating-customer">👤 Trần Thị B</div>
                    <div class="rating-date">📅 18 Tháng 1, 2026</div>
                </div>
                <div class="rating-score">
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                </div>
            </div>
            <div class="rating-comment">
                "Tốt, nhưng có một chút khác với hình ảnh. Tổng thể vẫn ổn."
            </div>
            
            <div class="rating-item">
                <div class="rating-header">
                    <div class="rating-product">👖 Quần jean</div>
                    <div class="rating-customer">👤 Lê Văn C</div>
                    <div class="rating-date">📅 15 Tháng 1, 2026</div>
                </div>
                <div class="rating-score">
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                    <span class="star">⭐</span>
                </div>
            </div>
            <div class="rating-comment">
                "Sản phẩm không tệ, nhưng giao hàng hơi chậm."
            </div>
        </div>
    </div>
</body>
</html>
