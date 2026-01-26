<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đánh giá sản phẩm - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; font-family: 'Segoe UI', Tahoma, sans-serif; }
        .container { max-width: 900px; margin: 20px auto; padding: 0 16px 40px; }
        .card { background: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 20px; }
        .rating-item { border-bottom: 1px solid #eee; padding: 12px 0; }
        .rating-item:last-child { border-bottom: none; }
        .stars { color: #f5b301; font-size: 18px; }
        .meta { color: #666; font-size: 13px; }
        .empty { text-align: center; color: #777; padding: 30px 0; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; padding: 12px; border-radius: 6px; margin-bottom: 16px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />
<div class="container">
    <div class="card">
        <h2 style="margin-top:0;">Đánh giá sản phẩm</h2>
        <c:if test="${param.success == 'true'}">
            <div class="success">Cảm ơn bạn đã gửi đánh giá!</div>
        </c:if>
        <c:if test="${empty ratings}">
            <div class="empty">Chưa có đánh giá nào cho sản phẩm này.</div>
        </c:if>
        <c:if test="${not empty ratings}">
            <c:forEach var="r" items="${ratings}">
                <div class="rating-item">
                    <div class="stars">
                        <c:forEach begin="1" end="5" var="i">
                            <c:choose>
                                <c:when test="${i <= r.rating}">&#9733;</c:when>
                                <c:otherwise><span style="color:#ddd;">&#9733;</span></c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </div>
                    <div class="meta">
                        Đơn thuê: ${r.clothingName} • Người đánh giá: ${r.ratingFromUsername}
                    </div>
                    <div style="margin-top:6px;">${r.comment}</div>
                </div>
            </c:forEach>
        </c:if>
    </div>
</div>
</body>
</html>
