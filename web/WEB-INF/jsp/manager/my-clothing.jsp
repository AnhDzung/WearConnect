<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .btn { padding: 10px 20px; background-color: #007bff; color: white; border: none; cursor: pointer; border-radius: 4px; }
        .btn:hover { background-color: #0056b3; }
        .clothing-list { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        .clothing-card { border: 1px solid #ddd; padding: 15px; border-radius: 5px; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .clothing-card img { width: 100%; height: 250px; object-fit: cover; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Quản lý quần áo của tôi</h1>
    
    <a href="${pageContext.request.contextPath}/clothing?action=upload" class="btn">Đăng tải quần áo</a>
    
    <c:if test="${param.success}">
        <div style="color: green; margin: 20px 0;">Thao tác thành công!</div>
    </c:if>
    
    <div class="clothing-list">
        <c:forEach var="clothing" items="${myClothing}">
            <div class="clothing-card">
                <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
                <h3>${clothing.clothingName}</h3>
                <p><strong>Danh mục:</strong> ${clothing.category}</p>
                <p><strong>Phong cách:</strong> ${clothing.style}</p>
                <p><strong>Size:</strong> ${clothing.size}</p>
                <p><strong>Số lượng:</strong> <span style="color: #28a745; font-weight: bold;">${clothing.quantity > 0 ? clothing.quantity : 1}</span> sản phẩm</p>
                <p><strong>Giá thuê/giờ:</strong> ${clothing.hourlyPrice} VNĐ</p>
                <p><strong>Mô tả:</strong> ${clothing.description}</p>
                <p><strong>Có sẵn từ:</strong> ${clothing.availableFrom}</p>
                <p><strong>Đến:</strong> ${clothing.availableTo}</p>
                <a href="${pageContext.request.contextPath}/clothing?action=view&id=${clothing.clothingID}" class="btn">Xem chi tiết</a>
                <a href="${pageContext.request.contextPath}/clothing?action=edit&id=${clothing.clothingID}" class="btn">Chỉnh sửa</a>
                <form method="POST" action="${pageContext.request.contextPath}/clothing" style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="clothingID" value="${clothing.clothingID}">
                    <button type="submit" class="btn" onclick="return confirm('Bạn chắc chắn muốn xóa?')">Xóa</button>
                </form>
            </div>
        </c:forEach>
    </div>
</div>
</body>
</html>
