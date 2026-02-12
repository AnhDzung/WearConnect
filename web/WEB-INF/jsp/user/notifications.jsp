<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo của tôi</title>
    <style>
        body { font-family: cursive; background:#f5f5f5; padding:20px; }
        .box { max-width:800px; margin:0 auto; background:white; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.08); padding:16px; }
        .title-row { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:12px; }
        .title { font-size:20px; margin:0; }
        .btn-home { padding:8px 12px; background:#6c757d; color:white; border-radius:6px; text-decoration:none; }
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
        <div class="title-row">
            <div class="title">Thông Báo Mới Nhận</div>
            <c:choose>
                <c:when test="${sessionScope.userRole == 'Admin'}">
                    <a class="btn-home" href="${pageContext.request.contextPath}/admin">Quay lại trang chủ</a>
                </c:when>
                <c:when test="${sessionScope.userRole == 'Manager'}">
                    <a class="btn-home" href="${pageContext.request.contextPath}/manager">Quay lại trang chủ</a>
                </c:when>
                <c:otherwise>
                    <a class="btn-home" href="${pageContext.request.contextPath}/home">Quay lại trang chủ</a>
                </c:otherwise>
            </c:choose>
        </div>
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
                            <%-- Use pure scriptlet to compute order id and render link (avoids JSTL/scriptlet mixing issues) --%>
                                <%
                                    Integer oid = null;
                                    Integer nid = null;
                                    Integer pid = null;
                                    try {
                                        Object o = pageContext.findAttribute("n");
                                        if (o != null) {
                                            try {
                                                java.lang.reflect.Method m = o.getClass().getMethod("getOrderID");
                                                Object val = m.invoke(o);
                                                if (val != null) oid = (Integer) val;
                                            } catch (NoSuchMethodException ignore) {}
                                            try {
                                                java.lang.reflect.Method mm2 = o.getClass().getMethod("getNotificationID");
                                                Object v2 = mm2.invoke(o);
                                                if (v2 != null) nid = (Integer) v2;
                                            } catch (NoSuchMethodException ignore) {}

                                            if (oid == null) {
                                                try {
                                                    String msg = (String) o.getClass().getMethod("getMessage").invoke(o);
                                                    if (msg != null) {
                                                        java.util.regex.Matcher mm = java.util.regex.Pattern.compile("#(\\d+)").matcher(msg);
                                                        if (mm.find()) oid = Integer.parseInt(mm.group(1));
                                                    }
                                                } catch (NoSuchMethodException ignore) {}
                                            }

                                            if (pid == null) {
                                                try {
                                                    String msg = (String) o.getClass().getMethod("getMessage").invoke(o);
                                                    if (msg != null) {
                                                        java.util.regex.Matcher pm = java.util.regex.Pattern.compile("SP#(\\d+)").matcher(msg);
                                                        if (pm.find()) pid = Integer.parseInt(pm.group(1));
                                                    }
                                                } catch (NoSuchMethodException ignore) {}
                                            }
                                        }
                                    } catch (Exception ex) {
                                        oid = null;
                                        nid = null;
                                        pid = null;
                                    }
                                    if (oid != null) {
                                %>
                                    <a href="#" onclick="markAndOpen(<%= (nid!=null?nid:-1) %>, <%= oid %>); return false;" class="btn">Xem đơn</a>
                                <%
                                    }
                                    if (pid != null) {
                                %>
                                    <a href="${pageContext.request.contextPath}/clothing?action=view&id=<%= pid %>" class="btn">Xem san pham</a>
                                <%
                                    }
                                %>
                        </div>
                    </div>
                </c:forEach>
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
<script>
    function markAndOpen(notificationID, orderID) {
        try {
            // Send AJAX POST to mark notification as read
            var xhr = new XMLHttpRequest();
            xhr.open('GET', window.location.origin + '${pageContext.request.contextPath}/user?action=markNotificationRead&notificationID=' + encodeURIComponent(notificationID), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    // ignore response details; redirect anyway
                    window.location.href = '${pageContext.request.contextPath}/rental?action=viewOrder&id=' + orderID;
                }
            };
            xhr.send();
        } catch (e) {
            // fallback: directly open order
            window.location.href = '${pageContext.request.contextPath}/rental?action=viewOrder&id=' + orderID;
        }
    }
</script>
</html>