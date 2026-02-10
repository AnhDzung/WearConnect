<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 20px auto; padding: 20px; }
        .detail-wrapper { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
        .detail-image { position: relative; }
        .detail-image img { width: 100%; border-radius: 5px; }
        .gallery { display: flex; flex-direction: column; gap: 12px; }
        .thumbs { display: grid; grid-template-columns: repeat(auto-fill, minmax(70px, 1fr)); gap: 8px; }
        .thumbs button { border: 2px solid transparent; padding: 0; background: none; cursor: pointer; border-radius: 4px; overflow: hidden; }
        .thumbs button.active { border-color: #007bff; }
        .thumbs img { width: 100%; height: 70px; object-fit: cover; display: block; }
        .favorite-btn {
            position: absolute;
            top: 15px;
            left: 15px;
            background-color: rgba(255, 255, 255, 0.95);
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            font-size: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        .favorite-btn:hover {
            background-color: white;
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }
        .favorite-btn.active {
            color: #FF1493;
        }
        .detail-info h1 { margin-top: 0; display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .info-row { margin: 15px 0; }
        .info-row strong { display: inline-block; width: 120px; }
        .avg-rating { display: inline-flex; align-items: center; gap: 6px; background: #fff6e6; color: #d97706; padding: 6px 10px; border-radius: 999px; font-weight: 600; font-size: 14px; }
        .avg-rating .star { color: #f59e0b; font-size: 16px; }
        .rating-section { margin: 24px 0; }
        .btn { padding: 10px 20px; background-color: #007bff; color: white; border: none; cursor: pointer; margin-right: 10px; }
        .btn-book { background-color: #28a745; }
        .btn-back { background-color: #6c757d; }
        .ratings-block { margin-top: 30px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        .ratings-block h3 { margin-top: 0; margin-bottom: 15px; }
        .rating-item { border-top: 1px solid #eee; padding: 12px 0; }
        .rating-item:first-of-type { border-top: none; }
        .rating-meta { display: flex; align-items: center; gap: 8px; font-weight: 600; }
        .rating-stars { color: #f59e0b; }
        .rating-comment { margin: 6px 0 0; color: #444; white-space: pre-wrap; }
        .muted { color: #888; }
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
                        <img id="mainImage" src="${pageContext.request.contextPath}/image?imageId=${images[0].imageID}" alt="${clothing.clothingName}">
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
                    <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
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
            <div class="info-row">
                <strong>Phong cách:</strong> ${clothing.style}
            </div>
            <div class="info-row">
                <strong>Size:</strong> ${clothing.size}
            </div>
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
                <c:choose>
                    <!-- Admin (and Manager) can see both renter->product and owner->renter ratings separately -->
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
