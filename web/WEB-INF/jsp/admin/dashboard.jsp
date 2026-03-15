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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin-dashboard.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        h1, h2, h3, h4, h5, h6 { font-family: 'Poppins', sans-serif; }
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
            <button type="button" class="tab-button"
                    onclick="location.href='${pageContext.request.contextPath}/admin?action=ratings'">
                 Đánh giá
            </button>
            <button type="button" class="tab-button ${view eq 'payments' ? 'active' : ''}"
                    onclick="location.href='${pageContext.request.contextPath}/admin?action=payments'">
                 💰 Xử lý thanh toán
            </button>
                <button type="button" class="tab-button ${view eq 'aiKnowledge' ? 'active' : ''}"
                    onclick="location.href='${pageContext.request.contextPath}/admin?action=aiKnowledge'">
                 🤖 Tri thức AI
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
                                        <button type="button" class="btn btn-add" onclick="viewProductDetailsFromButton(this)">Chi tiết</button>
                                        <button type="button" class="btn btn-delete" onclick="openDeactivateModalFromButton(this)">Xóa</button>
                                        <span class="clothing-id-data" style="display:none;"><%= p.getClothingID() %></span>
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
        
        <c:if test="${view eq 'payments'}">
        <c:if test="${param.success == 'true'}">
            <div style="background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
                ✓ Xác nhận thanh toán thành công! Thông báo đã được gửi đến User và Manager.
            </div>
        </c:if>
        <c:if test="${param.error == 'true'}">
            <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
                ✗ Có lỗi xảy ra khi xử lý thanh toán. Vui lòng thử lại.
            </div>
        </c:if>
        <div class="control-panel">
            <div><strong>Xử lý thanh toán cho các đơn hàng đã trả</strong></div>
        </div>

        <div class="table-container">
            <%
                @SuppressWarnings("unchecked")
                List<Model.RentalOrder> returnedOrders = (List<Model.RentalOrder>) request.getAttribute("returnedOrders");
                @SuppressWarnings("unchecked")
                java.util.Map<Integer, Model.Account> accountMap = (java.util.Map<Integer, Model.Account>) request.getAttribute("accountMap");
                @SuppressWarnings("unchecked")
                java.util.Map<Integer, Model.Clothing> clothingMap = (java.util.Map<Integer, Model.Clothing>) request.getAttribute("clothingMap");
                
                if (returnedOrders != null && returnedOrders.size() > 0) {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Sản phẩm</th>
                            <th>Người thuê (User)</th>
                            <th>Số TK User</th>
                            <th>Chủ sản phẩm (Manager)</th>
                            <th>Số TK Manager</th>
                            <th>Tiền cọc</th>
                            <th>Giá thuê</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Model.RentalOrder order : returnedOrders) {
                                Model.Account renter = accountMap.get(order.getRenterUserID());
                                Model.Clothing clothing = clothingMap.get(order.getClothingID());
                                Model.Account manager = (clothing != null) ? accountMap.get(clothing.getRenterID()) : null;
                                
                                String renterBankInfo = "Chưa cập nhật";
                                if (renter != null && renter.getBankAccountNumber() != null && !renter.getBankAccountNumber().trim().isEmpty()) {
                                    renterBankInfo = renter.getBankAccountNumber() + " - " + (renter.getBankName() != null ? renter.getBankName() : "");
                                }
                                
                                String managerBankInfo = "Chưa cập nhật";
                                if (manager != null && manager.getBankAccountNumber() != null && !manager.getBankAccountNumber().trim().isEmpty()) {
                                    managerBankInfo = manager.getBankAccountNumber() + " - " + (manager.getBankName() != null ? manager.getBankName() : "");
                                }
                        %>
                            <tr>
                                <td>#<%= order.getRentalOrderID() %></td>
                                <td><%= clothing != null ? clothing.getClothingName() : "N/A" %></td>
                                <td><%= renter != null ? renter.getFullName() : "N/A" %></td>
                                <td style="font-size: 12px;"><%= renterBankInfo %></td>
                                <td><%= manager != null ? manager.getFullName() : "N/A" %></td>
                                <td style="font-size: 12px;"><%= managerBankInfo %></td>
                                <td><%= String.format("%,.0f", order.getDepositAmount()) %> VND</td>
                                <td><%= String.format("%,.0f", order.getTotalPrice()) %> VND</td>
                                <td>
                                    <button type="button" class="btn btn-add" onclick="openPaymentModalFromButton(this)">
                                        Xác nhận thanh toán
                                    </button>
                                    <span class="payment-order-id" style="display:none;"><%= order.getRentalOrderID() %></span>
                                    <span class="payment-deposit-amount" style="display:none;"><%= order.getDepositAmount() %></span>
                                    <span class="payment-total-amount" style="display:none;"><%= order.getTotalPrice() %></span>
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
                <div class="empty-message">Không có đơn hàng nào cần xử lý thanh toán.</div>
            <%
                }
            %>
        </div>
        </c:if>

        <c:if test="${view eq 'aiKnowledge'}">
        <div class="control-panel">
            <div><strong>Quản lý tri thức nội bộ cho AI Chat</strong></div>
            <div class="knowledge-tools">
                <input type="text" id="knowledgeSearchInput" placeholder="Tìm theo tiêu đề/nội dung/tags..." style="min-width: 260px;">
                <label style="display:flex; align-items:center; gap:6px; font-size:14px;">
                    <input type="checkbox" id="knowledgeIncludeInactive"> Hiện cả bản đã ẩn
                </label>
                <button type="button" class="btn btn-refresh" onclick="loadKnowledgeDocs()">Tải lại</button>
                <span id="knowledgeStatus" class="knowledge-status"></span>
            </div>
        </div>

        <form id="knowledgeForm" class="knowledge-form">
            <input type="hidden" id="knowledgeDocID">
            <div class="knowledge-grid">
                <div>
                    <label for="knowledgeTitle"><strong>Tiêu đề</strong></label>
                    <input type="text" id="knowledgeTitle" required style="width:100%;">
                </div>
                <div>
                    <label for="knowledgeCategory"><strong>Danh mục</strong></label>
                    <input type="text" id="knowledgeCategory" placeholder="VD: PAYMENT, RETURN_REFUND" style="width:100%;">
                </div>
                <div class="full">
                    <label for="knowledgeTags"><strong>Tags</strong></label>
                    <input type="text" id="knowledgeTags" placeholder="VD: cọc, thanh toán, hoàn tiền" style="width:100%;">
                </div>
                <div class="full">
                    <label for="knowledgeContent"><strong>Nội dung</strong></label>
                    <textarea id="knowledgeContent" required style="width:100%;"></textarea>
                </div>
            </div>
            <div class="knowledge-tools">
                <label style="display:flex; align-items:center; gap:6px; font-size:14px;">
                    <input type="checkbox" id="knowledgeIsActive" checked> Đang kích hoạt
                </label>
                <button type="submit" class="btn btn-add" id="knowledgeSubmitBtn">Tạo mới</button>
                <button type="button" class="btn btn-toggle" onclick="resetKnowledgeForm()">Làm sạch</button>
            </div>
        </form>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tiêu đề</th>
                        <th>Danh mục</th>
                        <th>Tags</th>
                        <th>Trạng thái</th>
                        <th>Cập nhật</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody id="knowledgeTableBody">
                    <tr><td colspan="7" class="empty-message">Đang tải dữ liệu...</td></tr>
                </tbody>
            </table>
        </div>

        <div class="control-panel" style="margin-top:20px;">
            <div><strong>Lịch sử chỉnh sửa tri thức (Audit)</strong></div>
            <div class="knowledge-tools">
                <input type="number" id="auditDocIDInput" placeholder="DocID" style="width:100px;">
                <input type="number" id="auditOperatorIDInput" placeholder="OperatorID" style="width:120px;">
                <select id="auditActionInput">
                    <option value="">Tất cả action</option>
                    <option value="CREATE">CREATE</option>
                    <option value="UPDATE">UPDATE</option>
                    <option value="DEACTIVATE">DEACTIVATE</option>
                </select>
                <button type="button" class="btn btn-refresh" onclick="loadKnowledgeAuditLogs()">Tải audit</button>
                <span id="knowledgeAuditStatus" class="knowledge-status"></span>
            </div>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>AuditID</th>
                        <th>DocID</th>
                        <th>Action</th>
                        <th>Operator</th>
                        <th>Summary</th>
                        <th>IP</th>
                        <th>Thời gian</th>
                    </tr>
                </thead>
                <tbody id="knowledgeAuditTableBody">
                    <tr><td colspan="7" class="empty-message">Nhấn "Tải audit" để xem lịch sử.</td></tr>
                </tbody>
            </table>
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

    <div id="paymentModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Xác nhận thanh toán</h3>
                <button type="button" class="btn btn-toggle" onclick="closePaymentModal()">Đóng</button>
            </div>
            <form method="POST" action="<%= request.getContextPath() %>/admin" enctype="multipart/form-data">
                <input type="hidden" name="action" value="confirmPayment">
                <input type="hidden" name="orderID" id="paymentOrderID">
                <div style="padding: 15px 0; display: grid; gap: 15px;">
                    <div>
                        <strong>Tiền cọc trả lại User:</strong> <span id="depositDisplay"></span> VND
                        <div style="margin-top: 8px;">
                            <label style="display: block; margin-bottom: 5px;">Upload ảnh chứng minh đã hoàn cọc:</label>
                            <input type="file" name="refundProof" accept="image/*" required style="padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        </div>
                    </div>
                    <div>
                        <strong>Tiền thuê trả cho Manager:</strong> <span id="rentalDisplay"></span> VND
                        <div style="margin-top: 6px; color: #555;">
                            <div>Phí hệ thống (10%): <strong><span id="systemFeeDisplay">0</span> VND</strong></div>
                            <div>Số tiền Manager nhận: <strong><span id="managerReceiveDisplay">0</span> VND</strong></div>
                        </div>
                        <div style="margin-top: 8px;">
                            <label style="display: block; margin-bottom: 5px;">Upload ảnh chứng minh đã trả tiền cho Manager:</label>
                            <input type="file" name="managerPaymentProof" accept="image/*" required style="padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        </div>
                    </div>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-toggle" onclick="closePaymentModal()">Hủy</button>
                    <button type="submit" class="btn btn-add">Xác nhận đã thanh toán</button>
                </div>
            </form>
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
        window.WEARCONNECT_CTX = '<%= request.getContextPath() %>';
    </script>
    <script src="<%= request.getContextPath() %>/assets/js/admin-dashboard.js"></script>
</body>
</html>
