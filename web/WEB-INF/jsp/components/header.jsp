<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

    .wearconnect-header {
        --primary-blue: #0a84ff;
        --primary-blue-hover: #0670dc;
        --white-text: #ffffff;
        --dark-gray-text: #5a5a5a;
        --green-start: #00d084;
        --blue-end: #0a84ff;
        --blue-border: #0a84ff;
        --header-btn-gap: 8px;
        font-family: 'Inter', sans-serif;
        background: linear-gradient(135deg, #f5fbff 0%, #0cc0df 100%);
        color: #111;
        padding: 8px 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        border-bottom: 1px solid rgba(62, 213, 240, 0.897);
        margin-bottom: 20px;
        min-height: 130px;
        overflow: visible;
        position: relative;
        z-index: 20;
    }
    
    .header-container {
        width: 100%;
        max-width: 1680px;
        padding: 0 clamp(12px, 1.8vw, 24px);
        box-sizing: border-box;
        margin: 0 auto;
        display: grid;
        grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);
        align-items: center;
        gap: 6px;
        min-height: 117px;
        overflow: visible;
    }

    .header-right {
        grid-column: 3;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 10px;
        justify-self: stretch;
        width: 100%;
        max-width: 100%;
        overflow-x: visible;
        overflow-y: visible;
        min-width: 0;
    }
    
    .header-logo {
        grid-column: 2;
        justify-self: center;
        font-size: 24px;
        font-weight: bold;
        text-decoration: none;
        color: #111;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
    }
    .header-logo img.logo-img {
        width: 173px;
        height: 117px;
        object-fit: contain;
        display: block;
    }
    .header-logo .brand-name {
        font-family: 'Poppins', sans-serif;
        font-size: 24px;
        font-weight: 700;
        line-height: 1;
    }
    
    .header-logo:hover {
        opacity: 0.9;
    }
    
    .header-nav {
        grid-column: 1;
        display: flex;
        gap: var(--header-btn-gap);
        align-items: center;
        justify-content: flex-start;
        min-width: 0;
        list-style: none;
        margin: 0;
        padding: 0;
        flex-wrap: nowrap;
        overflow-x: auto;
        overflow-y: visible;
        white-space: nowrap;
        -webkit-overflow-scrolling: touch;
        justify-self: start;
    }
    
    .header-nav li {
        margin: 0;
        flex: 0 0 auto;
        display: flex;
        align-items: center;
    }

    .header-auth-actions {
        display: flex;
        gap: var(--header-btn-gap);
        align-items: center;
        flex-wrap: nowrap;
        justify-content: flex-end;
        min-width: 0;
    }

    .header-nav-main-btn {
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        width: 165px;
        min-height: 45px;
        padding: 0 14px !important;
        box-sizing: border-box;
        border-radius: 8px !important;
        font-size: 15px !important;
        font-weight: 600 !important;
        line-height: 1;
        letter-spacing: 0 !important;
        word-spacing: 0 !important;
        text-align: center;
        white-space: nowrap;
        background: none !important;
        color: var(--dark-gray-text) !important;
        border: none !important;
        transition: color 0.2s ease;
    }
    
    .header-nav-main-btn:hover {
        color: #111 !important;
    }

    .advisor-prompt-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        min-height: 45px;
        max-width: 220px;
        padding: 0 18px;
        border-radius: 10px;
        border: none;
        background: linear-gradient(90deg, var(--green-start) 0%, var(--blue-end) 100%);
        color: #ffffff;
        font-size: 15px;
        font-weight: 700;
        line-height: 1;
        text-decoration: none;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        flex: 0 1 auto;
        box-shadow: 0 4px 12px rgba(10, 132, 255, 0.25);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .advisor-prompt-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(10, 132, 255, 0.35);
    }
    
    .header-nav a, .header-nav button {
        display: block;
        padding: 11px 13px;
        color: var(--dark-gray-text);
        font-family: 'Inter', sans-serif;
        text-decoration: none;
        transition: color 0.2s ease;
        border: none;
        background: none !important;
        cursor: pointer;
        font-size: 15px;
        font-weight: 500;
        border-radius: 8px;
    }

    .header-nav > li > a {
        background: none !important;
    }
    
    .header-nav > li > a:hover {
        color: #111;
    }

    .header-nav > li > a.cosplay-highlight {
        background: none;
        color: var(--dark-gray-text);
        font-weight: 600 !important;
        letter-spacing: 0 !important;
        word-spacing: 0 !important;
        box-shadow: none;
        border: none;
    }

    .header-nav > li > a.cosplay-highlight .cosplay-badge {
        display: inline-block;
        margin-left: 6px;
        padding: 1px 6px;
        border-radius: 999px;
        font-size: 18px;
        font-weight: 800;
        letter-spacing: 0.3px;
        color: #fff;
        background: #d7263d;
        box-shadow: 0 2px 8px rgba(215, 38, 61, 0.45);
        vertical-align: middle;
    }

    .header-nav > li > a.cosplay-highlight.cosplay-spotlight {
        animation: none;
        font-weight: 700;
    }

    @keyframes cosplayPulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 1; }
    }

    .header-nav > li > a.cosplay-highlight:hover {
        color: #111;
        transform: none;
    }

    @media (max-width: 1200px) {
        .header-container {
            grid-template-columns: 1fr;
            align-items: center;
            gap: 10px;
        }

        .header-logo {
            grid-column: auto;
            justify-content: center;
        }

        .header-right {
            grid-column: auto;
            width: 100%;
            flex-direction: column;
            gap: 8px;
            justify-content: center;
        }

        .header-nav {
            grid-column: auto;
            margin-left: 0;
            justify-content: center;
            flex-wrap: wrap;
            white-space: normal;
        }

        .header-auth-actions { justify-content: center; }
    }
    
    .header-nav a:hover, .header-nav button:hover {
        color: #111;
    }
    
    .header-nav .active {
        color: #111;
        border-bottom: none;
    }
    
    .header-user-info {
        display: flex;
        align-items: center;
        gap: var(--header-btn-gap);
        white-space: normal;
        flex-wrap: nowrap;
        justify-content: flex-end;
        width: 100%;
        max-width: 100%;
        min-width: 0;
    }

    .header-user-actions {
        display: flex;
        align-items: center;
        gap: var(--header-btn-gap);
        flex-wrap: nowrap;
        justify-content: flex-end;
        min-width: 0;
    }

    .header-user-name {
        min-width: 0;
        max-width: 210px;
    }

    .header-user-name .header-auth-link {
        min-width: 0;
        max-width: 100%;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .header-user-info > .logout-btn {
        margin-left: 0;
        flex-shrink: 0;
    }
    
    .header-user-name {
        font-family: 'Inter', sans-serif;
        font-size: 15px;
    }
    
    .header-user-role {
        font-family: 'Inter', sans-serif;
        font-size: 12px;
        opacity: 0.8;
        background: rgba(255,255,255,0.2);
        padding: 4px 10px;
        border-radius: 12px;
    }
    
    .logout-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-height: 45px;
        min-width: 120px;
        padding: 0 18px !important;
        background: #ffffff !important;
        color: var(--primary-blue) !important;
        border: 1.5px solid var(--blue-border);
        border-radius: 10px;
        font-size: 15px !important;
        font-weight: 700;
        transition: background-color 0.2s ease, box-shadow 0.2s ease;
    }

    .header-auth-link {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-family: 'Inter', sans-serif;
        min-height: 45px;
        min-width: 120px;
        padding: 0 18px;
        background: none;
        color: var(--dark-gray-text);
        text-decoration: none;
        border-radius: 10px;
        line-height: 1;
        font-size: 15px;
        font-weight: 600;
        border: none;
        transition: color 0.2s ease;
    }

    .header-auth-link:hover {
        color: #111;
    }

    .header-auth-actions .auth-login,
    .header-auth-actions .auth-register {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 160px;
        min-height: 45px;
        padding: 0 18px;
        border-radius: 10px;
        font-size: 15px;
        font-weight: 700;
        letter-spacing: 0.2px;
        border: 1.5px solid var(--blue-border);
        overflow: hidden;
        transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        background: none;
        box-shadow: none;
    }

    .header-auth-actions .auth-login {
        background: linear-gradient(90deg, var(--green-start) 0%, var(--blue-end) 100%);
        color: #ffffff;
        border: none;
    }

    .header-auth-actions .auth-register {
        background: #ffffff;
        color: var(--primary-blue);
        border: 1.5px solid var(--blue-border);
    }

    .header-auth-actions .auth-login::before,
    .header-auth-actions .auth-register::before {
        display: none;
    }

    .header-auth-actions .auth-login:hover,
    .header-auth-actions .auth-register:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(10, 132, 255, 0.25);
    }

    .header-auth-actions .auth-login:hover::before,
    .header-auth-actions .auth-register:hover::before {
        display: none;
    }
    
    .logout-btn:hover {
        background: #f0f8ff !important;
        box-shadow: 0 4px 12px rgba(10, 132, 255, 0.2);
    }
    
    @media (max-width: 768px) {
        .header-container {
            gap: 15px;
            padding: 0 12px;
        }
        
        .header-nav {
            width: 100%;
            margin-left: 0;
            justify-content: center;
            flex-wrap: wrap; /* allow wrap on mobile */
            overflow: visible;
            white-space: normal;
        }
        
        .header-nav a, .header-nav button {
            padding: 10px 15px;
            font-size: 15px;
        }

        .advisor-prompt-btn {
            width: 100%;
            justify-content: center;
        }
    }
    /* Notifications dropdown styles (match provided screenshot) */
    .notif-wrapper { position: relative; }
    .notif-wrapper > a {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-family: 'Inter', sans-serif;
        min-height: 45px;
        min-width: 120px;
        padding: 0 14px;
        border-radius: 10px;
        background: none;
        color: var(--dark-gray-text);
        font-size: 15px;
        font-weight: 600;
        transition: color 0.2s ease;
    }
    .notif-wrapper > a:hover { 
        color: #111;
    }
    .notif-dropdown {
        display: none;
        position: absolute;
        top: calc(100% + 8px);
        left: 0;
        width: 340px;
        background: #fff;
        color: #333;
        border-radius: 8px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.15);
        overflow: hidden;
        z-index: 3000;
        font-size: 14px;
    }
    .notif-dropdown:before {
        content: '';
        position: absolute;
        top: -10px;
        left: 24px;
        border-width: 6px;
        border-style: solid;
        border-color: transparent transparent #fff transparent;
        filter: drop-shadow(0 2px 2px rgba(0,0,0,0.06));
    }
    .notif-header { padding: 12px 14px; background:#fafafa; font-weight:700; color:#666; }
    .notif-list { max-height: 360px; overflow:auto; }
    .notif-item { display:flex; gap:10px; padding:12px 12px; border-bottom:1px solid #f0f0f0; }
    .notif-item:last-child { border-bottom:none; }
    .notif-thumb { width:48px; height:48px; border-radius:6px; background:#f3f3f3; flex:0 0 48px; display:flex; align-items:center; justify-content:center; color:#999; font-weight:700; }
    .notif-body { flex:1; }
    .notif-title { font-weight:700; font-size:13px; color:#222; }
    .notif-desc { color:#666; font-size:13px; margin-top:6px; line-height:1.25; }
    .notif-time { font-size:11px; color:#999; margin-top:6px; }
    .notif-footer { padding:10px; text-align:center; background:#fff; }
    .notif-footer a { color:#0d6efd; text-decoration:none; font-weight:600; }

    .wc-chat-fab {
        position: fixed;
        right: 22px;
        bottom: 22px;
        width: 56px;
        height: 56px;
        border-radius: 50%;
        border: none;
        background: linear-gradient(135deg, #667eea 0%, #5f9df7 100%);
        color: #fff;
        font-size: 24px;
        cursor: pointer;
        box-shadow: 0 10px 30px rgba(73, 106, 255, 0.35);
        z-index: 3900;
    }

    .wc-chat-mini {
        position: fixed;
        right: 22px;
        bottom: 88px;
        width: 340px;
        max-width: calc(100vw - 20px);
        height: 430px;
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 12px 40px rgba(0,0,0,0.2);
        display: none;
        z-index: 3900;
        overflow: hidden;
    }

    .wc-chat-mini.open { display: flex; flex-direction: column; }
    .wc-chat-head {
        padding: 12px 14px;
        background: #667eea;
        color: #fff;
        font-weight: 700;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .wc-chat-close { background: transparent; border: none; color: #fff; font-size: 18px; cursor: pointer; }
    .wc-chat-messages {
        flex: 1;
        padding: 12px;
        overflow-y: auto;
        background: #f8f9ff;
    }
    .wc-chat-item { display:flex; margin-bottom:8px; }
    .wc-chat-item.user { justify-content:flex-end; }
    .wc-chat-bubble {
        max-width: 76%;
        padding: 9px 10px;
        border-radius: 10px;
        font-size: 13px;
        line-height: 1.35;
        white-space: pre-wrap;
    }
    .wc-chat-item.user .wc-chat-bubble { background:#5c7cfa; color:#fff; border-bottom-right-radius: 4px; }
    .wc-chat-item.bot .wc-chat-bubble { background:#eceff8; color:#222; border-bottom-left-radius: 4px; }
    .wc-chat-products { display:grid; grid-template-columns: 1fr; gap:8px; margin: 6px 0 10px; }
    .wc-chat-product { display:flex; gap:8px; border:1px solid #dbe1f5; border-radius:8px; padding:8px; background:#fff; text-decoration:none; color:#1f2937; }
    .wc-chat-product:hover { background:#f8faff; }
    .wc-chat-product img { width:52px; height:52px; object-fit:cover; border-radius:6px; background:#eef2ff; flex-shrink:0; }
    .wc-chat-product-name { font-size:12px; font-weight:700; line-height:1.3; }
    .wc-chat-product-meta { font-size:11px; color:#6b7280; margin-top:3px; }
    .wc-chat-product-price { font-size:11px; color:#1d4ed8; font-weight:700; margin-top:4px; }
    .wc-chat-foot {
        padding: 10px;
        border-top: 1px solid #eee;
        display: flex;
        gap: 8px;
    }
    .wc-chat-input {
        flex: 1;
        border: 1px solid #d8dbe8;
        border-radius: 8px;
        padding: 8px 10px;
        font-family: 'Inter', sans-serif;
    }
    .wc-chat-send {
        border: none;
        border-radius: 8px;
        background: #5c7cfa;
        color: #fff;
        padding: 8px 12px;
        cursor: pointer;
    }

    @media (max-width: 640px) {
        .wc-chat-mini {
            right: 10px;
            bottom: 76px;
            width: calc(100vw - 20px);
        }
        .wc-chat-fab {
            right: 12px;
            bottom: 12px;
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
        
        <!-- Navigation Menu - Column 1 (LEFT) -->
        <ul class="header-nav">
            
            <!-- Menu cho Guest (Chưa đăng nhập) -->
            <% if (userRole == null || userRole.isEmpty()) { %>
                <li><a class="header-nav-main-btn" href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
                <li><a class="header-nav-main-btn cosplay-highlight" href="${pageContext.request.contextPath}/cosplay">Cosplay & Fes</a></li>
            <% } %>
            
            <!-- Menu cho User -->
            <% if ("User".equals(userRole)) { %>
                <li><a class="header-nav-main-btn" href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
                <li><a class="header-nav-main-btn cosplay-highlight" href="${pageContext.request.contextPath}/cosplay">Cosplay & Fes</a></li>
                <li><a href="${pageContext.request.contextPath}/rental?action=myOrders">Đơn Thuê Của Tôi</a></li>
                <li><a href="${pageContext.request.contextPath}/user?action=favorites">Yêu Thích</a></li>
            <% } %>
            

            <!-- Menu cho Manager (Người Cho Thuê Quần Áo) -->
            <% if ("Manager".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/manager">Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/clothing?action=myClothing">Quản Lý Sản Phẩm</a></li>
                <!--<li><a href="${pageContext.request.contextPath}/clothing?action=upload">Đăng Tải Mới</a></li>-->
                <li><a href="${pageContext.request.contextPath}/manager?action=orders">Đơn Đặt Thuê</a></li>
                <li><a href="${pageContext.request.contextPath}/manager?action=ratings">Đánh Giá</a></li>
            <% } %>
            
            <!-- Menu cho Admin -->
            <% if ("Admin".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/admin">Trang Chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=orders">Đơn Hàng</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=reviewCosplay">Xét Duyệt Cosplay</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=statistics">Thống Kê</a></li>
            <% } %>
            
        </ul>

        <!-- Logo - Column 2 (CENTER) -->
        <a href="<%= logoHref %>" class="header-logo">
            <img class="logo-img" src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="Wear Connect logo">
            <!-- <span class="brand-name">Wear Connect</span> -->
        </a>
        
        <!-- User Controls - Column 3 (RIGHT) -->
        <div class="header-right">
            <!-- User Info -->
            <% if (userRole != null && !userRole.isEmpty()) { %>
                            <div class="header-user-info header-auth-actions">
                                <div class="header-user-actions">
                                    <%-- Unread notifications --%>
                                    <%
                                        int currentUserID = -1;
                                        java.util.List<Model.Notification> unreadNotes = null;
                                        if (account != null) {
                                            Model.Account acc2 = (Model.Account) account;
                                            currentUserID = acc2.getAccountID();
                                            try {
                                                unreadNotes = Controller.NotificationController.getUnreadNotifications(currentUserID);
                                            } catch (Exception e) {
                                                unreadNotes = null;
                                            }
                                        }
                                        int unreadCount = (unreadNotes == null) ? 0 : unreadNotes.size();
                                    %>
                                    <div class="notif-wrapper" style="position:relative; display:inline-block;">
                                        <a href="${pageContext.request.contextPath}/user?action=notifications" style="text-decoration:none;">
                                            Thông báo 🔔
                                            <% if (unreadCount > 0) { %>
                                                <span style="position:absolute; top:-6px; right:-8px; background:#ff4757; color:white; border-radius:50%; padding:2px 6px; font-size:12px; font-weight:700;"><%= unreadCount %></span>
                                            <% } %>
                                        </a>
                                        <!-- Dropdown preview -->
                                        <div id="notifDropdown" class="notif-dropdown">
                                            <div class="notif-header">Thông Báo Mới Nhận</div>
                                            <div class="notif-list">
                                                <% if (unreadNotes != null && !unreadNotes.isEmpty()) {
                                                    for (Model.Notification nn : unreadNotes) { %>
                                                        <div class="notif-item">
                                                            <div class="notif-thumb">TB</div>
                                                            <div class="notif-body">
                                                                <div class="notif-title"><%= nn.getTitle() %></div>
                                                                <div class="notif-desc"><%= nn.getMessage() %></div>
                                                                <div class="notif-time"><%= nn.getFormattedCreatedAt() %></div>
                                                            </div>
                                                        </div>
                                                    <% }
                                                } else { %>
                                                    <div style="padding:18px; text-align:center; color:#666;">Không có thông báo mới</div>
                                                <% } %>
                                            </div>
                                            <div class="notif-footer">
                                                <a href="${pageContext.request.contextPath}/user?action=notifications">Xem tất cả</a>
                                            </div>
                                        </div>
                                </div>
                                    <% if ("User".equals(userRole)) { %>
                                        <a href="${pageContext.request.contextPath}/advisor-chat" class="advisor-prompt-btn">AI Picks</a>
                                    <% } %>
                                <div class="header-user-name">
                            <% 
                                // Show badge next to username if available
                                java.util.Map<String,Object> badge = null;
                                try {
                                    if (currentUserID > 0) {
                                        badge = Controller.RatingController.getBadgeForUser(currentUserID);
                                    }
                                } catch (Exception ex) {
                                    badge = null;
                                }
                            %>
                            <% if ("Manager".equals(userRole)) { %>
                                <a href="${pageContext.request.contextPath}/manager?action=profile" class="header-auth-link" style="display:inline-flex; align-items:center; gap:8px;">
                                    <span><%= (fullName != null && !fullName.trim().isEmpty()) ? fullName : username %></span>
                                    <%
                                        if (badge != null && badge.get("label") != null) {
                                            String bl = String.valueOf(badge.get("label"));
                                            Object d = badge.get("discount");
                                            String disc = (d!=null) ? (d.toString()+"%") : "";
                                    %>
                                        <span style="background:rgba(255,255,255,0.15); padding:4px 8px; border-radius:12px; font-size:12px; font-weight:700;"> <%= bl %> <%= disc %> </span>
                                    <%
                                        }
                                    %>
                                </a>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/user?action=profile" class="header-auth-link" style="display:inline-flex; align-items:center; gap:8px;">
                                    <span><%= (fullName != null && !fullName.trim().isEmpty()) ? fullName : username %></span>
                                    <%
                                        if (badge != null && badge.get("label") != null) {
                                            String bl = String.valueOf(badge.get("label"));
                                            Object d = badge.get("discount");
                                            String disc = (d!=null) ? (d.toString()+"%") : "";
                                    %>
                                        <span style="background:rgba(255,255,255,0.15); padding:4px 8px; border-radius:12px; font-size:12px; font-weight:700;"> <%= bl %> <%= disc %> </span>
                                    <%
                                        }
                                    %>
                                </a>
                            <% } %>
                        </div>
                        <a href="${pageContext.request.contextPath}/logout" class="logout-btn"> Đăng Xuất</a>
                    </div>
            <% } else { %>
                <div class="header-auth-actions">
                    <a href="${pageContext.request.contextPath}/login" class="header-auth-link auth-login">Đăng Nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="header-auth-link auth-register">Đăng Ký</a>
                </div>
            <% } %>
        </div>
    </div>
</header>

<button id="wcChatFab" class="wc-chat-fab" type="button" title="Chat với trợ lý">💬</button>
<div id="wcMiniChat" class="wc-chat-mini" aria-hidden="true">
    <div class="wc-chat-head">
        <span>Trợ lý WearConnect</span>
        <button id="wcChatClose" class="wc-chat-close" type="button">×</button>
    </div>
    <div id="wcChatMessages" class="wc-chat-messages"></div>
    <div class="wc-chat-foot">
        <input id="wcChatInput" class="wc-chat-input" type="text" placeholder="Nhập câu hỏi của bạn..." />
        <button id="wcChatSend" class="wc-chat-send" type="button">Gửi</button>
    </div>
</div>

<script>
    // Toggle notifications dropdown on bell click
    (function(){
        var bell = document.querySelector('.notif-wrapper > a[href$="action=notifications"]');
        var dd = document.getElementById('notifDropdown');
        if (!bell || !dd) return;
        // position container relative to header
        bell.addEventListener('click', function(e){
            e.preventDefault();
            // toggle using class for smoother styling
            if (dd.classList.contains('open')) {
                dd.classList.remove('open'); dd.style.display = 'none';
            } else {
                dd.classList.add('open'); dd.style.display = 'block';
            }
        });
        // close when clicking outside
        document.addEventListener('click', function(ev){
            if (dd.style.display === 'none') return;
            if (!dd.contains(ev.target) && !bell.contains(ev.target)) {
                dd.style.display = 'none';
            }
        });
    })();

    (function(){
        const key = 'wc_cosplay_spotlight_seen_v1';
        const cosplayLink = document.querySelector('.header-nav a.cosplay-highlight');
        if (!cosplayLink) return;

        try {
            if (!localStorage.getItem(key)) {
                cosplayLink.classList.add('cosplay-spotlight');
                setTimeout(function(){
                    cosplayLink.classList.remove('cosplay-spotlight');
                }, 8000);
                localStorage.setItem(key, '1');
            }
        } catch (e) {
            // Fallback when storage is unavailable
            cosplayLink.classList.add('cosplay-spotlight');
            setTimeout(function(){
                cosplayLink.classList.remove('cosplay-spotlight');
            }, 5000);
        }
    })();

    (function(){
        const contextPath = '<%= request.getContextPath() %>';
        const mini = document.getElementById('wcMiniChat');
        const fab = document.getElementById('wcChatFab');
        const closeBtn = document.getElementById('wcChatClose');
        const sendBtn = document.getElementById('wcChatSend');
        const input = document.getElementById('wcChatInput');
        const messages = document.getElementById('wcChatMessages');
        let conversationID = null;

        if (!mini || !fab || !closeBtn || !sendBtn || !input || !messages) return;

        function addMessage(role, text) {
            const item = document.createElement('div');
            item.className = 'wc-chat-item ' + (role === 'user' ? 'user' : 'bot');
            const bubble = document.createElement('div');
            bubble.className = 'wc-chat-bubble';
            bubble.textContent = text;
            item.appendChild(bubble);
            messages.appendChild(item);
            messages.scrollTop = messages.scrollHeight;
        }

        function addProductSuggestions(products) {
            if (!products || !products.length) return;

            const wrap = document.createElement('div');
            wrap.className = 'wc-chat-products';

            products.slice(0, 3).forEach(function(product){
                if (!product || !product.clothingID) return;

                const card = document.createElement('a');
                card.className = 'wc-chat-product';
                card.href = contextPath + '/clothing?action=view&id=' + product.clothingID;
                card.target = '_blank';
                card.rel = 'noopener noreferrer';

                const img = document.createElement('img');
                img.src = contextPath + '/image?id=' + product.clothingID;
                img.alt = product.clothingName || 'Sản phẩm';
                img.onerror = function() {
                    this.onerror = null;
                    this.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="52" height="52"%3E%3Crect width="52" height="52" fill="%23e5e7eb"/%3E%3Ctext x="50%25" y="50%25" dominant-baseline="middle" text-anchor="middle" fill="%236b7280" font-size="9"%3ENo%20Img%3C/text%3E%3C/svg%3E';
                };

                const body = document.createElement('div');
                const name = document.createElement('div');
                name.className = 'wc-chat-product-name';
                name.textContent = product.clothingName || ('Sản phẩm #' + product.clothingID);

                const meta = document.createElement('div');
                meta.className = 'wc-chat-product-meta';
                meta.textContent = (product.category || 'Khác') + (product.style ? (' • ' + product.style) : '');

                const price = document.createElement('div');
                price.className = 'wc-chat-product-price';
                if (product.dailyPrice) {
                    const parsed = Number(product.dailyPrice);
                    price.textContent = Number.isNaN(parsed)
                        ? ('Giá/ngày: ' + product.dailyPrice + 'đ')
                        : ('Giá/ngày: ' + new Intl.NumberFormat('vi-VN').format(parsed) + 'đ');
                } else {
                    price.textContent = 'Xem chi tiết giá';
                }

                body.appendChild(name);
                body.appendChild(meta);
                body.appendChild(price);
                card.appendChild(img);
                card.appendChild(body);
                wrap.appendChild(card);
            });

            if (wrap.childElementCount > 0) {
                messages.appendChild(wrap);
                messages.scrollTop = messages.scrollHeight;
            }
        }

        function openAdvisorPage(seedQuestion) {
            let target = contextPath + '/advisor-chat';
            const params = new URLSearchParams();
            if (seedQuestion && seedQuestion.trim()) {
                params.set('q', seedQuestion.trim());
            }
            if (conversationID) {
                params.set('conversationID', conversationID);
            }
            const query = params.toString();
            if (query) {
                target += '?' + query;
            }
            window.location.href = target;
        }

        function sendChatMessage(text) {
            if (!text || !text.trim()) return;
            const question = text.trim();
            addMessage('user', question);
            input.value = '';

            fetch(contextPath + '/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: question, conversationID: conversationID })
            })
            .then(async function(response){
                const data = await response.json();
                if (!response.ok || !data.success) {
                    if (response.status === 401) {
                        addMessage('bot', 'Bạn cần đăng nhập để sử dụng chatbot. Mình sẽ chuyển bạn đến trang đăng nhập.');
                        setTimeout(function(){ window.location.href = contextPath + '/login'; }, 1000);
                        return null;
                    }
                    throw new Error((data && data.error) ? data.error : 'SYSTEM_ERROR');
                }
                return data;
            })
            .then(function(data){
                if (!data) return;
                const payload = data.data || {};
                conversationID = payload.conversationID || conversationID;
                addMessage('bot', payload.assistantMessage || 'Mình chưa thể trả lời lúc này.');
                addProductSuggestions(payload.productSuggestions || []);

                if (payload.redirectToAdvisor) {
                    if (payload.redirectReason === 'CONSULT_ADVICE') {
                        setTimeout(function(){
                            addMessage('bot', 'Mình sẽ mở trang tư vấn chi tiết để hỗ trợ tốt hơn.');
                            setTimeout(function(){ openAdvisorPage(question); }, 500);
                        }, 350);
                    } else {
                        setTimeout(function(){ openAdvisorPage(question); }, 350);
                    }
                }
            })
            .catch(function(error){
                console.error(error);
                addMessage('bot', 'Hiện tại hệ thống đang bận, bạn thử lại sau ít phút nhé.');
            });
        }

        fab.addEventListener('click', function(){
            mini.classList.toggle('open');
            if (mini.classList.contains('open') && messages.childElementCount === 0) {
                addMessage('bot', 'Xin chào! Mình có thể trả lời nhanh các câu hỏi về hệ thống. Nếu cần tư vấn sâu, mình sẽ chuyển bạn sang trang tư vấn riêng.');
            }
        });

        closeBtn.addEventListener('click', function(){
            mini.classList.remove('open');
        });

        sendBtn.addEventListener('click', function(){
            sendChatMessage(input.value);
        });

        input.addEventListener('keydown', function(event){
            if (event.key === 'Enter') {
                event.preventDefault();
                sendChatMessage(input.value);
            }
        });
    })();
</script>
