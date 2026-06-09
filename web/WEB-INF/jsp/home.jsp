<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Cửa hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">

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
        <form class="search-inline" method="GET" action="${pageContext.request.contextPath}/home" id="searchForm">
            <select name="type">
                <option value="">Tìm theo tên</option>
                <option value="category" ${param.type == 'category' ? 'selected' : ''}>Danh mục</option>
                <option value="style"    ${param.type == 'style'    ? 'selected' : ''}>Phong cách</option>
                <option value="occasion" ${param.type == 'occasion' ? 'selected' : ''}>Mục đích</option>
            </select>
            <input type="text" name="query" placeholder="Tìm kiếm sản phẩm..." value="${param.query}">
            <button type="submit">Tìm Kiếm</button>
        </form>

        <form method="POST" action="${pageContext.request.contextPath}/search" class="search-by-image" id="cameraSearchFormHome">
            <input type="hidden" name="cameraImageData" id="cameraImageDataHome">
            <button type="button" class="btn-start-camera" id="startCameraBtnHome">Mở camera</button>
            <button type="button" class="btn-image-search" id="captureSearchBtnHome">Chụp và tìm ngay</button>
            <div class="camera-preview-wrap" id="cameraPreviewWrapHome">
                <video id="cameraPreviewHome" class="camera-preview" autoplay playsinline muted></video>
            </div>
            <div class="camera-hint" id="cameraHintHome">Nhấn "Mở camera", căn sản phẩm vào khung hình, rồi bấm "Chụp và tìm ngay".</div>
        </form>
    </div>

    <button class="mobile-filter-toggle" id="mobileFilterToggle" aria-expanded="false">Bộ lọc</button>

    <!-- Mobile filter overlay (bottom-sheet) -->
    <div id="filterOverlay" class="filter-overlay" aria-hidden="true"></div>

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
                        <label>
                            <input type="checkbox" id="cat-all" style="width:15px;height:15px;accent-color:var(--orange);" ${empty selectedCategories ? 'checked' : ''}>
                            <span class="filter-chip-text">Tất Cả</span>
                        </label>
                    </div>
                    <c:set var="cats" value="${selectedCategories}" />
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Váy"     ${cats.contains('Váy')     ? 'checked' : ''}><span class="filter-chip-text">Chân váy / Váy</span></label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Áo"      ${cats.contains('Áo')      ? 'checked' : ''}><span class="filter-chip-text">Áo</span></label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Quần"    ${cats.contains('Quần')    ? 'checked' : ''}><span class="filter-chip-text">Quần</span></label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Áo khoác" ${cats.contains('Áo khoác') ? 'checked' : ''}><span class="filter-chip-text">Áo khoác</span></label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Áo dài"  ${cats.contains('Áo dài')  ? 'checked' : ''}><span class="filter-chip-text">Áo dài / Đồ truyền thống</span></label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Set"     ${cats.contains('Set')     ? 'checked' : ''}><span class="filter-chip-text">Set bộ</span></label><span class="sub-arrow">▾</span></div>
                    <div class="filter-item"><label><input type="checkbox" class="cat-cb" value="Đồ Golf" ${cats.contains('Đồ Golf') ? 'checked' : ''}><span class="filter-chip-text">Đồ Golf</span></label><span class="sub-arrow">▾</span></div>
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

// ═══════════════════════════ CAMERA SEARCH ═══════════════════════════
(function () {
    const form = document.getElementById('cameraSearchFormHome');
    const startBtn = document.getElementById('startCameraBtnHome');
    const captureBtn = document.getElementById('captureSearchBtnHome');
    const previewWrap = document.getElementById('cameraPreviewWrapHome');
    const video = document.getElementById('cameraPreviewHome');
    const imageDataInput = document.getElementById('cameraImageDataHome');
    const hint = document.getElementById('cameraHintHome');
    let stream = null;

    if (!form || !startBtn || !captureBtn || !previewWrap || !video || !imageDataInput || !hint) {
        return;
    }

    async function startCamera() {
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            hint.textContent = 'Thiết bị hoặc trình duyệt chưa hỗ trợ camera trực tiếp.';
            return;
        }

        try {
            stream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: { ideal: 'environment' } },
                audio: false
            });
            video.srcObject = stream;
            previewWrap.style.display = 'block';
            hint.textContent = 'Camera đã sẵn sàng. Nhấn "Chụp và tìm ngay" để tìm sản phẩm.';
        } catch (error) {
            hint.textContent = 'Không thể mở camera. Vui lòng cấp quyền camera trong trình duyệt.';
        }
    }

    function stopCamera() {
        if (!stream) {
            return;
        }
        stream.getTracks().forEach(track => track.stop());
        stream = null;
    }

    function captureAndSubmit() {
        if (!video.videoWidth || !video.videoHeight) {
            hint.textContent = 'Camera chưa sẵn sàng. Hãy mở camera trước khi chụp.';
            return;
        }

        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        const context = canvas.getContext('2d');
        context.drawImage(video, 0, 0, canvas.width, canvas.height);
        imageDataInput.value = canvas.toDataURL('image/jpeg', 0.9);
        stopCamera();
        form.submit();
    }

    startBtn.addEventListener('click', startCamera);
    captureBtn.addEventListener('click', captureAndSubmit);
    window.addEventListener('beforeunload', stopCamera);
})();

// Mobile filter toggle: show/hide the left filter panel on small screens
// Mobile filter bottom-sheet behavior
(function(){
    const btn = document.getElementById('mobileFilterToggle');
    const panel = document.getElementById('filterPanel');
    const overlay = document.getElementById('filterOverlay');
    if (!btn || !panel || !overlay) return;

    function openSheet(){
        panel.classList.add('filter-bottom','open');
        overlay.classList.add('open');
        btn.setAttribute('aria-expanded','true');
        overlay.addEventListener('click', closeSheet);
        // add swipe-down to close
        let startY=0;
        function onTouchStart(e){ startY = e.touches ? e.touches[0].clientY : e.clientY; }
        function onTouchMove(e){
            const y = e.touches ? e.touches[0].clientY : e.clientY;
            const dy = y - startY;
            if (dy>0) panel.style.transform = `translateY(${Math.min(dy, window.innerHeight)}px)`;
        }
        function onTouchEnd(e){ panel.style.transform=''; }
        panel.addEventListener('touchstart', onTouchStart);
        panel.addEventListener('touchmove', onTouchMove);
        panel.addEventListener('touchend', onTouchEnd);
    }

    function closeSheet(){
        panel.classList.remove('open');
        overlay.classList.remove('open');
        // keep filter-bottom class so desktop styling unaffected when resizing
        btn.setAttribute('aria-expanded','false');
        overlay.removeEventListener('click', closeSheet);
    }

    btn.addEventListener('click', function(){
        const isOpen = panel.classList.contains('open');
        if (isOpen) closeSheet(); else openSheet();
    });

    // close on Escape
    document.addEventListener('keydown', function(e){ if (e.key==='Escape') closeSheet(); });
})();
</script>
</body>
</html>
