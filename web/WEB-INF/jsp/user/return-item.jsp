<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Trả hàng - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 700px; margin: 20px auto; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; color: #333; }
        input, select, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; box-sizing: border-box; }
        textarea { resize: vertical; min-height: 100px; }
        .radio-group { display: flex; gap: 20px; margin-top: 10px; }
        .radio-option { display: flex; align-items: center; }
        .radio-option input { width: auto; margin-right: 8px; }
        .damage-section { display: none; margin-top: 15px; padding: 15px; background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 4px; }
        .damage-section.show { display: block; }
        .info-box { background-color: #e8f4f8; border: 1px solid #b8e0e8; padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .info-box h4 { margin-top: 0; color: #0c5460; }
        .info-box p { margin: 8px 0; }
        .btn-group { display: flex; gap: 10px; margin-top: 20px; }
        button { padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold; }
        .btn-submit { background-color: #28a745; color: white; flex: 1; }
        .btn-submit:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; color: white; flex: 1; }
        .btn-cancel:hover { background-color: #5a6268; }
        .order-info { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
        .info-item { padding: 10px; background-color: #f9f9f9; border-radius: 4px; }
        .info-label { font-size: 12px; color: #666; font-weight: bold; }
        .info-value { font-size: 16px; color: #333; margin-top: 5px; }
    </style>
    <script>
        function onReturnStatusChange() {
            const status = document.getElementById('returnStatus').value;
            const damageSection = document.getElementById('damageSection');
            
            if (status === 'MINOR_DAMAGE') {
                damageSection.classList.add('show');
                document.getElementById('damagePercentage').required = true;
            } else {
                damageSection.classList.remove('show');
                document.getElementById('damagePercentage').required = false;
            }
        }
        
        function submitReturn() {
            const form = document.getElementById('returnForm');
            if (form.checkValidity() === false) {
                alert('Vui lòng điền đầy đủ thông tin');
                return;
            }
            form.submit();
        }
    </script>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>📦 Trả Hàng & Hoàn Lại Cọc</h1>
    
    <c:if test="${order != null}">
        <!-- Order Information -->
        <div class="info-box">
            <h4>Thông tin đơn hàng</h4>
            <div class="order-info">
                <div class="info-item">
                    <div class="info-label">Mã đơn hàng</div>
                    <div class="info-value">${order.orderCode}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Tên sản phẩm</div>
                    <div class="info-value">${order.clothingName}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Ngày kết thúc thuê</div>
                    <div class="info-value">${order.formattedEndDate}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Tiền cọc đã thanh toán</div>
                    <div class="info-value"><fmt:formatNumber value="${order.adjustedDepositAmount}" pattern="#,###" /> ₫</div>
                </div>
            </div>
        </div>
        
        <!-- Return Form -->
        <form id="returnForm" method="POST" action="${pageContext.request.contextPath}/return">
            <input type="hidden" name="action" value="submitReturn">
            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}">
            
            <!-- Return Status -->
            <div class="form-group">
                <label for="returnStatus">Tình trạng sản phẩm: *</label>
                <select id="returnStatus" name="returnStatus" required onchange="onReturnStatusChange()">
                    <option value="">-- Chọn tình trạng --</option>
                    <option value="NO_DAMAGE">✓ Không hư hỏng (Hoàn 100% cọc)</option>
                    <option value="LATE_RETURN">⏰ Trả trễ (<= 1 ngày: 10% giá trị SP, > 1 ngày: 30%)</option>
                    <option value="MINOR_DAMAGE">⚠️ Hư hỏng nhẹ (Trừ bồi thường)</option>
                    <option value="LOST">❌ Mất đồ (Trừ giá trị sản phẩm)</option>
                </select>
            </div>
            
            <!-- Damage Details (shown only for MINOR_DAMAGE) -->
            <div id="damageSection" class="damage-section">
                <div class="form-group">
                    <label for="damagePercentage">Mức độ hư hỏng (%): *</label>
                    <input type="number" id="damagePercentage" name="damagePercentage" 
                           min="0" max="100" step="5" placeholder="VD: 20">
                    <small>Nhập phần trăm hư hỏng (0-100%)</small>
                </div>
                <div class="form-group">
                    <label for="damageDescription">Mô tả chi tiết hư hỏng:</label>
                    <textarea id="damageDescription" name="damageDescription" 
                              placeholder="Vị trí, loại hư hỏng..."></textarea>
                </div>
            </div>
            
            <!-- Additional Notes -->
            <div class="form-group">
                <label for="returnNotes">Ghi chú thêm:</label>
                <textarea id="returnNotes" name="returnNotes" 
                          placeholder="Ví dụ: Sản phẩm sạch sẽ, không mùi..."></textarea>
            </div>
            
            <!-- Action Buttons -->
            <div class="btn-group">
                <button type="button" class="btn-cancel" onclick="window.history.back()">Hủy</button>
                <button type="button" class="btn-submit" onclick="submitReturn()">Xác nhận trả hàng</button>
            </div>
        </form>
        
        <!-- Return Information -->
        <div class="info-box" style="margin-top: 30px;">
            <h4>ℹ️ Hướng dẫn trả hàng</h4>
            <p><strong>1. Kiểm tra tình trạng sản phẩm:</strong> Trước khi trả, hãy kiểm tra kỹ tình trạng quần áo</p>
            <p><strong>2. Chọn tình trạng phù hợp:</strong></p>
            <ul>
                <li><strong>Không hư hỏng:</strong> Quần áo nguyên vẹn, sạch sẽ → Hoàn 100% cọc</li>
                <li><strong>Trả trễ:</strong> Trả sau thời hạn → Trễ dưới hoặc bằng 1 ngày thu 10% giá trị sản phẩm, trễ trên 1 ngày thu 30% giá trị sản phẩm</li>
                <li><strong>Hư hỏng nhẹ:</strong> Vết nhỏ, xước, phai → Chi trả bồi thường tương ứng</li>
                <li><strong>Mất đồ:</strong> Không tìm thấy hoặc hư hỏng nặng → Thu toàn bộ giá trị</li>
            </ul>
            <p><strong>3. Hóa đơn:</strong> Sau khi trả, bạn sẽ nhận được chi tiết hoàn lại cọc trong 24 giờ</p>
        </div>
        
    </c:if>
    
    <c:if test="${order == null}">
        <div class="alert alert-danger">
            <strong>Lỗi:</strong> Không tìm thấy thông tin đơn hàng
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
