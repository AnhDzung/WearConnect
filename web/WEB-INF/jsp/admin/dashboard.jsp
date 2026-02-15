<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="Model.Account" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WearConnect - Admin Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: cursive;
            background-color: #f5f5f5;
        }
        
        .btn-logout {
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
            background-color: #dc3545;
            color: white;
        }
        
        .btn-logout:hover {
            background-color: #c82333;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .control-panel {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            display: flex;
            gap: 10px;
            align-items: center;
            justify-content: space-between;
        }
        
        .btn {
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        
        .btn-add {
            background-color: #28a745;
            color: white;
        }
        
        .btn-add:hover {
            background-color: #218838;
        }
        
        .btn-refresh {
            background-color: #17a2b8;
            color: white;
        }
        
        .btn-refresh:hover {
            background-color: #138496;
        }
        
        .btn-delete {
            background-color: #dc3545;
            color: white;
            font-size: 12px;
            padding: 6px 10px;
        }
        
        .btn-delete:hover {
            background-color: #c82333;
        }
        
        .btn-toggle {
            background-color: #ffc107;
            color: black;
            font-size: 12px;
            padding: 5px 10px;
        }
        
        .btn-toggle:hover {
            background-color: #e0a800;
        }
        
        .table-container {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background-color: #667eea;
            color: white;
        }
        
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }
        
        tbody tr:hover {
            background-color: #f9f9f9;
        }
        
        .status-active {
            color: #28a745;
            font-weight: 600;
        }
        
        .status-inactive {
            color: #dc3545;
            font-weight: 600;
        }

        .status-pending {
            color: #ff9800;
            font-weight: 600;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            align-items: center;
            justify-content: center;
        }
        .modal.show { display: flex; }
        .modal-content {
            background: white;
            padding: 20px;
            border-radius: 8px;
            width: 90%;
            max-width: 520px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }
        .modal-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 16px; }
        .reason-list { display: grid; gap: 8px; margin-top: 8px; }
        .reason-note { width: 100%; min-height: 80px; padding: 8px; border: 1px solid #ddd; border-radius: 6px; }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .empty-message {
            text-align: center;
            padding: 40px;
            color: #666;
            font-size: 16px;
        }

        .tab-navigation {
            display: flex;
            gap: 0;
            margin-bottom: 20px;
            border-bottom: 2px solid #ddd;
        }

        .tab-button {
            padding: 12px 20px;
            border: none;
            background: none;
            cursor: pointer;
            font-size: 16px;
            font-family: cursive;
            font-weight: 600;
            color: #666;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
            margin-bottom: -2px;
        }

        .tab-button:hover {
            color: #333;
        }

        .tab-button.active {
            color: #1f8e74;
            border-bottom-color: #1f8e74;
        }
    
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />
    
    <%
        Account admin = (Account) session.getAttribute("account");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
    %>
    
    <div class="container">
        <c:if test="${newOrdersCount > 0}">
            <div style="background:#fff3cd; border:1px solid #ffeeba; color:#856404; padding:14px 16px; border-radius:8px; margin-bottom:16px; box-shadow:0 2px 6px rgba(0,0,0,0.05);">
                <strong>🔔 Có ${newOrdersCount} đơn hàng cần xác nhận.</strong>
                <span>(PENDING: ${pendingCount}, VERIFYING: ${verifyingCount})</span>
                <c:choose>
                    <c:when test="${pendingCount > 0}">
                        <a href="${pageContext.request.contextPath}/admin?action=orders&status=PENDING" style="margin-left:12px; color:#0d6efd; font-weight:600;">Xem đơn cần duyệt</a>
                    </c:when>
                    <c:when test="${verifyingCount > 0}">
                        <a href="${pageContext.request.contextPath}/admin?action=orders&status=VERIFYING" style="margin-left:12px; color:#0d6efd; font-weight:600;">Xem đơn cần duyệt</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/admin?action=orders&status=ALL" style="margin-left:12px; color:#0d6efd; font-weight:600;">Xem đơn cần duyệt</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <div class="tab-navigation">
            <button type="button" class="tab-button ${view eq 'products' ? 'active' : ''}" 
                    onclick="location.href='${pageContext.request.contextPath}/admin'">
                 Quản lý sản phẩm
            </button>
            <button type="button" class="tab-button ${view eq 'users' ? 'active' : ''}" 
                    onclick="location.href='${pageContext.request.contextPath}/admin?action=users'">
                 Quản lý người dùng
            </button>
        </div>

        <c:if test="${view eq 'products'}">
        <div class="control-panel">
            <div><strong>Danh sách sản phẩm của tất cả manager</strong></div>
            <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;">
                <button type="submit" class="btn btn-refresh">Làm Mới</button>
            </form>
        </div>

        <div class="table-container">
            <%
                @SuppressWarnings("unchecked")
                List<Model.Clothing> products = (List<Model.Clothing>) request.getAttribute("products");
                @SuppressWarnings("unchecked")
                java.util.Map<Integer, Model.Account> managerMap = (java.util.Map<Integer, Model.Account>) request.getAttribute("managerMap");

                if (products != null && !products.isEmpty()) {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên sản phẩm</th>
                            <th>Danh mục</th>
                            <th>Manager</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Model.Clothing p : products) {
                                Model.Account m = managerMap != null ? managerMap.get(p.getRenterID()) : null;
                                String status = p.getClothingStatus();
                        %>
                            <tr>
                                <td><%= p.getClothingID() %></td>
                                <td><%= p.getClothingName() %></td>
                                <td><%= p.getCategory() %></td>
                                <td><%= m != null ? m.getFullName() : ("ID " + p.getRenterID()) %></td>
                                <td>
                                    <% if ("ACTIVE".equals(status) || "APPROVED_COSPLAY".equals(status)) { %>
                                        <span class="status-active">Hoạt động</span>
                                    <% } else if ("INACTIVE".equals(status)) { %>
                                        <span class="status-inactive">Không hoạt động</span>
                                    <% } else { %>
                                        <span class="status-pending">Chờ duyệt</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <button type="button" class="btn btn-add" onclick="viewProductDetails(<%= p.getClothingID() %>)">Chi tiết</button>
                                        <button type="button" class="btn btn-delete" onclick="openDeactivateModal(<%= p.getClothingID() %>)">Xóa</button>
                                        <% if ("PENDING_REVIEW".equals(status) || "PENDING_COSPLAY_REVIEW".equals(status)) { %>
                                            <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;">
                                                <input type="hidden" name="action" value="approveProduct">
                                                <input type="hidden" name="clothingID" value="<%= p.getClothingID() %>">
                                                <button type="submit" class="btn btn-add">Duyệt lại</button>
                                            </form>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            <%
                } else {
            %>
                <div class="empty-message">Không có sản phẩm nào để hiển thị.</div>
            <%
                }
            %>
        </div>
        </c:if>

        <c:if test="${view eq 'users'}">
        <div class="control-panel">
            <div><strong>Danh sách người dùng</strong></div>
            <form method="GET" action="<%= request.getContextPath() %>/admin?action=users" style="display: inline;">
                <button type="submit" class="btn btn-refresh">Làm Mới</button>
            </form>
        </div>

        <div class="table-container">
            <%
                @SuppressWarnings("unchecked")
                List<Model.Account> users = (List<Model.Account>) request.getAttribute("users");
                
                if (users != null && !users.isEmpty()) {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên người dùng</th>
                            <th>Email</th>
                            <th>Họ và tên</th>
                            <th>Role</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Model.Account user : users) {
                        %>
                            <tr>
                                <td><%= user.getAccountID() %></td>
                                <td><%= user.getUsername() %></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getFullName() %></td>
                                <td><span style="background: #667eea; color: white; padding: 4px 10px; border-radius: 4px; font-size: 12px;"><%= user.getUserRole() %></span></td>
                                <td>
                                    <% if (user.isStatus()) { %>
                                        <span class="status-active">Hoạt động</span>
                                    <% } else { %>
                                        <span class="status-inactive">Không hoạt động</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="id" value="<%= user.getAccountID() %>">
                                            <input type="hidden" name="status" value="<%= user.isStatus() ? "active" : "inactive" %>">
                                            <button type="submit" class="btn btn-toggle"><%= user.isStatus() ? "Vô hiệu hóa" : "Kích hoạt" %></button>
                                        </form>
                                        <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= user.getAccountID() %>">
                                            <button type="submit" class="btn btn-delete" onclick="return confirm('Bạn có chắc chắn muốn xóa người dùng này?')">Xóa</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            <%
                } else {
            %>
                <div class="empty-message">Không có người dùng nào để hiển thị.</div>
            <%
                }
            %>
        </div>
        </c:if>
    </div>

    <div id="detailsModal" class="modal">
        <div class="modal-content" style="max-width: 700px; max-height: 80vh; overflow-y: auto;">
            <div class="modal-header">
                <h3>Chi tiết sản phẩm</h3>
                <button type="button" class="btn btn-toggle" onclick="closeDetailsModal()">Đóng</button>
            </div>
            <div id="detailsContent" style="padding: 15px 0;">
                <p>Đang tải...</p>
            </div>
        </div>
    </div>

    <div id="deactivateModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Nhập lý do xóa sản phẩm</h3>
                <button type="button" class="btn btn-toggle" onclick="closeDeactivateModal()">Đóng</button>
            </div>
            <form method="GET" action="<%= request.getContextPath() %>/admin">
                <input type="hidden" name="action" value="deactivateProduct">
                <input type="hidden" name="clothingID" id="deactivateClothingID">
                <div class="reason-list">
                    <label><input type="radio" name="reason" value="San pham sai so voi ten" required> Sản phẩm sai so với tên</label>
                    <label><input type="radio" name="reason" value="Anh sai so voi san pham" required> Ảnh sai so với sản phẩm</label>
                </div>
                <div style="margin-top:10px;">
                    <label for="note">Ghi chú thêm (nếu có)</label>
                    <textarea id="note" name="note" class="reason-note" placeholder="Nhập ghi chú..."></textarea>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-toggle" onclick="closeDeactivateModal()">Hủy</button>
                    <button type="submit" class="btn btn-delete">Xác nhận</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openDeactivateModal(id) {
            document.getElementById('deactivateClothingID').value = id;
            document.getElementById('deactivateModal').classList.add('show');
        }
        function closeDeactivateModal() {
            document.getElementById('deactivateModal').classList.remove('show');
        }

        function viewProductDetails(clothingID) {
            fetch('<%= request.getContextPath() %>/clothing?action=getDetails&id=' + clothingID)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const p = data.product;
                        let html = '<div style="display: grid; gap: 12px;">';
                        
                        // Image
                        if (p.imagePath) {
                            html += '<div><img src="<%= request.getContextPath() %>/image?id=' + p.clothingID + '" style="width: 100%; max-height: 300px; object-fit: cover; border-radius: 6px;"></div>';
                        }
                        
                        // Basic Info
                        html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                        html += '<p><strong>ID:</strong> ' + p.clothingID + '</p>';
                        html += '<p><strong>Tên sản phẩm:</strong> ' + p.clothingName + '</p>';
                        html += '<p><strong>Danh mục:</strong> ' + p.category + '</p>';
                        // Show Style only for non-Cosplay items
                        if (p.category !== 'Cosplay') {
                            html += '<p><strong>Phong cách:</strong> ' + p.style + '</p>';
                        }
                        html += '<p><strong>Dịp:</strong> ' + p.occasion + '</p>';
                        html += '</div>';
                        
                        // Pricing
                        html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                        html += '<p><strong>Giá theo giờ:</strong> ' + new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(p.hourlyPrice) + '</p>';
                        html += '<p><strong>Giá theo ngày:</strong> ' + new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(p.dailyPrice) + '</p>';
                        html += '<p><strong>Tiền cọc:</strong> ' + new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(p.depositAmount) + '</p>';
                        html += '</div>';
                        
                        // Details
                        html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                        html += '<p><strong>Size:</strong> ' + p.size + '</p>';
                        // Show Accessories for Cosplay items
                        if (p.category === 'Cosplay' && p.cosplayDetail && p.cosplayDetail.accessoryList) {
                            html += '<p><strong>Phụ kiện đi kèm:</strong> ' + p.cosplayDetail.accessoryList + '</p>';
                        }
                        html += '<p><strong>Số lượng:</strong> ' + p.quantity + '</p>';
                        html += '<p><strong>Mô tả:</strong> ' + (p.description || 'N/A') + '</p>';
                        html += '</div>';
                        
                        // Availability
                        html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                        html += '<p><strong>Có sẵn từ:</strong> ' + p.availableFrom + '</p>';
                        html += '<p><strong>Có sẵn đến:</strong> ' + p.availableTo + '</p>';
                        html += '</div>';
                        
                        // Status
                        html += '<div>';
                        html += '<p><strong>Trạng thái:</strong> <span style="padding: 4px 8px; border-radius: 4px; ';
                        if (p.clothingStatus === 'ACTIVE' || p.clothingStatus === 'APPROVED_COSPLAY') {
                            html += 'background: #d4edda; color: #155724;';
                        } else if (p.clothingStatus === 'INACTIVE') {
                            html += 'background: #f8d7da; color: #721c24;';
                        } else {
                            html += 'background: #fff3cd; color: #856404;';
                        }
                        html += '">' + p.clothingStatus + '</span></p>';
                        html += '<p><strong>Hoạt động:</strong> ' + (p.active ? 'Có' : 'Không') + '</p>';
                        html += '</div>';
                        
                        html += '</div>';
                        document.getElementById('detailsContent').innerHTML = html;
                        document.getElementById('detailsModal').classList.add('show');
                    } else {
                        alert('Không thể tải chi tiết sản phẩm');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi khi tải chi tiết sản phẩm');
                });
        }

        function closeDetailsModal() {
            document.getElementById('detailsModal').classList.remove('show');
        }
    </script>
</body>
</html>
