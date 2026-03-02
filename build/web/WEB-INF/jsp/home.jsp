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
        
        .hero-slider {
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #1f8e74 0%, #1b5d49 100%);
            color: white;
            margin-bottom: 26px;
            border-radius: 20px;
            box-shadow: var(--shadow);
            width: 100%;
            max-width: 1200px;
            aspect-ratio: 1200 / 675;
        }
        .hero-slider::before {
            content: "";
            position: absolute;
            top: -120px;
            right: -80px;
            width: 240px;
            height: 240px;
            background: rgba(255, 255, 255, 0.12);
            border-radius: 50%;
        }
        .hero-slider::after {
            content: "";
            position: absolute;
            bottom: -100px;
            left: -60px;
            width: 200px;
            height: 200px;
            background: rgba(0, 0, 0, 0.12);
            border-radius: 50%;
        }
        .slider-track {
            position: relative;
            width: 100%;
            height: 100%;
        }
        .hero-slide {
            position: absolute;
            inset: 0;
            opacity: 0;
            visibility: hidden;
            transition: opacity 1.2s ease;
        }
        .hero-slide.active {
            opacity: 1;
            visibility: visible;
        }
        .hero-slide img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }
        .hero-overlay {
            position: absolute;
            left: 0;
            right: 0;
            bottom: 0;
            padding: 22px 24px;
            background: linear-gradient(transparent, rgba(0, 0, 0, 0.62));
            display: grid;
            gap: 8px;
            z-index: 2;
        }
        .hero-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.22);
            font-size: 12px;
            letter-spacing: 0.4px;
            text-transform: uppercase;
            width: fit-content;
        }
        .hero-overlay h1 { margin: 0; font-size: clamp(24px, 3.2vw, 34px); }
        .hero-overlay p { margin: 0; opacity: 0.95; font-size: 15px; }
        .slider-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 42px;
            height: 42px;
            border: none;
            border-radius: 50%;
            background: rgba(0, 0, 0, 0.4);
            color: #fff;
            font-size: 24px;
            line-height: 1;
            cursor: pointer;
            z-index: 3;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .slider-btn:hover { background: rgba(0, 0, 0, 0.6); }
        .slider-btn.prev { left: 12px; }
        .slider-btn.next { right: 12px; }
        .slider-dots {
            position: absolute;
            left: 50%;
            bottom: 14px;
            transform: translateX(-50%);
            display: flex;
            gap: 8px;
            z-index: 4;
        }
        .slider-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            border: none;
            background: rgba(255, 255, 255, 0.55);
            cursor: pointer;
        }
        .slider-dot.active {
            background: #fff;
            transform: scale(1.15);
        }
        
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
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 16px;
        }
        .product-card {
            display: block;
            background: var(--card);
            border-radius: 14px;
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
        .product-info { padding: 12px; display: grid; gap: 6px; }
        .product-name { font-size: 15px; font-weight: bold; color: var(--ink); }
        .product-category { font-size: 12px; color: var(--muted); }
        .product-price { font-size: 16px; font-weight: bold; color: var(--accent-strong); }
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

        .pagination {
            margin: 26px 0 0;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
        }
        .page-link {
            padding: 8px 12px;
            border-radius: 10px;
            background: var(--card);
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: var(--ink);
            text-decoration: none;
            font-weight: 600;
            min-width: 36px;
            text-align: center;
        }
        .page-link:hover { background: #efe9e1; }
        .page-link.active {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }
        
        @media (max-width: 900px) {
            .search-bar form { grid-template-columns: 1fr; }
            .hero-slider { aspect-ratio: 16 / 9; }
            .hero-overlay { padding: 16px 16px 28px; }
            .slider-btn { width: 36px; height: 36px; font-size: 20px; }
            .products-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
        }
        @media (max-width: 1200px) {
            .products-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); }
        }
        @media (max-width: 720px) {
            .products-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 520px) {
            .products-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">WearConnect</a> > Cửa Hàng
    </div>
    
    <div class="hero-slider" id="homeHeroSlider">
        <div class="slider-track">
            <div class="hero-slide active">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-1.jpg" alt="WearConnect banner 1" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay">
                    <span class="hero-tag">San giao thue trang phuc</span>
                    <h1>WearConnect</h1>
                    <p>Wear once – Connect forever</p>
                </div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-2.jpg" alt="WearConnect banner 2" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay">
                    <span class="hero-tag">San giao thue trang phuc</span>
                    <h1>WearConnect</h1>
                    <p>Wear once – Connect forever</p>
                </div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-3.jpg" alt="WearConnect banner 3" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay">
                    <span class="hero-tag">San giao thue trang phuc</span>
                    <h1>WearConnect</h1>
                    <p>Wear once – Connect forever</p>
                </div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-4.jpg" alt="WearConnect banner 4" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay">
                    <span class="hero-tag">San giao thue trang phuc</span>
                    <h1>WearConnect</h1>
                    <p>Wear once – Connect forever</p>
                </div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-5.jpg" alt="WearConnect banner 5" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay">
                    <span class="hero-tag">San giao thue trang phuc</span>
                    <h1>WearConnect</h1>
                    <p>Wear once – Connect forever</p>
                </div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-6.jpg" alt="WearConnect banner 5" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay">
                    <span class="hero-tag">San giao thue trang phuc</span>
                    <h1>WearConnect</h1>
                    <p>Wear once – Connect forever</p>
                </div>
            </div>
        </div>
        <button type="button" class="slider-btn prev" aria-label="Slide trước">‹</button>
        <button type="button" class="slider-btn next" aria-label="Slide sau">›</button>
        <div class="slider-dots" aria-label="Điều hướng slide"></div>
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
        <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${currentPage > 1}">
                    <c:url var="prevLink" value="/home">
                        <c:param name="type" value="${param.type}" />
                        <c:param name="query" value="${param.query}" />
                        <c:param name="sort" value="${param.sort}" />
                        <c:param name="page" value="${currentPage - 1}" />
                    </c:url>
                    <a class="page-link" href="${prevLink}">Truoc</a>
                </c:if>

                <c:forEach var="i" begin="1" end="${totalPages}">
                    <c:url var="pageLink" value="/home">
                        <c:param name="type" value="${param.type}" />
                        <c:param name="query" value="${param.query}" />
                        <c:param name="sort" value="${param.sort}" />
                        <c:param name="page" value="${i}" />
                    </c:url>
                    <a class="page-link ${i == currentPage ? 'active' : ''}" href="${pageLink}">${i}</a>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                    <c:url var="nextLink" value="/home">
                        <c:param name="type" value="${param.type}" />
                        <c:param name="query" value="${param.query}" />
                        <c:param name="sort" value="${param.sort}" />
                        <c:param name="page" value="${currentPage + 1}" />
                    </c:url>
                    <a class="page-link" href="${nextLink}">Sau</a>
                </c:if>
            </div>
        </c:if>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
<script>
    (function () {
        const slider = document.getElementById('homeHeroSlider');
        if (!slider) return;

        const slides = Array.from(slider.querySelectorAll('.hero-slide'));
        const dotsContainer = slider.querySelector('.slider-dots');
        const prevBtn = slider.querySelector('.slider-btn.prev');
        const nextBtn = slider.querySelector('.slider-btn.next');
        let currentIndex = 0;
        let autoTimer;

        if (slides.length <= 1) {
            if (prevBtn) prevBtn.style.display = 'none';
            if (nextBtn) nextBtn.style.display = 'none';
            if (dotsContainer) dotsContainer.style.display = 'none';
            return;
        }

        slides.forEach((_, index) => {
            const dot = document.createElement('button');
            dot.type = 'button';
            dot.className = 'slider-dot' + (index === 0 ? ' active' : '');
            dot.setAttribute('aria-label', 'Chuyển đến slide ' + (index + 1));
            dot.addEventListener('click', () => {
                showSlide(index);
                restartAutoPlay();
            });
            dotsContainer.appendChild(dot);
        });

        const dots = Array.from(dotsContainer.querySelectorAll('.slider-dot'));

        function showSlide(index) {
            currentIndex = (index + slides.length) % slides.length;
            slides.forEach((slide, i) => slide.classList.toggle('active', i === currentIndex));
            dots.forEach((dot, i) => dot.classList.toggle('active', i === currentIndex));
        }

        function nextSlide() {
            showSlide(currentIndex + 1);
        }

        function prevSlide() {
            showSlide(currentIndex - 1);
        }

        function startAutoPlay() {
            autoTimer = setInterval(nextSlide, 7000);
        }

        function restartAutoPlay() {
            clearInterval(autoTimer);
            startAutoPlay();
        }

        prevBtn.addEventListener('click', () => {
            prevSlide();
            restartAutoPlay();
        });
        nextBtn.addEventListener('click', () => {
            nextSlide();
            restartAutoPlay();
        });

        slider.addEventListener('mouseenter', () => clearInterval(autoTimer));
        slider.addEventListener('mouseleave', startAutoPlay);

        startAutoPlay();
    })();
</script>
</body>
</html>
