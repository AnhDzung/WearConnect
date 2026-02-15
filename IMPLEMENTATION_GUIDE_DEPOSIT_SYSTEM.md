## ✅ HOÀN THÀNH: Hệ Thống Tính Tiền Cọc & Hoàn Lại Động

### **TỔNG QUAN**
Đã triển khai hệ thống tính tiền cọc thông minh dựa trên:
1. **Thời gian thuê** (theo giờ vs theo ngày)
2. **Độ uy tín người dùng** (rating cao, bình thường, hay mới)
3. **Tình trạng trả hàng** (không hư, trả trễ, hư nhẹ, mất)

---

## 📋 CÁC FILE ĐÃ TẠO/CẬP NHẬT

### **1. ✨ NEW: `DepositCalculationConfig.java`**
**Vị trí:** `src/java/config/DepositCalculationConfig.java`

**Chứa:**
- Constants tất cả tỷ lệ:
  - Hourly: 40% X hoặc 2× RentalFee (chọn max)
  - Daily: 30% X hoặc 0.5× RentalFee (chọn max)
- Trust rating multipliers:
  - Rating ≥ 4.0: × 0.80 (giảm 20%)
  - Rating 3.0-3.9: × 1.0 (bình thường)
  - Rating < 3.0 hoặc không rating: × 1.20 (tăng 20%)
- Methods:
  - `calculateHourlyDeposit()` - tính cọc cho giờ
  - `calculateDailyDeposit()` - tính cọc cho ngày
  - `shouldUseDailyPricing()` - xác định dùng daily nếu ≥ 24h
  - `getTrustBasedMultiplier()` - lấy hệ số uy tín
  - `getTrustRatingDescription()` - mô tả Vietnamese

---

### **2. ✨ NEW: `DepositCalculationUtil.java`**
**Vị trí:** `src/java/util/DepositCalculationUtil.java`

**Chứa:**
- `calculatePaymentDetails()` - tính toàn bộ chi tiết thanh toán
  - RentalFee, DepositAmount, TotalPayNow
  - Phân tích công thức (% vs Multiplier, chọn max nào)
- `formatCurrency()` - định dạng tiền VND
- `getPriceTypeDescription()` - mô tả loại giá
- `getFormulaDescription()` - mô tả công thức cho user

**Output Example:**
```
{
  "durationHours": 2,
  "itemValue": 2000000,
  "rentalFee": 300000,
  "depositAmount": 800000,
  "totalPayNow": 1100000,
  "priceType": "Hourly",
  "depositPercentage": 40,
  "depositMultiplier": 2,
  "depositFromPercentage": 800000,
  "depositFromMultiplier": 600000,
  "usedFormula": "max(800.000 ₫, 600.000 ₫) = 800.000 ₫"
}
```

---

### **3. ✨ NEW: `RefundCalculationUtil.java`**
**Vị trí:** `src/java/util/RefundCalculationUtil.java`

**Chứa:**
- `RefundStatus` enum:
  - NO_DAMAGE (100% hoàn lại)
  - LATE_RETURN (trừ late fee)
  - MINOR_DAMAGE (trừ compensation)
  - LOST (trừ toàn bộ value)

- Methods tính toán:
  - `calculateLateFee()` - LateFee = HrRate × LateHours × 150%
  - `calculateMinorDamageCompensation()` - = DamagePercentage × X
  - `calculateLostItemCompensation()` - = X (full)
  - `calculateRefund()` - tính toán hoàn lại chi tiết

- **RefundDetails class** chứa:
  - originalDeposit, status, lateFee, compensation
  - totalDeduction, refundAmount
  - additionalCharges (nếu thiệt hại > deposit)

---

### **4. 📝 UPDATED: `DepositCalculationConfig.java`**
**Thêm constants:**
```java
HOURLY_DEPOSIT_PERCENTAGE = 0.40        // 40%
HOURLY_DEPOSIT_MULTIPLIER = 2.0         // 2x tiền thuê
DAILY_DEPOSIT_PERCENTAGE = 0.30         // 30%
DAILY_DEPOSIT_MULTIPLIER = 0.5          // 0.5x tiền thuê
HIGH_RATING_MULTIPLIER = 0.80           // -20% cho rating cao
NEW_USER_MULTIPLIER = 1.20              // +20% cho user mới
NORMAL_USER_MULTIPLIER = 1.0            // bình thường
HIGH_RATING_THRESHOLD = 4.0
LOW_RATING_THRESHOLD = 3.0
```

**Thêm methods:**
- `getTrustBasedMultiplier(Double userRating)` - hệ số uy tín
- `getTrustRatingDescription(Double userRating)` - mô tả VN

---

### **5. 📝 UPDATED: `RentalOrder.java`**
**Thêm fields:**
```java
LocalDateTime actualReturnDate          // Ngày trả thực tế
double userRating                       // Rating của user
double trustBasedMultiplier             // Hệ số uy tín (0.8, 1.0, 1.2)
double adjustedDepositAmount            // Cọc sau khi áp dụng uy tín
String returnStatus                     // NO_DAMAGE, LATE_RETURN, MINOR_DAMAGE, LOST
double damagePercentage                 // % hư hỏng (0.0-1.0)
double lateFees                         // Phí trả trễ
double compensationAmount               // Tiền bồi thường
double refundAmount                     // Tiền hoàn lại
```

**Thêm getters/setters** cho tất cả fields trên

---

### **6. 📝 UPDATED: `RentalOrderService.java`**
**Import thêm:**
```java
import DAO.RatingDAO;
import config.DepositCalculationConfig;
```

**Sửa `createRentalOrder()` method:**
- Tính duration (giờ)
- Xác định: hourly (< 24h) hay daily (≥ 24h)
- Tính depositAmount theo công thức tương ứng
- **Lấy user rating:** `RatingDAO.getAverageRatingForUser(renterUserID)`
- **Áp dụng trust-based multiplier:** `depositAmount × multiplier`
- Lưu trữ tất cả thông tin vào RentalOrder object

---

## 🔢 CÔNG THỨC TÍNH TOÁN

### **Thuê theo GIỜ (< 24h):**
```
RentalFee = Hours × HourlyPrice
Deposit = MAX(X × 40%, 2 × RentalFee)
AdjustedDeposit = Deposit × TrustMultiplier
TotalPayNow = RentalFee + AdjustedDeposit
```

**Ví dụ:** 3 giờ thuê
```
X = 2.000.000đ, HrRate = 150.000đ
RentalFee = 3 × 150.000 = 450.000đ
Deposit = MAX(2.000.000 × 40%, 2 × 450.000)
        = MAX(800.000đ, 900.000đ) = 900.000đ
Nếu user uy tín cao (rating ≥ 4.0):
  AdjustedDeposit = 900.000 × 0.80 = 720.000đ
  TotalPayNow = 450.000 + 720.000 = 1.170.000đ
```

### **Thuê theo NGÀY (≥ 24h):**
```
Days = Hours / 24
RentalFee = Days × DailyPrice
Deposit = MAX(X × 30%, 0.5 × RentalFee)
AdjustedDeposit = Deposit × TrustMultiplier
TotalPayNow = RentalFee + AdjustedDeposit
```

**Ví dụ:** 2 ngày thuê
```
X = 2.000.000đ, DayRate = 300.000đ
RentalFee = 2 × 300.000 = 600.000đ
Deposit = MAX(2.000.000 × 30%, 0.5 × 600.000)
        = MAX(600.000đ, 300.000đ) = 600.000đ
Nếu user mới (không rating):
  AdjustedDeposit = 600.000 × 1.20 = 720.000đ
  TotalPayNow = 600.000 + 720.000 = 1.320.000đ
```

---

## 💰 HOÀN LẠI CỌC (REFUND)

### **Trường hợp 1: Không hư hỏng (NO_DAMAGE)**
```
Refund = OriginalDeposit (100% hoàn lại)
```

### **Trường hợp 2: Trả trễ (LATE_RETURN)**
```
LateHours = ActualReturn - ExpectedReturn
LateFee = HourlyPrice × LateHours × 150%
Refund = OriginalDeposit - LateFee
```
**Ví dụ:** Trễ 2 giờ
```
HrRate = 150.000đ
LateFee = 150.000 × 2 × 1.5 = 450.000đ
Deposit = 900.000đ
Refund = 900.000 - 450.000 = 450.000đ
```

### **Trường hợp 3: Hư hỏng nhẹ (MINOR_DAMAGE)**
```
Compensation = DamagePercentage × X
Refund = OriginalDeposit - Compensation
```
**Ví dụ:** 20% hư hỏng
```
X = 2.000.000đ
Compensation = 0.20 × 2.000.000 = 400.000đ
Deposit = 900.000đ
Refund = 900.000 - 400.000 = 500.000đ
```

### **Trường hợp 4: Mất đồ (LOST)**
```
Compensation = X (toàn bộ giá trị)
if Compensation > OriginalDeposit:
  Refund = 0
  AdditionalCharges = Compensation - OriginalDeposit
else:
  Refund = OriginalDeposit - Compensation
```
**Ví dụ:** Mất đồ
```
X = 2.000.000đ
Compensation = 2.000.000đ
Deposit = 1.200.000đ (sau trust adjustment)
Refund = 0
AdditionalCharges = 2.000.000 - 1.200.000 = 800.000đ
  → Charge thêm 800.000đ qua payment gateway
```

---

## 👤 ỨY TÍN USER (TRUST RATING)

| Rating | Loại | Hệ Số | Cộc |
|--------|------|-------|-----|
| ≥ 4.0 | Uy tín cao | × 0.80 | **-20%** ✓ |
| 3.0-3.9 | Bình thường | × 1.0 | **0%** → |
| < 3.0 | Uy tín thấp | × 1.20 | **+20%** ⚠️ |
| Không rating | User mới | × 1.20 | **+20%** ⚠️ |

---

## 🔄 FLOW TÍNH CỌC

```
User tạo đơn thiêu
  ↓
[Xác định thời gian thuê]
  ├─ < 24h → Hourly pricing
  └─ ≥ 24h → Daily pricing
  ↓
[Tính Rental Fee]
  ├─ Hourly: hours × HourlyPrice
  └─ Daily: days × DailyPrice
  ↓
[Tính Base Deposit]
  ├─ Formula: MAX(X × %, multiplier × RentalFee)
  └─ Lấy giá cao hơn
  ↓
[Lấy User Rating] 
  └─ RatingDAO.getAverageRatingForUser()
  ↓
[Tính Trust Multiplier]
  ├─ Rating ≥ 4.0 → 0.80
  ├─ Rating 3.0-3.9 → 1.0
  ├─ Rating < 3.0 → 1.2
  └─ No rating → 1.2
  ↓
[Áp Dụng Trust Multiplier]
  └─ AdjustedDeposit = BaseDeposit × Multiplier
  ↓
[Total Payment]
  └─ RentalFee + AdjustedDeposit
```

---

## 📦 YÊU CẦU CẬP NHẬT DATABASE

**Cần thêm vào bảng RentalOrder:**
```sql
ALTER TABLE RentalOrder ADD ActualReturnDate DATETIME NULL;
ALTER TABLE RentalOrder ADD UserRating DECIMAL(3,1) DEFAULT 0;
ALTER TABLE RentalOrder ADD TrustBasedMultiplier DECIMAL(3,2) DEFAULT 1.0;
ALTER TABLE RentalOrder ADD AdjustedDepositAmount DECIMAL(10,2);
ALTER TABLE RentalOrder ADD ReturnStatus NVARCHAR(50) NULL;
ALTER TABLE RentalOrder ADD DamagePercentage DECIMAL(3,2) DEFAULT 0;
ALTER TABLE RentalOrder ADD LateFees DECIMAL(10,2) DEFAULT 0;
ALTER TABLE RentalOrder ADD CompensationAmount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE RentalOrder ADD RefundAmount DECIMAL(10,2) DEFAULT 0;
```

---

## 🎯 TIẾP THEO

1. **Tạo SQL migration script** để thêm các fields vào database
2. **Cập nhật DAO** (RentalOrderDAO) để save/load các fields mới
3. **Cập nhật Servlet** để hiển thị chi tiết tính toán
4. **Tạo JSP** cho trang hoàn lại cọc (return resolution)
5. **Thêm logic thanh toán** cho additional charges khi mất/hư hỏng nặng
