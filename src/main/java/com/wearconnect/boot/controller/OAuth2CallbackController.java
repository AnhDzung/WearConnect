package com.wearconnect.boot.controller;

import Model.Account;
import Service.GoogleOAuth2Service;
import Service.GoogleOAuth2Service.GoogleUserInfo;
import Controller.AuthController;
import org.springframework.beans.factory.annotation.Autowired;
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
    
    private static final String GOOGLE_TOKEN_URL = "https://www.googleapis.com/oauth2/v4/token";
    
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
            String clientId = System.getenv("GOOGLE_CLIENT_ID");
            String clientSecret = System.getenv("GOOGLE_CLIENT_SECRET");
            String redirectUri = request.getScheme() + "://" + request.getServerName() + 
                               ":" + request.getServerPort() + 
                               request.getContextPath() + "/oauth2/callback/google";
            
            if (clientId == null || clientSecret == null) {
                System.err.println("Missing Google credentials in environment");
                return null;
            }
            
            // Prepare token request
            String tokenRequestBody = String.format(
                "code=%s&client_id=%s&client_secret=%s&redirect_uri=%s&grant_type=authorization_code",
                code, clientId, clientSecret, java.net.URLEncoder.encode(redirectUri, "UTF-8")
            );
            
            // Use RestTemplate hoặc HttpClient để gọi Google token endpoint
            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.postForObject(GOOGLE_TOKEN_URL, tokenRequestBody, String.class);
            
            if (response != null) {
                JsonObject jsonResponse = JsonParser.parseString(response).getAsJsonObject();
                if (jsonResponse.has("access_token")) {
                    return jsonResponse.get("access_token").getAsString();
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
            String clientId = System.getenv("GOOGLE_CLIENT_ID");
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
}
