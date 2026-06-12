<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Xác nhận OTP - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { background-color: #f5f5f5; }
        .form-container { max-width: 450px; margin: 40px auto; padding: 30px; background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; text-align: center; font-size: 20px; letter-spacing: 5px; }
        button { width: 100%; padding: 12px; background-color: #000; color: white; border: none; cursor: pointer; border-radius: 4px; font-weight: bold;}
        button:hover { background-color: #333; }
        .error-msg { background-color: #ffebee; color: #d32f2f; padding: 10px; border-radius: 4px; margin-bottom: 15px; }
        .resend { display: block; text-align: center; margin-top: 15px; color: #666; font-size: 14px; }
        .resend a { color: #000; text-decoration: underline; font-weight: bold;}
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />

    <div class="form-container">
        <h2 style="text-align: center; margin-bottom: 20px;">Nhập mã xác thực</h2>
        <p style="text-align: center; color: #666; margin-bottom: 20px;">
            Mã OTP gồm 6 số đã được gửi đến email <strong>${sessionScope.resetEmail}</strong>. 
        </p>
        
        <c:if test="${not empty error}">
            <div class="error-msg">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="action" value="verifyOTP">
            
            <div class="form-group">
                <input type="text" id="otp" name="otp" required maxlength="6" pattern="\d{6}" autocomplete="off" placeholder="------">
            </div>
            
            <button type="submit">Xác nhận mã</button>
            
            <div class="resend">
                Chưa nhận được mã? <a href="${pageContext.request.contextPath}/forgot-password">Thử gửi lại</a>
            </div>
        </form>
    </div>

    <jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>