<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Hồ sơ cá nhân - WearConnect</title>
    <style>
        body { margin: 0; background: #f5f5f5; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .container { max-width: 900px; margin: 20px auto 40px; padding: 0 20px; }
        .profile-card { background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); padding: 24px; }
        .profile-header { display: flex; align-items: center; gap: 15px; margin-bottom: 20px; }
        .avatar { width: 64px; height: 64px; border-radius: 50%; background: linear-gradient(135deg, #667eea, #764ba2); color: white; display: flex; align-items: center; justify-content: center; font-size: 26px; font-weight: 700; }
        .name { font-size: 22px; font-weight: 700; margin: 0; }
        .role { display: inline-block; padding: 6px 12px; border-radius: 999px; background: #fef3c7; color: #92400e; font-weight: 600; font-size: 12px; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; margin-top: 10px; }
        .info-item { background: #fafafa; border: 1px solid #eee; border-radius: 8px; padding: 12px 14px; }
        .label { font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 0.4px; }
        .value { font-size: 15px; color: #111; margin-top: 4px; word-break: break-word; }
        .actions { margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap; }
        .btn { padding: 10px 16px; border: none; border-radius: 6px; cursor: pointer; font-weight: 600; }
        .btn-edit { background: #667eea; color: white; }
        .btn-back { background: #e5e7eb; color: #111; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: white; padding: 30px; border-radius: 10px; max-width: 500px; width: 90%; }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-header h2 { margin: 0; font-size: 20px; }
        .close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #999; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #333; font-size: 14px; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; box-sizing: border-box; }
        .modal-buttons { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .btn-submit { background: #667eea; color: white; padding: 10px 20px; }
        .btn-cancel { background: #e5e7eb; color: #111; padding: 10px 20px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<%
    Model.Account manager = (Model.Account) session.getAttribute("account");
    if (manager == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String displayName = (manager.getFullName() != null && !manager.getFullName().trim().isEmpty()) ? manager.getFullName() : manager.getUsername();
%>

<div class="container">
    <c:if test="${param.success == 'true'}">
        <div style="background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            Cập nhật thông tin thành công!
        </div>
    </c:if>
    <c:if test="${param.pwdSuccess == 'true'}">
        <div style="background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            Đổi mật khẩu thành công!
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Có lỗi xảy ra. Vui lòng thử lại.
        </div>
    </c:if>
    <c:if test="${param.pwdError == 'empty'}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Vui lòng nhập đủ thông tin mật khẩu.
        </div>
    </c:if>
    <c:if test="${param.pwdError == 'notmatch'}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Mật khẩu mới không khớp!
        </div>
    </c:if>
    <c:if test="${param.pwdError == 'short'}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Mật khẩu mới phải có ít nhất 6 ký tự.
        </div>
    </c:if>
    <c:if test="${param.pwdError == 'wrongold'}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Mật khẩu hiện tại không chính xác.
        </div>
    </c:if>
    <c:if test="${param.pwdError == 'update'}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Cập nhật mật khẩu thất bại. Vui lòng thử lại.
        </div>
    </c:if>
    <c:if test="${param.pwdError == 'exception'}">
        <div style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;">
            ✗ Có lỗi xảy ra khi đổi mật khẩu. Vui lòng liên hệ hỗ trợ.
        </div>
    </c:if>
    <div class="profile-card">
        <div class="profile-header">
            <div class="avatar"><%= displayName.substring(0,1).toUpperCase() %></div>
            <div>
                <p class="name"><%= displayName %></p>
                <span class="role"><%= manager.getUserRole() %></span>
            </div>
        </div>
        <div class="info-grid">
            <div class="info-item">
                <div class="label">Tên đăng nhập</div>
                <div class="value"><%= manager.getUsername() %></div>
            </div>
            <div class="info-item">
                <div class="label">Họ và tên</div>
                <div class="value"><%= (manager.getFullName() != null) ? manager.getFullName() : "" %></div>
            </div>
            <div class="info-item">
                <div class="label">Email</div>
                <div class="value"><%= (manager.getEmail() != null) ? manager.getEmail() : "" %></div>
            </div>
            <div class="info-item">
                <div class="label">Số điện thoại</div>
                <div class="value"><%= (manager.getPhoneNumber() != null) ? manager.getPhoneNumber() : "" %></div>
            </div>
            <div class="info-item">
                <div class="label">Địa chỉ</div>
                <div class="value"><%= (manager.getAddress() != null) ? manager.getAddress() : "" %></div>
            </div>
        </div>
        <div class="actions">
            <button class="btn btn-edit" onclick="openEditModal()">Chỉnh sửa thông tin</button>
            <button class="btn btn-edit" style="background: #10b981;" onclick="openChangePasswordModal()">🔐 Đổi mật khẩu</button>
            <button class="btn btn-back" onclick="history.back()">Quay lại</button>
        </div>
    </div>
</div>

    <!-- Edit Profile Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Chỉnh sửa thông tin</h2>
                <button class="close-btn" onclick="closeEditModal()">&times;</button>
            </div>
            <form id="editForm" method="POST" action="${pageContext.request.contextPath}/manager?action=updateProfile">
                <div class="form-group">
                    <label for="fullName">Họ và tên *</label>
                    <input type="text" id="fullName" name="fullName" value="<%= (manager.getFullName() != null) ? manager.getFullName() : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" value="<%= (manager.getEmail() != null) ? manager.getEmail() : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="phoneNumber">Số điện thoại</label>
                    <input type="text" id="phoneNumber" name="phoneNumber" value="<%= (manager.getPhoneNumber() != null) ? manager.getPhoneNumber() : "" %>">
                </div>
                <div class="form-group">
                    <label for="address">Địa chỉ</label>
                    <input type="text" id="address" name="address" value="<%= (manager.getAddress() != null) ? manager.getAddress() : "" %>">
                </div>
                <div class="modal-buttons">
                    <button type="button" class="btn btn-cancel" onclick="closeEditModal()">Hủy</button>
                    <button type="submit" class="btn btn-submit">Cập nhật</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div id="changePasswordModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Đổi mật khẩu</h2>
                <button class="close-btn" onclick="closeChangePasswordModal()">&times;</button>
            </div>
            <form id="changePasswordForm" method="POST" action="${pageContext.request.contextPath}/manager?action=changePassword">
                <div class="form-group">
                    <label for="oldPassword">Mật khẩu hiện tại *</label>
                    <input type="password" id="oldPassword" name="oldPassword" required>
                </div>
                <div class="form-group">
                    <label for="newPassword">Mật khẩu mới *</label>
                    <input type="password" id="newPassword" name="newPassword" required minlength="6">
                </div>
                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu mới *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required minlength="6">
                </div>
                <div id="passwordError" style="color: #dc3545; font-size: 14px; margin-bottom: 10px; display: none;"></div>
                <div class="modal-buttons">
                    <button type="button" class="btn btn-cancel" onclick="closeChangePasswordModal()">Hủy</button>
                    <button type="submit" class="btn btn-submit">Cập nhật mật khẩu</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal() {
            document.getElementById('editModal').classList.add('show');
        }
        function closeEditModal() {
            document.getElementById('editModal').classList.remove('show');
        }
        function openChangePasswordModal() {
            document.getElementById('changePasswordModal').classList.add('show');
            document.getElementById('passwordError').style.display = 'none';
        }
        function closeChangePasswordModal() {
            document.getElementById('changePasswordModal').classList.remove('show');
            document.getElementById('changePasswordForm').reset();
        }
        // Validate password match before submit
        document.getElementById('changePasswordForm')?.addEventListener('submit', function(e) {
            const newPwd = document.getElementById('newPassword').value;
            const confirmPwd = document.getElementById('confirmPassword').value;
            const errorDiv = document.getElementById('passwordError');
            if (newPwd !== confirmPwd) {
                e.preventDefault();
                errorDiv.textContent = 'Mật khẩu mới không khớp!';
                errorDiv.style.display = 'block';
            }
        });
        window.onclick = function(event) {
            const editModal = document.getElementById('editModal');
            const pwdModal = document.getElementById('changePasswordModal');
            if (event.target == editModal) {
                editModal.classList.remove('show');
            }
            if (event.target == pwdModal) {
                pwdModal.classList.remove('show');
            }
        }
    </script>
<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
