<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá đơn hàng - WearConnect</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: cursive; background: #f5f5f5; padding: 20px; }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e0e0e0;
        }
        .header h1 { color: #333; font-size: 28px; }
        .back-link {
            padding: 10px 20px;
            background: #6c757d;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .table-container { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 14px; }
        thead { background: #343a40; color: white; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e0e0e0; }
        th { font-weight: 600; text-transform: uppercase; font-size: 12px; letter-spacing: 0.5px; }
        tbody tr:hover { background: #f8f9fa; }
        .rating-score { font-weight: 700; color: #d32f2f; }
        .role-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            background: #e9ecef;
            color: #495057;
        }
        .no-data { text-align: center; padding: 60px 20px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Đánh giá đơn hàng</h1>
            <a href="${pageContext.request.contextPath}/admin" class="back-link">Quay lại Dashboard</a>
        </div>

        <div class="table-container">
            <c:choose>
                <c:when test="${not empty ratings}">
                    <table>
                        <thead>
                            <tr>
                                <th>Mã ĐH</th>
                                <th>Sản phẩm</th>
                                <th>Người đánh giá</th>
                                <th>Vai trò</th>
                                <th>Được đánh giá</th>
                                <th>Vai trò</th>
                                <th>Số sao</th>
                                <th>Nhận xét</th>
                                <th>Ngày tạo</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rating" items="${ratings}">
                                <tr>
                                    <td>#${rating.rentalOrderID}</td>
                                    <td>${rating.clothingName}</td>
                                    <td>${rating.raterName}</td>
                                    <td><span class="role-badge">${rating.raterRole}</span></td>
                                    <td>${rating.ratedName}</td>
                                    <td><span class="role-badge">${rating.ratedRole}</span></td>
                                    <td class="rating-score">${rating.rating}</td>
                                    <td>${empty rating.comment ? "-" : rating.comment}</td>
                                    <td><fmt:formatDate value="${rating.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-data">
                        Không có đánh giá nào.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
