<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Cửa hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');
        :root {
            --ink: #15110f;
            --muted: #6f6a64;
            --paper: #f7f3ee;
            --card: #ffffff;
            --accent: #1f8e74;
            --accent-strong: #156c57;
            --sun: #f2a65a;
            --orange: #f97316;
            --shadow: 0 4px 18px rgba(20,16,11,0.09);
            --radius: 14px;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: #f5f4f2;
            margin: 0; color: var(--ink);
        }
        h1,h2,h3,h4,h5,h6 { font-family: 'Poppins', sans-serif; }
        .container { max-width: 1320px; margin: 0 auto; padding: 22px 16px 60px; }

        /* ── Hero Slider ── */
        .hero-slider {
            position: relative; overflow: hidden;
            background: linear-gradient(135deg,#1f8e74,#1b5d49);
            color: white; margin-bottom: 20px; border-radius: 18px;
            box-shadow: 0 16px 34px rgba(20,16,11,.12);
            width: 100%; aspect-ratio: 1200/400;
        }
        .hero-slider::before { content:""; position:absolute; top:-120px; right:-80px; width:240px; height:240px; background:rgba(255,255,255,.12); border-radius:50%; }
        .hero-slider::after  { content:""; position:absolute; bottom:-100px; left:-60px; width:200px; height:200px; background:rgba(0,0,0,.12); border-radius:50%; }
        .slider-track { position:relative; width:100%; height:100%; }
        .hero-slide { position:absolute; inset:0; opacity:0; visibility:hidden; transition:opacity 1.2s ease; }
        .hero-slide.active { opacity:1; visibility:visible; }
        .hero-slide img { width:100%; height:100%; object-fit:cover; display:block; }
        .hero-overlay { position:absolute; left:0; right:0; bottom:0; padding:18px 22px; background:linear-gradient(transparent,rgba(0,0,0,.55)); z-index:2; }
        .hero-tag { display:inline-flex; align-items:center; gap:8px; padding:5px 11px; border-radius:999px; background:rgba(255,255,255,.2); font-size:11px; letter-spacing:.4px; text-transform:uppercase; margin-bottom:6px; }
        .hero-overlay h1 { margin:0; font-size:clamp(20px,3vw,30px); }
        .hero-overlay p  { margin:4px 0 0; opacity:.92; font-size:14px; }
        .slider-btn { position:absolute; top:50%; transform:translateY(-50%); width:38px; height:38px; border:none; border-radius:50%; background:rgba(0,0,0,.38); color:#fff; font-size:22px; cursor:pointer; z-index:3; display:inline-flex; align-items:center; justify-content:center; }
        .slider-btn:hover { background:rgba(0,0,0,.58); }
        .slider-btn.prev { left:10px; }
        .slider-btn.next { right:10px; }
        .slider-dots { position:absolute; left:50%; bottom:12px; transform:translateX(-50%); display:flex; gap:7px; z-index:4; }
        .slider-dot { width:9px; height:9px; border-radius:50%; border:none; background:rgba(255,255,255,.5); cursor:pointer; }
        .slider-dot.active { background:#fff; transform:scale(1.2); }

        /* ── Search Bar ── */
        .search-bar { margin-bottom: 18px; background:var(--card); padding:14px 16px; border-radius:14px; box-shadow:var(--shadow); border:1px solid rgba(0,0,0,.05); }
        .search-bar form { display:flex; gap:10px; flex-wrap:wrap; align-items:center; }
        .search-bar select, .search-bar input[type=text] { padding:10px 12px; border:1px solid #e3ddd5; border-radius:10px; background:#fcfaf7; font-size:13px; flex:1; min-width:120px; }
        .search-bar button { padding:10px 24px; background:var(--accent); color:#fff; border:none; cursor:pointer; border-radius:999px; font-weight:600; font-size:13px; transition:background .2s,transform .2s; white-space:nowrap; }
        .search-bar button:hover { background:var(--accent-strong); transform:translateY(-1px); }

        /* ── Layout ── */
        .main-content { display:flex; gap:18px; align-items:flex-start; }

        /* ── Filter Panel ── */
        .filter-panel {
            width: 240px; flex-shrink:0;
            background:var(--card); border-radius:14px;
            box-shadow:var(--shadow); border:1px solid rgba(0,0,0,.06);
            position:sticky; top:74px; overflow:hidden;
        }
        .filter-title-bar {
            display:flex; align-items:center; justify-content:space-between;
            padding:14px 16px; border-bottom:1px solid #f0ebe4;
            font-weight:700; font-size:14px; letter-spacing:.3px;
        }
        .filter-action-btns { display:flex; gap:8px; }
        .btn-apply {
            padding:6px 14px; border-radius:999px; border:none; cursor:pointer;
            background:var(--orange); color:#fff; font-size:12px; font-weight:600;
            transition:background .2s;
        }
        .btn-apply:hover { background:#ea6c0a; }
        .btn-clear {
            padding:6px 12px; border-radius:999px; border:1px solid #d4cec6; cursor:pointer;
            background:#fff; color:var(--ink); font-size:12px; font-weight:600;
        }
        .btn-clear:hover { background:#f5f0ea; }

        /* Filter sections */
        .filter-section { border-bottom:1px solid #f0ebe4; }
        .filter-section:last-child { border-bottom:none; }
        .filter-section-header {
            display:flex; justify-content:space-between; align-items:center;
            padding:12px 16px; cursor:pointer; user-select:none;
            font-weight:700; font-size:12px; letter-spacing:.8px; color:#333;
        }
        .filter-section-header:hover { background:#fcf9f5; }
        .section-toggle { font-size:16px; color:#888; line-height:1; }
        .filter-section-body { padding:6px 16px 12px; display:none; }
        .filter-section.open .filter-section-body { display:block; }
        .filter-section.open .section-toggle { content:"−"; }

        /* Filter items */
        .filter-item-all {
            display:flex; align-items:center; gap:8px;
            padding:7px 0; font-size:13px; cursor:pointer;
            color:var(--ink); font-weight:500;
        }
        .filter-item {
            display:flex; align-items:center; justify-content:space-between;
            padding:6px 0; font-size:13px; cursor:pointer;
        }
        .filter-item label {
            display:flex; align-items:center; gap:8px; cursor:pointer; flex:1;
            color:var(--ink);
        }
        .filter-item input[type=checkbox] {
            width:15px; height:15px; accent-color:var(--orange);
            border-radius:3px; cursor:pointer; flex-shrink:0;
        }
        .filter-item .sub-arrow { color:#bbb; font-size:10px; }

        /* ── Products Area ── */
        .products-area { flex:1; min-width:0; }

        /* Top bar: date + sort */
        .products-topbar {
            display:flex; align-items:center; justify-content:space-between;
            gap:12px; margin-bottom:14px; flex-wrap:wrap;
        }
        .date-range {
            display:flex; align-items:center; gap:8px;
            background:var(--card); padding:8px 14px; border-radius:10px;
            box-shadow:var(--shadow); border:1px solid rgba(0,0,0,.06);
        }
        .date-range .date-icon { color:#888; font-size:15px; }
        .date-range input[type=date] {
            border:none; background:transparent; font-size:13px;
            color:var(--ink); cursor:pointer; padding:2px 0; outline:none;
        }
        .date-range .separator { color:#ccc; font-size:13px; }

        .sort-tabs { display:flex; gap:6px; flex-wrap:wrap; }
        .sort-tab {
            padding:7px 14px; border-radius:8px; border:1px solid #ddd;
            font-size:12px; font-weight:600; cursor:pointer; background:#fff;
            color:var(--muted); text-decoration:none; transition:all .15s;
            white-space:nowrap;
        }
        .sort-tab:hover { border-color:var(--orange); color:var(--orange); }
        .sort-tab.active { background:var(--orange); color:#fff; border-color:var(--orange); }

        /* ── Product Grid ── */
        .products-grid {
            display:grid;
            grid-template-columns: repeat(4, minmax(0,1fr));
            gap:14px;
        }
        @media(max-width:1100px) { .products-grid { grid-template-columns:repeat(3,minmax(0,1fr)); } }
        @media(max-width:820px)  { .products-grid { grid-template-columns:repeat(2,minmax(0,1fr)); } .filter-panel { display:none; } }
        @media(max-width:500px)  { .products-grid { grid-template-columns:1fr; } }

        /* ── Product Card ── */
        .product-card {
            display:block; background:var(--card); border-radius:12px;
            overflow:hidden; box-shadow:var(--shadow); border:1px solid rgba(0,0,0,.05);
            text-decoration:none; color:inherit; transition:transform .25s,box-shadow .25s;
        }
        .product-card:hover { transform:translateY(-5px); box-shadow:0 14px 28px rgba(0,0,0,.15); }
        .product-image-wrap { position:relative; overflow:hidden; aspect-ratio:4/5; background:#efe9e1; }
        .product-image { width:100%; height:100%; object-fit:cover; display:block; transition:transform .4s ease; }
        .product-card:hover .product-image { transform:scale(1.04); }

        /* HOT badge */
        .badge-hot {
            position:absolute; top:10px; left:10px;
            background:#e8003d; color:#fff; font-size:10px; font-weight:700;
            padding:3px 8px; border-radius:4px; letter-spacing:.5px; z-index:2;
        }
        /* Heart icon */
        .btn-heart {
            position:absolute; top:10px; right:10px;
            width:32px; height:32px; border-radius:50%;
            background:rgba(255,255,255,.86); border:none; cursor:pointer;
            display:flex; align-items:center; justify-content:center;
            font-size:15px; z-index:2; transition:background .2s;
        }
        .btn-heart:hover { background:#fff; }
        /* Status badge (Hàng sắp về etc.) */
        .badge-status {
            position:absolute; bottom:0; left:0; right:0;
            background:rgba(140,130,200,.78); color:#fff;
            font-size:11px; font-weight:600; text-align:center;
            padding:5px 8px; z-index:2;
        }

        /* Card body */
        .product-info { padding:10px 12px 12px; }
        .product-name { font-size:13px; font-weight:600; color:var(--ink); line-height:1.35; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
        .product-price-row { display:flex; justify-content:space-between; align-items:flex-end; margin-top:8px; gap:6px; }
        .product-price-info { display:flex; flex-direction:column; gap:2px; }
        .price-thue { font-size:12px; color:var(--ink); font-weight:600; }
        .price-thue span { color:var(--orange); }
        .price-promo { font-size:10px; color:var(--muted); margin-top:2px; font-style:italic; }
        .btn-add {
            width:30px; height:30px; border-radius:50%; border:none; cursor:pointer;
            background:var(--orange); color:#fff; font-size:18px; line-height:1;
            display:flex; align-items:center; justify-content:center; flex-shrink:0;
            transition:background .2s;
        }
        .btn-add:hover { background:#ea6c0a; }

        /* ── Empty state ── */
        .no-products { text-align:center; padding:50px 20px; color:var(--muted); background:var(--card); border-radius:14px; box-shadow:var(--shadow); }

        /* ── Pagination ── */
        .pagination { margin:22px 0 0; display:flex; flex-wrap:wrap; gap:6px; justify-content:center; }
        .page-link { padding:8px 13px; border-radius:9px; background:var(--card); border:1px solid rgba(0,0,0,.1); color:var(--ink); text-decoration:none; font-weight:600; font-size:13px; }
        .page-link:hover { background:#efe9e1; }
        .page-link.active { background:var(--orange); color:#fff; border-color:var(--orange); }

        /* ── breadcrumb ── */
        .breadcrumb { margin-bottom:14px; color:var(--muted); font-size:13px; }
        .breadcrumb a { color:var(--accent-strong); text-decoration:none; }

        /* Mobile filter toggle */
        .mobile-filter-toggle {
            display:none; width:100%; padding:10px; margin-bottom:12px;
            background:var(--card); border:1px solid #e0dcd6; border-radius:10px;
            font-weight:600; font-size:13px; cursor:pointer;
        }
        @media(max-width:820px) { .mobile-filter-toggle { display:block; } }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">WearConnect</a> › Cửa Hàng
    </div>

    <%-- Hero Slider --%>
    <div class="hero-slider" id="homeHeroSlider">
        <div class="slider-track">
            <div class="hero-slide active">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-1.jpg?v=2" alt="WearConnect banner 1" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay"><span class="hero-tag">Sàn giao thuê trang phục</span><h1>WearConnect</h1><p>Wear once – Connect forever</p></div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-2.jpg?v=2" alt="WearConnect banner 2" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay"><span class="hero-tag">Sàn giao thuê trang phục</span><h1>WearConnect</h1><p>Wear once – Connect forever</p></div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-3.jpg?v=2" alt="WearConnect banner 3" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay"><span class="hero-tag">Sàn giao thuê trang phục</span><h1>WearConnect</h1><p>Wear once – Connect forever</p></div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-4.jpg?v=2" alt="WearConnect banner 4" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay"><span class="hero-tag">Sàn giao thuê trang phục</span><h1>WearConnect</h1><p>Wear once – Connect forever</p></div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-5.jpg?v=2" alt="WearConnect banner 5" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay"><span class="hero-tag">Sàn giao thuê trang phục</span><h1>WearConnect</h1><p>Wear once – Connect forever</p></div>
            </div>
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/uploads/slider/slide-6.jpg?v=2" alt="WearConnect banner 6" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/wear-connect-logo.png';">
                <div class="hero-overlay"><span class="hero-tag">Sàn giao thuê trang phục</span><h1>WearConnect</h1><p>Wear once – Connect forever</p></div>
            </div>
        </div>
        <button type="button" class="slider-btn prev" aria-label="Slide trước">‹</button>
        <button type="button" class="slider-btn next" aria-label="Slide sau">›</button>
        <div class="slider-dots" aria-label="Điều hướng slide"></div>
    </div>

    <%-- Search Bar --%>
    <div class="search-bar">
        <form method="GET" action="${pageContext.request.contextPath}/home" id="searchForm">
            <select name="type">
                <option value="">Tìm theo tên</option>
                <option value="category" ${param.type == 'category' ? 'selected' : ''}>Danh mục</option>
                <option value="style"    ${param.type == 'style'    ? 'selected' : ''}>Phong cách</option>
                <option value="occasion" ${param.type == 'occasion' ? 'selected' : ''}>Mục đích</option>
            </select>
            <input type="text" name="query" placeholder="Tìm kiếm sản phẩm..." value="${param.query}">
            <button type="submit">Tìm Kiếm</button>
        </form>
    </div>

    <%-- Main Content: Filter + Products --%>
    <div class="main-content">

        <%-- ─── Left Filter Panel ─── --%>
        <aside class="filter-panel" id="filterPanel">
            <div class="filter-title-bar">
                <span>Bộ Lọc Sản Phẩm</span>
                <div class="filter-action-btns">
                    <button class="btn-apply" onclick="applyFilters()">Áp dụng</button>
                    <button class="btn-clear" onclick="clearFilters()">Bỏ chọn</button>
                </div>
            </div>

            <%-- TRANG PHỤC --%>
            <div class="filter-section open" id="sec-trang-phuc">
                <div class="filter-section-header" onclick="toggleSection('sec-trang-phuc')">
                    TRANG PHỤC <span class="section-toggle">−</span>
                </div>
                <div class="filter-section-body">
                    <div class="filter-item-all" id="item-all" onclick="selectAll()">
                        <input type="checkbox" id="cat-all" style="width:15px;height:15px;accent-color:var(--orange);"
                            ${empty selectedCategories ? 'checked' : ''}> Tất Cả
                    </div>
                    <c:set var="cats" value="${selectedCategories}" />
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Váy"     ${cats.contains('Váy')     ? 'checked' : ''}> Chân váy / Váy</label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Áo"      ${cats.contains('Áo')      ? 'checked' : ''}> Áo</label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Quần"    ${cats.contains('Quần')    ? 'checked' : ''}> Quần</label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Áo khoác" ${cats.contains('Áo khoác') ? 'checked' : ''}> Áo khoác</label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Áo dài"  ${cats.contains('Áo dài')  ? 'checked' : ''}> Áo dài / Đồ truyền thống</label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Set"     ${cats.contains('Set')     ? 'checked' : ''}> Set bộ</label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Đồ Golf" ${cats.contains('Đồ Golf') ? 'checked' : ''}> Đồ Golf</label><span class="sub-arrow">▾</span></div>
                </div>
            </div>
        </aside>

        <%-- ─── Right Products Area ─── --%>
        <div class="products-area">

            <%-- Top bar --%>
            <div class="products-topbar">
                <div class="sort-tabs">
                    <a class="sort-tab ${currentSort == 'newest' || empty currentSort ? 'active' : ''}"  href="javascript:void(0)" onclick="applySort('newest')">Mới nhất</a>
                    <a class="sort-tab ${currentSort == 'popular' ? 'active' : ''}"   href="javascript:void(0)" onclick="applySort('popular')">Đánh giá cao nhất</a>
                    <a class="sort-tab ${currentSort == 'price_asc' ? 'active' : ''}" href="javascript:void(0)" onclick="applySort('price_asc')">Giá từ thấp đến cao</a>
                    <a class="sort-tab ${currentSort == 'price_desc' ? 'active' : ''}" href="javascript:void(0)" onclick="applySort('price_desc')">Giá từ cao đến thấp</a>
                </div>
            </div>

            <%-- Products Grid --%>
            <c:choose>
                <c:when test="${empty products}">
                    <div class="no-products">
                        <p style="font-size:16px;">Không tìm thấy sản phẩm phù hợp.</p>
                        <p>Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="products-grid">
                        <c:forEach var="product" items="${products}">
                            <a class="product-card" href="${pageContext.request.contextPath}/clothing?action=view&id=${product.clothingID}">
                                <div class="product-image-wrap">
                                    <span class="badge-hot">HOT</span>
                                    <button class="btn-heart" onclick="event.preventDefault()" aria-label="Yêu thích">♡</button>
                                    <img src="${pageContext.request.contextPath}/image?id=${product.clothingID}" alt="${product.clothingName}" class="product-image">
                                    <%-- "Hàng sắp về" nếu chưa đến ngày cho thuê --%>
                                    <%-- (Client-side check not feasible here; use text from availableFrom if needed) --%>
                                </div>
                                <div class="product-info">
                                    <div class="product-name">${product.clothingName}</div>
                                    <div class="product-price-row">
                                        <div class="product-price-info">
                                            <div class="price-thue">Thuê ngày: <span><fmt:formatNumber value="${product.dailyPrice}" pattern="#,##0"/> đ</span></div>
                                            <div class="price-thue">Thuê giờ: <span><fmt:formatNumber value="${product.hourlyPrice}" pattern="#,##0"/> đ</span></div>
                                            <div class="price-promo">Thuê 0đ khi mua gói ưu đãi</div>
                                        </div>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>

                    <%-- Pagination --%>
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
                </c:otherwise>
            </c:choose>
        </div><%-- /products-area --%>
    </div><%-- /main-content --%>
</div><%-- /container --%>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />

<script>
// ═══════════════════════════ SLIDER ═══════════════════════════
(function () {
    const slider = document.getElementById('homeHeroSlider');
    if (!slider) return;
    const slides = Array.from(slider.querySelectorAll('.hero-slide'));
    const dotsContainer = slider.querySelector('.slider-dots');
    const prevBtn = slider.querySelector('.slider-btn.prev');
    const nextBtn = slider.querySelector('.slider-btn.next');
    let idx = 0, autoTimer;
    if (slides.length <= 1) { if(prevBtn)prevBtn.style.display='none'; if(nextBtn)nextBtn.style.display='none'; return; }
    slides.forEach((_,i) => {
        const d = document.createElement('button'); d.type='button';
        d.className='slider-dot'+(i===0?' active':'');
        d.addEventListener('click',()=>{show(i);restart();});
        dotsContainer.appendChild(d);
    });
    const dots = Array.from(dotsContainer.querySelectorAll('.slider-dot'));
    function show(i) { idx=(i+slides.length)%slides.length; slides.forEach((s,j)=>s.classList.toggle('active',j===idx)); dots.forEach((d,j)=>d.classList.toggle('active',j===idx)); }
    function next() { show(idx+1); }
    function prev() { show(idx-1); }
    function start() { autoTimer=setInterval(next,7000); }
    function restart() { clearInterval(autoTimer); start(); }
    prevBtn.addEventListener('click',()=>{prev();restart();});
    nextBtn.addEventListener('click',()=>{next();restart();});
    slider.addEventListener('mouseenter',()=>clearInterval(autoTimer));
    slider.addEventListener('mouseleave',start);
    start();
})();

// ═══════════════════════════ FILTER PANEL ═══════════════════════════
function toggleSection(id) {
    const sec = document.getElementById(id);
    const isOpen = sec.classList.toggle('open');
    sec.querySelector('.section-toggle').textContent = isOpen ? '−' : '+';
}

function selectAll() {
    const catAll = document.getElementById('cat-all');
    catAll.checked = !catAll.checked;
    if (catAll.checked) {
        document.querySelectorAll('.cat-cb').forEach(cb => cb.checked = false);
    }
}

document.querySelectorAll('.cat-cb').forEach(cb => {
    cb.addEventListener('change', function() {
        if (this.checked) {
            document.getElementById('cat-all').checked = false;
        } else {
            const anyChecked = Array.from(document.querySelectorAll('.cat-cb')).some(c => c.checked);
            if (!anyChecked) document.getElementById('cat-all').checked = true;
        }
    });
});

function buildParams(extra) {
    const params = new URLSearchParams();
    // Preserve search
    const searchForm = document.getElementById('searchForm');
    const qType  = searchForm.querySelector('[name=type]').value;
    const qQuery = searchForm.querySelector('[name=query]').value;
    if (qType)  params.append('type', qType);
    if (qQuery) params.append('query', qQuery);
    // Categories
    const catAll = document.getElementById('cat-all');
    if (!catAll.checked) {
        document.querySelectorAll('.cat-cb:checked').forEach(cb => params.append('categories', cb.value));
    }
    // Sort
    const currentSort = '${currentSort}';
    params.append('sort', (extra && extra.sort) ? extra.sort : currentSort);
    // Page
    params.append('page', (extra && extra.page) ? extra.page : 1);
    return params;
}

function applyFilters() {
    window.location.href = '${pageContext.request.contextPath}/home?' + buildParams().toString();
}

function applySort(sortVal) {
    window.location.href = '${pageContext.request.contextPath}/home?' + buildParams({sort: sortVal, page: 1}).toString();
}

function goPage(p) {
    window.location.href = '${pageContext.request.contextPath}/home?' + buildParams({page: p}).toString();
}

function clearFilters() {
    document.querySelectorAll('.cat-cb').forEach(cb => cb.checked = false);
    document.getElementById('cat-all').checked = true;
}
</script>
</body>
</html>
