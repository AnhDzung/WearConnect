# 🎨 WEARCONNECT - HỆ THỐNG GIAO DIỆN THỐNG NHẤT

## ✅ ĐÃ HOÀN THÀNH

### 1. Core System
- ✅ **global-styles.css** - Hệ thống CSS variables và components
- ✅ **header.jsp** - Header với hamburger menu mobile
- ✅ **footer.jsp** - Footer responsive
- ✅ **common-head.jsp** - Meta tags chung

### 2. Pages Đã Cập Nhật (Mobile-Ready)
- ✅ **home.jsp** - Trang chủ với product grid responsive
- ✅ **login.jsp** - Form đăng nhập mobile-friendly
- ✅ **register.jsp** - Form đăng ký responsive
- ✅ **user/dashboard.jsp** - Dashboard user với menu grid
- ✅ **manager/dashboard.jsp** - Dashboard manager với charts

## 🎯 DESIGN SYSTEM

### Color Palette
```css
/* Primary */
--primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%)
--primary-color: #667eea
--primary-dark: #764ba2

/* Roles */
--user-color: #cc3399
--manager-color: #667eea  
--admin-color: #2d3748

/* Semantic */
--secondary-color: #48bb78 (green)
--warning-color: #ed8936 (orange)
--danger-color: #dc3545 (red)
--info-color: #4299e1 (blue)
```

### Breakpoints
- **Mobile**: < 640px (1 column)
- **Tablet**: 640px - 1023px (2 columns)
- **Desktop**: >= 1024px (3-4 columns)

### Typography
- Base: 14px
- Mobile h1: 24px
- Desktop h1: 32px
- Font: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif

### Spacing
- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 20px
- 2xl: 24px
- 3xl: 32px
- 4xl: 40px

## 📱 MOBILE-FIRST FEATURES

### 1. Hamburger Menu (Header)
- Hiện ở màn hình < 968px
- Slide menu từ phải sang trái
- Overlay tối khi mở menu
- Auto-close khi resize lên desktop
- Body scroll lock khi menu mở

### 2. Touch-Friendly
- Minimum tap target: 44x44px
- Button padding: 12px-16px
- Form inputs: 12px padding
- Easy-to-tap navigation items

### 3. Responsive Grids
- Auto-fit columns với minmax()
- 1 column trên mobile
- 2 columns trên tablet
- 3-4 columns trên desktop

### 4. Forms Mobile-Optimized
- Full-width inputs trên mobile
- Larger touch targets
- Stack buttons vertically nếu cần
- Clear error messages

## 🔧 COMPONENT LIBRARY

### Buttons
```html
<button class="wc-btn wc-btn-primary">Primary</button>
<button class="wc-btn wc-btn-secondary">Success</button>
<button class="wc-btn wc-btn-danger">Danger</button>
<button class="wc-btn wc-btn-sm">Small</button>
<button class="wc-btn wc-btn-lg">Large</button>
<button class="wc-btn wc-btn-block">Full Width</button>
```

### Forms
```html
<div class="wc-form-group">
    <label class="wc-form-label">Label</label>
    <input type="text" class="wc-form-input">
</div>

<div class="wc-form-group">
    <select class="wc-form-select">
        <option>Option</option>
    </select>
</div>

<div class="wc-form-group">
    <textarea class="wc-form-textarea"></textarea>
</div>
```

### Cards
```html
<div class="wc-card">
    <div class="wc-card-header">
        <h3 class="wc-card-title">Title</h3>
    </div>
    <!-- Content -->
</div>
```

### Tables (Responsive)
```html
<div class="wc-table-container">
    <table class="wc-table">
        <thead>
            <tr>
                <th>Header</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Data</td>
            </tr>
        </tbody>
    </table>
</div>
```

### Alerts
```html
<div class="wc-alert wc-alert-success">Success message</div>
<div class="wc-alert wc-alert-error">Error message</div>
<div class="wc-alert wc-alert-warning">Warning message</div>
<div class="wc-alert wc-alert-info">Info message</div>
```

### Badges
```html
<span class="wc-badge wc-badge-primary">New</span>
<span class="wc-badge wc-badge-success">Active</span>
<span class="wc-badge wc-badge-danger">Urgent</span>
```

## 📋 TEMPLATE CHUẨN

### Standard Page Template
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Title - WearConnect</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
    <style>
        /* Page-specific styles only */
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<div class="wc-container">
    <div class="wc-breadcrumb">
        <a href="${pageContext.request.contextPath}/">WearConnect</a>
        <span>›</span>
        <span>Current Page</span>
    </div>
    
    <div class="wc-page-header">
        <h1>Page Title</h1>
        <p>Description</p>
    </div>
    
    <div class="wc-card">
        <!-- Content here -->
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
```

## 📂 CÁC TRANG CẦN CẬP NHẬT

### High Priority (User-facing)
- [x] home.jsp ✅
- [x] login.jsp ✅
- [x] register.jsp ✅
- [ ] user/clothing-details.jsp
- [ ] user/booking.jsp
- [ ] user/my-orders.jsp
- [ ] user/favorites.jsp
- [ ] user/rental-history.jsp
- [ ] user/payment.jsp
- [ ] user/profile.jsp

### Medium Priority (Manager)
- [x] manager/dashboard.jsp ✅
- [ ] manager/my-clothing.jsp
- [ ] manager/upload-clothing.jsp
- [ ] manager/edit-clothing.jsp
- [ ] manager/orders.jsp
- [ ] manager/revenue.jsp

### Lower Priority (Admin)
- [ ] admin/dashboard.jsp
- [ ] admin/orders.jsp
- [ ] admin/statistics.jsp

## 🚀 HƯỚNG DẪN ÁP DỤNG

### Bước 1: Thêm Global CSS
```jsp
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css">
```

### Bước 2: Thay Thế Classes

#### Container
```html
<!-- Old -->
<div class="container">

<!-- New -->
<div class="wc-container">
```

#### Button
```html
<!-- Old -->
<button class="btn btn-primary">

<!-- New -->
<button class="wc-btn wc-btn-primary">
```

#### Form
```html
<!-- Old -->
<div class="form-group">
    <label>Label</label>
    <input type="text">
</div>

<!-- New -->
<div class="wc-form-group">
    <label class="wc-form-label">Label</label>
    <input type="text" class="wc-form-input">
</div>
```

### Bước 3: Update Inline Styles

#### Colors
```css
/* Old */
background-color: #667eea;

/* New */
background: var(--primary-gradient);
/* or */
background-color: var(--primary-color);
```

#### Spacing
```css
/* Old */
padding: 20px;
margin-bottom: 30px;

/* New */
padding: var(--spacing-xl);
margin-bottom: var(--spacing-3xl);
```

#### Shadows
```css
/* Old */
box-shadow: 0 2px 8px rgba(0,0,0,0.1);

/* New */
box-shadow: var(--shadow-md);
```

### Bước 4: Thêm Mobile Responsiveness

```css
/* Thêm vào <style> section */
@media (max-width: 639px) {
    .your-grid {
        grid-template-columns: 1fr;
    }
    .your-element {
        padding: var(--spacing-lg);
    }
}
```

## 📱 MOBILE TESTING CHECKLIST

### Mỗi Trang Phải Test:
- [ ] Hiển thị đúng trên iPhone SE (375px)
- [ ] Hiển thị đúng trên tablet (768px)
- [ ] Hamburger menu hoạt động
- [ ] Forms dễ nhập liệu
- [ ] Buttons dễ nhấn (>= 44px)
- [ ] Images responsive
- [ ] Tables scroll ngang nếu cần
- [ ] Text không bị cắt
- [ ] Navigation accessible

## 🎨 STYLING RULES

### ❌ KHÔNG NÊN
```css
/* Hardcoded colors */
color: #667eea;

/* Hardcoded spacing */
margin: 20px;

/* Inline styles */
<div style="padding: 20px;">

/* Fixed widths */
width: 300px;
```

### ✅ NÊN
```css
/* CSS variables */
color: var(--primary-color);

/* Spacing variables */
margin: var(--spacing-xl);

/* CSS classes */
<div class="wc-card">

/* Responsive widths */
max-width: 100%;
```

## 🔄 WORKFLOW

1. **Mở file JSP**
2. **Thêm global CSS vào head**
3. **Thay thế inline styles bằng CSS variables**
4. **Update classes (btn → wc-btn, etc.)**
5. **Thêm responsive media queries**
6. **Test trên mobile, tablet, desktop**
7. **Commit changes**

## 📊 PROGRESS TRACKING

- **Total Pages**: ~30
- **Completed**: 5 ✅
- **In Progress**: 0
- **Remaining**: 25
- **Progress**: 17%

---

**Last Updated**: 2026-02-03
**Version**: 2.0 - Complete Redesign
**Status**: Core System Complete, Rolling Out to Pages
