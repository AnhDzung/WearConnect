package Model;

import java.time.LocalDateTime;

public class Account {
    private int accountID;
    private String username;
    private String password;
    private String email;
    private String userRole; // Admin, Manager, User
    private String fullName;
    private String phoneNumber;
    private String address;
    private String avatar;
    private boolean status;
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;

    // Constructor
    public Account() {
    }

    public Account(String username, String password, String email, String userRole, String fullName) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.userRole = userRole;
        this.fullName = fullName;
        this.status = true;
    }

    public Account(int accountID, String username, String password, String email, String userRole, 
                   String fullName, String phoneNumber, String address, boolean status) {
        this.accountID = accountID;
        this.username = username;
        this.password = password;
        this.email = email;
        this.userRole = userRole;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.status = status;
    }

    // Getters and Setters
    public int getAccountID() {
        return accountID;
    }

    public void setAccountID(int accountID) {
        this.accountID = accountID;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public LocalDateTime getUpdatedDate() {
        return updatedDate;
    }

    public void setUpdatedDate(LocalDateTime updatedDate) {
        this.updatedDate = updatedDate;
    }

    @Override
    public String toString() {
        return "Account{" +
                "accountID=" + accountID +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", userRole='" + userRole + '\'' +
                ", fullName='" + fullName + '\'' +
                ", status=" + status +
                '}';
    }
}
