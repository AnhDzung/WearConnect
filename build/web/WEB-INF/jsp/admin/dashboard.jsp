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
        }
        
        .nav-links {
            display: flex;
            gap: 15px;
        }
        
        .nav-links a {
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav-links a:hover {
            background: #0056b3;
        }
        
        .controls {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
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
            padding: 5px 10px;
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
        <div class="control-panel">
            <button class="btn btn-add" onclick="addAccount()">Thêm Tài Khoản</button>
            <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;">
                <button type="submit" class="btn btn-refresh">Làm Mới</button>
            </form>
        </div>
        
        <div class="table-container">
            <%
                @SuppressWarnings("unchecked")
                List<Account> users = (List<Account>) request.getAttribute("users");
                
                if (users != null && !users.isEmpty()) {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Đăng Nhập</th>
                            <th>Email</th>
                            <th>Tên Đầy Đủ</th>
                            <th>Loại Tài Khoản</th>
                            <th>Trạng Thái</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Account user : users) {
                        %>
                            <tr>
                                <td><%= user.getAccountID() %></td>
                                <td><%= user.getUsername() %></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getFullName() %></td>
                                <td><%= user.getUserRole() %></td>
                                <td>
                                    <% if (user.isStatus()) { %>
                                        <span class="status-active">Hoạt Động</span>
                                    <% } else { %>
                                        <span class="status-inactive">✗ Khóa</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="id" value="<%= user.getAccountID() %>">
                                            <input type="hidden" name="status" value="<%= user.isStatus() ? "active" : "inactive" %>">
                                            <button type="submit" class="btn btn-toggle">
                                                <% if (user.isStatus()) { %>
                                                    🔒 Khóa
                                                <% } else { %>
                                                    🔓 Mở Khóa
                                                <% } %>
                                            </button>
                                        </form>
                                        <form method="GET" action="<%= request.getContextPath() %>/admin" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa tài khoản này?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= user.getAccountID() %>">
                                            <button type="submit" class="btn btn-delete">Xóa</button>
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
                <div class="empty-message">
                    Không có tài khoản nào để hiển thị.
                </div>
            <%
                }
            %>
        </div>
    </div>
    
    <script>
        function addAccount() {
            alert('Chức năng sẽ được phát triển!');
        }
    </script>
</body>
</html>
