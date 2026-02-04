<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .wearconnect-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 12px 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        margin-bottom: 20px;
        min-height: 64px;
    }
    
    .header-container {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        min-height: 40px;
    }
    
    .header-logo {
        font-size: 24px;
        font-weight: bold;
        text-decoration: none;
        color: white;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .header-logo img.logo-img {
        height: 36px;
        width: auto;
        display: block;
    }
    .header-logo .brand-name {
        font-size: 20px;
        font-weight: 700;
        line-height: 1;
    }
    
    .header-logo:hover {
        opacity: 0.9;
    }
    
    .header-nav {
        display: flex;
        gap: 0;
        align-items: center;
        list-style: none;
        margin: 0;
        padding: 0;
        flex-wrap: nowrap; /* keep single row on desktop */
        overflow-x: auto;  /* allow scroll if too many items */
        white-space: nowrap;
        -webkit-overflow-scrolling: touch;
    }
    
    .header-nav li {
        margin: 0;
        flex: 0 0 auto;
    }
    
    .header-nav a, .header-nav button {
        display: block;
        padding: 15px 20px;
        color: white;
        text-decoration: none;
        transition: background-color 0.3s;
        border: none;
        background: none;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
    }
    
    .header-nav a:hover, .header-nav button:hover {
        background-color: rgba(255,255,255,0.2);
    }
    
    .header-nav .active {
        background-color: rgba(255,255,255,0.3);
        border-bottom: 3px solid white;
    }
    
    .header-user-info {
        display: flex;
        align-items: center;
        gap: 15px;
        white-space: nowrap; /* avoid wrapping user info */
    }
    
    .header-user-name {
        font-size: 14px;
    }
    
    .header-user-role {
        font-size: 12px;
        opacity: 0.8;
        background: rgba(255,255,255,0.2);
        padding: 4px 10px;
        border-radius: 12px;
    }
    
    .logout-btn {
        padding: 8px 16px !important;
        background-color: #ff4757 !important;
        border-radius: 4px;
        font-size: 13px !important;
    }
    
    .logout-btn:hover {
        background-color: #ff3838 !important;
    }
    
    @media (max-width: 768px) {
        .header-container {
            flex-direction: column;
            gap: 15px;
        }
        
        .header-nav {
            width: 100%;
            flex-wrap: wrap; /* allow wrap on mobile */
            justify-content: center;
            overflow: visible;
            white-space: normal;
        }
        
        .header-nav a, .header-nav button {
            padding: 10px 15px;
            font-size: 13px;
        }
    }
</style>

<header class="wearconnect-header">
    <div class="header-container">
        <!-- Logo with Dynamic Navigation Based on Role -->
        <%
            String userRole = (String) session.getAttribute("userRole");
            String logoHref = request.getContextPath() + "/";
            String username = "";
            String fullName = "";
            Object account = session.getAttribute("account");
            if (account != null) {
                Model.Account acc = (Model.Account) account;
                username = acc.getUsername();
                fullName = acc.getFullName();
            }
            
            // Determine logo link based on role
            if ("User".equals(userRole)) {
                logoHref = request.getContextPath() + "/home";
            } else if ("Manager".equals(userRole)) {
                logoHref = request.getContextPath() + "/manager";
            } else if ("Admin".equals(userRole)) {
                logoHref = request.getContextPath() + "/admin";
            }
        %>
        
        <a href="<%= logoHref %>" class="header-logo">
            <img class="logo-img" src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="Wear Connect logo">
            <span class="brand-name">Wear Connect</span>
        </a>
        
        <!-- Navigation Menu -->
        <ul class="header-nav">
            
            <!-- Menu cho User -->
            <% if ("User".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
                <li><a href="${pageContext.request.contextPath}/rental?action=myOrders">Đơn Thuê Của Tôi</a></li>
                <li><a href="${pageContext.request.contextPath}/user?action=favorites">Yêu Thích</a></li>
            <% } %>
            

            <!-- Menu cho Manager (Người Cho Thuê Quần Áo) -->
            <% if ("Manager".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/manager">Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/clothing?action=myClothing">Quản Lý Sản Phẩm</a></li>
                <li><a href="${pageContext.request.contextPath}/clothing?action=upload">Đăng Tải Mới</a></li>
                <li><a href="${pageContext.request.contextPath}/manager?action=orders">Đơn Đặt Thuê</a></li>
                <li><a href="${pageContext.request.contextPath}/manager?action=ratings">Đánh Giá</a></li>
            <% } %>
            
            <!-- Menu cho Admin -->
            <% if ("Admin".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/">Trang Chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/admin">Người Dùng</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=orders">Đơn Hàng</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=statistics">Thống Kê</a></li>
            <% } %>
            
            <!-- User Info -->
            <% if (userRole != null && !userRole.isEmpty()) { %>
                <li style="margin-left: auto;">
                    <div class="header-user-info">
                        <div class="header-user-name">
                            <% if ("Manager".equals(userRole)) { %>
                                <a href="${pageContext.request.contextPath}/manager?action=profile" style="color: white; text-decoration: none;">
                                    <%= (fullName != null && !fullName.trim().isEmpty()) ? fullName : username %>
                                </a>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/user?action=profile" style="color: white; text-decoration: none;">
                                    <%= (fullName != null && !fullName.trim().isEmpty()) ? fullName : username %>
                                </a>
                            <% } %>
                        </div>
                        <a href="${pageContext.request.contextPath}/logout" class="logout-btn"> Đăng Xuất</a>
                    </div>
                </li>
            <% } else { %>
                <li style="margin-left: auto;">
                    <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
                    <a href="${pageContext.request.contextPath}/register">Đăng Ký</a>
                </li>
            <% } %>
        </ul>
    </div>
</header>
