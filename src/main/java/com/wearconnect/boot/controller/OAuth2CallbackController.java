package com.wearconnect.boot.controller;

import Model.Account;
import Service.GoogleOAuth2Service;
import Service.GoogleOAuth2Service.GoogleUserInfo;
import Service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller xử lý OAuth2 callback từ Google
 */
@RestController
public class OAuth2CallbackController {
    
    @Autowired(required = false)
    private GoogleOAuth2Service googleOAuth2Service;

    @Value("${spring.security.oauth2.client.registration.google.client-id:}")
    private String configuredClientId;

    @Value("${spring.security.oauth2.client.registration.google.client-secret:}")
    private String configuredClientSecret;
    
    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";

    private String resolveClientId() {
        if (configuredClientId != null && !configuredClientId.isBlank()
                && !"local-dev-client-id".equals(configuredClientId)) {
            return configuredClientId;
        }
        String envValue = System.getenv("GOOGLE_CLIENT_ID");
        return (envValue == null || envValue.isBlank()) ? null : envValue;
    }

    private String resolveClientSecret() {
        if (configuredClientSecret != null && !configuredClientSecret.isBlank()
                && !"local-dev-client-secret".equals(configuredClientSecret)) {
            return configuredClientSecret;
        }
        String envValue = System.getenv("GOOGLE_CLIENT_SECRET");
        return (envValue == null || envValue.isBlank()) ? null : envValue;
    }
    
    /**
     * Google OAuth2 callback endpoint
     */
    @GetMapping("/oauth2/callback/google")
    public void handleGoogleCallback(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "error", required = false) String error,
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        
        try {
            // Kiểm tra lỗi từ Google
            if (error != null) {
                System.err.println("Google OAuth2 Error: " + error);
                response.sendRedirect(request.getContextPath() + "/login?error=oauth_error");
                return;
            }
            
            // Kiểm tra authorization code
            if (code == null || code.isEmpty()) {
                System.err.println("Missing authorization code from Google");
                response.sendRedirect(request.getContextPath() + "/login?error=missing_code");
                return;
            }
            
            // Khởi tạo service nếu chưa có
            if (googleOAuth2Service == null) {
                googleOAuth2Service = new GoogleOAuth2Service();
            }
            
            // Exchange authorization code với access token
            String accessToken = exchangeCodeForToken(code, request);
            
            if (accessToken == null || accessToken.isEmpty()) {
                System.err.println("Failed to get access token from Google");
                response.sendRedirect(request.getContextPath() + "/login?error=token_exchange_failed");
                return;
            }
            
            // Lấy user information từ Google
            GoogleUserInfo googleUserInfo = googleOAuth2Service.getGoogleUserInfo(accessToken);
            
            if (googleUserInfo == null) {
                System.err.println("Failed to get user info from Google");
                response.sendRedirect(request.getContextPath() + "/login?error=user_info_failed");
                return;
            }
            
            // Xử lý OAuth2 login
            Account account = googleOAuth2Service.handleOAuth2Login(googleUserInfo);
            
            if (account == null) {
                System.err.println("Failed to handle OAuth2 login");
                response.sendRedirect(request.getContextPath() + "/login?error=oauth_login_failed");
                return;
            }
            
            // Tạo session
            HttpSession session = request.getSession(true);
            session.setAttribute("account", account);
            session.setAttribute("accountID", account.getAccountID());
            session.setAttribute("userRole", account.getUserRole());
            session.setMaxInactiveInterval(30 * 60);
            
            // Redirect dựa trên role
            String role = account.getUserRole();
            if (role != null) {
                role = role.trim();
            }

            if ("User".equals(role) || "Manager".equals(role)) {
                checkProfileCompletionAndNotify(account);
            }

            if ("Admin".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else if ("Manager".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/manager");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
            
        } catch (Exception e) {
            System.err.println("Error in OAuth2 callback: " + e.getMessage());
            e.printStackTrace();
            try {
                response.sendRedirect(request.getContextPath() + "/login?error=server_error");
            } catch (IOException ioException) {
                ioException.printStackTrace();
            }
        }
    }
    
    /**
     * Exchange authorization code với access token
     */
    private String exchangeCodeForToken(String code, HttpServletRequest request) {
        try {
            // Lấy client credentials từ environment hoặc application.properties
            String clientId = resolveClientId();
            String clientSecret = resolveClientSecret();
            String redirectUri = request.getScheme() + "://" + request.getServerName() + 
                               ":" + request.getServerPort() + 
                               request.getContextPath() + "/oauth2/callback/google";
            
            if (clientId == null || clientSecret == null) {
                System.err.println("Missing Google credentials in environment");
                return null;
            }

            // Google token endpoint yêu cầu application/x-www-form-urlencoded
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

            MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
            form.add("code", code);
            form.add("client_id", clientId);
            form.add("client_secret", clientSecret);
            form.add("redirect_uri", redirectUri);
            form.add("grant_type", "authorization_code");

            HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(form, headers);

            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.postForObject(GOOGLE_TOKEN_URL, requestEntity, String.class);
            
            if (response != null) {
                JsonObject jsonResponse = JsonParser.parseString(response).getAsJsonObject();
                if (jsonResponse.has("access_token")) {
                    return jsonResponse.get("access_token").getAsString();
                }

                if (jsonResponse.has("error")) {
                    String error = jsonResponse.get("error").getAsString();
                    String desc = jsonResponse.has("error_description")
                            ? jsonResponse.get("error_description").getAsString()
                            : "";
                    System.err.println("Google token error: " + error + " - " + desc);
                }
            }
        } catch (Exception e) {
            System.err.println("Error exchanging code for token: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Redirect endpoint để initiate Google OAuth2 flow
     */
    @GetMapping("/oauth2/authorize/google")
    public void authorizeGoogle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String clientId = resolveClientId();
            String redirectUri = request.getScheme() + "://" + request.getServerName() + 
                               ":" + request.getServerPort() + 
                               request.getContextPath() + "/oauth2/callback/google";
            
            if (clientId == null) {
                response.sendRedirect(request.getContextPath() + "/login?error=config_missing");
                return;
            }
            
            String googleAuthUrl = String.format(
                "https://accounts.google.com/o/oauth2/v2/auth?" +
                "client_id=%s&" +
                "redirect_uri=%s&" +
                "response_type=code&" +
                "scope=%s&" +
                "access_type=offline",
                clientId,
                java.net.URLEncoder.encode(redirectUri, "UTF-8"),
                java.net.URLEncoder.encode("profile email", "UTF-8")
            );
            
            response.sendRedirect(googleAuthUrl);
        } catch (Exception e) {
            System.err.println("Error in authorize: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login?error=server_error");
        }
    }

    private void checkProfileCompletionAndNotify(Account account) {
        try {
            boolean isIncomplete = false;
            StringBuilder missingFields = new StringBuilder();

            if (account.getPhoneNumber() == null || account.getPhoneNumber().trim().isEmpty()) {
                isIncomplete = true;
                missingFields.append("Số điện thoại, ");
            }
            if (account.getAddress() == null || account.getAddress().trim().isEmpty()) {
                isIncomplete = true;
                missingFields.append("Địa chỉ, ");
            }
            try {
                if (account.getBankAccountNumber() == null || account.getBankAccountNumber().trim().isEmpty()) {
                    isIncomplete = true;
                    missingFields.append("Số tài khoản ngân hàng, ");
                }
            } catch (Exception e) {
                isIncomplete = true;
                missingFields.append("Số tài khoản ngân hàng, ");
            }
            try {
                if (account.getBankName() == null || account.getBankName().trim().isEmpty()) {
                    isIncomplete = true;
                    missingFields.append("Tên ngân hàng, ");
                }
            } catch (Exception e) {
                isIncomplete = true;
                missingFields.append("Tên ngân hàng, ");
            }

            if (isIncomplete && missingFields.length() > 0) {
                String fields = missingFields.substring(0, missingFields.length() - 2);
                String role = account.getUserRole() == null ? "" : account.getUserRole().trim();
                String chatbotGuidance = "Manager".equals(role)
                        ? "Bên cạnh đó nếu bạn muốn tìm hiểu về quy trình đăng tải quần áo lên website thì có thể vào phần chatbot và hỏi về quy trình đăng tải quần áo."
                        : "Bên cạnh đó nếu bạn muốn tìm hiểu về quy trình thuê hàng thì có thể vào phần chatbot và hỏi về quy trình đặt thuê.";

                String message = "Cảm ơn bạn đã tin tưởng và sử dụng WearConnect. Hãy cập nhật đầy đủ thông tin của bạn trong profile để trải nghiệm tốt hơn!"
                        + "\n\nThông tin chưa đầy đủ: " + fields + "\n\n" + chatbotGuidance;

                NotificationService.createNotificationOnceByTitle(
                        account.getAccountID(),
                        "Cập nhật thông tin Profile",
                        message
                );
            }
        } catch (Exception e) {
            System.err.println("Error checking profile completion (OAuth): " + e.getMessage());
        }
    }
}
