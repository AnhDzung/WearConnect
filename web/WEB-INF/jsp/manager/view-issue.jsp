<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết vấn đề - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
        .back-btn { padding: 10px 20px; background-color: #6c757d; color: white; border: none; cursor: pointer; margin-bottom: 20px; border-radius: 4px; }
        .back-btn:hover { background-color: #5a6268; }
        
        .content-wrapper { display: flex; gap: 30px; }
        .issue-info { flex: 1; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .issue-image { width: 300px; flex-shrink: 0; }
        
        .issue-image img { width: 100%; max-height: 400px; object-fit: cover; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); }
        .no-image { background-color: #f0f0f0; padding: 60px 20px; text-align: center; color: #999; border-radius: 8px; }
        
        .issue-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
        .issue-type { display: inline-block; padding: 8px 16px; background-color: #fff3cd; color: #856404; border-radius: 20px; font-weight: 600; font-size: 14px; }
        
        .field-group { margin-bottom: 25px; }
        .field-label { color: #666; font-size: 13px; font-weight: 600; text-transform: uppercase; margin-bottom: 5px; }
        .field-value { color: #333; font-size: 15px; padding: 12px 0; }
        
        .status-badge { display: inline-block; padding: 8px 16px; border-radius: 20px; font-weight: 600; font-size: 12px; }
        .status-pending { background-color: #fff3cd; color: #856404; }
        .status-acknowledged { background-color: #cfe2ff; color: #084298; }
        .status-resolved { background-color: #d1e7dd; color: #0f5132; }
        .status-rejected { background-color: #f8d7da; color: #842029; }
        
        .action-section { background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin-top: 30px; }
        .action-section h3 { color: #333; margin-top: 0; }
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: #333; font-weight: 600; margin-bottom: 8px; }
        .form-group select, .form-group textarea { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-family: inherit; font-size: 14px; }
        .form-group textarea { resize: vertical; min-height: 120px; }
        
        .btn-group { display: flex; gap: 10px; }
        .btn { padding: 10px 20px; border: none; cursor: pointer; border-radius: 4px; font-weight: 600; font-size: 14px; transition: 0.3s; }
        .btn-success { background-color: #198754; color: white; }
        .btn-success:hover { background-color: #157347; }
        .btn-danger { background-color: #dc3545; color: white; }
        .btn-danger:hover { background-color: #c82333; }
        .btn-secondary { background-color: #6c757d; color: white; }
        .btn-secondary:hover { background-color: #5a6268; }
        
        .success-message { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 12px 16px; border-radius: 4px; margin-bottom: 20px; }
        .error-message { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 4px; margin-bottom: 20px; }
        
        .order-info { background-color: #f0f7ff; padding: 15px; border-left: 4px solid #0066cc; margin-bottom: 20px; border-radius: 4px; }
        .order-info-item { display: inline-block; margin-right: 30px; }
        .order-info-label { color: #666; font-size: 12px; }
        .order-info-value { color: #333; font-weight: 600; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <button onclick="history.back()" class="back-btn">← Quay lại</button>
    
    <c:if test="${param.success}">
        <div class="success-message">✓ Cập nhật trạng thái vấn đề thành công!</div>
    </c:if>
    
    <c:if test="${empty issue}">
        <div style="background: white; padding: 40px; text-align: center; color: #666; border-radius: 8px;">
            Không tìm thấy vấn đề nào cho đơn hàng này
        </div>
    </c:if>
    
    <c:if test="${not empty issue}">
        <div class="issue-info" style="grid-column: 1 / -1;">
            <div class="issue-header">
                <h2 style="margin: 0; flex: 1;">Chi tiết vấn đề</h2>
                <span class="status-badge status-${issue.status.toLowerCase()}">
                    <c:choose>
                        <c:when test="${issue.status == 'PENDING'}">⏳ Chờ xử lý</c:when>
                        <c:when test="${issue.status == 'ACKNOWLEDGED'}">👍 Đã xác nhận</c:when>
                        <c:when test="${issue.status == 'RESOLVED'}">✓ Đã giải quyết</c:when>
                        <c:when test="${issue.status == 'REJECTED'}">✗ Đã từ chối</c:when>
                        <c:otherwise>${issue.status}</c:otherwise>
                    </c:choose>
                </span>
            </div>
            
            <div class="order-info">
                <div class="order-info-item">
                    <div class="order-info-label">Mã đơn hàng</div>
                    <div class="order-info-value">${order.orderCode}</div>
                </div>
                <div class="order-info-item">
                    <div class="order-info-label">Sản phẩm</div>
                    <div class="order-info-value">${order.clothingName}</div>
                </div>
                <div class="order-info-item">
                    <div class="order-info-label">Người thuê</div>
                        <div class="order-info-value">
                            <c:choose>
                                <c:when test="${not empty order.renterUsername}">${order.renterUsername}</c:when>
                                <c:otherwise>ID: ${order.renterUserID}</c:otherwise>
                            </c:choose>
                        </div>
                </div>
            </div>
            
            <div style="display: flex; gap: 30px;">
                <div style="flex: 1;">
                    <div class="field-group">
                        <div class="field-label">Loại vấn đề</div>
                        <div>
                            <span class="issue-type">
                                <c:choose>
                                    <c:when test="${issue.issueType == 'WRONG_ITEM'}">❌ Hàng sai</c:when>
                                    <c:when test="${issue.issueType == 'DAMAGED'}">💔 Hàng bị hỏng</c:when>
                                    <c:when test="${issue.issueType == 'WRONG_SIZE'}">📏 Size sai</c:when>
                                    <c:when test="${issue.issueType == 'COLOR_MISMATCH'}">🎨 Màu sai</c:when>
                                    <c:when test="${issue.issueType == 'OTHER'}">❓ Khác</c:when>
                                    <c:otherwise>${issue.issueType}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                    
                    <div class="field-group">
                        <div class="field-label">Mô tả vấn đề</div>
                        <div class="field-value" style="white-space: pre-wrap; line-height: 1.6;">${issue.description}</div>
                    </div>
                    
                    <div class="field-group">
                        <div class="field-label">Ngày báo cáo</div>
                        <div class="field-value">
                            <c:choose>
                                <c:when test="${not empty issueCreatedAtDate}">
                                    <fmt:formatDate value="${issueCreatedAtDate}" pattern="dd/MM/yyyy HH:mm" />
                                </c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <c:if test="${not empty issueResolvedAtDate}">
                        <div class="field-group">
                            <div class="field-label">Ngày giải quyết</div>
                            <div class="field-value">
                                <fmt:formatDate value="${issueResolvedAtDate}" pattern="dd/MM/yyyy HH:mm" />
                            </div>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty issue.notes}">
                        <div class="field-group">
                            <div class="field-label">Ghi chú từ quản lý</div>
                            <div class="field-value" style="background-color: #f0f0f0; padding: 12px; border-radius: 4px; white-space: pre-wrap; line-height: 1.6;">${issue.notes}</div>
                        </div>
                    </c:if>
                </div>
                
                <div class="issue-image">
                    <c:if test="${not empty issue.imageData}">
                        <img src="${pageContext.request.contextPath}/image?issueID=${issue.issueID}" alt="Ảnh vấn đề" />
                    </c:if>
                    <c:if test="${empty issue.imageData}">
                        <div class="no-image">
                            <div style="font-size: 40px; margin-bottom: 10px;">📷</div>
                            Không có ảnh
                        </div>
                    </c:if>
                </div>
            </div>
            
            <c:if test="${issue.status != 'RESOLVED' && issue.status != 'REJECTED'}">
                <div class="action-section">
                    <h3>Xử lý vấn đề</h3>
                    <form method="POST" action="${pageContext.request.contextPath}/manager">
                        <input type="hidden" name="action" value="updateIssue" />
                        <input type="hidden" name="issueID" value="${issue.issueID}" />
                        
                        <div class="form-group">
                            <label for="issueStatus">Trạng thái</label>
                            <select id="issueStatus" name="issueStatus" required>
                                <option value="ACKNOWLEDGED" <c:if test="${issue.status == 'ACKNOWLEDGED'}">selected</c:if>>Xác nhận - Đã nhận</option>
                                <option value="RESOLVED">Giải quyết - Vấn đề đã xử lý</option>
                                <option value="REJECTED">Từ chối - Không công nhận vấn đề</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="notes">Ghi chú xử lý</label>
                            <textarea id="notes" name="notes" placeholder="Nhập ghi chú về cách xử lý vấn đề...">${issue.notes}</textarea>
                        </div>
                        
                        <div class="field-group">
                            <div class="field-label">Ngày báo cáo</div>
                            <div class="field-value">
                                <c:choose>
                                    <c:when test="${not empty issueCreatedAtDate}">
                                        <fmt:formatDate value="${issueCreatedAtDate}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>--</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    
                        <c:if test="${not empty issueResolvedAtDate}">
                            <div class="field-group">
                                <div class="field-label">Ngày giải quyết</div>
                                <div class="field-value">
                                    <fmt:formatDate value="${issueResolvedAtDate}" pattern="dd/MM/yyyy HH:mm" />
                                </div>
                            </div>
                        </c:if>
                        
                        <div class="btn-group">
                            <button type="submit" class="btn btn-success">💾 Lưu</button>
                            <button type="button" onclick="history.back()" class="btn btn-secondary">❌ Hủy</button>
                        </div>
                    </form>

                    <div style="margin-top:20px; display:flex; gap:10px; flex-wrap: wrap;">
                        <form method="POST" action="${pageContext.request.contextPath}/manager">
                            <input type="hidden" name="action" value="updateStatus" />
                            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                            <input type="hidden" name="status" value="RENTED" />
                            <button type="submit" class="btn btn-info">🔄 Đổi hàng (đưa về RENTED)</button>
                        </form>
                        <form method="POST" action="${pageContext.request.contextPath}/manager">
                            <input type="hidden" name="action" value="updateStatus" />
                            <input type="hidden" name="rentalOrderID" value="${order.rentalOrderID}" />
                            <input type="hidden" name="status" value="RETURNED" />
                            <button type="submit" class="btn btn-danger">✖ Hủy đơn hàng (yêu cầu trả)</button>
                        </form>
                    </div>
                </div>
            </c:if>

            <c:if test="${issue.status == 'RESOLVED' || issue.status == 'REJECTED'}">
                <div class="action-section">
                    <div style="text-align: center; color: #666; padding: 20px;">
                        <p>Vấn đề này đã được xử lý và không thể chỉnh sửa</p>
                    </div>
                </div>
            </c:if>
        </div>
    </c:if>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
