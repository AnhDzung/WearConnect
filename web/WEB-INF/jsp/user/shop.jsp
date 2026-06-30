<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Cửa hàng ${shop.fullName} - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            background: #f8fafc;
            color: #0f172a;
            font-family: 'Inter', sans-serif;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px 16px 60px;
        }
        
        /* Breadcrumb */
        .breadcrumb {
            font-size: 13px;
            color: #64748b;
            margin: 8px 0 24px;
            display: flex;
            align-items: center;
            gap: 6px;
            font-weight: 500;
        }
        .breadcrumb a {
            color: var(--primary-color, #6366f1);
            text-decoration: none;
            font-weight: 600;
        }
        .breadcrumb a:hover {
            text-decoration: underline;
        }

        /* Shop Banner Profile */
        .shop-profile-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(99, 102, 241, 0.1);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
            display: flex;
            align-items: center;
            gap: 30px;
            margin-bottom: 40px;
        }
        
        @media (max-width: 768px) {
            .shop-profile-card {
                flex-direction: column;
                text-align: center;
                align-items: center;
                padding: 24px;
            }
        }

        .shop-avatar-container {
            width: 110px;
            height: 110px;
            border-radius: 50%;
            background: #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 40px;
            color: var(--accent, #6366f1);
            border: 3px solid rgba(99, 102, 241, 0.15);
            overflow: hidden;
            flex-shrink: 0;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.1);
        }
        .shop-avatar-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .shop-info-details {
            flex-grow: 1;
        }
        .shop-name-title {
            margin: 0 0 10px 0;
            font-size: 26px;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.5px;
        }
        
        .shop-meta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 12px;
            margin-top: 15px;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #475569;
        }
        .meta-item svg {
            color: #64748b;
            flex-shrink: 0;
        }
        .meta-label {
            font-weight: 600;
            color: #1e293b;
        }

        .shop-rating-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fff8e7;
            border: 1px solid #f0dca6;
            color: #7a5a0a;
            padding: 6px 12px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 13.5px;
        }

        /* Products Listing */
        .section-title {
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 24px;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title span {
            background: rgba(99, 102, 241, 0.1);
            color: var(--accent, #6366f1);
            padding: 4px 10px;
            border-radius: 50px;
            font-size: 14px;
            font-weight: 700;
        }

        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
            gap: 20px;
        }

        .product-card {
            background: #fff;
            border: 1px solid rgba(0, 0, 0, 0.05);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
            text-decoration: none;
            color: inherit;
            position: relative;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.07);
            border-color: rgba(99, 102, 241, 0.15);
        }

        .product-image-wrap {
            position: relative;
            width: 100%;
            padding-bottom: 120%; /* 5:6 aspect ratio */
            background: #f1f5f9;
            overflow: hidden;
        }
        .product-image-wrap img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }
        .product-card:hover .product-image-wrap img {
            transform: scale(1.05);
        }

        .product-info {
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            flex-grow: 1;
        }

        .product-name {
            font-size: 15px;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            height: 42px;
        }

        .product-price-row {
            display: flex;
            flex-direction: column;
            gap: 4px;
            border-top: 1px solid #f1f5f9;
            padding-top: 10px;
            margin-top: auto;
        }

        .price-thue {
            font-size: 12.5px;
            color: #64748b;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .price-thue span {
            font-weight: 800;
            color: #0f172a;
            font-size: 14.5px;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: #fff;
            border-radius: 16px;
            border: 1.5px dashed #cbd5e1;
            color: #64748b;
        }
        .empty-state svg {
            margin-bottom: 16px;
            color: #94a3b8;
        }
        .empty-state h3 {
            margin: 0 0 8px 0;
            color: #1e293b;
            font-size: 18px;
        }

        @media (max-width: 480px) {
            .products-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
        <span>›</span>
        <span>Cửa hàng</span>
        <span>›</span>
        <span>${shop.fullName}</span>
    </div>

    <!-- Shop Profile Header -->
    <div class="shop-profile-card">
        <div class="shop-avatar-container">
            <c:choose>
                <c:when test="${not empty shop.avatar}">
                    <img src="${pageContext.request.contextPath}/${shop.avatar}" alt="${shop.fullName}" onerror="this.onerror=null; this.parentNode.innerHTML='${fn:substring(shop.fullName, 0, 1)}';">
                </c:when>
                <c:otherwise>
                    ${fn:substring(shop.fullName, 0, 1)}
                </c:otherwise>
            </c:choose>
        </div>
        <div class="shop-info-details">
            <div style="display: flex; align-items: center; gap: 14px; flex-wrap: wrap; margin-bottom: 6px;">
                <h1 class="shop-name-title">${shop.fullName}</h1>
                <div class="shop-rating-badge">
                    <span style="color: #f5a623;">★</span>
                    <c:choose>
                        <c:when test="${shopRating > 0}">
                            <fmt:formatNumber value="${shopRating}" type="number" maxFractionDigits="1" minFractionDigits="1"/> / 5
                        </c:when>
                        <c:otherwise>Chưa có đánh giá</c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <div class="shop-meta-grid">
                <div class="meta-item">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                    <span><span class="meta-label">Địa chỉ:</span> ${shop.address}</span>
                </div>
                <c:if test="${not empty shop.phoneNumber}">
                    <div class="meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                        <span><span class="meta-label">SĐT:</span> ${shop.phoneNumber}</span>
                    </div>
                </c:if>
                <c:if test="${not empty shop.email}">
                    <div class="meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                        <span><span class="meta-label">Email:</span> ${shop.email}</span>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Products listed by shop -->
    <h2 class="section-title">
        Sản phẩm từ cửa hàng
        <span>${fn:length(products)}</span>
    </h2>

    <c:choose>
        <c:when test="${empty products}">
            <div class="empty-state">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                <h3>Chưa có sản phẩm nào</h3>
                <p>Cửa hàng hiện tại chưa đăng sản phẩm cho thuê nào.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="products-grid">
                <c:forEach var="product" items="${products}">
                    <a class="product-card" href="${pageContext.request.contextPath}/clothing?action=view&id=${product.clothingID}">
                        <div class="product-image-wrap">
                            <img src="${pageContext.request.contextPath}/image?id=${product.clothingID}" alt="${product.clothingName}">
                        </div>
                        <div class="product-info">
                            <h3 class="product-name">${product.clothingName}</h3>
                            <div class="product-price-row">
                                <div class="price-thue">
                                    <span>Thuê ngày:</span>
                                    <span><fmt:formatNumber value="${product.dailyPrice}" pattern="#,##0"/> đ</span>
                                </div>
                                <div class="price-thue">
                                    <span>Thuê giờ:</span>
                                    <span><fmt:formatNumber value="${product.hourlyPrice}" pattern="#,##0"/> đ</span>
                                </div>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
