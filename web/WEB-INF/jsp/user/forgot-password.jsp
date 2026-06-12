<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Quên mật khẩu - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { background-color: #f5f5f5; }
        .form-container { max-width: 450px; margin: 40px auto; padding: 30px; background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background-color: #000; color: white; border: none; cursor: pointer; border-radius: 4px; font-weight: bold;}
        button:hover { background-color: #333; }
        .error-msg { background-color: #ffebee; color: #d32f2f; padding: 10px; border-radius: 4px; margin-bottom: 15px; }
        .back-link { display: block; text-align: center; margin-top: 15px; color: #666; text-decoration: none; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />

    <div class="form-container">
        <h2 style="text-align: center; margin-bottom: 20px;">Quên mật khẩu</h2>
        <p style="text-align: center; color: #666; margin-bottom: 20px;">
            Vui lòng nhập địa chỉ email đã đăng ký của bạn. Chúng tôi sẽ gửi một mã OTP gồm 6 chữ số để xác thực.
        </p>
        
        <c:if test="${not empty error}">
            <div class="error-msg">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="action" value="sendOTP">
            
            <div class="form-group">
                <label for="email">Địa chỉ Email <span style="color: red;">*</span></label>
                <input type="email" id="email" name="email" required placeholder="Nhập email của bạn...">
            </div>
            
            <button type="submit">Gửi mã OTP</button>
            
            <a href="${pageContext.request.contextPath}/login" class="back-link">Quay lại trang Đăng nhập</a>
        </form>
    </div>

    <jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>