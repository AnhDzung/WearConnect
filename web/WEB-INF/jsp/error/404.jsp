<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Không Tìm Thấy - WearConnect</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; 
            padding: 20px;
            background-color: #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .container {
            text-align: center;
            background: white;
            padding: 60px 40px;
            border-radius: 8px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            max-width: 600px;
        }
        h1 { 
            font-size: 72px; 
            margin: 0; 
            color: #667eea;
            font-weight: bold;
        }
        h2 { 
            font-size: 28px; 
            margin: 20px 0 10px 0;
            color: #333;
        }
        p { 
            color: #666; 
            font-size: 16px;
            line-height: 1.6;
        }
        .error-message {
            background: #f9f3cd;
            border: 1px solid #fddab3;
            color: #856404;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            text-align: left;
            word-break: break-all;
        }
        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 30px;
            background-color: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        .btn:hover {
            background-color: #764ba2;
        }
        .btn-home {
            margin-right: 10px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>404</h1>
    <h2>Không Tìm Thấy Trang</h2>
    <p>Xin lỗi, trang bạn tìm kiếm không tồn tại hoặc đã bị xóa.</p>
    
    <%
        String requestUri = request.getAttribute("jakarta.servlet.error.request_uri") != null 
            ? request.getAttribute("jakarta.servlet.error.request_uri").toString()
            : "không xác định";
    %>
    
    <div class="error-message">
        <strong>URI yêu cầu:</strong> <%= requestUri %>
    </div>
    
    <p style="color: #999; font-size: 14px;">Código lỗi: <%= response.getStatus() %></p>
    
    <div style="margin-top: 30px;">
        <a href="${pageContext.request.contextPath}/" class="btn btn-home">Trang Chủ</a>
        <a href="javascript:history.back();" class="btn">Quay Lại</a>
    </div>
</div>
</body>
</html>
