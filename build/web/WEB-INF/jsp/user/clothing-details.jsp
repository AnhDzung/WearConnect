<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        :root {
            --ink: #15110f;
            --muted: #6f6a64;
            --paper: #f7f3ee;
            --card: #ffffff;
            --accent: #1f8e74;
            --accent-strong: #156c57;
            --berry: #c02b7f;
            --shadow: 0 16px 34px rgba(20, 16, 11, 0.12);
            --radius: 18px;
        }
        body {
            margin: 0;
            background: radial-gradient(circle at 10% 10%, #efe2d0, transparent 40%),
                        radial-gradient(circle at 90% 20%, #dff1ea, transparent 45%),
                        var(--paper);
            color: var(--ink);
        }
        .container { max-width: 1100px; margin: 28px auto 60px; padding: 0 20px; }
        .detail-wrapper {
            display: grid;
            grid-template-columns: minmax(0, 1.1fr) minmax(0, 0.9fr);
            gap: 28px;
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 20px;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }
        .detail-image {
            position: relative;
            display: grid;
            gap: 14px;
        }
        .main-image {
            width: 100%;
            aspect-ratio: 4 / 5;
            border-radius: 16px;
            object-fit: cover;
            object-position: center;
            display: block;
            box-shadow: 0 10px 24px rgba(0, 0, 0, 0.12);
        }
        .gallery { display: grid; gap: 12px; }
        .thumbs {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(64px, 1fr));
            gap: 8px;
        }
        .thumbs button {
            border: 2px solid transparent;
            padding: 0;
            background: none;
            cursor: pointer;
            border-radius: 12px;
            overflow: hidden;
            transition: border-color 0.2s ease, transform 0.2s ease;
        }
        .thumbs button:hover { transform: translateY(-2px); }
        .thumbs button.active { border-color: var(--accent); }
        .thumbs img { width: 100%; height: 70px; object-fit: cover; display: block; }
        .favorite-btn {
            position: absolute;
            top: 16px;
            left: 16px;
            background: rgba(255, 255, 255, 0.95);
            border: none;
            border-radius: 50%;
            width: 52px;
            height: 52px;
            font-size: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            box-shadow: 0 10px 18px rgba(0, 0, 0, 0.18);
        }
        .favorite-btn:hover { transform: scale(1.05); box-shadow: 0 14px 24px rgba(0, 0, 0, 0.22); }
        .favorite-btn.active { color: var(--berry); }
        .detail-info {
            display: grid;
            gap: 16px;
            align-content: start;
        }
        .detail-info h1 {
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            font-size: clamp(24px, 3vw, 34px);
        }
        .avg-rating {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fff3df;
            color: #b65d06;
            padding: 6px 12px;
            border-radius: 999px;
            font-weight: 600;
            font-size: 13px;
        }
        .avg-rating .star { color: #f59e0b; font-size: 16px; }
        .info-row {
            display: grid;
            grid-template-columns: 120px 1fr;
            gap: 12px;
            padding: 10px 12px;
            background: #faf8f4;
            border-radius: 12px;
        }
        .info-row strong {
            color: var(--muted);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .detail-info .info-row:last-of-type { align-items: start; }
        .btn {
            padding: 10px 18px;
            border: none;
            cursor: pointer;
            border-radius: 999px;
            font-weight: 600;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(0,0,0,0.12); }
        .btn-book { background: var(--accent); color: #fff; }
        .btn-book:hover { background: var(--accent-strong); }
        .btn-back { background: #ece6dd; color: var(--ink); }
        .ratings-block {
            margin-top: 28px;
            background: var(--card);
            padding: 22px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid rgba(0, 0, 0, 0.05);
        }
        .ratings-block h3 { margin: 0 0 12px; font-size: 20px; }
        .rating-item { border-top: 1px solid #eee2d6; padding: 14px 0; }
        .rating-item:first-of-type { border-top: none; }
        .rating-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
        }
        .rating-stars { color: #f59e0b; }
        .rating-stars .star { color: #e4d7c8; }
        .rating-stars .filled { color: #f59e0b; }
        .rating-comment { margin: 6px 0 0; color: #444; white-space: pre-wrap; }
        .muted { color: var(--muted); }
        @media (max-width: 900px) {
            .detail-wrapper { grid-template-columns: 1fr; }
            .info-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<%
    // Get user role from session
    Object accountObj = session.getAttribute("account");
    Object userRole = session.getAttribute("userRole");
    String role = userRole != null ? userRole.toString() : "";
    boolean isUser = "User".equals(role);
    boolean isLoggedIn = accountObj != null;
%>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="detail-wrapper">
        <div class="detail-image">
            <% if (isLoggedIn) { %>
                <button class="favorite-btn" id="favoriteBtn" onclick="toggleFavorite(${clothing.clothingID})" title="Thêm vào yêu thích">★</button>
            <% } %>

            <c:choose>
                <c:when test="${not empty images}">
                    <div class="gallery">
                        <img id="mainImage" class="main-image" src="${pageContext.request.contextPath}/image?imageId=${images[0].imageID}" alt="${clothing.clothingName}">
                        <div class="thumbs" id="thumbs">
                            <c:forEach items="${images}" var="img" varStatus="loop">
                                <button class="${loop.index == 0 ? 'active' : ''}" data-index="${loop.index}" onclick="showImage(${loop.index}); return false;">
                                    <img src="${pageContext.request.contextPath}/image?imageId=${img.imageID}" alt="thumb ${loop.index}">
                                </button>
                            </c:forEach>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <img class="main-image" src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
                </c:otherwise>
            </c:choose>
        </div>
        
        <div class="detail-info">
            <h1>
                ${clothing.clothingName}
                <span class="avg-rating">
                    <span class="star">★</span>
                    <c:choose>
                        <c:when test="${avgRating > 0}">
                            <fmt:formatNumber value="${avgRating}" type="number" maxFractionDigits="1" minFractionDigits="1"/> / 5
                        </c:when>
                        <c:otherwise>Chưa có đánh giá</c:otherwise>
                    </c:choose>
                </span>
            </h1>
            
            <div class="info-row">
                <strong>Danh mục:</strong> ${clothing.category}
            </div>
            <c:if test="${clothing.category ne 'Cosplay'}">
                <div class="info-row">
                    <strong>Phong cách:</strong> ${clothing.style}
                </div>
            </c:if>
            <div class="info-row">
                <strong>Mục đích:</strong> ${clothing.occasion}
            </div>
            <div class="info-row">
                <strong>Size:</strong> ${clothing.size}
            </div>
            <c:if test="${clothing.category eq 'Cosplay' && cosplayDetail != null}">
                <div class="info-row">
                    <strong>Phụ kiện đi kèm:</strong> ${cosplayDetail.accessoryList}
                </div>
            </c:if>
            <div class="info-row">
                <strong>Giá thuê:</strong> <fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,##0"/> VNĐ/giờ • <fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/> VNĐ/ngày
            </div>
            <div class="info-row">
                <strong>Có sẵn:</strong> ${clothing.availableFrom} đến ${clothing.availableTo}
            </div>
            <div class="info-row">
                <strong>Mô tả:</strong> ${clothing.description}
            </div>
            
            <div>
                <% if (!"Manager".equals(role) && !"Admin".equals(role)) { %>
                    <button class="btn btn-book" onclick="handleBooking()">Đặt thuê</button>
                <% } %>
                <button class="btn btn-back" onclick="history.back()">Quay lại</button>
            </div>
        </div>
    </div>
    <div class="ratings-block">
        <h3>Đánh giá</h3>
        <c:choose>
            <c:when test="${empty ratings}">
                <div class="muted">Chưa có đánh giá nào cho sản phẩm này.</div>
            </c:when>
            <c:otherwise>
                <%-- Admin (and Manager) can see both renter->product and owner->renter ratings separately --%>
                <c:choose>
                    <c:when test="${sessionScope.userRole == 'Admin' || sessionScope.userRole == 'Manager'}">
                        <h4>Đánh giá của người thuê về sản phẩm</h4>
                        <c:forEach var="r" items="${ratings}">
                            <c:if test="${r.ratingFromUserID == r.rentalRenterUserID}">
                                <div class="rating-item">
                                    <div class="rating-meta">
                                        <span class="rating-stars">
                                            <c:forEach var="i" begin="1" end="5">
                                                <span class="star${i <= r.rating ? ' filled' : ''}">★</span>
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

                        <h4 style="margin-top:18px">Đánh giá của người cho thuê về khách thuê</h4>
                        <c:forEach var="r" items="${ratings}">
                            <c:if test="${r.ratingFromUserID == r.rentalManagerUserID}">
                                <div class="rating-item">
                                    <div class="rating-meta">
                                        <span class="rating-stars">
                                            <c:forEach var="i" begin="1" end="5">
                                                <span class="star${i <= r.rating ? ' filled' : ''}">★</span>
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
                        <!-- Regular users see only renter->product ratings -->
                        <c:forEach var="r" items="${ratings}">
                            <c:if test="${r.ratingFromUserID == r.rentalRenterUserID}">
                                <div class="rating-item">
                                    <div class="rating-meta">
                                        <span class="rating-stars">
                                            <c:forEach var="i" begin="1" end="5">
                                                <span class="star${i <= r.rating ? ' filled' : ''}">★</span>
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
    function toggleFavorite(clothingID) {
        var btn = document.getElementById('favoriteBtn');
        btn.classList.toggle('active');
        
        // Lưu vào database qua server
        var action = btn.classList.contains('active') ? 'add' : 'remove';
        
        fetch('${pageContext.request.contextPath}/user?action=' + action + 'Favorite&clothingID=' + clothingID, {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(action === 'add' ? 'Đã thêm vào yêu thích!' : 'Đã xóa khỏi yêu thích!');
                // Cập nhật localStorage để đồng bộ
                var favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
                if (action === 'add' && favorites.indexOf(clothingID) === -1) {
                    favorites.push(clothingID);
                } else if (action === 'remove') {
                    var index = favorites.indexOf(clothingID);
                    if (index !== -1) {
                        favorites.splice(index, 1);
                    }
                }
                localStorage.setItem('favorites', JSON.stringify(favorites));
            } else {
                alert(action === 'add' ? 'Không thể thêm vào yêu thích!' : 'Không thể xóa khỏi yêu thích!');
                btn.classList.toggle('active');
            }
        })
        .catch(err => {
            console.error('Lỗi:', err);
            alert('Có lỗi xảy ra! Vui lòng thử lại.');
            btn.classList.toggle('active');
        });
    }
    
    // Kiểm tra nếu sản phẩm đã được đánh dấu yêu thích
    window.addEventListener('load', function() {
        var btn = document.getElementById('favoriteBtn');
        
        // Only check favorites if user is logged in
        if (btn) {
            var clothingID = ${clothing.clothingID};
            // Kiểm tra từ server
            fetch('${pageContext.request.contextPath}/user?action=checkFavorite&clothingID=' + clothingID)
                .then(response => response.json())
                .then(data => {
                    if (data.isFavorited) {
                        btn.classList.add('active');
                    }
                })
                .catch(err => {
                    // Nếu có lỗi, dùng localStorage
                    var favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
                    if (favorites.indexOf(clothingID) !== -1) {
                        btn.classList.add('active');
                    }
                });
        }
    });

    function handleBooking() {
        // Redirect to booking page (will redirect to login if not logged in)
        window.location.href = '${pageContext.request.contextPath}/rental?action=booking&clothingID=${clothing.clothingID}&hourlyPrice=${clothing.hourlyPrice}&dailyPrice=${clothing.dailyPrice}';
    }

    // Gallery logic
    const images = [
        <c:forEach items="${images}" var="img" varStatus="loop">
            '${pageContext.request.contextPath}/image?imageId=${img.imageID}'${!loop.last ? ',' : ''}
        </c:forEach>
    ];

    function showImage(idx) {
        if (!images.length) return false;
        const main = document.getElementById('mainImage');
        const buttons = document.querySelectorAll('#thumbs button');
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
