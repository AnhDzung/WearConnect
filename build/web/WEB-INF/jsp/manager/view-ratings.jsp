<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đánh giá quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .container { max-width: 900px; margin: 20px auto; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
        
        h1 { color: #333; margin-bottom: 20px; }
        
        .header-btn { 
            padding: 10px 20px; 
            background-color: #6c757d; 
            color: white; 
            border: none; 
            cursor: pointer; 
            border-radius: 6px;
            font-weight: 600;
            margin-bottom: 20px;
            transition: background-color 0.3s;
        }
        
        .header-btn:hover { background-color: #5a6268; }
        
        .rating-info { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 24px; 
            border-radius: 10px; 
            margin-bottom: 30px;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
        }
        
        .rating-info h3 { margin: 0 0 10px 0; font-size: 18px; }
        .rating-info p { margin: 5px 0; font-size: 15px; }
        
        .stars { 
            color: #ffd700; 
            font-size: 20px; 
            display: inline-block;
        }
        
        h2 { color: #333; margin: 30px 0 20px 0; font-size: 20px; }
        
        .empty-message { 
            text-align: center; 
            padding: 40px; 
            background: #f9f9f9; 
            border-radius: 8px; 
            color: #999;
            border: 2px dashed #ddd;
        }
        
        .rating-item { 
            border-left: 4px solid #667eea;
            background: #f8f9fa;
            padding: 16px; 
            margin-bottom: 16px;
            border-radius: 8px;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .rating-item:hover {
            transform: translateX(4px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .rating-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 12px;
        }
        
        .rating-user {
            font-weight: 600;
            color: #333;
        }
        
        .rating-date {
            font-size: 12px;
            color: #999;
        }
        
        .rating-stars {
            color: #ffc107;
            font-size: 18px;
            margin: 8px 0;
        }
        
        .rating-comment {
            color: #555;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #e0e0e0;
            font-style: italic;
        }
        
        .rating-score {
            display: inline-block;
            padding: 4px 12px;
            background: #e7f5ff;
            color: #0c5aa0;
            border-radius: 20px;
            font-weight: 600;
            font-size: 13px;
            margin-left: 10px;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Đánh giá về sản phẩm</h1>
    <button onclick="history.back()" class="header-btn">Quay lại</button>
    
    <c:if test="${totalRatings == 0}">
        <div class="empty-message">
            <p>Chưa có đánh giá nào cho sản phẩm của bạn</p>
            <p style="font-size: 13px;">Hãy chờ khách hàng đánh giá sản phẩm khi họ hoàn thành thuê</p>
        </div>
    </c:if>
    
    <c:if test="${totalRatings > 0}">
        <div class="rating-info">
            <h3>Đánh giá trung bình: 
                <span class="stars" id="avgRating"></span>
                <span class="rating-score">${avgRating} / 5</span>
            </h3>
            <p>Tổng số đánh giá: <strong>${totalRatings}</strong></p>
        </div>
        
        <h2>Chi tiết đánh giá</h2>
        <c:forEach var="rating" items="${ratings}">
            <div class="rating-item">
                <div class="rating-header">
                    <span class="rating-user">
                        <c:choose>
                            <c:when test="${not empty rating.ratingFromUsername}">
                                ${rating.ratingFromUsername}
                            </c:when>
                            <c:otherwise>
                                Khách hàng #${rating.ratingFromUserID}
                            </c:otherwise>
                        </c:choose>
                    </span>
                    <span class="rating-date">
                        ${rating.formattedCreatedAt}
                    </span>
                </div>
                <div class="rating-stars" id="rating${rating.ratingID}"></div>
                <c:if test="${not empty rating.comment}">
                    <div class="rating-comment">
                        &quot;${rating.comment}&quot;
                    </div>
                </c:if>
            </div>
        </c:forEach>
    </c:if>
    
    <script>
        // Display stars
        function displayStars(ratingId, stars) {
            let starsHtml = '';
            for (let i = 0; i < stars; i++) {
                starsHtml += '★';
            }
            document.getElementById(ratingId).textContent = starsHtml;
        }
        
        // Initialize ratings
        <c:forEach var="rating" items="${ratings}">
            displayStars('rating${rating.ratingID}', ${rating.rating});
        </c:forEach>
        
        displayStars('avgRating', Math.round(${avgRating}));
    </script>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
