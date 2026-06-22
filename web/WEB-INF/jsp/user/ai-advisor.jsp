<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tư vấn AI - WearConnect</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

        body { font-family: var(--font-family); background-color: var(--gray-100); color: var(--gray-900); }
        h1, h2, h3, h4, h5, h6, .advisor-title, .advisor-side-title { font-family: var(--heading-font-family); }
        .advisor-wrap { max-width: 1200px; margin: 30px auto; padding: 0 16px; }
        .advisor-layout { display: grid; grid-template-columns: 280px 1fr; gap: 20px; }
        
        .advisor-sidebar,
        .advisor-card { 
            background: rgba(255, 255, 255, 0.75); 
            backdrop-filter: blur(12px) saturate(180%);
            -webkit-backdrop-filter: blur(12px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.45);
            border-radius: var(--radius-lg); 
            box-shadow: var(--shadow-lg); 
            overflow: hidden; 
            transition: transform var(--transition-base), box-shadow var(--transition-base);
        }
        
        .advisor-side-head { 
            padding: 16px; 
            border-bottom: 1.5px solid rgba(99, 102, 241, 0.1); 
            display: flex; 
            flex-direction: column; 
            gap: 12px; 
        }
        
        .advisor-side-title { 
            font-size: var(--font-size-base); 
            font-weight: 800; 
            color: var(--gray-800); 
            letter-spacing: 0.5px;
        }
        
        .advisor-side-actions { 
            display: flex; 
            flex-direction: column;
            gap: 8px; 
        }
        
        .advisor-new-btn { 
            border: none; 
            border-radius: var(--radius-full); 
            background: var(--primary-gradient); 
            color: var(--white); 
            padding: 10px 16px; 
            cursor: pointer; 
            font-size: var(--font-size-sm); 
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
            transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275), box-shadow var(--transition-base);
            text-align: center;
        }
        .advisor-new-btn:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
        }
        .advisor-new-btn:active {
            transform: scale(0.96);
        }
        
        .advisor-clear-btn { 
            border: 1px solid var(--danger-color); 
            border-radius: var(--radius-full); 
            background: rgba(255, 255, 255, 0.8); 
            color: var(--danger-color); 
            padding: 9px 16px; 
            cursor: pointer; 
            font-size: var(--font-size-sm); 
            font-weight: 600;
            transition: all var(--transition-base);
            text-align: center;
        }
        .advisor-clear-btn:hover { 
            background: rgba(244, 63, 94, 0.08); 
            transform: translateY(-1px);
        }
        .advisor-clear-btn:active {
            transform: scale(0.97);
        }
        
        .advisor-history-list { 
            max-height: 600px; 
            overflow-y: auto; 
            padding: 12px; 
            scrollbar-width: thin;
            scrollbar-color: rgba(99, 102, 241, 0.2) transparent;
        }
        .advisor-history-list::-webkit-scrollbar {
            width: 5px;
        }
        .advisor-history-list::-webkit-scrollbar-thumb {
            background-color: rgba(99, 102, 241, 0.2);
            border-radius: var(--radius-full);
        }
        
        .advisor-history-item { 
            border: 1px solid rgba(99, 102, 241, 0.1); 
            border-radius: var(--radius-md); 
            padding: 12px; 
            margin-bottom: 10px; 
            cursor: pointer; 
            background: rgba(255, 255, 255, 0.4); 
            transition: all var(--transition-base);
        }
        .advisor-history-item:hover {
            border-color: rgba(99, 102, 241, 0.4);
            background: rgba(255, 255, 255, 0.8);
            transform: translateX(3px);
        }
        .advisor-history-item.active { 
            border-color: var(--primary-color); 
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(168, 85, 247, 0.08) 100%);
            box-shadow: inset 0 0 0 1px var(--primary-color), var(--shadow-sm);
        }
        .advisor-history-id { 
            font-size: var(--font-size-sm); 
            font-weight: 700; 
            color: var(--gray-800); 
        }
        .advisor-history-meta { 
            font-size: var(--font-size-xs); 
            color: var(--gray-500); 
            margin-top: 6px; 
        }
        .advisor-empty { 
            padding: 16px; 
            font-size: var(--font-size-sm); 
            color: var(--gray-500); 
            text-align: center;
        }
        
        .advisor-head { 
            padding: 20px; 
            border-bottom: 1.5px solid rgba(99, 102, 241, 0.1); 
            background: linear-gradient(to right, rgba(99, 102, 241, 0.03), rgba(168, 85, 247, 0.03));
        }
        .advisor-title { 
            font-size: var(--font-size-2xl); 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .advisor-sub { 
            font-size: var(--font-size-sm); 
            color: var(--gray-600); 
            margin-top: 6px; 
            line-height: 1.5;
        }
        
        .advisor-messages { 
            height: 520px; 
            overflow-y: auto; 
            padding: 20px; 
            background: rgba(248, 250, 252, 0.4); 
            scrollbar-width: thin;
            scrollbar-color: rgba(99, 102, 241, 0.2) transparent;
        }
        .advisor-messages::-webkit-scrollbar {
            width: 5px;
        }
        .advisor-messages::-webkit-scrollbar-thumb {
            background-color: rgba(99, 102, 241, 0.2);
            border-radius: var(--radius-full);
        }
        
        .advisor-item { margin-bottom: 16px; display: flex; }
        .advisor-item.user { justify-content: flex-end; }
        .advisor-bubble { 
            max-width: 75%; 
            padding: 12px 16px; 
            border-radius: var(--radius-lg); 
            line-height: 1.5; 
            white-space: pre-wrap; 
            font-size: var(--font-size-base);
            box-shadow: var(--shadow-sm);
        }
        .advisor-item.user .advisor-bubble { 
            background: var(--primary-gradient); 
            color: var(--white); 
            border-bottom-right-radius: 4px; 
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
        }
        .advisor-item.bot .advisor-bubble { 
            background: var(--white); 
            color: var(--gray-800); 
            border-bottom-left-radius: 4px; 
            border: 1px solid rgba(99, 102, 241, 0.1);
        }
        
        .advisor-product-wrap { margin: 16px 0; }
        .advisor-products-title { 
            font-size: var(--font-size-sm); 
            color: var(--gray-700); 
            margin: 0 0 10px 2px; 
            font-weight: 700; 
            letter-spacing: 0.3px;
        }
        .advisor-products { 
            display: grid; 
            grid-template-columns: repeat(2, minmax(0, 1fr)); 
            gap: 16px; 
        }
        .advisor-product-card { 
            border: 1px solid rgba(99, 102, 241, 0.1); 
            border-radius: var(--radius-lg); 
            overflow: hidden; 
            background: var(--white); 
            text-decoration: none; 
            color: var(--gray-800);
            box-shadow: var(--shadow-sm);
            transition: all var(--transition-base);
            display: flex;
            flex-direction: column;
        }
        .advisor-product-card:hover {
            transform: translateY(-4px);
            border-color: var(--primary-color);
            box-shadow: var(--shadow-md);
        }
        .advisor-product-thumb { 
            width: 100%; 
            height: 130px; 
            object-fit: cover; 
            display: block; 
            background: var(--gray-100); 
            transition: transform var(--transition-base);
        }
        .advisor-product-card:hover .advisor-product-thumb {
            transform: scale(1.03);
        }
        .advisor-product-body { 
            padding: 12px; 
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            gap: 6px;
        }
        .advisor-product-name { 
            font-size: var(--font-size-base); 
            font-weight: 700; 
            line-height: 1.4; 
            min-height: 40px;
            color: var(--gray-900);
        }
        .advisor-product-meta { 
            font-size: var(--font-size-xs); 
            color: var(--gray-500); 
        }
        .advisor-product-price { 
            margin-top: auto; 
            color: var(--primary-color); 
            font-size: var(--font-size-base); 
            font-weight: 800; 
        }
        .advisor-product-cta { 
            margin-top: 8px; 
            display: inline-block; 
            text-align: center;
            font-size: var(--font-size-xs); 
            font-weight: 700; 
            color: var(--white); 
            background: var(--primary-gradient); 
            border: none; 
            border-radius: var(--radius-full); 
            padding: 8px 12px; 
            transition: all var(--transition-fast);
            box-shadow: 0 2px 8px rgba(99, 102, 241, 0.15);
        }
        .advisor-product-card:hover .advisor-product-cta {
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
            transform: scale(1.02);
        }
        
        .advisor-actions { 
            padding: 16px; 
            border-top: 1.5px solid rgba(99, 102, 241, 0.1); 
            display: flex; 
            gap: 12px; 
            background: var(--white);
        }
        .advisor-input { 
            flex: 1; 
            border: 1px solid var(--gray-300); 
            border-radius: var(--radius-full); 
            padding: 12px 20px; 
            font-family: var(--font-family); 
            font-size: var(--font-size-base);
            background-color: var(--gray-50);
            transition: all var(--transition-base);
        }
        .advisor-input:focus {
            outline: none;
            background-color: var(--white);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }
        
        .advisor-send { 
            border: none; 
            background: var(--primary-gradient); 
            color: var(--white); 
            border-radius: var(--radius-full); 
            padding: 12px 24px; 
            cursor: pointer; 
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
            transition: all var(--transition-base);
        }
        .advisor-send:hover { 
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
        }
        .advisor-send:active {
            transform: scale(0.96);
        }
        
        .advisor-note { 
            padding: 0 20px 20px 20px; 
            font-size: var(--font-size-xs); 
            color: var(--gray-500); 
            background: var(--white);
        }

        @media (max-width: 960px) {
            .advisor-wrap { margin: 15px auto; }
            .advisor-layout { grid-template-columns: 1fr; gap: 16px; }
            .advisor-history-list { max-height: 180px; }
            .advisor-products { grid-template-columns: 1fr; }
            .advisor-side-actions { flex-direction: row; flex-wrap: wrap; }
            .advisor-side-actions > * { flex: 1; min-width: 100px; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="advisor-wrap">
    <div class="advisor-layout">
        <aside class="advisor-sidebar">
            <div class="advisor-side-head">
                <div class="advisor-side-title">Lịch sử tư vấn</div>
                <div class="advisor-side-actions">
                    <button id="newConversationBtn" class="advisor-new-btn" type="button">+ Tư vấn mới</button>
                    <button id="deleteConversationBtn" class="advisor-clear-btn" type="button">Xóa hội thoại</button>
                    <button id="deleteAllConversationsBtn" class="advisor-clear-btn" type="button">Xóa tất cả</button>
                </div>
            </div>
            <div id="advisorHistoryList" class="advisor-history-list"></div>
        </aside>

        <div class="advisor-card">
            <div class="advisor-head">
                <div class="advisor-title">Trang tư vấn AI</div>
                <div class="advisor-sub">Phù hợp cho các câu hỏi cần tư vấn chi tiết về size, phong cách, phối đồ và chọn trang phục phù hợp theo dịp.</div>
            </div>
            <div id="advisorMessages" class="advisor-messages"></div>
            <div class="advisor-actions">
                <input id="advisorInput" class="advisor-input" type="text" placeholder="Nhập câu hỏi tư vấn của bạn..." />
                <button id="advisorSend" class="advisor-send" type="button">Gửi</button>
            </div>
            <div class="advisor-note">Nếu chưa đăng nhập, hệ thống sẽ yêu cầu đăng nhập để dùng chatbot.</div>
        </div>
    </div>
</div>

<script>
(function(){
    const contextPath = '<%= request.getContextPath() %>';
    const input = document.getElementById('advisorInput');
    const sendBtn = document.getElementById('advisorSend');
    const messagesEl = document.getElementById('advisorMessages');
    const historyListEl = document.getElementById('advisorHistoryList');
    const newConversationBtn = document.getElementById('newConversationBtn');
    const deleteConversationBtn = document.getElementById('deleteConversationBtn');
    const deleteAllConversationsBtn = document.getElementById('deleteAllConversationsBtn');

    const params = new URLSearchParams(window.location.search);
    let currentConversationID = params.get('conversationID') ? parseInt(params.get('conversationID'), 10) : null;
    const initialQuestion = params.get('q');
    const suggestionCacheKey = 'advisorProductSuggestionCacheV1';
    let suggestionCache = loadSuggestionCache();

    function loadSuggestionCache() {
        try {
            const raw = sessionStorage.getItem(suggestionCacheKey);
            if (!raw) {
                return {};
            }
            const parsed = JSON.parse(raw);
            return parsed && typeof parsed === 'object' ? parsed : {};
        } catch (error) {
            console.warn('Cannot parse suggestion cache:', error);
            return {};
        }
    }

    function saveSuggestionCache() {
        try {
            sessionStorage.setItem(suggestionCacheKey, JSON.stringify(suggestionCache));
        } catch (error) {
            console.warn('Cannot persist suggestion cache:', error);
        }
    }

    function toConversationKey(conversationID) {
        if (!conversationID) {
            return null;
        }
        return String(conversationID);
    }

    function cacheProductSuggestions(conversationID, assistantMessageID, products) {
        const conversationKey = toConversationKey(conversationID);
        if (!conversationKey || !assistantMessageID || !products || !products.length) {
            return;
        }

        if (!suggestionCache[conversationKey]) {
            suggestionCache[conversationKey] = {};
        }
        suggestionCache[conversationKey][String(assistantMessageID)] = products;
        saveSuggestionCache();
    }

    function getCachedProductSuggestions(conversationID, assistantMessageID) {
        const conversationKey = toConversationKey(conversationID);
        if (!conversationKey || !assistantMessageID || !suggestionCache[conversationKey]) {
            return [];
        }
        return suggestionCache[conversationKey][String(assistantMessageID)] || [];
    }

    function removeConversationSuggestionCache(conversationID) {
        const conversationKey = toConversationKey(conversationID);
        if (!conversationKey || !suggestionCache[conversationKey]) {
            return;
        }
        delete suggestionCache[conversationKey];
        saveSuggestionCache();
    }

    function clearAllSuggestionCache() {
        suggestionCache = {};
        saveSuggestionCache();
    }

    function syncConversationInUrl() {
        const url = new URL(window.location.href);
        if (currentConversationID) {
            url.searchParams.set('conversationID', String(currentConversationID));
        } else {
            url.searchParams.delete('conversationID');
        }
        url.searchParams.delete('q');
        window.history.replaceState({}, '', url.toString());
    }

    function addMessage(role, text) {
        const item = document.createElement('div');
        item.className = 'advisor-item ' + (role === 'user' ? 'user' : 'bot');
        const bubble = document.createElement('div');
        bubble.className = 'advisor-bubble';
        bubble.textContent = text;
        item.appendChild(bubble);
        messagesEl.appendChild(item);
        messagesEl.scrollTop = messagesEl.scrollHeight;
    }

    function addProductSuggestions(products) {
        if (!products || !products.length) {
            return;
        }

        const wrap = document.createElement('div');
        wrap.className = 'advisor-product-wrap';

        const title = document.createElement('div');
        title.className = 'advisor-products-title';
        title.textContent = 'Sản phẩm liên quan:';
        wrap.appendChild(title);

        const grid = document.createElement('div');
        grid.className = 'advisor-products';

        products.forEach(function(product){
            const card = document.createElement('a');
            card.className = 'advisor-product-card';
            card.href = contextPath + '/clothing?action=view&id=' + product.clothingID;
            card.target = '_blank';
            card.rel = 'noopener noreferrer';

            const image = document.createElement('img');
            image.className = 'advisor-product-thumb';
            image.src = contextPath + '/image?id=' + product.clothingID;
            image.alt = product.clothingName || 'Sản phẩm';
            image.onerror = function(){
                this.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="220" height="110"%3E%3Crect width="220" height="110" fill="%23e5e7eb"/%3E%3Ctext x="50%25" y="50%25" dominant-baseline="middle" text-anchor="middle" fill="%236b7280" font-size="14"%3EKh%C3%B4ng%20c%C3%B3%20%E1%BA%A3nh%3C/text%3E%3C/svg%3E';
            };

            const body = document.createElement('div');
            body.className = 'advisor-product-body';

            const name = document.createElement('div');
            name.className = 'advisor-product-name';
            name.textContent = product.clothingName || ('Sản phẩm #' + product.clothingID);

            const meta = document.createElement('div');
            meta.className = 'advisor-product-meta';
            meta.textContent = (product.category || 'Khác') + ' • ' + (product.style || 'Không rõ style');

            const price = document.createElement('div');
            price.className = 'advisor-product-price';
            if (product.dailyPrice) {
                const value = Number(product.dailyPrice);
                if (!Number.isNaN(value)) {
                    price.textContent = 'Giá/ngày: ' + new Intl.NumberFormat('vi-VN').format(value) + 'đ';
                } else {
                    price.textContent = 'Giá/ngày: ' + product.dailyPrice + 'đ';
                }
            } else {
                price.textContent = 'Xem chi tiết giá';
            }

            const cta = document.createElement('span');
            cta.className = 'advisor-product-cta';
            cta.textContent = 'Xem chi tiết';

            body.appendChild(name);
            body.appendChild(meta);
            body.appendChild(price);
            body.appendChild(cta);

            card.appendChild(image);
            card.appendChild(body);
            grid.appendChild(card);
        });

        wrap.appendChild(grid);
        messagesEl.appendChild(wrap);
        messagesEl.scrollTop = messagesEl.scrollHeight;
    }

    function clearMessages() {
        messagesEl.innerHTML = '';
    }

    function renderHistory(conversations) {
        historyListEl.innerHTML = '';
        if (!conversations || conversations.length === 0) {
            const empty = document.createElement('div');
            empty.className = 'advisor-empty';
            empty.textContent = 'Chưa có lịch sử tư vấn.';
            historyListEl.appendChild(empty);
            return;
        }

        conversations.forEach(function(conversation){
            const item = document.createElement('div');
            item.className = 'advisor-history-item' + (conversation.conversationID === currentConversationID ? ' active' : '');
            item.dataset.conversationId = conversation.conversationID;

            const id = document.createElement('div');
            id.className = 'advisor-history-id';
            id.textContent = 'Hội thoại #' + conversation.conversationID;

            const meta = document.createElement('div');
            meta.className = 'advisor-history-meta';
            const status = conversation.status || 'OPEN';
            const lastMessageAt = conversation.lastMessageAt || 'N/A';
            meta.textContent = 'Trạng thái: ' + status + ' • ' + lastMessageAt;

            item.appendChild(id);
            item.appendChild(meta);
            item.addEventListener('click', function(){
                loadConversation(conversation.conversationID);
            });

            historyListEl.appendChild(item);
        });
    }

    function loadConversations(forceSelectFirst) {
        return fetch(contextPath + '/chat?action=conversations&limit=30')
            .then(async function(response){
                const data = await response.json();
                if (!response.ok || !data.success) {
                    throw new Error((data && data.error) ? data.error : 'LOAD_CONVERSATIONS_FAILED');
                }
                const conversations = data.conversations || [];
                renderHistory(conversations);

                if (!currentConversationID && forceSelectFirst && conversations.length > 0) {
                    loadConversation(conversations[0].conversationID);
                }
            })
            .catch(function(error){
                console.error(error);
                historyListEl.innerHTML = '<div class="advisor-empty">Không tải được lịch sử tư vấn.</div>';
            });
    }

    function loadConversation(conversationID) {
        if (!conversationID || Number.isNaN(conversationID)) {
            return;
        }

        fetch(contextPath + '/chat?conversationID=' + conversationID + '&limit=40')
            .then(async function(response){
                const data = await response.json();
                if (!response.ok || !data.success) {
                    throw new Error((data && data.error) ? data.error : 'LOAD_HISTORY_FAILED');
                }
                currentConversationID = conversationID;
                syncConversationInUrl();
                clearMessages();
                const messages = data.messages || [];
                if (messages.length === 0) {
                    addMessage('bot', 'Hội thoại này chưa có nội dung. Bạn có thể bắt đầu đặt câu hỏi.');
                } else {
                    messages.forEach(function(message){
                        const role = (message.role || '').toUpperCase() === 'USER' ? 'user' : 'bot';
                        addMessage(role, message.content || '');

                        if (role === 'bot') {
                            const cachedProducts = getCachedProductSuggestions(conversationID, message.messageID);
                            if (cachedProducts.length > 0) {
                                addProductSuggestions(cachedProducts);
                            }
                        }
                    });
                }
                loadConversations(false);
            })
            .catch(function(error){
                console.error(error);
                addMessage('bot', 'Không tải được lịch sử hội thoại này.');
            });
    }

    function createNewConversation() {
        return fetch(contextPath + '/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'new_conversation' })
        })
        .then(async function(response){
            const data = await response.json();
            if (!response.ok || !data.success) {
                throw new Error((data && data.error) ? data.error : 'CREATE_CONVERSATION_FAILED');
            }

            const payload = data.data || {};
            currentConversationID = payload.conversationID || null;
            syncConversationInUrl();
            clearMessages();
            addMessage('bot', 'Mình đã tạo phiên tư vấn mới. Bạn muốn tư vấn theo phong cách nào?');
            loadConversations(false);
        })
        .catch(function(error){
            console.error(error);
            addMessage('bot', 'Chưa tạo được phiên tư vấn mới, bạn thử lại sau nhé.');
        });
    }

    function deleteCurrentConversation() {
        if (!currentConversationID) {
            addMessage('bot', 'Bạn cần chọn một hội thoại để xóa.');
            return;
        }

        const targetConversationID = currentConversationID;
        const confirmed = window.confirm('Bạn có chắc muốn xóa hội thoại #' + targetConversationID + ' không?');
        if (!confirmed) {
            return;
        }

        fetch(contextPath + '/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'delete_conversation', conversationID: targetConversationID })
        })
        .then(async function(response){
            const data = await response.json();
            if (response.status === 401) {
                throw new Error('UNAUTHORIZED');
            }
            if (!response.ok || !data.success) {
                const detail = (data && (data.detail || data.error)) ? (data.detail || data.error) : 'DELETE_CONVERSATION_FAILED';
                throw new Error(detail);
            }

            currentConversationID = null;
            removeConversationSuggestionCache(targetConversationID);
            syncConversationInUrl();
            clearMessages();
            addMessage('bot', 'Mình đã xóa hội thoại #' + targetConversationID + '. Bạn có thể chọn hội thoại khác hoặc tạo tư vấn mới.');
            loadConversations(true);
        })
        .catch(function(error){
            console.error(error);
            if (error && error.message === 'UNAUTHORIZED') {
                addMessage('bot', 'Phiên đăng nhập đã hết hạn. Bạn vui lòng đăng nhập lại để xóa hội thoại.');
                setTimeout(function(){
                    window.location.href = contextPath + '/login';
                }, 1200);
                return;
            }
            addMessage('bot', 'Chưa thể xóa hội thoại lúc này (' + (error && error.message ? error.message : 'Loi khong xac dinh') + ').');
        });
    }

    function deleteAllConversations() {
        const confirmed = window.confirm('Bạn có chắc muốn xóa toàn bộ lịch sử hội thoại không?');
        if (!confirmed) {
            return;
        }

        fetch(contextPath + '/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'delete_all_conversations' })
        })
        .then(async function(response){
            const data = await response.json();
            if (response.status === 401) {
                throw new Error('UNAUTHORIZED');
            }
            if (!response.ok || !data.success) {
                const detail = (data && (data.detail || data.error)) ? (data.detail || data.error) : 'DELETE_ALL_CONVERSATIONS_FAILED';
                throw new Error(detail);
            }

            currentConversationID = null;
            clearAllSuggestionCache();
            syncConversationInUrl();
            clearMessages();
            addMessage('bot', 'Mình đã xóa toàn bộ lịch sử hội thoại của bạn.');
            loadConversations(false);
        })
        .catch(function(error){
            console.error(error);
            if (error && error.message === 'UNAUTHORIZED') {
                addMessage('bot', 'Phiên đăng nhập đã hết hạn. Bạn vui lòng đăng nhập lại.');
                setTimeout(function(){
                    window.location.href = contextPath + '/login';
                }, 1200);
                return;
            }
            addMessage('bot', 'Chưa thể xóa toàn bộ hội thoại lúc này (' + (error && error.message ? error.message : 'Loi khong xac dinh') + ').');
        });
    }

    function sendMessage(text) {
        if (!text || !text.trim()) return;
        addMessage('user', text);
        input.value = '';

        fetch(contextPath + '/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: text, conversationID: currentConversationID })
        })
        .then(async response => {
            const data = await response.json();
            if (!response.ok || !data.success) {
                if (response.status === 401) {
                    addMessage('bot', 'Bạn cần đăng nhập để sử dụng tư vấn AI.');
                    setTimeout(() => {
                        window.location.href = contextPath + '/login';
                    }, 1200);
                    return null;
                }
                throw new Error(data.error || 'Lỗi hệ thống');
            }
            return data;
        })
        .then(data => {
            if (!data) return;
            const payload = data.data || {};
            currentConversationID = payload.conversationID || currentConversationID;
            syncConversationInUrl();
            addMessage('bot', payload.assistantMessage || 'Mình đang xử lý, bạn thử lại nhé.');
            const products = payload.productSuggestions || [];
            cacheProductSuggestions(currentConversationID, payload.assistantMessageID, products);
            addProductSuggestions(products);
            loadConversations(false);
        })
        .catch(error => {
            console.error(error);
            addMessage('bot', 'Hiện chưa thể trả lời, bạn thử lại sau ít phút.');
        });
    }

    sendBtn.addEventListener('click', function(){
        sendMessage(input.value);
    });

    input.addEventListener('keydown', function(event){
        if (event.key === 'Enter') {
            event.preventDefault();
            sendMessage(input.value);
        }
    });

    newConversationBtn.addEventListener('click', function(){
        createNewConversation();
    });

    deleteConversationBtn.addEventListener('click', function(){
        deleteCurrentConversation();
    });

    deleteAllConversationsBtn.addEventListener('click', function(){
        deleteAllConversations();
    });

    addMessage('bot', 'Chào bạn! Mình là trợ lý tư vấn AI của WearConnect. Bạn muốn tư vấn theo phong cách nào?');

    if (initialQuestion && initialQuestion.trim()) {
        sendMessage(initialQuestion);
    } else if (currentConversationID) {
        loadConversation(currentConversationID);
    }

    loadConversations(!currentConversationID);
})();
</script>
</body>
</html>
