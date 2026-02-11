<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đơn thuê của tôi - WearConnect</title>
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
        
        .btn { 
            padding: 8px 14px; 
            background-color: #0d6efd; 
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
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>Các đơn thuê của tôi</h1>
    <button onclick="history.back()" style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 20px;">Quay lại</button>
    
    <c:if test="${param.success}">
        <div style="color: green; padding: 10px; background-color: #d4edda; margin-bottom: 20px;">
            Thao tác thành công!
        </div>
    </c:if>
    
    <c:if test="${param.error}">
        <div style="color: red; padding: 10px; background-color: #f8d7da; margin-bottom: 20px;">
            Đã xảy ra lỗi. Vui lòng thử lại!
        </div>
    </c:if>
    
    <c:if test="${empty myOrders}">
        <div style="background: white; padding: 40px; text-align: center; color: #666; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            Bạn chưa có đơn thuê nào.
        </div>
    </c:if>
    
    <c:if test="${not empty myOrders}">
        <table>
            <thead>
                <tr>
                    <th>Mã đơn hàng</th>
                    <th>Quần áo</th>
                    <th>Ngày bắt đầu</th>
                    <th>Ngày kết thúc</th>
                    <th>Tổng giá</th>
                    <th>Trạng thái</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="order" items="${myOrders}">
                    <tr>
                        <td>${order.orderCode}</td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty order.clothingName}">${order.clothingName}</c:when>
                                <c:otherwise>${order.clothingID}</c:otherwise>
                            </c:choose>
                        </td>
                        <td>${order.formattedStartDate}</td>
                        <td>${order.formattedEndDate}</td>
                        <td><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> VNĐ</td>
                        <td>
                            <span class="status ${order.status.toLowerCase()}">
                                <c:choose>
                                    <c:when test="${order.status == 'PENDING'}">Chờ duyệt</c:when>
                                    <c:when test="${order.status == 'VERIFYING'}">Đang xác minh</c:when>
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
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
