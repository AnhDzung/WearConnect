<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap');

  .wearconnect-footer {
    font-family: 'Inter', sans-serif;
    background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
    color: #cbd5e1;
    padding: 32px 20px;
    margin-top: 48px;
    border-top: 1px solid rgba(99, 102, 241, 0.15);
  }
  .footer-container {
    max-width: 1200px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: 1.2fr 1fr 1fr;
    gap: 32px;
    align-items: start;
  }
  .footer-brand {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .footer-brand img {
    height: 36px;
    width: auto;
    display: block;
  }
  .footer-title { font-family: 'Poppins', sans-serif; font-weight: 700; font-size: 18px; color: #fff; }
  .footer-toggle-btn { display:none; background:none; border:none; font-weight:700; font-size:16px; cursor:pointer; color: #cbd5e1; }
  .footer-links { list-style: none; margin: 0; padding: 0; }
  .footer-links li { margin: 10px 0; }
  .footer-links a { color: #94a3b8; text-decoration: none; transition: all var(--transition-base); }
  .footer-links a:hover { color: #6366f1; text-shadow: 0 0 10px rgba(99, 102, 241, 0.3); }
  .footer-note { font-size: 13px; color: #64748b; line-height: 1.5; }
  .footer-bottom {
    margin-top: 32px;
    padding-top: 16px;
    border-top: 1px solid rgba(255, 255, 255, 0.05);
    text-align: center;
    font-size: 12px;
    color: #64748b;
  }
  @media (max-width: 768px) {
    .footer-container { grid-template-columns: 1fr; gap: 20px; }
    .wearconnect-footer { padding: 24px 16px; }
    .footer-toggle-btn { display:inline-block; }
    .footer-links { display:none; }
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
      <div style="display:flex; align-items:center; justify-content:space-between;">
        <div class="footer-title">Liên kết nhanh</div>
        <button class="footer-toggle-btn" aria-expanded="false">▾</button>
      </div>
      <ul class="footer-links">
        <li><a href="${pageContext.request.contextPath}/home">Cửa Hàng</a></li>
        <li><a href="${pageContext.request.contextPath}/login">Đăng Nhập</a></li>
        <li><a href="${pageContext.request.contextPath}/register">Đăng Ký</a></li>
        <li><a href="${pageContext.request.contextPath}/clothing?action=myClothing">Quản Lý Sản Phẩm</a></li>
      </ul>
    </div>

    <div>
      <div style="display:flex; align-items:center; justify-content:space-between;">
        <div class="footer-title">Hỗ trợ</div>
        <button class="footer-toggle-btn" aria-expanded="false">▾</button>
      </div>
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

<script>
  (function(){
    if (window.matchMedia && window.matchMedia('(max-width:768px)').matches) {
      document.querySelectorAll('.footer-toggle-btn').forEach(function(btn){
        btn.addEventListener('click', function(){
          const ul = this.parentElement.nextElementSibling;
          const open = ul.style.display !== 'block';
          ul.style.display = open ? 'block' : 'none';
          this.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
      });
    }
  })();
</script>
