# Hướng Dẫn Tích Hợp Đăng Nhập Google OAuth2 cho WearConnect

## 1. Tổng Quan
Hướng dẫn này hướng dẫn cách tích hợp Google OAuth2 để cho phép người dùng đăng ký/đăng nhập bằng tài khoản Google.

## 2. Các Bước Chu Ẩm Giai Đoạn

### Giai Đoạn 1: Cấu Hình Google Cloud Console

1. **Truy cập Google Cloud Console**
   - Vào https://console.cloud.google.com/
   - Tạo dự án mới hoặc chọn dự án hiện có

2. **Tạo OAuth 2.0 Credentials**
   - Vào menu: APIs & Services → Credentials
   - Click "Create Credentials" → OAuth client ID
   - Chọn Application Type: Web application
   - Đặt tên: "WearConnect"

3. **Cấu Hình Authorized Redirect URIs**
   - Thêm: `http://localhost:8080/oauth2/callback/google`
   - Thêm: `http://localhost:8080/auth/google/callback`
   - Thêm: Production URL khi deploy

4. **Lưu Client ID và Client Secret**
   - Bạn sẽ cần chúng trong `application.properties`

### Giai Đoạn 2: Cập Nhật Maven Dependencies

Thêm các dependency sau vào `pom.xml`:

```xml
<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- OAuth2 Client -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-oauth2-client</artifactId>
</dependency>

<!-- OAuth2 Resource Server -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-oauth2-resource-server</artifactId>
</dependency>

<!-- JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- JSON Processing -->
<dependency>
    <groupId>com.nimbusds</groupId>
    <artifactId>oauth2-oidc-sdk</artifactId>
    <version>11.10</version>
</dependency>
```

### Giai Đoạn 3: Cấu Hình Application Properties

Thêm vào `src/main/resources/application.properties`:

```properties
# Google OAuth2 Configuration
spring.security.oauth2.client.registration.google.client-id=YOUR_CLIENT_ID
spring.security.oauth2.client.registration.google.client-secret=YOUR_CLIENT_SECRET
spring.security.oauth2.client.registration.google.scope=profile,email
spring.security.oauth2.client.registration.google.redirect-uri=http://localhost:8080/oauth2/callback/google
spring.security.oauth2.client.provider.google.authorization-uri=https://accounts.google.com/o/oauth2/v2/auth
spring.security.oauth2.client.provider.google.token-uri=https://www.googleapis.com/oauth2/v4/token
spring.security.oauth2.client.provider.google.user-info-uri=https://www.googleapis.com/oauth2/v3/userinfo
spring.security.oauth2.client.provider.google.user-name-attribute=email

# Session & Security
server.servlet.session.cookie.http-only=true
server.servlet.session.cookie.same-site=lax
server.servlet.session.tracking-modes=cookie
```

### Giai Đoạn 4: Các Tệp Cần Tạo/Cập Nhật

1. `GoogleOAuth2Config.java` - Security configuration
2. `GoogleOAuth2Service.java` - Service xử lý OAuth2
3. `OAuth2CallbackController.java` - Callback endpoint
4. `Account.java` - Cập nhật model (thêm OAuth2 fields)
5. `login.jsp` - Thêm Google login button
6. `SecurityConfig.java` - Spring Security configuration

### Giai Đoạn 5: Tích Hợp Với Current Authentication

- Giữ nguyên login/register hiện tại
- Thêm Google OAuth2 như option thay thế
- Auto-create account nếu user không tồn tại
- Kiểm tra email duplicate

## 3. Chi Tiết Triển Khai

### 3.1. Cập Nhật Account Model
- Thêm field: `oauthProvider` (Google, Facebook,...)
- Thêm field: `oauthID` (ID từ OAuth provider)
- Thêm field: `googleID` (Google-specific ID)

### 3.2. Luồng OAuth2
1. User click "Sign in with Google"
2. Redirect đến Google login
3. Google redirect về `/oauth2/callback/google`
4. Verify token từ Google
5. Kiểm tra user tồn tại hoặc tạo mới
6. Tạo session và redirect tới home

### 3.3. Database Changes
```sql
-- Thêm column vào Account table
ALTER TABLE Account ADD COLUMN OAuthProvider NVARCHAR(50) NULL;
ALTER TABLE Account ADD COLUMN OAuthID NVARCHAR(255) NULL;
ALTER TABLE Account ADD COLUMN GoogleID NVARCHAR(255) NULL;
```

## 4. Bảo Mật

- Không lưu password từ Google
- Sử dụng HTTPS trong production
- Validate token từ Google mỗi lần
- Set HttpOnly cookies
- CSRF protection

## 5. URLs Quan Trọng

- Login URL: `/login`
- Google OAuth Initiate: `/oauth2/authorize/google`
- Google OAuth Callback: `/oauth2/callback/google`
- Logout: `/logout`

## 6. Testing

```bash
# Local development
- http://localhost:8080/login
- Click "Sign in with Google"
- Verify redirect tới Google
- Verify account creation
```

## 7. Production Deployment

- Cập nhật Redirect URI trong Google Cloud Console
- Đặt `https://yourdomain.com/oauth2/callback/google`
- Thay đổi application.properties cho environment production
- Test với real Google account

## 8. Troubleshooting

| Issue | Giải Pháp |
|-------|----------|
| redirect_uri_mismatch | Kiểm tra URI trong Google Cloud Console |
| invalid_client | Kiểm tra Client ID & Secret |
| User data missing | Kiểm tra userinfo endpoint response |
| CORS error | Cấu hình CORS filter |

---

**Tiếp theo:** Bạn muốn tôi implement các file code chi tiết không?
