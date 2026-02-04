<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Account" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WearConnect - User Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
    <style>
        body {
            background-color: var(--gray-100);
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
            gap: var(--spacing-xl);
            margin-bottom: var(--spacing-4xl);
        }
        
        .menu-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: var(--spacing-3xl);
            text-align: center;
            box-shadow: var(--shadow-md);
            cursor: pointer;
            transition: all var(--transition-base);
        }
        
        .menu-card:hover {
            transform: translateY(-10px);
            box-shadow: var(--shadow-xl);
        }
        
        @media (max-width: 639px) {
            .menu-grid {
                grid-template-columns: 1fr;
            }
            .menu-card {
                padding: var(--spacing-xl);
            }
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
                <a href="${pageContext.request.contextPath}/user" style="padding: 12px 24px; background-color: #cc3399; color: white; text-decoration: none; border-radius: 5px; font-weight: 600; transition: background-color 0.3s;" onmouseover="this.style.backgroundColor='#b8278a'" onmouseout="this.style.backgroundColor='#cc3399'"> Dashboard</a>
                <a href="${pageContext.request.contextPath}/user?action=rentalHistory" style="padding: 12px 24px; background-color: #ff69b4; color: white; text-decoration: none; border-radius: 5px; font-weight: 600; transition: background-color 0.3s;" onmouseover="this.style.backgroundColor='#ff3fa0'" onmouseout="this.style.backgroundColor='#ff69b4'"> Lịch Sử Thuê</a>
                <a href="${pageContext.request.contextPath}/user?action=favorites" style="padding: 12px 24px; background-color: #ff1493; color: white; text-decoration: none; border-radius: 5px; font-weight: 600; transition: background-color 0.3s;" onmouseover="this.style.backgroundColor='#e60a7e'" onmouseout="this.style.backgroundColor='#ff1493'"> Sản Phẩm Yêu Thích</a>
            </nav>
        </div>
        
        <div class="menu-grid">
            <div class="menu-card" onclick="window.location.href='${pageContext.request.contextPath}/search'">
                <div class="icon"></div>
                <h3>Duyệt Sản Phẩm</h3>
                <p>Khám phá các bộ đồ mới</p>
            </div>
            
            <div class="menu-card" onclick="window.location.href='${pageContext.request.contextPath}/rental?action=myOrders'">
                <div class="icon"></div>
                <h3>Đơn Thuê Của Tôi</h3>
                <p>Quản lý các đơn thuê đang hoạt động</p>
            </div>
            
            <div class="menu-card" onclick="alert('Tính năng yêu thích đang được phát triển')">
                <div class="icon"></div>
                <h3>Yêu Thích</h3>
                <p>Lưu lại những bộ đồ yêu thích</p>
            </div>
            
            <div class="menu-card" onclick="window.location.href='${pageContext.request.contextPath}/user?action=profile'">
                <div class="icon"></div>
                <h3>Hồ Sơ</h3>
                <p>Cập nhật thông tin cá nhân</p>
            </div>
            
            <div class="menu-card" onclick="alert('Tính năng lịch sử đang được phát triển')">
                <div class="icon"></div>
                <h3>Lịch Sử</h3>
                <p>Xem các đơn thuê trong quá khứ</p>
            </div>
            
            <div class="menu-card" onclick="alert('Tính năng cài đặt đang được phát triển')">
                <div class="icon"></div>
                <h3>Cài Đặt</h3>
                <p>Quản lý tài khoản và bảo mật</p>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
