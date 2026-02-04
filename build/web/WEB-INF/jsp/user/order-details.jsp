<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="DAO.ColorDAO" %>
<%@ page import="Model.Color" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết đơn - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .container { max-width: 1000px; margin: 40px auto; padding: 20px; }
        .order-wrapper { display: flex; gap: 24px; align-items: flex-start; }
        .order-left { flex: 1; }
        .order-right { width: 320px; }
        .product-image-box { background: #f9f9f9; padding: 14px; border-radius: 8px; text-align: center; border: 1px solid #e6e9f0; }
        .product-image { width: 100%; max-height: 260px; object-fit: cover; border-radius: 6px; box-shadow: 0 6px 14px rgba(0,0,0,0.06); }
        .order-info { background-color: #f9f9f9; padding: 20px; border-radius: 8px; border: 1px solid #e6e9f0; }
        .info-row { margin: 10px 0; }
        .info-row strong { display: inline-block; width: 150px; }
        .status { padding: 8px 15px; border-radius: 3px; font-weight: bold; }
        .status.pending { background-color: #ffc107; }
        .status.verifying { background-color: #17a2b8; color: white; }
        .status.confirmed { background-color: #28a745; color: white; }
        .status.rented { background-color: #28a745; color: white; }
        .status.returned { background-color: #6c757d; color: white; }
        .btn { padding: 10px 20px; margin-top: 20px; background-color: #007bff; color: white; border: none; cursor: pointer; }
        .btn-danger { background-color: #dc3545; }
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .alert-success { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .star-rating { display: inline-flex; flex-direction: row-reverse; gap: 6px; font-size: 26px; cursor: pointer; }
        .star-rating input { display: none; }
        .star-rating label { color: #ccc; transition: color 0.2s ease; }
        .star-rating input:checked ~ label { color: #f5b301; }
        .star-rating label:hover,
        .star-rating label:hover ~ label { color: #f5d16b; }
        .rating-note { font-size: 12px; color: #666; margin-top: 4px; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        .modal.show { display: flex; align-items: center; justify-content: center; }
        .modal-content { background-color: white; padding: 30px; border-radius: 8px; width: 90%; max-width: 500px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-header h2 { margin: 0; font-size: 24px; color: #333; }
        .modal-close { background: none; border: none; font-size: 28px; cursor: pointer; color: #999; }
        .modal-close:hover { color: #333; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #333; }
        .form-group select, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-family: inherit; font-size: 14px; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .modal-buttons { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .modal-btn { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: 600; }
        .modal-btn-submit { background-color: #dc3545; color: white; }
        .modal-btn-submit:hover { opacity: 0.9; }
        .modal-btn-cancel { background-color: #e0e0e0; color: #333; }
        .modal-btn-cancel:hover { background-color: #d0d0d0; }
        .color-info { display: flex; align-items: center; gap: 10px; }
        .color-swatch { display: inline-block; width: 24px; height: 24px; border-radius: 3px; border: 1px solid #999; }
        @media (max-width: 768px) {
            .order-wrapper { flex-direction: column; }
            .order-right { width: 100%; }
            .product-image { max-height: 320px; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Chi tiết đơn thuê</h1>
    
    <!-- Success message for payment verifying -->
    <c:if test="${param.paymentVerifying == 'true'}">
        <div class="alert alert-success">
            <strong>Thanh toán thành công!</strong><br>
            Cảm ơn bạn đã tải ảnh chứng minh thanh toán.<br>
            Đơn hàng của bạn đang được hệ thống kiểm tra và xác thực.<br>
            Vui lòng đợi admin xác nhận thanh toán.
        </div>
    </c:if>

    <!-- Bank transfer pending message when no proof uploaded -->
    <c:if test="${param.bankTransferPending == 'true'}">
        <div class="alert alert-info" style="border:1px solid #b8daff; color:#0c5460;">
            <strong>Yêu cầu thanh toán đã được ghi nhận.</strong><br>
            Bạn đã chọn chuyển khoản nhưng chưa tải ảnh chứng minh.<br>
            Vui lòng chuyển khoản theo thông tin đã hiển thị và tải ảnh chứng minh thanh toán để hệ thống xác thực nhanh hơn.
        </div>
    </c:if>
    
    <c:choose>
        <c:when test="${sessionScope.userRole == 'Admin'}">
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin?action=orders'" style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 20px;">Quay lại</button>
        </c:when>
        <c:when test="${sessionScope.userRole == 'Manager'}">
            <button onclick="window.location.href='${pageContext.request.contextPath}/manager?action=orders'" style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 20px;">Quay lại</button>
        </c:when>
        <c:otherwise>
            <button onclick="window.location.href='${pageContext.request.contextPath}/rental?action=myOrders'" style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 20px;">Quay lại</button>
        </c:otherwise>
    </c:choose>
    
    <div class="order-wrapper">
        <div class="order-left">
            <div class="order-info">
                <div style="display:flex; gap:20px; align-items:flex-start;">
                    <div style="flex:1;">
                        <div class="info-row">
                            <strong>Mã đơn hàng:</strong> ${order.orderCode}
                        </div>
                        <div class="info-row">
                            <strong>Quần áo:</strong> ${empty order.clothingName ? order.clothingID : order.clothingName}
                        </div>
                        <div class="info-row">
                            <strong>Ngày bắt đầu:</strong> ${order.rentalStartDate}
                        </div>
                        <div class="info-row">
                            <strong>Ngày kết thúc:</strong> ${order.rentalEndDate}
                        </div>
                        <div class="info-row">
                            <strong>Tổng giá:</strong> ${order.totalPrice} VNĐ
                        </div>
                        <div class="info-row">
                            <strong>Tiền cọc:</strong> ${order.depositAmount} VNĐ
                        </div>
                        <div class="info-row">
                            <strong>Trạng thái:</strong>
                            <span class="status ${order.status.toLowerCase()}">
                                ${order.status}
                            </span>
                        </div>
                        <div class="info-row">
                            <strong>Ngày tạo:</strong> ${order.createdAt}
                        </div>
                        <c:if test="${not empty order.selectedSize}">
                            <div class="info-row">
                                <strong>Size đã chọn:</strong> ${order.selectedSize}
                            </div>
                        </c:if>
                        <c:if test="${order.colorID != null}">
                            <%
                                Integer colorID = (Integer) pageContext.getAttribute("order", PageContext.PAGE_SCOPE) != null ? 
                                    ((Model.RentalOrder) pageContext.getAttribute("order", PageContext.PAGE_SCOPE)).getColorID() : null;
                                if (colorID != null) {
                                    Color color = ColorDAO.getColorByID(colorID);
                                    if (color != null) {
                                        pageContext.setAttribute("selectedColor", color);
                                    }
                                }
                            %>
                            <div class="info-row">
                                <strong>Màu sắc:</strong>
                                <c:if test="${not empty selectedColor}">
                                    <div class="color-info">
                                        <div class="color-swatch" style="background-color: ${selectedColor.hexCode != null ? selectedColor.hexCode : '#ccc'};"></div>
                                        <span>${selectedColor.colorName}</span>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>
                    </div>
                    <div style="width:320px;">
                        <c:choose>
                            <c:when test="${not empty clothingImages}">
                                <c:forEach var="image" items="${clothingImages}">
                                    <c:if test="${image.primary}">
                                        <div class="product-image-box">
                                            <img src="${pageContext.request.contextPath}/image?imageID=${image.imageID}" alt="${order.clothingName}" class="product-image">
                                            <p style="margin: 10px 0 0 0; font-size: 12px; color: #999;">Ảnh sản phẩm</p>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="product-image-box">
                                    <img src="${pageContext.request.contextPath}/image?id=${order.clothingID}" alt="${order.clothingName}" class="product-image">
                                    <p style="margin: 10px 0 0 0; font-size: 12px; color: #999;">Ảnh sản phẩm</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <c:if test="${order.status == 'PENDING' && sessionScope.userRole == 'User'}">
                <a href="${pageContext.request.contextPath}/payment?rentalOrderID=${order.rentalOrderID}" class="btn">Thanh toán</a>
                <form method="POST" action="${pageContext.request.contextPath}/rental">
                    <input type="hidden" name="action" value="cancelOrder">
                    <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}">
                    <button type="submit" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn hủy đơn?')">Hủy đơn</button>
                </form>
            </c:if>

            <c:if test="${order.status == 'RENTED'}">
                <form method="POST" action="${pageContext.request.contextPath}/rental" style="margin-top: 16px; display:inline-block;">
                    <input type="hidden" name="action" value="requestReturn">
                    <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}">
                    <button type="submit" class="btn" style="background-color:#17a2b8; margin-right:8px;">Đã thuê xong-trả lại</button>
                </form>
                <button type="button" class="btn" style="background-color:#dc3545; margin-top:16px;" onclick="openIssueModal('${order.rentalOrderID}')">Báo cáo vấn đề</button>
            </c:if>

            <c:if test="${order.status == 'COMPLETED'}">
                <c:if test="${sessionScope.accountID != order.managerID}">
                    <div style="margin-top: 25px; padding: 16px; border: 1px solid #e1e5ee; border-radius: 6px; background: #f8fafc;">
                        <h3 style="margin-top: 0;">Đánh giá sản phẩm</h3>
                        <form method="POST" action="${pageContext.request.contextPath}/rating">
                            <input type="hidden" name="action" value="submitRating">
                            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}">
                            <div style="margin-bottom: 10px;">
                                <label for="rating">Chấm điểm:</label>
                                <div class="star-rating">
                                    <input type="radio" id="star5" name="rating" value="5" required><label for="star5">&#9733;</label>
                                    <input type="radio" id="star4" name="rating" value="4"><label for="star4">&#9733;</label>
                                    <input type="radio" id="star3" name="rating" value="3"><label for="star3">&#9733;</label>
                                    <input type="radio" id="star2" name="rating" value="2"><label for="star2">&#9733;</label>
                                    <input type="radio" id="star1" name="rating" value="1"><label for="star1">&#9733;</label>
                                </div>
                                <div class="rating-note">Chọn số sao tương ứng với trải nghiệm của bạn.</div>
                            </div>
                            <div style="margin-bottom: 10px;">
                                <label for="comment">Nhận xét của bạn:</label>
                                <textarea id="comment" name="comment" rows="3" style="width: 100%; box-sizing: border-box;" placeholder="Chia sẻ trải nghiệm để người cho thuê biết" required></textarea>
                            </div>
                            <button type="submit" class="btn">Gửi đánh giá</button>
                        </form>
                    </div>
                </c:if>
            </c:if>
        </div>
    </div>

    <!-- Issue Reporting Modal -->
    <div id="issueModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Báo cáo vấn đề</h2>
                <button class="modal-close" onclick="closeIssueModal()">&times;</button>
            </div>
            <form id="issueForm" method="POST" action="${pageContext.request.contextPath}/rental" enctype="multipart/form-data">
                <input type="hidden" name="action" value="reportIssue">
                <input type="hidden" name="rentalOrderID" id="issueRentalOrderID">
                
                <div class="form-group">
                    <label for="issueType">Loại vấn đề:</label>
                    <select id="issueType" name="issueType" required>
                        <option value="">-- Chọn loại vấn đề --</option>
                        <option value="WRONG_ITEM">Đó không đúng sản phẩm</option>
                        <option value="DAMAGED">Đó bị hỏng hóc / kích hoạt</option>
                        <option value="WRONG_SIZE">Sai kích thước / size</option>
                        <option value="COLOR_MISMATCH">Màu sắc không khớp</option>
                        <option value="OTHER">Vấn đề khác</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="description">Mô tả chi tiết:</label>
                    <textarea id="description" name="description" placeholder="Hãy mô tả rõ rằng vấn đề bạn gặp phải..." required></textarea>
                </div>

                <div class="form-group">
                    <label for="issueImage">Tải ảnh chứng minh (tối đa 5MB):</label>
                    <input type="file" id="issueImage" name="issueImage" accept="image/*" style="padding:8px; border:1px solid #ddd; border-radius:4px; width:100%; box-sizing:border-box;">
                </div>
                
                <div class="modal-buttons">
                    <button type="button" class="modal-btn modal-btn-cancel" onclick="closeIssueModal()">Hủy</button>
                    <button type="submit" class="modal-btn modal-btn-submit">Gửi báo cáo</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openIssueModal(rentalOrderID) {
            document.getElementById('issueRentalOrderID').value = rentalOrderID;
            document.getElementById('issueModal').classList.add('show');
        }
        
        function closeIssueModal() {
            document.getElementById('issueModal').classList.remove('show');
            document.getElementById('issueForm').reset();
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('issueModal');
            if (event.target == modal) {
                modal.classList.remove('show');
            }
        }
    </script>

    <!-- Payment proof preview for staff/admin -->
    <c:if test="${not empty payment and not empty payment.paymentProofImage}">
        <div style="margin-top:24px; padding:16px; border:1px solid #e1e5ee; border-radius:8px; background:#f9fbff;">
            <h3 style="margin-top:0;">Ảnh chứng minh thanh toán</h3>
            <img src="${pageContext.request.contextPath}/${payment.paymentProofImage}" alt="Payment proof" style="max-width:100%; border-radius:6px; border:1px solid #dce3f0;">
        </div>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
