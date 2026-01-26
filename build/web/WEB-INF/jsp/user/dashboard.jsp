<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Account" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WearConnect - User Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            min-height: 100vh;
        }
        
        .header {
            background: linear-gradient(135deg, #cc3399 0%, #cc0099 100%);
            color: white;
            padding: 30px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }
        
        .header-info {
            flex: 1;
        }
        
        .header-info p {
            font-size: 14px;
            margin: 3px 0;
        }
        
        .header-right {
            text-align: right;
        }
        
        .btn-logout {
            background-color: #dc3545;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        
        .btn-logout:hover {
            background-color: #c82333;
        }
        
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .title {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }
        
        .title h2 {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .menu-card {
            background: white;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .menu-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }
        
        .menu-card .icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        
        .menu-card h3 {
            color: #333;
            font-size: 18px;
            margin-bottom: 10px;
        }
        
        .menu-card p {
            color: #666;
            font-size: 14px;
        }
        
        .menu-card:nth-child(1) {
            border-top: 4px solid #FF1493;
        }
        
        .menu-card:nth-child(2) {
            border-top: 4px solid #FF69B4;
        }
        
        .menu-card:nth-child(3) {
            border-top: 4px solid #FF00FF;
        }
        
        .menu-card:nth-child(4) {
            border-top: 4px solid #FF1493;
        }
        
        .menu-card:nth-child(5) {
            border-top: 4px solid #FF69B4;
        }
        
        .menu-card:nth-child(6) {
            border-top: 4px solid #FF00FF;
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
        <div class="title">
            <h2>👋 Chào mừng, <%= user.getFullName() %></h2>
            <p>Tài khoản: <%= user.getUsername() %></p>
        </div>
        
        <div class="menu-container">
            <nav style="margin-bottom: 30px; display: flex; gap: 15px; justify-content: center; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/user" style="padding: 12px 24px; background-color: #cc3399; color: white; text-decoration: none; border-radius: 5px; font-weight: 600; transition: background-color 0.3s;" onmouseover="this.style.backgroundColor='#b8278a'" onmouseout="this.style.backgroundColor='#cc3399'">📊 Dashboard</a>
                <a href="${pageContext.request.contextPath}/user?action=rentalHistory" style="padding: 12px 24px; background-color: #ff69b4; color: white; text-decoration: none; border-radius: 5px; font-weight: 600; transition: background-color 0.3s;" onmouseover="this.style.backgroundColor='#ff3fa0'" onmouseout="this.style.backgroundColor='#ff69b4'">📜 Lịch Sử Thuê</a>
                <a href="${pageContext.request.contextPath}/user?action=favorites" style="padding: 12px 24px; background-color: #ff1493; color: white; text-decoration: none; border-radius: 5px; font-weight: 600; transition: background-color 0.3s;" onmouseover="this.style.backgroundColor='#e60a7e'" onmouseout="this.style.backgroundColor='#ff1493'">❤️ Sản Phẩm Yêu Thích</a>
            </nav>
        </div>
        
        <div class="menu-grid">
            <div class="menu-card" onclick="window.location.href='${pageContext.request.contextPath}/search'">
                <div class="icon">👗</div>
                <h3>Duyệt Sản Phẩm</h3>
                <p>Khám phá các bộ đồ mới</p>
            </div>
            
            <div class="menu-card" onclick="window.location.href='${pageContext.request.contextPath}/rental?action=myOrders'">
                <div class="icon">📦</div>
                <h3>Đơn Thuê Của Tôi</h3>
                <p>Quản lý các đơn thuê đang hoạt động</p>
            </div>
            
            <div class="menu-card" onclick="alert('Tính năng yêu thích đang được phát triển')">
                <div class="icon">❤️</div>
                <h3>Yêu Thích</h3>
                <p>Lưu lại những bộ đồ yêu thích</p>
            </div>
            
            <div class="menu-card" onclick="window.location.href='${pageContext.request.contextPath}/user?action=profile'">
                <div class="icon">👤</div>
                <h3>Hồ Sơ</h3>
                <p>Cập nhật thông tin cá nhân</p>
            </div>
            
            <div class="menu-card" onclick="alert('Tính năng lịch sử đang được phát triển')">
                <div class="icon">📜</div>
                <h3>Lịch Sử</h3>
                <p>Xem các đơn thuê trong quá khứ</p>
            </div>
            
            <div class="menu-card" onclick="alert('Tính năng cài đặt đang được phát triển')">
                <div class="icon">⚙️</div>
                <h3>Cài Đặt</h3>
                <p>Quản lý tài khoản và bảo mật</p>
            </div>
        </div>
    </div>
</body>
</html>
