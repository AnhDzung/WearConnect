<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="DAO.RatingDAO" %>
<%@ page import="DAO.CosplayDetailDAO" %>
<%@ page import="Model.CosplayDetail" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Cosplay & Fes - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
    <style>
        :root {
            --ink: var(--gray-900);
            --muted: var(--gray-500);
            --paper: rgba(255, 255, 255, 0.75);
            --accent: var(--primary-color);
            --accent-hover: var(--primary-hover);
            --border: rgba(99, 102, 241, 0.1);
            --bg-light: var(--gray-100);
            --font-family: var(--font-family);
            --heading-font-family: var(--heading-font-family);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: var(--font-family); }
        body { background: var(--bg-light); color: var(--ink); }
        h1, h2, h3, h4, h5, h6 { font-family: var(--heading-font-family); }

        /* Hero Slider */
        .hero-slider {
            position: relative;
            overflow: hidden;
            background: var(--primary-gradient);
            color: white;
            width: 100%;
            max-width: 1200px;
            margin: 0 auto 20px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-xl);
            aspect-ratio: 1200 / 400;
        }
        .hero-slider::before {
            content: "";
            position: absolute;
            top: -120px;
            right: -80px;
            width: 240px;
            height: 240px;
            background: rgba(255, 255, 255, 0.15);
            border-radius: 50%;
            z-index: 1;
        }
        .hero-slider::after {
            content: "";
            position: absolute;
            bottom: -110px;
            left: -70px;
            width: 210px;
            height: 210px;
            background: rgba(0, 0, 0, 0.15);
            border-radius: 50%;
            z-index: 1;
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
            transition: opacity 1s cubic-bezier(0.4, 0, 0.2, 1);
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
            filter: brightness(0.9);
        }
        .hero-overlay {
            position: absolute;
            left: 0;
            right: 0;
            bottom: 0;
            padding: 30px;
            background: linear-gradient(transparent, rgba(15, 23, 42, 0.85));
            display: grid;
            gap: 10px;
            z-index: 2;
        }
        .hero-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            border-radius: var(--radius-full);
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(4px);
            font-size: var(--font-size-xs);
            font-weight: 700;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            width: fit-content;
        }
        .hero-overlay h1 {
            font-size: clamp(28px, 4vw, 42px);
            font-weight: 800;
            margin: 0;
            text-shadow: 2px 2px 10px rgba(99, 102, 241, 0.4);
            color: var(--white);
        }
        .hero-overlay p {
            margin: 0;
            font-size: 16px;
            opacity: 0.95;
            max-width: 700px;
            line-height: 1.6;
        }
        .slider-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 44px;
            height: 44px;
            border: none;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(8px);
            color: #fff;
            font-size: 24px;
            line-height: 1;
            cursor: pointer;
            z-index: 3;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all var(--transition-fast);
        }
        .slider-btn:hover { 
            background: rgba(255, 255, 255, 0.4);
            transform: translateY(-50%) scale(1.05);
        }
        .slider-btn.prev { left: 16px; }
        .slider-btn.next { right: 16px; }
        .slider-dots {
            position: absolute;
            left: 50%;
            bottom: 16px;
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
            background: rgba(255, 255, 255, 0.4);
            cursor: pointer;
            transition: all var(--transition-fast);
        }
        .slider-dot.active {
            background: #fff;
            transform: scale(1.3);
            box-shadow: 0 0 8px rgba(255,255,255,0.8);
        }

        /* Search Panel */
        .search-panel {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            padding: 25px;
            margin: -30px auto 30px;
            max-width: 900px;
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.45);
            box-shadow: var(--shadow-lg);
            position: relative;
            z-index: 10;
        }
        .search-form {
            display: grid;
            grid-template-columns: 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 700;
            color: var(--gray-700);
            font-size: 14px;
        }
        .form-group select, .form-group input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--gray-300);
            background-color: var(--gray-50);
            border-radius: var(--radius-md);
            font-size: 15px;
            transition: all var(--transition-base);
        }
        .form-group select:focus, .form-group input[type="text"]:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--white);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }
        .btn-search {
            padding: 12px 30px;
            background: var(--primary-gradient);
            color: white;
            border: none;
            border-radius: var(--radius-full);
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
            transition: all var(--transition-base);
        }
        .btn-search:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
        }
        .btn-search:active {
            transform: scale(0.96);
        }

        /* Sort Bar */
        .sort-bar {
            max-width: 1200px;
            margin: 0 auto 30px;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .sort-bar p {
            color: var(--muted);
            font-size: 14px;
        }
        .sort-bar select {
            padding: 8px 12px;
            border: 1px solid rgba(99, 102, 241, 0.15);
            border-radius: var(--radius-md);
            font-size: 14px;
        }

        /* Product Grid */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 20px;
        }

        /* Cosplay Product Card */
        .cosplay-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px) saturate(180%);
            -webkit-backdrop-filter: blur(10px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.45);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            transition: transform var(--transition-base), box-shadow var(--transition-base), border-color var(--transition-base);
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
        }
        .cosplay-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-color);
        }
        .cosplay-card-image {
            width: 100%;
            aspect-ratio: 4 / 5;
            object-fit: cover;
            background-color: var(--gray-100);
            transition: transform var(--transition-slow);
        }
        .cosplay-card:hover .cosplay-card-image {
            transform: scale(1.04);
        }
        .cosplay-card-body {
            padding: 16px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            gap: 8px;
        }
        .character-name {
            font-size: 16px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 2px;
            line-height: 1.3;
        }
        .series-name {
            font-size: var(--font-size-sm);
            color: var(--gray-500);
            margin-bottom: 4px;
        }
        .cosplay-type-badge {
            display: inline-block;
            padding: 4px 10px;
            background: #e0e7ff;
            color: #4338ca;
            border-radius: var(--radius-sm);
            font-size: var(--font-size-xs);
            font-weight: 700;
            width: fit-content;
            margin-bottom: 4px;
        }
        .price-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 4px;
            padding-top: 12px;
            border-top: 1px solid rgba(99, 102, 241, 0.1);
            margin-top: auto;
        }
        .hourly-price {
            font-size: 16px;
            font-weight: 800;
            color: var(--primary-color);
        }
        .price-label {
            font-size: 12px;
            color: var(--muted);
        }
        .deposit-info {
            font-size: 13px;
            color: var(--muted);
            margin-bottom: 8px;
        }
        .deposit-refund {
            color: var(--secondary-color);
            font-weight: 600;
        }
        .rating-row {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: var(--font-size-sm);
        }
        .rating-star {
            color: #fbbf24;
            font-size: 14px;
        }
        .rating-value {
            font-weight: 700;
            color: var(--gray-800);
        }
        .rental-count {
            color: var(--muted);
        }
        .price-thue { font-size:12px; color:var(--gray-800); font-weight:600; }
        .price-thue span { color:var(--primary-color); font-weight: 800; }
        .price-promo { font-size:10px; color:var(--gray-500); margin-top:2px; font-style:italic; }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--muted);
        }
        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 10px;
            color: var(--ink);
        }

        /* Pagination */
        .pagination {
            margin: 30px 0 0;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
        }
        .page-link {
            padding: 8px 16px;
            border-radius: var(--radius-full);
            background: rgba(255, 255, 255, 0.8);
            border: 1px solid rgba(99, 102, 241, 0.1);
            color: var(--gray-800);
            text-decoration: none;
            font-weight: 700;
            min-width: 40px;
            text-align: center;
            transition: all var(--transition-fast);
        }
        .page-link:hover { 
            background: rgba(99, 102, 241, 0.08); 
            border-color: var(--primary-color);
            transform: translateY(-1px);
        }
        .page-link.active {
            background: var(--primary-gradient);
            color: white;
            border-color: transparent;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.2);
        }

        @media (max-width: 980px) {
            .product-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
        }
        @media (max-width: 768px) {
            .hero-slider { aspect-ratio: 1200 / 500; }
            .hero-overlay { padding: 20px; }
            .slider-btn { width: 36px; height: 36px; font-size: 20px; }
            .main-content { flex-direction: column; }
            .product-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 520px) {
            .product-grid { grid-template-columns: 1fr; }
        }

        /* ── Search Bar ── */
        .search-bar-wrap { max-width: 1200px; margin: -30px auto 20px; padding: 0 20px; position: relative; z-index: 10; }
        .search-bar-wrap form { 
            background: rgba(255, 255, 255, 0.8); 
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            padding: 14px 20px; 
            border-radius: var(--radius-lg); 
            box-shadow: var(--shadow-lg); 
            border: 1px solid rgba(255, 255, 255, 0.45); 
            display: flex; 
            gap: 12px; 
            flex-wrap: wrap; 
            align-items: center; 
        }
        .search-bar-wrap select, .search-bar-wrap input[type=text] { 
            padding: 12px 16px; 
            border: 1px solid var(--gray-300); 
            border-radius: var(--radius-md); 
            background: var(--gray-50); 
            font-size: 14px; 
            flex: 1; 
            min-width: 150px; 
            transition: all var(--transition-base);
        }
        .search-bar-wrap select:focus, .search-bar-wrap input[type=text]:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--white);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }
        .search-bar-wrap button { 
            padding: 12px 28px; 
            background: var(--primary-gradient); 
            color: #fff; 
            border: none; 
            cursor: pointer; 
            border-radius: var(--radius-full); 
            font-weight: 700; 
            font-size: 14px; 
            transition: all var(--transition-base); 
            white-space: nowrap; 
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
        }
        .search-bar-wrap button:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
        }
        .search-bar-wrap button:active {
            transform: scale(0.96);
        }

        /* ── Main Layout ── */
        .main-content-wrap { max-width: 1200px; margin: 0 auto; padding: 0 20px 40px; }
        .main-content { display: flex; gap: 24px; align-items: flex-start; }
        .products-area { flex: 1; min-width: 0; }
        .products-topbar { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
        .sort-tabs { display: flex; gap: 8px; flex-wrap: wrap; }
        .sort-tab { 
            padding: 8px 16px; 
            border-radius: var(--radius-full); 
            border: 1px solid rgba(99, 102, 241, 0.1); 
            font-size: 13px; 
            font-weight: 700; 
            cursor: pointer; 
            background: rgba(255, 255, 255, 0.8); 
            color: var(--gray-600); 
            text-decoration: none; 
            transition: all var(--transition-fast); 
            white-space: nowrap; 
        }
        .sort-tab:hover { 
            border-color: var(--primary-color); 
            color: var(--primary-color); 
            background: rgba(99, 102, 241, 0.05);
        }
        .sort-tab.active { 
            background: var(--primary-gradient); 
            color: #fff; 
            border-color: transparent; 
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.2);
        }

        /* ── Filter Panel ── */
        .filter-panel { 
            width: 240px; 
            flex-shrink: 0; 
            background: rgba(255, 255, 255, 0.75); 
            backdrop-filter: blur(12px) saturate(180%);
            -webkit-backdrop-filter: blur(12px) saturate(180%);
            border-radius: var(--radius-lg); 
            box-shadow: var(--shadow-md); 
            border: 1px solid rgba(255, 255, 255, 0.45); 
            position: sticky; 
            top: 90px; 
            overflow: hidden; 
            transition: transform var(--transition-base);
        }
        .filter-title-bar { 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            padding: 16px; 
            border-bottom: 1px solid rgba(99, 102, 241, 0.1); 
            font-weight: 800; 
            font-size: 14px; 
            background: linear-gradient(to right, rgba(99, 102, 241, 0.03), rgba(168, 85, 247, 0.03));
        }
        .filter-action-btns { display: flex; gap: 8px; }
        .btn-apply { 
            padding: 6px 14px; 
            border-radius: var(--radius-full); 
            border: none; 
            cursor: pointer; 
            background: var(--primary-gradient); 
            color: #fff; 
            font-size: 12px; 
            font-weight: 700; 
            transition: all var(--transition-fast); 
            box-shadow: 0 2px 6px rgba(99, 102, 241, 0.2);
        }
        .btn-apply:hover { 
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.35);
        }
        .btn-clear { 
            padding: 6px 12px; 
            border-radius: var(--radius-full); 
            border: 1px solid var(--gray-300); 
            cursor: pointer; 
            background: var(--white); 
            color: var(--gray-800); 
            font-size: 12px; 
            font-weight: 700; 
            transition: all var(--transition-fast);
        }
        .btn-clear:hover { 
            background: var(--gray-100); 
        }
        .filter-section { border-bottom: 1px solid rgba(99, 102, 241, 0.1); }
        .filter-section:last-child { border-bottom: none; }
        .filter-section-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            padding: 14px 16px; 
            cursor: pointer; 
            user-select: none; 
            font-weight: 800; 
            font-size: 12px; 
            letter-spacing: 1px; 
            color: var(--gray-800); 
            transition: background var(--transition-fast);
        }
        .filter-section-header:hover { background: rgba(99, 102, 241, 0.04); }
        .section-toggle { font-size: 16px; color: var(--gray-500); line-height: 1; }
        .filter-section-body { padding: 8px 16px 16px; display: none; }
        .filter-section.open .filter-section-body { display: block; }
        .filter-item { display: flex; align-items: center; padding: 8px 0; font-size: 13px; cursor: pointer; }
        .filter-item label { display: flex; align-items: center; gap: 8px; cursor: pointer; flex: 1; color: var(--gray-800); font-weight: 600; }
        .filter-item input[type=checkbox] { 
            width: 16px; 
            height: 16px; 
            accent-color: var(--primary-color); 
            border-radius: 4px; 
            cursor: pointer; 
            flex-shrink: 0; 
        }
        @media (max-width: 820px) { .filter-panel { display: none; } }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<!-- Hero Section -->
<div class="hero-slider" id="cosplayHeroSlider">
    <div class="slider-track">
        <div class="hero-slide active">
            <img src="${pageContext.request.contextPath}/uploads/slider/slide-7.jpg?v=2" alt="Cosplay banner 1" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
            <div class="hero-overlay">
                <span class="hero-tag">Cosplay spotlight</span>
                <p>Cho thuê trang phục cosplay chất lượng cao từ Anime, Game và Movie để bạn hóa thân nổi bật trong mọi sự kiện.</p>
            </div>
        </div>
        <div class="hero-slide">
            <img src="${pageContext.request.contextPath}/uploads/slider/slide-8.jpg?v=2" alt="Cosplay banner 2" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
            <div class="hero-overlay">
                <span class="hero-tag">Anime energy</span>
                <p>Từ chiến binh, công chúa đến phản diện cá tính, chọn đúng nhân vật bạn muốn xuất hiện thật ấn tượng.</p>
            </div>
        </div>
        <div class="hero-slide">
            <img src="${pageContext.request.contextPath}/uploads/slider/slide-9.jpg?v=2" alt="Cosplay banner 3" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
            <div class="hero-overlay">
                <span class="hero-tag">Game & movie</span>
                <p>Chất liệu đẹp, kiểu dáng rõ nhân vật và phù hợp cho lễ hội, chụp ảnh, event hay biểu diễn sân khấu.</p>
            </div>
        </div>
        <div class="hero-slide">
            <img src="${pageContext.request.contextPath}/uploads/slider/slide-10.jpg?v=2" alt="Cosplay banner 4" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
            <div class="hero-overlay">
                <span class="hero-tag">Festival ready</span>
                <p>Tìm nhanh bộ đồ phù hợp theo series, nhân vật hoặc loại cosplay để chuẩn bị cho buổi xuất hiện tiếp theo của bạn.</p>
            </div>
        </div>
        <div class="hero-slide">
            <img src="${pageContext.request.contextPath}/uploads/slider/slide-11.jpg?v=2" alt="Cosplay banner 5" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
            <div class="hero-overlay">
                <span class="hero-tag">Signature look</span>
                <p>Khám phá nhiều lựa chọn cosplay đang được yêu thích và chọn bộ phù hợp nhất với phong cách bạn muốn thể hiện.</p>
            </div>
        </div>
        <div class="hero-slide">
            <img src="${pageContext.request.contextPath}/uploads/slider/slide-12.jpg?v=2" alt="Cosplay banner 6" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
            <div class="hero-overlay">
                <span class="hero-tag">WearConnect cosplay</span>
                <p>Lựa chọn nhanh, xem giá rõ ràng và tìm bộ cosplay phù hợp để xuất hiện nổi bật ở mọi sân chơi fandom.</p>
            </div>
        </div>
    </div>
    <button type="button" class="slider-btn prev" aria-label="Slide trước">‹</button>
    <button type="button" class="slider-btn next" aria-label="Slide sau">›</button>
    <div class="slider-dots" aria-label="Điều hướng slide"></div>
</div>

<!-- Search Bar -->
<div class="search-bar-wrap">
    <form method="GET" action="${pageContext.request.contextPath}/cosplay" id="cosplaySearchForm">
        <select name="searchType" id="cosSearchType">
            <option value="">Tìm theo tên</option>
            <option value="character" ${searchType == 'character' ? 'selected' : ''}>Nhân vật</option>
            <option value="series" ${searchType == 'series' ? 'selected' : ''}>Series</option>
        </select>
        <input type="text" name="searchValue" id="cosSearchValue"
               placeholder="Tìm nhân vật, series..."
               value="${searchType != 'type' ? searchValue : ''}"/>
        <input type="hidden" name="sortBy" value="${sortBy}"/>
        <button type="submit">🔍 Tìm kiếm</button>
    </form>
</div>

<!-- Main Content: Filter + Products -->
<div class="main-content-wrap">
    <div class="main-content">

        <!-- Filter Panel -->
        <aside class="filter-panel" id="filterPanel">
            <div class="filter-title-bar">
                <span>Bộ Lọc</span>
                <div class="filter-action-btns">
                    <button class="btn-apply" onclick="applyFilters()">Áp dụng</button>
                    <button class="btn-clear" onclick="clearFilters()">Bỏ chọn</button>
                </div>
            </div>
            <div class="filter-section open" id="sec-loai">
                <div class="filter-section-header" onclick="toggleSection('sec-loai')">
                    LOẠI COSPLAY <span class="section-toggle">−</span>
                </div>
                <div class="filter-section-body">
                    <div class="filter-item">
                        <label><input type="checkbox" class="type-cb" value="Anime"
                            ${searchType == 'type' && searchValue == 'Anime' ? 'checked' : ''}> Anime</label>
                    </div>
                    <div class="filter-item">
                        <label><input type="checkbox" class="type-cb" value="Game"
                            ${searchType == 'type' && searchValue == 'Game' ? 'checked' : ''}> Game</label>
                    </div>
                    <div class="filter-item">
                        <label><input type="checkbox" class="type-cb" value="Movie"
                            ${searchType == 'type' && searchValue == 'Movie' ? 'checked' : ''}> Movie</label>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Products Area -->
        <div class="products-area">
            <div class="products-topbar">
                <p style="color: var(--muted); font-size: 14px;">Tìm thấy <strong>${totalItems != null ? totalItems : 0}</strong> trang phục cosplay</p>
                <div class="sort-tabs">
                    <a class="sort-tab ${empty sortBy ? 'active' : ''}" href="javascript:void(0)" onclick="applySort('')">Mặc định</a>
                    <a class="sort-tab ${sortBy == 'rating' ? 'active' : ''}" href="javascript:void(0)" onclick="applySort('rating')">Đánh giá cao nhất</a>
                    <a class="sort-tab ${sortBy == 'priceAsc' ? 'active' : ''}" href="javascript:void(0)" onclick="applySort('priceAsc')">Giá thấp → cao</a>
                    <a class="sort-tab ${sortBy == 'priceDesc' ? 'active' : ''}" href="javascript:void(0)" onclick="applySort('priceDesc')">Giá cao → thấp</a>
                </div>
            </div>
    <c:choose>
        <c:when test="${clothingList != null && clothingList.size() > 0}">
            <div class="product-grid">
                <c:forEach var="clothing" items="${clothingList}">
                    <%
                        Model.Clothing currentClothing = (Model.Clothing) pageContext.getAttribute("clothing");
                        int clothingID = currentClothing.getClothingID();
                        double avgRating = RatingDAO.getAverageRatingForClothing(clothingID);
                        int rentalCount = RatingDAO.getRatingsByClothing(clothingID).size();
                        CosplayDetail cosplayDetail = CosplayDetailDAO.getCosplayDetailByClothingID(clothingID);
                        
                        pageContext.setAttribute("avgRating", avgRating);
                        pageContext.setAttribute("rentalCount", rentalCount);
                        pageContext.setAttribute("cosplayDetail", cosplayDetail);
                    %>
                    
                    <a href="${pageContext.request.contextPath}/clothing?action=view&id=${clothing.clothingID}" class="cosplay-card">
                        <c:choose>
                            <c:when test="${clothing.imageData != null}">
                                <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" 
                                     alt="${clothing.clothingName}" class="cosplay-card-image">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/assets/images/default.jpg" 
                                     alt="Default Image" class="cosplay-card-image">
                            </c:otherwise>
                        </c:choose>
                        
                        <div class="cosplay-card-body">
                            <c:if test="${cosplayDetail != null}">
                                <div class="character-name">${cosplayDetail.characterName}</div>
                                <div class="series-name">${cosplayDetail.series}</div>
                                <span class="cosplay-type-badge">${cosplayDetail.cosplayType}</span>
                            </c:if>
                            
                            <div class="price-row">
                                <div>
                                    <div class="price-thue">Thuê ngày: <span><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> đ</span></div>
                                    <div class="price-thue">Thuê giờ: <span><fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,##0"/> đ</span></div>
                                    <div class="price-promo">Thuê 0đ khi mua gói ưu đãi</div>
                                </div>
                            </div>
                            
                            <div class="rating-row">
                                <span class="rating-star">⭐</span>
                                <span class="rating-value">${avgRating > 0 ? String.format("%.1f", avgRating) : "Chưa có"}</span>
                                <span class="rental-count">(${rentalCount} lượt thuê)</span>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </div>
            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <c:if test="${currentPage > 1}">
                        <a class="page-link" href="javascript:void(0)" onclick="goPage(${currentPage - 1})">‹ Trước</a>
                    </c:if>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <a class="page-link ${i == currentPage ? 'active' : ''}" href="javascript:void(0)" onclick="goPage(${i})">${i}</a>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <a class="page-link" href="javascript:void(0)" onclick="goPage(${currentPage + 1})">Sau ›</a>
                    </c:if>
                </div>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <h3>🎭 Không tìm thấy trang phục cosplay</h3>
                <p>Thử tìm kiếm với từ khóa khác hoặc xem tất cả trang phục.</p>
            </div>
        </c:otherwise>
    </c:choose>
        </div><%-- /products-area --%>
    </div><%-- /main-content --%>
</div><%-- /main-content-wrap --%>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />

<script>
    // ═══════════════════════════ FILTER PANEL ═══════════════════════════
    function toggleSection(id) {
        const sec = document.getElementById(id);
        const isOpen = sec.classList.toggle('open');
        sec.querySelector('.section-toggle').textContent = isOpen ? '−' : '+';
    }

    // Type checkboxes: radio-like (only one at a time)
    document.querySelectorAll('.type-cb').forEach(cb => {
        cb.addEventListener('change', function() {
            if (this.checked) {
                document.querySelectorAll('.type-cb').forEach(o => { if (o !== this) o.checked = false; });
            }
        });
    });

    function buildParams(extra) {
        const params = new URLSearchParams();
        const checkedType = document.querySelector('.type-cb:checked');
        if (checkedType) {
            params.append('searchType', 'type');
            params.append('searchValue', checkedType.value);
        } else {
            const sType = document.getElementById('cosSearchType').value;
            const sValue = document.getElementById('cosSearchValue').value;
            if (sType && sValue) {
                params.append('searchType', sType);
                params.append('searchValue', sValue);
            }
        }
        const currentSort = '${sortBy}';
        const sortVal = (extra && extra.sort !== undefined) ? extra.sort : currentSort;
        if (sortVal) params.append('sortBy', sortVal);
        params.append('page', (extra && extra.page) ? extra.page : 1);
        return params;
    }

    function applyFilters() {
        window.location.href = '${pageContext.request.contextPath}/cosplay?' + buildParams().toString();
    }

    function applySort(sortVal) {
        window.location.href = '${pageContext.request.contextPath}/cosplay?' + buildParams({sort: sortVal, page: 1}).toString();
    }

    function goPage(p) {
        window.location.href = '${pageContext.request.contextPath}/cosplay?' + buildParams({page: p}).toString();
    }

    function clearFilters() {
        document.querySelectorAll('.type-cb').forEach(cb => cb.checked = false);
    }

    // ═══════════════════════════ SLIDER ═══════════════════════════
    (function () {
        const slider = document.getElementById('cosplayHeroSlider');
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
