<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tư vấn AI - WearConnect</title>
    <style>
        body { font-family: cursive; background: #f5f6fb; }
        .advisor-wrap { max-width: 900px; margin: 20px auto; padding: 0 16px; }
        .advisor-card { background: white; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.08); overflow: hidden; }
        .advisor-head { padding: 16px; border-bottom: 1px solid #eee; }
        .advisor-title { font-size: 20px; font-weight: 700; color: #2d2d2d; }
        .advisor-sub { font-size: 13px; color: #666; margin-top: 4px; }
        .advisor-messages { height: 520px; overflow-y: auto; padding: 16px; background: #fafbff; }
        .advisor-item { margin-bottom: 12px; display: flex; }
        .advisor-item.user { justify-content: flex-end; }
        .advisor-bubble { max-width: 75%; padding: 10px 12px; border-radius: 12px; line-height: 1.35; white-space: pre-wrap; }
        .advisor-item.user .advisor-bubble { background: #5c7cfa; color: white; border-bottom-right-radius: 4px; }
        .advisor-item.bot .advisor-bubble { background: #eceff8; color: #222; border-bottom-left-radius: 4px; }
        .advisor-actions { padding: 12px; border-top: 1px solid #eee; display: flex; gap: 8px; }
        .advisor-input { flex: 1; border: 1px solid #d8dbe8; border-radius: 8px; padding: 10px 12px; font-family: cursive; }
        .advisor-send { border: none; background: #5c7cfa; color: white; border-radius: 8px; padding: 10px 14px; cursor: pointer; }
        .advisor-send:hover { background: #4c6ef5; }
        .advisor-note { padding: 0 12px 12px 12px; font-size: 12px; color: #666; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="advisor-wrap">
    <div class="advisor-card">
        <div class="advisor-head">
            <div class="advisor-title">Trang tư vấn AI</div>
            <div class="advisor-sub">Phù hợp cho các câu hỏi cần tư vấn chi tiết về size, phong cách, phối đồ, chọn cosplay.</div>
        </div>
        <div id="advisorMessages" class="advisor-messages"></div>
        <div class="advisor-actions">
            <input id="advisorInput" class="advisor-input" type="text" placeholder="Nhập câu hỏi tư vấn của bạn..." />
            <button id="advisorSend" class="advisor-send" type="button">Gửi</button>
        </div>
        <div class="advisor-note">Nếu chưa đăng nhập, hệ thống sẽ yêu cầu đăng nhập để dùng chatbot.</div>
    </div>
</div>

<script>
(function(){
    const contextPath = '<%= request.getContextPath() %>';
    const input = document.getElementById('advisorInput');
    const sendBtn = document.getElementById('advisorSend');
    const messagesEl = document.getElementById('advisorMessages');

    const params = new URLSearchParams(window.location.search);
    let currentConversationID = params.get('conversationID') ? parseInt(params.get('conversationID'), 10) : null;
    const initialQuestion = params.get('q');

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
            addMessage('bot', payload.assistantMessage || 'Mình đang xử lý, bạn thử lại nhé.');
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

    addMessage('bot', 'Chào bạn! Mình là trợ lý tư vấn AI của WearConnect. Bạn muốn tư vấn theo phong cách nào?');

    if (initialQuestion && initialQuestion.trim()) {
        sendMessage(initialQuestion);
    }
})();
</script>
</body>
</html>
