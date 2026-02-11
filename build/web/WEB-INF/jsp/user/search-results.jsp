<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tìm kiếm quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .search-bar { margin-bottom: 20px; }
        .search-bar input, .search-bar select { padding: 8px; margin-right: 10px; }
        .search-bar button { padding: 8px 20px; background-color: #007bff; color: white; border: none; cursor: pointer; }
        .clothing-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }
        .clothing-item { border: 1px solid #ddd; padding: 10px; border-radius: 5px; }
        .clothing-item img { width: 100%; height: 200px; object-fit: cover; }
        .btn-browse { padding: 8px 12px; background-color: #28a745; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Tìm kiếm quần áo</h1>
    <button onclick="history.back()" style="padding: 8px 15px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 15px;">Quay lại</button>
    
    <div class="search-bar">
        <form method="GET" action="${pageContext.request.contextPath}/search">
            <select name="type">
                <option value="">Tất cả</option>
                <option value="category">Danh mục</option>
                <option value="style">Phong cách</option>
                <option value="occasion">Mục đích sử dụng</option>
            </select>
            <input type="text" name="query" placeholder="Nhập từ khóa tìm kiếm">
            <button type="submit">Tìm kiếm</button>
        </form>
    </div>
    
    <div class="clothing-grid">
        <c:forEach var="clothing" items="${searchResults}">
            <div class="clothing-item">
                <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
                <h4>${clothing.clothingName}</h4>
                <p><strong>Danh mục:</strong> ${clothing.category}</p>
                <p><strong>Phong cách:</strong> ${clothing.style}</p>
                <p><strong>Mục đích:</strong> ${clothing.occasion}</p>
                <p><strong>Size:</strong> ${clothing.size}</p>
                <p><strong>Giá:</strong> ${clothing.hourlyPrice} VNĐ/giờ</p>
                <a href="${pageContext.request.contextPath}/clothing?action=view&id=${clothing.clothingID}" class="btn-browse">Xem chi tiết</a>
            </div>
        </c:forEach>
    </div>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
