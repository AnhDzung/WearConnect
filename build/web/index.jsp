<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect đến dashboard nếu đã đăng nhập
    String userRole = (String) session.getAttribute("userRole");
    if (userRole != null) {
        if ("Admin".equals(userRole)) {
            response.sendRedirect("admin");
        } else if ("Manager".equals(userRole)) {
            response.sendRedirect("manager");
        } else if ("User".equals(userRole)) {
            response.sendRedirect("user");
        }
    } else {
        // Chưa đăng nhập - redirect tới trang home công khai
        response.sendRedirect("home");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WearConnect - Hệ Thống Quản Lý Cho Thuê Đồ</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        h1, h2, h3, h4, h5, h6 {
            font-family: 'Poppins', sans-serif;
        }
        
        .container {
            text-align: center;
            background: white;
            padding: 60px 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            max-width: 600px;
        }
        
        h1 {
            font-size: 48px;
            color: #333;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        p {
            font-size: 18px;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 15px 40px;
            font-size: 16px;
            font-weight: 600;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-login {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-login:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn-register {
            background-color: #28a745;
            color: white;
        }
        
        .btn-register:hover {
            background-color: #218838;
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(40, 167, 69, 0.3);
        }
        
        .features {
            margin-top: 50px;
            padding-top: 40px;
            border-top: 2px solid #e0e0e0;
        }
        
        .features h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
        }
        
        .feature-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            text-align: left;
        }
        
        .feature-item {
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .feature-item strong {
            color: #333;
            display: block;
            margin-bottom: 5px;
        }
        
        .feature-item p {
            font-size: 12px;
            color: #666;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>👗 WearConnect</h1>
        <p>Hệ thống quản lý cho thuê đồ hiện đại<br>
        Kết nối những người yêu thích thời trang</p>
        
        <div class="button-group">
            <a href="<%= request.getContextPath() %>/home" class="btn btn-login">Duyệt Sản Phẩm</a>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-login">Đăng Nhập</a>
            <a href="<%= request.getContextPath() %>/register" class="btn btn-register">Đăng Ký</a>
        </div>
        
        <div class="features">
            <h3>✨ Tính Năng Chính</h3>
            <div class="feature-list">
                <div class="feature-item">
                    <strong>🔐 Bảo Mật</strong>
                    <p>Xác thực tài khoản an toàn</p>
                </div>
                <div class="feature-item">
                    <strong>👥 3 Loại User</strong>
                    <p>Admin, Manager, User</p>
                </div>
                <div class="feature-item">
                    <strong>📊 Quản Lý</strong>
                    <p>Quản lý sản phẩm, đơn hàng</p>
                </div>
                <div class="feature-item">
                    <strong>💾 Database</strong>
                    <p>Kết nối SQL Server</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
