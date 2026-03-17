<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Color" %>
<%@ page import="Model.CosplayDetail" %>
<%@ page import="DAO.ColorDAO" %>
<%@ page import="DAO.CosplayDetailDAO" %>
<%
    int managerID = (session != null && session.getAttribute("accountID") != null) 
        ? (int) session.getAttribute("accountID") 
        : -1;
    
    int clothingID = 0;
    CosplayDetail cosplayDetail = null;
    String availableFromValue = "";
    String availableToValue = "";
    String[] existingSizes = new String[0];
    try {
        Object clothing = pageContext.getAttribute("clothing", PageContext.REQUEST_SCOPE);
        if (clothing != null && clothing instanceof Model.Clothing) {
            clothingID = ((Model.Clothing) clothing).getClothingID();
            // Fetch existing cosplay detail if it exists
            cosplayDetail = CosplayDetailDAO.getCosplayDetailByClothingID(clothingID);
            
            // Parse existing sizes
            String sizeStr = ((Model.Clothing) clothing).getSize();
            if (sizeStr != null && !sizeStr.isEmpty()) {
                existingSizes = sizeStr.split(",\\s*");
            }

            java.time.LocalDateTime from = ((Model.Clothing) clothing).getAvailableFrom();
            java.time.LocalDateTime to = ((Model.Clothing) clothing).getAvailableTo();
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            if (from != null) availableFromValue = from.format(formatter);
            if (to != null) availableToValue = to.format(formatter);
        }
    } catch (Exception e) {}
    
    List<Color> availableColors = ColorDAO.getColorsByManager(managerID);
    List<Color> clothingColors = clothingID > 0 ? ColorDAO.getColorsByClothing(clothingID) : new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chỉnh sửa quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@600;700;800&display=swap');

        :root {
            --ink: #1b232e;
            --muted: #667085;
            --line: #dbe2ea;
            --bg: #eef3f8;
            --card: #ffffff;
            --brand: #0ea5e9;
            --brand-strong: #0284c7;
            --accent: #f59e0b;
        }

        body {
            margin: 0;
            background:
                radial-gradient(1200px 600px at -10% -20%, rgba(14, 165, 233, 0.18), transparent 60%),
                radial-gradient(1000px 500px at 110% -10%, rgba(245, 158, 11, 0.16), transparent 60%),
                var(--bg);
            color: var(--ink);
            font-family: 'Inter', sans-serif;
        }

        .form-container {
            max-width: 980px;
            margin: 26px auto 36px;
            padding: 26px;
            border: 1px solid var(--line);
            background: var(--card);
            border-radius: 18px;
            box-shadow: 0 14px 40px rgba(13, 32, 56, 0.12);
        }

        .form-container h1 {
            margin: 0 0 8px;
            font-family: 'Poppins', sans-serif;
            font-size: clamp(24px, 3vw, 34px);
            letter-spacing: 0.2px;
        }

        .upload-subtitle {
            margin: 0 0 20px;
            color: var(--muted);
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-weight: 700;
            color: #273445;
            font-size: 13px;
            letter-spacing: 0.2px;
        }

        input,
        textarea,
        select {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid var(--line);
            border-radius: 11px;
            background: #f9fbfd;
            color: var(--ink);
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            transition: border-color 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
            box-sizing: border-box;
        }

        input:focus,
        textarea:focus,
        select:focus {
            outline: none;
            background: #fff;
            border-color: var(--brand);
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.15);
        }

        small {
            color: var(--muted) !important;
            display: block;
            margin-top: 6px;
            font-size: 12px;
            line-height: 1.45;
        }

        .cosplay-note {
            background: linear-gradient(135deg, #fffbeb 0%, #fff4d8 100%);
            border: 1px solid #facc15;
            padding: 14px 16px;
            border-radius: 12px;
            margin-bottom: 18px;
        }

        .cosplay-note h3 {
            margin: 0 0 6px;
            color: #a16207;
            font-size: 16px;
        }

        .cosplay-note p {
            margin: 0;
            color: #92400e;
            font-size: 13px;
        }

        .size-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-top: 8px;
        }

        .size-option {
            display: flex;
            align-items: center;
            padding: 9px 10px;
            border: 1px solid var(--line);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s;
            background: #fff;
        }

        .size-option:hover {
            background: #f0f8ff;
            border-color: #93c5fd;
            transform: translateY(-1px);
        }

        .size-option input[type="checkbox"] {
            margin-right: 8px;
            cursor: pointer;
        }

        .size-option span {
            font-weight: 600;
        }

        .color-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(118px, 1fr));
            gap: 10px;
            margin-bottom: 12px;
        }

        .color-option {
            padding: 10px;
            border: 1px solid var(--line);
            border-radius: 11px;
            cursor: pointer;
            text-align: center;
            background: #fff;
            transition: all 0.2s;
        }

        .color-option:hover {
            border-color: var(--brand);
            box-shadow: 0 6px 16px rgba(14, 165, 233, 0.16);
            transform: translateY(-1px);
        }

        .color-option input[type="checkbox"] {
            display: block;
            margin: 6px auto 2px;
            cursor: pointer;
        }

        .color-swatch {
            width: 100%;
            height: 30px;
            border-radius: 8px;
            margin-bottom: 6px;
            border: 1px solid #dbe4ee;
        }

        .current-colors {
            margin: 10px 0;
            padding: 12px;
            background: #f8fbff;
            border: 1px solid #dbeafe;
            border-radius: 12px;
        }

        .color-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
            color: white;
            padding: 6px 10px;
            border-radius: 999px;
            margin: 5px 6px 5px 0;
            font-size: 12px;
            font-weight: 600;
        }

        .mini-swatch {
            display: inline-block;
            width: 16px;
            height: 16px;
            border-radius: 4px;
            border: 1px solid rgba(255,255,255,0.6);
        }

        .empty-note {
            color: #98a2b3;
            font-style: italic;
            font-size: 13px;
        }

        .custom-color-section {
            margin-top: 15px;
            padding: 15px;
            background: #f8fbff;
            border: 1px solid #dbeafe;
            border-radius: 12px;
        }

        .custom-color-section input {
            margin-top: 6px;
        }

        .preview-card {
            margin-top: 10px;
            padding: 10px;
            background-color: white;
            border: 1px solid var(--line);
            border-radius: 8px;
        }

        .preview-card .color-swatch {
            height: 50px;
            margin-top: 10px;
            margin-bottom: 0;
        }

        .image-gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 12px;
            margin-top: 10px;
        }

        .image-item {
            border: 1px solid var(--line);
            border-radius: 10px;
            padding: 8px;
            background: #fff;
            box-shadow: 0 6px 14px rgba(15, 23, 42, 0.08);
        }

        .image-item img {
            width: 100%;
            height: 120px;
            object-fit: cover;
            border-radius: 8px;
        }

        .image-actions {
            margin-top: 8px;
            font-size: 12px;
            color: #555;
        }

        .current-image {
            margin-top: 10px;
            display: inline-block;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid var(--line);
        }

        .current-image img {
            width: 220px;
            max-width: 100%;
            height: auto;
            display: block;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 8px;
            flex-wrap: wrap;
        }

        button {
            padding: 11px 18px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            margin-right: 0;
            font-weight: 700;
            letter-spacing: 0.2px;
            transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        }

        button[type="submit"] {
            background: linear-gradient(135deg, var(--brand) 0%, var(--brand-strong) 100%);
            color: #fff;
            box-shadow: 0 8px 18px rgba(2, 132, 199, 0.35);
        }

        button[type="submit"]:hover {
            transform: translateY(-1px);
            box-shadow: 0 12px 24px rgba(2, 132, 199, 0.42);
        }

        .btn-back {
            background: #eef2f7;
            color: #1f2937;
            border: 1px solid #d5dce5;
        }

        .btn-back:hover {
            background: #e3e9f1;
            transform: translateY(-1px);
        }

        @media (max-width: 768px) {
            .form-container {
                margin: 16px 12px 24px;
                padding: 18px;
                border-radius: 14px;
            }

            .size-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 520px) {
            .size-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="form-container">
    <h1>Chỉnh Sửa Quần Áo</h1>
    <p class="upload-subtitle">Cập nhật thông tin sản phẩm để tăng khả năng được thuê và hiển thị chuyên nghiệp hơn.</p>
    
    <form method="POST" action="${pageContext.request.contextPath}/clothing" enctype="multipart/form-data" onsubmit="return validateForm()">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="clothingID" value="${clothing.clothingID}">
        
        <div class="form-group">
            <label for="clothingName">Tên quần áo:</label>
            <input type="text" id="clothingName" name="clothingName" value="${clothing.clothingName}" required>
        </div>
        
        <div class="form-group">
            <label for="category">Danh mục:</label>
            <select id="category" name="category" required onchange="toggleCosplayFields()">
                <option value="">-- Chọn danh mục --</option>
                <option value="Váy" <c:if test="${clothing.category == 'Váy'}">selected</c:if>>Váy</option>
                <option value="Áo dài" <c:if test="${clothing.category == 'Áo dài'}">selected</c:if>>Áo dài</option>
                <option value="Áo" <c:if test="${clothing.category == 'Áo'}">selected</c:if>>Áo</option>
                <option value="Quần" <c:if test="${clothing.category == 'Quần'}">selected</c:if>>Quần</option>
                <option value="Áo khoác" <c:if test="${clothing.category == 'Áo khoác'}">selected</c:if>>Áo khoác</option>
                <option value="Set" <c:if test="${clothing.category == 'Set'}">selected</c:if>>Set quần áo</option>
                <option value="Cosplay" <c:if test="${clothing.category == 'Cosplay'}">selected</c:if>>Cosplay</option>
                <option value="Phụ kiện" <c:if test="${clothing.category == 'Phụ kiện'}">selected</c:if>>Phụ kiện</option>
            </select>
        </div>
        
        <div class="form-group" id="styleSection">
            <label for="style">Phong cách:</label>
            <select id="style" name="style" required>
                <option value="">-- Chọn phong cách --</option>
                <option value="Thường ngày" <c:if test="${clothing.style == 'Thường ngày'}">selected</c:if>>Thường ngày</option>
                <option value="Trang trọng" <c:if test="${clothing.style == 'Trang trọng'}">selected</c:if>>Trang trọng</option>
                <option value="Dự tiệc" <c:if test="${clothing.style == 'Dự tiệc'}">selected</c:if>>Dự tiệc</option>
                <option value="Thể thao" <c:if test="${clothing.style == 'Thể thao'}">selected</c:if>>Thể thao</option>
                <option value="Cổ điển" <c:if test="${clothing.style == 'Cổ điển'}">selected</c:if>>Cổ điển</option>
                <option value="Vintage" <c:if test="${clothing.style == 'Vintage'}">selected</c:if>>Vintage</option>
                <option value="Streetwear" <c:if test="${clothing.style == 'Streetwear'}">selected</c:if>>Streetwear</option>
                <option value="Sexy" <c:if test="${clothing.style == 'Sexy'}">selected</c:if>>Sexy</option>
                <option value="Minimalist" <c:if test="${clothing.style == 'Minimalist'}">selected</c:if>>Minimalist</option>
            </select>
        </div>

        <div class="form-group">
            <label for="occasion">Mục đích sử dụng:</label>
            <select id="occasion" name="occasion" required>
                <option value="">-- Chọn mục đích --</option>
                <option value="Dự tiệc" <c:if test="${clothing.occasion == 'Dự tiệc'}">selected</c:if>>Dự tiệc</option>
                <option value="Tốt nghiệp" <c:if test="${clothing.occasion == 'Tốt nghiệp'}">selected</c:if>>Tốt nghiệp</option>
                <option value="Đám cưới" <c:if test="${clothing.occasion == 'Đám cưới' || clothing.occasion == 'Tiệc cưới'}">selected</c:if>>Đám cưới</option>
                <option value="Gala / Sự kiện công ty" <c:if test="${clothing.occasion == 'Gala / Sự kiện công ty'}">selected</c:if>>Gala / Sự kiện công ty</option>
                <option value="Biểu diễn" <c:if test="${clothing.occasion == 'Biểu diễn'}">selected</c:if>>Biểu diễn</option>
                <option value="Chụp ảnh" <c:if test="${clothing.occasion == 'Chụp ảnh'}">selected</c:if>>Chụp ảnh</option>
                <option value="Quay video / Content" <c:if test="${clothing.occasion == 'Quay video / Content'}">selected</c:if>>Quay video / Content</option>
                <option value="Du lịch" <c:if test="${clothing.occasion == 'Du lịch'}">selected</c:if>>Du lịch</option>
                <option value="Hẹn hò" <c:if test="${clothing.occasion == 'Hẹn hò'}">selected</c:if>>Hẹn hò</option>
                <option value="Đi biển" <c:if test="${clothing.occasion == 'Đi biển'}">selected</c:if>>Đi biển</option>
                <option value="Street style / Đi chơi concept" <c:if test="${clothing.occasion == 'Street style / Đi chơi concept'}">selected</c:if>>Street style / Đi chơi concept</option>
            </select>
        </div>
        
        <!-- Cosplay-specific fields (hidden by default) -->
        <div id="cosplayFields" style="display: none;">
            <div class="cosplay-note">
                <h3>📝 Thông tin Cosplay bổ sung</h3>
                <p>Cosplay cần được admin xét duyệt trước khi hiển thị.</p>
            </div>

            <div class="form-group">
                <label for="characterName">Tên nhân vật: *</label>
                <input type="text" id="characterName" name="characterName" placeholder="Ví dụ: Gojo Satoru, Luffy, Miku Hatsune" value="<%= cosplayDetail != null ? cosplayDetail.getCharacterName() : "" %>">
            </div>

            <div class="form-group">
                <label for="series">Series: *</label>
                <input type="text" id="series" name="series" placeholder="Ví dụ: Jujutsu Kaisen, One Piece, Vocaloid" value="<%= cosplayDetail != null ? cosplayDetail.getSeries() : "" %>">
            </div>

            <div class="form-group">
                <label for="cosplayType">Loại: *</label>
                <select id="cosplayType" name="cosplayType">
                    <option value="">-- Chọn loại --</option>
                    <option value="Anime" <%= cosplayDetail != null && "Anime".equals(cosplayDetail.getCosplayType()) ? "selected" : "" %>>Anime</option>
                    <option value="Game" <%= cosplayDetail != null && "Game".equals(cosplayDetail.getCosplayType()) ? "selected" : "" %>>Game</option>
                    <option value="Movie" <%= cosplayDetail != null && "Movie".equals(cosplayDetail.getCosplayType()) ? "selected" : "" %>>Movie</option>
                </select>
            </div>

            <div class="form-group">
                <label for="accuracyLevel">Mức độ hoàn thiện: *</label>
                <select id="accuracyLevel" name="accuracyLevel">
                    <option value="">-- Chọn mức độ --</option>
                    <option value="Cao" <%= cosplayDetail != null && "Cao".equals(cosplayDetail.getAccuracyLevel()) ? "selected" : "" %>>Cao (99% giống gốc)</option>
                    <option value="Trung bình" <%= cosplayDetail != null && "Trung bình".equals(cosplayDetail.getAccuracyLevel()) ? "selected" : "" %>>Trung bình (tương đối giống)</option>
                    <option value="Cơ bản" <%= cosplayDetail != null && "Cơ bản".equals(cosplayDetail.getAccuracyLevel()) ? "selected" : "" %>>Cơ bản (có thể thiếu chi tiết)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="accessoryList">Danh sách phụ kiện đi kèm:</label>
                <textarea id="accessoryList" name="accessoryList" rows="3" placeholder="Ví dụ: Vương miện, gươm gỗ, găng tay, giày cao cổ, tóc giả xanh dương, kính đen..."><%= cosplayDetail != null && cosplayDetail.getAccessoryList() != null ? cosplayDetail.getAccessoryList() : "" %></textarea>
                <small style="color: #666; display: block; margin-top: 5px;">Liệt kê các phụ kiện đi kèm với outfit cosplay</small>
            </div>
        </div>

        <div class="form-group">
            <label>Size: *</label>
            <%
                String[] allSizes = {"XS", "S", "M", "L", "XL", "XXL"};
                java.util.Set<String> existingSizeSet = new java.util.HashSet<>(java.util.Arrays.asList(existingSizes));
            %>
            <div class="size-grid">
                <%
                for (String sizeOption : allSizes) {
                    boolean isChecked = existingSizeSet.contains(sizeOption);
                %>
                <label class="size-option">
                    <input type="checkbox" name="size" value="<%= sizeOption %>" <%= isChecked ? "checked" : "" %>>
                    <span><%= sizeOption %></span>
                </label>
                <%
                }
                %>
            </div>
            <small style="color: #666; display: block; margin-top: 5px;">Chọn tất cả size có sẵn cho sản phẩm này</small>
        </div>
        
        <div class="form-group">
            <label for="quantity">Số lượng:</label>
            <input type="number" id="quantity" name="quantity" min="1" max="1000" value="${clothing.quantity > 0 ? clothing.quantity : 1}" required>
            <small style="color: #666; display: block; margin-top: 5px;">Số lượng sản phẩm cùng loại có sẵn để cho thuê</small>
        </div>
        
        <div class="form-group">
            <label for="description">Mô tả:</label>
            <textarea id="description" name="description" rows="4" required>${clothing.description}</textarea>
        </div>
        
        <div class="form-group">
            <label for="hourlyPrice">Giá thuê/giờ (VNĐ):</label>
            <input type="number" id="hourlyPrice" name="hourlyPrice" step="0.01" min="10000" max="99999999.99" value="${clothing.hourlyPrice}" required>
            <small style="color: #666; display: block; margin-top: 5px;">Giá tối thiểu: 10.000 VNĐ</small>
        </div>
        
        <div class="form-group">
            <label for="dailyPrice">Giá thuê/ngày (VNĐ):</label>
            <c:set var="dailyPriceValue">
                <c:choose>
                    <c:when test="${clothing.dailyPrice > 0}">${clothing.dailyPrice}</c:when>
                    <c:otherwise>${clothing.hourlyPrice * 24}</c:otherwise>
                </c:choose>
            </c:set>
            <input type="number" id="dailyPrice" name="dailyPrice" step="0.01" min="10000" max="99999999.99" value="${dailyPriceValue}" required>
            <small style="color: #666; display: block; margin-top: 5px;">Giá tối thiểu: 10.000 VNĐ</small>
        </div>
        
        <div class="form-group">
            <label for="itemValue">Item value (VNĐ):</label>
                 <input type="number" id="itemValue" name="itemValue" step="0.01" min="0" max="99999999.99" 
                     value="${clothing.itemValue > 0 ? clothing.itemValue : clothing.hourlyPrice * 24 * 0.2}" required>
            <small style="color: #666; display: block; margin-top: 5px;">Giá trị sản phẩm - người dùng phải trả khi đặt thuê. Người dùng sẽ thanh toán 100% tổng tiền.</small>
        </div>

        <!-- Chỉnh sửa màu sắc -->
        <div class="form-group">
            <label>Màu sắc hiện tại:</label>
            <div class="current-colors">
                <% if (clothingColors.isEmpty()) { %>
                    <em class="empty-note">Chưa có màu nào được chọn</em>
                <% } else { %>
                    <% for (Color color : clothingColors) { %>
                        <%
                            String currentHex = color.getHexCode();
                            if (currentHex == null || currentHex.trim().isEmpty()) {
                                currentHex = "#ccc";
                            }
                        %>
                        <span class="color-tag">
                            <span class="mini-swatch" data-color="<%= currentHex %>"></span>
                            <%= color.getColorName() %>
                        </span>
                    <% } %>
                <% } %>
            </div>
        </div>

        <div class="form-group" id="colorSection">
            <label>Cập nhật màu sắc:</label>
            <div class="color-grid">
                <%
                    for (Color color : availableColors) {
                        String colorClass = color.getManagerID() != null && color.getManagerID() == managerID ? "manager-custom" : "global";
                        String hexCode = color.getHexCode();
                        if (hexCode == null || hexCode.trim().isEmpty()) {
                            hexCode = "#ccc";
                        }
                        boolean isSelected = false;
                        for (Color selected : clothingColors) {
                            if (selected.getColorID() == color.getColorID()) {
                                isSelected = true;
                                break;
                            }
                        }
                %>
                <div class="color-option">
                    <div class="color-swatch" data-color="<%= hexCode %>" title="<%= color.getColorName() %>"></div>
                    <label>
                        <input type="checkbox" name="colors" value="<%= color.getColorID() %>" class="color-checkbox <%= colorClass %>" <%= isSelected ? "checked" : "" %>>
                        <%= color.getColorName() %>
                    </label>
                </div>
                <%
                    }
                %>
            </div>
        </div>

        <div class="form-group" id="otherColorSection">
            <label>
                <input type="checkbox" id="hasOtherColor" name="hasOtherColor" onchange="toggleCustomColorInput()">
                Thêm màu khác (không có trong danh sách)
            </label>
        </div>

        <div class="custom-color-section" id="customColorSection" style="display: none;">
            <label for="customColorName">Tên màu mới:</label>
            <input type="text" id="customColorName" name="customColorName" placeholder="Ví dụ: Xanh nước biển, Đỏ đô..." maxlength="100" oninput="updateColorPreview()">
            
            <label for="customColorHex" style="margin-top: 10px;">Mã màu Hex (tùy chọn):</label>
            <input type="text" id="customColorHex" name="customColorHex" placeholder="Ví dụ: #FFCC66" maxlength="7" value="#CCCCCC" oninput="updateColorPreview()">
            <small style="color: #666; display: block; margin-top: 5px;">Định dạng: #RRGGBB (ví dụ: #FF0000 = Đỏ, #00FF00 = Xanh lá, #0000FF = Xanh dương)</small>
            <div class="preview-card">
                <span>Màu mẫu:</span>
                <div class="color-swatch" id="colorPreview" style="background-color: #CCCCCC;"></div>
            </div>
            <small style="color: #666; display: block; margin-top: 10px;">Màu mới sẽ được thêm vào danh sách của bạn. Nếu manager khác nhập cùng tên màu, sẽ sử dụng màu bạn đã tạo.</small>
        </div>
        
        <div class="form-group">
            <label>Hình ảnh hiện tại:</label>
            <c:choose>
                <c:when test="${not empty images}">
                    <div class="image-gallery">
                        <c:forEach var="img" items="${images}">
                            <div class="image-item">
                                <img src="${pageContext.request.contextPath}/image?imageID=${img.imageID}" alt="${clothing.clothingName}">
                                <div class="image-actions">
                                    <label style="display:flex;align-items:center;gap:6px;font-weight:normal;margin:0;">
                                        <input type="checkbox" name="deleteImageIds" value="${img.imageID}" style="width:auto; margin: 0;">
                                        Xóa ảnh này
                                    </label>
                                    <c:if test="${img.primary}">
                                        <small style="display:block;color:#28a745;margin-top:4px;">Ảnh chính</small>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="current-image">
                        <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        
        <div class="form-group">
            <label for="images">Thêm hình ảnh mới (có thể chọn nhiều):</label>
            <input type="file" id="images" name="images" accept="image/*" multiple>
            <small style="color: #999;">Bạn có thể tick xóa ảnh cũ phía trên rồi tải ảnh mới để thay thế. Ảnh đầu tiên tải lên sẽ trở thành ảnh chính.</small>
        </div>
        
        <div class="form-group">
            <label for="availableFrom">Có sẵn từ:</label>
            <input type="datetime-local" id="availableFrom" name="availableFrom" value="<%= availableFromValue %>" required>
        </div>
        
        <div class="form-group">
            <label for="availableTo">Đến:</label>
            <input type="datetime-local" id="availableTo" name="availableTo" value="<%= availableToValue %>" required>
        </div>
        
        <div class="form-group">
            <div class="form-actions">
                <button type="submit">Cập nhật</button>
                <button type="button" class="btn-back" onclick="history.back()">Hủy</button>
            </div>
        </div>
    </form>
</div>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />

<script>
    function toggleCustomColorInput() {
        const hasOtherColor = document.getElementById('hasOtherColor').checked;
        document.getElementById('customColorSection').style.display = hasOtherColor ? 'block' : 'none';
        
        if (hasOtherColor) {
            // Nếu chọn "Màu khác" thì uncheck các màu khác
            document.querySelectorAll('input[name="colors"]').forEach(cb => cb.checked = false);
        }
    }

    function updateColorPreview() {
        const hexInput = document.getElementById('customColorHex');
        const preview = document.getElementById('colorPreview');
        let hexValue = hexInput.value.trim();
        
        // Nếu trống thì dùng màu mặc định
        if (!hexValue) {
            hexValue = '#CCCCCC';
        }
        
        // Kiểm tra định dạng hex hợp lệ (bắt đầu với # và có 6 chữ số/ký tự)
        if (/^#[0-9A-Fa-f]{6}$/.test(hexValue)) {
            preview.style.backgroundColor = hexValue;
            hexInput.style.borderColor = '#ddd'; // Reset border color
        } else if (hexValue.length < 7) {
            // Chưa đủ ký tự, hiển thị màu mặc định
            preview.style.backgroundColor = '#CCCCCC';
        } else {
            // Format sai
            preview.style.backgroundColor = '#CCCCCC';
            hexInput.style.borderColor = '#ff6b6b'; // Highlight error
        }
    }

    function validateColors() {
        const category = document.getElementById('category').value;
        
        // Skip color validation for Cosplay category
        if (category === 'Cosplay') {
            return validateCosplayFields();
        }
        
        const checkedColors = document.querySelectorAll('input[name="colors"]:checked').length > 0;
        const hasCustomColor = document.getElementById('hasOtherColor').checked;
        const customColorName = document.getElementById('customColorName').value.trim();

        if (!checkedColors && !hasCustomColor) {
            alert('Vui lòng chọn ít nhất một màu sắc cho sản phẩm!');
            return false;
        }

        if (hasCustomColor && !customColorName) {
            alert('Vui lòng nhập tên màu sắc!');
            return false;
        }

        return true;
    }

    function validateSizes() {
        const selectedSizes = document.querySelectorAll('input[name="size"]:checked').length;
        if (selectedSizes === 0) {
            alert('Vui lòng chọn ít nhất một size cho sản phẩm!');
            return false;
        }
        return true;
    }

    function validateForm() {
        if (!validateSizes()) {
            return false;
        }
        return validateColors();
    }

    function validateCosplayFields() {
        const characterName = document.getElementById('characterName').value.trim();
        const series = document.getElementById('series').value.trim();
        const cosplayType = document.getElementById('cosplayType').value;
        const accuracyLevel = document.getElementById('accuracyLevel').value;

        if (!characterName || !series || !cosplayType || !accuracyLevel) {
            alert('Vui lòng điền đầy đủ thông tin cosplay (Tên nhân vật, Series, Loại, Mức độ hoàn thiện)!');
            return false;
        }

        return true;
    }

    function toggleCosplayFields() {
        const category = document.getElementById('category').value;
        const cosplayFields = document.getElementById('cosplayFields');
        const styleSection = document.getElementById('styleSection');
        const colorSection = document.getElementById('colorSection');
        const otherColorSection = document.getElementById('otherColorSection');
        const customColorSection = document.getElementById('customColorSection');

        if (category === 'Cosplay') {
            // Show cosplay fields
            cosplayFields.style.display = 'block';
            
            // Hide style field for cosplay
            if (styleSection) {
                styleSection.style.display = 'none';
                document.getElementById('style').removeAttribute('required');
            }
            
            // Hide color selection for cosplay
            if (colorSection) colorSection.style.display = 'none';
            if (otherColorSection) otherColorSection.style.display = 'none';
            if (customColorSection) customColorSection.style.display = 'none';
            
            // Make cosplay fields required
            document.getElementById('characterName').setAttribute('required', 'required');
            document.getElementById('series').setAttribute('required', 'required');
            document.getElementById('cosplayType').setAttribute('required', 'required');
            document.getElementById('accuracyLevel').setAttribute('required', 'required');
        } else {
            // Hide cosplay fields
            cosplayFields.style.display = 'none';
            
            // Show style field for non-cosplay
            if (styleSection) {
                styleSection.style.display = 'block';
                document.getElementById('style').setAttribute('required', 'required');
            }
            
            // Show color selection for non-cosplay
            if (colorSection) colorSection.style.display = 'block';
            if (otherColorSection) otherColorSection.style.display = 'block';
            
            // Remove required from cosplay fields
            document.getElementById('characterName').removeAttribute('required');
            document.getElementById('series').removeAttribute('required');
            document.getElementById('cosplayType').removeAttribute('required');
            document.getElementById('accuracyLevel').removeAttribute('required');
        }
    }

    // Initialize color preview on page load
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.color-swatch[data-color]').forEach(function(swatch) {
            swatch.style.backgroundColor = swatch.getAttribute('data-color');
        });
        document.querySelectorAll('.mini-swatch[data-color]').forEach(function(swatch) {
            swatch.style.backgroundColor = swatch.getAttribute('data-color');
        });
        updateColorPreview();
        toggleCosplayFields(); // Initialize cosplay fields visibility
    });
</script>
</body>
</html>
