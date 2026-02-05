<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo của tôi</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background:#f5f5f5; padding:20px; }
        .box { max-width:800px; margin:0 auto; background:white; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.08); padding:16px; }
        .title { font-size:20px; margin-bottom:12px; }
        .note { display:flex; gap:12px; padding:12px; border-bottom:1px solid #eee; align-items:flex-start; }
        .note:last-child{ border-bottom:none; }
        .note .avatar { width:48px; height:48px; border-radius:8px; background:#f0f0f0; display:flex; align-items:center; justify-content:center; color:#666; font-weight:700; }
        .note .content { flex:1; }
        .note .content .head { display:flex; justify-content:space-between; gap:12px; }
        .note .content .head .t { font-weight:700; }
        .note .content .msg { margin-top:6px; color:#444; white-space:pre-wrap; }
        .empty { text-align:center; padding:40px; color:#666; }
        .note.read { opacity:0.65; background:#fafafa; }
        .actions { margin-top:12px; text-align:right; }
        .btn { padding:8px 12px; background:#007bff; color:white; border-radius:6px; text-decoration:none; }
    </style>
</head>
<body>
    <div class="box">
        <div class="title">Thông Báo Mới Nhận</div>
        <c:choose>
            <c:when test="${not empty notifications}">
                <c:forEach var="n" items="${notifications}">
                    <div class="note ${n.read ? 'read' : ''}">
                        <div class="avatar">TB</div>
                        <div class="content">
                            <div class="head">
                                <div class="t">${n.title}</div>
                                <div class="time">${n.formattedCreatedAt}</div>
                            </div>
                            <div class="msg">${n.message}</div>
                        </div>
                        <div style="margin-left:12px; display:flex; align-items:center;">
                            <c:if test="${not empty n.orderID}">
                                <a href="${pageContext.request.contextPath}/rental?action=viewOrder&id=${n.orderID}" class="btn">Xem đơn</a>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
                <div class="actions">
                    <a href="${pageContext.request.contextPath}/rental?action=myOrders" class="btn">Xem tất cả đơn</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty">
                    <h3>Không có thông báo mới</h3>
                    <p>Bạn chưa có thông báo nào.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>