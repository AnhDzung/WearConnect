<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết hoàn lại cọc - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .container { max-width: 800px; margin: 20px auto; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .status-badge { display: inline-block; padding: 8px 16px; border-radius: 20px; font-weight: bold; margin: 10px 0; text-align: center; }
        .status-no-damage { background-color: #d4edda; color: #155724; }
        .status-late-return { background-color: #fff3cd; color: #856404; }
        .status-minor-damage { background-color: #f8d7da; color: #721c24; }
        .status-lost { background-color: #f5c6cb; color: #721c24; }
        .info-box { background-color: #e8f4f8; border: 1px solid #b8e0e8; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .info-box h4 { margin-top: 0; color: #0c5460; }
        .calculation-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .calculation-table th { background-color: #007bff; color: white; padding: 12px; text-align: left; }
        .calculation-table td { padding: 12px; border-bottom: 1px solid #ddd; }
        .calculation-table tr:hover { background-color: #f9f9f9; }
        .row-label { font-weight: bold; color: #333; width: 60%; }
        .row-value { text-align: right; color: #333; }
        .row-total { background-color: #f0f0f0; font-weight: bold; }
        .amount-positive { color: #28a745; font-weight: bold; }
        .amount-negative { color: #dc3545; font-weight: bold; }
        .summary-box { background-color: #f9f9f9; padding: 20px; border-radius: 4px; margin: 20px 0; }
        .summary-row { display: flex; justify-content: space-between; margin: 10px 0; font-size: 16px; }
        .summary-row.total { font-size: 20px; font-weight: bold; color: #333; border-top: 2px solid #ddd; padding-top: 10px; margin-top: 10px; }
        .refund-status-good { color: #28a745; }
        .refund-status-charge { color: #dc3545; }
        .order-info { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
        .info-item { padding: 10px; background-color: #f9f9f9; border-radius: 4px; border-left: 4px solid #007bff; }
        .info-label { font-size: 12px; color: #666; font-weight: bold; text-transform: uppercase; }
        .info-value { font-size: 16px; color: #333; margin-top: 5px; font-weight: bold; }
        .timeline { margin: 20px 0; }
        .timeline-item { padding: 10px; border-left: 4px solid #007bff; margin: 10px 0; }
        .timeline-item.date { border-left-color: #28a745; }
        .timeline-item.fee { border-left-color: #dc3545; }
        .timeline-item.compensation { border-left-color: #ffc107; }
        .btn-group { display: flex; gap: 10px; margin-top: 20px; }
        button { padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold; }
        .btn-primary { background-color: #007bff; color: white; flex: 1; }
        .btn-primary:hover { background-color: #0056b3; }
        .btn-print { background-color: #6c757d; color: white; flex: 1; }
        .btn-print:hover { background-color: #5a6268; }
        @media print { .btn-group { display: none; } }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <h1>📋 Chi Tiết Hoàn Lại Cọc</h1>
    
    <c:if test="${order != null && refundDetails != null}">
        
        <!-- Status -->
        <div style="text-align: center;">
            <c:choose>
                <c:when test="${order.returnStatus == 'NO_DAMAGE'}">
                    <div class="status-badge status-no-damage">✓ Không hư hỏng - Hoàn 100%</div>
                </c:when>
                <c:when test="${order.returnStatus == 'LATE_RETURN'}">
                    <div class="status-badge status-late-return">⏰ Trả trễ - Trừ phí trễ hạn</div>
                </c:when>
                <c:when test="${order.returnStatus == 'MINOR_DAMAGE'}">
                    <div class="status-badge status-minor-damage">⚠️ Hư hỏng nhẹ - Trừ bồi thường</div>
                </c:when>
                <c:when test="${order.returnStatus == 'LOST'}">
                    <div class="status-badge status-lost">❌ Mất đồ - Trừ toàn bộ giá trị</div>
                </c:when>
            </c:choose>
        </div>
        
        <!-- Order Information -->
        <div class="order-info">
            <div class="info-item">
                <div class="info-label">Mã đơn hàng</div>
                <div class="info-value">${order.orderCode}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Sản phẩm</div>
                <div class="info-value">${order.clothingName}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Ngày kết thúc thuê</div>
                <div class="info-value">${order.formattedEndDate}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Ngày trả thực tế</div>
                <div class="info-value">
                    <fmt:formatDate value="${order.actualReturnDate}" pattern="dd/MM/yyyy HH:mm"/>
                </div>
            </div>
        </div>
        
        <!-- Calculation Details -->
        <div class="info-box">
            <h4>📊 Chi Tiết Tính Toán</h4>
            
            <table class="calculation-table">
                <thead>
                    <tr>
                        <th colspan="2">Hạng Mục</th>
                        <th>Số Tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="2" class="row-label">Tiền cọc đã thanh toán</td>
                        <td class="row-value"><fmt:formatNumber value="${refundDetails.originalDeposit}" pattern="#,###" /> ₫</td>
                    </tr>
                    
                    <c:if test="${refundDetails.lateFee > 0}">
                        <tr>
                            <td colspan="2" class="row-label">
                                ⏰ Phí trả trễ 
                                <small>(${order.lateFees > 0 ? 'Trễ ' : ''} ×150%)</small>
                            </td>
                            <td class="row-value amount-negative">- <fmt:formatNumber value="${refundDetails.lateFee}" pattern="#,###" /> ₫</td>
                        </tr>
                    </c:if>
                    
                    <c:if test="${refundDetails.compensationAmount > 0}">
                        <tr>
                            <td colspan="2" class="row-label">
                                <c:choose>
                                    <c:when test="${order.returnStatus == 'MINOR_DAMAGE'}">
                                        ⚠️ Bồi thường hư hỏng (${order.damagePercentage * 100}%)
                                    </c:when>
                                    <c:otherwise>
                                        ❌ Giá trị sản phẩm (Mất đồ)
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="row-value amount-negative">- <fmt:formatNumber value="${refundDetails.compensationAmount}" pattern="#,###" /> ₫</td>
                        </tr>
                    </c:if>
                    
                    <tr class="row-total">
                        <td colspan="2" class="row-label">Tổng trừ</td>
                        <td class="row-value amount-negative">- <fmt:formatNumber value="${refundDetails.totalDeduction}" pattern="#,###" /> ₫</td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <!-- Refund Summary -->
        <div class="summary-box">
            <h4 style="margin-top: 0;">💰 Tóm Tắt Hoàn Lại</h4>
            
            <div class="summary-row">
                <span>Tiền cọc ban đầu:</span>
                <span><fmt:formatNumber value="${refundDetails.originalDeposit}" pattern="#,###" /> ₫</span>
            </div>
            
            <c:if test="${refundDetails.totalDeduction > 0}">
                <div class="summary-row">
                    <span>Tổng trừ tiền:</span>
                    <span class="amount-negative"><fmt:formatNumber value="${refundDetails.totalDeduction}" pattern="#,###" /> ₫</span>
                </div>
            </c:if>
            
            <div class="summary-row total">
                <span>Bạn sẽ nhận lại:</span>
                <span class="refund-status-good">
                    <fmt:formatNumber value="${refundDetails.refundAmount}" pattern="#,###" /> ₫
                </span>
            </div>
            
            <c:if test="${refundDetails.additionalCharges > 0}">
                <div class="summary-row total">
                    <span>Hoặc bạn phải thanh toán thêm:</span>
                    <span class="refund-status-charge">
                        <fmt:formatNumber value="${refundDetails.additionalCharges}" pattern="#,###" /> ₫
                    </span>
                </div>
            </c:if>
        </div>
        
        <!-- Timeline -->
        <div class="info-box">
            <h4>📅 Thời Gian Xử Lý</h4>
            <div class="timeline">
                <div class="timeline-item date">
                    <strong>Ngày kết thúc thuê:</strong> ${order.formattedEndDate}
                </div>
                <div class="timeline-item date">
                    <strong>Ngày trả thực tế:</strong> <fmt:formatDate value="${order.actualReturnDate}" pattern="dd/MM/yyyy HH:mm"/>
                </div>
                <div class="timeline-item">
                    <strong>Xử lý hoàn lại:</strong> Trong 1-2 ngày làm việc
                </div>
                <div class="timeline-item">
                    <strong>Phương thức:</strong> Chuyển khoản về tài khoản gốc
                </div>
            </div>
        </div>
        
        <!-- Notes -->
        <c:if test="${order.damagePercentage > 0}">
            <div class="info-box">
                <h4>⚠️ Chi Tiết Hư Hỏng</h4>
                <p><strong>Mức độ hư hỏng:</strong> ${order.damagePercentage * 100}%</p>
                <p><strong>Bồi thường:</strong> <fmt:formatNumber value="${refundDetails.compensationAmount}" pattern="#,###" /> ₫</p>
            </div>
        </c:if>
        
        <!-- Action Buttons -->
        <div class="btn-group">
            <button type="button" class="btn-print" onclick="window.print()">🖨️ In chi tiết</button>
            <button type="button" class="btn-primary" onclick="window.location.href='${pageContext.request.contextPath}/user?action=orders'">Quay lại danh sách đơn hàng</button>
        </div>
        
    </c:if>
    
    <c:if test="${order == null || refundDetails == null}">
        <div class="info-box">
            <strong>⚠️ Lỗi:</strong> Không tìm thấy thông tin hoàn lại cọc
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
