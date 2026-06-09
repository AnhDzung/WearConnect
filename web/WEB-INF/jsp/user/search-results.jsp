<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tìm kiếm quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background: linear-gradient(180deg, #f6f1e8 0%, #faf7f2 40%, #f3efe8 100%); }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .search-panel { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 20px; }
        .search-card { background: rgba(255, 255, 255, 0.92); border: 1px solid rgba(0, 0, 0, 0.06); border-radius: 18px; padding: 18px; box-shadow: 0 14px 40px rgba(33, 32, 28, 0.08); backdrop-filter: blur(8px); }
        .search-card h3 { margin: 0 0 12px; font-size: 18px; }
        .search-card p { margin: 0 0 12px; color: #666; }
        .search-card form { display: flex; flex-direction: column; gap: 10px; }
        .search-card input, .search-card select { padding: 11px 12px; border: 1px solid #d7d0c4; border-radius: 12px; font-size: 14px; }
        .search-card button { padding: 11px 16px; background: #1f6f5b; color: white; border: none; border-radius: 12px; cursor: pointer; font-weight: 600; }
        .search-card button:hover { background: #185845; }
        .clothing-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; }
        .clothing-item { background: rgba(255,255,255,0.96); border: 1px solid rgba(0,0,0,0.06); padding: 12px; border-radius: 18px; box-shadow: 0 10px 30px rgba(33, 32, 28, 0.07); }
        .clothing-item img { width: 100%; height: 220px; object-fit: cover; border-radius: 14px; background: #f2eee7; }
        .btn-browse { display: inline-block; padding: 9px 12px; background-color: #0f172a; color: white; border: none; cursor: pointer; border-radius: 10px; text-decoration: none; }
        .search-message { margin: 0 0 16px; padding: 12px 14px; background: #fff8e7; border: 1px solid #f0dca6; border-radius: 12px; color: #7a5a0a; }
        .empty-state { padding: 20px; background: rgba(255,255,255,0.9); border-radius: 16px; border: 1px dashed #d7d0c4; color: #666; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Tìm kiếm quần áo</h1>
    <button onclick="history.back()" style="padding: 8px 15px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 15px;">Quay lại</button>
    
    <div class="search-panel">
        <div class="search-card">
            <h3>Tìm theo từ khóa</h3>
            <p>Nhập tên, danh mục, phong cách hoặc dịp sử dụng để lọc nhanh.</p>
            <form method="GET" action="${pageContext.request.contextPath}/search">
                <select name="type">
                    <option value="" ${searchType == null || searchType == '' ? 'selected' : ''}>Tất cả</option>
                    <option value="category" ${searchType == 'category' ? 'selected' : ''}>Danh mục</option>
                    <option value="style" ${searchType == 'style' ? 'selected' : ''}>Phong cách</option>
                    <option value="occasion" ${searchType == 'occasion' ? 'selected' : ''}>Mục đích sử dụng</option>
                </select>
                <input type="text" name="query" placeholder="Nhập từ khóa tìm kiếm" value="${query}">
                <button type="submit">Tìm kiếm</button>
            </form>
        </div>

        <div class="search-card">
            <h3>Tìm bằng ảnh</h3>
            <p>Chụp hoặc tải ảnh sản phẩm để tìm mẫu giống hoặc gần giống nhất.</p>
            <form method="POST" action="${pageContext.request.contextPath}/search" enctype="multipart/form-data">
                <input type="hidden" name="type" value="image">
                <input type="file" name="image" accept="image/*" capture="environment" required>
                <button type="submit">Tìm bằng ảnh</button>
            </form>
        </div>
    </div>

    <c:if test="${not empty searchMessage}">
        <div class="search-message">${searchMessage}</div>
    </c:if>

    <c:if test="${empty searchResults}">
        <div class="empty-state">Không có sản phẩm phù hợp để hiển thị.</div>
    </c:if>

    <c:if test="${not empty searchResults}">
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
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
