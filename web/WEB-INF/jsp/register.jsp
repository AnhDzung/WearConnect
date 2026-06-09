<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Đăng ký - WearConnect</title>
    <style>
        /* dynamic background kept inline via class on body */
        body.register-bg { background-image: linear-gradient(rgba(20,24,32,0.45), rgba(20,24,32,0.45)), url('${pageContext.request.contextPath}/assets/images/register-img.png'); background-size:cover; background-position:center; background-repeat:no-repeat; }
    </style>
</head>
<body class="register-bg">
    <div class="register-container">
            <p>Tạo tài khoản mới trên WearConnect</p>
        </div>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="success-message">
                <%= request.getAttribute("success") %>
            </div>
        <% } %>
        
        <form method="POST" action="<%= request.getContextPath() %>/register">
            <div class="form-group">
                <label for="username">Tên đăng nhập:</label>
                <input type="text" id="username" name="username" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="fullName">Tên đầy đủ:</label>
                <input type="text" id="fullName" name="fullName" required>
            </div>
            
            <div class="form-group">
                <label>Loại tài khoản:</label>
                <div class="radio-group">
                    <label><input type="radio" name="userRole" value="User" checked> Người Thuê Đồ</label>
                    <label><input type="radio" name="userRole" value="Manager"> Người Cho Thuê Đồ</label>
                </div>
            </div>
            
            <div class="form-group">
                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Xác nhận mật khẩu:</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required>
            </div>
            
            <div class="button-group">
                <button type="submit" class="btn-register">Đăng Ký</button>
            </div>
        </form>
        
        <div class="login-link">
            Đã có tài khoản? <a href="<%= request.getContextPath() %>/login">Đăng nhập ngay</a>
        </div>
        
        <a href="<%= request.getContextPath() %>/home" class="btn-home">Quay Về Home</a>
    </div>
</body>
</html>
