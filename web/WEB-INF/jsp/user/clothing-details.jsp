<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Chi tiết sản phẩm - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/clothing-details.css">
    <style>
        /* Responsive adjustments for mobile */
        @media (max-width: 768px) {
            .top-card {
                display: flex !important;
                flex-direction: column !important;
                padding: 15px !important;
            }
            .gallery-wrap {
                display: flex !important;
                flex-direction: column-reverse !important; /* Đẩy thumbnails xuống dưới ảnh chính */
                width: 100% !important;
            }
            .thumb-list {
                display: flex !important;
                flex-direction: row !important;
                overflow-x: auto !important;
                margin-top: 15px !important;
                gap: 10px !important;
                padding-bottom: 5px; /* Tránh bị cắt thanh cuộn */
            }
            .thumb-btn {
                flex-shrink: 0 !important; /* Không cho thumbnail bị ép nhỏ */
            }
            .detail-panel {
                width: 100% !important;
                padding-left: 0 !important;
                padding-top: 20px !important;
            }
            .detail-grid {
                display: flex !important;
                flex-direction: column !important;
                gap: 15px !important;
            }
            .action-row {
                display: flex !important;
                flex-direction: column !important;
                gap: 10px !important;
            }
            .action-row .btn {
                width: 100% !important;
                margin: 0 !important;
            }
            .breadcrumb {
                white-space: nowrap;
                overflow-x: auto;
            }
        }
        .back-link:hover {
            color: var(--primary-color) !important;
        }
    </style>
</head>
<body class="clothing-page">
<%
    Object accountObj = session.getAttribute("account");
    Object userRole = session.getAttribute("userRole");
    String role = userRole != null ? userRole.toString() : "";
    boolean isLoggedIn = accountObj != null;
%>

<jsp:include page="/WEB-INF/jsp/components/header.jsp" />
<%
    boolean isForSale = false;
    Model.Clothing clothing = (Model.Clothing) request.getAttribute("clothing");
    if (clothing != null) {
        Model.Account owner = DAO.AccountDAO.findById(clothing.getRenterID());
        if (owner != null && "Renter".equals(owner.getUserRole())) {
            isForSale = true;
        }
    }
%>

<div class="page-wrap">
    <div class="breadcrumb" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; margin-bottom: 20px;">
        <div>
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span>›</span>
            <span>${clothing.category}</span>
            <span>›</span>
            <span>${clothing.clothingName}</span>
        </div>
        <a href="javascript:void(0);" onclick="handleBack()" class="back-link" style="display: inline-flex; align-items: center; gap: 6px; text-decoration: none; color: var(--gray-600); font-weight: 600; font-size: 14px; transition: color var(--transition-fast);">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
            Quay lại
        </a>
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
                <% if (isForSale) { %>
                    <div class="price-row">
                        <span class="price-label">Giá bán:</span>
                        <span class="price-value" style="color: #d97706; font-size: 24px; font-weight: 800;"><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> đ</span>
                    </div>
                <% } else { %>
                    <div class="price-row">
                        <span class="price-label">Thuê ngày:</span>
                        <span class="price-value"><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> đ</span>
                    </div>
                    <div class="price-row">
                        <span class="price-label">Thuê giờ:</span>
                        <span class="price-value"><fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,##0"/> đ</span>
                    </div>
                <% } %>
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

            <% if (!isForSale) { %>
            <div class="stock-line">
                Có sẵn: ${clothing.availableFrom} → ${clothing.availableTo}
            </div>
            <% } %>

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
                <% if (!"Manager".equals(role) && !"Admin".equals(role) && !"Renter".equals(role)) { %>
                    <% if (isForSale) { %>
                        <button class="btn btn-book" onclick="handleBooking()" type="button">Mua ngay</button>
                        <button class="btn btn-book" onclick="handleAddToCart()" type="button" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); margin-left: 10px;">Thêm vào giỏ hàng 🛒</button>
                    <% } else { %>
                        <button class="btn btn-book" onclick="handleBooking()" type="button">Thuê ngay</button>
                        <button class="btn btn-book" onclick="handleAddToCart()" type="button" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); margin-left: 10px;">Thêm vào giỏ hàng 🛒</button>
                    <% } %>
                <% } %>
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
                <div class="kv-label"><%= isForSale ? "Chất liệu" : "Phong cách" %></div>
                <div><c:choose><c:when test="${not empty clothing.style}">${clothing.style}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label"><%= isForSale ? "Xuất xứ" : "Mục đích" %></div>
                <div><c:choose><c:when test="${not empty clothing.occasion}">${clothing.occasion}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label">Size</div>
                <div><c:choose><c:when test="${not empty clothing.size}">${clothing.size}</c:when><c:otherwise>-</c:otherwise></c:choose></div>
            </div>
            <div class="kv">
                <div class="kv-label"><%= isForSale ? "Giá bán" : "Giá ngày" %></div>
                <div><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> đ</div>
            </div>
            <div class="kv">
                <div class="kv-label">Cửa hàng</div>
                <div>
                    <c:choose>
                        <c:when test="${not empty shop}">
                            <a href="${pageContext.request.contextPath}/shop?id=${shop.accountID}" style="color: var(--accent); font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 4px;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle;"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                ${shop.fullName}
                            </a>
                        </c:when>
                        <c:otherwise>Không rõ</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Cửa hàng bán sản phẩm -->
    <c:if test="${not empty shop}">
        <div class="panel" style="margin-top: 24px; display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap; border-radius: var(--radius-lg); background: var(--surface); padding: 24px; box-shadow: var(--shadow-md);">
            <div style="display: flex; align-items: center; gap: 16px;">
                <div style="width: 60px; height: 60px; border-radius: 50%; background: #e2e8f0; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 22px; color: var(--accent); border: 2px solid var(--line); overflow: hidden; flex-shrink: 0;">
                    <c:choose>
                        <c:when test="${not empty shop.avatar}">
                            <img src="${pageContext.request.contextPath}/${shop.avatar}" alt="${shop.fullName}" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.onerror=null; this.parentNode.innerHTML='${fn:substring(shop.fullName, 0, 1)}';">
                        </c:when>
                        <c:otherwise>
                            ${fn:substring(shop.fullName, 0, 1)}
                        </c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h4 style="margin: 0 0 6px 0; font-size: 18px; font-weight: 800; color: var(--gray-900);">
                        <a href="${pageContext.request.contextPath}/shop?id=${shop.accountID}" style="text-decoration: none; color: inherit; transition: color 0.2s;">
                            ${shop.fullName}
                        </a>
                    </h4>
                    <div style="display: flex; align-items: center; gap: 12px; font-size: 13px; color: var(--muted); flex-wrap: wrap;">
                        <span style="display: inline-flex; align-items: center; gap: 4px; font-weight: 600;">
                            <span style="color: #f5a623; font-size: 15px;">★</span>
                            <c:choose>
                                <c:when test="${shopRating > 0}">
                                    <fmt:formatNumber value="${shopRating}" type="number" maxFractionDigits="1" minFractionDigits="1"/>/5
                                </c:when>
                                <c:otherwise>Chưa có đánh giá</c:otherwise>
                            </c:choose>
                        </span>
                        <span style="color: var(--line);">|</span>
                        <span style="display: inline-flex; align-items: center; gap: 4px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle;"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                            ${shop.address}
                        </span>
                    </div>
                </div>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/shop?id=${shop.accountID}" class="btn" style="background: linear-gradient(135deg, var(--accent) 0%, var(--accent-strong) 100%); color: white; text-decoration: none; border-radius: var(--radius-full); padding: 10px 20px; font-weight: 700; transition: all 0.2s; box-shadow: var(--shadow-sm); display: inline-flex; align-items: center; gap: 6px; font-size: 13px;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                    Xem Cửa Hàng
                </a>
            </div>
        </div>
    </c:if>

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

    const isLoggedIn = <%= isLoggedIn %>;

    function handleBooking() {
        if (!isLoggedIn) {
            alert("Bạn vui lòng đăng nhập hoặc đăng ký hệ thống để sử dụng dịch vụ nhé!");
            window.location.href = '${pageContext.request.contextPath}/login';
            return;
        }
        window.location.href = '${pageContext.request.contextPath}/rental?action=booking&clothingID=${clothing.clothingID}&hourlyPrice=${clothing.hourlyPrice != null ? clothing.hourlyPrice : 0}&dailyPrice=${clothing.dailyPrice != null ? clothing.dailyPrice : 0}';
    }

    function handleAddToCart() {
        if (!isLoggedIn) {
            alert("Bạn vui lòng đăng nhập hoặc đăng ký hệ thống để sử dụng dịch vụ nhé!");
            window.location.href = '${pageContext.request.contextPath}/login';
            return;
        }
        window.location.href = '${pageContext.request.contextPath}/rental?action=booking&clothingID=${clothing.clothingID}&hourlyPrice=${clothing.hourlyPrice != null ? clothing.hourlyPrice : 0}&dailyPrice=${clothing.dailyPrice != null ? clothing.dailyPrice : 0}&addToCart=true';
    }

    function handleBack() {
        if (document.referrer && document.referrer.includes(window.location.host) && !document.referrer.includes('/login') && !document.referrer.includes('/register')) {
            window.history.back();
        } else {
            window.location.href = '${pageContext.request.contextPath}/home';
        }
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
