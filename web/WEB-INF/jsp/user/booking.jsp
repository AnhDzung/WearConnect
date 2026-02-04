<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Color" %>
<%@ page import="DAO.ColorDAO" %>
<%
    int clothingID = 0;
    try {
        clothingID = Integer.parseInt(request.getParameter("clothingID") != null ? request.getParameter("clothingID") : "0");
    } catch (Exception e) {}
    List<Color> availableColors = clothingID > 0 ? ColorDAO.getColorsByClothing(clothingID) : new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Đặt thuê - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .form-container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; background: white; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { padding: 10px 20px; background-color: #28a745; color: white; border: none; cursor: pointer; margin-right: 10px; border-radius: 4px; }
        button:hover { background-color: #218838; }
        .price-summary { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin-top: 20px; }
        .rental-type-group { display: flex; gap: 20px; margin-bottom: 15px; }
        .rental-type-group label { display: flex; align-items: center; margin: 0; width: auto; }
        .rental-type-group input[type="radio"] { width: auto; margin-right: 5px; }
        .form-section { display: none; }
        .form-section.active { display: block; }
        .color-option { padding: 8px; margin: 5px 0; border: 1px solid #ddd; border-radius: 4px; }
        .color-swatch { display: inline-block; width: 20px; height: 20px; border-radius: 3px; border: 1px solid #999; margin-right: 8px; vertical-align: middle; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="form-container">
    <h1>Đặt thuê quần áo</h1>
    
    <!-- Error message for unavailability -->
    <c:if test="${not empty error and error == 'notAvailable'}">
        <div style="background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 5px; padding: 15px; margin-bottom: 20px; color: #856404;">
            <h3 style="margin-top: 0; color: #d9534f;">Không đủ số lượng</h3>
            <p><strong>Tất cả sản phẩm cùng loại này đã được thuê hết trong khoảng thời gian bạn chọn.</strong></p>
            
            <c:if test="${not empty requestedStartDateDate}">
                <p>Thời gian bạn yêu cầu: 
                    <fmt:formatDate value="${requestedStartDateDate}" pattern="dd/MM/yyyy HH:mm" /> 
                    đến 
                    <fmt:formatDate value="${requestedEndDateDate}" pattern="dd/MM/yyyy HH:mm" />
                </p>
            </c:if>
            
            <c:if test="${not empty conflictingOrders}">
                <div style="background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; padding: 10px; margin: 10px 0;">
                    <p style="margin: 5px 0; color: #721c24; font-weight: bold;">
                        Tình trạng: <span style="color: #d9534f;">${conflictingOrders.size()} sản phẩm</span> đang được thuê trong thời gian này
                    </p>
                    <c:if test="${availableQuantity != null}">
                        <p style="margin: 5px 0; color: #721c24;">
                            Số lượng còn lại: <strong>${availableQuantity}</strong> sản phẩm
                        </p>
                    </c:if>
                </div>
                <h4 style="margin-bottom: 10px;">Các đơn thuê đang xung đột:</h4>
                <ul style="margin: 10px 0; padding-left: 20px;">
                    <c:forEach items="${conflictingOrders}" var="order">
                        <li style="margin-bottom: 8px;">
                            <strong>Đơn #${order.rentalOrderID}</strong> - 
                            ${order.formattedStartDate} 
                            đến 
                            ${order.formattedEndDate}
                            <span style="color: #28a745; font-weight: bold;">(${order.status})</span>
                        </li>
                    </c:forEach>
                </ul>
                
                <div style="background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; padding: 10px; margin-top: 15px;">
                    <h4 style="margin-top: 0; color: #155724;">💡 Đề xuất thời gian:</h4>
                    <p style="margin: 5px 0; color: #155724;">
                        • Chọn thời gian <strong>trước</strong> ${conflictingOrders[0].formattedStartDate}
                        <br>
                        • Hoặc chọn thời gian <strong>sau</strong> 
                        <c:set var="lastOrder" value="${conflictingOrders[conflictingOrders.size() - 1]}" />
                        ${lastOrder.formattedEndDate}
                    </p>
                </div>
            </c:if>
            
            <p style="margin-top: 15px; margin-bottom: 0;">Vui lòng chọn khoảng thời gian khác bên dưới.</p>
        </div>
    </c:if>
    
    <form method="POST" action="${pageContext.request.contextPath}/rental">
        <input type="hidden" name="action" value="createOrder">
        <input type="hidden" name="clothingID" value="${clothingID}">
        <input type="hidden" name="hourlyPrice" value="${hourlyPrice}">
        <input type="hidden" name="dailyPrice" value="${dailyPrice}">
        <input type="hidden" id="rentalTypeInput" name="rentalType" value="hourly">
        
        <!-- Chọn size -->
        <div class="form-group">
            <label for="selectedSize">Chọn size phù hợp:</label>
            <select id="selectedSize" name="selectedSize" required>
                <option value="">-- Chọn size --</option>
                <option value="XS">XS</option>
                <option value="S">S</option>
                <option value="M">M</option>
                <option value="L">L</option>
                <option value="XL">XL</option>
                <option value="XXL">XXL</option>
                <option value="One Size">One Size</option>
            </select>
        </div>
        
        <!-- Chọn màu sắc -->
        <div class="form-group">
            <label for="selectedColor">Chọn màu sắc:</label>
            <select id="selectedColor" name="selectedColor">
                <option value="">-- Không chọn màu (nếu có) --</option>
                <% for (Color color : availableColors) { %>
                <option value="<%= color.getColorID() %>">
                    <span style="color: <%= color.getHexCode() != null ? color.getHexCode() : "#999" %>;">●</span>
                    <%= color.getColorName() %>
                </option>
                <% } %>
            </select>
            <% if (availableColors.isEmpty()) { %>
                <small style="color: #999; display: block; margin-top: 5px;">Sản phẩm này không có lựa chọn màu sắc</small>
            <% } %>
        </div>
        
        <!-- Lựa chọn loại thuê -->
        <div class="form-group">
            <label>Chọn loại thuê:</label>
            <div class="rental-type-group">
                <label>
                    <input type="radio" name="rentalType" value="hourly" checked onchange="toggleRentalType()">
                    Thuê theo giờ
                </label>
                <label>
                    <input type="radio" name="rentalType" value="daily" onchange="toggleRentalType()">
                    Thuê theo ngày
                </label>
            </div>
        </div>
        
        <!-- Phần thuê theo giờ -->
        <div id="hourlySection" class="form-section active">
            <div class="form-group">
                <label for="hourlyStartDate">Ngày giờ bắt đầu:</label>
                <input type="datetime-local" id="hourlyStartDate" name="startDate" required onchange="calculatePrice()">
            </div>
            
            <div class="form-group">
                <label for="hourlyEndDate">Ngày giờ kết thúc:</label>
                <input type="datetime-local" id="hourlyEndDate" name="endDate" required onchange="calculatePrice()">
            </div>
        </div>
        
        <!-- Phần thuê theo ngày -->
        <div id="dailySection" class="form-section">
            <div class="form-group">
                <label for="dailyStartDate">Ngày bắt đầu:</label>
                <input type="date" id="dailyStartDate" name="dailyStartDate" required onchange="calculatePrice()">
            </div>
            
            <div class="form-group">
                <label for="dailyEndDate">Ngày kết thúc:</label>
                <input type="date" id="dailyEndDate" name="dailyEndDate" required onchange="calculatePrice()">
            </div>
        </div>
        
        <div class="price-summary">
            <p><strong>Tổng giá:</strong> <span id="totalPrice">0</span> VNĐ</p>
            <p style="color: #d9534f; font-weight: bold;"><strong>Số tiền phải thanh toán:</strong> <span id="paymentAmount">0</span> VNĐ</p>
            <small style="color: #666;">Bạn sẽ thanh toán 100% tổng tiền thuê khi đặt hàng.</small>
        </div>
        
        <button type="submit">Tiến hành thanh toán</button>
        <button type="button" onclick="history.back()">Quay lại</button>
    </form>
</div>

<script>
    const HOURLY_PRICE = Number('${hourlyPrice}');
    const DAILY_PRICE = Number('${dailyPrice}');
    
    function toggleRentalType() {
        const rentalType = document.querySelector('input[name="rentalType"]:checked').value;
        const hourlySection = document.getElementById('hourlySection');
        const dailySection = document.getElementById('dailySection');
        
        // Update hidden input
        document.getElementById('rentalTypeInput').value = rentalType;
        
        if (rentalType === 'hourly') {
            hourlySection.classList.add('active');
            dailySection.classList.remove('active');
            document.getElementById('hourlyStartDate').required = true;
            document.getElementById('hourlyEndDate').required = true;
            document.getElementById('dailyStartDate').required = false;
            document.getElementById('dailyEndDate').required = false;
        } else {
            hourlySection.classList.remove('active');
            dailySection.classList.add('active');
            document.getElementById('hourlyStartDate').required = false;
            document.getElementById('hourlyEndDate').required = false;
            document.getElementById('dailyStartDate').required = true;
            document.getElementById('dailyEndDate').required = true;
        }
        
        calculatePrice();
    }
    
    function parseFlexibleDate(value) {
        if (!value) return null;
        // Try direct parse (ISO format from datetime-local / date inputs)
        let d = new Date(value);
        if (!isNaN(d.getTime())) return d;

        // Try parse common localized format: dd/MM/yyyy HH:mm [AM|PM]
        // Examples: "02/04/2026 11:43 AM" or "02/04/2026 11:43"
        const m = value.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})\s+(\d{1,2}):(\d{2})(?:\s*(AM|PM))?/i);
        if (m) {
            let day = parseInt(m[1], 10);
            let month = parseInt(m[2], 10) - 1;
            let year = parseInt(m[3], 10);
            let hour = parseInt(m[4], 10);
            let minute = parseInt(m[5], 10);
            let ampm = m[6];
            if (ampm) {
                ampm = ampm.toUpperCase();
                if (ampm === 'PM' && hour < 12) hour += 12;
                if (ampm === 'AM' && hour === 12) hour = 0;
            }
            return new Date(year, month, day, hour, minute);
        }

        // Fallback: invalid date
        return null;
    }

    function calculatePrice() {
        const rentalType = document.querySelector('input[name="rentalType"]:checked').value;
        let totalPrice = 0;

        if (rentalType === 'hourly') {
            const rawStart = document.getElementById('hourlyStartDate').value;
            const rawEnd = document.getElementById('hourlyEndDate').value;
            const startDate = parseFlexibleDate(rawStart);
            const endDate = parseFlexibleDate(rawEnd);

            if (startDate instanceof Date && endDate instanceof Date && !isNaN(startDate.getTime()) && !isNaN(endDate.getTime()) && startDate < endDate) {
                const hours = (endDate - startDate) / (1000 * 60 * 60);
                totalPrice = hours * HOURLY_PRICE;
            }
        } else {
            // daily inputs usually provide yyyy-mm-dd which Date() handles
            const rawStart = document.getElementById('dailyStartDate').value;
            const rawEnd = document.getElementById('dailyEndDate').value;
            const startDate = parseFlexibleDate(rawStart) || new Date(rawStart);
            const endDate = parseFlexibleDate(rawEnd) || new Date(rawEnd);

            if (startDate instanceof Date && endDate instanceof Date && !isNaN(startDate.getTime()) && !isNaN(endDate.getTime()) && startDate < endDate) {
                const timeDiff = endDate - startDate;
                const days = timeDiff / (1000 * 60 * 60 * 24);
                totalPrice = days * DAILY_PRICE;
            }
        }

        const paymentAmount = totalPrice; // 100% payment

        document.getElementById('totalPrice').textContent = (isFinite(totalPrice) && totalPrice > 0) ? Math.round(totalPrice).toLocaleString('vi-VN') : '0';
        document.getElementById('paymentAmount').textContent = (isFinite(paymentAmount) && paymentAmount > 0) ? Math.round(paymentAmount).toLocaleString('vi-VN') : '0';
    }
</script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
