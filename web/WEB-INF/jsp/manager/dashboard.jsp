<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - WearConnect Manager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        body {
            background-color: var(--gray-100);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .dashboard-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .dashboard-header h1 {
            font-size: 32px;
            margin-bottom: 8px;
        }
        
        .dashboard-header p {
            font-size: 16px;
            opacity: 0.9;
        }

        .alert-banner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            background: #fff7ed;
            border: 1px solid #fed7aa;
            border-left: 5px solid #f97316;
            color: #7c2d12;
            padding: 14px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .alert-banner .text {
            font-weight: 600;
            line-height: 1.4;
        }

        .alert-banner .action-btn {
            background: #f97316;
            color: #fff;
            border: none;
            border-radius: 6px;
            padding: 10px 14px;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.1s ease, box-shadow 0.2s ease;
        }

        .alert-banner .action-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(0,0,0,0.12);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--spacing-xl);
            margin-bottom: var(--spacing-3xl);
        }
        
        .stat-card {
            background: var(--white);
            padding: var(--spacing-2xl);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border-left: 4px solid var(--primary-color);
        }
        
        @media (max-width: 639px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .stat-card.revenue {
            border-left-color: #48bb78;
        }
        
        .stat-card.pending {
            border-left-color: #ed8936;
        }
        
        .stat-card.completed {
            border-left-color: #4299e1;
        }
        
        .stat-label {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 8px;
            font-weight: 600;
        }
        
        .stat-value {
            font-size: 36px;
            font-weight: 700;
            color: #333;
        }
        
        .stat-unit {
            font-size: 14px;
            color: #999;
            margin-top: 4px;
        }
        
        .charts-section {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .section-title {
            font-size: 22px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #667eea;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            margin-bottom: 30px;
        }
        
        .top-products-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        .top-products-box {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .top-products-box h3 {
            font-size: 18px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        .product-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background-color 0.3s;
        }
        
        .product-item:last-child {
            border-bottom: none;
        }
        
        .product-item:hover {
            background-color: #f9f9f9;
        }
        
        .product-name {
            font-weight: 600;
            color: #333;
            flex: 1;
        }
        
        .product-stat {
            text-align: right;
            min-width: 100px;
        }
        
        .rating-badge {
            background-color: #ffd700;
            color: #333;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 13px;
        }
        
        .revenue-badge {
            background-color: #48bb78;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 13px;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .top-products-section {
                grid-template-columns: 1fr;
            }
            
            .dashboard-header h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="dashboard-header">
        <h1>Dashboard Quản Lý</h1>
        <p>Xem tổng quan doanh số, thống kê sản phẩm và hiệu suất kinh doanh của bạn</p>
    </div>

    <c:if test="${confirmedOrders > 0}">
        <div class="alert-banner">
            <div class="text">Có ${confirmedOrders} đơn hàng mới được admin xác thực. Vui lòng kiểm tra và bàn giao.</div>
            <form action="${pageContext.request.contextPath}/manager" method="get" style="margin:0;">
                <input type="hidden" name="action" value="orders" />
                <button type="submit" class="action-btn">Xem đơn</button>
            </form>
        </div>
    </c:if>
    
    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card revenue">
            <div class="stat-label"> Tổng Doanh Thu</div>
            <div class="stat-value"><fmt:formatNumber value="${totalRevenue}" pattern="0.00" /></div>
            <div class="stat-unit">VNĐ</div>
        </div>
        
        <div class="stat-card completed">
            <div class="stat-label">Đơn Hàng Hoàn Thành</div>
            <div class="stat-value">${completedOrders}</div>
            <div class="stat-unit">đơn hàng</div>
        </div>
        
        <div class="stat-card pending">
            <div class="stat-label">Đơn Hàng Chờ Xử Lý</div>
            <div class="stat-value">${pendingOrders}</div>
            <div class="stat-unit">đơn hàng</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-label">Sản Phẩm Hoạt Động</div>
            <div class="stat-value">${activeProducts}</div>
            <div class="stat-unit">sản phẩm</div>
        </div>
    </div>
    
    <!-- Charts Section -->
    <div class="charts-section">
        <h2 class="section-title"> Biểu Đồ Doanh Thu (Toàn Thời Gian)</h2>
        <div class="chart-container">
            <canvas id="revenueChart"></canvas>
        </div>
    </div>
    
    <!-- Top Products Section -->
    <div class="top-products-section">
        <!-- Top Rated Products -->
        <div class="top-products-box">
            <h3>Sản Phẩm Đánh Giá Cao Nhất</h3>
            <c:choose>
                <c:when test="${empty topRatedProducts}">
                    <div class="empty-state">
                        <p>Chưa có đánh giá nào</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="product" items="${topRatedProducts}">
                        <div class="product-item">
                            <span class="product-name">${product.clothingName}</span>
                            <div class="product-stat">
                                <span class="rating-badge">
                                    <fmt:formatNumber value="${product.avgRating}" pattern="0.0" /> 
                                    (${product.ratingCount})
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- Top Revenue Products -->
        <div class="top-products-box">
            <h3> Sản Phẩm Doanh Thu Cao Nhất</h3>
            <c:choose>
                <c:when test="${empty topRevenueProducts}">
                    <div class="empty-state">
                        <p>Chưa có đơn hàng nào</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="product" items="${topRevenueProducts}">
                        <div class="product-item">
                            <span class="product-name">${product.clothingName}</span>
                            <div class="product-stat">
                                <span class="revenue-badge">
                                    <fmt:formatNumber value="${product.totalRevenue}" pattern="0.00" /> VNĐ
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
    // Prepare revenue data for chart
    const revenueData = [
        <c:forEach var="item" items="${revenueByDate}" varStatus="status">
        {
            date: '${item.date}',
            revenue: Number('${item.revenue}')
        }<c:if test="${not status.last}">,</c:if>
        </c:forEach>
    ].filter(item => item.date && !Number.isNaN(item.revenue));

    function renderEmptyRevenueState() {
        const canvas = document.getElementById('revenueChart');
        if (!canvas || !canvas.parentElement) return;
        canvas.parentElement.innerHTML = '<div class="empty-state"><p>Chua co du lieu doanh thu</p></div>';
    }

    function renderRevenueFallback(canvas, labels, values) {
        const ctx = canvas.getContext('2d');
        const w = canvas.clientWidth || 800;
        const h = canvas.clientHeight || 300;
        canvas.width = w;
        canvas.height = h;

        const pad = { top: 20, right: 20, bottom: 36, left: 56 };
        const chartW = w - pad.left - pad.right;
        const chartH = h - pad.top - pad.bottom;
        const maxVal = Math.max(...values, 1);

        ctx.clearRect(0, 0, w, h);
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, w, h);

        ctx.strokeStyle = '#d1d5db';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(pad.left, pad.top);
        ctx.lineTo(pad.left, h - pad.bottom);
        ctx.lineTo(w - pad.right, h - pad.bottom);
        ctx.stroke();

        ctx.fillStyle = '#6b7280';
        ctx.font = '12px sans-serif';
        for (let i = 0; i <= 4; i++) {
            const y = pad.top + (chartH * i / 4);
            const val = Math.round(maxVal * (1 - i / 4));
            ctx.fillText(val.toLocaleString('vi-VN'), 6, y + 4);
            ctx.strokeStyle = 'rgba(209,213,219,0.35)';
            ctx.beginPath();
            ctx.moveTo(pad.left, y);
            ctx.lineTo(w - pad.right, y);
            ctx.stroke();
        }

        const stepX = labels.length > 1 ? chartW / (labels.length - 1) : chartW;
        const points = values.map((v, i) => {
            const x = pad.left + (labels.length > 1 ? stepX * i : chartW / 2);
            const y = pad.top + (1 - v / maxVal) * chartH;
            return { x, y };
        });

        ctx.strokeStyle = '#667eea';
        ctx.lineWidth = 2;
        ctx.beginPath();
        points.forEach((p, i) => {
            if (i === 0) ctx.moveTo(p.x, p.y);
            else ctx.lineTo(p.x, p.y);
        });
        ctx.stroke();

        ctx.fillStyle = '#667eea';
        points.forEach(p => {
            ctx.beginPath();
            ctx.arc(p.x, p.y, 3, 0, Math.PI * 2);
            ctx.fill();
        });
    }

    (function initRevenueChart() {
        const canvas = document.getElementById('revenueChart');
        if (!canvas) return;
        if (revenueData.length === 0) {
            renderEmptyRevenueState();
            return;
        }

        const labels = revenueData.map(d => d.date);
        const revenues = revenueData.map(d => d.revenue);

        if (window.Chart) {
            const ctx = canvas.getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Doanh Thu (VNĐ)',
                        data: revenues,
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 5,
                        pointBackgroundColor: '#667eea',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2,
                        pointHoverRadius: 7
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            labels: {
                                font: { size: 14 },
                                padding: 20
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return value.toLocaleString('vi-VN') + ' VNĐ';
                                }
                            }
                        }
                    }
                }
            });
        } else {
            renderRevenueFallback(canvas, labels, revenues);
        }
    })();
</script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
