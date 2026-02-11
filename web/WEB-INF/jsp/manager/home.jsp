<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sản phẩm của tôi - WearConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: cursive;
            background-color: #f5f5f5;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .page-header {
            background: white;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .page-header h1 {
            font-size: 28px;
            color: #333;
        }
        
        .btn-upload {
            background-color: #667eea;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        
        .btn-upload:hover {
            background-color: #5568d3;
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .product-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .product-image {
            width: 100%;
            height: 250px;
            object-fit: cover;
            display: block;
        }
        
        .product-info {
            padding: 20px;
        }
        
        .product-name {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .product-category {
            display: inline-block;
            background-color: #f0f0f0;
            color: #666;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            margin-bottom: 10px;
        }
        
        .product-details {
            font-size: 13px;
            color: #666;
            margin-bottom: 10px;
            line-height: 1.6;
        }
        
        .product-price {
            font-size: 20px;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 15px;
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
            text-decoration: none;
            text-align: center;
        }
        
        .btn-edit {
            background-color: #667eea;
            color: white;
        }
        
        .btn-edit:hover {
            background-color: #5568d3;
        }
        
        .btn-delete {
            background-color: #f56565;
            color: white;
        }
        
        .btn-delete:hover {
            background-color: #e53e3e;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .empty-state h2 {
            color: #666;
            margin-bottom: 15px;
        }
        
        .empty-state p {
            color: #999;
            margin-bottom: 25px;
        }
        
        .empty-state .btn-upload {
            display: inline-block;
        }
        
        .success-message {
            background-color: #c6f6d5;
            color: #22543d;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: none;
        }
        
        .success-message.show {
            display: block;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="page-header">
        <h1>Sản phẩm của tôi</h1>
        <a href="${pageContext.request.contextPath}/clothing?action=upload" class="btn-upload">+ Đăng tải sản phẩm mới</a>
    </div>
    
    <c:if test="${param.success}">
        <div class="success-message show">
            Thao tác thành công!
        </div>
    </c:if>
    
    <c:choose>
        <c:when test="${empty myClothing}">
            <div class="empty-state">
                <h2>Chưa có sản phẩm nào</h2>
                <p>Hãy đăng tải sản phẩm đầu tiên của bạn để bắt đầu kiếm tiền</p>
                <a href="${pageContext.request.contextPath}/clothing?action=upload" class="btn-upload">+ Đăng tải sản phẩm</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="products-grid">
                <c:forEach var="clothing" items="${myClothing}">
                    <div class="product-card">
                        <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}" class="product-image">
                        <div class="product-info">
                            <h3 class="product-name">${clothing.clothingName}</h3>
                            <span class="product-category">${clothing.category}</span>
                            <div class="product-details">
                                <div><strong>Phong cách:</strong> ${clothing.style}</div>
                                <div><strong>Size:</strong> ${clothing.size}</div>
                                <div><strong>Trạng thái:</strong> 
                                    <c:choose>
                                        <c:when test="${clothing.isActive == 1}">
                                            <span style="color: #48bb78;">Hoạt động</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #f56565;">✗ Đã xóa</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="product-price">${clothing.hourlyPrice}đ/giờ</div>
                            <div class="product-actions">
                                <a href="${pageContext.request.contextPath}/clothing?action=edit&id=${clothing.clothingID}" class="btn btn-edit">Chỉnh sửa</a>
                                <form method="POST" action="${pageContext.request.contextPath}/clothing" style="flex: 1;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="clothingID" value="${clothing.clothingID}">
                                    <button type="submit" class="btn btn-delete" onclick="return confirm('Bạn chắc chắn muốn xóa sản phẩm này?')">Xóa</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
    // Hide success message after 3 seconds
    if (document.querySelector('.success-message.show')) {
        setTimeout(() => {
            document.querySelector('.success-message').classList.remove('show');
        }, 3000);
    }
</script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
