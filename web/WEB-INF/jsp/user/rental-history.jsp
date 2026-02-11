<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Account" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Thuê - WearConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: cursive;
            background-color: #f5f5f5;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .page-header {
            background: linear-gradient(135deg, #cc3399 0%, #cc0099 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .page-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .menu-nav {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
            flex-wrap: wrap;
            justify-content: center;
        }
        
        .menu-nav a {
            padding: 12px 24px;
            background-color: #ff69b4;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        
        .menu-nav a:hover {
            background-color: #ff3fa0;
        }
        
        .menu-nav a.active {
            background-color: #ff1493;
        }
        
        .history-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #dee2e6;
            color: #666;
        }
        
        tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .empty-message {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-message p {
            font-size: 18px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />
    
    <%
        Account user = (Account) session.getAttribute("account");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
    %>
    
    <div class="container">
        <div class="page-header">
            <h1>Lịch Sử Thuê Hàng</h1>
            <p>Xem tất cả các đơn thuê của bạn</p>
        </div>
        
        <div class="menu-nav">
            <a href="${pageContext.request.contextPath}/user">Dashboard</a>
            <a href="${pageContext.request.contextPath}/user?action=rentalHistory" class="active">Lịch Sử Thuê</a>
            <a href="${pageContext.request.contextPath}/user?action=favorites">Sản Phẩm Yêu Thích</a>
        </div>
        
        <div class="history-table">
            <table>
                <thead>
                    <tr>
                        <th>Mã Đơn</th>
                        <th>Sản Phẩm</th>
                        <th>Từ Ngày</th>
                        <th>Đến Ngày</th>
                        <th>Tổng Giá</th>
                        <th>Trạng Thái</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="6" class="empty-message">
                            <p>🎯 Chưa có lịch sử thuê hàng</p>
                            <p style="font-size: 14px; color: #999;">Hãy bắt đầu thuê những bộ đồ yêu thích của bạn ngay hôm nay!</p>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
