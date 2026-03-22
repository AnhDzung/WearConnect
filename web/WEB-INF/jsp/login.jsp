<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WearConnect - Đăng Nhập</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
    <style>
        body {
            background-image:
                linear-gradient(rgba(20, 24, 32, 0.45), rgba(20, 24, 32, 0.45)),
                url('${pageContext.request.contextPath}/assets/images/login-img.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: var(--spacing-lg);
        }
        
        .login-container {
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-xl);
            width: 100%;
            max-width: 450px;
            padding: var(--spacing-4xl);
        }
        
        .login-header {
            text-align: center;
            margin-bottom: var(--spacing-3xl);
        }
        
        .login-header h1 {
            font-size: var(--font-size-3xl);
            color: var(--gray-900);
            margin-bottom: var(--spacing-md);
        }
        
        .login-header p {
            color: var(--gray-600);
            font-size: var(--font-size-base);
        }
        
        @media (max-width: 480px) {
            .login-container {
                padding: var(--spacing-2xl);
            }
            .login-header h1 {
                font-size: 24px;
            }
        }
        
        .error-message {
            background-color: #fee2e2;
            color: #991b1b;
            padding: var(--spacing-md);
            border-radius: var(--radius-md);
            margin-bottom: var(--spacing-xl);
            font-size: var(--font-size-base);
            border-left: 4px solid var(--danger-color);
        }
        
        .btn-login {
            width: 100%;
            padding: var(--spacing-md);
            background: var(--primary-gradient);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-size: var(--font-size-lg);
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition-base);
            min-height: 44px;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        
        .register-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 14px;
        }
        
        .register-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
        
        .register-link a:hover {
            text-decoration: underline;
        }
        
        .button-group {
            display: flex; 
            gap: 10px; 
            margin-top: 20px;
        }
        
        .btn-home {
            flex: 1;
            padding: 12px;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
        }
        
        .btn-home:hover {
            background-color: #5a6268;
        }
        
        .divider {
            display: flex;
            align-items: center;
            margin: 20px 0;
            color: #999;
        }
        
        .divider::before,
        .divider::after {
            content: "";
            flex: 1;
            border-bottom: 1px solid #ddd;
        }
        
        .divider::before {
            margin-right: 10px;
        }
        
        .divider::after {
            margin-left: 10px;
        }
        
        .btn-google {
            width: 100%;
            padding: 12px;
            background: white;
            color: #333;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            min-height: 44px;
        }
        
        .btn-google:hover {
            background: #f8f9fa;
            border-color: #999;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .btn-google img {
            width: 20px;
            height: 20px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>WearConnect</h1>
            <p>Hệ thống quản lý cho thuê đồ</p>
        </div>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <form method="POST" action="<%= request.getContextPath() %>/login">
            <div class="wc-form-group">
                <label for="username" class="wc-form-label">Tên đăng nhập:</label>
                <input type="text" id="username" name="username" class="wc-form-input" required>
            </div>
            
            <div class="wc-form-group">
                <label for="password" class="wc-form-label">Mật khẩu:</label>
                <input type="password" id="password" name="password" class="wc-form-input" required>
            </div>
            
            <button type="submit" class="btn-login">Đăng Nhập</button>
        </form>
        
        <div class="register-link">
            Chưa có tài khoản? <a href="<%= request.getContextPath() %>/register">Đăng ký ngay</a>
        </div>
        
        <div class="divider">hoặc</div>
        
        <a href="<%= request.getContextPath() %>/oauth2/authorize/google" class="btn-google">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Đăng nhập với Google
        </a>
        
        <div class="button-group">
            <a href="<%= request.getContextPath() %>/home" class="btn-home">Quay Về Home</a>
        </div>
    </div>
</body>
</html>
