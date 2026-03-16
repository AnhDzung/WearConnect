<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Color" %>
<%@ page import="Model.Clothing" %>
<%@ page import="DAO.ColorDAO" %>
<%@ page import="DAO.ClothingDAO" %>
<%
    int clothingID = 0;
    Clothing clothing = null;
    boolean isCosplay = false;
    String[] availableSizes = new String[0];
    try {
        clothingID = Integer.parseInt(request.getParameter("clothingID") != null ? request.getParameter("clothingID") : "0");
        if (clothingID > 0) {
            clothing = ClothingDAO.getClothingByID(clothingID);
            if (clothing != null) {
                isCosplay = "Cosplay".equalsIgnoreCase(clothing.getCategory());
                String sizeStr = clothing.getSize();
                if (sizeStr != null && !sizeStr.trim().isEmpty()) {
                    availableSizes = sizeStr.split(",\\s*");
                }
            }
        }
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
        <input type="hidden" name="itemValue" value="${itemValue}">
        <input type="hidden" id="isCosplayInput" name="isCosplay" value="<%= isCosplay %>">
        
        <% if (isCosplay) { %>
        <!-- Thông báo cho cosplay -->
        <div style="background-color: #d1ecf1; border: 1px solid #bee5eb; border-radius: 5px; padding: 12px; margin-bottom: 20px; color: #0c5460;">
            <strong>Sản phẩm Cosplay:</strong> Vui lòng chọn size phù hợp. Sản phẩm cosplay không hỗ trợ chọn màu sắc.
        </div>
        <% } %>

        <!-- Chọn size -->
        <div class="form-group">
            <label for="selectedSize">Chọn size phù hợp: <span style="color: red;">*</span></label>
            <select id="selectedSize" name="selectedSize">
                <option value="">-- Chọn size --</option>
                <% if (availableSizes != null && availableSizes.length > 0) { %>
                    <% for (String sizeOption : availableSizes) { 
                        String trimmedSize = sizeOption != null ? sizeOption.trim() : "";
                        if (!trimmedSize.isEmpty()) {
                    %>
                    <option value="<%= trimmedSize %>"><%= trimmedSize %></option>
                    <%  }
                    } %>
                <% } else { %>
                    <option value="XS">XS</option>
                    <option value="S">S</option>
                    <option value="M">M</option>
                    <option value="L">L</option>
                    <option value="XL">XL</option>
                    <option value="XXL">XXL</option>
                    <option value="One Size">One Size</option>
                <% } %>
            </select>
        </div>

        <% if (!isCosplay) { %>
        <!-- Chọn màu sắc -->
        <div class="form-group">
            <label for="selectedColor">Chọn màu sắc:</label>
            <select id="selectedColor" name="selectedColor">
                <option value="">-- Không chọn màu (nếu có) --</option>
                <% for (Color color : availableColors) { %>
                <option value="<%= color.getColorID() %>">
                    <%= color.getColorName() %>
                </option>
                <% } %>
            </select>
            <% if (availableColors.isEmpty()) { %>
                <small style="color: #999; display: block; margin-top: 5px;">Sản phẩm này không có lựa chọn màu sắc</small>
            <% } %>
        </div>
        <% } // End if (!isCosplay) %>
        
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
                <label for="hourlyStartDate">Ngày giờ bắt đầu: <span style="color: red;">*</span></label>
                <input type="datetime-local" id="hourlyStartDate" name="startDate" onchange="calculatePrice()">
            </div>
            
            <div class="form-group">
                <label for="hourlyEndDate">Ngày giờ kết thúc: <span style="color: red;">*</span></label>
                <input type="datetime-local" id="hourlyEndDate" name="endDate" onchange="calculatePrice()">
            </div>
        </div>
        
        <!-- Phần thuê theo ngày -->
        <div id="dailySection" class="form-section">
            <div class="form-group">
                <label for="dailyStartDate">Ngày bắt đầu: <span style="color: red;">*</span></label>
                <input type="date" id="dailyStartDate" name="dailyStartDate" onchange="calculatePrice()">
            </div>
            
            <div class="form-group">
                <label for="dailyEndDate">Ngày kết thúc: <span style="color: red;">*</span></label>
                <input type="date" id="dailyEndDate" name="dailyEndDate" onchange="calculatePrice()">
            </div>
        </div>
        
        <div class="price-summary">
            <p><strong>Tổng giá thuê:</strong> <span id="rentalFee">0</span> VNĐ</p>
            <p><strong>Tiền cọc:</strong> <span id="depositAmount">0</span> VNĐ</p>
            <p style="color: #d9534f; font-weight: bold; border-top: 1px solid #ddd; padding-top: 10px; margin-top: 10px;"><strong>Số tiền phải thanh toán:</strong> <span id="paymentAmount">0</span> VNĐ</p>
            <small style="color: #666; display: block; margin-top: 10px;">Bạn sẽ thanh toán tổng tiền thuê + tiền cọc. Tiền cọc sẽ được hoàn lại sau khi trả hàng và sản phẩm không có lỗi gì.</small>
            <!-- <small style="color: #2e7d32; display: block; margin-top: 8px;"><strong>💡 Mẹo:</strong> Nếu bạn có độ tin tưởng cao (uy tín từ những lần thuê trước), tiền cọc sẽ được giảm tự động ở phần thanh toán!</small> -->
        </div>
        
        <button type="submit" onclick="return validateForm()">Tiến hành thanh toán</button>
        <button type="button" onclick="history.back()">Quay lại</button>
    </form>
</div>

<script>
    const HOURLY_PRICE = Number('${hourlyPrice}');
    const DAILY_PRICE = Number('${dailyPrice}');
    const ITEM_VALUE = Number('${itemValue}');
    
    function calculateDeposit(hours, rentalType) {
        if (hours <= 0) return 0;
        
        if (rentalType === 'hourly') {
            // Hourly: MAX(40% × itemValue, 2 × hourlyPrice)
            const percentBased = ITEM_VALUE * 0.40;
            const priceBased = HOURLY_PRICE * 2;
            return Math.max(percentBased, priceBased);
        } else {
            // Daily: MAX(30% × itemValue, 0.5 × dailyPrice)
            const days = hours; // hours is already in days for daily rental
            const percentBased = ITEM_VALUE * 0.30 * days;
            const priceBased = DAILY_PRICE * 0.5 * days;
            return Math.max(percentBased, priceBased);
        }
    }
    
    function validateForm() {
        const rentalType = document.querySelector('input[name="rentalType"]:checked').value;
        const selectedSize = document.getElementById('selectedSize').value;
        if (!selectedSize || selectedSize.trim() === '') {
            alert('Vui lòng chọn size');
            return false;
        }
        
        // Validate datetime inputs
        if (rentalType === 'hourly') {
            const startDate = document.getElementById('hourlyStartDate').value;
            const endDate = document.getElementById('hourlyEndDate').value;
            if (!startDate || !endDate) {
                alert('Vui lòng nhập đầy đủ ngày giờ bắt đầu và kết thúc');
                return false;
            }
            // Compare datetime strings directly (format YYYY-MM-DDTHH:mm is lexicographically sorted)
            if (startDate >= endDate) {
                alert('Ngày giờ kết thúc phải sau ngày giờ bắt đầu');
                return false;
            }
        } else {
            const startDate = document.getElementById('dailyStartDate').value;
            const endDate = document.getElementById('dailyEndDate').value;
            if (!startDate || !endDate) {
                alert('Vui lòng nhập đầy đủ ngày bắt đầu và kết thúc');
                return false;
            }
            // Compare date strings directly (format YYYY-MM-DD is lexicographically sorted)
            if (startDate >= endDate) {
                alert('Ngày kết thúc phải sau ngày bắt đầu');
                return false;
            }
        }
        return true;
    }
    
    function toggleRentalType() {
        const rentalType = document.querySelector('input[name="rentalType"]:checked').value;
        const hourlySection = document.getElementById('hourlySection');
        const dailySection = document.getElementById('dailySection');
        
        if (rentalType === 'hourly') {
            hourlySection.classList.add('active');
            dailySection.classList.remove('active');
            document.getElementById('hourlyStartDate').required = true;
            document.getElementById('hourlyEndDate').required = true;
            document.getElementById('dailyStartDate').required = false;
            document.getElementById('dailyEndDate').required = false;

            document.getElementById('hourlyStartDate').disabled = false;
            document.getElementById('hourlyEndDate').disabled = false;
            document.getElementById('dailyStartDate').disabled = true;
            document.getElementById('dailyEndDate').disabled = true;
        } else {
            hourlySection.classList.remove('active');
            dailySection.classList.add('active');
            document.getElementById('hourlyStartDate').required = false;
            document.getElementById('hourlyEndDate').required = false;
            document.getElementById('dailyStartDate').required = true;
            document.getElementById('dailyEndDate').required = true;

            document.getElementById('hourlyStartDate').disabled = true;
            document.getElementById('hourlyEndDate').disabled = true;
            document.getElementById('dailyStartDate').disabled = false;
            document.getElementById('dailyEndDate').disabled = false;
        }
        
        calculatePrice();
    }

    // Initialize correct required/disabled state on first load
    window.addEventListener('DOMContentLoaded', function() {
        toggleRentalType();
    });

    function calculatePrice() {
        const rentalType = document.querySelector('input[name="rentalType"]:checked').value;
        let rentalPrice = 0;
        let depositPrice = 0;

        if (rentalType === 'hourly') {
            const rawStart = document.getElementById('hourlyStartDate').value;
            const rawEnd = document.getElementById('hourlyEndDate').value;
            
            if (rawStart && rawEnd && rawStart < rawEnd) {
                const start = new Date(rawStart);
                const end = new Date(rawEnd);
                const hours = (end - start) / (1000 * 60 * 60);
                rentalPrice = hours * HOURLY_PRICE;
                depositPrice = calculateDeposit(hours, 'hourly');
            }
        } else {
            const rawStart = document.getElementById('dailyStartDate').value;
            const rawEnd = document.getElementById('dailyEndDate').value;
            
            if (rawStart && rawEnd && rawStart < rawEnd) {
                const start = new Date(rawStart);
                const end = new Date(rawEnd);
                const timeDiff = end - start;
                const days = timeDiff / (1000 * 60 * 60 * 24);
                rentalPrice = days * DAILY_PRICE;
                depositPrice = calculateDeposit(days, 'daily');
            }
        }

        const totalPayment = rentalPrice + depositPrice;

        document.getElementById('rentalFee').textContent = (isFinite(rentalPrice) && rentalPrice > 0) ? Math.round(rentalPrice).toLocaleString('vi-VN') : '0';
        document.getElementById('depositAmount').textContent = (isFinite(depositPrice) && depositPrice > 0) ? Math.round(depositPrice).toLocaleString('vi-VN') : '0';
        document.getElementById('paymentAmount').textContent = (isFinite(totalPayment) && totalPayment > 0) ? Math.round(totalPayment).toLocaleString('vi-VN') : '0';
    }
</script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
