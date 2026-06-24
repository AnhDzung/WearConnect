<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="Model.Voucher" %>
<%@ page import="java.util.List" %>

<style>
    .voucher-container {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 20px;
        margin-top: 20px;
    }
    @media (max-width: 992px) {
        .voucher-container {
            grid-template-columns: 1fr;
        }
    }
    .card {
        background: white;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        padding: 20px;
        border: 1px solid #eef2f6;
    }
    .card-title {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 15px;
        color: #1e293b;
        border-bottom: 2px solid #f1f5f9;
        padding-bottom: 10px;
    }
    .form-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 15px;
    }
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 5px;
    }
    .form-group label {
        font-weight: 500;
        font-size: 14px;
        color: #475569;
    }
    .form-group input, .form-group select {
        padding: 10px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        outline: none;
        font-size: 14px;
        background: #f8fafc;
        transition: all 0.2s;
    }
    .form-group input:focus, .form-group select:focus {
        border-color: #3b82f6;
        background: white;
        box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
    }
    .btn-submit {
        background: #2563eb;
        color: white;
        padding: 12px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s;
        margin-top: 10px;
    }
    .btn-submit:hover {
        background: #1d4ed8;
    }
    .badge {
        padding: 4px 8px;
        border-radius: 9999px;
        font-size: 12px;
        font-weight: 500;
    }
    .badge-success {
        background: #dcfce7;
        color: #15803d;
    }
    .badge-danger {
        background: #fee2e2;
        color: #b91c1c;
    }
    .btn-action {
        padding: 6px 12px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        border: none;
        transition: background 0.2s;
    }
    .btn-toggle-active {
        background: #f1f5f9;
        color: #475569;
    }
    .btn-toggle-active:hover {
        background: #e2e8f0;
    }
    .btn-delete-voucher {
        background: #fee2e2;
        color: #b91c1c;
    }
    .btn-delete-voucher:hover {
        background: #fecaca;
    }
</style>

<c:if test="${param.success eq 'true'}">
    <div style="background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; padding: 12px 16px; border-radius: 6px; margin-bottom: 20px; font-weight: 500;">
        ✓ Thao tác xử lý voucher thành công!
    </div>
</c:if>
<c:if test="${param.error eq 'true'}">
    <div style="background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; padding: 12px 16px; border-radius: 6px; margin-bottom: 20px; font-weight: 500;">
        ✗ Có lỗi xảy ra trong quá trình xử lý voucher. Vui lòng kiểm tra lại.
    </div>
</c:if>

<div class="voucher-container">
    <!-- Left: List of Vouchers -->
    <div class="card">
        <div class="card-title">Danh sách Voucher hiện có</div>
        <div class="table-container" style="overflow-x: auto;">
            <table>
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Loại giảm giá</th>
                        <th>Giá trị</th>
                        <th>Đơn tối thiểu</th>
                        <th>Giảm tối đa</th>
                        <th>Thời hạn</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        @SuppressWarnings("unchecked")
                        List<Voucher> list = (List<Voucher>) request.getAttribute("vouchers");
                        if (list != null && !list.isEmpty()) {
                            for (Voucher v : list) {
                                String typeText = "PERCENTAGE".equals(v.getDiscountType()) ? "Giảm %" : "Giảm tiền";
                                String valueText = "PERCENTAGE".equals(v.getDiscountType()) ? ((int)v.getDiscountValue() + "%") : String.format("%,.0f đ", v.getDiscountValue());
                                String minOrderText = String.format("%,.0f đ", v.getMinOrderValue());
                                String maxDiscountText = v.getMaxDiscountAmount() != null ? String.format("%,.0f đ", v.getMaxDiscountAmount()) : "Không giới hạn";
                                String dateRangeText = "";
                                if (v.getStartDate() != null && v.getEndDate() != null) {
                                    dateRangeText = v.getStartDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM")) 
                                            + " - " + v.getEndDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                                } else {
                                    dateRangeText = "Không thời hạn";
                                }
                    %>
                        <tr>
                            <td style="font-weight: 700; color: #1e3a8a;"><%= v.getVoucherCode() %></td>
                            <td><%= typeText %></td>
                            <td style="font-weight: 600;"><%= valueText %></td>
                            <td><%= minOrderText %></td>
                            <td><%= maxDiscountText %></td>
                            <td style="font-size: 13px; color: #64748b;"><%= dateRangeText %></td>
                            <td>
                                <% if (v.isActive()) { %>
                                    <span class="badge badge-success">Hoạt động</span>
                                <% } else { %>
                                    <span class="badge badge-danger">Tạm khóa</span>
                                <% } %>
                            </td>
                            <td>
                                <div style="display: flex; gap: 8px;">
                                    <form method="POST" action="<%= request.getContextPath() %>/admin" style="display:inline;">
                                        <input type="hidden" name="action" value="toggleVoucher">
                                        <input type="hidden" name="voucherID" value="<%= v.getVoucherID() %>">
                                        <input type="hidden" name="isActive" value="<%= !v.isActive() %>">
                                        <button type="submit" class="btn-action btn-toggle-active">
                                            <%= v.isActive() ? "Khóa" : "Mở" %>
                                        </button>
                                    </form>
                                    <form method="POST" action="<%= request.getContextPath() %>/admin" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa voucher này?')">
                                        <input type="hidden" name="action" value="deleteVoucher">
                                        <input type="hidden" name="voucherID" value="<%= v.getVoucherID() %>">
                                        <button type="submit" class="btn-action btn-delete-voucher">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="8" class="empty-message" style="text-align: center; padding: 20px;">Chưa có voucher nào được tạo.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add Voucher Form -->
    <div class="card">
        <div class="card-title">Thêm Voucher mới</div>
        <form method="POST" action="<%= request.getContextPath() %>/admin">
            <input type="hidden" name="action" value="addVoucher">
            <div class="form-grid">
                <div class="form-group">
                    <label for="voucherCode">Mã Voucher (viết liền, không dấu)</label>
                    <input type="text" id="voucherCode" name="voucherCode" required placeholder="Ví dụ: WELCOME100" style="text-transform: uppercase;" oninput="this.value = this.value.toUpperCase()">
                </div>
                <div class="form-group">
                    <label for="discountType">Loại giảm giá</label>
                    <select id="discountType" name="discountType" required onchange="toggleDiscountFields()">
                        <option value="PERCENTAGE">Giảm theo phần trăm (%)</option>
                        <option value="AMOUNT">Giảm số tiền cố định (đ)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="discountValue" id="valueLabel">Giá trị giảm (%)</label>
                    <input type="number" id="discountValue" name="discountValue" required min="1" placeholder="Ví dụ: 10">
                </div>
                <div class="form-group">
                    <label for="minOrderValue">Giá trị đơn tối thiểu (đ)</label>
                    <input type="number" id="minOrderValue" name="minOrderValue" value="0" min="0" placeholder="0">
                </div>
                <div class="form-group" id="maxDiscountGroup">
                    <label for="maxDiscountAmount">Mức giảm tối đa (đ)</label>
                    <input type="number" id="maxDiscountAmount" name="maxDiscountAmount" placeholder="Để trống nếu không giới hạn">
                </div>
                <div class="form-group">
                    <label for="startDate">Ngày bắt đầu áp dụng</label>
                    <input type="date" id="startDate" name="startDate">
                </div>
                <div class="form-group">
                    <label for="endDate">Ngày kết thúc áp dụng</label>
                    <input type="date" id="endDate" name="endDate">
                </div>
                <button type="submit" class="btn-submit">Tạo Voucher</button>
            </div>
        </form>
    </div>
</div>

<script>
    function toggleDiscountFields() {
        const type = document.getElementById('discountType').value;
        const valueLabel = document.getElementById('valueLabel');
        const maxDiscountGroup = document.getElementById('maxDiscountGroup');
        const discountValue = document.getElementById('discountValue');
        
        if (type === 'PERCENTAGE') {
            valueLabel.innerText = "Giá trị giảm (%)";
            discountValue.placeholder = "Ví dụ: 10";
            discountValue.max = "100";
            maxDiscountGroup.style.display = "flex";
        } else {
            valueLabel.innerText = "Số tiền giảm (đ)";
            discountValue.placeholder = "Ví dụ: 50000";
            discountValue.removeAttribute('max');
            maxDiscountGroup.style.display = "none";
            document.getElementById('maxDiscountAmount').value = "";
        }
    }
    
    window.addEventListener('DOMContentLoaded', toggleDiscountFields);
</script>
