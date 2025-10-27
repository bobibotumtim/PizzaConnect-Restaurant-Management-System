package dao;

import java.sql.*;
import java.time.LocalDateTime;

public class TokenDAO extends DBContext {

    // Save OTP and new password hash into PasswordTokens table
    public boolean saveOTP(int userId, String otpCode, String newPasswordHash) {
        String sql = """
                INSERT INTO PasswordTokens (Token, UserID, NewPasswordHash, ExpiresAt, Used)
                VALUES (?, ?, ?, DATEADD(MINUTE, 5, GETDATE()), 0)
                """;

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpCode);
            ps.setInt(2, userId);
            ps.setString(3, newPasswordHash);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error saving OTP: " + e.getMessage());
            return false;
        }
    }

    // Check if OTP is valid
    public boolean verifyOTP(int userId, String otpCode) {
        String sql = """
                SELECT 1 FROM PasswordTokens
                WHERE UserID = ? AND Token = ? AND Used = 0 AND ExpiresAt > GETDATE()
                """;

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, otpCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error verifying OTP: " + e.getMessage());
            return false;
        }
    }

    // Mark OTP as used
    public void markOTPUsed(String otpCode) {
        String sql = "UPDATE PasswordTokens SET Used = 1 WHERE Token = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpCode);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error marking OTP used: " + e.getMessage());
        }
    }

    // Cleanup expired or used tokens
    public void cleanupExpiredTokens() {
        String sql = "DELETE FROM PasswordTokens WHERE ExpiresAt <= GETDATE() OR Used = 1";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error cleaning up tokens: " + e.getMessage());
        }
    }
}
