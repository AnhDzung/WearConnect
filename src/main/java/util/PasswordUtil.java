package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 * Simple salted SHA-256 password hashing utility.
 * Stores passwords as "salt$hash" for non-admin accounts.
 */
public class PasswordUtil {

    private static final int SALT_BYTES = 16;

    public static String hashPassword(String plain) {
        String salt = generateSaltHex(SALT_BYTES);
        String hash = sha256Hex(salt + plain);
        return salt + "$" + hash;
    }

    public static boolean verifyPassword(String plain, String stored) {
        if (stored == null) return false;
        if (isSaltedHash(stored)) {
            String[] parts = stored.split("\\$", 2);
            String salt = parts[0];
            String expectedHash = parts[1];
            String computed = sha256Hex(salt + plain);
            return constantTimeEquals(expectedHash, computed);
        }
        // Fallback: plain text comparison for legacy/admin
        return stored.equals(plain);
    }

    public static boolean isSaltedHash(String stored) {
        if (stored == null) return false;
        int idx = stored.indexOf('$');
        if (idx <= 0) return false;
        String salt = stored.substring(0, idx);
        String hash = stored.substring(idx + 1);
        return isHex(salt) && isHex(hash) && hash.length() == 64; // SHA-256 hex length
    }

    private static String generateSaltHex(int bytes) {
        SecureRandom rng = new SecureRandom();
        byte[] salt = new byte[bytes];
        rng.nextBytes(salt);
        return toHex(salt);
    }

    private static String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            return toHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private static boolean isHex(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))) {
                return false;
            }
        }
        return true;
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) return false;
        if (a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
