<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .wearconnect-footer {
    background: linear-gradient(135deg, #1f2a44 0%, #314a72 100%);
    color: #eaeef6;
    padding: 24px 20px;
    margin-top: 40px;
  }
  .footer-container {
    max-width: 1200px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 20px;
    align-items: start;
  }
  .footer-brand {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .footer-brand img {
    height: 32px;
    width: auto;
    display: block;
  }
  .footer-title { font-weight: 700; font-size: 18px; }
  .footer-links { list-style: none; margin: 0; padding: 0; }
  .footer-links li { margin: 8px 0; }
  .footer-links a { color: #eaeef6; text-decoration: none; opacity: 0.9; }
  .footer-links a:hover { opacity: 1; text-decoration: underline; }
  .footer-note { font-size: 13px; opacity: 0.8; }
  .footer-bottom {
    margin-top: 20px;
    text-align: center;
    font-size: 12px;
    opacity: 0.7;
  }
  @media (max-width: 768px) {
    .footer-container { grid-template-columns: 1fr; }
    .wearconnect-footer { padding: 20px 16px; }
  }
</style>

<footer class="wearconnect-footer">
  <div class="footer-container">
    <div>
      <div class="footer-brand">
        <img src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="Wear Connect logo" />
        <div>
          <div class="footer-title">Wear Connect</div>
          <div class="footer-note">Wear once – Connect forever</div>
        </div>
      </div>
      <div class="footer-note" style="margin-top:10px">Kết nối người cho thuê và người thuê trang phục một cách dễ dàng.</div>
    </div>

    <div>
      <div class="footer-title">Liên kết nhanh</div>
      <ul class="footer-links">
        <li><a href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
        <li><a href="${pageContext.request.contextPath}/login">Đăng Nhập</a></li>
        <li><a href="${pageContext.request.contextPath}/register">Đăng Ký</a></li>
        <li><a href="${pageContext.request.contextPath}/clothing?action=myClothing">Quản Lý Sản Phẩm</a></li>
      </ul>
    </div>

    <div>
      <div class="footer-title">Hỗ trợ</div>
      <ul class="footer-links">
        <li><a href="#" onclick="return false;">Điều Khoản</a></li>
        <li><a href="#" onclick="return false;">Chính Sách Bảo Mật</a></li>
        <li><a href="#" onclick="return false;">Liên Hệ &amp; Hỗ Trợ</a></li>
      </ul>
    </div>
  </div>

  <div class="footer-bottom">
    &copy; <%= java.time.Year.now() %> Wear Connect. All rights reserved.
  </div>
</footer>
