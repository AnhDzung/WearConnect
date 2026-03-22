package Service;

import Model.Account;
import DAO.AccountDAO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

/**
 * Service xử lý Google OAuth2 authentication
 */
@Service
public class GoogleOAuth2Service {
    
    @Value("${spring.security.oauth2.client.registration.google.client-id:}")
    private String clientId;
    
    @Value("${spring.security.oauth2.client.registration.google.client-secret:}")
    private String clientSecret;
    
    /**
     * Lấy Google user info từ access token
     * @param accessToken Token từ Google
     * @return Google user information
     */
    public GoogleUserInfo getGoogleUserInfo(String accessToken) {
        try {
            String url = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=" + accessToken;
            
            URLConnection urlConnection = new URL(url).openConnection();
            InputStream inputStream = urlConnection.getInputStream();
            
            String jsonResponse = getStringFromInputStream(inputStream);
            
            JsonObject jsonObject = JsonParser.parseString(jsonResponse).getAsJsonObject();
            
            GoogleUserInfo userInfo = new GoogleUserInfo();
            userInfo.setGoogleId(jsonObject.get("id").getAsString());
            userInfo.setEmail(jsonObject.get("email").getAsString());
            userInfo.setName(jsonObject.has("name") ? jsonObject.get("name").getAsString() : "");
            userInfo.setGivenName(jsonObject.has("given_name") ? jsonObject.get("given_name").getAsString() : "");
            userInfo.setFamilyName(jsonObject.has("family_name") ? jsonObject.get("family_name").getAsString() : "");
            userInfo.setPicture(jsonObject.has("picture") ? jsonObject.get("picture").getAsString() : "");
            
            return userInfo;
        } catch (Exception e) {
            System.err.println("Error fetching Google user info: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Xử lý OAuth2 callback và tạo hoặc cập nhật user
     * @param googleUserInfo Google user information
     * @return Account object hoặc null nếu thất bại
     */
    public Account handleOAuth2Login(GoogleUserInfo googleUserInfo) {
        if (googleUserInfo == null || googleUserInfo.getEmail() == null) {
            return null;
        }
        
        // Kiểm tra user đã tồn tại với Google ID
        Account account = AccountDAO.findByGoogleID(googleUserInfo.getGoogleId());
        
        if (account != null) {
            // Update last login
            LoginHistoryDAO.recordLogin(account.getAccountID());
            return account;
        }
        
        // Kiểm tra user đã tồn tại với email
        account = AccountDAO.findByEmail(googleUserInfo.getEmail());
        
        if (account != null) {
            // Link Google account
            account.setGoogleID(googleUserInfo.getGoogleId());
            account.setOAuthProvider("Google");
            account.setOAuthID(googleUserInfo.getGoogleId());
            AccountDAO.update(account);
            LoginHistoryDAO.recordLogin(account.getAccountID());
            return account;
        }
        
        // Tạo account mới từ Google info
        String username = generateUniqueUsername(googleUserInfo.getEmail());
        Account newAccount = new Account(
            username, 
            "", // Không có password cho OAuth users
            googleUserInfo.getEmail(), 
            "User", 
            googleUserInfo.getName()
        );
        newAccount.setGoogleID(googleUserInfo.getGoogleId());
        newAccount.setOAuthProvider("Google");
        newAccount.setOAuthID(googleUserInfo.getGoogleId());
        newAccount.setAvatar(googleUserInfo.getPicture());
        
        // Create account
        if (AccountDAO.create(newAccount)) {
            // Find and return the created account
            account = AccountDAO.findByEmail(googleUserInfo.getEmail());
            if (account != null) {
                LoginHistoryDAO.recordLogin(account.getAccountID());
                return account;
            }
        }
        
        return null;
    }
    
    /**
     * Generate unique username từ email
     * @param email Email từ Google
     * @return Unique username
     */
    private String generateUniqueUsername(String email) {
        String baseUsername = email.split("@")[0];
        String username = baseUsername;
        int counter = 1;
        
        while (AuthService.isUsernameExists(username)) {
            username = baseUsername + counter;
            counter++;
        }
        
        return username;
    }
    
    /**
     * Convert InputStream to String
     */
    private String getStringFromInputStream(InputStream is) {
        Scanner scanner = new Scanner(is, StandardCharsets.UTF_8.name()).useDelimiter("\\A");
        return scanner.hasNext() ? scanner.next() : "";
    }
    
    /**
     * Inner class để lưu Google user information
     */
    public static class GoogleUserInfo {
        private String googleId;
        private String email;
        private String name;
        private String givenName;
        private String familyName;
        private String picture;
        
        public String getGoogleId() { return googleId; }
        public void setGoogleId(String googleId) { this.googleId = googleId; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getGivenName() { return givenName; }
        public void setGivenName(String givenName) { this.givenName = givenName; }
        
        public String getFamilyName() { return familyName; }
        public void setFamilyName(String familyName) { this.familyName = familyName; }
        
        public String getPicture() { return picture; }
        public void setPicture(String picture) { this.picture = picture; }
    }
}
