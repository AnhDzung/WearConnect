<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đơn hàng - WearConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .header h1 {
            color: #333;
            font-size: 28px;
        }
        
        .nav-links {
            display: flex;
            gap: 15px;
        }
        
        .nav-links a {
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav-links a:hover {
            background: #0056b3;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .filters {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .filters select {
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
        }
        
        .filters button {
            padding: 10px 25px;
            background: #28a745;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
        }
        
        .filters button:hover {
            background: #218838;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        
        thead {
            background: #343a40;
            color: white;
        }
        
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }
        
        th {
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
        
        tbody tr {
            transition: background 0.2s;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        .status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            display: inline-block;
            min-width: 100px;
        }
        
        .status.pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status.verifying {
            background: #cfe2ff;
            color: #084298;
        }
        
        .status.confirmed {
            background: #d1e7dd;
            color: #0f5132;
        }
        
        .status.rented {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .status.returned {
            background: #e2e3e5;
            color: #383d41;
        }
        
        .status.cancelled {
            background: #f8d7da;
            color: #721c24;
        }
        
        .actions {
            display: flex;
            gap: 8px;
        }
        
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 13px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
        }
        
        .btn-verify {
            background: #28a745;
            color: white;
        }
        
        .btn-verify:hover {
            background: #218838;
            transform: translateY(-2px);
        }
        
        .btn-view {
            background: #007bff;
            color: white;
        }
        
        .btn-view:hover {
            background: #0056b3;
            transform: translateY(-2px);
        }
        
        .price {
            color: #d32f2f;
            font-weight: 600;
        }
        
        .stats-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            text-align: center;
        }
        
        .stat-card h3 {
            font-size: 32px;
            margin-bottom: 5px;
        }
        
        .stat-card p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .no-data svg {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header" style="display: flex; justify-content: space-between; align-items: center;">
            <h1>📦 Quản lý đơn hàng</h1>
            <a href="${pageContext.request.contextPath}/admin" style="padding: 10px 20px; background: #6c757d; color: white; text-decoration: none; border-radius: 5px; transition: background 0.3s;">← Quay lại Dashboard</a>
        </div>
        
        <!-- Alert messages -->
        <c:if test="${param.verified == 'true'}">
            <div class="alert success">
                ✓ Đơn hàng đã được xác nhận thành công!
            </div>
        </c:if>
        
        <c:if test="${param.error == 'true'}">
            <div class="alert error">
                ✗ Có lỗi xảy ra khi xác nhận đơn hàng!
            </div>
        </c:if>
        
        <!-- Filters -->
        <form method="get" action="${pageContext.request.contextPath}/admin">
            <input type="hidden" name="action" value="orders">
            <div class="filters">
                <select name="status" id="statusFilter">
                    <option value="ALL" ${statusFilter == 'ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
                    <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>Chờ thanh toán</option>
                    <option value="VERIFYING" ${statusFilter == 'VERIFYING' ? 'selected' : ''}>Đang kiểm tra</option>
                    <option value="CONFIRMED" ${statusFilter == 'CONFIRMED' ? 'selected' : ''}>Đã xác nhận</option>
                    <option value="RENTED" ${statusFilter == 'RENTED' ? 'selected' : ''}>Đang thuê</option>
                    <option value="RETURNED" ${statusFilter == 'RETURNED' ? 'selected' : ''}>Đã trả</option>
                    <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
                </select>
                <button type="submit">Lọc</button>
            </div>
        </form>
        
        <!-- Orders Table -->
        <div class="table-container">
            <c:choose>
                <c:when test="${not empty orders}">
                    <table>
                        <thead>
                            <tr>
                                <th>Mã ĐH</th>
                                <th>Sản phẩm</th>
                                <th>Người thuê</th>
                                <th>Manager</th>
                                <th>Giá</th>
                                <th>Trạng thái</th>
                                <th>Thanh toán</th>
                                <th>Ngày tạo</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="order" items="${orders}">
                                <tr>
                                    <td>#${order.rentalOrderID}</td>
                                    <td>
                                        <strong>${order.clothingName}</strong><br>
                                        <small style="color: #666;">${order.category}</small>
                                    </td>
                                    <td>${order.renterName}</td>
                                    <td>${order.managerName}</td>
                                    <td class="price">
                                        <fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/>đ
                                    </td>
                                    <td>
                                        <span class="status ${order.status.toLowerCase()}">
                                            ${order.status}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.paymentStatus != null}">
                                                ${order.paymentStatus}
                                                <c:if test="${order.paymentProofImage != null}">
                                                    <br><small style="color: #28a745;">✓ Có ảnh CM</small>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #999;">Chưa thanh toán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>
                                        <div class="actions" style="flex-wrap: wrap;">
                                            <c:if test="${order.status == 'PENDING' || order.status == 'VERIFYING'}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin" style="display: inline;">
                                                    <input type="hidden" name="action" value="verifyPayment">
                                                    <input type="hidden" name="orderID" value="${order.rentalOrderID}">
                                                    <button type="submit" class="btn btn-verify" 
                                                            onclick="return confirm('Xác nhận thanh toán cho đơn hàng #${order.rentalOrderID}?')">
                                                        ✓ Xác nhận
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${not empty order['paymentProofImage']}">
                                                <c:set var="imagePath" value="${order['paymentProofImage']}" />
                                                <button type="button" class="btn btn-view" 
                                                        onclick="openProofImage('${pageContext.request.contextPath}/image?path=${imagePath}')">
                                                    📸 Xem ảnh
                                                </button>
                                            </c:if>
                                            <a href="${pageContext.request.contextPath}/rental?action=viewOrder&id=${order.rentalOrderID}" 
                                               class="btn btn-view">
                                                👁 Chi tiết
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-data">
                        <svg fill="currentColor" viewBox="0 0 20 20">
                            <path d="M10 2a8 8 0 100 16 8 8 0 000-16zm1 11H9v-2h2v2zm0-4H9V5h2v4z"/>
                        </svg>
                        <h3>Không có đơn hàng</h3>
                        <p>Không tìm thấy đơn hàng nào với bộ lọc đã chọn.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Modal for viewing proof image -->
    <div id="proofImageModal" style="display:none; position:fixed; z-index:2000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.7); align-items:center; justify-content:center;">
        <div style="background:white; padding:20px; border-radius:10px; max-width:90%; max-height:90%; overflow:auto; text-align:center;">
            <button type="button" onclick="closeProofImage()" style="float:right; background:none; border:none; font-size:24px; cursor:pointer; color:#666;">&times;</button>
            <h3>Ảnh chứng minh thanh toán</h3>
            <img id="proofImage" src="" alt="Payment proof" style="max-width:100%; max-height:70vh; border-radius:8px; margin-top:15px;">
        </div>
    </div>

    <script>
        function openProofImage(imagePath) {
            console.log("[Debug] Opening proof image via servlet: " + imagePath);
            const img = document.getElementById('proofImage');
            img.onerror = function() {
                console.error("[Error] Failed to load image from: " + imagePath);
                img.alt = "Ảnh không tìm thấy hoặc không thể tải";
            };
            img.src = imagePath;
            document.getElementById('proofImageModal').style.display = 'flex';
        }
        
        function closeProofImage() {
            document.getElementById('proofImageModal').style.display = 'none';
        }
        
        // Close modal when clicking outside
        document.getElementById('proofImageModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeProofImage();
            }
        });
    </script>
</body>
</html>
