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
        <div class="wc-card wc-mb-0" style="max-width: 500px; width: 100%; margin: 0 auto; padding: 35px 25px; background: rgba(255,255,255,0.95); backdrop-filter: blur(10px);">
            <div class="wc-text-center wc-mb-3">
                <h1 style="color: var(--primary-color);">WearConnect</h1>
                <p class="wc-mt-1" style="color: var(--gray-600);">Tạo tài khoản mới</p>
            </div>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="wc-alert wc-alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="wc-alert" style="background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; padding: 10px; border-radius: 4px; margin-bottom: 15px;">
                    <%= request.getAttribute("success") %>
                </div>
            <% } %>
            
            <form method="POST" action="<%= request.getContextPath() %>/register">
                <div class="wc-form-group">
                    <label for="username" class="wc-form-label">Tên đăng nhập:</label>
                    <input type="text" id="username" name="username" class="wc-form-input" required>
                </div>
                
                <div class="wc-form-group">
                    <label for="email" class="wc-form-label">Email:</label>
                    <input type="email" id="email" name="email" class="wc-form-input" required>
                </div>
                
                <div class="wc-form-group">
                    <label for="fullName" class="wc-form-label">Tên đầy đủ:</label>
                    <input type="text" id="fullName" name="fullName" class="wc-form-input" required>
                </div>
                
                <div class="wc-form-group">
                    <label class="wc-form-label">Loại tài khoản:</label>
                    <div style="display: flex; flex-wrap: wrap; gap: 15px; margin-top: 5px;">
                        <label style="display: flex; align-items: center; gap: 5px; cursor: pointer;">
                            <input type="radio" name="userRole" value="User" checked style="accent-color: var(--primary-color);"> Người Thuê Đồ
                        </label>
                        <label style="display: flex; align-items: center; gap: 5px; cursor: pointer;">
                            <input type="radio" name="userRole" value="Manager" style="accent-color: var(--primary-color);"> Người Cho Thuê Đồ
                        </label>
                    </div>
                </div>
                
                <div class="wc-form-group">
                    <label for="password" class="wc-form-label">Mật khẩu:</label>
                    <input type="password" id="password" name="password" class="wc-form-input" required>
                </div>
                
                <div class="wc-form-group">
                    <label for="confirmPassword" class="wc-form-label">Xác nhận mật khẩu:</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="wc-form-input" required>
                </div>
                
                <button type="submit" class="wc-btn wc-btn-primary wc-btn-block wc-mb-2">Đăng Ký</button>
            </form>
            
            <div class="wc-text-center wc-mb-2" style="font-size: var(--font-size-sm);">
                Đã có tài khoản? <a href="<%= request.getContextPath() %>/login">Đăng nhập ngay</a>
            </div>
            
            <div class="wc-text-center">
                <a href="<%= request.getContextPath() %>/home" class="wc-btn wc-btn-secondary wc-btn-block">Quay Về Home</a>
            </div>
        </div>
    </div>
</body>
</html>
