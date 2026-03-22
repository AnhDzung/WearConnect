# Hướng Dẫn Hoàn Thành Tích Hợp Google OAuth2 cho WearConnect

## Tổng Quan Công Việc Đã Hoàn Thành

Tôi đã thực hiện các bước sau để tích hợp Google OAuth2:

### ✅ 1. Maven Dependencies (pom.xml)
- ✓ Thêm Spring Security
- ✓ Thêm Spring OAuth2 Client
- ✓ Thêm JWT libraries
- ✓ Thêm OAuth2 OIDC SDK

### ✅ 2. Cập Nhật Models & DAOs
- ✓ Cập nhật `Account.java` thêm OAuth2 fields:
  - `oauthProvider` (Google, Facebook, etc.)
  - `oauthID` (OAuth provider ID)
  - `googleID` (Google-specific ID)
  
- ✓ Cập nhật `AccountDAO.java` thêm methods:
  - `findByGoogleID()` - Tìm user theo Google ID
  - `findByEmail()` - Tìm user theo email
  - `updateOAuthInfo()` - Cập nhật OAuth information

### ✅ 3. Service Layer
- ✓ Tạo `GoogleOAuth2Service.java`:
  - `getGoogleUserInfo()` - Lấy user info từ access token
  - `handleOAuth2Login()` - Xử lý OAuth2 login
  - `generateUniqueUsername()` - Tạo unique username

### ✅ 4. Controllers
- ✓ Tạo `OAuth2CallbackController.java`:
  - `/oauth2/authorize/google` - Initiate OAuth2 flow
  - `/oauth2/callback/google` - Handle OAuth2 callback

### ✅ 5. UI Updates
- ✓ Cập nhật `login.jsp`:
  - Thêm "Đăng nhập với Google" button
  - Thêm Google icon SVG
  - Responsive design

### ✅ 6. Configuration & Migration
- ✓ Tạo `ALTER TABLE` script để thêm OAuth2 columns
- ✓ Tạo properties config file

---

## Các Bước Tiếp Theo Để Triển Khai

### Bước 1: Tạo Google Cloud Console Project

1. **Truy cập Google Cloud Console**
   - Vào https://console.cloud.google.com/
   - Tạo dự án mới (hoặc chọn dự án hiện có)

2. **Enable Google+ API**
   - Vào APIs & Services → Library
   - Tìm "Google+ API"
   - Click Enable

3. **Tạo OAuth 2.0 Credentials**
   - Vào APIs & Services → Credentials
   - Click "Create Credentials" → OAuth client ID
   - Chọn Application Type: **Web application**
   - Đặt tên: "WearConnect"

4. **Cấu Hình Authorized URIs**
   - Thêm Authorized JavaScript origins:
     ```
     http://localhost:8080
     http://localhost:8081
     https://yourdomain.com
     ```
   
   - Thêm Authorized redirect URIs:
     ```
     http://localhost:8080/oauth2/callback/google
     http://localhost:8081/oauth2/callback/google
     https://yourdomain.com/oauth2/callback/google
     ```

5. **Lưu Credentials**
   - Copy **Client ID**
   - Copy **Client Secret**
   - Bạn sẽ cần chúng ở bước sau

### Bước 2: Cập Nhật Application Configuration

#### Option A: Environment Variables (Recommended for Production)

**Windows:**
```batch
-- Set environment variables
setx GOOGLE_CLIENT_ID "YOUR_CLIENT_ID.apps.googleusercontent.com"
setx GOOGLE_CLIENT_SECRET "YOUR_CLIENT_SECRET"

-- Restart IDE/Terminal để áp dụng
```

**Linux/Mac:**
```bash
export GOOGLE_CLIENT_ID="YOUR_CLIENT_ID.apps.googleusercontent.com"
export GOOGLE_CLIENT_SECRET="YOUR_CLIENT_SECRET"
```

#### Option B: application.properties (For Development)

**File:** `src/main/resources/application.properties`

Thêm vào cuối file:
```properties
# Google OAuth2 Configuration
spring.security.oauth2.client.registration.google.client-id=YOUR_CLIENT_ID.apps.googleusercontent.com
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

### Bước 3: Chạy Database Migration

**SQL Server:**

1. Mở SQL Server Management Studio
2. Kết nối tới database của bạn
3. Mở file: `ADD_OAUTH2_COLUMNS.sql`
4. Execute script để thêm OAuth2 columns

```sql
-- Hoặc chạy từng command:
ALTER TABLE Accounts ADD OAuthProvider NVARCHAR(50) NULL;
ALTER TABLE Accounts ADD OAuthID NVARCHAR(255) NULL;
ALTER TABLE Accounts ADD GoogleID NVARCHAR(255) NULL;
ALTER TABLE Accounts ADD Avatar NVARCHAR(500) NULL;
```

### Bước 4: Update Maven & Build Project

```bash
# Clean & rebuild
mvn clean package

# Hoặc nếu dùng Spring Boot
mvn clean spring-boot:run
```

### Bước 5: Test OAuth2 Integration

1. **Khởi động Application**
   - Run: `mvn spring-boot:run`
   - Hoặc deploy WAR file

2. **Truy cập Login Page**
   - Vào: `http://localhost:8080/login`
   - Bạn sẽ thấy nút "Đăng nhập với Google"

3. **Test Google Login**
   - Click "Đăng nhập với Google"
   - Login với Google account
   - Verify được redirect về home page
   - Check database xem user được tạo

4. **Kiểm tra Data**
   ```sql
   SELECT AccountID, Username, Email, OAuthProvider, GoogleID, Status 
   FROM Accounts 
   WHERE OAuthProvider = 'Google'
   ORDER BY AccountID DESC;
   ```

---

## Cấu Trúc File Đã Tạo

```
src/main/java/
├── Service/
│   └── GoogleOAuth2Service.java          (NEW)
├── com/wearconnect/boot/controller/
│   └── OAuth2CallbackController.java     (NEW)
├── Model/
│   └── Account.java                      (UPDATED)
└── DAO/
    └── AccountDAO.java                   (UPDATED)

src/main/resources/
└── application.properties                (UPDATE with OAuth2 config)

web/WEB-INF/jsp/
└── login.jsp                             (UPDATED)

docs/
├── GOOGLE_OAUTH2_INTEGRATION.md          (NEW - Overview)
└── ADD_OAUTH2_COLUMNS.sql                (NEW - DB Migration)
```

---

## Troubleshooting

### Error: "redirect_uri_mismatch"
**Giải pháp:**
- Kiểm tra Redirect URI trong Google Cloud Console
- Phải khớp CHÍNH XÁC với endpoint trong code
- Không được chứa trailing slash

### Error: "invalid_client"
**Giải pháp:**
- Kiểm tra Client ID và Secret
- Ensure credentials được set từ environment hoặc properties
- Verify Google Cloud project enable Google+ API

### Error: "User data missing from Google"
**Giải pháp:**
- Kiểm tra scope: `profile email`
- Check Google userinfo endpoint response

### CORS Error
**Giải pháp:**
- Thêm CORS Configuration class nếu cần
- Set `Access-Control-Allow-Origin` headers

---

## Security Best Practices

✅ **Đã Implement:**
- HTTPS redirect URIs in production
- HttpOnly cookies for sessions
- Scope giới hạn (profile, email chỉ)
- Token verification từ Google

🔒 **Recommendation cho Production:**
```properties
# Set HTTPS redirect URI cho production
spring.security.oauth2.client.registration.google.redirect-uri=https://yourdomain.com/oauth2/callback/google

# Enable HTTPS only
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=YOUR_PASSWORD
```

---

## Optional Enhancements

### 1. Link Multiple OAuth Providers
File: `GoogleOAuth2Service.java`
```java
// Có thể extend để support Facebook, GitHub, etc.
handleOAuth2Login(facebookUserInfo)
handleOAuth2Login(githubUserInfo)
```

### 2. Implement CSRF Protection
```properties
spring.security.oauth2.client.registration.google.scope=openid,profile,email
```

### 3. Token Refresh
```java
// Implement refresh token logic
exchangeCodeForRefreshToken(code)
```

### 4. User Profile Picture Integration
```java
// Avatar đã tự động save từ Google profile
account.setAvatar(googleUserInfo.getPicture());
```

---

## Contact & Support

Nếu gặp vấn đề:
1. Kiểm tra logs (console hoặc log file)
2. Verify Google OAuth2 config
3. Ensure database migration chạy thành công
4. Check CORS headers nếu call từ different domain

---

**Tài liệu này cập nhật lần cuối:** 2026-03-22
