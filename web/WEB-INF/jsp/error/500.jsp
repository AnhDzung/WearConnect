<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Lỗi Server - WearConnect</title>
    <style>
        body { 
            font-family: cursive;
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
            color: #dc3545;
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
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            text-align: left;
            word-break: break-all;
            max-height: 150px;
            overflow-y: auto;
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
    <h1>500</h1>
    <h2>Lỗi Máy Chủ Nội Bộ</h2>
    <p>Xin lỗi, đã xảy ra lỗi trong quá trình xử lý yêu cầu của bạn.</p>
    
    <%
        Throwable exception = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
        String message = "";
        if (exception != null) {
            message = exception.getMessage();
            if (message == null) {
                message = exception.toString();
            }
        }
    %>
    
    <% if (!message.isEmpty()) { %>
    <div class="error-message">
        <strong>Chi tiết:</strong> <%= message %>
    </div>
    <% } %>
    
    <p style="color: #999; font-size: 14px;">Código lỗi: <%= response.getStatus() %></p>
    
    <div style="margin-top: 30px;">
        <a href="${pageContext.request.contextPath}/" class="btn btn-home">Trang Chủ</a>
        <a href="javascript:history.back();" class="btn">Quay Lại</a>
    </div>
</div>
</body>
</html>
