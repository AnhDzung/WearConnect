<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

    .wearconnect-header {
        --primary-blue: #6366f1;
        --primary-blue-hover: #4f46e5;
        --white-text: #ffffff;
        --dark-gray-text: #475569;
        --green-start: #ec4899;
        --blue-end: #6366f1;
        --blue-border: #cbd5e1;
        --header-btn-gap: 10px;
        font-family: 'Inter', sans-serif;
        background: rgba(255, 255, 255, 0.8) !important;
        backdrop-filter: blur(16px) saturate(180%) !important;
        -webkit-backdrop-filter: blur(16px) saturate(180%) !important;
        color: #0f172a;
        padding: 10px 0;
        box-shadow: 0 4px 20px rgba(99, 102, 241, 0.05);
        border-bottom: 1px solid rgba(99, 102, 241, 0.12);
        margin-bottom: 24px;
        min-height: 80px;
        position: sticky !important;
        top: 0;
        z-index: 1000;
        transition: background 0.3s, box-shadow 0.3s;
    }
    
    .header-container {
        width: 100%;
        max-width: 1400px;
        padding: 0 clamp(16px, 2.5vw, 32px);
        box-sizing: border-box;
        margin: 0 auto;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        min-height: 60px;
    }

    /* Mobile hamburger and compact user button */
    .mobile-hamburger {
        display: none;
        background: rgba(99, 102, 241, 0.05);
        border: 1px solid rgba(99, 102, 241, 0.1);
        width: 44px;
        height: 44px;
        border-radius: 12px;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 20px;
        color: #4f46e5;
        transition: all 0.2s;
    }
    .mobile-hamburger:hover {
        background: rgba(99, 102, 241, 0.1);
        transform: scale(1.05);
    }
    .mobile-user-btn {
        display: none;
        background: rgba(255, 255, 255, 0.95);
        border: 1px solid rgba(99, 102, 241, 0.15);
        padding: 8px 12px;
        border-radius: 12px;
        font-weight: 700;
        font-size: 13px;
        color: #4f46e5;
        box-shadow: 0 2px 8px rgba(99, 102, 241, 0.05);
    }

    /* Mobile menu panel animation */
    #wcMobileMenu { display: none; }
    .wc-mobile-panel {
        width: 90%;
        max-width: 380px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border-right: 1px solid rgba(255, 255, 255, 0.5);
        height: 100%;
        overflow: auto;
        padding: 24px;
        box-shadow: 20px 0 80px rgba(99, 102, 241, 0.15);
        transform: translateX(-105%);
        transition: transform 350ms cubic-bezier(.2, .9, .2, 1);
    }
    .wc-mobile-panel.open {
        transform: translateX(0%);
    }

    /* hamburger open state */
    .mobile-hamburger.open {
        transform: rotate(90deg) scale(1.02);
        background: rgba(244, 63, 94, 0.1);
        color: #f43f5e;
        border-color: rgba(244, 63, 94, 0.2);
    }

    /* compact header on small screens */
    @media (max-width: 768px) {
        .wearconnect-header { padding: 6px 0; min-height: 56px; }
        .header-container { min-height: 56px; display: flex; align-items: center; justify-content: space-between; }
        .header-logo img.logo-img { width: 110px; height: 50px; }
    }

    .header-right {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
        flex-shrink: 0;
    }
    
    .header-logo {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
        text-decoration: none;
        transition: opacity var(--transition-fast), transform 0.2s;
    }
    .header-logo img.logo-img {
        width: 140px;
        height: 60px;
        object-fit: contain;
        display: block;
    }
    .header-logo:hover {
        transform: scale(1.02);
    }
    
    .header-nav {
        display: flex;
        gap: 6px;
        align-items: center;
        list-style: none;
        margin: 0;
        padding: 0;
        flex-shrink: 0;
    }
    
    .header-nav li {
        margin: 0;
        display: flex;
        align-items: center;
    }

    .header-auth-actions {
        display: flex;
        gap: var(--header-btn-gap);
        align-items: center;
    }

    .header-nav-main-btn {
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        height: 40px;
        padding: 0 16px !important;
        box-sizing: border-box;
        border-radius: var(--radius-md) !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        line-height: 1;
        text-align: center;
        white-space: nowrap;
        background: none !important;
        color: var(--dark-gray-text) !important;
        border: none !important;
        transition: all var(--transition-base);
    }
    
    .header-nav-main-btn:hover {
        color: var(--primary-color) !important;
        background: rgba(99, 102, 241, 0.06) !important;
    }

    .advisor-prompt-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        height: 40px;
        padding: 0 16px;
        border-radius: var(--radius-full);
        border: none;
        background: linear-gradient(135deg, #ff007f 0%, #7928ca 100%);
        color: #ffffff;
        font-size: 14px;
        font-weight: 700;
        line-height: 1;
        text-decoration: none;
        white-space: nowrap;
        box-shadow: 0 4px 12px rgba(244, 63, 94, 0.25);
        transition: transform 0.2s, box-shadow 0.2s;
    }

    .advisor-prompt-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(244, 63, 94, 0.4);
    }
    .advisor-prompt-btn:active {
        transform: scale(0.96);
    }
    
    .header-nav a, .header-nav button {
        display: block;
        padding: 10px 14px;
        color: var(--dark-gray-text);
        text-decoration: none;
        transition: all var(--transition-base);
        border: none;
        background: none;
        cursor: pointer;
        font-size: 14px;
        font-weight: 600;
        border-radius: var(--radius-md);
    }
    
    .header-nav a:hover, .header-nav button:hover {
        color: var(--primary-color);
        background: rgba(99, 102, 241, 0.06);
    }

    .header-nav > li > a.cosplay-highlight {
        font-weight: 700 !important;
        color: var(--primary-color) !important;
    }

    .header-nav > li > a.cosplay-highlight .cosplay-badge {
        display: inline-block;
        margin-left: 6px;
        padding: 2px 6px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 800;
        color: #fff;
        background: linear-gradient(135deg, #f43f5e, #e11d48);
        box-shadow: 0 2px 8px rgba(244, 63, 94, 0.35);
        vertical-align: middle;
    }

    @media (max-width: 1200px) {
        .header-nav {
            display: none; /* Hide on smaller screen - hamburger takes over */
        }
        .header-right {
            display: none;
        }
        .mobile-hamburger {
            display: inline-flex;
        }
        .mobile-user-btn {
            display: inline-flex;
        }
    }
    
    .header-user-info {
        display: flex;
        align-items: center;
        gap: 8px;
        justify-content: flex-end;
    }

    .header-user-actions {
        display: flex;
        align-items: center;
        gap: var(--header-btn-gap);
    }

    .header-user-name {
        font-size: 14px;
        font-weight: 600;
    }

    .header-user-name .header-auth-link {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        color: var(--gray-800);
        transition: color var(--transition-base);
    }
    .header-user-name .header-auth-link:hover {
        color: var(--primary-color);
    }
    
    .logout-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        height: 40px;
        padding: 0 16px !important;
        background: #ffffff !important;
        color: var(--primary-color) !important;
        border: 1.5px solid rgba(99, 102, 241, 0.4);
        border-radius: var(--radius-full);
        font-size: 14px !important;
        font-weight: 700;
        transition: all var(--transition-base);
    }
    .logout-btn:hover {
        background: rgba(99, 102, 241, 0.05) !important;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.15);
        transform: translateY(-1px);
    }
    .logout-btn:active {
        transform: scale(0.97);
    }

    .header-auth-link {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        height: 40px;
        padding: 0 16px;
        background: none;
        color: var(--dark-gray-text);
        text-decoration: none;
        border-radius: var(--radius-full);
        font-size: 14px;
        font-weight: 600;
        border: none;
        transition: all var(--transition-base);
    }
    .header-auth-link:hover {
        color: var(--primary-color);
        background: rgba(99, 102, 241, 0.05);
    }

    .header-auth-actions .auth-login,
    .header-auth-actions .auth-register {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0 18px;
        height: 40px;
        border-radius: var(--radius-full);
        font-size: 14px;
        font-weight: 700;
        transition: all var(--transition-base);
    }

    .header-auth-actions .auth-login {
        background: var(--primary-gradient);
        color: #ffffff;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
    }

    .header-auth-actions .auth-register {
        background: #ffffff;
        color: var(--primary-color);
        border: 1.5px solid rgba(99, 102, 241, 0.4);
    }

    .header-auth-actions .auth-login:hover,
    .header-auth-actions .auth-register:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
    }
    .header-auth-actions .auth-login:active,
    .header-auth-actions .auth-register:active {
        transform: scale(0.96);
    }
    
    /* Notifications dropdown styles */
    .notif-wrapper { position: relative; }
    .notif-wrapper > a {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        height: 40px;
        padding: 0 12px;
        border-radius: var(--radius-full);
        background: none;
        color: var(--dark-gray-text);
        font-size: 14px;
        font-weight: 600;
        transition: all var(--transition-base);
    }
    .notif-wrapper > a:hover { 
        color: var(--primary-color);
        background: rgba(99, 102, 241, 0.05);
    }
    .notif-dropdown {
        display: none;
        position: absolute;
        top: calc(100% + 12px);
        right: 0;
        width: 320px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(99, 102, 241, 0.15);
        color: #334155;
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-lg);
        overflow: hidden;
        z-index: 3000;
        font-size: 13px;
    }
    .notif-header { padding: 12px 16px; background: rgba(99, 102, 241, 0.05); font-weight: 700; color: var(--primary-color); border-bottom: 1px solid rgba(99, 102, 241, 0.1); }
    .notif-list { max-height: 320px; overflow:auto; }
    .notif-item { display:flex; gap:10px; padding:12px; border-bottom:1px solid rgba(99, 102, 241, 0.05); transition: background 0.2s; }
    .notif-item:hover { background: rgba(99, 102, 241, 0.02); }
    .notif-item:last-child { border-bottom:none; }
    .notif-thumb { width:38px; height:38px; border-radius:10px; background:rgba(99, 102, 241, 0.1); flex:0 0 38px; display:flex; align-items:center; justify-content:center; color:var(--primary-color); font-weight:700; }
    .notif-body { flex:1; }
    .notif-title { font-weight:700; font-size:12px; color:var(--gray-900); }
    .notif-desc { color:var(--gray-600); font-size:12px; margin-top:3px; line-height:1.3; }
    .notif-time { font-size:10px; color:var(--gray-400); margin-top:4px; }
    .notif-footer { padding:10px; text-align:center; background:#fff; border-top:1px solid rgba(99, 102, 241, 0.05); }
    .notif-footer a { color:var(--primary-color); text-decoration:none; font-weight:700; }

    /* Modern AI assistant FAB & Mini box */
    .wc-chat-fab {
        position: fixed;
        right: 24px;
        bottom: 24px;
        width: 56px;
        height: 56px;
        border-radius: 50%;
        border: none;
        background: linear-gradient(135deg, #ff007f 0%, #7928ca 100%);
        color: #fff;
        font-size: 24px;
        cursor: pointer;
        box-shadow: 0 10px 30px rgba(244, 63, 94, 0.35);
        z-index: 3900;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .wc-chat-fab:hover {
        transform: scale(1.08) translateY(-2px);
        box-shadow: 0 12px 36px rgba(244, 63, 94, 0.5);
    }
    .wc-chat-fab:active {
        transform: scale(0.96);
    }

    .wc-chat-mini {
        position: fixed;
        right: 24px;
        bottom: 92px;
        width: 350px;
        max-width: calc(100vw - 32px);
        height: 460px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(99, 102, 241, 0.15);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-xl);
        display: none;
        z-index: 3900;
        overflow: hidden;
    }

    .wc-chat-mini.open { display: flex; flex-direction: column; }
    .wc-chat-head {
        padding: 14px 16px;
        background: var(--primary-gradient);
        color: #fff;
        font-weight: 700;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .wc-chat-close { background: transparent; border: none; color: #fff; font-size: 18px; cursor: pointer; transition: opacity 0.2s; }
    .wc-chat-close:hover { opacity: 0.8; }
    .wc-chat-messages {
        flex: 1;
        padding: 14px;
        overflow-y: auto;
        background: rgba(99, 102, 241, 0.02);
    }
    .wc-chat-item { display:flex; margin-bottom:10px; }
    .wc-chat-item.user { justify-content:flex-end; }
    .wc-chat-bubble {
        max-width: 78%;
        padding: 10px 12px;
        border-radius: 12px;
        font-size: 13px;
        line-height: 1.4;
        white-space: pre-wrap;
    }
    .wc-chat-item.user .wc-chat-bubble { background: var(--primary-color); color:#fff; border-bottom-right-radius: 4px; box-shadow: 0 2px 8px rgba(99, 102, 241, 0.2); }
    .wc-chat-item.bot .wc-chat-bubble { background:#f1f5f9; color:#0f172a; border-bottom-left-radius: 4px; border: 1px solid #e2e8f0; }
    .wc-chat-foot {
        padding: 12px;
        border-top: 1px solid rgba(99, 102, 241, 0.1);
        display: flex;
        gap: 8px;
        background: #fff;
    }
    .wc-chat-input {
        flex: 1;
        border: 1px solid var(--gray-300);
        border-radius: var(--radius-md);
        padding: 8px 12px;
        font-family: 'Inter', sans-serif;
        font-size: 13px;
        transition: border-color 0.2s;
    }
    .wc-chat-input:focus {
        border-color: var(--primary-color);
        outline: none;
    }
    .wc-chat-send {
        border: none;
        border-radius: var(--radius-md);
        background: var(--primary-color);
        color: #fff;
        padding: 8px 16px;
        cursor: pointer;
        font-weight: 700;
        font-size: 13px;
        transition: all 0.2s;
    }
    .wc-chat-send:hover {
        background: var(--primary-hover);
        box-shadow: 0 2px 8px rgba(99, 102, 241, 0.3);
    }

    @media (max-width: 640px) {
        .wc-chat-mini {
            right: 16px;
            bottom: 84px;
            width: calc(100vw - 32px);
        }
        .wc-chat-fab {
            right: 16px;
            bottom: 16px;
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
                <li><a class="header-nav-main-btn" href="${pageContext.request.contextPath}/home">Thuê Đồ</a></li>
                <li><a class="header-nav-main-btn" href="${pageContext.request.contextPath}/buy">Mua Sản Phẩm</a></li>
                <li><a class="header-nav-main-btn cosplay-highlight" href="${pageContext.request.contextPath}/cosplay">Cosplay & Fes</a></li>
            <% } %>
            
            <!-- Menu cho User -->
            <% if ("User".equals(userRole)) { %>
                <li><a class="header-nav-main-btn" href="${pageContext.request.contextPath}/home">Thuê Đồ</a></li>
                <li><a class="header-nav-main-btn" href="${pageContext.request.contextPath}/buy">Mua Sản Phẩm</a></li>
                <li><a class="header-nav-main-btn cosplay-highlight" href="${pageContext.request.contextPath}/cosplay">Cosplay & Fes</a></li>
                <li><a href="${pageContext.request.contextPath}/rental?action=myOrders">Đơn Thuê Của Tôi</a></li>
                <li><a href="${pageContext.request.contextPath}/user?action=favorites">Yêu Thích</a></li>
                <%
                    int cartSize = 0;
                    java.util.List<?> cartList = (java.util.List<?>) session.getAttribute("cart");
                    if (cartList != null) {
                        cartSize = cartList.size();
                    }
                %>
                <li>
                    <a href="${pageContext.request.contextPath}/cart" style="position:relative; display:inline-flex; align-items:center; gap:4px; font-weight:600; text-decoration:none; padding: 0 16px; font-size: 14px; color: var(--dark-gray-text);">
                        Giỏ Hàng 🛒
                        <% if (cartSize > 0) { %>
                            <span style="background:#28a745; color:white; border-radius:50%; padding:1px 6px; font-size:11px; font-weight:700; display:inline-block; line-height:1.4;"><%= cartSize %></span>
                        <% } %>
                    </a>
                </li>
            <% } %>
            

            <!-- Menu cho Manager hoặc Seller -->
            <% if ("Manager".equals(userRole) || "Seller".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/manager">Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/clothing?action=myClothing">Quản Lý Sản Phẩm</a></li>
                <li><a href="${pageContext.request.contextPath}/manager?action=orders"><%= "Seller".equals(userRole) ? "Đơn Hàng Bán" : "Đơn Đặt Thuê" %></a></li>
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

                                        int adminPendingCount = 0;
                                        int adminVerifyingCount = 0;
                                        int adminNewOrdersCount = 0;
                                        if ("Admin".equals(userRole)) {
                                            try {
                                                adminPendingCount = Service.RentalOrderService.countOrdersByStatus("PENDING_PAYMENT");
                                                adminVerifyingCount = Service.RentalOrderService.countOrdersByStatus("PAYMENT_SUBMITTED");
                                                adminNewOrdersCount = adminPendingCount + adminVerifyingCount;
                                            } catch (Exception e) {
                                                adminNewOrdersCount = 0;
                                            }
                                        }

                                        int displayUnreadCount = "Admin".equals(userRole) ? adminNewOrdersCount : unreadCount;

                                        String notifLink = request.getContextPath() + "/user?action=notifications";
                                        if ("Admin".equals(userRole)) {
                                            if (adminPendingCount > 0) {
                                                notifLink = request.getContextPath() + "/admin?action=orders&status=PENDING";
                                            } else if (adminVerifyingCount > 0) {
                                                notifLink = request.getContextPath() + "/admin?action=orders&status=VERIFYING";
                                            } else {
                                                notifLink = request.getContextPath() + "/admin?action=orders";
                                            }
                                        }
                                    %>
                                    <div class="notif-wrapper" style="position:relative; display:inline-block;">
                                        <a id="notifBell" href="<%= notifLink %>" style="text-decoration:none;">
                                            Thông báo 🔔
                                            <% if (displayUnreadCount > 0) { %>
                                                <span style="position:absolute; top:-6px; right:-8px; background:#ff4757; color:white; border-radius:50%; padding:2px 6px; font-size:12px; font-weight:700;"><%= displayUnreadCount %></span>
                                            <% } %>
                                        </a>
                                        <!-- Dropdown preview -->
                                        <div id="notifDropdown" class="notif-dropdown">
                                            <div class="notif-header">Thông Báo Mới Nhận</div>
                                            <div class="notif-list">
                                                <% if ("Admin".equals(userRole)) {
                                                    if (adminNewOrdersCount > 0) {
                                                %>
                                                        <a href="<%= notifLink %>" style="text-decoration:none; color:inherit;">
                                                            <div class="notif-item" style="cursor:pointer; background:#fff3cd; border-left:4px solid #ffeeba;">
                                                                <div class="notif-thumb" style="background:#ffc107; color:#856404;">🔔</div>
                                                                <div class="notif-body">
                                                                    <div class="notif-title" style="font-weight:700; color:#856404;">Đơn hàng cần duyệt</div>
                                                                    <div class="notif-desc" style="color:#666;">Có <%= adminNewOrdersCount %> đơn hàng cần xác nhận. (PENDING: <%= adminPendingCount %>, VERIFYING: <%= adminVerifyingCount %>)</div>
                                                                    <div class="notif-time">Nhấp để xem đơn cần duyệt</div>
                                                                </div>
                                                            </div>
                                                        </a>
                                                <%  } else { %>
                                                        <div style="padding:18px; text-align:center; color:#666;">Không có đơn hàng cần xác nhận</div>
                                                <%  }
                                                } else { %>
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
                                                <% } %>
                                            </div>
                                            <div class="notif-footer">
                                                <% if ("Admin".equals(userRole)) { %>
                                                    <a href="${pageContext.request.contextPath}/admin?action=orders">Xem tất cả đơn hàng</a>
                                                <% } else { %>
                                                    <a href="${pageContext.request.contextPath}/user?action=notifications">Xem tất cả</a>
                                                <% } %>
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
        var bell = document.getElementById('notifBell');
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

<!-- Mobile menu overlay -->
<div id="wcMobileMenu" style="display:none; position:fixed; inset:0; z-index:5000; background:rgba(0,0,0,0.6);">
    <div class="wc-mobile-panel">
        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:16px;">
            <a href="<%= logoHref %>" style="display:flex; align-items:center; gap:8px; text-decoration:none; color:#111;">
                <img src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="logo" style="height:40px;">
                <strong>WearConnect</strong>
            </a>
            <button id="wcMobileClose" style="background:none;border:none;font-size:28px;cursor:pointer;">×</button>
        </div>
        <nav style="display:flex; flex-direction:column; gap:10px;">
            <a href="${pageContext.request.contextPath}/home" style="padding:12px 10px; border-radius:8px; background:#f7f7fb; text-decoration:none; color:#111;">Thuê Đồ</a>
            <a href="${pageContext.request.contextPath}/buy" style="padding:12px 10px; border-radius:8px; background:#f7f7fb; text-decoration:none; color:#111;">Mua Sản Phẩm</a>
            <a href="${pageContext.request.contextPath}/cosplay" style="padding:12px 10px; border-radius:8px; background:#f7f7fb; text-decoration:none; color:#111;">Cosplay & Fes</a>
            <a href="${pageContext.request.contextPath}/rental?action=myOrders" style="padding:12px 10px; border-radius:8px; background:#f7f7fb; text-decoration:none; color:#111;">Đơn Thuê Của Tôi</a>
            <a href="${pageContext.request.contextPath}/user?action=favorites" style="padding:12px 10px; border-radius:8px; background:#f7f7fb; text-decoration:none; color:#111;">Yêu Thích</a>
            <c:if test="${sessionScope.userRole == 'Manager' || sessionScope.userRole == 'Renter'}">
                <a href="${pageContext.request.contextPath}/manager" style="padding:12px 10px; border-radius:8px; background:#f7f7fb; text-decoration:none; color:#111;">Dashboard</a>
            </c:if>
            <hr style="border:none; height:1px; background:#eee; margin:12px 0;">
            <c:choose>
                <c:when test="${not empty sessionScope.userRole}">
                    <a href="${pageContext.request.contextPath}/user?action=profile" style="padding:12px 10px; border-radius:8px; background:#fff; text-decoration:none; color:#111;">Hồ sơ</a>
                    <a href="${pageContext.request.contextPath}/user?action=notifications" style="padding:12px 10px; border-radius:8px; background:#fff; text-decoration:none; color:#111;">Thông báo</a>
                    <a href="${pageContext.request.contextPath}/logout" style="padding:12px 10px; border-radius:8px; background:#fff; text-decoration:none; color:#d33;">Đăng Xuất</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" style="padding:12px 10px; border-radius:8px; background:#fff; text-decoration:none; color:#111;">Đăng Nhập</a>
                    <a href="${pageContext.request.contextPath}/register" style="padding:12px 10px; border-radius:8px; background:#fff; text-decoration:none; color:#111;">Đăng Ký</a>
                </c:otherwise>
            </c:choose>
        </nav>
    </div>
</div>

<script>
    (function(){
        // mobile menu toggle
        const openBtn = document.createElement('button');
        openBtn.className = 'mobile-hamburger';
        openBtn.id = 'wcMobileOpen';
        openBtn.setAttribute('aria-label','Mở menu');
        openBtn.innerHTML = '☰';

        // inject into header (before logo)
        const headerContainer = document.querySelector('.header-container');
        if (headerContainer) {
            headerContainer.insertBefore(openBtn, headerContainer.firstChild);
        }

        const mobileMenu = document.getElementById('wcMobileMenu');
        const closeBtn = document.getElementById('wcMobileClose');
        if (openBtn && mobileMenu) {
            const panel = mobileMenu.querySelector('.wc-mobile-panel');
            openBtn.addEventListener('click', function(){ 
                mobileMenu.style.display = 'block';
                // allow overlay to paint then slide in panel
                setTimeout(function(){ panel.classList.add('open'); openBtn.classList.add('open'); }, 20);
                document.body.style.overflow='hidden';
            });

            // close when clicking outside panel
            mobileMenu.addEventListener('click', function(e){
                if (e.target === mobileMenu) {
                    panel.classList.remove('open'); openBtn.classList.remove('open');
                    setTimeout(function(){ mobileMenu.style.display = 'none'; document.body.style.overflow=''; }, 340);
                }
            });
        }
        if (closeBtn && mobileMenu) {
            const panel = mobileMenu.querySelector('.wc-mobile-panel');
            closeBtn.addEventListener('click', function(){ 
                panel.classList.remove('open'); openBtn.classList.remove('open');
                setTimeout(function(){ mobileMenu.style.display = 'none'; document.body.style.overflow=''; }, 340);
            });
        }
    })();
</script>
