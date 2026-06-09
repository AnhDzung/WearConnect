# 🚀 Deploy WearConnect lên Azure for Students - Hướng dẫn Chi Tiết

> Dự kiến thời gian: 30-45 phút (lần đầu), 5 phút (lần sau)

---

## 📋 Bước 0: Chuẩn bị

### 0.1 Đăng ký Azure for Students
1. Truy cập: https://azure.microsoft.com/en-us/free/students/
2. Click **Start Free**
3. Đăng nhập hoặc tạo tài khoản Microsoft bằng **email FPT** (ví dụ: `your.name@fpt.edu.vn` hoặc email học tập FPT)
4. Xác minh qua email (nếu cần)
5. Không cần card tín dụng
6. Nhận **$100 credit miễn phí trong 1 năm**

### 0.2 Chuẩn bị máy local
- Đảm bảo có Maven cài đặt: `mvn -v`
- Nếu chưa có, chạy: `C:\Users\Admin\.maven\maven-3.9.15(1)\bin\mvn.cmd -v`
- Hoặc cài Maven từ https://maven.apache.org/download.cgi

### 0.3 Cài Azure CLI (tùy chọn nhưng khuyến khích)
- Download: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
- Hoặc dùng Azure Portal web qua browser cũng được

---

## 📦 Bước 1: Build WAR trên Local

### 1.1 Mở Terminal trong thư mục project
```bash
cd d:\Fpt\sm7\WearConnect
```

### 1.2 Build WAR
```bash
C:\Users\Admin\.maven\maven-3.9.15(1)\bin\mvn.cmd clean package -DskipTests
```

**Kết quả mong đợi:**
- Xong lúc: `[INFO] BUILD SUCCESS`
- File WAR nằm ở: `d:\Fpt\sm7\WearConnect\target\wearconnect-0.0.1-SNAPSHOT.war`

### 1.3 Kiểm tra file WAR
```bash
dir target\*.war
```

Nếu thấy file `wearconnect-0.0.1-SNAPSHOT.war`, bạn sẵn sàng deploy.

---

## ☁️ Bước 2: Tạo Resources trên Azure

### 2.1 Đăng nhập Azure Portal
1. Mở: https://portal.azure.com
2. Đăng nhập bằng tài khoản FPT của bạn
3. Chọn **Subscriptions** → xác nhận **Azure for Students** được chọn

### 2.2 Tạo Resource Group
1. Click **Create a resource** hoặc **+ Create**
2. Tìm **Resource Group** → Click **Create**
3. Điền:
   - **Subscription**: Azure for Students
   - **Resource group**: `wearconnect-rg`
   - **Region**: `Southeast Asia` (gần Việt Nam nhất)
4. Click **Review + Create** → **Create**

### 2.3 Tạo SQL Database
1. Click **Create a resource**
2. Tìm **SQL Database** → Click **Create**
3. Điền:
   - **Subscription**: Azure for Students
   - **Resource group**: `wearconnect-rg`
   - **Database name**: `wearconnect`
   - **Server**: Click **Create new**
     - **Server name**: `wearconnect-server` (phải duy nhất toàn cầu)
     - **Location**: Southeast Asia
     - **Authentication method**: SQL authentication
     - **Server admin login**: `wearconnectadmin`
     - **Password**: Chọn mật khẩu mạnh (16+ ký tự, chứa chữ hoa, số, ký tự đặc biệt)
       - Ví dụ: `WearConnect@2024SqlDB`
     - Click **OK**
   - **Compute + storage**: Chọn **Basic** (rẻ nhất, miễn phí tier)
4. Click **Review + Create** → **Create**

**Lưu ý:**
- Ghi lại `wearconnect-server` server name
- Ghi lại mật khẩu admin SQL
- Ghi lại tên database: `wearconnect`

### 2.4 Cho phép kết nối từ App Service
1. Chờ SQL Database tạo xong
2. Vào SQL Server vừa tạo → **Networking**
3. Chọn **Allow public endpoint**
4. Thêm firewall rule:
   - Click **+ Add a firewall rule**
   - **Rule name**: `AllowAzureServices`
   - **Start IP**: `0.0.0.0`
   - **End IP**: `0.0.0.0`
   - Click **OK**

### 2.5 Lấy Connection String SQL Database
1. Vào **SQL Database** → `wearconnect`
2. Click **Connection strings**
3. Tab **JDBC**
4. Copy cái này (sẽ dùng sau):
```
jdbc:sqlserver://wearconnect-server.database.windows.net:1433;database=wearconnect;user=wearconnectadmin@wearconnect-server;password=AnhDung_14062003;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
```

**Cần sửa:** Thay `YourPasswordHere` bằng mật khẩu admin SQL bạn chọn.

---

## 🖥️ Bước 3: Tạo App Service

### 3.1 Tạo App Service
1. Click **Create a resource**
2. Tìm **App Service** → Click **Create**
3. Điền:
   - **Subscription**: Azure for Students
   - **Resource group**: `wearconnect-rg`
   - **Name**: `wearconnect-app` (phải duy nhất, Azure sẽ gợi ý tên khác nếu trùng)
   - **Publish**: **Code**
   - **Runtime stack**: **Java 17**
   - **Java web server container**: **Tomcat 10.1**
   - **Region**: Southeast Asia
   - **App Service plan**: Click **Create new**
     - **Name**: `wearconnect-plan`
     - **Sku and size**: **Free F1** (miễn phí, 60 phút/ngày → đủ để test)
     - Click **OK**
4. Click **Review + Create** → **Create**

**Lưu ý:** App Service Free tier có giới hạn CPU/Memory, nên có thể chậm. Nếu sau này cần nhanh hơn, bạn nâng cấp lên **Basic B1** ($13/tháng).

### 3.2 Chờ App Service tạo xong
- Xong khi thấy thông báo **"Deployment completed successfully"**
- Lưu lại URL app: `https://wearconnect-app.azurewebsites.net` (bạn có thể thấy khác tên)

---

## ⚙️ Bước 4: Cấu hình Biến Môi Trường trên Azure

### 4.1 Vào App Service → Configuration
1. Vào **App Service** vừa tạo
2. Click **Configuration** (phía trái)
3. Tab **Application settings**
4. Click **+ New application setting** và thêm từng cái này:

| Key | Value | Mô tả |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | `prod` | Bật profile production |
| `SPRING_DATASOURCE_URL` | `jdbc:sqlserver://wearconnect-server.database.windows.net:1433;database=wearconnect;user=wearconnectadmin@wearconnect-server;password=YourPasswordHere;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;` | Connection string SQL (thay password) |
| `SPRING_DATASOURCE_USERNAME` | `wearconnectadmin@wearconnect-server` | User SQL |
| `SPRING_DATASOURCE_PASSWORD` | `WearConnect@2024SqlDB` | Mật khẩu SQL (cái bạn chọn) |
| `GOOGLE_CLIENT_ID` | `your-google-client-id.apps.googleusercontent.com` | Lấy từ Google Cloud Console |
| `GOOGLE_CLIENT_SECRET` | `your-google-client-secret` | Lấy từ Google Cloud Console |
| `GOOGLE_REDIRECT_URI` | `https://wearconnect-app.azurewebsites.net/oauth2/callback/google` | Thay `wearconnect-app` bằng tên app thực tế |
| `GEMINI_API_KEY` | `your-gemini-api-key` | Lấy từ Google AI Studio |
| `AI_GEMINI_API_KEY` | `your-gemini-api-key` | Biến cũ tương thích ngược |
| `AI_PROVIDER` | `gemini` | Chọn nhà cung cấp AI (Gemini mặc định) |
| `AI_MODEL` | `gemini-2.5-flash` | Model mặc định |
| `INTERNAL_API_TOKEN` | `your-internal-token-123` | Token bảo mật nội bộ (tự chọn) |

**Ghi chú:** Dự án hiện ưu tiên sử dụng Gemini. Chỉ cần đặt `AI_PROVIDER=gemini` cùng `GEMINI_API_KEY` (hoặc alias `AI_GEMINI_API_KEY`).

**Cách điền từng cái:**
1. Click **+ New application setting**
2. Nhập **Name** (Key)
3. Nhập **Value**
4. Click **OK**
5. Lặp lại cho cái tiếp theo

### 4.2 Cập nhật Google OAuth2
**Vào Google Cloud Console:**
1. Truy cập: https://console.cloud.google.com
2. Chọn/tạo project
3. Vào **Credentials**
4. Click OAuth 2.0 Client ID (hoặc tạo mới nếu chưa có)
5. Ở **Authorized redirect URIs**, thêm:
   ```
   https://wearconnect-app.azurewebsites.net/oauth2/callback/google
   ```
6. Click **Save**
7. Copy **Client ID** và **Client Secret**
8. Dán vào `GOOGLE_CLIENT_ID` và `GOOGLE_CLIENT_SECRET` trong Azure Application Settings

### 4.3 Cập nhật Gemini API Key
1. Truy cập: https://aistudio.google.com/apikey
2. Click **Create API Key**
3. Copy key
4. Dán vào `GEMINI_API_KEY` trong Azure

### 4.4 Lưu cấu hình
- Click **Save** ở trên cùng
- Chờ thông báo **"Application settings have been updated successfully"**

---

## 🗄️ Bước 5: Khởi tạo SQL Database Schema

### 5.1 Tạo firewall rule cho máy local
1. Vào **SQL Server** → `wearconnect-server`
2. Click **Networking**
3. Click **+ Add a firewall rule**
4. **Rule name**: `MyLocalIP`
5. **Start IP** và **End IP**: Lấy từ https://www.whatismyipaddress.com (ghi IP của bạn)
6. Click **OK**

### 5.2 Kết nối từ SQL Server Management Studio
1. Mở **SQL Server Management Studio** (SSMS)
2. **Server name**: `wearconnect-server.database.windows.net`
3. **Authentication**: SQL Server Authentication
4. **Login**: `wearconnectadmin@wearconnect-server`
5. **Password**: Cái bạn chọn
6. Click **Connect**

### 5.3 Chạy SQL schema
1. File: `d:\Fpt\sm7\WearConnect\sql_database_schema.sql`
2. Mở trong SSMS
3. Thay đổi database sang `wearconnect`
4. **Execute** (hoặc Ctrl+Shift+E)

Khi xong, bạn sẽ thấy tất cả bảng được tạo trong database.

---

## 📤 Bước 6: Deploy WAR lên Azure App Service

### 6.1 Upload WAR qua Azure Portal (cách dễ)
1. Vào **App Service** `wearconnect-app`
2. Click **Deployment** → **Deployment Center** (phía trái)
3. Tab **Deploy**
4. Kéo thả file `wearconnect-0.0.1-SNAPSHOT.war` từ `d:\Fpt\sm7\WearConnect\target\`
5. Hoặc click **Browse** để chọn file
6. Azure sẽ tự deploy (chờ 2-3 phút)

### 6.2 Xem trạng thái deploy
1. Vào **Deployment** → **Deployments**
2. Xem trạng thái: **In progress** → **Success** ✓
3. Khi xong, app sẽ khởi động lại

### 6.3 Xem log (nếu có lỗi)
1. Vào **Monitoring** → **Log stream**
2. Xem log output real-time
3. Tìm lỗi hoặc xác nhận **Started ... in ... seconds**

---

## ✅ Bước 7: Test App Public

### 7.1 Truy cập app
- URL: `https://wearconnect-app.azurewebsites.net/`
- Bạn sẽ thấy trang **Home** (hoặc trang login)

### 7.2 Kiểm tra chức năng
1. **Trang chủ**: Load được không?
2. **Login thường**: Đăng nhập bằng user/pass được không?
3. **Google OAuth**: Click "Login with Google" → chuyển hướng Google được không?
4. **AI Chat** (nếu có): Chat bot hoạt động không?

### 7.3 Nếu app không chạy
- Vào **Log stream** xem lỗi
- Thường là:
  - Connection string SQL sai → sửa trong **Configuration**
  - API key Google/Gemini sai → kiểm tra lại
  - Mất quyền firewall SQL → thêm firewall rule

---

## 🔄 Bước 8: Cập nhật App (sau này)

Mỗi lần bạn sửa code và muốn deploy version mới:

### 8.1 Build WAR mới
```bash
C:\Users\Admin\.maven\maven-3.9.15(1)\bin\mvn.cmd clean package -DskipTests
```

### 8.2 Upload WAR
- Vào App Service → Deployment Center → Deploy
- Kéo thả file `.war` mới
- Chờ xong

**Thêm tùy chọn:** Bạn cũng có thể kết nối GitHub → tự động deploy khi push code.

---

## 💾 Bước 9: Backup & Restore (tuỳ chọn)

### 9.1 Backup Database
1. Vào **SQL Database** `wearconnect`
2. Click **Backups**
3. Azure tự động backup hàng ngày (miễn phí)

### 9.2 Export Database (sao lưu)
1. Vào **SQL Database** `wearconnect`
2. Click **Export**
3. Chọn Storage account → tạo file `.bacpac`
4. Download về máy

---

## 📊 Giám sát Chi phí (miễn phí track)

1. Vào **Cost Management + Billing**
2. Xem **Current month costs**
3. Với Free tier, chi phí sẽ là **$0** (nếu không vượt giới hạn)

**Lưu ý:** Nếu đạt $100 credit hết, hoặc resource tăng, Azure sẽ yêu cầu upgrade. Bạn có thể:
- Tắt app (nhưng vẫn chi phí lưu trữ nhỏ)
- Nâng cấp sang **Basic** (~$13/tháng)
- Chuyển sang server khác miễn phí (Render, Railway, etc.)

---

## 🆘 Troubleshooting

| Vấn đề | Giải pháp |
|---|---|
| App không load (trang trắng) | Xem Log stream, thường là SQL connection sai |
| Google OAuth không hoạt động | Kiểm tra `GOOGLE_REDIRECT_URI` khớp với Google Console |
| App chậm | Free tier có CPU/RAM hạn chế; nâng cấp lên Basic B1 |
| Database connection timeout | Thêm firewall rule cho IP App Service hoặc xóa firewall hạn chế |
| "503 Service Unavailable" | Chờ App Service khởi động (2-3 phút sau deploy) |

---

## 📝 Checklist Deploy

- [ ] Đăng ký Azure for Students
- [ ] Tạo Resource Group `wearconnect-rg`
- [ ] Tạo SQL Database + Server
- [ ] Lấy SQL connection string
- [ ] Tạo App Service (Java 17 + Tomcat 10.1)
- [ ] Cấu hình Application Settings (8 biến)
- [ ] Cập nhật Google OAuth redirect URI
- [ ] Khởi tạo SQL schema từ máy local
- [ ] Build WAR trên local
- [ ] Upload WAR lên App Service
- [ ] Test app ở URL public
- [ ] Xem log nếu có lỗi

---

## 🎉 Xong!

Bây giờ app của bạn chạy ở:
```
https://wearconnect-app.azurewebsites.net/
```

Mọi người trên internet (từ điện thoại, laptop, bất kỳ đâu) đều có thể truy cập!

Nếu cần đổi tên miền hoặc cấu hình tên miền riêng, xem: https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain

---

**Questions?**
- Inbox email: `dadnguyen14062003@gmail.com`
- GitHub: https://github.com/AnhDzung
