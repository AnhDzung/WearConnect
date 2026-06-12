<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Đặt lại mật khẩu - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { background-color: #f5f5f5; }
        .form-container { max-width: 450px; margin: 40px auto; padding: 30px; background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background-color: #28a745; color: white; border: none; cursor: pointer; border-radius: 4px; font-weight: bold;}
        button:hover { background-color: #218838; }
        .error-msg { background-color: #ffebee; color: #d32f2f; padding: 10px; border-radius: 4px; margin-bottom: 15px; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />

    <div class="form-container">
        <h2 style="text-align: center; margin-bottom: 20px;">Tạo mật khẩu mới</h2>
        
        <c:if test="${not empty error}">
            <div class="error-msg">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="action" value="resetPassword">
            
            <div class="form-group">
                <label for="newPassword">Mật khẩu mới <span style="color: red;">*</span></label>
                <input type="password" id="newPassword" name="newPassword" required minlength="6">
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Xác nhận mật khẩu mới <span style="color: red;">*</span></label>
                <input type="password" id="confirmPassword" name="confirmPassword" required minlength="6">
            </div>
            
            <button type="submit">Cập nhật mật khẩu</button>
            
            <div style="text-align: center; margin-top: 15px; font-size: 14px; color: #666;">Tài khoản: ${sessionScope.resetEmail}</div>
        </form>
    </div>

    <jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>