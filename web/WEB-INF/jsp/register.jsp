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
<body class="register-bg wc-flex wc-items-center wc-justify-center" style="min-height: 100vh; padding: var(--spacing-xl) 0;">
    <div class="wc-container-sm">
        <div class="register-container wc-mb-0">
            <div class="wc-text-center wc-mb-3">
                <h1 style="background: var(--primary-gradient); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-weight: 800;">WearConnect</h1>
                <p class="wc-mt-1" style="color: var(--gray-600); font-weight: 600;">Tạo tài khoản mới</p>
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
                    <label for="username" class="wc-form-label">Tên đăng nhập:</label>
                    <input type="text" id="username" name="username" class="wc-form-input" required>
                </div>
                
                <div class="form-group">
                    <label for="email" class="wc-form-label">Email:</label>
                    <input type="email" id="email" name="email" class="wc-form-input" required>
                </div>
                
                <div class="form-group">
                    <label for="fullName" class="wc-form-label">Tên đầy đủ:</label>
                    <input type="text" id="fullName" name="fullName" class="wc-form-input" required>
                </div>
                
                <div class="form-group">
                    <label class="wc-form-label">Loại tài khoản:</label>
                    <div class="radio-group" style="margin-top: 5px;">
                        <label style="display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 14px;">
                            <input type="radio" name="userRole" value="User" checked style="accent-color: var(--primary-color);"> Người Thuê Đồ
                        </label>
                        <label style="display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 14px;">
                            <input type="radio" name="userRole" value="Manager" style="accent-color: var(--primary-color);"> Người Cho Thuê Đồ
                        </label>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="password" class="wc-form-label">Mật khẩu:</label>
                    <input type="password" id="password" name="password" class="wc-form-input" required>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword" class="wc-form-label">Xác nhận mật khẩu:</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="wc-form-input" required>
                </div>
                
                <div class="button-group">
                    <button type="submit" class="btn-register">Đăng Ký</button>
                </div>
            </form>
            
            <div class="login-link" style="color: var(--gray-600); font-weight: 600;">
                Đã có tài khoản? <a href="<%= request.getContextPath() %>/login" style="color: var(--primary-color); font-weight: 700; text-decoration: none;">Đăng nhập ngay</a>
            </div>
            
            <div class="wc-text-center">
                <a href="<%= request.getContextPath() %>/home" class="btn-home">Quay Về Home</a>
            </div>
        </div>
    </div>
</body>
</html>
