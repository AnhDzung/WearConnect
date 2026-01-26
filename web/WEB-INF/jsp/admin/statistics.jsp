<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống kê - WearConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .header h1 {
            color: #333;
            font-size: 28px;
        }
        
        .nav-links {
            display: flex;
            gap: 15px;
        }
        
        .nav-links a {
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav-links a:hover {
            background: #0056b3;
        }
        
        .section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .section h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e0e0e0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 25px;
            border-radius: 10px;
            color: white;
            transition: transform 0.3s;
        }
        
        .card:hover {
            transform: translateY(-5px);
        }
        
        .card.orange {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .card.green {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        
        .card.blue {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        }
        
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }
        
        .card-rank {
            font-size: 24px;
            font-weight: bold;
            background: rgba(255,255,255,0.3);
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .card-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .card-subtitle {
            font-size: 13px;
            opacity: 0.9;
            margin-bottom: 15px;
        }
        
        .card-stats {
            display: flex;
            gap: 20px;
            margin-top: 15px;
        }
        
        .stat {
            flex: 1;
        }
        
        .stat-label {
            font-size: 11px;
            opacity: 0.8;
            margin-bottom: 5px;
        }
        
        .stat-value {
            font-size: 20px;
            font-weight: 700;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        
        thead {
            background: #f8f9fa;
        }
        
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }
        
        th {
            font-weight: 600;
            color: #555;
        }
        
        tbody tr {
            transition: background 0.2s;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        .rank-badge {
            display: inline-block;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            text-align: center;
            line-height: 30px;
            font-weight: bold;
            color: white;
            font-size: 14px;
        }
        
        .rank-1 { background: #ffd700; color: #333; }
        .rank-2 { background: #c0c0c0; color: #333; }
        .rank-3 { background: #cd7f32; color: white; }
        .rank-other { background: #6c757d; }
        
        .rating-stars {
            color: #ffc107;
            font-size: 16px;
        }
        
        .price {
            color: #d32f2f;
            font-weight: 600;
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .no-data svg {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header" style="display: flex; justify-content: space-between; align-items: center;">
            <h1>📊 Thống kê hệ thống</h1>
            <a href="${pageContext.request.contextPath}/admin" style="padding: 10px 20px; background: #6c757d; color: white; text-decoration: none; border-radius: 5px; transition: background 0.3s;">← Quay lại Dashboard</a>
        </div>
        
        <!-- Top Managers Section -->
        <div class="section">
            <h2>🏆 Top Manager được đánh giá cao nhất</h2>
            <c:choose>
                <c:when test="${not empty topManagers}">
                    <div class="cards-grid">
                        <c:forEach var="manager" items="${topManagers}" varStatus="status">
                            <c:if test="${status.index < 3}">
                                <div class="card ${status.index == 0 ? '' : (status.index == 1 ? 'orange' : 'green')}">
                                    <div class="card-header">
                                        <div>
                                            <div class="card-title">${manager.accountName}</div>
                                            <div class="card-subtitle">${manager.email}</div>
                                        </div>
                                        <div class="card-rank">#${status.index + 1}</div>
                                    </div>
                                    <div class="card-stats">
                                        <div class="stat">
                                            <div class="stat-label">Đánh giá trung bình</div>
                                            <div class="stat-value">
                                                <fmt:formatNumber value="${manager.avgRating}" maxFractionDigits="1"/> ⭐
                                            </div>
                                        </div>
                                        <div class="stat">
                                            <div class="stat-label">Số lượt đánh giá</div>
                                            <div class="stat-value">${manager.ratingCount}</div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                    
                    <c:if test="${topManagers.size() > 3}">
                        <div class="table-container" style="margin-top: 30px;">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Hạng</th>
                                        <th>Tên Manager</th>
                                        <th>Email</th>
                                        <th>Đánh giá TB</th>
                                        <th>Số lượt đánh giá</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="manager" items="${topManagers}" varStatus="status">
                                        <c:if test="${status.index >= 3}">
                                            <tr>
                                                <td>
                                                    <span class="rank-badge rank-other">#${status.index + 1}</span>
                                                </td>
                                                <td><strong>${manager.accountName}</strong></td>
                                                <td>${manager.email}</td>
                                                <td>
                                                    <span class="rating-stars">
                                                        <fmt:formatNumber value="${manager.avgRating}" maxFractionDigits="1"/> ⭐
                                                    </span>
                                                </td>
                                                <td>${manager.ratingCount} đánh giá</td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="no-data">
                        <svg fill="currentColor" viewBox="0 0 20 20">
                            <path d="M10 2a8 8 0 100 16 8 8 0 000-16zm1 11H9v-2h2v2zm0-4H9V5h2v4z"/>
                        </svg>
                        <h3>Chưa có dữ liệu</h3>
                        <p>Chưa có manager nào được đánh giá.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- Most Rented Products Section -->
        <div class="section">
            <h2>🔥 Sản phẩm được thuê nhiều nhất</h2>
            <c:choose>
                <c:when test="${not empty topProducts}">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Hạng</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Danh mục</th>
                                    <th>Manager</th>
                                    <th>Giá/giờ</th>
                                    <th>Số lượt thuê</th>
                                    <th>Tổng doanh thu</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="product" items="${topProducts}" varStatus="status">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${status.index == 0}">
                                                    <span class="rank-badge rank-1">#1</span>
                                                </c:when>
                                                <c:when test="${status.index == 1}">
                                                    <span class="rank-badge rank-2">#2</span>
                                                </c:when>
                                                <c:when test="${status.index == 2}">
                                                    <span class="rank-badge rank-3">#3</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="rank-badge rank-other">#${status.index + 1}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><strong>${product.clothingName}</strong></td>
                                        <td>${product.category}</td>
                                        <td>${product.managerName}</td>
                                        <td class="price">
                                            <fmt:formatNumber value="${product.hourlyPrice}" type="number" groupingUsed="true"/>đ
                                        </td>
                                        <td><strong style="color: #28a745;">${product.rentalCount}</strong> lượt</td>
                                        <td class="price">
                                            <fmt:formatNumber value="${product.totalRevenue}" type="number" groupingUsed="true"/>đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="no-data">
                        <svg fill="currentColor" viewBox="0 0 20 20">
                            <path d="M10 2a8 8 0 100 16 8 8 0 000-16zm1 11H9v-2h2v2zm0-4H9V5h2v4z"/>
                        </svg>
                        <h3>Chưa có dữ liệu</h3>
                        <p>Chưa có sản phẩm nào được thuê.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
