<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Đặt Thuê - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        
        .page-header {
            background: white;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .page-header h1 {
            margin: 0 0 10px 0;
            color: #333;
            font-size: 28px;
        }
        
        .page-header p {
            margin: 0;
            color: #666;
            font-size: 14px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        th {
            background-color: #667eea;
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        tbody tr:hover {
            background-color: #f9f9f9;
        }
        
        .status {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-pending { background-color: #ffc107; color: #333; }
        .status-confirmed { background-color: #17a2b8; color: white; }
        .status-rented { background-color: #28a745; color: white; }
        .status-returned { background-color: #6c757d; color: white; }
        
        .btn { 
            padding: 8px 15px; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 13px;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary { background-color: #007bff; color: white; }
        .btn-primary:hover { background-color: #0056b3; }
        
        .empty-message {
            background: white;
            padding: 40px;
            text-align: center;
            color: #666;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />
    
    <div class="container">
        <div class="page-header">
            <h1> Đơn Đặt Thuê</h1>
            <p>Quản lý các đơn đặt thuê sản phẩm của bạn</p>
        </div>
        
        <table>
            <thead>
                <tr>
                    <th>Mã Đơn</th>
                    <th>Sản Phẩm</th>
                    <th>Khách Thuê</th>
                    <th>Ngày Bắt Đầu</th>
                    <th>Ngày Kết Thúc</th>
                    <th>Giá Tiền</th>
                    <th>Trạng Thái</th>
                    <th>Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>#001</td>
                    <td>Áo sơ mi xanh</td>
                    <td>Nguyễn Văn A</td>
                    <td>2026-01-20</td>
                    <td>2026-01-22</td>
                    <td>150.000 VNĐ</td>
                    <td><span class="status status-confirmed">✓ Đã Xác Nhận</span></td>
                    <td><button class="btn btn-primary">Xem</button></td>
                </tr>
                <tr>
                    <td>#002</td>
                    <td>Váy dạo phố</td>
                    <td>Trần Thị B</td>
                    <td>2026-01-21</td>
                    <td>2026-01-23</td>
                    <td>200.000 VNĐ</td>
                    <td><span class="status status-pending">⏳ Chờ Duyệt</span></td>
                    <td><button class="btn btn-primary">Xem</button></td>
                </tr>
                <tr>
                    <td>#003</td>
                    <td>Quần jean</td>
                    <td>Lê Văn C</td>
                    <td>2026-01-15</td>
                    <td>2026-01-18</td>
                    <td>100.000 VNĐ</td>
                    <td><span class="status status-returned">✓ Đã Trả</span></td>
                    <td><button class="btn btn-primary">Xem</button></td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
