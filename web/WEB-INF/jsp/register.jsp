<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WearConnect - Đăng Ký</title>
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
        
        .register-container {
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-xl);
            width: 100%;
            max-width: 500px;
            padding: var(--spacing-4xl);
        }
        
        .register-header {
            text-align: center;
            margin-bottom: var(--spacing-3xl);
        }
        
        .register-header h1 {
            font-size: var(--font-size-3xl);
            color: var(--gray-900);
            margin-bottom: var(--spacing-md);
        }
        
        .register-header p {
            color: var(--gray-600);
            font-size: var(--font-size-base);
        }
        
        @media (max-width: 480px) {
            .register-container {
                padding: var(--spacing-2xl);
            }
            .register-header h1 {
                font-size: 24px;
            }
        }
        
        .error-message {
            background-color: #fee;
            color: #c33;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid #c33;
        }
        
        .success-message {
            background-color: #efe;
            color: #3c3;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid #3c3;
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn-register {
            flex: 1;
            padding: 12px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-register:hover {
            background-color: #218838;
        }
        
        .btn-back {
            flex: 1;
            padding: 12px;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-back:hover {
            background-color: #5a6268;
        }
        
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 14px;
        }
        
        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
        
        .login-link a:hover {
            text-decoration: underline;
        }
        
        .btn-home {
            display: inline-block;
            width: 100%;
            padding: 12px;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            margin-top: 10px;
        }
        
        .btn-home:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-header">
            <h1>Đăng Ký</h1>
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
                <label for="userRole">Loại tài khoản:</label>
                <select id="userRole" name="userRole" required>
                    <option value="">-- Chọn loại tài khoản --</option>
                    <option value="User">Người Thuê Đồ</option>
                    <option value="Manager">Người Cho Thuê Đồ</option>
                </select>
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
                <a href="<%= request.getContextPath() %>/login" class="btn-back" style="text-decoration: none; display: flex; align-items: center; justify-content: center;">Quay Lại Đăng Nhập</a>
            </div>
        </form>
        
        <div class="login-link">
            Đã có tài khoản? <a href="<%= request.getContextPath() %>/login">Đăng nhập ngay</a>
        </div>
        
        <a href="<%= request.getContextPath() %>/home" class="btn-home">Quay Về Home</a>
    </div>
</body>
</html>
