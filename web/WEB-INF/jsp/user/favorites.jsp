<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Account" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Sản Phẩm Yêu Thích - WearConnect</title>
    <style>
        body {
            background:
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.12), transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(6, 182, 212, 0.08), transparent 45%),
                linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%) !important;
        }

        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
            margin-top: 30px;
            margin-bottom: 50px;
        }

        @media (max-width: 576px) {
            .products-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }

        .product-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            transition: transform var(--transition-base), box-shadow var(--transition-base);
            display: flex;
            flex-direction: column;
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }

        .product-image-wrapper {
            width: 100%;
            height: 340px;
            position: relative;
            overflow: hidden;
            background-color: var(--gray-100);
            border-bottom: 1px solid rgba(226, 232, 240, 0.5);
        }

        .product-image-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform var(--transition-slow);
        }

        .product-card:hover .product-image-wrapper img {
            transform: scale(1.05);
        }

        .product-info {
            padding: var(--spacing-xl);
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            gap: 12px;
        }

        .product-info h3 {
            font-size: 16px;
            font-weight: 700;
            color: var(--gray-900);
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .product-price {
            font-size: 14px;
            color: var(--primary-color);
            font-weight: 700;
            margin: 0;
        }

        .product-actions {
            display: flex;
            gap: 10px;
            margin-top: auto;
        }

        .empty-message {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            padding: 60px var(--spacing-xl);
            text-align: center;
            box-shadow: var(--shadow-lg);
            margin-top: 30px;
        }

        .wc-btn-primary {
            color: var(--white) !important;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />

    <%
        Account user = (Account) session.getAttribute("account");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
    %>

    <div class="wc-container wc-mt-4 wc-mb-4" style="max-width: 1200px; margin: 40px auto 50px; padding: 0 15px;">
        <div style="margin-bottom: 30px;">
            <h1 style="font-family: Poppins, sans-serif; font-weight: 800; font-size: 28px; color: var(--gray-900); margin: 0;">Sản Phẩm Yêu Thích</h1>
            <p style="color: var(--gray-500); margin-top: 5px; font-size: 14px;">Danh sách trang phục bạn đã đánh dấu yêu thích</p>
        </div>
        
        <div class="empty-message">
            <div style="font-size: 64px; margin-bottom: 20px;">💔</div>
            <h3 style="font-weight: 800; color: var(--gray-700); font-size: 20px; margin-bottom: 8px;">Chưa có sản phẩm yêu thích</h3>
            <p style="color: var(--gray-500); margin-bottom: 25px;">Hãy khám phá các trang phục lộng lẫy và nhấn vào ngôi sao trên sản phẩm để thêm vào đây nhé!</p>
            <a href="${pageContext.request.contextPath}/home" class="wc-btn wc-btn-primary" style="width: auto; display: inline-block; padding: 12px 30px; text-decoration: none;">Khám Phá Sản Phẩm</a>
        </div>
        
        <div id="productsContainer" style="display: none;">
            <div class="products-grid" id="favoritesList"></div>
        </div>
    </div>
    
    <script>
        // Lấy danh sách yêu thích từ server
        window.addEventListener('load', function() {
            fetchFavoritesFromServer();
        });
        
        function fetchFavoritesFromServer() {
            var emptyMsg = document.querySelector('.empty-message');
            var productsContainer = document.getElementById('productsContainer');
            var favoritesList = document.getElementById('favoritesList');
            
            // Lấy danh sách yêu thích từ server
            fetch('${pageContext.request.contextPath}/user?action=getFavoritesJSON', {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (!data.favorites || data.favorites.length === 0) {
                    emptyMsg.style.display = 'block';
                    productsContainer.style.display = 'none';
                    return;
                }
                
                emptyMsg.style.display = 'none';
                productsContainer.style.display = 'block';
                
                // Tạo card cho từng sản phẩm yêu thích
                data.favorites.forEach(function(clothingID) {
                    fetchClothingDetails(clothingID);
                });
            })
            .catch(err => {
                console.error('Lỗi lấy danh sách yêu thích:', err);
                // Fallback: Hiển thị từ localStorage
                loadFromLocalStorage();
            });
        }
        
        function loadFromLocalStorage() {
            var favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
            var emptyMsg = document.querySelector('.empty-message');
            var productsContainer = document.getElementById('productsContainer');
            
            if (favorites.length === 0) {
                emptyMsg.style.display = 'block';
                productsContainer.style.display = 'none';
                return;
            }
            
            emptyMsg.style.display = 'none';
            productsContainer.style.display = 'block';
            
            favorites.forEach(function(clothingID) {
                fetchClothingDetails(clothingID);
            });
        }
        
        function fetchClothingDetails(clothingID) {
            // Fetch product details from API endpoint (JSON)
            console.log('Fetching details for clothingID:', clothingID);
            
            // Try API endpoint first (JSON)
            fetch('${pageContext.request.contextPath}/clothing?id=' + clothingID, {
                headers: {'Accept': 'application/json'}
            })
                .then(response => {
                    if (response.status === 404) {
                        console.warn('Product clothingID ' + clothingID + ' not found (404)');
                        removeFavoriteIfNotExists(clothingID);
                        return null;
                    }
                    if (response.ok && response.headers.get('content-type')?.includes('application/json')) {
                        return response.json();
                    }
                    throw new Error('API not available, falling back to HTML parse');
                })
                .then(data => {
                    if (!data) return;
                    
                    var name = data.clothingName || 'Sản phẩm #' + clothingID;
                    var price = data.hourlyPrice ? data.hourlyPrice + ' VNĐ/giờ • ' + data.dailyPrice + ' VNĐ/ngày' : '---';
                    
                    console.log('API Success - clothingID:', clothingID, 'name:', name);
                    createProductCard(clothingID, name, price);
                })
                .catch(err => {
                    console.log('Falling back to HTML parse for clothingID:', clothingID);
                    // Fallback: Parse HTML from clothing-details page
                    fetch('${pageContext.request.contextPath}/clothing?action=view&id=' + clothingID)
                        .then(response => {
                            if (response.status === 404) {
                                console.warn('Product clothingID ' + clothingID + ' not found (404)');
                                removeFavoriteIfNotExists(clothingID);
                                return null;
                            }
                            if (!response.ok) throw new Error('HTTP ' + response.status);
                            return response.text();
                        })
                        .then(data => {
                            if (!data) return;
                            
                            var parser = new DOMParser();
                            var doc = parser.parseFromString(data, 'text/html');
                            var productName = doc.querySelector('h1');
                            var productPrice = doc.querySelectorAll('.info-row');
                            
                            if (!productName || !productName.textContent.trim()) {
                                console.warn('No product name in HTML for clothingID:', clothingID);
                                createProductCard(clothingID, 'Sản phẩm #' + clothingID, '---');
                                return;
                            }
                            
                            var name = productName.textContent.trim();
                            var price = '';
                            
                            for (var i = 0; i < productPrice.length; i++) {
                                if (productPrice[i].textContent.includes('Giá')) {
                                    price = productPrice[i].textContent.replace(/.*Giá.*?:/, '').trim();
                                    break;
                                }
                            }
                            
                            console.log('HTML Parse Success - clothingID:', clothingID, 'name:', name);
                            createProductCard(clothingID, name, price);
                        })
                        .catch(err => {
                            console.error('Fallback error for clothingID ' + clothingID + ':', err);
                            createProductCard(clothingID, 'Sản phẩm #' + clothingID, '---');
                        });
                });
        }

        function removeFavoriteIfNotExists(clothingID) {
            // Silently remove product from favorites if it doesn't exist
            fetch('${pageContext.request.contextPath}/user?action=removeFavorite&clothingID=' + clothingID, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    var card = document.getElementById('card-' + clothingID);
                    if (card) {
                        card.remove();
                        console.log('Removed deleted product clothingID:', clothingID);
                    }
                }
            })
            .catch(err => console.error('Error removing favorite:', err));
        }
        
        function createProductCard(clothingID, name, price) {
            var favoritesList = document.getElementById('favoritesList');
            var productCard = document.createElement('div');
            productCard.className = 'product-card';
            productCard.id = 'card-' + clothingID;
            productCard.innerHTML = `
                <div class="product-image-wrapper">
                    <img src="${pageContext.request.contextPath}/image?id=` + clothingID + `" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22100%22 height=%22100%22%3E%3Crect fill=%22%23ddd%22 width=%22100%22 height=%22100%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22cursive%22 font-size=%2214%22 fill=%22%23999%22%3E[IMG]%3C/text%3E%3C/svg%3E'">
                </div>
                <div class="product-info">
                    <h3>` + name + `</h3>
                    <p class="product-price">` + price + `</p>
                    <div class="product-actions">
                        <button class="wc-btn wc-btn-primary wc-btn-sm" style="flex: 1; font-weight: 700;" onclick="window.location.href='${pageContext.request.contextPath}/clothing?action=view&id=` + clothingID + `'">Xem Chi Tiết</button>
                        <button class="wc-btn wc-btn-danger wc-btn-sm" onclick="removeFavorite(` + clothingID + `, this)">Xóa</button>
                    </div>
                </div>
            `;
            favoritesList.appendChild(productCard);
        }
        
        function removeFavorite(clothingID, btn) {
            // Xóa từ server
            fetch('${pageContext.request.contextPath}/user?action=removeFavorite&clothingID=' + clothingID, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    var card = document.getElementById('card-' + clothingID);
                    if (card) {
                        card.remove();
                    }
                    
                    // Nếu không còn sản phẩm, hiển thị thông báo trống
                    var remainingCards = document.querySelectorAll('.product-card').length;
                    if (remainingCards === 0) {
                        document.querySelector('.empty-message').style.display = 'block';
                        document.getElementById('productsContainer').style.display = 'none';
                    }
                    
                    alert('Đã xóa khỏi yêu thích!');
                } else {
                    alert('Không thể xóa! Vui lòng thử lại.');
                }
            })
            .catch(err => {
                console.error('Lỗi:', err);
                alert('Có lỗi xảy ra! Vui lòng thử lại.');
            });
        }
    </script>
    <jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
