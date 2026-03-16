<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết sản phẩm - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #f5f5f6;
            --surface: #ffffff;
            --line: #e9e6e2;
            --text: #1f1b19;
            --muted: #7a726c;
            --accent: #f28b55;
            --accent-strong: #e36f34;
            --dark-btn: #111111;
            --ok-bg: #ecf7ef;
            --ok-text: #1e7a34;
        }

        * { box-sizing: border-box; }
        body {
            margin: 0;
            background: var(--bg);
            color: var(--text);
            font-family: 'Inter', sans-serif;
        }

        .page-wrap {
            max-width: 1240px;
            margin: 0 auto;
            padding: 18px 16px 52px;
        }

        .breadcrumb {
            font-size: 12px;
            color: var(--muted);
            margin: 6px 0 14px;
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            align-items: center;
        }

        .breadcrumb a {
            color: #6f6b67;
            text-decoration: none;
        }

        .top-card {
            background: var(--surface);
            border: 1px solid var(--line);
            display: grid;
            grid-template-columns: 480px 1fr;
            gap: 24px;
            padding: 16px;
        }

        .gallery-wrap {
            display: grid;
            grid-template-columns: 68px 1fr;
            gap: 12px;
            align-items: start;
        }

        .thumb-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
            max-height: 640px;
            overflow: auto;
        }

        .thumb-btn {
            border: 1px solid #ddd;
            background: #fff;
            padding: 0;
            height: 84px;
            width: 100%;
            cursor: pointer;
            overflow: hidden;
        }

        .thumb-btn.active { border-color: #2b2b2b; }
        .thumb-btn img { width: 100%; height: 100%; object-fit: cover; display: block; }

        .main-image-wrap {
            position: relative;
            width: 100%;
            background: #f0efee;
            min-height: 640px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .main-image {
            width: 100%;
            height: 100%;
            min-height: 640px;
            object-fit: cover;
            display: block;
        }

        .favorite-btn {
            position: absolute;
            top: 12px;
            right: 12px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 1px solid #ddd;
            background: rgba(255,255,255,0.94);
            color: #8f8a85;
            font-size: 18px;
            cursor: pointer;
            z-index: 2;
        }

        .favorite-btn.active {
            color: #d1486a;
            border-color: #d1486a;
        }

        .detail-panel {
            display: grid;
            align-content: start;
            gap: 12px;
        }

        .brand-line {
            color: var(--muted);
            font-size: 12px;
            letter-spacing: 0.2px;
        }

        .product-title {
            font-family: 'Playfair Display', serif;
            margin: 0;
            font-size: clamp(24px, 3vw, 34px);
            line-height: 1.2;
        }

        .rating-line {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #8f8277;
            font-size: 13px;
        }

        .rating-stars { color: #f5a623; letter-spacing: 1px; }

        .price-block {
            border-top: 1px solid var(--line);
            border-bottom: 1px solid var(--line);
            padding: 12px 0;
            display: grid;
            gap: 8px;
        }

        .price-row {
            display: flex;
            align-items: baseline;
            gap: 10px;
            font-size: 13px;
        }

        .price-label { color: var(--muted); min-width: 42px; }
        .price-value {
            font-weight: 700;
            color: #111;
            font-size: 19px;
        }

        .price-sub {
            font-size: 12px;
            color: var(--accent-strong);
        }

        .size-wrap { display: grid; gap: 6px; }
        .meta-title {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: var(--muted);
            font-weight: 700;
        }

        .size-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .size-pill {
            border: 1px solid #d6d6d6;
            padding: 7px 12px;
            font-size: 13px;
            background: #fff;
        }

        .stock-line {
            font-size: 12px;
            color: var(--ok-text);
            background: var(--ok-bg);
            border: 1px solid #cde7d4;
            width: fit-content;
            padding: 6px 10px;
        }

        .summary-line {
            font-size: 13px;
            color: #5e5750;
            line-height: 1.6;
        }

        .action-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 2px;
        }

        .btn {
            border: none;
            padding: 11px 18px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background .2s ease;
        }

        .btn-book {
            background: var(--accent);
            color: #fff;
        }

        .btn-book:hover { background: var(--accent-strong); }

        .btn-back {
            background: var(--dark-btn);
            color: #fff;
        }

        .detail-grid {
            margin-top: 18px;
            display: grid;
            grid-template-columns: 1.6fr 0.9fr;
            gap: 16px;
        }

        .panel {
            background: var(--surface);
            border: 1px solid var(--line);
            padding: 18px;
        }

        .panel h3 {
            margin: 0 0 12px;
            font-size: 18px;
            letter-spacing: 0.2px;
        }

        .desc {
            white-space: pre-wrap;
            font-size: 14px;
            color: #393430;
            line-height: 1.7;
        }

        .kv {
            display: grid;
            grid-template-columns: 110px 1fr;
            gap: 10px;
            padding: 10px 0;
            border-top: 1px solid #f0ece8;
            font-size: 13px;
        }

        .kv:first-child { border-top: none; }
        .kv-label { color: var(--muted); }

        .ratings-block {
            margin-top: 16px;
            background: var(--surface);
            border: 1px solid var(--line);
            padding: 18px;
        }

        .ratings-block h3 {
            margin: 0 0 10px;
            font-size: 18px;
        }

        .rating-item {
            border-top: 1px solid #efe9e3;
            padding: 12px 0;
        }

        .rating-item:first-child { border-top: none; }

        .rating-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            font-size: 13px;
        }

        .rating-comment {
            margin-top: 6px;
            color: #473f39;
            font-size: 14px;
            line-height: 1.6;
            white-space: pre-wrap;
        }

        .muted { color: var(--muted); }

        @media (max-width: 1100px) {
            .top-card { grid-template-columns: 1fr; }
            .main-image-wrap, .main-image { min-height: 520px; }
        }

        @media (max-width: 880px) {
            .detail-grid { grid-template-columns: 1fr; }
            .gallery-wrap { grid-template-columns: 56px 1fr; }
            .thumb-btn { height: 72px; }
            .main-image-wrap, .main-image { min-height: 440px; }
            .kv { grid-template-columns: 1fr; gap: 4px; }
        }
    </style>
</head>
<body>
<%
    Object accountObj = session.getAttribute("account");
    Object userRole = session.getAttribute("userRole");
    String role = userRole != null ? userRole.toString() : "";
    boolean isLoggedIn = accountObj != null;
%>

<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="page-wrap">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
        <span>›</span>
        <span>${clothing.category}</span>
        <span>›</span>
        <span>${clothing.clothingName}</span>
    </div>

    <div class="top-card">
        <div class="gallery-wrap">
            <c:choose>
                <c:when test="${not empty images}">
                    <div class="thumb-list" id="thumbs">
                        <c:forEach items="${images}" var="img" varStatus="loop">
                            <button class="thumb-btn" data-index="${loop.index}" onclick="return showImage(this.dataset.index);" type="button">
                                <img src="${pageContext.request.contextPath}/image?imageId=${img.imageID}" alt="Ảnh phụ ${loop.index + 1}">
                            </button>
                        </c:forEach>
                    </div>
                    <div class="main-image-wrap">
                        <% if (isLoggedIn) { %>
                            <button class="favorite-btn" id="favoriteBtn" data-clothing-id="${clothing.clothingID}" onclick="toggleFavorite(this)" title="Thêm vào yêu thích" type="button">♡</button>
                        <% } %>
                        <img id="mainImage" class="main-image" src="${pageContext.request.contextPath}/image?imageId=${images[0].imageID}" alt="${clothing.clothingName}">
                    </div>
                </c:when>
                <c:otherwise>
                    <div></div>
                    <div class="main-image-wrap">
                        <% if (isLoggedIn) { %>
                            <button class="favorite-btn" id="favoriteBtn" data-clothing-id="${clothing.clothingID}" onclick="toggleFavorite(this)" title="Thêm vào yêu thích" type="button">♡</button>
                        <% } %>
                        <img id="mainImage" class="main-image" src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="detail-panel">
            <div class="brand-line">
                <c:choose>
                    <c:when test="${not empty clothing.category}">${clothing.category}</c:when>
                    <c:otherwise>Sản phẩm</c:otherwise>
                </c:choose>
            </div>
            <h1 class="product-title">${clothing.clothingName}</h1>

            <div class="rating-line">
                <span class="rating-stars">★</span>
                <c:choose>
                    <c:when test="${avgRating > 0}">
                        <span><fmt:formatNumber value="${avgRating}" type="number" maxFractionDigits="1" minFractionDigits="1"/> / 5</span>
                    </c:when>
                    <c:otherwise>
                        <span>Chưa có đánh giá</span>
                    </c:otherwise>
                </c:choose>
                <span class="muted">(${fn:length(ratings)} đánh giá)</span>
            </div>

            <div class="price-block">
                <div class="price-row">
                    <span class="price-label">Thuê ngày:</span>
                    <span class="price-value"><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> đ</span>
                </div>
                <div class="price-row">
                    <span class="price-label">Thuê giờ:</span>
                    <span class="price-value"><fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,##0"/> đ</span>
                </div>
            </div>

            <div class="size-wrap">
                <div class="meta-title">Size</div>
                <div class="size-list">
                    <c:choose>
                        <c:when test="${not empty clothing.size}">
                            <c:forEach var="sz" items="${fn:split(clothing.size, ',')}">
                                <span class="size-pill">${fn:trim(sz)}</span>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <span class="muted">Không có thông tin size</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="stock-line">
                Có sẵn: ${clothing.availableFrom} → ${clothing.availableTo}
            </div>

            <c:if test="${not empty cosplayDetail and clothing.category eq 'Cosplay'}">
                <div class="summary-line">
                    <strong>Phụ kiện đi kèm:</strong> ${cosplayDetail.accessoryList}
                </div>
            </c:if>

            <c:choose>
                <c:when test="${not empty clothing.description}">
                    <div class="summary-line">${clothing.description}</div>
                </c:when>
                <c:otherwise>
                    <div class="summary-line">Sản phẩm chưa có mô tả chi tiết.</div>
                </c:otherwise>
            </c:choose>

            <div class="action-row">
                <% if (!"Manager".equals(role) && !"Admin".equals(role)) { %>
                    <!-- <button class="btn btn-book" onclick="handleBooking()" type="button">Thêm vào giỏ thuê</button> -->
                    <button class="btn btn-back" onclick="handleBooking()" type="button">Thuê ngay</button>
                <% } %>
                <button class="btn btn-back" onclick="history.back()" type="button">Quay lại</button>
            </div>
        </div>
    </div>

    <div class="detail-grid">
        <div class="panel">
            <h3>Mô tả sản phẩm</h3>
            <c:choose>
                <c:when test="${not empty clothing.description}">
                    <div class="desc">${clothing.description}</div>
                </c:when>
                <c:otherwise>
                    <div class="desc">Chưa có mô tả.</div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="panel">
            <h3>Thông tin chi tiết</h3>
            <div class="kv">
                <div class="kv-label">Mã sản phẩm</div>
                <div>WC-${clothing.clothingID}</div>
            </div>
            <div class="kv">
                <div class="kv-label">Danh mục</div>
                <div><c:choose><c:when test="${not empty clothing.category}">${clothing.category}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label">Phong cách</div>
                <div><c:choose><c:when test="${not empty clothing.style}">${clothing.style}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label">Mục đích</div>
                <div><c:choose><c:when test="${not empty clothing.occasion}">${clothing.occasion}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label">Size</div>
                <div><c:choose><c:when test="${not empty clothing.size}">${clothing.size}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label">Giá ngày</div>
                <div><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> đ</div>
            </div>
        </div>
    </div>

    <div class="ratings-block">
        <h3>Đánh giá sản phẩm</h3>
        <c:choose>
            <c:when test="${empty ratings}">
                <div class="muted">Sản phẩm chưa có đánh giá.</div>
            </c:when>
            <c:otherwise>
                <c:choose>
                    <c:when test="${sessionScope.userRole == 'Admin' || sessionScope.userRole == 'Manager'}">
                        <h4>Đánh giá của người thuê về sản phẩm</h4>
                        <c:forEach var="r" items="${ratings}">
                            <c:if test="${r.ratingFromUserID == r.rentalRenterUserID}">
                                <div class="rating-item">
                                    <div class="rating-meta">
                                        <span class="rating-stars">
                                            <c:forEach var="i" begin="1" end="5">
                                                <c:choose>
                                                    <c:when test="${i <= r.rating}"><span>★</span></c:when>
                                                    <c:otherwise><span>☆</span></c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </span>
                                        <span>${r.ratingFromUsername}</span>
                                        <span class="muted">•</span>
                                        <span class="muted"><fmt:formatNumber value="${r.rating}" type="number" maxFractionDigits="0"/>/5</span>
                                    </div>
                                    <c:if test="${not empty r.comment}">
                                        <div class="rating-comment">${r.comment}</div>
                                    </c:if>
                                </div>
                            </c:if>
                        </c:forEach>

                        <h4 style="margin-top:16px;">Đánh giá của người cho thuê về khách thuê</h4>
                        <c:forEach var="r" items="${ratings}">
                            <c:if test="${r.ratingFromUserID == r.rentalManagerUserID}">
                                <div class="rating-item">
                                    <div class="rating-meta">
                                        <span class="rating-stars">
                                            <c:forEach var="i" begin="1" end="5">
                                                <c:choose>
                                                    <c:when test="${i <= r.rating}"><span>★</span></c:when>
                                                    <c:otherwise><span>☆</span></c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </span>
                                        <span>${r.ratingFromUsername}</span>
                                        <span class="muted">•</span>
                                        <span class="muted"><fmt:formatNumber value="${r.rating}" type="number" maxFractionDigits="0"/>/5</span>
                                    </div>
                                    <c:if test="${not empty r.comment}">
                                        <div class="rating-comment">${r.comment}</div>
                                    </c:if>
                                </div>
                            </c:if>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="r" items="${ratings}">
                            <c:if test="${r.ratingFromUserID == r.rentalRenterUserID}">
                                <div class="rating-item">
                                    <div class="rating-meta">
                                        <span class="rating-stars">
                                            <c:forEach var="i" begin="1" end="5">
                                                <c:choose>
                                                    <c:when test="${i <= r.rating}"><span>★</span></c:when>
                                                    <c:otherwise><span>☆</span></c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </span>
                                        <span>${r.ratingFromUsername}</span>
                                        <span class="muted">•</span>
                                        <span class="muted"><fmt:formatNumber value="${r.rating}" type="number" maxFractionDigits="0"/>/5</span>
                                    </div>
                                    <c:if test="${not empty r.comment}">
                                        <div class="rating-comment">${r.comment}</div>
                                    </c:if>
                                </div>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    function toggleFavorite(btn) {
        if (!btn) return;
        var clothingID = btn.getAttribute('data-clothing-id');
        if (!clothingID) return;

        btn.classList.toggle('active');
        var action = btn.classList.contains('active') ? 'add' : 'remove';

        fetch('${pageContext.request.contextPath}/user?action=' + action + 'Favorite&clothingID=' + clothingID, {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (!data.success) {
                btn.classList.toggle('active');
            }
        })
        .catch(() => {
            btn.classList.toggle('active');
        });
    }

    window.addEventListener('load', function() {
        var btn = document.getElementById('favoriteBtn');
        var thumbButtons = document.querySelectorAll('#thumbs .thumb-btn');
        if (thumbButtons.length) {
            thumbButtons[0].classList.add('active');
        }

        if (!btn) return;

        var clothingID = btn.getAttribute('data-clothing-id');
        fetch('${pageContext.request.contextPath}/user?action=checkFavorite&clothingID=' + clothingID)
            .then(response => response.json())
            .then(data => {
                if (data.isFavorited) {
                    btn.classList.add('active');
                }
            })
            .catch(() => {});
    });

    function handleBooking() {
        window.location.href = '${pageContext.request.contextPath}/rental?action=booking&clothingID=${clothing.clothingID}&hourlyPrice=${clothing.hourlyPrice}&dailyPrice=${clothing.dailyPrice}';
    }

    const images = [
        <c:forEach items="${images}" var="img" varStatus="loop">
            '${pageContext.request.contextPath}/image?imageId=${img.imageID}'<c:if test="${not loop.last}">,</c:if>
        </c:forEach>
    ];

    function showImage(idx) {
        if (!images.length) return false;
        idx = Number(idx);

        const main = document.getElementById('mainImage');
        const buttons = document.querySelectorAll('#thumbs .thumb-btn');

        if (main && images[idx]) {
            main.src = images[idx];
        }

        buttons.forEach((btn, i) => btn.classList.toggle('active', i === idx));
        return false;
    }
</script>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
