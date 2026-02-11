<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cửa Hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { font-family: cursive; background-color: #f5f5f5; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        
        .page-title { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; margin-bottom: 30px; border-radius: 10px; }
        .page-title h1 { margin: 0; font-size: 32px; }
        .page-title p { margin: 10px 0 0 0; opacity: 0.9; }
        
        .search-bar { margin-bottom: 30px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .search-bar form { display: flex; gap: 10px; flex-wrap: wrap; }
        .search-bar select, .search-bar input { padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        .search-bar input { flex: 1; min-width: 200px; }
        .search-bar button { padding: 10px 30px; background-color: #667eea; color: white; border: none; cursor: pointer; border-radius: 4px; }
        .search-bar button:hover { background-color: #764ba2; }
        
        .products-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .product-card { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: transform 0.3s, box-shadow 0.3s; }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 8px 16px rgba(0,0,0,0.2); }
        .product-image { width: 100%; height: 250px; object-fit: cover; background-color: #f0f0f0; }
        .product-info { padding: 15px; }
        .product-name { font-size: 16px; font-weight: bold; color: #333; margin-bottom: 8px; }
        .product-category { font-size: 12px; color: #999; margin-bottom: 5px; }
        .product-price { font-size: 18px; font-weight: bold; color: #667eea; margin-bottom: 10px; }
        .product-btn { display: inline-block; padding: 8px 15px; background-color: #28a745; color: white; text-decoration: none; border-radius: 4px; cursor: pointer; border: none; font-size: 14px; }
        .product-btn:hover { background-color: #218838; }
        .card-footer { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: 10px; flex-wrap: wrap; }
        .card-rating { display: inline-flex; align-items: center; gap: 6px; padding: 6px 10px; background: #fff6e6; color: #d97706; border-radius: 999px; font-weight: 600; font-size: 13px; }
        .card-rating .star { color: #f59e0b; font-size: 14px; }
        .muted { color: #888; }
        
        .no-products { text-align: center; padding: 40px; color: #999; }
        
        .breadcrumb { margin-bottom: 20px; }
        .breadcrumb a { color: #667eea; text-decoration: none; margin-right: 10px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">WearConnect</a> > Cửa Hàng
    </div>
    
    <div class="page-title">
        <h1>WearConnect</h1>
        <p>Wear once – Connect forever</p>
    </div>
    
    <div class="search-bar">
        <form method="GET" action="${pageContext.request.contextPath}/home">
            <select name="type">
                <option value="">Tìm theo tên</option>
                <option value="category">Danh mục</option>
                <option value="style">Phong cách</option>
            </select>
            <input type="text" name="query" placeholder="Tìm kiếm sản phẩm..." value="${param.query}">
            <select name="sort">
                <option value="">Tất cả</option>
                <option value="rating_desc" ${param.sort == 'rating_desc' ? 'selected' : ''}>Đánh giá cao nhất - thấp nhất</option>
                <option value="price_desc" ${param.sort == 'price_desc' ? 'selected' : ''}>Giá thuê cao nhất - thấp nhất</option>
                <option value="price_asc" ${param.sort == 'price_asc' ? 'selected' : ''}>Giá thuê thấp nhất - cao nhất</option>
            </select>
            <button type="submit">Tìm Kiếm</button>
        </form>
    </div>
    
    <c:if test="${empty products}">
        <div class="no-products">
            <p>Không có sản phẩm nào phù hợp. Hãy thử tìm kiếm với từ khóa khác!</p>
        </div>
    </c:if>
    
    <c:if test="${not empty products}">
        <div class="products-grid">
            <c:forEach var="product" items="${products}">
                <div class="product-card">
                    <img src="${pageContext.request.contextPath}/image?id=${product.clothingID}" alt="${product.clothingName}" class="product-image">
                    <div class="product-info">
                        <div class="product-name">${product.clothingName}</div>
                        <div class="product-category">${product.category} • ${product.style}</div>
                            <div class="product-price"><fmt:formatNumber value="${product.hourlyPrice}" pattern="#,##0"/> VNĐ/giờ</div>
                        <div class="card-footer">
                            <a href="${pageContext.request.contextPath}/clothing?action=view&id=${product.clothingID}" class="product-btn">Xem Chi Tiết</a>
                            <c:set var="avg" value="${avgRatings[product.clothingID]}" />
                            <span class="card-rating">
                                <span class="star">★</span>
                                <c:choose>
                                    <c:when test="${avg > 0}">
                                        <fmt:formatNumber value="${avg}" type="number" maxFractionDigits="1" minFractionDigits="1"/> / 5
                                    </c:when>
                                    <c:otherwise>Chưa có</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
