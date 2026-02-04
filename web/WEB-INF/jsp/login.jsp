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
            background: var(--primary-gradient);
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
        
        <div class="button-group">
            <a href="<%= request.getContextPath() %>/home" class="btn-home">Quay Về Home</a>
        </div>
    </div>
</body>
</html>
