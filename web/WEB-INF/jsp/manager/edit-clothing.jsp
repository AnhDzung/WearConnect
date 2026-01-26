<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Color" %>
<%@ page import="DAO.ColorDAO" %>
<%
    int managerID = (session != null && session.getAttribute("accountID") != null) 
        ? (int) session.getAttribute("accountID") 
        : -1;
    
    int clothingID = 0;
    try {
        Object clothing = pageContext.getAttribute("clothing", PageContext.PAGE_SCOPE);
        if (clothing != null && clothing instanceof Model.Clothing) {
            clothingID = ((Model.Clothing) clothing).getClothingID();
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
        body { margin: 0; background-color: #f5f5f5; }
        .form-container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { padding: 10px 20px; background-color: #28a745; color: white; border: none; cursor: pointer; margin-right: 10px; border-radius: 4px; }
        button:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; }
        .btn-cancel:hover { background-color: #5a6268; }
        .current-image { margin-bottom: 15px; }
        .current-image img { max-width: 200px; max-height: 200px; border-radius: 4px; }
        .color-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 10px; margin-bottom: 15px; }
        .color-option { padding: 10px; border: 2px solid #ddd; border-radius: 4px; cursor: pointer; text-align: center; transition: all 0.3s; }
        .color-option:hover { border-color: #28a745; background-color: #f0f0f0; }
        .color-option input[type="checkbox"] { display: block; margin: 5px auto; cursor: pointer; }
        .color-swatch { width: 100%; height: 30px; border-radius: 3px; margin-bottom: 5px; }
        .current-colors { margin: 10px 0; padding: 10px; background-color: #f9f9f9; border: 1px solid #ddd; border-radius: 4px; }
        .color-tag { display: inline-block; background-color: #28a745; color: white; padding: 5px 10px; border-radius: 3px; margin: 5px 5px 5px 0; }
        .custom-color-section { margin-top: 15px; padding: 15px; background-color: #f9f9f9; border: 1px solid #ddd; border-radius: 4px; }
        .custom-color-section input { margin-top: 10px; }
        .color-preview { display: inline-block; width: 20px; height: 20px; border-radius: 3px; border: 1px solid #ddd; margin-right: 8px; vertical-align: middle; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="form-container">
    <h1>Chỉnh Sửa Quần Áo</h1>
    
    <form method="POST" action="${pageContext.request.contextPath}/clothing" enctype="multipart/form-data" onsubmit="validateColors()">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="clothingID" value="${clothing.clothingID}">
        
        <div class="form-group">
            <label for="clothingName">Tên quần áo:</label>
            <input type="text" id="clothingName" name="clothingName" value="${clothing.clothingName}" required>
        </div>
        
        <div class="form-group">
            <label for="category">Danh mục:</label>
            <select id="category" name="category" required>
                <option value="">-- Chọn danh mục --</option>
                <option value="Dress" <c:if test="${clothing.category == 'Dress'}">selected</c:if>>Váy</option>
                <option value="Shirt" <c:if test="${clothing.category == 'Shirt'}">selected</c:if>>Áo sơ mi</option>
                <option value="Pants" <c:if test="${clothing.category == 'Pants'}">selected</c:if>>Quần</option>
                <option value="Jacket" <c:if test="${clothing.category == 'Jacket'}">selected</c:if>>Áo khoác</option>
                <option value="Accessories" <c:if test="${clothing.category == 'Accessories'}">selected</c:if>>Phụ kiện</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="style">Phong cách:</label>
            <select id="style" name="style" required>
                <option value="">-- Chọn phong cách --</option>
                <option value="Casual" <c:if test="${clothing.style == 'Casual'}">selected</c:if>>Thường ngày</option>
                <option value="Formal" <c:if test="${clothing.style == 'Formal'}">selected</c:if>>Trang trọng</option>
                <option value="Party" <c:if test="${clothing.style == 'Party'}">selected</c:if>>Dự tiệc</option>
                <option value="Sport" <c:if test="${clothing.style == 'Sport'}">selected</c:if>>Thể thao</option>
                <option value="Vintage" <c:if test="${clothing.style == 'Vintage'}">selected</c:if>>Cổ điển</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="size">Size:</label>
            <select id="size" name="size" required>
                <option value="XS" <c:if test="${clothing.size == 'XS'}">selected</c:if>>XS</option>
                <option value="S" <c:if test="${clothing.size == 'S'}">selected</c:if>>S</option>
                <option value="M" <c:if test="${clothing.size == 'M'}">selected</c:if>>M</option>
                <option value="L" <c:if test="${clothing.size == 'L'}">selected</c:if>>L</option>
                <option value="XL" <c:if test="${clothing.size == 'XL'}">selected</c:if>>XL</option>
                <option value="XXL" <c:if test="${clothing.size == 'XXL'}">selected</c:if>>XXL</option>
            </select>
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
                    <c:when test="${clothing.dailyPrice > 0}"><fmt:formatNumber value="${clothing.dailyPrice}" pattern="#,##0"/></c:when>
                    <c:otherwise><fmt:formatNumber value="${clothing.hourlyPrice * 24}" pattern="#,##0"/></c:otherwise>
                </c:choose>
            </c:set>
            <input type="number" id="dailyPrice" name="dailyPrice" step="0.01" min="10000" max="99999999.99" value="${dailyPriceValue}" required>
            <small style="color: #666; display: block; margin-top: 5px;">Giá tối thiểu: 10.000 VNĐ</small>
        </div>
        
        <div class="form-group">
            <label for="depositAmount">Tiền đặt cọc (VNĐ):</label>
            <input type="number" id="depositAmount" name="depositAmount" step="0.01" min="0" max="99999999.99" 
                   value="<fmt:formatNumber value='${clothing.depositAmount > 0 ? clothing.depositAmount : clothing.hourlyPrice * 24 * 0.2}' pattern='#,##0'/>" required>
            <small style="color: #666; display: block; margin-top: 5px;">Đặt cọc tối thiểu người dùng phải trả khi đặt thuê. Người dùng sẽ thanh toán 100% tổng tiền.</small>
        </div>

        <!-- Chỉnh sửa màu sắc -->
        <div class="form-group">
            <label>Màu sắc hiện tại:</label>
            <div class="current-colors">
                <% if (clothingColors.isEmpty()) { %>
                    <em style="color: #999;">Chưa có màu nào được chọn</em>
                <% } else { %>
                    <% for (Color color : clothingColors) { %>
                        <span class="color-tag">
                            <span class="color-swatch" style="background-color: <%= color.getHexCode() != null ? color.getHexCode() : "#ccc" %>; display: inline-block; width: 16px; height: 16px; margin-right: 5px; border-radius: 2px;"></span>
                            <%= color.getColorName() %>
                        </span>
                    <% } %>
                <% } %>
            </div>
        </div>

        <div class="form-group">
            <label>Cập nhật màu sắc:</label>
            <div class="color-grid">
                <%
                    for (Color color : availableColors) {
                        String colorClass = color.getManagerID() != null && color.getManagerID() == managerID ? "manager-custom" : "global";
                        boolean isSelected = false;
                        for (Color selected : clothingColors) {
                            if (selected.getColorID() == color.getColorID()) {
                                isSelected = true;
                                break;
                            }
                        }
                %>
                <div class="color-option">
                    <div class="color-swatch" style="background-color: <%= color.getHexCode() != null ? color.getHexCode() : "#ccc" %>;" title="<%= color.getColorName() %>"></div>
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

        <div class="form-group">
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
            <div style="margin-top: 10px; padding: 10px; background-color: white; border: 1px solid #ddd; border-radius: 4px;">
                <span>Màu mẫu:</span>
                <div class="color-swatch" id="colorPreview" style="background-color: #CCCCCC; height: 50px; margin-top: 10px;"></div>
            </div>
            <small style="color: #666; display: block; margin-top: 10px;">Màu mới sẽ được thêm vào danh sách của bạn. Nếu manager khác nhập cùng tên màu, sẽ sử dụng màu bạn đã tạo.</small>
        </div>
        
        <div class="form-group">
            <label>Hình ảnh hiện tại:</label>
            <div class="current-image">
                <img src="${pageContext.request.contextPath}/image?id=${clothing.clothingID}" alt="${clothing.clothingName}">
            </div>
        </div>
        
        <div class="form-group">
            <label for="images">Thêm hình ảnh mới (có thể chọn nhiều):</label>
            <input type="file" id="images" name="images" accept="image/*" multiple>
            <small style="color: #999;">Để trống nếu không thêm ảnh mới. Ảnh đầu tiên tải lên sẽ trở thành ảnh chính.</small>
        </div>
        
        <div class="form-group">
            <label for="availableFrom">Có sẵn từ:</label>
            <input type="datetime-local" id="availableFrom" name="availableFrom" value="${clothing.availableFrom}" required>
        </div>
        
        <div class="form-group">
            <label for="availableTo">Đến:</label>
            <input type="datetime-local" id="availableTo" name="availableTo" value="${clothing.availableTo}" required>
        </div>
        
        <div class="form-group">
            <button type="submit">Cập nhật</button>
            <button type="button" class="btn-cancel" onclick="history.back()">Hủy</button>
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

    // Initialize color preview on page load
    document.addEventListener('DOMContentLoaded', function() {
        updateColorPreview();
    });
</script>
</body>
</html>
