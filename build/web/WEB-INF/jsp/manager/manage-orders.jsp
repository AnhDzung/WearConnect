<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý đơn thuê - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; font-family: cursive; }
        .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
        h1 { color: #333; margin-bottom: 20px; }
        
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 20px; 
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border-radius: 8px;
            overflow: hidden;
        }
        
        th, td { 
            padding: 16px 14px; 
            text-align: left; 
            border-bottom: 1px solid #f0f0f0;
            font-size: 14px;
        }
        
        th { 
            background-color: #f8f9fa; 
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #dee2e6;
        }
        
        td { color: #555; }
        
        tr:hover { background-color: #f9f9f9; }
        
        .status { 
            display: inline-block;
            padding: 6px 12px; 
            border-radius: 20px; 
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }
        
        .status.pending { background-color: #fff3cd; color: #856404; }
        .status.verifying { background-color: #cfe2ff; color: #084298; }
        .status.confirmed { background-color: #cff4fc; color: #055160; }
        .status.rented { background-color: #d1e7dd; color: #0f5132; }
        .status.returned { background-color: #e2e3e5; color: #383d41; }
        .status.issue { background-color: #fff3cd; color: #856404; font-weight: 700; }
        .status.completed { background-color: #198754; color: white; font-weight: 700; }
        .status.cancelled { background-color: #f8d7da; color: #842029; }
        
        /* Renter info styling for PAYMENT_VERIFIED status */
        .renter-info {
            font-size: 0.85em;
            color: #495057;
            margin-top: 8px;
            padding: 8px;
            background: #f8f9fa;
            border-left: 3px solid #28a745;
            border-radius: 4px;
        }
        .renter-info div {
            margin: 3px 0;
            line-height: 1.5;
        }
        .renter-info strong {
            color: #212529;
            min-width: 70px;
            display: inline-block;
        }
        
        .btn-group { display: flex; gap: 8px; flex-wrap: wrap; }
        
        .btn { 
            padding: 8px 14px; 
            background-color: #007bff; 
            color: white; 
            border: none; 
            cursor: pointer; 
            border-radius: 4px;
            font-size: 13px;
            font-weight: 500;
            transition: background-color 0.3s;
            white-space: nowrap;
        }
        
        .btn:hover { opacity: 0.9; }
        .btn-info { background-color: #0dcaf0; }
        .btn-success { background-color: #198754; }
        .btn-secondary { background-color: #6c757d; }
        /* Rating widget styles (match user-side `order-details.jsp`) */
        .star-rating { display: inline-flex; gap: 6px; font-size: 26px; cursor: pointer; }
        .star-rating input { display: none; }
        .star-rating label { color: #ccc; transition: color 0.2s ease; font-size: 26px; }
        .star-rating input:checked ~ label { color: #f5b301; }
        .star-rating label:hover,
        .star-rating label:hover ~ label { color: #f5d16b; }
        
        /* Rating Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }
        
        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
            width: 90%;
            max-width: 500px;
        }
        
        .modal-header {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            color: #333;
            font-size: 22px;
        }
        
        .modal-close {
            font-size: 28px;
            font-weight: bold;
            color: #999;
            cursor: pointer;
            background: none;
            border: none;
            padding: 0;
            line-height: 1;
        }
        
        .modal-close:hover {
            color: #333;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        
        .rating-stars {
            display: flex;
            flex-direction: row-reverse;
            gap: 10px;
            font-size: 32px;
        }
        
        .rating-stars input {
            display: none;
        }
        
        .rating-stars label {
            cursor: pointer;
            color: #ddd;
            margin: 0;
            transition: color 0.2s;
        }
        
        .rating-stars input:checked ~ label,
        .rating-stars label:hover,
        .rating-stars label:hover ~ label {
            color: #ffc107;
        }
        
        textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-family: inherit;
            font-size: 14px;
            resize: vertical;
            min-height: 100px;
        }
        
        .modal-footer {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 25px;
        }
        
        .btn-cancel {
            background-color: #6c757d;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Quản lý đơn thuê</h1>
    <button onclick="history.back()" style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 20px;">Quay lại</button>
    <c:if test="${newConfirmedCount > 0}">
        <div style="background:#cff4fc; border:1px solid #b6effb; color:#055160; padding:12px 14px; border-radius:8px; margin-bottom:16px; box-shadow:0 2px 6px rgba(0,0,0,0.05);">
            🔔 Có ${newConfirmedCount} đơn hàng mới được admin xác thực. Vui lòng kiểm tra và bàn giao.
        </div>
    </c:if>
    
    <c:if test="${param.success}">
        <div style="color: green; padding: 10px; background-color: #d4edda; margin-bottom: 20px;">
            Thao tác thành công!
        </div>
    </c:if>
    
    <c:if test="${empty rentalOrders}">
        <div style="background: white; padding: 40px; text-align: center; color: #666; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            Không có đơn đặt thuê nào
        </div>
    </c:if>
    
    <c:if test="${not empty rentalOrders}">
    <table>
        <thead>
            <tr>
                <th>Mã đơn hàng</th>
                <th>Quần áo</th>
                <th>Người thuê</th>
                <th>Ngày bắt đầu</th>
                <th>Ngày kết thúc</th>
                <th>Tổng giá</th>
                <th>Trạng thái</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="order" items="${rentalOrders}">
                <tr>
                    <td>${order.orderCode}</td>
                    <td>
                        <c:choose>
                            <c:when test="${not empty order.clothingName}">${order.clothingName}</c:when>
                            <c:otherwise>${order.clothingID}</c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${not empty order.renterUsername}">
                                <strong>${order.renterUsername}</strong>
                                <c:if test="${order.status == 'PAYMENT_VERIFIED'}">
                                    <div class="renter-info">
                                        <div><strong>Họ tên:</strong> ${order.renterFullName}</div>
                                        <div><strong>SĐT:</strong> ${order.renterPhone}</div>
                                        <div><strong>Email:</strong> ${order.renterEmail}</div>
                                        <div><strong>Địa chỉ:</strong> ${order.renterAddress}</div>
                                    </div>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                ID: ${order.renterUserID}
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>${order.formattedStartDate}</td>
                    <td>${order.formattedEndDate}</td>
                    <td><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> VNĐ</td>
                    <td>
                        <span class="status ${order.status.toLowerCase()}">
                            <c:choose>
                                <c:when test="${order.status == 'PENDING'}">Chờ duyệt</c:when>
                                <c:when test="${order.status == 'VERIFYING'}">Đang xác thực</c:when>
                                <c:when test="${order.status == 'CONFIRMED'}">Đã xác nhận</c:when>
                                <c:when test="${order.status == 'RENTED'}">Đang thuê</c:when>
                                <c:when test="${order.status == 'RETURNED'}">Đã trả hàng</c:when>
                                <c:when test="${order.status == 'ISSUE'}">Có vấn đề</c:when>
                                <c:when test="${order.status == 'COMPLETED'}">Hoàn thành</c:when>
                                <c:when test="${order.status == 'CANCELLED'}">✗ Đã hủy</c:when>
                                <c:otherwise>${order.status}</c:otherwise>
                            </c:choose>
                        </span>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/rental?action=viewOrder&id=${order.rentalOrderID}" class="btn btn-info">Chi tiết</a>
                        <c:if test="${order.status == 'PAYMENT_VERIFIED'}">
                            <form method="POST" action="${pageContext.request.contextPath}/manager" style="display:inline-block;">
                                <input type="hidden" name="action" value="shipOrder" />
                                <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                                <input type="text" name="trackingNumber" placeholder="Mã tracking" required style="padding:6px 8px; margin-right:6px;" />
                                <button type="submit" class="btn btn-success">Bàn giao (Gửi)</button>
                            </form>
                        </c:if>
                        <c:if test="${order.status == 'SHIPPING'}">
                            <form method="POST" action="${pageContext.request.contextPath}/manager" style="display:inline-block;">
                                <input type="hidden" name="action" value="confirmDelivery" />
                                <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                                <button type="submit" class="btn btn-success">Xác nhận đã giao</button>
                            </form>
                        </c:if>
                        <c:if test="${order.status == 'RENTED'}">
                            <form method="POST" action="${pageContext.request.contextPath}/manager" style="display:inline-block;">
                                <input type="hidden" name="action" value="updateStatus" />
                                <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                                <input type="hidden" name="status" value="RETURNED" />
                                <button type="submit" class="btn btn-secondary">Đã nhận lại</button>
                            </form>
                        </c:if>
                        <c:if test="${order.status == 'RETURNED'}">
                            <form method="POST" action="${pageContext.request.contextPath}/manager" style="display:inline-block;">
                                <input type="hidden" name="action" value="updateStatus" />
                                <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                                <input type="hidden" name="status" value="COMPLETED" />
                                <button type="submit" class="btn btn-success">Đã nhận hàng (hoàn tất)</button>
                            </form>
                        </c:if>
                        <c:if test="${order.status == 'COMPLETED'}">
                            <c:choose>
                                <c:when test="${ratedMap[order.rentalOrderID]}">
                                    <button type="button" class="btn btn-secondary" disabled style="margin-left:8px;opacity:0.6">Đã đánh giá</button>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="btn btn-info rating-btn" data-toggle-row="${order.rentalOrderID}" style="margin-left:8px;">Đánh giá người thuê</button>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                        <c:if test="${order.status == 'ISSUE'}">
                            <a href="${pageContext.request.contextPath}/manager?action=viewIssue&id=${order.rentalOrderID}" class="btn btn-info">Xem vấn đề</a>
                            <form method="POST" action="${pageContext.request.contextPath}/manager" style="display:inline-block;">
                                <input type="hidden" name="action" value="updateStatus" />
                                <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                                <input type="hidden" name="status" value="CANCELLED" />
                                <button type="submit" class="btn btn-danger">Hủy đơn hàng</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />

<!-- Rating Modal -->
<div id="ratingModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Đánh giá người thuê</h2>
            <button type="button" class="modal-close" onclick="closeRatingModal()">&times;</button>
        </div>
        <form id="ratingForm">
            <input type="hidden" id="rentalOrderID" />
            
            <div class="form-group">
                <label>Đánh giá:</label>
                <div class="rating-stars">
                    <input type="radio" id="star5" name="rating" value="5" />
                    <label for="star5">★</label>
                    <input type="radio" id="star4" name="rating" value="4" />
                    <label for="star4">★</label>
                    <input type="radio" id="star3" name="rating" value="3" />
                    <label for="star3">★</label>
                    <input type="radio" id="star2" name="rating" value="2" />
                    <label for="star2">★</label>
                    <input type="radio" id="star1" name="rating" value="1" />
                    <label for="star1">★</label>
                </div>
            </div>
            
            <div class="form-group">
                <label for="managerNotes">Ghi chú:</label>
                <textarea id="managerNotes" name="managerNotes" placeholder="Nhập ghi chú của bạn về người thuê..."></textarea>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeRatingModal()">Hủy</button>
                <button type="button" class="btn btn-success" onclick="submitRating()">Gửi đánh giá</button>
            </div>
        </form>
    </div>
</div>

<script>
    function submitRating() {
        const rentalOrderID = document.getElementById('rentalOrderID').value;
        const ratingValue = document.querySelector('input[name="rating"]:checked');
        const managerNotes = document.getElementById('managerNotes').value;
        
        if (!ratingValue) {
            alert('Vui lòng chọn số sao!');
            return;
        }
        
        const formData = new FormData();
        formData.append('action', 'saveManagerRating');
        formData.append('rentalOrderID', rentalOrderID);
        formData.append('rating', ratingValue.value);
        formData.append('managerNotes', managerNotes);
        
        fetch('<%= request.getContextPath() %>/manager', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (response.ok) {
                alert('Đánh giá được lưu thành công!');
                closeRatingModal();
                
                // Update UI: find and replace rating button with disabled button
                const ratingBtn = document.querySelector(`.rating-btn[data-toggle-row="${rentalOrderID}"]`);
                if (ratingBtn) {
                    const disabledBtn = document.createElement('button');
                    disabledBtn.type = 'button';
                    disabledBtn.className = 'btn btn-secondary';
                    disabledBtn.disabled = true;
                    disabledBtn.style.marginLeft = '8px';
                    disabledBtn.style.opacity = '0.6';
                    disabledBtn.textContent = 'Đã đánh giá';
                    ratingBtn.replaceWith(disabledBtn);
                }
            } else {
                alert('Có lỗi xảy ra. Vui lòng thử lại!');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra. Vui lòng thử lại!');
        });
    }
    
    function openRatingModal(rentalOrderID) {
        document.getElementById('rentalOrderID').value = rentalOrderID;
        document.getElementById('ratingForm').reset();
        document.getElementById('ratingModal').classList.add('show');
    }
    
    function closeRatingModal() {
        document.getElementById('ratingModal').classList.remove('show');
    }
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('ratingModal');
        if (event.target === modal) {
            closeRatingModal();
        }
    }
    
    // Update rating button click handlers
    document.querySelectorAll('.rating-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const rentalOrderID = this.getAttribute('data-toggle-row');
            openRatingModal(rentalOrderID);
        });
    });
</script>
</body>
</html>
<!-- Manager rating UI removed: manager cannot rate renters from this page. -->
