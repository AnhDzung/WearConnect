<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống Kê Doanh Thu - WearConnect</title>
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-box {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-left: 4px solid #667eea;
        }
        
        .stat-box h3 {
            margin: 0 0 10px 0;
            color: #666;
            font-size: 14px;
            text-transform: uppercase;
            font-weight: 600;
        }
        
        .stat-box .value {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-box.green { border-left-color: #28a745; }
        .stat-box.green .value { color: #28a745; }
        
        .stat-box.orange { border-left-color: #ff9800; }
        .stat-box.orange .value { color: #ff9800; }
        
        .stat-box.red { border-left-color: #dc3545; }
        .stat-box.red .value { color: #dc3545; }
        
        .chart-container {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .chart-container h2 {
            margin: 0 0 20px 0;
            color: #333;
            font-size: 20px;
        }
        
        .message {
            background: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            border-radius: 4px;
            color: #1976D2;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/components/header.jsp" />
    
    <div class="container">
        <div class="page-header">
            <h1>💰 Thống Kê Doanh Thu</h1>
            <p>Xem chi tiết doanh thu từ hoạt động cho thuê sản phẩm</p>
        </div>
        
        <div class="message">
            📊 Tính năng thống kê doanh thu đang được phát triển. Những dữ liệu dưới đây là mẫu để minh họa.
        </div>
        
        <div class="stats-grid">
            <div class="stat-box green">
                <h3>💵 Tổng Doanh Thu</h3>
                <div class="value">12.500.000 ₫</div>
            </div>
            
            <div class="stat-box">
                <h3>📅 Doanh Thu Tháng Này</h3>
                <div class="value">2.150.000 ₫</div>
            </div>
            
            <div class="stat-box orange">
                <h3>📊 Đơn Hàng Hoàn Thành</h3>
                <div class="value">48</div>
            </div>
            
            <div class="stat-box red">
                <h3>⏳ Đơn Hàng Đang Xử Lý</h3>
                <div class="value">5</div>
            </div>
        </div>
        
        <div class="chart-container">
            <h2>📈 Biểu Đồ Doanh Thu Theo Tháng</h2>
            <p style="color: #999; text-align: center; padding: 40px;">
                Biểu đồ sẽ được cập nhật khi tính năng phân tích dữ liệu hoàn tất.
            </p>
        </div>
        
        <div class="chart-container">
            <h2>🏆 Sản Phẩm Bán Chạy Nhất</h2>
            <table style="width: 100%;">
                <thead>
                    <tr style="border-bottom: 2px solid #ddd;">
                        <th style="text-align: left; padding: 10px 0;">Sản Phẩm</th>
                        <th style="text-align: center; padding: 10px 0;">Lần Thuê</th>
                        <th style="text-align: right; padding: 10px 0;">Doanh Thu</th>
                    </tr>
                </thead>
                <tbody>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px 0;">Áo sơ mi cao cấp</td>
                        <td style="text-align: center;">15</td>
                        <td style="text-align: right;">1.500.000 ₫</td>
                    </tr>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px 0;">Váy dạo phố</td>
                        <td style="text-align: center;">12</td>
                        <td style="text-align: right;">1.200.000 ₫</td>
                    </tr>
                    <tr>
                        <td style="padding: 12px 0;">Quần jean</td>
                        <td style="text-align: center;">10</td>
                        <td style="text-align: right;">750.000 ₫</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
