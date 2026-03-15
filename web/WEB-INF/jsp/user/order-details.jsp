<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="DAO.ColorDAO" %>
<%@ page import="Model.Color" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết đơn - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

        :root {
            --ink-900: #1a2238;
            --ink-700: #33446b;
            --ink-500: #5a6f9a;
            --soft-100: #f5f8ff;
            --soft-200: #e8eefc;
            --line: #d8e1f5;
            --brand: #1f6feb;
            --brand-2: #17a2b8;
            --ok: #198754;
            --warn: #ff9800;
            --danger: #dc3545;
            --shadow: 0 18px 40px rgba(18, 42, 93, 0.12);
        }

        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            color: var(--ink-900);
            background:
                radial-gradient(circle at 8% 12%, rgba(31, 111, 235, 0.16), transparent 38%),
                radial-gradient(circle at 92% 88%, rgba(23, 162, 184, 0.14), transparent 34%),
                linear-gradient(165deg, #f8fbff 0%, #eef4ff 48%, #f3fbff 100%);
        }

        .container {
            max-width: 1320px;
            margin: 34px auto 46px;
            padding: 0 16px;
        }

        h1 {
            margin: 0 0 20px;
            font-family: 'Poppins', sans-serif;
            font-size: clamp(1.7rem, 2.6vw, 2.25rem);
            letter-spacing: 0.3px;
            color: var(--ink-900);
        }

        .order-wrapper {
            display: grid;
            grid-template-columns: 1fr;
            gap: 22px;
            align-items: start;
        }

        .order-left { min-width: 0; }
        .order-right { width: auto; }

        .order-info {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow);
            backdrop-filter: blur(2px);
            animation: riseIn 320ms ease-out;
        }

        .product-image-box {
            background: linear-gradient(160deg, #ffffff, #f5f8ff);
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 14px;
            text-align: center;
            box-shadow: var(--shadow);
        }

        .product-image {
            width: 100%;
            max-height: 270px;
            object-fit: cover;
            border-radius: 12px;
            box-shadow: 0 12px 28px rgba(20, 46, 104, 0.2);
        }

        .info-row {
            margin: 0;
            padding: 12px 0;
            display: grid;
            grid-template-columns: minmax(130px, 180px) 1fr;
            gap: 10px;
            border-bottom: 1px dashed rgba(90, 111, 154, 0.25);
        }

        .info-row strong {
            display: block;
            width: auto;
            font-weight: 700;
            color: var(--ink-700);
        }

        .status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 32px;
            padding: 6px 14px;
            border-radius: 999px;
            font-weight: 700;
            font-size: 0.83rem;
            letter-spacing: 0.25px;
            border: 1px solid transparent;
        }

        .status.pending { background: rgba(255, 193, 7, 0.18); border-color: rgba(255, 193, 7, 0.35); color: #7d5d00; }
        .status.verifying { background: rgba(23, 162, 184, 0.18); border-color: rgba(23, 162, 184, 0.35); color: #0f5e6b; }
        .status.confirmed { background: rgba(25, 135, 84, 0.16); border-color: rgba(25, 135, 84, 0.3); color: #11643d; }
        .status.rented { background: rgba(31, 111, 235, 0.14); border-color: rgba(31, 111, 235, 0.3); color: #124b9f; }
        .status.returned { background: rgba(108, 117, 125, 0.14); border-color: rgba(108, 117, 125, 0.3); color: #4d5862; }
        .status.completed { background: rgba(25, 135, 84, 0.16); border-color: rgba(25, 135, 84, 0.3); color: #11643d; }
        .status.issue { background: rgba(220, 53, 69, 0.14); border-color: rgba(220, 53, 69, 0.3); color: #9e1f31; }
        .status.return_requested { background: rgba(255, 152, 0, 0.16); border-color: rgba(255, 152, 0, 0.3); color: #8c5300; }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 18px;
            margin-top: 16px;
            border-radius: 11px;
            border: 1px solid rgba(17, 77, 155, 0.35);
            text-decoration: none;
            cursor: pointer;
            color: #fff;
            font-weight: 700;
            letter-spacing: 0.2px;
            background: linear-gradient(135deg, var(--brand), #1358bf);
            box-shadow: 0 10px 22px rgba(31, 111, 235, 0.24);
            transition: transform 0.2s ease, box-shadow 0.2s ease, filter 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 13px 24px rgba(31, 111, 235, 0.28);
            filter: saturate(1.08);
        }

        .btn-danger {
            background: linear-gradient(135deg, #e03b49, #b61e2d);
            border-color: rgba(182, 30, 45, 0.45);
            box-shadow: 0 10px 22px rgba(182, 30, 45, 0.24);
        }

        .alert {
            padding: 14px 16px;
            margin-bottom: 16px;
            border-radius: 12px;
            border: 1px solid;
            box-shadow: 0 6px 16px rgba(26, 34, 56, 0.08);
            font-size: 0.95rem;
        }

        .alert-success {
            background: #ebfaf2;
            border-color: #b7e8cb;
            color: #155a37;
        }

        .alert-info {
            background: #eaf6ff;
            border-color: #bddfff;
            color: #0f4f7b;
        }

        .star-rating {
            display: inline-flex;
            flex-direction: row-reverse;
            gap: 6px;
            font-size: 27px;
            cursor: pointer;
        }

        .star-rating input { display: none; }
        .star-rating label { color: #cfd6e6; transition: color 0.2s ease; }
        .star-rating input:checked ~ label { color: #f3b321; }
        .star-rating label:hover,
        .star-rating label:hover ~ label { color: #f9cd63; }

        .rating-note {
            font-size: 12px;
            color: var(--ink-500);
            margin-top: 4px;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            inset: 0;
            background-color: rgba(16, 30, 59, 0.5);
            backdrop-filter: blur(2px);
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: #fff;
            padding: 26px;
            border-radius: 16px;
            width: 92%;
            max-width: 520px;
            border: 1px solid var(--line);
            box-shadow: 0 20px 42px rgba(16, 30, 59, 0.24);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
        }

        .modal-header h2 {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            font-size: 1.5rem;
            color: var(--ink-900);
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 28px;
            cursor: pointer;
            color: var(--ink-500);
        }

        .modal-close:hover { color: var(--ink-900); }

        .form-group { margin-bottom: 14px; }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 700;
            color: var(--ink-700);
        }

        .form-group select,
        .form-group textarea,
        .form-group input[type="text"],
        .form-group input[type="file"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--line);
            border-radius: 10px;
            font-family: inherit;
            font-size: 14px;
            background: #fff;
            box-sizing: border-box;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 16px;
        }

        .modal-btn {
            padding: 10px 18px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 700;
        }

        .modal-btn-submit {
            background: linear-gradient(135deg, #e03b49, #b61e2d);
            color: #fff;
        }

        .modal-btn-submit:hover { filter: brightness(1.03); }

        .modal-btn-cancel {
            background: #eef2fb;
            color: var(--ink-700);
            border: 1px solid var(--line);
        }

        .modal-btn-cancel:hover { background: #e5ebfa; }

        .color-info { display: flex; align-items: center; gap: 10px; }

        .color-swatch {
            display: inline-block;
            width: 24px;
            height: 24px;
            border-radius: 6px;
            border: 1px solid rgba(26, 34, 56, 0.25);
        }

        @keyframes riseIn {
            from {
                transform: translateY(8px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        @media (max-width: 900px) {
            .order-wrapper {
                grid-template-columns: 1fr;
            }

            .product-image {
                max-height: 330px;
            }
        }

        @media (max-width: 640px) {
            .container {
                margin-top: 20px;
                padding: 0 12px;
            }

            .order-info {
                padding: 16px;
                border-radius: 14px;
            }

            .info-row {
                grid-template-columns: 1fr;
                gap: 6px;
            }

            .btn,
            .modal-btn {
                width: 100%;
            }

            .modal-buttons {
                flex-direction: column-reverse;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Chi tiết đơn thuê</h1>
    
    <!-- Success message for payment submission -->
    <c:if test="${param.paymentSubmitted == 'true'}">
        <div class="alert alert-success">
            <strong>Thông tin thanh toán đã gửi!</strong><br>
            Cảm ơn bạn đã gửi thông tin thanh toán (kèm ảnh nếu có).<br>
            Đơn hàng của bạn đang chờ admin xác thực.
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
                        
                        <!-- Thông tin người thuê (chỉ manager/admin xem được) -->
                        <c:if test="${sessionScope.userRole == 'Manager' || sessionScope.userRole == 'Admin'}">
                            <div style="background-color: #fff9e6; padding: 12px; border-radius: 6px; margin: 12px 0; border-left: 3px solid #ffa500;">
                                <div style="font-weight: bold; color: #ff8c00; margin-bottom: 8px;">📋 Thông tin người đặt</div>
                                <div class="info-row" style="margin: 6px 0;">
                                    <strong>Họ tên:</strong> ${order.renterFullName}
                                </div>
                                <div class="info-row" style="margin: 6px 0;">
                                    <strong>SĐT:</strong> ${order.renterPhone}
                                </div>
                                <div class="info-row" style="margin: 6px 0;">
                                    <strong>Email:</strong> ${order.renterEmail}
                                </div>
                                <div class="info-row" style="margin: 6px 0;">
                                    <strong>Địa chỉ:</strong> ${order.renterAddress}
                                </div>
                            </div>
                        </c:if>
                        
                        <div class="info-row">
                            <strong>Ngày bắt đầu:</strong> ${order.rentalStartDate}
                        </div>
                        <div class="info-row">
                            <strong>Ngày kết thúc:</strong> ${order.rentalEndDate}
                        </div>
                        <div class="info-row">
                            <strong>Tổng giá thuê:</strong> <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> VNĐ
                        </div>
                        <c:if test="${sessionScope.userRole == 'Manager' || sessionScope.userRole == 'Admin'}">
                            <div class="info-row" style="background-color: #eef9f0; padding: 8px; border-radius: 4px; border-left: 3px solid #198754;">
                                <strong>Thực nhận sau trừ phí (10%):</strong>
                                <span style="font-weight: 700; color: #198754;">
                                    <fmt:formatNumber value="${order.totalPrice * 0.9}" pattern="#,##0"/> VNĐ
                                </span>
                            </div>
                        </c:if>
                        
                        <c:if test="${sessionScope.userRole != 'Manager'}">
                            <!-- Tiền cọc chi tiết -->
                            <c:choose>
                                <c:when test="${not empty order.trustBasedMultiplier and order.trustBasedMultiplier > 0 and order.trustBasedMultiplier < 1.0}">
                                    <c:set var="baseDeposit" value="${order.adjustedDepositAmount / order.trustBasedMultiplier}" />
                                    <div class="info-row">
                                        <strong>Tiền cọc gốc:</strong> 
                                        <span style="text-decoration: line-through; color: #999;">
                                            <fmt:formatNumber value="${baseDeposit}" pattern="#,##0"/> VNĐ
                                        </span>
                                    </div>
                                    <div class="info-row" style="background-color: #e8f5e9; padding: 8px; border-radius: 4px;">
                                        <strong style="color: #2e7d32;">Vourcher đặc biệt:</strong> 
                                        <span style="color: #2e7d32; font-weight: bold;">
                                            -<fmt:formatNumber value="${baseDeposit - order.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <strong>Tiền cọc chính thức:</strong> 
                                        <span style="color: #2e7d32; font-weight: bold; font-size: 16px;">
                                            <fmt:formatNumber value="${order.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                                        </span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="info-row">
                                        <strong>Tiền cọc:</strong> <fmt:formatNumber value="${order.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div class="info-row" style="background-color: #f5f5f5; padding: 10px; border-radius: 4px; border-left: 3px solid #cc3399;">
                                <strong style="font-size: 16px; color: #cc3399;">Tổng tiền phải thanh toán:</strong> <span style="font-size: 16px; font-weight: bold; color: #cc3399;"><fmt:formatNumber value="${order.totalPrice + order.adjustedDepositAmount}" pattern="#,##0"/> VNĐ</span>
                            </div>
                        </c:if>
                        <div class="info-row">
                            <strong>Trạng thái:</strong>
                            <span class="status ${order.status.toLowerCase()}">
                                <c:choose>
                                    <c:when test="${order.status == 'PENDING_PAYMENT'}">Chờ thanh toán</c:when>
                                    <c:when test="${order.status == 'PAYMENT_SUBMITTED'}">Đã gửi thanh toán</c:when>
                                    <c:when test="${order.status == 'PAYMENT_VERIFIED'}">Đã xác thực</c:when>
                                    <c:when test="${order.status == 'DELIVERED_PENDING_CONFIRMATION'}">Chờ nhận hàng</c:when>
                                    <c:when test="${order.status == 'RENTED'}">Đang thuê</c:when>
                                    <c:when test="${order.status == 'RETURN_REQUESTED'}">Yêu cầu trả hàng</c:when>
                                    <c:when test="${order.status == 'RETURNED'}">Đã trả hàng</c:when>
                                    <c:when test="${order.status == 'COMPLETED'}">Hoàn thành</c:when>
                                    <c:when test="${order.status == 'ISSUE'}">Có vấn đề</c:when>
                                    <c:otherwise>${order.status}</c:otherwise>
                                </c:choose>
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
            
            <c:if test="${order.status == 'PENDING_PAYMENT' && sessionScope.userRole == 'User'}">
                <a href="${pageContext.request.contextPath}/payment?rentalOrderID=${order.rentalOrderID}" class="btn">Thanh toán</a>
                <form method="POST" action="${pageContext.request.contextPath}/rental">
                    <input type="hidden" name="action" value="cancelOrder">
                    <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}">
                    <button type="submit" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn hủy đơn?')">Hủy đơn</button>
                </form>
            </c:if>

            <c:if test="${order.status == 'DELIVERED_PENDING_CONFIRMATION' && sessionScope.userRole == 'User'}">
                <c:if test="${param.received == 'true'}">
                    <div class="alert alert-success" style="margin-top:12px;">
                        Cảm ơn! Đơn hàng đã được xác nhận là đã nhận. Trạng thái đã chuyển sang "ĐANG THUÊ".
                    </div>
                </c:if>
                <form method="POST" action="${pageContext.request.contextPath}/rental" enctype="multipart/form-data" style="margin-top:12px;">
                    <input type="hidden" name="action" value="confirmReceipt">
                    <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}">
                    <div class="form-group">
                        <label for="receivedImage">Tải ảnh chứng minh đã nhận hàng (tối đa 5MB):</label>
                        <input type="file" id="receivedImage" name="receivedImage" accept="image/*" style="padding:8px; border:1px solid #ddd; border-radius:4px; width:100%; box-sizing:border-box;">
                    </div>
                    <button type="submit" class="btn" style="background-color:#28a745;">Tôi đã nhận hàng</button>
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
            
            <!-- User đã yêu cầu trả hàng - hiển thị thông báo thành công -->
            <c:if test="${param.returnRequested == 'true'}">
                <div class="alert alert-success" style="margin-top:12px;">
                    ✅ Yêu cầu trả hàng đã được gửi! Manager sẽ chọn phương thức nhận hàng sớm.
                </div>
            </c:if>
            
            <c:if test="${param.trackingSubmitted == 'true'}">
                <div class="alert alert-success" style="margin-top:12px;">
                    ✅ Mã vận đơn đã được cập nhật! Manager sẽ theo dõi và xác nhận khi nhận được hàng.
                </div>
            </c:if>
            
            <!-- User đã yêu cầu trả hàng - chờ manager chọn phương thức -->
            <c:if test="${order.status == 'RETURN_REQUESTED' && sessionScope.userRole == 'User'}">
                <c:if test="${empty order.returnMethod}">
                    <div style="margin-top:20px; padding:16px; border:2px solid #ff9800; border-radius:8px; background:#fff3e0;">
                        <h3 style="color:#e65100; margin-top:0;">⏳ Đang chờ xác nhận</h3>
                        <p>Yêu cầu trả hàng của bạn đã được gửi. Manager đang xem xét và sẽ chọn phương thức nhận hàng sớm.</p>
                    </div>
                </c:if>
                
                <c:if test="${not empty order.returnMethod}">
                    <%@ page import="DAO.AccountDAO" %>
                    <%@ page import="Model.Account" %>
                    <%
                        Model.RentalOrder ord = (Model.RentalOrder) request.getAttribute("order");
                        if (ord != null && ord.getManagerID() > 0) {
                            Account mgr = AccountDAO.findById(ord.getManagerID());
                            if (mgr != null) {
                                pageContext.setAttribute("manager", mgr);
                            }
                        }
                    %>
                    
                    <c:choose>
                        <c:when test="${order.returnMethod == 'MANAGER_PICKUP'}">
                            <div style="margin-top:20px; padding:16px; border:2px solid #4caf50; border-radius:8px; background:#e8f5e9;">
                                <h3 style="color:#2e7d32; margin-top:0;">🚗 Manager sẽ đến lấy hàng</h3>
                                <p>Manager sẽ liên hệ với bạn để sắp xếp thời gian lấy hàng.</p>
                                <c:if test="${not empty manager}">
                                    <div style="background:#fff; padding:12px; border-radius:4px; margin-top:12px;">
                                        <strong>Thông tin liên hệ Manager:</strong><br/>
                                        📞 SĐT: ${manager.phoneNumber}<br/>
                                        👤 Tên: ${manager.fullName}
                                    </div>
                                </c:if>
                            </div>
                        </c:when>
                        <c:when test="${order.returnMethod == 'SHIP_TO_MANAGER'}">
                            <div style="margin-top:20px; padding:16px; border:2px solid #2196f3; border-radius:8px; background:#e3f2fd;">
                                <h3 style="color:#1565c0; margin-top:0;">📦 Vui lòng gửi hàng về địa chỉ sau</h3>
                                <c:if test="${not empty manager}">
                                    <div style="background:#fff; padding:16px; border-radius:4px; margin-top:12px; border-left:4px solid #2196f3;">
                                        <div style="margin-bottom:10px;"><strong>📍 Địa chỉ:</strong> ${manager.address}</div>
                                        <div style="margin-bottom:10px;"><strong>📞 SĐT:</strong> ${manager.phoneNumber}</div>
                                        <div><strong>👤 Người nhận:</strong> ${manager.fullName}</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${empty order.returnTrackingNumber}">
                                    <form method="POST" action="${pageContext.request.contextPath}/rental" style="margin-top:16px;">
                                        <input type="hidden" name="action" value="submitReturnTracking" />
                                        <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                                        <label for="returnTracking" style="display:block; margin-bottom:8px; font-weight:600;">Mã vận đơn (sau khi gửi):</label>
                                        <input type="text" id="returnTracking" name="returnTrackingNumber" placeholder="Nhập mã vận đơn" required style="padding:8px; border:1px solid #ddd; border-radius:4px; width:70%; margin-right:8px;" />
                                        <button type="submit" class="btn" style="background-color:#4caf50;">Xác nhận đã gửi</button>
                                    </form>
                                </c:if>
                                
                                <c:if test="${not empty order.returnTrackingNumber}">
                                    <div style="margin-top:16px; padding:12px; background:#fff; border-radius:4px;">
                                        <strong>✅ Mã vận đơn trả hàng:</strong> ${order.returnTrackingNumber}
                                        <p style="color:#666; margin-top:8px;">Đang chờ manager xác nhận nhận hàng.</p>
                                    </div>
                                </c:if>
                            </div>
                        </c:when>
                    </c:choose>
                </c:if>
            </c:if>
            
            <!-- Đơn hàng đã trả về - thông báo cho user -->
            <c:if test="${order.status == 'RETURNED' && sessionScope.userRole == 'User'}">
                <c:if test="${param.returnConfirmed == 'true'}">
                    <div class="alert alert-success" style="margin-top:12px;">
                        ✅ Manager đã xác nhận nhận hàng trả về! 
                    </div>
                </c:if>
                <div style="margin-top:20px; padding:20px; border:2px solid #4caf50; border-radius:8px; background:#e8f5e9;">
                    <h3 style="color:#2e7d32; margin-top:0;">✅ Đã trả hàng thành công</h3>
                    <p>Manager đã xác nhận nhận được hàng trả về. Admin đang xử lý hoàn tiền cọc cho bạn.</p>
                    <p style="color:#666; margin-bottom:0;">Vui lòng chờ thông báo từ admin về việc hoàn tiền.</p>
                </div>
            </c:if>
            
            <c:if test="${order.status == 'ISSUE'}">
                <c:if test="${param.issueReported == 'true'}">
                    <div class="alert alert-success" style="margin-top:12px;">
                        Vấn đề đã được báo cáo thành công! Manager sẽ kiểm tra và xử lý sớm.
                    </div>
                </c:if>
                <a href="${pageContext.request.contextPath}/orderissue?rentalOrderID=${order.rentalOrderID}" class="btn" style="background-color:#ff6600; margin-top:16px;">
                    Chi tiết vấn đề
                </a>
            </c:if>
            
            <c:if test="${order.status == 'COMPLETED'}">
                <c:if test="${sessionScope.userRole == 'User' && sessionScope.accountID != order.managerID}">
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

            <c:if test="${sessionScope.userRole == 'Manager'}">
                <!-- Manager chọn phương thức nhận hàng khi user yêu cầu trả -->
                <c:if test="${order.status == 'RETURN_REQUESTED' && empty order.returnMethod}">
                    <div style="margin-top:20px; padding:20px; border:2px solid #ff9800; border-radius:8px; background:#fff3e0;">
                        <h3 style="color:#e65100; margin-top:0;">⚠️ Khách hàng yêu cầu trả hàng</h3>
                        <p style="margin-bottom:16px;">Vui lòng chọn phương thức nhận hàng:</p>
                        <form method="POST" action="${pageContext.request.contextPath}/manager" style="margin-bottom:12px;">
                            <input type="hidden" name="action" value="setReturnMethod" />
                            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                            <input type="hidden" name="returnMethod" value="MANAGER_PICKUP" />
                            <button type="submit" class="btn" style="background-color:#4caf50;">🚗 Tôi sẽ đến lấy hàng trực tiếp</button>
                        </form>
                        <form method="POST" action="${pageContext.request.contextPath}/manager">
                            <input type="hidden" name="action" value="setReturnMethod" />
                            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                            <input type="hidden" name="returnMethod" value="SHIP_TO_MANAGER" />
                            <button type="submit" class="btn" style="background-color:#2196f3;">📦 Khách gửi về địa chỉ của tôi</button>
                        </form>
                    </div>
                </c:if>
                
                <!-- Manager xác nhận đã nhận hàng trả về -->
                <c:if test="${order.status == 'RETURN_REQUESTED' && not empty order.returnMethod}">
                    <div style="margin-top:20px; padding:20px; border:2px solid #2196f3; border-radius:8px; background:#e3f2fd;">
                        <h3 style="color:#1565c0; margin-top:0;">📦 Đang chờ nhận hàng trả về</h3>
                        
                        <c:choose>
                            <c:when test="${order.returnMethod == 'MANAGER_PICKUP'}">
                                <p>Bạn đã chọn <strong>đến lấy hàng trực tiếp</strong>.</p>
                                <p style="color:#666;">Sau khi lấy hàng từ khách hàng, vui lòng xác nhận bên dưới.</p>
                            </c:when>
                            <c:when test="${order.returnMethod == 'SHIP_TO_MANAGER'}">
                                <p>Khách hàng đang gửi hàng về địa chỉ của bạn.</p>
                                <c:if test="${not empty order.returnTrackingNumber}">
                                    <div style="background:#fff; padding:12px; border-radius:4px; margin:12px 0;">
                                        <strong>📍 Mã vận đơn:</strong> ${order.returnTrackingNumber}
                                    </div>
                                    <p style="color:#666;">Sau khi nhận được hàng, vui lòng xác nhận bên dưới.</p>
                                </c:if>
                                <c:if test="${empty order.returnTrackingNumber}">
                                    <p style="color:#ff9800;">⏳ Đang chờ khách hàng cập nhật mã vận đơn...</p>
                                </c:if>
                            </c:when>
                        </c:choose>
                        
                        <form method="POST" action="${pageContext.request.contextPath}/manager" style="margin-top:16px;">
                            <input type="hidden" name="action" value="confirmReturnReceived" />
                            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                            <button type="submit" class="btn" style="background-color:#4caf50;" onclick="return confirm('Xác nhận bạn đã nhận được hàng trả về từ khách hàng?')">
                                ✅ Xác nhận đã nhận hàng trả về
                            </button>
                        </form>
                    </div>
                </c:if>
                
                <c:if test="${order.status == 'PAYMENT_VERIFIED'}">
                    <form method="POST" action="${pageContext.request.contextPath}/manager" style="margin-top:16px;">
                        <input type="hidden" name="action" value="shipOrder" />
                        <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                        <input type="text" name="trackingNumber" placeholder="Mã tracking" required style="padding:6px 8px; margin-right:6px;" />
                        <button type="submit" class="btn btn-success">Bàn giao (Gửi)</button>
                    </form>
                </c:if>
                <c:if test="${not empty order.trackingNumber}">
                    <div style="margin-top:12px; padding:12px; border:1px solid #e1e5ee; border-radius:6px; background:#f1f7ff;">
                        <strong>Mã vận đơn:</strong> ${order.trackingNumber}
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

    <!-- Payment proof preview (visible only to Admin or the renter user) -->
    <c:if test="${sessionScope.userRole eq 'Admin' || (not empty sessionScope.accountID and not empty order.renterUserID and sessionScope.accountID eq order.renterUserID)}">
        <c:set var="proofPath" value="" />
        <c:if test="${not empty payment and not empty payment.paymentProofImage}">
            <c:set var="proofPath" value="${payment.paymentProofImage}" />
        </c:if>
        <c:if test="${empty proofPath and not empty order.paymentProofImage}">
            <c:set var="proofPath" value="${order.paymentProofImage}" />
        </c:if>
        <c:choose>
            <c:when test="${not empty proofPath}">
                <c:set var="proofLower" value="${fn:toLowerCase(proofPath)}" />
                <div style="margin-top:24px; padding:16px; border:1px solid #e1e5ee; border-radius:8px; background:#f9fbff;">
                    <h3 style="margin-top:0;">Ảnh chứng minh thanh toán</h3>
                    <c:choose>
                        <c:when test="${fn:endsWith(proofLower, '.pdf')}">
                            <a href="${pageContext.request.contextPath}/image?path=${proofPath}" target="_blank" class="btn">Xem file chứng minh</a>
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/image?path=${proofPath}" alt="Payment proof" style="max-width:100%; border-radius:6px; border:1px solid #dce3f0;">
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:when>
        </c:choose>
    </c:if>

    <!-- Received proof preview -->
    <c:if test="${not empty order.receivedProofImage}">
        <c:set var="receivedLower" value="${fn:toLowerCase(order.receivedProofImage)}" />
        <div style="margin-top:16px; padding:16px; border:1px solid #e1e5ee; border-radius:8px; background:#fff8f0;">
            <h3 style="margin-top:0;">Ảnh chứng minh đã nhận hàng</h3>
            <c:choose>
                <c:when test="${fn:endsWith(receivedLower, '.pdf')}">
                    <a href="${pageContext.request.contextPath}/image?path=${order.receivedProofImage}" target="_blank" class="btn">Xem file chứng minh</a>
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/image?path=${order.receivedProofImage}" alt="Received proof" style="max-width:100%; border-radius:6px; border:1px solid #dce3f0;">
                </c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <!-- Tracking info (non-manager) -->
    <c:if test="${sessionScope.userRole != 'Manager' && not empty order.trackingNumber}">
        <div style="margin-top:12px; padding:12px; border:1px solid #e1e5ee; border-radius:6px; background:#f1f7ff;">
            <strong>Mã vận đơn:</strong> ${order.trackingNumber}
        </div>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
