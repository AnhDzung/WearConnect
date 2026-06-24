<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Color" %>
<%@ page import="Model.Clothing" %>
<%@ page import="DAO.ColorDAO" %>
<%@ page import="DAO.ClothingDAO" %>
<%@ page import="config.DepositCalculationConfig" %>
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
<c:set var="isAddToCart" value="${param.addToCart eq 'true'}" />
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Đặt thuê - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            background:
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.12), transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(6, 182, 212, 0.08), transparent 45%),
                linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%) !important;
        }

        .booking-layout {
            display: grid;
            grid-template-columns: 1fr 1.2fr;
            gap: 30px;
            margin-top: 30px;
            margin-bottom: 50px;
            align-items: start;
        }

        @media (max-width: 992px) {
            .booking-layout {
                grid-template-columns: 1fr;
                gap: 20px;
                margin-top: 15px;
            }
        }

        .booking-product-card {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            padding: var(--spacing-2xl);
            box-shadow: var(--shadow-lg);
        }

        .product-image-wrapper {
            position: relative;
            border-radius: var(--radius-md);
            overflow: hidden;
            aspect-ratio: 4/5;
            background-color: var(--gray-100);
            margin-bottom: 20px;
            box-shadow: var(--shadow-md);
        }

        .product-image-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform var(--transition-slow);
        }

        .product-image-wrapper:hover img {
            transform: scale(1.05);
        }

        .category-badge {
            position: absolute;
            top: 15px;
            left: 15px;
            background: var(--primary-gradient);
            color: white;
            padding: 6px 14px;
            border-radius: var(--radius-full);
            font-size: var(--font-size-xs);
            font-weight: 800;
            letter-spacing: 0.5px;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
        }

        .product-title {
            font-family: var(--heading-font-family);
            font-size: var(--font-size-2xl);
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 12px;
        }

        .product-meta-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 15px;
        }

        .product-meta-item {
            background: rgba(99, 102, 241, 0.08);
            color: var(--primary-color);
            padding: 6px 14px;
            border-radius: var(--radius-full);
            font-size: var(--font-size-xs);
            font-weight: 700;
        }

        .pricing-card {
            background: rgba(255, 255, 255, 0.5);
            border: 1px dashed var(--gray-300);
            border-radius: var(--radius-md);
            padding: 16px;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }

        .pricing-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .pricing-label {
            font-size: var(--font-size-xs);
            color: var(--gray-500);
            font-weight: 600;
        }

        .pricing-value {
            font-size: var(--font-size-xl);
            font-weight: 800;
            color: var(--gray-900);
        }

        .policy-box {
            background: rgba(16, 185, 129, 0.05);
            border-left: 4px solid var(--secondary-color);
            padding: 14px 18px;
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            font-size: var(--font-size-sm);
            line-height: 1.6;
            color: #065f46;
        }

        .booking-form-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.55);
            border-radius: var(--radius-lg);
            padding: var(--spacing-2xl);
            box-shadow: var(--shadow-lg);
        }

        .booking-header {
            margin-bottom: 25px;
        }

        .booking-header h1 {
            font-size: 26px;
            font-weight: 800;
            margin-bottom: 4px;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .booking-header p {
            font-size: var(--font-size-sm);
            color: var(--gray-500);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 700;
            font-size: var(--font-size-base);
            color: var(--gray-700);
        }

        .required-star {
            color: var(--danger-color);
            margin-left: 2px;
        }

        .form-control {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid var(--gray-300);
            border-radius: var(--radius-md);
            font-family: inherit;
            font-size: var(--font-size-base);
            background: rgba(255, 255, 255, 0.85);
            box-sizing: border-box;
            color: var(--gray-900);
            transition: all var(--transition-fast);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
            background: #ffffff;
        }

        .rental-type-segmented {
            display: flex;
            background: var(--gray-100);
            border-radius: var(--radius-md);
            padding: 4px;
            border: 1px solid var(--gray-200);
            gap: 4px;
        }

        .rental-type-segmented label {
            flex: 1;
            text-align: center;
            padding: 10px;
            cursor: pointer;
            border-radius: calc(var(--radius-md) - 4px);
            font-weight: 700;
            font-size: var(--font-size-base);
            color: var(--gray-500);
            transition: all var(--transition-base);
            margin: 0;
            display: block;
        }

        .rental-type-segmented input[type="radio"] {
            display: none;
        }

        .rental-type-segmented label:has(input[type="radio"]:checked) {
            background: #ffffff;
            color: var(--primary-color);
            box-shadow: var(--shadow-sm);
        }

        .voucher-input-wrapper {
            display: flex;
            gap: 10px;
        }

        .voucher-input-wrapper input {
            flex: 1;
            text-transform: uppercase;
        }

        .btn-apply-voucher {
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 0 20px;
            border-radius: var(--radius-md);
            cursor: pointer;
            font-weight: 700;
            font-size: var(--font-size-base);
            transition: all var(--transition-fast);
            white-space: nowrap;
            box-shadow: var(--shadow-sm);
        }

        .btn-apply-voucher:hover {
            background-color: var(--primary-hover);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .btn-apply-voucher:active {
            transform: translateY(0);
        }

        .price-summary {
            background: linear-gradient(160deg, rgba(255, 255, 255, 0.8), var(--gray-50));
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: 20px;
            margin: 25px 0;
            box-shadow: var(--shadow-sm);
        }

        .price-summary p {
            margin: 0;
            padding: 12px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px dashed rgba(99, 102, 241, 0.15);
            font-size: var(--font-size-base);
            color: var(--gray-700);
        }

        .price-summary p:last-of-type {
            border-bottom: none;
        }

        .price-summary p span {
            font-weight: 700;
            color: var(--gray-900);
        }

        .price-summary p.payment-row {
            border-top: 1.5px solid var(--gray-200);
            padding-top: 15px;
            margin-top: 5px;
        }

        .price-summary p.payment-row strong {
            color: var(--primary-color);
            font-size: var(--font-size-lg);
        }

        .price-summary p.payment-row span {
            font-size: 24px;
            font-weight: 800;
            color: var(--primary-color);
        }

        .summary-disclaimer {
            color: var(--gray-500);
            display: block;
            margin-top: 12px;
            font-size: var(--font-size-xs);
            line-height: 1.6;
        }

        .btn-submit {
            width: 100%;
            padding: 14px 20px;
            border-radius: var(--radius-full);
            border: none;
            cursor: pointer;
            color: #fff;
            font-weight: 700;
            font-size: var(--font-size-lg);
            background: var(--primary-gradient);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.25);
            transition: all var(--transition-base);
            margin-top: 15px;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 22px rgba(99, 102, 241, 0.4);
        }

        .btn-submit:active {
            transform: translateY(-1px);
        }

        .btn-back {
            width: 100%;
            padding: 12px 20px;
            border-radius: var(--radius-full);
            border: 1.5px solid var(--gray-300);
            cursor: pointer;
            color: var(--gray-700);
            font-weight: 700;
            font-size: var(--font-size-base);
            background: #ffffff;
            transition: all var(--transition-base);
            margin-top: 10px;
        }

        .btn-back:hover {
            background: var(--gray-50);
            color: var(--gray-900);
            border-color: var(--gray-400);
            transform: translateY(-1px);
        }

        .form-section {
            display: none;
            animation: fadeIn var(--transition-base) ease;
        }

        .form-section.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="wc-container wc-mt-4 wc-mb-4">
    <!-- Error message for unavailability -->
    <c:if test="${not empty error and error == 'notAvailable'}">
        <div style="background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 12px; padding: 20px; margin-bottom: 30px; color: #856404; box-shadow: var(--shadow-sm);">
            <h3 style="margin-top: 0; color: var(--danger-color); font-weight: 700; font-size: 18px;">Không đủ số lượng</h3>
            <p style="margin-bottom: 10px;"><strong>Tất cả sản phẩm cùng loại này đã được thuê hết trong khoảng thời gian bạn chọn.</strong></p>
            
            <c:if test="${not empty requestedStartDateDate}">
                <p style="margin-bottom: 10px;">Thời gian bạn yêu cầu: 
                    <strong style="color: var(--gray-900);"><fmt:formatDate value="${requestedStartDateDate}" pattern="dd/MM/yyyy HH:mm" /></strong> 
                    đến 
                    <strong style="color: var(--gray-900);"><fmt:formatDate value="${requestedEndDateDate}" pattern="dd/MM/yyyy HH:mm" /></strong>
                </p>
            </c:if>
            
            <c:if test="${not empty conflictingOrders}">
                <div style="background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 8px; padding: 12px; margin: 15px 0;">
                    <p style="margin: 5px 0; color: #721c24; font-weight: bold;">
                        Tình trạng: <span style="color: var(--danger-color);">${conflictingOrders.size()} sản phẩm</span> đang được thuê trong thời gian này
                    </p>
                    <c:if test="${availableQuantity != null}">
                        <p style="margin: 5px 0; color: #721c24;">
                            Số lượng còn lại: <strong>${availableQuantity}</strong> sản phẩm
                        </p>
                    </c:if>
                </div>
                <h4 style="margin-bottom: 10px; font-weight: 700; font-size: 15px; color: var(--gray-900);">Các đơn thuê đang xung đột:</h4>
                <ul style="margin: 10px 0; padding-left: 20px; color: var(--gray-700);">
                    <c:forEach items="${conflictingOrders}" var="order">
                        <li style="margin-bottom: 8px;">
                            <strong>Đơn #${order.rentalOrderID}</strong> - 
                            ${order.formattedStartDate} 
                            đến 
                            ${order.formattedEndDate}
                            <span style="color: var(--secondary-color); font-weight: bold;">(${order.status})</span>
                        </li>
                    </c:forEach>
                </ul>
                
                <div style="background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 8px; padding: 12px; margin-top: 15px;">
                    <h4 style="margin-top: 0; color: #155724; font-weight: 700;">💡 Đề xuất thời gian:</h4>
                    <p style="margin: 5px 0; color: #155724; line-height: 1.6;">
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
    
    <div class="booking-layout">
        
        <!-- LEFT COLUMN: Product & Pricing details -->
        <div class="booking-product-card">
            <% if (clothing != null) { %>
            <div class="product-image-wrapper">
                <span class="category-badge">
                    <%= isCosplay ? "Trang phục Cosplay" : "Trang phục Thời trang" %>
                </span>
                <img src="${pageContext.request.contextPath}/image?id=<%= clothing.getClothingID() %>" alt="<%= clothing.getClothingName() %>" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/default.jpg';">
            </div>
            
            <h2 class="product-title"><%= clothing.getClothingName() %></h2>
            
            <div class="product-meta-row">
                <% if (clothing.getStyle() != null && !clothing.getStyle().trim().isEmpty()) { %>
                    <span class="product-meta-item">Style: <%= clothing.getStyle() %></span>
                <% } %>
                <% if (clothing.getOccasion() != null && !clothing.getOccasion().trim().isEmpty()) { %>
                    <span class="product-meta-item">Dịp: <%= clothing.getOccasion() %></span>
                <% } %>
            </div>
            
            <% if (clothing.getDescription() != null && !clothing.getDescription().trim().isEmpty()) { %>
                <p class="product-description"><%= clothing.getDescription() %></p>
            <% } %>
            
            <div class="pricing-card">
                <div class="pricing-item">
                    <span class="pricing-label">Thuê theo giờ</span>
                    <span class="pricing-value"><fmt:formatNumber value="${hourlyPrice}" type="number" />đ<small style="font-weight: 500; font-size: 11px; color: var(--gray-500);">/giờ</small></span>
                </div>
                <div class="pricing-item">
                    <span class="pricing-label">Thuê theo ngày</span>
                    <span class="pricing-value"><fmt:formatNumber value="${dailyPrice}" type="number" />đ<small style="font-weight: 500; font-size: 11px; color: var(--gray-500);">/ngày</small></span>
                </div>
                <div class="pricing-item" style="grid-column: span 2; border-top: 1px dashed var(--gray-200); padding-top: 10px; margin-top: 5px;">
                    <span class="pricing-label">Giá trị sản phẩm (tính tiền cọc)</span>
                    <span class="pricing-value" style="color: var(--warning-color);"><fmt:formatNumber value="${itemValue}" type="number" />đ</span>
                </div>
            </div>
            <% } else { %>
            <p>Không tìm thấy thông tin sản phẩm.</p>
            <% } %>
            
            <div class="policy-box">
                <strong style="display: block; margin-bottom: 4px; font-weight: 700;">🛡️ Chính sách đặt thuê của WearConnect:</strong>
                • Tiền cọc sẽ được tính tự động dựa trên giá trị thực tế của sản phẩm.<br>
                • Bạn sẽ được hoàn tiền cọc 100% sau khi trả lại hàng sạch sẽ, nguyên vẹn và không hư hỏng.<br>
                • Vui lòng chọn chính xác khung thời gian bắt đầu và kết thúc thuê.
            </div>
        </div>
        
        <!-- RIGHT COLUMN: Booking Form -->
        <div class="booking-form-card">
            <div class="booking-header">
                <h1>${isAddToCart ? 'Thêm vào giỏ hàng' : 'Đặt thuê của bạn'}</h1>
                <p>${isAddToCart ? 'Cấu hình thời gian thuê để lưu vào giỏ hàng' : 'Cấu hình thời gian thuê và áp dụng voucher giảm giá'}</p>
            </div>
            
            <form method="POST" action="${pageContext.request.contextPath}${isAddToCart ? '/cart' : '/rental'}">
                <input type="hidden" name="action" value="${isAddToCart ? 'add' : 'createOrder'}">
                <input type="hidden" name="clothingID" value="${clothingID}">
                <input type="hidden" name="hourlyPrice" value="${hourlyPrice}">
                <input type="hidden" name="dailyPrice" value="${dailyPrice}">
                <input type="hidden" name="itemValue" value="${itemValue}">
                <input type="hidden" id="isCosplayInput" name="isCosplay" value="<%= isCosplay %>">
                
                <% if (isCosplay) { %>
                <!-- Thông báo cho cosplay -->
                <div style="background-color: rgba(99, 102, 241, 0.08); border-left: 4px solid var(--primary-color); border-radius: 0 var(--radius-md) var(--radius-md) 0; padding: 12px 16px; margin-bottom: 20px; color: var(--primary-hover); font-size: 13px; font-weight: 500;">
                    <strong>Sản phẩm Cosplay:</strong> Vui lòng chọn size phù hợp. Sản phẩm cosplay không hỗ trợ chọn màu sắc.
                </div>
                <% } %>
        
                <!-- Chọn size -->
                <div class="form-group">
                    <label for="selectedSize">Chọn size phù hợp: <span class="required-star">*</span></label>
                    <select id="selectedSize" name="selectedSize" class="form-control">
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
                    <select id="selectedColor" name="selectedColor" class="form-control">
                        <option value="">-- Không chọn màu (nếu có) --</option>
                        <% for (Color color : availableColors) { %>
                        <option value="<%= color.getColorID() %>">
                            <%= color.getColorName() %>
                        </option>
                        <% } %>
                    </select>
                    <% if (availableColors.isEmpty()) { %>
                        <small style="color: var(--gray-400); display: block; margin-top: 5px; font-size: 12px;">Sản phẩm này không có lựa chọn màu sắc</small>
                    <% } %>
                </div>
                <% } // End if (!isCosplay) %>
                
                <!-- Lựa chọn loại thuê -->
                <div class="form-group">
                    <label>Chọn hình thức thuê:</label>
                    <div class="rental-type-segmented">
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
                        <label for="hourlyStartDate">Ngày giờ bắt đầu: <span class="required-star">*</span></label>
                        <input type="datetime-local" id="hourlyStartDate" name="startDate" class="form-control" onchange="calculatePrice()">
                    </div>
                    
                    <div class="form-group">
                        <label for="hourlyEndDate">Ngày giờ kết thúc: <span class="required-star">*</span></label>
                        <input type="datetime-local" id="hourlyEndDate" name="endDate" class="form-control" onchange="calculatePrice()">
                    </div>
                </div>
                
                <!-- Phần thuê theo ngày -->
                <div id="dailySection" class="form-section">
                    <div class="form-group">
                        <label for="dailyStartDate">Ngày bắt đầu: <span class="required-star">*</span></label>
                        <input type="date" id="dailyStartDate" name="dailyStartDate" class="form-control" onchange="calculatePrice()">
                    </div>
                    
                    <div class="form-group">
                        <label for="dailyEndDate">Ngày kết thúc: <span class="required-star">*</span></label>
                        <input type="date" id="dailyEndDate" name="dailyEndDate" class="form-control" onchange="calculatePrice()">
                    </div>
                </div>
                
                <!-- Phần nhập Voucher -->
                <c:if test="${not isAddToCart}">
                <div class="form-group" style="margin-top: 25px; border-top: 1px dashed var(--gray-200); padding-top: 20px;">
                    <label for="voucherInput">Mã giảm giá (Voucher):</label>
                    <div class="voucher-input-wrapper">
                        <input type="text" id="voucherInput" class="form-control" placeholder="Nhập mã voucher (ví dụ: WELCOME100)">
                        <button type="button" id="btnApplyVoucher" class="btn-apply-voucher" onclick="applyVoucher()">Áp dụng</button>
                    </div>
                    <span id="voucherMessage" style="font-size: 13px; display: block; margin-top: 8px; font-weight: 600;"></span>
                    <input type="hidden" id="submittedVoucherCode" name="voucherCode" value="">
                </div>
                </c:if>
                
                <div class="price-summary">
                    <p><strong id="rentalFeeLabel">Tổng giá thuê:</strong> <span><span id="rentalFee">0</span> VNĐ</span></p>
                    <p id="discountRow" style="display: none; color: var(--secondary-color);"><strong>Giảm giá Voucher:</strong> <span>-<span id="discountAmountDisplay">0</span> VNĐ</span></p>
                    <p id="discountedRentalFeeRow" style="display: none; color: var(--primary-color);"><strong>Tiền thuê sau giảm:</strong> <span><span id="discountedRentalFeeDisplay">0</span> VNĐ</span></p>
                    <p><strong>Tiền cọc:</strong> <span><span id="depositAmount">0</span> VNĐ</span></p>
                    <p class="payment-row"><strong>${isAddToCart ? 'Ước tính thanh toán:' : 'Số tiền thanh toán:'}</strong> <span><span id="paymentAmount">0</span> VNĐ</span></p>
                    <small class="summary-disclaimer">
                        <c:choose>
                            <c:when test="${isAddToCart}">
                                Số tiền trên là ước tính gồm: <strong>Giá thuê + tiền cọc</strong>.<br>Bạn sẽ thực hiện thanh toán khi bấm thuê từ giỏ hàng.
                            </c:when>
                            <c:otherwise>
                                Bạn sẽ thanh toán: <strong>Tổng tiền thuê + tiền cọc</strong> trước.<br>Tiền cọc sẽ được hoàn lại sau khi shop nhận sản phẩm không có lỗi gì.
                            </c:otherwise>
                        </c:choose>
                    </small>
                </div>
                
                <button type="submit" class="btn-submit" onclick="return validateForm()">${isAddToCart ? 'Thêm vào giỏ hàng 🛒' : 'Tiến hành thanh toán'}</button>
                <button type="button" class="btn-back" onclick="history.back()">Quay lại</button>
            </form>
        </div>
        
    </div>
</div>

<script>
    const HOURLY_PRICE = Number('${hourlyPrice}');
    const DAILY_PRICE = Number('${dailyPrice}');
    const ITEM_VALUE = Number('${itemValue}');
    
    // Cấu hình đồng bộ từ Backend (DepositCalculationConfig)
    const HOURLY_DEPOSIT_PERCENTAGE = <%= DepositCalculationConfig.HOURLY_DEPOSIT_PERCENTAGE %>;
    const HOURLY_DEPOSIT_MULTIPLIER = <%= DepositCalculationConfig.HOURLY_DEPOSIT_MULTIPLIER %>;
    const DAILY_DEPOSIT_PERCENTAGE = <%= DepositCalculationConfig.DAILY_DEPOSIT_PERCENTAGE %>;
    const DAILY_DEPOSIT_MULTIPLIER = <%= DepositCalculationConfig.DAILY_DEPOSIT_MULTIPLIER %>;
    
    function calculateDeposit(duration, rentalType) {
        if (duration <= 0) return 0;
        
        if (rentalType === 'hourly') {
            // Công thức Thuê theo giờ: MAX(ITEM_VALUE * HOURLY_DEPOSIT_PERCENTAGE, Tổng tiền thuê * HOURLY_DEPOSIT_MULTIPLIER)
            const rentalFee = duration * HOURLY_PRICE;
            const percentBased = ITEM_VALUE * HOURLY_DEPOSIT_PERCENTAGE;
            const priceBased = rentalFee * HOURLY_DEPOSIT_MULTIPLIER;
            return Math.max(percentBased, priceBased);
        } else {
            // Công thức Thuê theo ngày: MAX(ITEM_VALUE * DAILY_DEPOSIT_PERCENTAGE, Tổng tiền thuê * DAILY_DEPOSIT_MULTIPLIER)
            const rentalFee = duration * DAILY_PRICE; // duration ở đây là số ngày
            const percentBased = ITEM_VALUE * DAILY_DEPOSIT_PERCENTAGE;
            const priceBased = rentalFee * DAILY_DEPOSIT_MULTIPLIER;
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
        // Validate voucher application
        const voucherInput = document.getElementById('voucherInput');
        const submittedVoucherCode = document.getElementById('submittedVoucherCode');
        if (voucherInput && voucherInput.value.trim() !== '' && (!submittedVoucherCode || submittedVoucherCode.value.trim() === '')) {
            alert('Vui lòng click nút "Áp dụng" để kích hoạt mã giảm giá trước khi thanh toán.');
            return false;
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

    let appliedVoucherData = null;

    function resetVoucher() {
        document.getElementById('submittedVoucherCode').value = "";
        document.getElementById('voucherInput').value = "";
        document.getElementById('voucherMessage').textContent = "";
        document.getElementById('discountRow').style.display = "none";
        document.getElementById('discountAmountDisplay').textContent = "0";
        appliedVoucherData = null;
    }

    function applyVoucher() {
        const code = document.getElementById('voucherInput').value.trim().toUpperCase();
        const msgSpan = document.getElementById('voucherMessage');
        
        if (code === '') {
            resetVoucher();
            return;
        }

        const rentalFeeText = document.getElementById('rentalFee').textContent.replace(/\D/g, '');
        const rentalPrice = parseFloat(rentalFeeText) || 0;
        
        if (rentalPrice <= 0) {
            msgSpan.style.color = 'red';
            msgSpan.textContent = 'Vui lòng chọn thời gian thuê trước khi áp dụng voucher.';
            return;
        }

        const ctx = '${pageContext.request.contextPath}';
        const url = ctx + '/rental/validateVoucher?code=' + encodeURIComponent(code) + '&totalPrice=' + rentalPrice;
        
        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data.valid) {
                    appliedVoucherData = data;
                    document.getElementById('submittedVoucherCode').value = data.voucherCode;
                    msgSpan.style.color = '#28a745';
                    msgSpan.textContent = 'Áp dụng voucher thành công!';
                    updatePriceDisplays();
                } else {
                    document.getElementById('submittedVoucherCode').value = "";
                    msgSpan.style.color = 'red';
                    msgSpan.textContent = data.message || 'Mã giảm giá không hợp lệ.';
                    
                    appliedVoucherData = null;
                    document.getElementById('discountRow').style.display = "none";
                    document.getElementById('discountAmountDisplay').textContent = "0";
                    updatePriceDisplays();
                }
            })
            .catch(err => {
                console.error(err);
                msgSpan.style.color = 'red';
                msgSpan.textContent = 'Lỗi hệ thống khi xác thực voucher.';
            });
    }

    function updatePriceDisplays() {
        const rentalFeeText = document.getElementById('rentalFee').textContent.replace(/\D/g, '');
        const rentalPrice = parseFloat(rentalFeeText) || 0;
        
        const depositText = document.getElementById('depositAmount').textContent.replace(/\D/g, '');
        const depositPrice = parseFloat(depositText) || 0;

        let discount = 0;
        if (appliedVoucherData) {
            if (appliedVoucherData.discountType === 'PERCENTAGE') {
                discount = rentalPrice * (appliedVoucherData.discountValue / 100);
                if (appliedVoucherData.maxDiscountAmount && discount > appliedVoucherData.maxDiscountAmount) {
                    discount = appliedVoucherData.maxDiscountAmount;
                }
            } else if (appliedVoucherData.discountType === 'AMOUNT') {
                discount = appliedVoucherData.discountValue;
            }
            
            if (discount > rentalPrice) {
                discount = rentalPrice;
            }
        }

        if (discount > 0) {
            document.getElementById('rentalFeeLabel').textContent = 'Giá thuê gốc:';
            document.getElementById('discountRow').style.display = 'block';
            document.getElementById('discountAmountDisplay').textContent = Math.round(discount).toLocaleString('vi-VN');
            document.getElementById('discountedRentalFeeRow').style.display = 'block';
            document.getElementById('discountedRentalFeeDisplay').textContent = Math.round(rentalPrice - discount).toLocaleString('vi-VN');
        } else {
            document.getElementById('rentalFeeLabel').textContent = 'Tổng giá thuê:';
            document.getElementById('discountRow').style.display = 'none';
            document.getElementById('discountedRentalFeeRow').style.display = 'none';
        }

        const totalPayment = rentalPrice - discount + depositPrice;
        document.getElementById('paymentAmount').textContent = totalPayment > 0 ? Math.round(totalPayment).toLocaleString('vi-VN') : '0';
    }

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

        document.getElementById('rentalFee').textContent = (isFinite(rentalPrice) && rentalPrice > 0) ? Math.round(rentalPrice).toLocaleString('vi-VN') : '0';
        document.getElementById('depositAmount').textContent = (isFinite(depositPrice) && depositPrice > 0) ? Math.round(depositPrice).toLocaleString('vi-VN') : '0';

        // Check if applied voucher is still valid with the new price
        if (appliedVoucherData && rentalPrice < appliedVoucherData.minOrderValue) {
            document.getElementById('submittedVoucherCode').value = "";
            document.getElementById('voucherMessage').style.color = 'red';
            document.getElementById('voucherMessage').textContent = 'Voucher tự động hủy do đơn hàng mới không đủ điều kiện tối thiểu.';
            appliedVoucherData = null;
        }

        updatePriceDisplays();
    }
</script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
