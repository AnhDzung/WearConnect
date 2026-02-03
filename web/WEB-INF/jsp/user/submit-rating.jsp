<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đánh giá - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .form-container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; background: white; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, select, textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        .rating-options { display: flex; gap: 10px; margin-top: 10px; }
        .rating-option { cursor: pointer; font-size: 24px; }
        button { padding: 10px 20px; background-color: #28a745; color: white; border: none; cursor: pointer; margin-right: 10px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="form-container">
    <h1>Đánh giá quần áo</h1>
    
    <form method="POST" action="${pageContext.request.contextPath}/rating">
        <input type="hidden" name="action" value="submitRating">
        <input type="hidden" name="rentalOrderID" value="${param.rentalOrderID}">
        
        <div class="form-group">
            <label for="rating">Đánh giá (1-5 sao):</label>
            <div class="rating-options">
                <span class="rating-option" onclick="setRating(1)">★</span>
                <span class="rating-option" onclick="setRating(2)">★</span>
                <span class="rating-option" onclick="setRating(3)">★</span>
                <span class="rating-option" onclick="setRating(4)">★</span>
                <span class="rating-option" onclick="setRating(5)">★</span>
            </div>
            <input type="hidden" id="rating" name="rating" value="5" required>
        </div>
        
        <div class="form-group">
            <label for="comment">Bình luận:</label>
            <textarea id="comment" name="comment" rows="4" required></textarea>
        </div>
        
        <button type="submit">Gửi đánh giá</button>
        <button type="button" onclick="history.back()">Quay lại</button>
    </form>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
<script>
    function setRating(stars) {
        document.getElementById('rating').value = stars;
    }
</script>
</body>
</html>
