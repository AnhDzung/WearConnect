<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Account" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sản Phẩm Yêu Thích - WearConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .page-header {
            background: linear-gradient(135deg, #cc3399 0%, #cc0099 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .page-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .product-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .product-image {
            width: 100%;
            height: 250px;
            background-color: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
        }
        
        .product-info {
            padding: 15px;
        }
        
        .product-info h3 {
            font-size: 16px;
            color: #333;
            margin-bottom: 8px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .product-info p {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .product-price {
            color: #cc3399;
            font-weight: 600;
            font-size: 16px;
            margin-bottom: 10px;
        }
        
        .product-actions {
            display: flex;
            gap: 8px;
        }
        
        .btn {
            flex: 1;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        
        .btn-view {
            background-color: #cc3399;
            color: white;
        }
        
        .btn-view:hover {
            background-color: #b8278a;
        }
        
        .btn-remove {
            background-color: #ff6b9d;
            color: white;
        }
        
        .btn-remove:hover {
            background-color: #ff5288;
        }
        
        .empty-message {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 10px;
            color: #999;
        }
        
        .empty-message p {
            font-size: 18px;
            margin-bottom: 20px;
        }
        
        .empty-message a {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 30px;
            background-color: #cc3399;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        
        .empty-message a:hover {
            background-color: #b8278a;
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
    
    <div class="container">
        <div class="page-header">
            <h1>Sản Phẩm Yêu Thích</h1>
            <p>Các bộ đồ bạn đã đánh dấu yêu thích</p>
        </div>
        
        <div class="empty-message">
            <p>💔 Chưa có sản phẩm yêu thích</p>
            <p style="font-size: 14px; color: #999;">Hãy nhấn vào ngôi sao trên sản phẩm để thêm vào danh sách yêu thích!</p>
            <a href="${pageContext.request.contextPath}/search">Khám Phá Sản Phẩm</a>
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
                <div class="product-image">
                    <img src="${pageContext.request.contextPath}/image?id=` + clothingID + `" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22100%22 height=%22100%22%3E%3Crect fill=%22%23ddd%22 width=%22100%22 height=%22100%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22Arial%22 font-size=%2214%22 fill=%22%23999%22%3E[IMG]%3C/text%3E%3C/svg%3E'">
                </div>
                <div class="product-info">
                    <h3>` + name.substring(0, 30) + `</h3>
                    <p class="product-price">` + price + `</p>
                    <div class="product-actions">
                        <button class="btn btn-view" onclick="window.location.href='${pageContext.request.contextPath}/clothing?action=view&id=` + clothingID + `'">Xem Chi Tiết</button>
                        <button class="btn btn-remove" onclick="removeFavorite(` + clothingID + `, this)">Xóa</button>
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
