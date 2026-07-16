<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/jsp/components/head.jsp" />
    <title>Cài đặt ứng dụng - WearConnect</title>
    
    <style>
        /* Modern Gradient & Glassmorphism Design System */
        .install-hero {
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.05) 0%, rgba(168, 85, 247, 0.05) 50%, rgba(6, 182, 212, 0.05) 100%);
            padding: 60px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            position: relative;
            overflow: hidden;
        }
        
        .install-hero::before {
            content: '';
            position: absolute;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(99, 102, 241, 0.15) 0%, transparent 70%);
            top: -100px;
            left: -50px;
            z-index: 0;
        }

        .install-hero::after {
            content: '';
            position: absolute;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(6, 182, 212, 0.1) 0%, transparent 70%);
            bottom: -100px;
            right: -50px;
            z-index: 0;
        }

        .install-hero-content {
            position: relative;
            z-index: 1;
            max-width: 700px;
            margin: 0 auto;
        }

        .install-logo-wrapper {
            margin-bottom: 20px;
            display: inline-block;
            position: relative;
        }

        .install-logo-glow {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 100px;
            height: 100px;
            background: var(--primary-gradient);
            filter: blur(25px);
            opacity: 0.45;
            border-radius: 50%;
            z-index: -1;
            animation: pulse-glow 4s infinite alternate;
        }

        @keyframes pulse-glow {
            0% { transform: translate(-50%, -50%) scale(0.9); opacity: 0.35; }
            100% { transform: translate(-50%, -50%) scale(1.1); opacity: 0.55; }
        }

        .install-logo-img {
            width: 80px;
            height: 80px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(99, 102, 241, 0.25);
            background: white;
            padding: 8px;
        }

        .install-title {
            font-size: 2.25rem;
            font-weight: 800;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 12px;
            letter-spacing: -0.5px;
        }

        .install-subtitle {
            color: var(--gray-600);
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 0;
            font-weight: 500;
        }

        .install-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
        }

        /* Tabs Switching */
        .install-tabs {
            display: flex;
            background: var(--gray-200);
            padding: 6px;
            border-radius: var(--radius-xl);
            margin-bottom: 35px;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
            position: relative;
            gap: 4px;
        }

        .install-tab-btn {
            flex: 1;
            padding: 14px 20px;
            border: none;
            background: transparent;
            color: var(--gray-600);
            font-weight: 700;
            font-size: 1.05rem;
            cursor: pointer;
            border-radius: var(--radius-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all var(--transition-base);
        }

        .install-tab-btn svg {
            width: 22px;
            height: 22px;
            transition: transform var(--transition-fast);
        }

        .install-tab-btn:hover svg {
            transform: scale(1.1);
        }

        .install-tab-btn.active {
            background: white;
            color: var(--primary-color);
            box-shadow: var(--shadow-md);
        }

        .install-tab-btn.active svg {
            fill: var(--primary-color);
        }

        /* Instruction Cards */
        .instruction-content {
            display: none;
            animation: fadeIn 0.4s ease-out forwards;
        }

        .instruction-content.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Warning alert for iOS */
        .ios-warning-alert {
            background: rgba(245, 158, 11, 0.08);
            border-left: 4px solid var(--warning-color);
            border-radius: var(--radius-md);
            padding: 16px 20px;
            margin-bottom: 30px;
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }

        .ios-warning-icon {
            color: var(--warning-color);
            flex-shrink: 0;
            margin-top: 2px;
        }

        .ios-warning-text {
            color: #78350f;
            font-size: 0.95rem;
            font-weight: 600;
            line-height: 1.5;
            margin: 0;
        }

        /* Steps Layout */
        .step-card {
            background: white;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-2xl);
            padding: 30px;
            margin-bottom: 25px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            box-shadow: var(--shadow-sm);
            transition: transform 0.25s, box-shadow 0.25s;
        }

        .step-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
            border-color: rgba(99, 102, 241, 0.2);
        }

        @media (max-width: 768px) {
            .step-card {
                grid-template-columns: 1fr;
                gap: 20px;
                padding: 20px;
            }
        }

        .step-info {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .step-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }

        .step-number {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: var(--primary-gradient);
            color: white;
            font-weight: 800;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.3);
        }

        .step-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--gray-900);
            margin: 0;
        }

        .step-desc {
            color: var(--gray-600);
            font-size: 0.95rem;
            line-height: 1.6;
            margin: 0;
            font-weight: 500;
        }

        /* Mockup Previews */
        .step-preview {
            background: var(--gray-50);
            border: 1px dashed var(--gray-300);
            border-radius: var(--radius-xl);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
            min-height: 180px;
        }

        /* Browser elements simulation */
        .chrome-mock-dots {
            display: flex;
            flex-direction: column;
            gap: 4px;
            background: var(--gray-200);
            padding: 10px;
            border-radius: 50%;
            cursor: pointer;
            transition: background 0.2s;
        }
        .chrome-mock-dots span {
            width: 5px;
            height: 5px;
            background: var(--gray-700);
            border-radius: 50%;
        }

        .mock-phone-bar {
            background: #f1f5f9;
            border-radius: var(--radius-full);
            padding: 10px 20px;
            font-size: 13px;
            font-weight: 600;
            color: var(--gray-600);
            border: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .mock-action-box {
            background: white;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            padding: 12px 18px;
            box-shadow: var(--shadow-md);
            font-weight: 700;
            color: var(--gray-900);
            display: flex;
            align-items: center;
            gap: 10px;
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-6px); }
        }

        .ios-share-mock {
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #e2e8f0;
            border-radius: 10px;
            color: #007aff;
            cursor: pointer;
            transition: background 0.2s;
        }

        .app-install-card {
            background: white;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            width: 250px;
            box-shadow: var(--shadow-sm);
        }

        .app-install-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: var(--primary-gradient);
            padding: 4px;
        }

        .app-install-info {
            display: flex;
            flex-direction: column;
        }
        .app-install-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--gray-900);
        }
        .app-install-url {
            font-size: 11px;
            color: var(--gray-400);
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/components/header.jsp" />

<!-- Hero Header Section -->
<div class="install-hero">
    <div class="install-hero-content">
        <div class="install-logo-wrapper">
            <div class="install-logo-glow"></div>
            <img class="install-logo-img" src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="WearConnect Logo" onerror="this.onerror=null;this.src='https://placehold.co/100x100/6366f1/ffffff?text=WC';">
        </div>
        <h1 class="install-title">Cài đặt ứng dụng WearConnect</h1>
        <p class="install-subtitle">
            Trải nghiệm WearConnect siêu tốc, tiết kiệm pin & dữ liệu di động, hoạt động như app bản địa trực tiếp trên màn hình chính của bạn.
        </p>
    </div>
</div>

<!-- Main Grid Container -->
<div class="install-container">
    
    <!-- Tab Selectors -->
    <div class="install-tabs">
        <button class="install-tab-btn active" onclick="switchTab('android')" id="tab-android-btn">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
                <path d="M12 2c5.52 0 10 4.48 10 10s-4.48 10-10 10S2 17.52 2 12 6.48 2 12 2zm-1 7h-2c-.55 0-1 .45-1 1v1h4v-1c0-.55-.45-1-1-1zm6 0h-2c-.55 0-1 .45-1 1v1h4v-1c0-.55-.45-1-1-1zm-6 4H7v4h4v-4zm6 0h-4v4h4v-4z"/>
            </svg>
            Android
        </button>
        <button class="install-tab-btn" onclick="switchTab('ios')" id="tab-ios-btn">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.21.67-2.93 1.49-.62.69-1.16 1.84-1.01 2.96 1.12.09 2.27-.57 2.95-1.39z"/>
            </svg>
            iOS / iPhone
        </button>
    </div>

    <!-- Android Content -->
    <div id="content-android" class="instruction-content active">
        
        <!-- Step 1 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">1</div>
                    <h3 class="step-title">Mở menu trình duyệt</h3>
                </div>
                <p class="step-desc">
                    Hãy truy cập WearConnect bằng trình duyệt <strong>Google Chrome</strong> trên thiết bị Android của bạn. Sau đó nhấn vào biểu tượng <strong>"⋮" (3 chấm dọc)</strong> nằm ở góc trên bên phải màn hình.
                </p>
            </div>
            <div class="step-preview">
                <div class="mock-phone-bar">
                    <span>wearconnect.com</span>
                    <div class="chrome-mock-dots" style="border: 2px solid var(--primary-color);">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Step 2 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">2</div>
                    <h3 class="step-title">Chọn "Thêm vào màn hình chính"</h3>
                </div>
                <p class="step-desc">
                    Cuộn danh sách menu vừa hiện ra xuống dưới và nhấn chọn mục <strong>"Thêm vào Màn hình chính"</strong> (hoặc <strong>"Add to Home screen"</strong> / <strong>"Cài đặt ứng dụng"</strong>).
                </p>
            </div>
            <div class="step-preview">
                <div class="mock-action-box" style="border: 2px solid var(--primary-color);">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                        <path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/>
                    </svg>
                    <span>Thêm vào MH chính</span>
                </div>
            </div>
        </div>

        <!-- Step 3 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">3</div>
                    <h3 class="step-title">Xác nhận và cài đặt</h3>
                </div>
                <p class="step-desc">
                    Một hộp thoại xác nhận sẽ hiện lên hiển thị tên ứng dụng. Hãy giữ tên mặc định là <strong>WearConnect</strong> và nhấn nút <strong>"Thêm" (Add)</strong> hoặc <strong>"Cài đặt"</strong> để hoàn tất.
                </p>
            </div>
            <div class="step-preview">
                <div class="app-install-card" style="border: 2px solid var(--primary-color);">
                    <div class="app-install-icon">
                        <img src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="Icon" style="width:100%; height:100%; object-fit:contain;">
                    </div>
                    <div class="app-install-info">
                        <div class="app-install-name">WearConnect</div>
                        <div class="app-install-url">Cài đặt ứng dụng</div>
                    </div>
                    <button style="margin-left:auto; background:var(--primary-color); border:none; color:white; padding:6px 12px; border-radius:15px; font-size:11px; font-weight:700; cursor:pointer;">Cài đặt</button>
                </div>
            </div>
        </div>

        <!-- Step 4 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">4</div>
                    <h3 class="step-title">Mở ứng dụng</h3>
                </div>
                <p class="step-desc">
                    Trở về màn hình chính điện thoại, bạn sẽ thấy biểu tượng logo **WearConnect** xuất hiện. Nhấp vào biểu tượng này để mở ứng dụng với trải nghiệm toàn màn hình cực kỳ mượt mà.
                </p>
            </div>
            <div class="step-preview">
                <div style="display:flex; flex-direction:column; align-items:center; gap:8px;">
                    <img src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="App Icon" style="width:60px; height:60px; border-radius:14px; box-shadow:0 8px 16px rgba(0,0,0,0.15);">
                    <span style="font-size:12px; font-weight:700; color:var(--gray-800);">WearConnect</span>
                </div>
            </div>
        </div>

    </div>

    <!-- iOS Content -->
    <div id="content-ios" class="instruction-content">
        
        <!-- iOS Warning -->
        <div class="ios-warning-alert">
            <div class="ios-warning-icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>
                </svg>
            </div>
            <div>
                <h4 style="margin:0 0 4px 0; font-size:0.95rem; color:#78350f;">Lưu ý quan trọng trên iOS</h4>
                <p class="ios-warning-text">
                    Hệ điều hành iOS chỉ hỗ trợ cài đặt PWA trực tiếp qua trình duyệt <strong>Safari gốc</strong>. Nếu bạn đang truy cập bằng Chrome, Firefox hoặc ứng dụng mạng xã hội, vui lòng sao chép liên kết trang này và mở lại bằng trình duyệt <strong>Safari</strong>.
                </p>
            </div>
        </div>

        <!-- Step 1 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">1</div>
                    <h3 class="step-title">Mở Safari (Bắt buộc)</h3>
                </div>
                <p class="step-desc">
                    Đảm bảo bạn đang truy cập website WearConnect trên trình duyệt **Safari** mặc định của iPhone hoặc iPad.
                </p>
            </div>
            <div class="step-preview">
                <div style="background:white; padding:15px; border-radius:50%; box-shadow:var(--shadow-md);">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="50" height="50" fill="#007aff">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1.79 13.79c-.39.39-1.02.39-1.41 0l-4.59-4.59c-.39-.39-.39-1.02 0-1.41s1.02-.39 1.41 0L12 12.59l3.79-3.79c.39-.39 1.02-.39 1.41 0s.39 1.02 0 1.41l-4.59 4.59c-.2.2-.45.3-.71.3z"/>
                    </svg>
                </div>
            </div>
        </div>

        <!-- Step 2 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">2</div>
                    <h3 class="step-title">Nhấn nút Chia sẻ</h3>
                </div>
                <p class="step-desc">
                    Nhấn vào biểu tượng **Chia sẻ (Share)** ở thanh công cụ dưới cùng của trình duyệt Safari (biểu tượng hình vuông có mũi tên hướng lên).
                </p>
            </div>
            <div class="step-preview">
                <div class="ios-share-mock" style="border: 2px solid var(--primary-color); padding: 8px;">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8M16 6l-4-4-4 4M12 2v13"/>
                    </svg>
                </div>
            </div>
        </div>

        <!-- Step 3 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">3</div>
                    <h3 class="step-title">Chọn "Thêm vào màn hình chính"</h3>
                </div>
                <p class="step-desc">
                    Cuộn danh sách menu hành động hiện lên từ dưới màn hình, tìm và nhấn chọn mục **"Thêm vào MH chính" (Add to Home Screen)**.
                </p>
            </div>
            <div class="step-preview">
                <div class="mock-action-box" style="border: 2px solid var(--primary-color);">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                        <line x1="12" y1="8" x2="12" y2="16"/>
                        <line x1="8" y1="12" x2="16" y2="12"/>
                    </svg>
                    <span>Thêm vào MH chính</span>
                </div>
            </div>
        </div>

        <!-- Step 4 -->
        <div class="step-card">
            <div class="step-info">
                <div class="step-header">
                    <div class="step-number">4</div>
                    <h3 class="step-title">Xác nhận và Hoàn tất</h3>
                </div>
                <p class="step-desc">
                    Đặt tên hiển thị mong muốn hoặc để mặc định là **WearConnect**, sau đó nhấn **"Thêm" (Add)** ở góc trên bên phải màn hình. Biểu tượng ứng dụng sẽ xuất hiện trên màn hình chính của bạn.
                </p>
            </div>
            <div class="step-preview">
                <div style="display:flex; flex-direction:column; align-items:center; gap:8px;">
                    <img src="${pageContext.request.contextPath}/assets/images/wear-connect-logo.png" alt="App Icon" style="width:60px; height:60px; border-radius:14px; box-shadow:0 8px 16px rgba(0,0,0,0.15);">
                    <span style="font-size:12px; font-weight:700; color:var(--gray-800);">WearConnect</span>
                </div>
            </div>
        </div>

    </div>

</div>

<!-- JS Tab switcher -->
<script>
    function switchTab(device) {
        // Update tabs active state
        document.querySelectorAll('.install-tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelectorAll('.instruction-content').forEach(content => {
            content.classList.remove('active');
        });

        // Set current active
        if (device === 'android') {
            document.getElementById('tab-android-btn').classList.add('active');
            document.getElementById('content-android').classList.add('active');
        } else if (device === 'ios') {
            document.getElementById('tab-ios-btn').classList.add('active');
            document.getElementById('content-ios').classList.add('active');
        }
    }
</script>

<jsp:include page="/WEB-INF/jsp/components/footer.jsp" />
</body>
</html>
