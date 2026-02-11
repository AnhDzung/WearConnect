<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        :root {
            --ink: #111111;
            --muted: #6f6a64;
            --paper: #f9f7f3;
            --pearl: #ffffff;
            --accent: #1f8e74;
            --accent-strong: #156c57;
            --gold: #c7933c;
            --danger: #b42318;
            --shadow: 0 12px 30px rgba(23, 18, 12, 0.12);
            --radius: 18px;
        }
        body {
            margin: 0;
            color: var(--ink);
            background: radial-gradient(circle at 10% 10%, #f2e7d7, transparent 40%),
                        radial-gradient(circle at 90% 20%, #e5f2ec, transparent 45%),
                        var(--paper);
            font-family: var(--font-family, cursive);
        }
        .container { max-width: 1180px; margin: 0 auto; padding: 32px 20px 70px; }
        .page-hero {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            align-items: center;
            justify-content: space-between;
            padding: 24px 28px;
            background: var(--pearl);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid rgba(0, 0, 0, 0.06);
        }
        .page-hero h1 {
            margin: 0 0 6px;
            font-family: var(--font-family, cursive);
            font-size: clamp(28px, 4vw, 40px);
            letter-spacing: 0.3px;
        }
        .page-hero p { margin: 0; color: var(--muted); font-size: 15px; }
        .toolbar { display: flex; flex-wrap: wrap; gap: 12px; }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 18px;
            border-radius: 999px;
            font-weight: 600;
            border: 1px solid transparent;
            text-decoration: none;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease, background-color 0.2s ease;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 18px rgba(0, 0, 0, 0.12); }
        .btn-primary { background: var(--accent); color: #fff; }
        .btn-primary:hover { background: var(--accent-strong); }
        .btn-ghost { background: #ffffff; color: var(--ink); border-color: rgba(0, 0, 0, 0.12); }
        .btn-outline { background: transparent; color: var(--ink); border-color: rgba(0, 0, 0, 0.2); }
        .btn-danger { background: #fff; color: var(--danger); border-color: rgba(180, 35, 24, 0.35); }
        .alert-success {
            margin: 22px 0 0;
            padding: 12px 16px;
            border-radius: 12px;
            background: #e7f6ef;
            color: #0b5138;
            font-weight: 600;
            border: 1px solid rgba(15, 89, 58, 0.2);
        }
        .clothing-list {
            margin-top: 28px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 22px;
        }
        .clothing-card {
            display: flex;
            flex-direction: column;
            gap: 12px;
            padding: 16px;
            border-radius: var(--radius);
            background: var(--pearl);
            box-shadow: var(--shadow);
            border: 1px solid rgba(0, 0, 0, 0.06);
        }
        .image-wrap {
            position: relative;
            border-radius: 14px;
            overflow: hidden;
        }
        .image-wrap img { width: 100%; height: 240px; object-fit: cover; display: block; }
        .badge {
            position: absolute;
            left: 12px;
            bottom: 12px;
            padding: 6px 12px;
            border-radius: 999px;
            background: rgba(17, 17, 17, 0.8);
            color: #fff;
            font-size: 12px;
            letter-spacing: 0.3px;
        }
        .card-title { margin: 0; font-size: 18px; font-weight: 700; }
        .price { font-weight: 700; color: var(--accent-strong); }
        .meta { color: var(--muted); font-size: 14px; }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 8px 16px;
            font-size: 14px;
        }
        .info-grid span { color: var(--muted); }
        .actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 6px; }
        .description { color: var(--muted); font-size: 14px; line-height: 1.5; }
        @media (max-width: 720px) {
            .page-hero { padding: 18px 20px; }
            .info-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="container">
    <div class="page-hero">
        <div>
            <h1>Quản lý quần áo của tôi</h1>
            <p>Kiểm soát kho, chỉnh sửa thông tin và cập nhật tình trạng sẵn sàng.</p>
        </div>
        <div class="toolbar">
            <a href="${pageContext.request.contextPath}/clothing?action=upload" class="btn btn-primary">Đăng tải quần áo</a>
            <a href="${pageContext.request.contextPath}/manager" class="btn btn-ghost">Về bảng điều khiển</a>
        </div>
    </div>
    
    <c:if test="${param.success}">
        <div class="alert-success">Thao tác thành công!</div>
    </c:if>
    
    <div class="clothing-list">
        <c:forEach var="clothing" items="${myClothing}">
            <div class="clothing-card">
                <div class="image-wrap">
                    <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
                    <span class="badge">${clothing.category}</span>
                </div>
                <div>
                    <h3 class="card-title">${clothing.clothingName}</h3>
                    <div class="meta">${clothing.style} · ${clothing.occasion} · Size ${clothing.size}</div>
                </div>
                <div class="info-grid">
                    <div><span>Số lượng:</span> ${clothing.quantity > 0 ? clothing.quantity : 1} sản phẩm</div>
                    <div><span>Giá thuê/giờ:</span> <span class="price">${clothing.hourlyPrice} VNĐ</span></div>
                    <div><span>Có sẵn từ:</span> ${clothing.availableFrom}</div>
                    <div><span>Đến:</span> ${clothing.availableTo}</div>
                </div>
                <div class="description">${clothing.description}</div>
                <div class="actions">
                    <a href="${pageContext.request.contextPath}/clothing?action=view&id=${clothing.clothingID}" class="btn btn-outline">Xem chi tiết</a>
                    <a href="${pageContext.request.contextPath}/clothing?action=edit&id=${clothing.clothingID}" class="btn btn-primary">Chỉnh sửa</a>
                    <form method="POST" action="${pageContext.request.contextPath}/clothing" style="display:inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="clothingID" value="${clothing.clothingID}">
                        <button type="submit" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn xóa?')">Xóa</button>
                    </form>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
