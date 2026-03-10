<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .wearconnect-header {
        background: linear-gradient(135deg, #f5fbff 0%, #0cc0df 100%);
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
        width: 185px;
        height: 117px;
        object-fit: contain;
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
        font-family: cursive;
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
        
        <a href="<%= logoHref %>" class="header-logo">
            <img class="logo-img" src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="Wear Connect logo">
            <span class="brand-name">Wear Connect</span>
        </a>
        
        <!-- Navigation Menu -->
        <ul class="header-nav">
            
            <!-- Menu cho Guest (Chưa đăng nhập) -->
            <% if (userRole == null || userRole.isEmpty()) { %>
                <li><a href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
                <li><a href="${pageContext.request.contextPath}/cosplay">Cosplay & Fes</a></li>
            <% } %>
            
            <!-- Menu cho User -->
            <% if ("User".equals(userRole)) { %>
                <li><a href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
                <li><a href="${pageContext.request.contextPath}/cosplay">Cosplay & Fes</a></li>
                <li><a href="${pageContext.request.contextPath}/rental?action=myOrders">Đơn Thuê Của Tôi</a></li>
                <li><a href="${pageContext.request.contextPath}/return?action=list">Trả Hàng</a></li>
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
                <li><a href="${pageContext.request.contextPath}/">Trang Chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=orders">Đơn Hàng</a></li>
                <li><a href="${pageContext.request.contextPath}/admin?action=reviewCosplay">Xét Duyệt Cosplay</a></li>
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
                                <a href="${pageContext.request.contextPath}/manager?action=profile" style="color: white; text-decoration: none; display:inline-flex; align-items:center; gap:8px;">
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
                                <a href="${pageContext.request.contextPath}/user?action=profile" style="color: white; text-decoration: none; display:inline-flex; align-items:center; gap:8px;">
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
                </li>
            <% } else { %>
                <li style="margin-left: auto;">
                    <div style="display:flex; gap:8px; align-items:center;">
                        <a href="${pageContext.request.contextPath}/login" style="display:inline-block; padding:8px 12px; background:transparent; border:1px solid rgba(255,255,255,0.15); color:white; text-decoration:none; border-radius:6px;">Đăng Nhập</a>
                        <a href="${pageContext.request.contextPath}/register" style="display:inline-block; padding:8px 12px; background:rgba(255,255,255,0.15); color:white; text-decoration:none; border-radius:6px;">Đăng Ký</a>
                    </div>
                </li>
            <% } %>
        </ul>
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
