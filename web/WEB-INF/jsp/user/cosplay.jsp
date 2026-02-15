<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="DAO.RatingDAO" %>
<%@ page import="DAO.CosplayDetailDAO" %>
<%@ page import="Model.CosplayDetail" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cosplay & Fes - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
    <style>
        :root {
            --ink: #1a1a1a;
            --muted: #6b7280;
            --paper: #ffffff;
            --accent: #ff6b6b;
            --accent-hover: #ff5252;
            --border: #e5e7eb;
            --bg-light: #f9fafb;
            --font-family: cursive;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: var(--font-family); }
        body { background: var(--bg-light); color: var(--ink); }

        /* Hero Section */
        .hero {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 60px 20px;
            text-align: center;
        }
        .hero h1 {
            font-size: 48px;
            font-weight: bold;
            margin-bottom: 15px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .hero p {
            font-size: 20px;
            opacity: 0.95;
            max-width: 600px;
            margin: 0 auto;
        }

        /* Search Panel */
        .search-panel {
            background: white;
            padding: 25px;
            margin: -30px auto 30px;
            max-width: 900px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
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
            font-weight: 600;
            color: var(--muted);
            font-size: 14px;
        }
        .form-group select, .form-group input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 15px;
            transition: all 0.2s;
        }
        .form-group select:focus, .form-group input[type="text"]:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.1);
        }
        .btn-search {
            padding: 12px 30px;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-search:hover { background: var(--accent-hover); transform: translateY(-2px); }

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
            border: 1px solid var(--border);
            border-radius: 6px;
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
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 16px;
        }

        /* Cosplay Product Card */
        .cosplay-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: all 0.3s;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        .cosplay-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        }
        .cosplay-card-image {
            width: 100%;
            aspect-ratio: 4 / 5;
            object-fit: cover;
            background-color: #f0f0f0;
        }
        .cosplay-card-body {
            padding: 14px;
        }
        .character-name {
            font-size: 16px;
            font-weight: bold;
            color: var(--ink);
            margin-bottom: 5px;
        }
        .series-name {
            font-size: 14px;
            color: var(--muted);
            margin-bottom: 12px;
        }
        .cosplay-type-badge {
            display: inline-block;
            padding: 4px 10px;
            background: #e0e7ff;
            color: #4338ca;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        .price-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            padding-top: 10px;
            border-top: 1px solid var(--border);
        }
        .hourly-price {
            font-size: 16px;
            font-weight: bold;
            color: var(--accent);
        }
        .price-label {
            font-size: 12px;
            color: var(--muted);
        }
        .deposit-info {
            font-size: 13px;
            color: var(--muted);
            margin-bottom:8px;
        }
        .deposit-refund {
            color: #10b981;
            font-weight: 600;
        }
        .rating-row {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }
        .rating-star {
            color: #fbbf24;
            font-size: 16px;
        }
        .rating-value {
            font-weight: 600;
            color: var(--ink);
        }
        .rental-count {
            color: var(--muted);
        }

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
            background: var(--paper);
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: var(--ink);
            text-decoration: none;
            font-weight: 600;
            min-width: 36px;
            text-align: center;
        }
        .page-link:hover { background: #f0f0f0; }
        .page-link.active {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }

        @media (max-width: 768px) {
            .hero h1 { font-size: 32px; }
            .search-form {
                grid-template-columns: 1fr;
            }
            .product-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 1200px) {
            .product-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); }
        }
        @media (max-width: 980px) {
            .product-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
        }
        @media (max-width: 520px) {
            .product-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<!-- Hero Section -->
<div class="hero">
    <h1> Cosplay & Fes</h1>
    <p>Cho thuê trang phục cosplay chất lượng cao từ Anime, Game, và Movie. Biến hóa thành nhân vật yêu thích của bạn!</p>
</div>

<!-- Search Panel -->
<div class="search-panel">
    <form method="GET" action="${pageContext.request.contextPath}/cosplay" class="search-form">
        <div class="form-group">
            <label for="searchType">Tìm kiếm theo:</label>
            <select id="searchType" name="searchType" onchange="toggleSearchInput()">
                <option value="">-- Tất cả --</option>
                <option value="character" ${searchType == 'character' ? 'selected' : ''}>Nhân vật</option>
                <option value="series" ${searchType == 'series' ? 'selected' : ''}>Series</option>
                <option value="type" ${searchType == 'type' ? 'selected' : ''}>Loại</option>
            </select>
        </div>

        <div class="form-group" id="searchValueGroup" style="display: ${searchType != null && !searchType.isEmpty() ? 'block' : 'none'};">
            <label for="searchValue">Giá trị tìm kiếm:</label>
            <c:choose>
                <c:when test="${searchType == 'type'}">
                    <select id="searchValue" name="searchValue">
                        <option value="">-- Chọn loại --</option>
                        <option value="Anime" ${searchValue == 'Anime' ? 'selected' : ''}>Anime</option>
                        <option value="Game" ${searchValue == 'Game' ? 'selected' : ''}>Game</option>
                        <option value="Movie" ${searchValue == 'Movie' ? 'selected' : ''}>Movie</option>
                    </select>
                </c:when>
                <c:otherwise>
                    <input type="text" id="searchValue" name="searchValue" value="${searchValue}" 
                           placeholder="Nhập tên nhân vật hoặc series...">
                </c:otherwise>
            </c:choose>
        </div>

        <button type="submit" class="btn-search">🔍 Tìm kiếm</button>
    </form>
</div>

<!-- Sort Bar -->
<div class="sort-bar">
    <p>Tìm thấy ${totalItems != null ? totalItems : 0} trang phục cosplay</p>
    <form method="GET" action="${pageContext.request.contextPath}/cosplay" style="display: inline;">
        <input type="hidden" name="searchType" value="${searchType}">
        <input type="hidden" name="searchValue" value="${searchValue}">
        <input type="hidden" name="page" value="1">
        <select name="sortBy" onchange="this.form.submit()">
            <option value="">Sắp xếp theo</option>
            <option value="rating" ${sortBy == 'rating' ? 'selected' : ''}>Đánh giá cao nhất</option>
            <option value="priceAsc" ${sortBy == 'priceAsc' ? 'selected' : ''}>Giá thấp đến cao</option>
            <option value="priceDesc" ${sortBy == 'priceDesc' ? 'selected' : ''}>Giá cao đến thấp</option>
        </select>
    </form>
</div>

<!-- Product Grid -->
<div class="container">
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
                                    <div class="hourly-price">
                                        <fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,###" />k / giờ
                                    </div>
                                    <div class="price-label">Thuê theo giờ</div>
                                </div>
                            </div>
                            
                            <div class="deposit-info">
                                Giá trị: <fmt:formatNumber value="${clothing.itemValue}" pattern="#,###" />k 
                                <span class="deposit-refund">(sản phẩm)</span>
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
                        <c:url var="prevLink" value="/cosplay">
                            <c:param name="searchType" value="${searchType}" />
                            <c:param name="searchValue" value="${searchValue}" />
                            <c:param name="sortBy" value="${sortBy}" />
                            <c:param name="page" value="${currentPage - 1}" />
                        </c:url>
                        <a class="page-link" href="${prevLink}">Truoc</a>
                    </c:if>

                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <c:url var="pageLink" value="/cosplay">
                            <c:param name="searchType" value="${searchType}" />
                            <c:param name="searchValue" value="${searchValue}" />
                            <c:param name="sortBy" value="${sortBy}" />
                            <c:param name="page" value="${i}" />
                        </c:url>
                        <a class="page-link ${i == currentPage ? 'active' : ''}" href="${pageLink}">${i}</a>
                    </c:forEach>

                    <c:if test="${currentPage < totalPages}">
                        <c:url var="nextLink" value="/cosplay">
                            <c:param name="searchType" value="${searchType}" />
                            <c:param name="searchValue" value="${searchValue}" />
                            <c:param name="sortBy" value="${sortBy}" />
                            <c:param name="page" value="${currentPage + 1}" />
                        </c:url>
                        <a class="page-link" href="${nextLink}">Sau</a>
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
</div>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />

<script>
    function toggleSearchInput() {
        const searchType = document.getElementById('searchType').value;
        const searchValueGroup = document.getElementById('searchValueGroup');
        const searchValue = document.getElementById('searchValue');
        
        if (searchType === '') {
            searchValueGroup.style.display = 'none';
        } else {
            searchValueGroup.style.display = 'block';
            
            // Change input type based on search type
            if (searchType === 'type') {
                // Replace with select dropdown
                const newSelect = document.createElement('select');
                newSelect.id = 'searchValue';
                newSelect.name = 'searchValue';
                newSelect.innerHTML = `
                    <option value="">-- Chọn loại --</option>
                    <option value="Anime">Anime</option>
                    <option value="Game">Game</option>
                    <option value="Movie">Movie</option>
                `;
                searchValue.parentNode.replaceChild(newSelect, searchValue);
            } else {
                // Ensure it's a text input
                if (searchValue.tagName !== 'INPUT') {
                    const newInput = document.createElement('input');
                    newInput.type = 'text';
                    newInput.id = 'searchValue';
                    newInput.name = 'searchValue';
                    newInput.placeholder = 'Nhập tên nhân vật hoặc series...';
                    searchValue.parentNode.replaceChild(newInput, searchValue);
                }
            }
        }
    }
</script>
</body>
</html>
