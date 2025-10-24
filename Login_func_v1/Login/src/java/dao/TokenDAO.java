package dao;

import java.sql.*;
import java.time.LocalDateTime;

public class TokenDAO extends DBContext {

    // 🔹 Lưu mã OTP vào DB, dùng cho xác minh đổi mật khẩu
    public static boolean saveOTP(int userId, String otpCode, String newPasswordHash) {
        String sql = """
                INSERT INTO PasswordTokens (Token, UserID, NewPasswordHash, ExpiresAt, Used)
                VALUES (?, ?, ?, DATEADD(MINUTE, 5, GETDATE()), 0)
                """;

        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpCode); // OTP 6 ký tự, lưu ở cột Token
            ps.setInt(2, userId);
            ps.setString(3, newPasswordHash);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error saving OTP: " + e.getMessage());
            return false;
        }
    }

    // 🔹 Kiểm tra mã OTP hợp lệ (chưa dùng, chưa hết hạn)
    public static boolean verifyOTP(int userId, String otpCode) {
        String sql = """
                SELECT 1 FROM PasswordTokens
                WHERE UserID = ? AND Token = ? AND Used = 0 AND ExpiresAt > GETDATE()
                """;

        try (Connection conn = new DBContext().getConnection();
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

    // 🔹 Đánh dấu OTP đã sử dụng
    public static void markOTPUsed(String otpCode) {
        String sql = "UPDATE PasswordTokens SET Used = 1 WHERE Token = ?";
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpCode);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error marking OTP used: " + e.getMessage());
        }
    }

    // 🔹 Xóa OTP hết hạn
    public static void cleanupExpiredTokens() {
        String sql = "DELETE FROM PasswordTokens WHERE ExpiresAt <= GETDATE() OR Used = 1";
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error cleaning up tokens: " + e.getMessage());
        }
    }
}
