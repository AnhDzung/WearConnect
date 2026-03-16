<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="config.BankTransferConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>Thanh toán - WearConnect</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { margin: 0; background-color: #f5f5f5; font-family: 'Inter', sans-serif; }
        h1, h2, h3, h4, h5, h6 { font-family: 'Poppins', sans-serif; }
        .container { max-width: 900px; margin: 20px auto; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        h1 { color: #333; margin-bottom: 30px; border-bottom: 3px solid #cc3399; padding-bottom: 10px; }
        h3 { color: #555; margin: 25px 0 15px 0; }
        .payment-info { background-color: #f9f9f9; padding: 20px; border-radius: 8px; margin-bottom: 30px; border-left: 4px solid #cc3399; }
        .payment-info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #e0e0e0; }
        .payment-info-row:last-child { border-bottom: none; }
        .payment-methods { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 30px; }
        .payment-method { padding: 20px; border: 2px solid #ddd; border-radius: 8px; cursor: pointer; text-align: center; }
        .payment-method:hover { border-color: #cc3399; background-color: #f5f0f5; }
        .payment-method input[type="radio"] { cursor: pointer; }
        .payment-method label { margin-bottom: 8px; cursor: pointer; font-size: 16px; margin: 0; }
        .payment-method.selected { border-color: #cc3399; background-color: #fff5fa; box-shadow: 0 0 10px rgba(204, 51, 153, 0.2); }
        .payment-details { background-color: #f0f8ff; padding: 20px; border-radius: 8px; margin: 20px 0; display: none; }
        .payment-details.show { display: block; }
        #qrCodeContainer { text-align: center; padding: 20px; background: white; border-radius: 8px; margin: 20px 0; }
        #qrCodeImage { max-width: 300px; margin: 10px auto; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; color: #333; }
        input[type="text"], input[type="email"], select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
        input[type="text"]:focus { outline: none; border-color: #cc3399; box-shadow: 0 0 5px rgba(204, 51, 153, 0.3); }
        .button-group { display: flex; gap: 10px; margin-top: 20px; }
        button { padding: 12px 24px; background-color: #cc3399; color: white; border: none; cursor: pointer; border-radius: 4px; font-weight: bold; }
        button:hover { background-color: #b8208f; }
        button.secondary { background-color: #999; }
        button.secondary:hover { background-color: #777; }
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; border-left: 4px solid; }
        .alert-error { background-color: #ffebee; border-color: #f44336; color: #d32f2f; }
        .alert-success { background-color: #e8f5e9; border-color: #4CAF50; color: #2e7d32; }
        .alert-info { background-color: #d1ecf1; border-color: #0c5460; color: #0c5460; }
        table { width: 100%; border-collapse: collapse; }
        tr { border-bottom: 1px solid #ffe0b2; }
        tr:last-child { border-bottom: none; }
        td { padding: 12px; }
        td:first-child { font-weight: bold; width: 40%; }
        .success-message { text-align: center; padding: 40px 20px; }
        .success-message .icon { font-size: 60px; margin-bottom: 20px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Thanh toán đơn hàng</h1>
    
    <!-- Success/Error Messages -->
    <c:if test="${param.proofUploaded == 'true'}">
        <div class="alert alert-success">
            <strong>Thành công!</strong> Ảnh chứng minh thanh toán đã được gửi. Vui lòng chờ admin xác thực. Trạng thái đơn hàng: <strong>ĐANG XÁC THỰC</strong>
        </div>
    </c:if>
    
    <c:if test="${param.error == 'nofile'}">
        <div class="alert alert-error">
            <strong>Lỗi!</strong> Vui lòng chọn file để upload.
        </div>
    </c:if>
    
    <c:if test="${param.error == 'invalidtype'}">
        <div class="alert alert-error">
            <strong>Lỗi!</strong> Định dạng file không hợp lệ. Vui lòng chọn JPG, PNG hoặc PDF.
        </div>
    </c:if>
    
    <c:if test="${param.error == 'toolarge'}">
        <div class="alert alert-error">
            <strong>Lỗi!</strong> File quá lớn. Kích thước tối đa: 10MB.
        </div>
    </c:if>
    
    <c:if test="${param.bankTransferPending == 'true'}">
        <div class="alert alert-info">
            <strong>Chờ xác nhận!</strong> Bạn đã gửi yêu cầu thanh toán bằng chuyển khoản. Vui lòng upload ảnh chứng minh bên dưới.
        </div>
    </c:if>
    
    <c:if test="${rentalOrder == null}">
        <div class="alert alert-error">
            <strong>Lỗi!</strong> Không tìm thấy đơn hàng.
        </div>
        <div class="button-group">
            <button type="button" onclick="window.location.href = '${pageContext.request.contextPath}/rental'">Quay lại</button>
        </div>
    </c:if>
    
    <c:if test="${rentalOrder != null}">
        <div class="payment-info">
            <div class="payment-info-row">
                <strong>Mã đơn hàng:</strong>
                <span>WRC<fmt:formatNumber value="${rentalOrderID}" pattern="00000"/></span>
            </div>
            <div class="payment-info-row">
                <strong>Tiền thuê:</strong>
                <span style="color: #333; font-weight: bold;">
                    <fmt:formatNumber value="${rentalOrder.totalPrice}" pattern="#,##0"/> VNĐ
                </span>
            </div>
            
            <!-- Tiền cọc chi tiết -->
            <c:choose>
                <c:when test="${not empty rentalOrder.trustBasedMultiplier and rentalOrder.trustBasedMultiplier > 0 and rentalOrder.trustBasedMultiplier < 1.0}">
                    <c:set var="baseDeposit" value="${rentalOrder.adjustedDepositAmount / rentalOrder.trustBasedMultiplier}" />
                    <div class="payment-info-row">
                        <strong>Tiền cọc gốc:</strong>
                        <span style="color: #999; font-weight: bold; text-decoration: line-through;">
                            <fmt:formatNumber value="${baseDeposit}" pattern="#,##0"/> VNĐ
                        </span>
                    </div>
                    <div class="payment-info-row" style="background-color: #e8f5e9; padding: 8px; border-radius: 4px;">
                        <strong style="color: #2e7d32;">Vourcher đặc biệt:</strong>
                        <span style="color: #2e7d32; font-weight: bold;">
                            -<fmt:formatNumber value="${baseDeposit - rentalOrder.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                        </span>
                    </div>
                    <div class="payment-info-row">
                        <strong>Tiền cọc chính thức:</strong>
                        <span style="color: #2e7d32; font-weight: bold; font-size: 16px;">
                            <fmt:formatNumber value="${rentalOrder.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                        </span>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="payment-info-row">
                        <strong>Tiền cọc:</strong>
                        <span style="color: #333; font-weight: bold;">
                            <fmt:formatNumber value="${rentalOrder.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                        </span>
                    </div>
                </c:otherwise>
            </c:choose>
            <div class="payment-info-row" style="background-color: #fff5fa; padding: 12px; border-radius: 4px; border-top: 2px solid #cc3399; border-bottom: 2px solid #cc3399;">
                <strong style="font-size: 18px;">Tổng tiền phải thanh toán:</strong>
                <span id="totalAmount" data-amount="${ rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount}" style="color: #cc3399; font-weight: bold; font-size: 18px;">
                    <fmt:formatNumber value="${rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                </span>
            </div>
            <c:if test="${not empty userBadge and userBadge.discount != null}">
                <div class="payment-info-row">
                    <strong>Huy hiệu:</strong>
                    <span style="color:#333">${userBadge.badge} — Giảm ${userBadge.discount}%</span>
                </div>
                <div class="payment-info-row">
                    <strong>Tiền sau giảm:</strong>
                    <span style="color: #28a745; font-weight: bold; font-size: 18px;">
                        <fmt:formatNumber value="${(rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount) * (1 - (userBadge.discount/100))}" pattern="#,##0"/> VNĐ
                    </span>
                </div>
            </c:if>
        </div>
        
        <c:if test="${payment == null || payment.paymentStatus == 'PENDING'}">
            <form method="POST" action="${pageContext.request.contextPath}/payment" id="paymentForm" enctype="multipart/form-data">
                <input type="hidden" name="action" value="processPayment">
                <input type="hidden" name="rentalOrderID" value="${rentalOrderID}">
                
                <h3>🛒 Chọn phương thức thanh toán</h3>
                
                <div class="payment-methods">
                    <div class="payment-method" onclick="selectPaymentMethod('BANK_TRANSFER', this)">
                        <input type="radio" name="paymentMethod" value="BANK_TRANSFER" id="bankTransfer">
                        <label for="bankTransfer">🏦 <strong>Chuyển Khoản</strong>
                            <div style="font-size: 12px; color: #999; margin-top: 5px;">Áp dụng với tất cả ngân hàng</div>
                        </label>
                    </div>
                    
                    <div class="payment-method" onclick="selectPaymentMethod('CREDIT_CARD', this)">
                        <input type="radio" name="paymentMethod" value="CREDIT_CARD" id="creditCard">
                        <label for="creditCard"><strong>Thẻ Visa/MasterCard</strong>
                            <div style="font-size: 12px; color: #999; margin-top: 5px;">Thanh toán trực tuyến</div>
                        </label>
                    </div>
                </div>
                
                <div id="bankTransferDetails" class="payment-details">
                    <h3>🏦 Thông tin chuyển khoản </h3>
                    
                    <div id="qrCodeContainer">
                        <p>📱 Mã QR thanh toán:</p>
                        <img src="${pageContext.request.contextPath}/assets/images/bank-qr-code.PNG" alt="QR Code thanh toán" style="max-width: 300px; border: 2px solid #ddd; border-radius: 8px; padding: 10px; background: white;">
                        <p style="color: #666; font-size: 12px; margin-top: 10px;">Quét mã QR để chuyển khoản nhanh</p>
                    </div>
                    
                    <table style="margin: 20px 0; background: #fffbf0; padding: 0; border-radius: 8px;">
                        <tr>
                            <td style="border: 1px solid #ffe0b2;">Ngân hàng:</td>
                            <td style="border: 1px solid #ffe0b2; color: #ff6f00;"><%= BankTransferConfig.BANK_NAME %></td>
                        </tr>
                        <tr>
                            <td style="border: 1px solid #ffe0b2;">Số tài khoản:</td>
                            <td style="border: 1px solid #ffe0b2; color: #ff6f00; font-family: 'Inter', sans-serif;"><%= BankTransferConfig.BANK_ACCOUNT_NUMBER %></td>
                        </tr>
                        <tr>
                            <td style="border: 1px solid #ffe0b2;">Chủ tài khoản:</td>
                            <td style="border: 1px solid #ffe0b2; color: #ff6f00;"><%= BankTransferConfig.ACCOUNT_HOLDER_NAME %></td>
                        </tr>
                        <tr>
                            <td style="border: 1px solid #ffe0b2;">Chi nhánh:</td>
                            <td style="border: 1px solid #ffe0b2; color: #ff6f00;"><%= BankTransferConfig.BRANCH %></td>
                        </tr>
                        <tr>
                            <td style="border: 1px solid #ffe0b2;">Số tiền:</td>
                            <td style="border: 1px solid #ffe0b2; color: #ff6f00; font-weight: bold; font-size: 16px;">
                                <c:choose>
                                    <c:when test="${not empty userBadge and userBadge.discount != null}">
                                        <fmt:formatNumber value="${(rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount) * (1 - (userBadge.discount/100))}" pattern="#,##0"/> VNĐ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <td style="border: 1px solid #ffe0b2;">Nội dung:</td>
                            <td style="border: 1px solid #ffe0b2; color: #ff6f00; font-family: 'Inter', sans-serif;">WRC<fmt:formatNumber value="${rentalOrderID}" pattern="00000"/></td>
                        </tr>
                    </table>
                    
                    <div class="alert alert-info">
                        Vui lòng chuyển khoản CHÍNH XÁC số tiền và nội dung<br>
                        Thời gian xác nhận: tối đa 5 phút hoặc lâu hơn tùy ngân hàng
                    </div>
                    
                    <!-- Upload Payment Proof -->
                    <div style="margin-top: 30px; padding: 20px; background: #f5f5f5; border-radius: 8px; border: 2px solid #4CAF50;">
                        <h4 style="color: #2e7d32; margin-top: 0;">Cung Cấp Ảnh Chứng Minh Thanh Toán</h4>
                        <p style="margin: 10px 0; color: #666; font-size: 14px;">
                            Chụp ảnh hoặc chụp màn hình biên lai chuyển khoản từ ngân hàng<br>
                            Ảnh phải hiển thị rõ: số tiền, nội dung, thời gian, tài khoản nhận<br>
                            Sau khi chọn ảnh, nhấn nút <strong>"Thanh toán"</strong> bên dưới
                        </p>
                        <div class="form-group">
                            <label for="paymentProof" style="color: #2e7d32; font-weight: bold;">Chọn ảnh chứng minh:</label>
                            <input type="file" id="paymentProof" name="paymentProof" accept="image/jpeg,image/png,application/pdf" style="padding: 12px; border: 2px dashed #4CAF50; border-radius: 4px; cursor: pointer;">
                            <small style="display: block; margin-top: 8px; color: #999;">
                                Định dạng: JPG, PNG, PDF<br>
                                Kích thước tối đa: 10MB
                            </small>
                        </div>
                        
                        <!-- Image Preview -->
                        <div id="imagePreviewContainer" style="margin-top: 15px; display: none;">
                            <p style="font-weight: bold; color: #333;">Ảnh xem trước:</p>
                            <img id="imagePreview" src="" alt="Preview" style="max-width: 300px; border-radius: 8px; border: 2px solid #4CAF50;">
                        </div>
                    </div>
                </div>
                
                <div id="creditCardDetails" class="payment-details">
                    <h3>Thanh Toán Bằng Thẻ Visa/MasterCard</h3>
                    <p><strong>Số tiền:</strong> 
                        <c:choose>
                            <c:when test="${not empty userBadge and userBadge.discount != null}">
                                <fmt:formatNumber value="${(rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount) * (1 - (userBadge.discount/100))}" pattern="#,##0"/> VNĐ
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${rentalOrder.totalPrice + rentalOrder.adjustedDepositAmount}" pattern="#,##0"/> VNĐ
                            </c:otherwise>
                        </c:choose>
                    </p>
                    
                    <div class="form-group">
                        <label>Tên chủ thẻ:</label>
                        <input type="text" id="cardHolder" placeholder="VD: NGUYEN VAN A" style="text-transform: uppercase;">
                    </div>
                    
                    <div class="form-group">
                        <label>Số thẻ:</label>
                        <input type="text" id="cardNumber" placeholder="0000 0000 0000 0000" maxlength="19" oninput="formatCardNumber(this)">
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div class="form-group">
                            <label>Ngày hết hạn (MM/YY):</label>
                            <input type="text" id="expiryDate" placeholder="MM/YY" maxlength="5" oninput="formatExpiryDate(this)">
                        </div>
                        <div class="form-group">
                            <label>CVV:</label>
                            <input type="text" id="cvv" placeholder="000" maxlength="3" oninput="this.value = this.value.replace(/[^0-9]/g, '')">
                        </div>
                    </div>
                </div>
                
                <div class="button-group">
                    <button type="submit" onclick="return validatePaymentMethod()">Thanh toán</button>
                    <button type="button" class="secondary" onclick="history.back()">Quay lại</button>
                </div>
            </form>
        </c:if>
        
        <c:if test="${payment != null && payment.paymentStatus == 'COMPLETED'}">
            <div class="success-message">
                <div class="alert alert-success">
                    <strong>Thanh toán thành công!</strong> Đơn hàng đã được xác nhận.
                </div>
                <div class="button-group">
                    <button type="button" onclick="window.location.href = '${pageContext.request.contextPath}/rental'">Đế danh sách đơn</button>
                </div>
            </div>
        </c:if>
        
        <c:if test="${payment != null && payment.paymentStatus == 'FAILED'}">
            <div class="alert alert-error">
                <strong>Thanh toán thất bại!</strong> Vui lòng thử lại.
            </div>
            <div class="button-group">
                <button type="button" onclick="location.reload()">Thử lại</button>
                <button type="button" class="secondary" onclick="history.back()">Quay lại</button>
            </div>
        </c:if>
    </c:if>
</div>

<script>
    function selectPaymentMethod(method, element) {
        document.querySelectorAll('.payment-method').forEach(e => e.classList.remove('selected'));
        element.classList.add('selected');
        
        const radioId = method === 'BANK_TRANSFER' ? 'bankTransfer' : 'creditCard';
        document.getElementById(radioId).checked = true;
        
        const bankDetails = document.getElementById('bankTransferDetails');
        const cardDetails = document.getElementById('creditCardDetails');
        
        if (method === 'BANK_TRANSFER') {
            bankDetails.classList.add('show');
            cardDetails.classList.remove('show');
        } else {
            bankDetails.classList.remove('show');
            cardDetails.classList.add('show');
        }
    }
    
    function formatCardNumber(input) {
        const value = input.value.replace(/\s/g, '');
        const formatted = value.replace(/(\d{4})/g, '$1 ').trim();
        input.value = formatted;
    }
    
    function formatExpiryDate(input) {
        const value = input.value.replace(/\D/g, '');
        if (value.length >= 2) {
            input.value = value.slice(0, 2) + '/' + value.slice(2, 4);
        } else {
            input.value = value;
        }
    }
    
    function validatePaymentMethod() {
        const bankTransferCheck = document.getElementById('bankTransfer')?.checked;
        const creditCardCheck = document.getElementById('creditCard')?.checked;
        
        if (!bankTransferCheck && !creditCardCheck) {
            alert('Vui lòng chọn phương thức thanh toán');
            return false;
        }
        
        // Check if bank transfer with uploaded file
        if (bankTransferCheck) {
            const fileInput = document.getElementById('paymentProof');
            if (fileInput && fileInput.files && fileInput.files.length > 0) {
                // User uploaded payment proof - show confirmation message
                // Let form submit, server will handle redirect
                return true;
            } else {
                // No file uploaded for bank transfer
                if (!confirm('Bạn chưa tải ảnh chứng minh lên. Bạn có muốn tiếp tục không?')) {
                    return false;
                }
            }
            return true;
        }
        
        if (creditCardCheck) {
            const cardHolder = document.getElementById('cardHolder').value.trim();
            const cardNumber = document.getElementById('cardNumber').value.trim();
            const expiryDate = document.getElementById('expiryDate').value.trim();
            const cvv = document.getElementById('cvv').value.trim();
            
            if (!cardHolder || !cardNumber || !expiryDate || !cvv) {
                alert('Vui lòng điền đầy đủ thông tin thẻ');
                return false;
            }
            
            if (cardNumber.replace(/\s/g, '').length !== 16) {
                alert('Số thẻ không hợp lệ (phải 16 chữ số)');
                return false;
            }
            
            if (cvv.length !== 3) {
                alert('CVV không hợp lệ (phải 3 chữ số)');
                return false;
            }
        }
        return true;
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
            radio.addEventListener('change', function() {
                selectPaymentMethod(this.value, this.closest('.payment-method'));
            });
        });
        
        // Auto-select BANK_TRANSFER
        const bankRadio = document.getElementById('bankTransfer');
        if (bankRadio) {
            const wrapper = bankRadio.closest('.payment-method');
            if (wrapper) {
                selectPaymentMethod('BANK_TRANSFER', wrapper);
            }
        }
        
        // Image preview for payment proof
        const paymentProofInput = document.getElementById('paymentProof');
        if (paymentProofInput) {
            paymentProofInput.addEventListener('change', function(e) {
                const file = e.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(event) {
                        const preview = document.getElementById('imagePreview');
                        const container = document.getElementById('imagePreviewContainer');
                        preview.src = event.target.result;
                        container.style.display = 'block';
                    };
                    reader.readAsDataURL(file);
                }
            });
        }
    });
</script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
