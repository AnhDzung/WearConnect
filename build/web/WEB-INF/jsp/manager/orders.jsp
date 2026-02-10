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
        /* Rating widget styles */
        .star-rating { display: inline-flex; flex-direction: row-reverse; gap: 6px; font-size: 16px; cursor: pointer; vertical-align: middle; }
        .star-rating input { display: none; }
        .star-rating label { color: #ccc; transition: color 0.15s ease; padding:0 4px; }
        .star-rating input:checked ~ label { color: #f5b301; }
        .star-rating label:hover, .star-rating label:hover ~ label { color: #f5d16b; }

        /* Rating cell layout to avoid overlap. Panels are overlays so they don't expand the table row. */
        .rating-cell { position: relative; padding-left: 6px; }
        .rating-panel { display: none; position: absolute; top: 42px; right: 0; z-index: 60; width: 360px; background: white; padding: 12px; box-shadow: 0 6px 18px rgba(0,0,0,0.12); border-radius: 8px; }
        .rating-panel.open { display: flex; flex-direction: column; gap:8px; }
        .rating-cell form { display: flex; gap: 8px; align-items: center; flex-wrap: nowrap; margin:0; }
        .rating-cell .star-rating { flex: 0 0 auto; margin-top: 0; }
        .rating-cell .comment { flex: 1 1 200px; min-width: 120px; max-width: 240px; padding:6px 8px; border:1px solid #ddd; border-radius:6px; box-sizing: border-box; font-size:14px }
        .rating-cell .submit-btn { flex: 0 0 auto; padding:8px 10px; border-radius:6px; background:#00c0d8; color:white; border:none; cursor:pointer; min-width:100px; }
        .rating-cell .submit-btn:hover { opacity: 0.95; }

        /* Action cell alignment so 'Chi tiết' lines up vertically with rating controls */
        .action-cell { display:flex; align-items:center; gap:8px; }
        td .btn { margin-right: 8px; }

        /* Prevent adjacent cell overlap */
        td { vertical-align: middle; }

        @media (max-width: 900px) {
            .rating-cell form { gap:6px; }
            .rating-cell .comment { flex-basis: 200px; }
            .star-rating { font-size: 15px; }
        }
        @media (max-width: 640px) {
            .rating-cell form { flex-direction: column; align-items: stretch; }
            .rating-cell .star-rating { order: 1; }
            .rating-cell .comment { order: 2; width: 100%; }
            .rating-cell .submit-btn { order: 3; width: 100%; }
            .rating-cell .submit-btn { min-width: unset; }
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
                    <th>Đánh Giá</th>
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
                    <td><span class="status status-confirmed">Đã Xác Nhận</span></td>
                    <td class="action-cell"><button class="btn btn-primary">Xem</button></td>
                    <td class="rating-cell">
                        <button type="button" class="btn" data-toggle-row="1" style="background:#00c0d8;color:#fff;border-radius:6px;padding:8px 12px;">Đánh giá khách hàng</button>
                        <div class="rating-panel" id="rating-panel-1">
                        <form method="POST" action="${pageContext.request.contextPath}/rating">
                            <input type="hidden" name="action" value="submitRating">
                            <input type="hidden" name="rentalOrderID" value="1">
                            <div class="star-rating" data-row="1" aria-hidden="false" role="radiogroup" aria-label="Đánh giá sao">
                                <input type="radio" id="star5_1" name="rating" value="5" aria-label="5 sao"><label for="star5_1" title="5 sao">&#9733;</label>
                                <input type="radio" id="star4_1" name="rating" value="4" aria-label="4 sao"><label for="star4_1" title="4 sao">&#9733;</label>
                                <input type="radio" id="star3_1" name="rating" value="3" aria-label="3 sao"><label for="star3_1" title="3 sao">&#9733;</label>
                                <input type="radio" id="star2_1" name="rating" value="2" aria-label="2 sao"><label for="star2_1" title="2 sao">&#9733;</label>
                                <input type="radio" id="star1_1" name="rating" value="1" aria-label="1 sao"><label for="star1_1" title="1 sao">&#9733;</label>
                            </div>
                            <input type="text" name="comment" class="comment" placeholder="Ghi chú (tùy chọn)">
                            <button type="submit" class="submit-btn">Gửi đánh giá</button>
                        </form>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>#002</td>
                    <td>Váy dạo phố</td>
                    <td>Trần Thị B</td>
                    <td>2026-01-21</td>
                    <td>2026-01-23</td>
                    <td>200.000 VNĐ</td>
                    <td><span class="status status-pending">Chờ Duyệt</span></td>
                    <td class="action-cell"><button class="btn btn-primary">Xem</button></td>
                    <td class="rating-cell">
                        <button type="button" class="btn" data-toggle-row="2" style="background:#00c0d8;color:#fff;border-radius:6px;padding:8px 12px;">Đánh giá khách hàng</button>
                        <div class="rating-panel" id="rating-panel-2">
                        <form method="POST" action="${pageContext.request.contextPath}/rating">
                            <input type="hidden" name="action" value="submitRating">
                            <input type="hidden" name="rentalOrderID" value="2">
                            <div class="star-rating" data-row="2" aria-hidden="false" role="radiogroup" aria-label="Đánh giá sao">
                                <input type="radio" id="star5_2" name="rating" value="5" aria-label="5 sao"><label for="star5_2" title="5 sao">&#9733;</label>
                                <input type="radio" id="star4_2" name="rating" value="4" aria-label="4 sao"><label for="star4_2" title="4 sao">&#9733;</label>
                                <input type="radio" id="star3_2" name="rating" value="3" aria-label="3 sao"><label for="star3_2" title="3 sao">&#9733;</label>
                                <input type="radio" id="star2_2" name="rating" value="2" aria-label="2 sao"><label for="star2_2" title="2 sao">&#9733;</label>
                                <input type="radio" id="star1_2" name="rating" value="1" aria-label="1 sao"><label for="star1_2" title="1 sao">&#9733;</label>
                            </div>
                            <input type="text" name="comment" class="comment" placeholder="Ghi chú (tùy chọn)">
                            <button type="submit" class="submit-btn">Gửi đánh giá</button>
                        </form>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>#003</td>
                    <td>Quần jean</td>
                    <td>Lê Văn C</td>
                    <td>2026-01-15</td>
                    <td>2026-01-18</td>
                    <td>100.000 VNĐ</td>
                    <td><span class="status status-returned">Đã Trả</span></td>
                    <td class="action-cell"><button class="btn btn-primary">Xem</button></td>
                    <td class="rating-cell">
                        <button type="button" class="btn" data-toggle-row="3" style="background:#00c0d8;color:#fff;border-radius:6px;padding:8px 12px;">Đánh giá khách hàng</button>
                        <div class="rating-panel" id="rating-panel-3">
                        <form method="POST" action="${pageContext.request.contextPath}/rating">
                            <input type="hidden" name="action" value="submitRating">
                            <input type="hidden" name="rentalOrderID" value="3">
                            <div class="star-rating" data-row="3" aria-hidden="false" role="radiogroup" aria-label="Đánh giá sao">
                                <input type="radio" id="star5_3" name="rating" value="5" aria-label="5 sao"><label for="star5_3" title="5 sao">&#9733;</label>
                                <input type="radio" id="star4_3" name="rating" value="4" aria-label="4 sao"><label for="star4_3" title="4 sao">&#9733;</label>
                                <input type="radio" id="star3_3" name="rating" value="3" aria-label="3 sao"><label for="star3_3" title="3 sao">&#9733;</label>
                                <input type="radio" id="star2_3" name="rating" value="2" aria-label="2 sao"><label for="star2_3" title="2 sao">&#9733;</label>
                                <input type="radio" id="star1_3" name="rating" value="1" aria-label="1 sao"><label for="star1_3" title="1 sao">&#9733;</label>
                            </div>
                            <input type="text" name="comment" class="comment" placeholder="Ghi chú (tùy chọn)">
                            <button type="submit" class="submit-btn">Gửi đánh giá</button>
                        </form>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
<script>
    // Enhance star hover for radio-based rating (works with CSS too)
    (function(){
        document.querySelectorAll('.star-rating').forEach(function(container){
            var labels = container.querySelectorAll('label');
            labels.forEach(function(lbl){
                lbl.addEventListener('click', function(){
                    // nothing extra needed; radio handles value. Small UX: briefly flash selected color handled by CSS.
                });
            });
        });
    })();
    // Toggle rating panels per row
    (function(){
        document.querySelectorAll('button[data-toggle-row]').forEach(function(btn){
            btn.addEventListener('click', function(){
                var id = btn.getAttribute('data-toggle-row');
                var panel = document.getElementById('rating-panel-' + id);
                if (!panel) return;
                // close other panels
                document.querySelectorAll('.rating-panel.open').forEach(function(p){ if(p !== panel) p.classList.remove('open'); });
                panel.classList.toggle('open');
                // focus the comment input when opening
                if (panel.classList.contains('open')) {
                    var input = panel.querySelector('.comment');
                    if (input) input.focus();
                }
            });
        });
        // close panels when clicking outside
        document.addEventListener('click', function(e){
            if (e.target.closest('.rating-cell')) return;
            document.querySelectorAll('.rating-panel.open').forEach(function(p){ p.classList.remove('open'); });
        });
    })();
</script>
