<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="config.DepositCalculationConfig" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="DAO.RatingDAO" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Giỏ hàng của tôi - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            background:
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.12), transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(6, 182, 212, 0.08), transparent 45%),
                linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%) !important;
        }

        .cart-layout {
            display: grid;
            grid-template-columns: 1fr 350px;
            gap: 30px;
            margin-top: 30px;
            margin-bottom: 50px;
            align-items: start;
        }

        @media (max-width: 992px) {
            .cart-layout {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }

        .cart-table-wrapper {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            padding: var(--spacing-xl);
            box-shadow: var(--shadow-lg);
        }

        .cart-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        .cart-table th {
            padding: 16px 12px;
            border-bottom: 2px solid rgba(99, 102, 241, 0.12);
            color: var(--gray-700);
            font-weight: 700;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .cart-table td {
            padding: 20px 12px;
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            vertical-align: middle;
        }

        .item-details {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .item-thumb {
            width: 70px;
            height: 85px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            box-shadow: var(--shadow-sm);
            background-color: var(--gray-100);
        }

        .item-info {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .item-name {
            font-weight: 700;
            color: var(--gray-900);
            text-decoration: none;
            font-size: 15px;
            transition: color var(--transition-fast);
        }

        .item-name:hover {
            color: var(--primary-color);
        }

        .item-meta {
            font-size: 12px;
            color: var(--gray-500);
            font-weight: 500;
        }

        .item-meta span {
            background-color: rgba(99, 102, 241, 0.08);
            color: var(--primary-color);
            padding: 2px 8px;
            border-radius: var(--radius-full);
            margin-right: 4px;
            font-weight: 600;
        }

        .price-text {
            font-weight: 700;
            color: var(--gray-900);
        }

        .deposit-text {
            color: var(--warning-color);
            font-weight: 700;
        }

        .btn-remove {
            background: none;
            border: none;
            color: var(--danger-color);
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: color var(--transition-fast);
            padding: 4px 8px;
            border-radius: var(--radius-sm);
        }

        .btn-remove:hover {
            color: #b91c1c;
            background-color: rgba(239, 68, 68, 0.08);
        }

        .summary-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.55);
            border-radius: var(--radius-lg);
            padding: var(--spacing-2xl);
            box-shadow: var(--shadow-lg);
            position: sticky;
            top: 100px;
        }

        .summary-header {
            font-size: 18px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 20px;
            border-bottom: 2px solid rgba(99, 102, 241, 0.12);
            padding-bottom: 10px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            font-size: 14px;
            color: var(--gray-600);
        }

        .summary-row.total {
            border-top: 1.5px solid var(--gray-200);
            padding-top: 15px;
            margin-top: 15px;
            font-size: 16px;
            font-weight: 800;
            color: var(--gray-900);
        }

        .summary-row.total span {
            color: var(--primary-color);
            font-size: 20px;
        }

        .btn-checkout {
            width: 100%;
            padding: 14px 20px;
            border-radius: var(--radius-full);
            border: none;
            cursor: pointer;
            color: #fff;
            font-weight: 700;
            font-size: 16px;
            background: var(--primary-gradient);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
            transition: all var(--transition-base);
            margin-top: 15px;
            display: block;
            text-align: center;
            text-decoration: none;
        }

        .btn-checkout:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
        }

        .empty-cart-view {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-cart-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .checkbox-custom {
            width: 20px;
            height: 20px;
            accent-color: var(--primary-color);
            cursor: pointer;
        }

        .alert-box {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 15px 20px;
            border-radius: var(--radius-md);
            margin-bottom: 25px;
            font-weight: 500;
        }

        .alert-success-box {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 15px 20px;
            border-radius: var(--radius-md);
            margin-bottom: 25px;
            font-weight: 500;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="wc-container wc-mt-4 wc-mb-4" style="max-width: 1200px; margin: 0 auto; padding: 0 15px;">
    
    <div style="margin-bottom: 30px;">
        <h1 style="font-family: Poppins, sans-serif; font-weight: 800; font-size: 28px; color: var(--gray-900); margin: 0;">Giỏ Hàng Của Bạn</h1>
        <p style="color: var(--gray-500); margin-top: 5px; font-size: 14px;">Quản lý và thanh toán các món đồ bạn chuẩn bị đặt thuê</p>
    </div>

    <!-- Alert Notifications -->
    <c:if test="${param.added eq 'true'}">
        <div class="alert-success-box">
            🎉 Đã thêm sản phẩm vào giỏ hàng thành công!
        </div>
    </c:if>
    <c:if test="${param.removed eq 'true'}">
        <div class="alert-success-box">
            🗑️ Đã xóa sản phẩm khỏi giỏ hàng.
        </div>
    </c:if>
    <c:if test="${param.error eq 'not_available'}">
        <div class="alert-box">
            ⚠️ Một số mặt hàng không khả dụng trong thời gian bạn chọn: <strong style="text-decoration: underline;">${param.conflictItem}</strong>. Vui lòng kiểm tra lại.
        </div>
    </c:if>
    <c:if test="${param.error eq 'no_items_selected'}">
        <div class="alert-box">
            ⚠️ Vui lòng chọn ít nhất 1 sản phẩm để thanh toán.
        </div>
    </c:if>
    <c:if test="${param.error eq 'checkout_failed'}">
        <div class="alert-box">
            ⚠️ Đặt thuê thất bại: ${param.msg}
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty cart}">
            <div class="cart-table-wrapper" style="padding: 40px;">
                <div class="empty-cart-view">
                    <div class="empty-cart-icon">🛒</div>
                    <h3 style="font-weight: 800; color: var(--gray-700); font-size: 20px;">Giỏ hàng của bạn đang trống</h3>
                    <p style="color: var(--gray-500); margin-top: 8px; margin-bottom: 25px;">Hãy khám phá các trang phục lộng lẫy và thêm chúng vào đây nhé!</p>
                    <a href="${pageContext.request.contextPath}/home" class="btn-checkout" style="width: auto; display: inline-block; padding: 12px 30px;">Tiếp tục mua sắm</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <form action="${pageContext.request.contextPath}/cart" method="POST" id="cartForm">
                <input type="hidden" name="action" value="checkout">
                
                <div class="cart-layout">
                    <!-- Left: Items list -->
                    <div class="cart-table-wrapper">
                        <table class="cart-table">
                            <thead>
                                <tr>
                                    <th style="width: 40px; text-align: center;">
                                        <input type="checkbox" id="selectAll" class="checkbox-custom" checked onclick="toggleSelectAll(this)">
                                    </th>
                                    <th>Sản Phẩm</th>
                                    <th style="width: 140px;">Thời Gian Thuê</th>
                                    <th style="width: 120px; text-align: right;">Giá Thuê</th>
                                    <th style="width: 120px; text-align: right;">Tiền Cọc</th>
                                    <th style="width: 60px; text-align: center;"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${cart}" var="item">
                                    <%
                                        CartItem cartItem = (CartItem) pageContext.getAttribute("item");
                                        long durationHours = ChronoUnit.HOURS.between(cartItem.getStartDate(), cartItem.getEndDate());
                                        double rentFee = 0.0;
                                        double deposit = 0.0;
                                        
                                        if ("daily".equals(cartItem.getRentalType())) {
                                            long durationDays = durationHours / 24;
                                            if (durationDays <= 0) durationDays = 1;
                                            rentFee = durationDays * cartItem.getDailyPrice();
                                            deposit = Math.max(cartItem.getItemValue() * DepositCalculationConfig.DAILY_DEPOSIT_PERCENTAGE, rentFee * DepositCalculationConfig.DAILY_DEPOSIT_MULTIPLIER);
                                        } else {
                                            rentFee = durationHours * cartItem.getHourlyPrice();
                                            deposit = Math.max(cartItem.getItemValue() * DepositCalculationConfig.HOURLY_DEPOSIT_PERCENTAGE, rentFee * DepositCalculationConfig.HOURLY_DEPOSIT_MULTIPLIER);
                                        }

                                        // Apply trust multiplier for user
                                        double userRating = RatingDAO.getAverageRatingForUser((int)session.getAttribute("accountID"));
                                        double trustBasedMultiplier = DepositCalculationConfig.getTrustBasedMultiplier(userRating > 0 ? userRating : null);
                                        double adjustedDeposit = deposit * trustBasedMultiplier;

                                        pageContext.setAttribute("durationHours", durationHours);
                                        pageContext.setAttribute("durationDays", durationHours / 24);
                                        pageContext.setAttribute("rentFee", rentFee);
                                        pageContext.setAttribute("adjustedDeposit", adjustedDeposit);
                                    %>
                                    <tr>
                                        <td style="text-align: center;">
                                            <input type="checkbox" name="selectedItems" value="${item.cartItemId}" 
                                                   class="checkbox-custom item-checkbox" checked
                                                   data-rent="${rentFee}" 
                                                   data-deposit="${adjustedDeposit}"
                                                   onclick="updateSummary()">
                                        </td>
                                        <td>
                                            <div class="item-details">
                                                <c:choose>
                                                    <c:when test="${not empty item.imageID}">
                                                        <img src="${pageContext.request.contextPath}/image?imageId=${item.imageID}" class="item-thumb" alt="${item.clothingName}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${pageContext.request.contextPath}/image?id=${item.clothingID}" class="item-thumb" alt="${item.clothingName}">
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="item-info">
                                                    <a href="${pageContext.request.contextPath}/clothing?action=details&clothingID=${item.clothingID}" class="item-name">${item.clothingName}</a>
                                                    <div class="item-meta">
                                                        <span>Size: ${item.selectedSize}</span>
                                                        <c:if test="${not empty item.colorName}">
                                                            <span>Màu: ${item.colorName}</span>
                                                        </c:if>
                                                        <span style="background-color: #f1f5f9; color: #475569; font-weight: bold;">
                                                            ${item.rentalType eq 'daily' ? 'Theo ngày' : 'Theo giờ'}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-size: 13px; font-weight: 600; color: var(--gray-700); line-height: 1.4;">
                                                Từ: ${item.formattedStartDate}<br>
                                                Đến: ${item.formattedEndDate}
                                            </div>
                                            <small style="color: var(--gray-400); font-size: 11px;">
                                                (${item.rentalType eq 'daily' ? durationDays : durationHours} ${item.rentalType eq 'daily' ? 'ngày' : 'giờ'})
                                            </small>
                                        </td>
                                        <td style="text-align: right;">
                                            <span class="price-text"><fmt:formatNumber value="${rentFee}" pattern="#,##0"/>đ</span>
                                        </td>
                                        <td style="text-align: right;">
                                            <span class="deposit-text"><fmt:formatNumber value="${adjustedDeposit}" pattern="#,##0"/>đ</span>
                                        </td>
                                        <td style="text-align: center;">
                                            <button type="button" class="btn-remove" onclick="removeItem(${item.cartItemId})">Xóa</button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Right: Sticky Cart Summary -->
                    <div class="summary-card">
                        <div class="summary-header">Tóm Tắt Đơn Hàng</div>
                        
                        <div class="summary-row">
                            <span>Số lượng chọn:</span>
                            <span id="selectedCount" style="font-weight: 700;">0</span>
                        </div>
                        
                        <div class="summary-row">
                            <span>Tổng giá thuê:</span>
                            <span id="sumRent" style="font-weight: 700; color: var(--gray-900);">0đ</span>
                        </div>
                        
                        <div class="summary-row">
                            <span>Tổng tiền cọc:</span>
                            <span id="sumDeposit" style="font-weight: 700; color: var(--gray-900);">0đ</span>
                        </div>

                        <div class="summary-row total">
                            <span>Tổng thanh toán:</span>
                            <span id="sumTotal" style="font-weight: 800;">0đ</span>
                        </div>
                        
                        <small style="display: block; font-size: 11px; color: var(--gray-500); line-height: 1.5; margin-top: 15px;">
                            * Tổng thanh toán = Tổng tiền thuê + Tổng tiền cọc.<br>
                            * Tiền cọc sẽ được hoàn lại 100% sau khi trả đồ và không bị hư hỏng gì.
                        </small>
                        
                        <button type="submit" class="btn-checkout" id="btnCheckout">Đặt Thuê Ngay</button>
                        <a href="${pageContext.request.contextPath}/home" class="btn-checkout" style="background: white; border: 1.5px solid var(--gray-300); color: var(--gray-700); box-shadow: none; margin-top: 10px;">Thêm Đồ Khác</a>
                    </div>
                </div>
            </form>
        </c:otherwise>
    </c:choose>
</div>

<script>
    function updateSummary() {
        const checkboxes = document.querySelectorAll('.item-checkbox:checked');
        let selectedCount = checkboxes.length;
        let sumRent = 0;
        let sumDeposit = 0;

        checkboxes.forEach(cb => {
            sumRent += parseFloat(cb.getAttribute('data-rent')) || 0;
            sumDeposit += parseFloat(cb.getAttribute('data-deposit')) || 0;
        });

        const sumTotal = sumRent + sumDeposit;

        document.getElementById('selectedCount').textContent = selectedCount;
        document.getElementById('sumRent').textContent = Math.round(sumRent).toLocaleString('vi-VN') + 'đ';
        document.getElementById('sumDeposit').textContent = Math.round(sumDeposit).toLocaleString('vi-VN') + 'đ';
        document.getElementById('sumTotal').textContent = Math.round(sumTotal).toLocaleString('vi-VN') + 'đ';

        const btnCheckout = document.getElementById('btnCheckout');
        if (selectedCount === 0) {
            btnCheckout.disabled = true;
            btnCheckout.style.opacity = '0.5';
            btnCheckout.style.cursor = 'not-allowed';
        } else {
            btnCheckout.disabled = false;
            btnCheckout.style.opacity = '1';
            btnCheckout.style.cursor = 'pointer';
        }
    }

    function toggleSelectAll(selectAllCheckbox) {
        const checkboxes = document.querySelectorAll('.item-checkbox');
        checkboxes.forEach(cb => {
            cb.checked = selectAllCheckbox.checked;
        });
        updateSummary();
    }

    function removeItem(cartItemId) {
        if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?')) {
            window.location.href = '${pageContext.request.contextPath}/cart?action=remove&cartItemId=' + cartItemId;
        }
    }

    // Initialize display on load
    window.addEventListener('DOMContentLoaded', () => {
        updateSummary();
    });

    document.getElementById('cartForm')?.addEventListener('submit', (e) => {
        const checkboxes = document.querySelectorAll('.item-checkbox:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất 1 sản phẩm để tiến hành đặt thuê.');
            e.preventDefault();
            return false;
        }
        return true;
    });
</script>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
