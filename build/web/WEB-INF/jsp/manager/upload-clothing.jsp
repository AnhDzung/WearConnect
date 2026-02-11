<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Color" %>
<%@ page import="DAO.ColorDAO" %>
<%
    int managerID = (session != null && session.getAttribute("accountID") != null) 
        ? (int) session.getAttribute("accountID") 
        : -1;
    List<Color> availableColors = ColorDAO.getColorsByManager(managerID);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng tải quần áo - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { margin: 0; background-color: #f5f5f5; }
        .form-container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; background: white; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { padding: 10px 20px; background-color: #28a745; color: white; border: none; cursor: pointer; margin-right: 10px; }
        .color-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 10px; margin-bottom: 15px; }
        .color-option { padding: 10px; border: 2px solid #ddd; border-radius: 4px; cursor: pointer; text-align: center; transition: all 0.3s; }
        .color-option:hover { border-color: #28a745; background-color: #f0f0f0; }
        .color-option input[type="checkbox"] { display: block; margin: 5px auto; cursor: pointer; }
        .color-swatch { width: 100%; height: 30px; border-radius: 3px; margin-bottom: 5px; }
        .custom-color-section { margin-top: 15px; padding: 15px; background-color: #f9f9f9; border: 1px solid #ddd; border-radius: 4px; }
        .custom-color-section input { margin-top: 10px; }
        .color-preview { display: inline-block; width: 20px; height: 20px; border-radius: 3px; border: 1px solid #ddd; margin-right: 8px; vertical-align: middle; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="form-container">
    <h1>Đăng tải quần áo</h1>
    
    <form method="POST" action="${pageContext.request.contextPath}/clothing" enctype="multipart/form-data" onsubmit="validateColors()">
        <input type="hidden" name="action" value="upload">
        
        <div class="form-group">
            <label for="clothingName">Tên quần áo:</label>
            <input type="text" id="clothingName" name="clothingName" required>
        </div>
        
        <div class="form-group">
            <label for="category">Danh mục:</label>
            <select id="category" name="category" required>
                <option value="">-- Chọn danh mục --</option>
                <option value="Váy">Váy</option>
                <option value="Áo dài">Áo dài</option>
                <option value="Áo">Áo</option>
                <option value="Quần">Quần</option>
                <option value="Áo khoác">Áo khoác</option>
                <option value="Set">Set cả quần và áo</option>
                <option value="Cosplay">Cosplay</option>
                <option value="Phụ kiện">Phụ kiện</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="style">Phong cách:</label>
            <select id="style" name="style" required>
                <option value="">-- Chọn phong cách --</option>
                <option value="Thường ngày">Thường ngày</option>
                <option value="Trang trọng">Trang trọng</option>
                <option value="Dự tiệc">Dự tiệc</option>
                <option value="Thể thao">Thể thao</option>
                <option value="Cổ điển">Cổ điển</option>
                <option value="Vintage">Vintage</option>
                <option value="Streetwear">Streetwear</option>
                <option value="Sexy">Sexy</option>
                <option value="Minimalist">Minimalist</option>
            </select>
        </div>

        <div class="form-group">
            <label for="occasion">Mục đích sử dụng:</label>
            <select id="occasion" name="occasion" required>
                <option value="">-- Chọn mục đích --</option>
                <option value="Tiệc cưới">Dự Tiệc</option>
                <option value="Tốt nghiệp">Tốt nghiệp</option>
                <option value="Fes / Cosplay">Fes / Cosplay</option>
                <option value="Chụp ảnh">Chụp ảnh</option>
                <option value="Biểu diễn">Biểu diễn</option>
                <option value="Hẹn hò">Hẹn hò</option>
                <option value="Du lịch">Du lịch</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="size">Size:</label>
            <select id="size" name="size" required>
                <option value="XS">XS</option>
                <option value="S">S</option>
                <option value="M">M</option>
                <option value="L">L</option>
                <option value="XL">XL</option>
                <option value="XXL">XXL</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="quantity">Số lượng:</label>
            <input type="number" id="quantity" name="quantity" min="1" max="1000" value="1" required>
            <small style="color: #666; display: block; margin-top: 5px;">Số lượng sản phẩm cùng loại có sẵn để cho thuê</small>
        </div>
        
        <div class="form-group">
            <label for="description">Mô tả:</label>
            <textarea id="description" name="description" rows="4" required></textarea>
        </div>
        
        <div class="form-group">
            <label for="hourlyPrice">Giá thuê/giờ (VNĐ):</label>
            <input type="number" id="hourlyPrice" name="hourlyPrice" step="0.01" min="10000" max="99999999.99" required>
            <small style="color: #666; display: block; margin-top: 5px;">Giá tối thiểu: 10.000 VNĐ</small>
        </div>
        
        <div class="form-group">
            <label for="dailyPrice">Giá thuê/ngày (VNĐ):</label>
            <input type="number" id="dailyPrice" name="dailyPrice" step="0.01" min="10000" max="99999999.99" required>
            <small style="color: #666; display: block; margin-top: 5px;">Giá tối thiểu: 10.000 VNĐ</small>
        </div>
        
        <div class="form-group">
            <label for="depositAmount">Tiền đặt cọc (VNĐ):</label>
            <input type="number" id="depositAmount" name="depositAmount" step="0.01" min="0" max="99999999.99" required>
            <small style="color: #666; display: block; margin-top: 5px;">Đặt cọc tối thiểu người dùng phải trả khi đặt thuê. Người dùng sẽ thanh toán 100% tổng tiền.</small>
        </div>

        <div class="form-group">
            <label>Màu sắc hiện có:</label>
            <div class="color-grid">
                <%
                    for (Color color : availableColors) {
                        String colorClass = color.getManagerID() != null && color.getManagerID() == managerID ? "manager-custom" : "global";
                %>
                <div class="color-option">
                    <div class="color-swatch" style="background-color: <%= color.getHexCode() != null ? color.getHexCode() : "#ccc" %>;" title="<%= color.getColorName() %>"></div>
                    <label>
                        <input type="checkbox" name="colors" value="<%= color.getColorID() %>" class="color-checkbox <%= colorClass %>">
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
                Màu khác (không có trong danh sách)
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
        </div>

        <div class="form-group">
            <label for="images">Tải ảnh lên:</label>
            <input type="file" id="images" name="images" accept="image/*" multiple required>
            <small style="color: #666; display: block; margin-top: 5px;">Chọn nhiều ảnh, ảnh đầu tiên sẽ làm ảnh chính.</small>
        </div>
        
        <div class="form-group">
            <label for="availableFrom">Có sẵn từ:</label>
            <input type="datetime-local" id="availableFrom" name="availableFrom" required>
        </div>
        
        <div class="form-group">
            <label for="availableTo">Đến:</label>
            <input type="datetime-local" id="availableTo" name="availableTo" required>
        </div>
        
        <button type="submit">Đăng tải</button>
        <button type="button" onclick="history.back()">Quay lại</button>
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
