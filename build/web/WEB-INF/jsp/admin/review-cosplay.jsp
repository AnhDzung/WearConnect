<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
            font-family: cursive;
            background-color: #f5f5f5;
            min-height: 100vh;
            padding: 24px 20px 60px;
            color: #111;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding-top: 10px;
        }
        
        header {
            background: #ffffff;
            padding: 24px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        header h1 {
            color: #007bff;
            font-size: 28px;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .pending-count {
            background: #ffc107;
            color: #111;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 13px;
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
            background: #ffffff;
            padding: 48px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .empty-state i {
            font-size: 80px;
            color: #667eea;
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
            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
            gap: 18px;
        }
        
        .cosplay-card {
            background: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
            border: 1px solid rgba(0, 0, 0, 0.06);
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
            justify-content: space-between;
        }

        .actions form {
            flex: 0 0 auto;
        }

        .actions form:last-child {
            margin-left: auto;
        }
        
        .btn {
            flex: 1;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        
        .btn-approve {
            background-color: #28a745;
            color: white;
        }
        
        .btn-approve:hover {
            background-color: #218838;
        }
        
        .btn-reject {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-reject:hover {
            background-color: #c82333;
        }
        
        .btn-detail {
            background-color: #007bff;
            color: white;
        }
        
        .btn-detail:hover {
            background-color: #0056b3;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.6);
            backdrop-filter: blur(5px);
        }
        
        .modal-content {
            background: white;
            margin: 3% auto;
            padding: 0;
            border-radius: 8px;
            width: 92%;
            max-width: 980px;
            box-shadow: 0 12px 32px rgba(0,0,0,0.2);
            animation: slideDown 0.3s ease;
        }
        
        @keyframes slideDown {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        .modal-header {
            background: #007bff;
            color: white;
            padding: 16px 20px;
            border-radius: 8px 8px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            font-size: 24px;
        }
        
        .close {
            color: white;
            font-size: 32px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
            transition: transform 0.2s;
        }
        
        .close:hover {
            transform: rotate(90deg);
        }
        
        .modal-body {
            padding: 20px;
            max-height: 72vh;
            overflow-y: auto;
        }
        
        .detail-section {
            margin-bottom: 25px;
        }
        
        .detail-section h3 {
            color: #007bff;
            margin-bottom: 12px;
            font-size: 18px;
            border-bottom: 2px solid #007bff;
            padding-bottom: 8px;
        }
        
        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }
        
        .detail-item {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 6px;
        }
        
        .detail-label {
            font-weight: 600;
            color: #666;
            font-size: 13px;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        
        .detail-value {
            color: #333;
            font-size: 16px;
        }
        
        .detail-image {
            width: 100%;
            max-width: 100%;
            max-height: 60vh;
            height: auto;
            object-fit: contain;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12);
            background: #f8f9fa;
            display: block;
        }
        
        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            background: #007bff;
            color: #ffffff;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .back-btn:hover {
            background: #0056b3;
            color: white;
            transform: none;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />
    <div class="container">
        <a href="${pageContext.request.contextPath}/admin" class="back-btn">
            <i class="fas fa-arrow-left"></i> Quay Lại Dashboard
        </a>
        
        <header>
            <h1>
                Xét Duyệt Sản Phẩm Cosplay
                <span class="pending-count">${fn:length(pendingCosplay)} Chờ Duyệt</span>
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
                        <c:set var="detailKey" value="cosplayDetail_${clothing.clothingID}" />
                        <c:set var="detail" value="${requestScope[detailKey]}" />
                        <div class="cosplay-card">
                            <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" 
                                 alt="${clothing.clothingName}" 
                                 class="card-image"
                                 onerror="if(!this.dataset.failed){this.dataset.failed='1';this.src='data:image/svg+xml,%3Csvg width=\'400\' height=\'300\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Crect width=\'400\' height=\'300\' fill=\'%23eee\'/%3E%3Ctext x=\'50%25\' y=\'50%25\' font-family=\'Arial\' font-size=\'18\' fill=\'%23999\' text-anchor=\'middle\' dy=\'.3em\'%3ENo Image%3C/text%3E%3C/svg%3E';}">
                            
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
                                            <c:choose>
                                                <c:when test="${not empty clothing.hourlyPrice}">
                                                    <fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,###" /> ₫/giờ
                                                </c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-label">Giá theo ngày:</span>
                                        <span class="price-value">
                                            <c:choose>
                                                <c:when test="${not empty clothing.dailyPrice}">
                                                    <fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,###" /> ₫/ngày
                                                </c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-label">Đặt cọc:</span>
                                        <span class="price-value">
                                            <c:choose>
                                                <c:when test="${not empty clothing.depositAmount}">
                                                    <fmt:formatNumber value="${clothing.depositAmount}" pattern="#,###" /> ₫
                                                </c:when>
                                                <c:otherwise>0 ₫</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-label">Số lượng:</span>
                                        <span class="price-value">
                                            <c:choose>
                                                <c:when test="${not empty clothing.quantity and clothing.quantity > 0}">
                                                    ${clothing.quantity}
                                                </c:when>
                                                <c:otherwise>1</c:otherwise>
                                            </c:choose>
                                        </span>
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
                                
                                <button type="button" class="btn btn-detail" 
                                        onclick="showDetail(${clothing.clothingID})" 
                                        style="width: 100%; margin-top: 15px;">
                                    <i class="fas fa-eye"></i> Xem Chi Tiết
                                </button>

                                <div id="detail-content-${clothing.clothingID}" style="display: none;">
                                    <div class="detail-section">
                                        <h3><i class="fas fa-image"></i> Hình Ảnh</h3>
                                        <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}"
                                             alt="${clothing.clothingName}"
                                             class="detail-image"
                                             onerror="this.src='data:image/svg+xml,%3Csvg width=\'400\' height=\'300\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Crect width=\'400\' height=\'300\' fill=\'%23eee\'/%3E%3Ctext x=\'50%25\' y=\'50%25\' font-family=\'Arial\' font-size=\'18\' fill=\'%23999\' text-anchor=\'middle\' dy=\'.3em\'%3ENo Image%3C/text%3E%3C/svg%3E';">
                                    </div>

                                    <div class="detail-section">
                                        <h3><i class="fas fa-info-circle"></i> Thông Tin Cơ Bản</h3>
                                        <div class="detail-grid">
                                            <div class="detail-item">
                                                <div class="detail-label">Tên Sản Phẩm</div>
                                                <div class="detail-value">${clothing.clothingName}</div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Danh Mục</div>
                                                <div class="detail-value">${clothing.category}</div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Phong Cách</div>
                                                <div class="detail-value">${clothing.style}</div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Dịp</div>
                                                <div class="detail-value">${clothing.occasion}</div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Size</div>
                                                <div class="detail-value">${clothing.size}</div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Số Lượng</div>
                                                <div class="detail-value">
                                                    <c:choose>
                                                        <c:when test="${not empty clothing.quantity and clothing.quantity > 0}">
                                                            ${clothing.quantity}
                                                        </c:when>
                                                        <c:otherwise>1</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="detail-section">
                                        <h3><i class="fas fa-dollar-sign"></i> Giá & Đặt Cọc</h3>
                                        <div class="detail-grid">
                                            <div class="detail-item">
                                                <div class="detail-label">Giá Theo Giờ</div>
                                                <div class="detail-value">
                                                    <c:choose>
                                                        <c:when test="${not empty clothing.hourlyPrice}">
                                                            <fmt:formatNumber value="${clothing.hourlyPrice}" pattern="#,###" /> ₫/giờ
                                                        </c:when>
                                                        <c:otherwise>N/A</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Giá Theo Ngày</div>
                                                <div class="detail-value">
                                                    <c:choose>
                                                        <c:when test="${not empty clothing.dailyPrice}">
                                                            <fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,###" /> ₫/ngày
                                                        </c:when>
                                                        <c:otherwise>N/A</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Tiền Đặt Cọc</div>
                                                <div class="detail-value">
                                                    <c:choose>
                                                        <c:when test="${not empty clothing.depositAmount}">
                                                            <fmt:formatNumber value="${clothing.depositAmount}" pattern="#,###" /> ₫
                                                        </c:when>
                                                        <c:otherwise>0 ₫</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="detail-section">
                                        <h3><i class="fas fa-calendar-alt"></i> Thời Gian Cho Thuê</h3>
                                        <div class="detail-grid">
                                            <div class="detail-item">
                                                <div class="detail-label">Có Sẵn Từ</div>
                                                <div class="detail-value">${clothing.availableFrom}</div>
                                            </div>
                                            <div class="detail-item">
                                                <div class="detail-label">Có Sẵn Đến</div>
                                                <div class="detail-value">${clothing.availableTo}</div>
                                            </div>
                                        </div>
                                    </div>

                                    <c:if test="${not empty detail}">
                                        <div class="detail-section">
                                            <h3>Thông Tin Cosplay</h3>
                                            <div class="detail-grid">
                                                <div class="detail-item">
                                                    <div class="detail-label">Nhân Vật</div>
                                                    <div class="detail-value">${detail.characterName}</div>
                                                </div>
                                                <div class="detail-item">
                                                    <div class="detail-label">Series</div>
                                                    <div class="detail-value">${detail.series}</div>
                                                </div>
                                                <div class="detail-item">
                                                    <div class="detail-label">Loại</div>
                                                    <div class="detail-value">${detail.cosplayType}</div>
                                                </div>
                                                <div class="detail-item">
                                                    <div class="detail-label">Độ Chính Xác</div>
                                                    <div class="detail-value">${detail.accuracyLevel}</div>
                                                </div>
                                            </div>
                                            <c:if test="${not empty detail.accessoryList}">
                                                <div class="detail-item" style="margin-top: 15px;">
                                                    <div class="detail-label">Phụ Kiện Đi Kèm</div>
                                                    <div class="detail-value">${detail.accessoryList}</div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:if>

                                    <div class="detail-section">
                                        <h3><i class="fas fa-align-left"></i> Mô Tả</h3>
                                        <div class="detail-item">
                                            <div class="detail-value">${clothing.description}</div>
                                        </div>
                                    </div>
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
    
    <!-- Modal Chi Tiết -->
    <div id="detailModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-info-circle"></i> Chi Tiết Sản Phẩm Cosplay</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body" id="modalBody">
                <p style="text-align: center; color: #666;">Đang tải...</p>
            </div>
        </div>
    </div>
    
    <script>
        function showDetail(id) {
            const modal = document.getElementById('detailModal');
            const modalBody = document.getElementById('modalBody');
            const detail = document.getElementById('detail-content-' + id);
            if (!detail) return;
            modalBody.innerHTML = detail.innerHTML;
            modal.style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('detailModal').style.display = 'none';
        }
        
        // Đóng modal khi click bên ngoài
        window.onclick = function(event) {
            const modal = document.getElementById('detailModal');
            if (event.target == modal) {
                closeModal();
            }
        }
        
        // Đóng modal bằng ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });
    </script>
    
</body>
</html>
