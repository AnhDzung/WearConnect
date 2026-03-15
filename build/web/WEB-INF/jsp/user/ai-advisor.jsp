<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tư vấn AI - WearConnect</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

        body { font-family: 'Inter', sans-serif; background: #f5f6fb; }
        h1, h2, h3, h4, h5, h6, .advisor-title, .advisor-side-title { font-family: 'Poppins', sans-serif; }
        .advisor-wrap { max-width: 1180px; margin: 20px auto; padding: 0 16px; }
        .advisor-layout { display: grid; grid-template-columns: 280px 1fr; gap: 16px; }
        .advisor-sidebar,
        .advisor-card { background: white; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.08); overflow: hidden; }
        .advisor-side-head { padding: 14px; border-bottom: 1px solid #eee; display: flex; flex-direction: column; gap: 10px; }
        .advisor-side-title { font-size: 15px; font-weight: 700; color: #2d2d2d; }
        .advisor-side-actions { display: flex; gap: 8px; }
        .advisor-new-btn { border: none; border-radius: 8px; background: #5c7cfa; color: #fff; padding: 9px 12px; cursor: pointer; font-size: 13px; }
        .advisor-new-btn:hover { background: #4c6ef5; }
        .advisor-clear-btn { border: 1px solid #d9534f; border-radius: 8px; background: #fff; color: #d9534f; padding: 9px 12px; cursor: pointer; font-size: 13px; }
        .advisor-clear-btn:hover { background: #fff5f5; }
        .advisor-history-list { max-height: 600px; overflow-y: auto; padding: 8px; }
        .advisor-history-item { border: 1px solid #e6e9f5; border-radius: 10px; padding: 10px; margin-bottom: 8px; cursor: pointer; background: #fff; }
        .advisor-history-item.active { border-color: #5c7cfa; background: #eef1ff; }
        .advisor-history-id { font-size: 12px; font-weight: 700; color: #445; }
        .advisor-history-meta { font-size: 11px; color: #6b7280; margin-top: 4px; }
        .advisor-empty { padding: 12px; font-size: 12px; color: #666; }
        .advisor-head { padding: 16px; border-bottom: 1px solid #eee; }
        .advisor-title { font-size: 20px; font-weight: 700; color: #2d2d2d; }
        .advisor-sub { font-size: 13px; color: #666; margin-top: 4px; }
        .advisor-messages { height: 520px; overflow-y: auto; padding: 16px; background: #fafbff; }
        .advisor-item { margin-bottom: 12px; display: flex; }
        .advisor-item.user { justify-content: flex-end; }
        .advisor-bubble { max-width: 75%; padding: 10px 12px; border-radius: 12px; line-height: 1.35; white-space: pre-wrap; }
        .advisor-item.user .advisor-bubble { background: #5c7cfa; color: white; border-bottom-right-radius: 4px; }
        .advisor-item.bot .advisor-bubble { background: #eceff8; color: #222; border-bottom-left-radius: 4px; }
        .advisor-product-wrap { margin: 6px 0 14px 0; }
        .advisor-products-title { font-size: 12px; color: #4b5563; margin: 0 0 8px 2px; font-weight: 700; }
        .advisor-products { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; }
        .advisor-product-card { border: 1px solid #dbe1f5; border-radius: 10px; overflow: hidden; background: #fff; text-decoration: none; color: #1f2937; }
        .advisor-product-thumb { width: 100%; height: 110px; object-fit: cover; display: block; background: #edf2ff; }
        .advisor-product-body { padding: 8px; }
        .advisor-product-name { font-size: 12px; font-weight: 700; line-height: 1.35; min-height: 32px; }
        .advisor-product-meta { font-size: 11px; color: #6b7280; margin-top: 5px; }
        .advisor-product-price { margin-top: 6px; color: #1d4ed8; font-size: 12px; font-weight: 700; }
        .advisor-product-cta { margin-top: 8px; display: inline-block; font-size: 11px; font-weight: 700; color: #374151; background: #eef2ff; border: 1px solid #c7d2fe; border-radius: 6px; padding: 4px 8px; }
        .advisor-actions { padding: 12px; border-top: 1px solid #eee; display: flex; gap: 8px; }
        .advisor-input { flex: 1; border: 1px solid #d8dbe8; border-radius: 8px; padding: 10px 12px; font-family: 'Inter', sans-serif; }
        .advisor-send { border: none; background: #5c7cfa; color: white; border-radius: 8px; padding: 10px 14px; cursor: pointer; }
        .advisor-send:hover { background: #4c6ef5; }
        .advisor-note { padding: 0 12px 12px 12px; font-size: 12px; color: #666; }

        @media (max-width: 960px) {
            .advisor-layout { grid-template-columns: 1fr; }
            .advisor-history-list { max-height: 220px; }
            .advisor-products { grid-template-columns: 1fr; }
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

    const params = new URLSearchParams(window.location.search);
    let currentConversationID = params.get('conversationID') ? parseInt(params.get('conversationID'), 10) : null;
    const initialQuestion = params.get('q');

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
                        addMessage((message.role || '').toUpperCase() === 'USER' ? 'user' : 'bot', message.content || '');
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
            if (!response.ok || !data.success) {
                throw new Error((data && data.error) ? data.error : 'DELETE_CONVERSATION_FAILED');
            }

            currentConversationID = null;
            syncConversationInUrl();
            clearMessages();
            addMessage('bot', 'Mình đã xóa hội thoại #' + targetConversationID + '. Bạn có thể chọn hội thoại khác hoặc tạo tư vấn mới.');
            loadConversations(true);
        })
        .catch(function(error){
            console.error(error);
            addMessage('bot', 'Chưa thể xóa hội thoại lúc này, bạn thử lại sau nhé.');
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
            addProductSuggestions(payload.productSuggestions || []);
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
