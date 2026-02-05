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
        overflow-x: visible;  /* allow dropdown to overflow without adding scrollbar */
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
    /* Notifications dropdown styles (match provided screenshot) */
    .notif-wrapper { position: relative; }
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
                                <div style="display:flex; align-items:center; gap:12px;">
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
                                        <a href="${pageContext.request.contextPath}/user?action=notifications" style="color:white; text-decoration:none;">
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
</script>
