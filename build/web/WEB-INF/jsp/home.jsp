<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cửa Hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        :root {
            --ink: #15110f;
            --muted: #6f6a64;
            --paper: #f7f3ee;
            --card: #ffffff;
            --accent: #1f8e74;
            --accent-strong: #156c57;
            --sun: #f2a65a;
            --shadow: 0 16px 34px rgba(20, 16, 11, 0.12);
            --radius: 18px;
        }
        body {
            font-family: cursive;
            background: radial-gradient(circle at 8% 12%, #efe2d0, transparent 40%),
                        radial-gradient(circle at 90% 20%, #dff1ea, transparent 45%),
                        var(--paper);
            margin: 0;
            color: var(--ink);
        }
        .container { max-width: 1200px; margin: 0 auto; padding: 28px 20px 70px; }
        
        .page-title {
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #1f8e74 0%, #1b5d49 100%);
            color: white;
            padding: 40px 32px;
            text-align: left;
            margin-bottom: 26px;
            border-radius: 20px;
            box-shadow: var(--shadow);
        }
        .page-title::before {
            content: "";
            position: absolute;
            top: -120px;
            right: -80px;
            width: 240px;
            height: 240px;
            background: rgba(255, 255, 255, 0.12);
            border-radius: 50%;
        }
        .page-title::after {
            content: "";
            position: absolute;
            bottom: -100px;
            left: -60px;
            width: 200px;
            height: 200px;
            background: rgba(0, 0, 0, 0.12);
            border-radius: 50%;
        }
        .hero-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.18);
            font-size: 12px;
            letter-spacing: 0.4px;
            text-transform: uppercase;
        }
        .page-title h1 { margin: 14px 0 6px; font-size: clamp(30px, 4vw, 40px); }
        .page-title p { margin: 0; opacity: 0.9; font-size: 15px; }
        
        .search-bar {
            margin-bottom: 30px;
            background: var(--card);
            padding: 18px;
            border-radius: 16px;
            box-shadow: var(--shadow);
            border: 1px solid rgba(0, 0, 0, 0.05);
        }
        .search-bar form { display: grid; gap: 12px; grid-template-columns: 1fr 2fr 1fr auto; }
        .search-bar select, .search-bar input {
            padding: 12px 14px;
            border: 1px solid #e3ddd5;
            border-radius: 12px;
            background: #fcfaf7;
            font-size: 14px;
        }
        .search-bar input { min-width: 200px; }
        .search-bar button {
            padding: 12px 28px;
            background-color: var(--accent);
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 999px;
            font-weight: 600;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .search-bar button:hover { background-color: var(--accent-strong); transform: translateY(-1px); box-shadow: 0 10px 18px rgba(0,0,0,0.12); }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 22px;
        }
        .product-card {
            display: block;
            background: var(--card);
            border-radius: 18px;
            overflow: hidden;
            box-shadow: var(--shadow);
            border: 1px solid rgba(0, 0, 0, 0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            text-decoration: none;
            color: inherit;
        }
        .product-card:hover { transform: translateY(-6px); box-shadow: 0 18px 30px rgba(0,0,0,0.18); }
        .product-image-wrap {
            position: relative;
            overflow: hidden;
            aspect-ratio: 4 / 5;
            background: #efe9e1;
        }
        .product-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
            display: block;
        }
        .product-badge {
            position: absolute;
            left: 14px;
            bottom: 14px;
            padding: 6px 12px;
            border-radius: 999px;
            background: rgba(0, 0, 0, 0.68);
            color: #fff;
            font-size: 12px;
        }
        .product-info { padding: 16px; display: grid; gap: 8px; }
        .product-name { font-size: 16px; font-weight: bold; color: var(--ink); }
        .product-category { font-size: 13px; color: var(--muted); }
        .product-price { font-size: 18px; font-weight: bold; color: var(--accent-strong); }
        .card-footer { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: 6px; flex-wrap: wrap; }
        .card-rating {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            background: #fff3df;
            color: #b65d06;
            border-radius: 999px;
            font-weight: 600;
            font-size: 13px;
        }
        .card-rating .star { color: #f59e0b; font-size: 14px; }
        .muted { color: var(--muted); }
        
        .no-products {
            text-align: center;
            padding: 50px 20px;
            color: var(--muted);
            background: var(--card);
            border-radius: 16px;
            box-shadow: var(--shadow);
        }
        
        .breadcrumb { margin-bottom: 18px; color: var(--muted); }
        .breadcrumb a { color: var(--accent-strong); text-decoration: none; margin-right: 10px; }
        
        @media (max-width: 900px) {
            .search-bar form { grid-template-columns: 1fr; }
            .page-title { text-align: left; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">WearConnect</a> > Cửa Hàng
    </div>
    
    <div class="page-title">
        <span class="hero-tag">San giao thue trang phuc</span>
        <h1>WearConnect</h1>
        <p>Wear once – Connect forever</p>
    </div>
    
    <div class="search-bar">
        <form method="GET" action="${pageContext.request.contextPath}/home">
            <select name="type">
                <option value="">Tìm theo tên</option>
                <option value="category">Danh mục</option>
                <option value="style">Phong cách</option>
                <option value="occasion">Mục đích sử dụng</option>
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
                <a class="product-card" href="${pageContext.request.contextPath}/clothing?action=view&id=${product.clothingID}">
                    <div class="product-image-wrap">
                        <img src="${pageContext.request.contextPath}/image?id=${product.clothingID}" alt="${product.clothingName}" class="product-image">
                        <span class="product-badge">${product.category}</span>
                    </div>
                    <div class="product-info">
                        <div class="product-name">${product.clothingName}</div>
                        <div class="product-category">${product.style} • ${product.occasion} • Size ${product.size}</div>
                        <div class="product-price"><fmt:formatNumber value="${product.hourlyPrice}" pattern="#,##0"/> VNĐ/giờ</div>
                        <div class="card-footer">
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
                </a>
            </c:forEach>
        </div>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
