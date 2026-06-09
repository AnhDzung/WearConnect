<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Danh sách trả hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 20px auto; padding: 20px; }
        h1 { color: #333; }
        .info-box { background-color: #e8f4f8; border: 1px solid #b8e0e8; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .info-box h4 { margin-top: 0; }
        .order-card { background: white; padding: 15px; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 20px; align-items: center; }
        .order-details { display: flex; flex-direction: column; gap: 8px; }
        .order-code { font-size: 14px; color: #666; font-weight: bold; }
        .order-name { font-size: 16px; color: #333; font-weight: bold; }
        .order-date { font-size: 12px; color: #999; }
        .order-price { display: flex; flex-direction: column; gap: 5px; }
        .price-label { font-size: 12px; color: #666; }
        .amount { font-size: 16px; font-weight: bold; color: #28a745; }
        .order-action { display: flex; gap: 10px; }
        button { padding: 10px 16px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold; }
        .btn-return { background-color: #28a745; color: white; }
        .btn-return:hover { background-color: #218838; }
        .status-ready { display: inline-block; padding: 4px 8px; background-color: #d4edda; color: #155724; border-radius: 3px; font-size: 12px; font-weight: bold; }
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state h3 { color: #999; }
        .empty-state p { color: #b8b8b8; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>📦 Danh Sách Trả Hàng</h1>
    
    <div class="info-box">
        <h4>ℹ️ Hướng dẫn</h4>
        <p>Dưới đây là danh sách các đơn hàng bạn cần trả. Hãy kiểm tra tình trạng sản phẩm và trả hàng để nhận lại cọc.</p>
    </div>
    
    <c:choose>
        <c:when test="${orders != null && orders.size() > 0}">
            <c:forEach var="order" items="${orders}">
                <div class="order-card">
                    <!-- Order Details -->
                    <div class="order-details">
                        <div class="order-code">${order.orderCode}</div>
                        <div class="order-name">${order.clothingName}</div>
                        <div class="order-date">
                            Kết thúc: ${order.formattedEndDate}
                        </div>
                    </div>
                    
                    <!-- Price Info -->
                    <div class="order-price">
                        <div>
                            <div class="price-label">Tiền cọc</div>
                            <div class="amount">
                                <fmt:formatNumber value="${order.adjustedDepositAmount > 0 ? order.adjustedDepositAmount : order.depositAmount}" pattern="#,###" /> ₫
                            </div>
                        </div>
                        <div class="status-ready">✓ Sẵn sàng trả</div>
                    </div>
                    
                    <!-- Action -->
                    <div class="order-action">
                        <button class="btn-return" onclick="window.location.href='${pageContext.request.contextPath}/return?action=details&id=${order.rentalOrderID}'">
                            Trả hàng
                        </button>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <h3>📭 Không có đơn hàng cần trả</h3>
                <p>Tất cả đơn thuê của bạn đã được xử lý trả hàng.</p>
                <button class="btn-return" onclick="window.location.href='${pageContext.request.contextPath}/user?action=orders'" style="margin-top: 20px;">
                    ← Xem danh sách đơn hàng
                </button>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
