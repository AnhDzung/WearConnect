<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xét Duyệt Sản Phẩm Cosplay - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            background: white;
            padding: 30px;
            border-radius: 20px;
            margin-bottom: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        
        header h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .pending-count {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 8px 20px;
            border-radius: 30px;
            font-size: 18px;
            font-weight: 600;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .empty-state {
            background: white;
            padding: 60px;
            border-radius: 20px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        
        .empty-state i {
            font-size: 80px;
            color: #67eea;
            margin-bottom: 20px;
        }
        
        .empty-state h2 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #666;
        }
        
        .cosplay-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 25px;
        }
        
        .cosplay-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .cosplay-card:hover {
            transform: translateY(-5px);
        }
        
        .card-image {
            width: 100%;
            height: 300px;
            object-fit: cover;
            border-bottom: 3px solid #667eea;
        }
        
        .card-body {
            padding: 25px;
        }
        
        .card-title {
            font-size: 24px;
            color: #333;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .meta-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
            color: #666;
            font-size: 14px;
        }
        
        .meta-row i {
            color: #667eea;
            width: 20px;
        }
        
        .badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .badge-anime {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
        }
        
        .badge-game {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
        }
        
        .badge-movie {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            color: white;
        }
        
        .price-section {
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 10px;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .price-label {
            color: #666;
        }
        
        .price-value {
            font-weight: 600;
            color: #333;
        }
        
        .checklist {
            background: #fff3cd;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            border-left: 4px solid #ffc107;
        }
        
        .checklist-title {
            font-weight: 700;
            color: #856404;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .checklist ul {
            list-style: none;
            padding-left: 0;
        }
        
        .checklist li {
            color: #856404;
            padding: 5px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .checklist li i {
            color: #ffc107;
        }
        
        .actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn {
            flex: 1;
            padding: 14px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .btn-approve {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            color: white;
        }
        
        .btn-approve:hover {
            box-shadow: 0 5px 20px rgba(67, 233, 123, 0.4);
            transform: translateY(-2px);
        }
        
        .btn-reject {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
            color: white;
        }
        
        .btn-reject:hover {
            box-shadow: 0 5px 20px rgba(250, 112, 154, 0.4);
            transform: translateY(-2px);
        }
        
        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            background: white;
            color: #667eea;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }
        
        .back-btn:hover {
            background: #667eea;
            color: white;
            transform: translateX(-5px);
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="${pageContext.request.contextPath}/admin" class="back-btn">
            <i class="fas fa-arrow-left"></i> Quay Lại Dashboard
        </a>
        
        <header>
            <h1>
                <i class="fas fa-mask"></i>
                Xét Duyệt Sản Phẩm Cosplay
                <span class="pending-count">${pendingCosplay.size()} Chờ Duyệt</span>
            </h1>
            <p style="color: #666; margin-top: 10px;">Kiểm tra và phê duyệt các sản phẩm cosplay được đăng tải bởi người cho thuê</p>
        </header>
        
        <c:if test="${param.success == 'approved'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <strong>Đã duyệt thành công!</strong> Sản phẩm đã được phê duyệt và hiển thị trên trang Cosplay.
            </div>
        </c:if>
        
        <c:if test="${param.success == 'rejected'}">
            <div class="alert alert-success">
                <i class="fas fa-times-circle"></i>
                <strong>Đã từ chối!</strong> Sản phẩm đã bị từ chối và ẩn khỏi hệ thống.
            </div>
        </c:if>
        
        <c:if test="${param.error == 'true'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>Lỗi!</strong> Không thể xử lý yêu cầu. Vui lòng thử lại.
            </div>
        </c:if>
        
        <c:choose>
            <c:when test="${empty pendingCosplay}">
                <div class="empty-state">
                    <i class="fas fa-check-circle"></i>
                    <h2>Tuyệt vời! Không có sản phẩm nào cần duyệt</h2>
                    <p>Tất cả các sản phẩm cosplay đã được xử lý</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="cosplay-grid">
                    <c:forEach var="clothing" items="${pendingCosplay}">
                        <c:set var="detail" value="${requestScope['cosplayDetail_'.concat(clothing.clothingID)]}" />
                        <div class="cosplay-card">
                            <img src="${pageContext.request.contextPath}/${clothing.imagePath}" 
                                 alt="${clothing.clothingName}" 
                                 class="card-image"
                                 onerror="this.src='${pageContext.request.contextPath}/assets/images/placeholder.jpg'">
                            
                            <div class="card-body">
                                <h3 class="card-title">${clothing.clothingName}</h3>
                                
                                <c:if test="${not empty detail}">
                                    <div class="meta-row">
                                        <i class="fas fa-user"></i>
                                        <strong>Nhân vật:</strong> ${detail.characterName}
                                    </div>
                                    
                                    <div class="meta-row">
                                        <i class="fas fa-book"></i>
                                        <strong>Series:</strong> ${detail.series}
                                    </div>
                                    
                                    <div class="meta-row">
                                        <i class="fas fa-tag"></i>
                                        <strong>Loại:</strong> 
                                        <c:choose>
                                            <c:when test="${detail.cosplayType == 'Anime'}">
                                                <span class="badge badge-anime">ANIME</span>
                                            </c:when>
                                            <c:when test="${detail.cosplayType == 'Game'}">
                                                <span class="badge badge-game">GAME</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-movie">MOVIE</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <div class="meta-row">
                                        <i class="fas fa-star"></i>
                                        <strong>Độ chính xác:</strong> ${detail.accuracyLevel}
                                    </div>
                                    
                                    <c:if test="${not empty detail.accessoryList}">
                                        <div class="meta-row">
                                            <i class="fas fa-box"></i>
                                            <strong>Phụ kiện:</strong> ${detail.accessoryList}
                                        </div>
                                    </c:if>
                                </c:if>
                                
                                <div class="price-section">
                                    <div class="price-row">
                                        <span class="price-label">Giá theo giờ:</span>
                                        <span class="price-value">
                                            <fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,###" /> ₫/giờ
                                        </span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-label">Giá theo ngày:</span>
                                        <span class="price-value">
                                            <fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,###" /> ₫/ngày
                                        </span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-label">Đặt cọc:</span>
                                        <span class="price-value">
                                            <fmt:formatNumber value="${clothing.depositAmount}" pattern="#,###" /> ₫
                                        </span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-label">Số lượng:</span>
                                        <span class="price-value">${clothing.quantity > 0 ? clothing.quantity : 1}</span>
                                    </div>
                                </div>
                                
                                <div class="checklist">
                                    <div class="checklist-title">
                                        <i class="fas fa-clipboard-check"></i>
                                        Checklist Kiểm Tra
                                    </div>
                                    <ul>
                                        <li><i class="fas fa-check"></i> Có đúng là trang phục cosplay không?</li>
                                        <li><i class="fas fa-check"></i> Có đầy đủ phụ kiện như mô tả không?</li>
                                        <li><i class="fas fa-check"></i> Ảnh sản phẩm có chất lượng tốt không?</li>
                                        <li><i class="fas fa-check"></i> Thông tin có chính xác không?</li>
                                    </ul>
                                </div>
                                
                                <div class="actions">
                                    <form action="${pageContext.request.contextPath}/admin" method="post" style="flex: 1;">
                                        <input type="hidden" name="action" value="approveCosplay">
                                        <input type="hidden" name="id" value="${clothing.clothingID}">
                                        <button type="submit" class="btn btn-approve">
                                            <i class="fas fa-check"></i> Duyệt
                                        </button>
                                    </form>
                                    
                                    <form action="${pageContext.request.contextPath}/admin" method="post" style="flex: 1;">
                                        <input type="hidden" name="action" value="rejectCosplay">
                                        <input type="hidden" name="id" value="${clothing.clothingID}">
                                        <button type="submit" class="btn btn-reject" 
                                                onclick="return confirm('Bạn có chắc muốn từ chối sản phẩm này?')">
                                            <i class="fas fa-times"></i> Từ Chối
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
