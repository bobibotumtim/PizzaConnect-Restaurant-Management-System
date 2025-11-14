package dao;

import java.sql.*;
import java.util.UUID;

public class TokenDAO extends DBContext {

    // Lưu OTP và mật khẩu mới đã hash
    public boolean saveOTP(int userID, String otpCode, String hashedNewPassword) {
        String sql = "INSERT INTO PasswordTokens (Token, UserID, NewPasswordHash, ExpiresAt) VALUES (?, ?, ?, DATEADD(MINUTE, 5, GETDATE()))";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, otpCode);
            ps.setInt(2, userID);
            ps.setString(3, hashedNewPassword);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error saving OTP: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Xác thực OTP
    public boolean verifyOTP(int userID, String otpCode) {
        String sql = "SELECT Token FROM PasswordTokens WHERE UserID = ? AND Token = ? AND Used = 0 AND ExpiresAt > GETDATE()";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ps.setString(2, otpCode);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // OTP hợp lệ nếu có kết quả
            }
        } catch (SQLException e) {
            System.err.println("Error verifying OTP: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Đánh dấu OTP đã sử dụng
    public boolean markOTPUsed(String otpCode) {
        String sql = "UPDATE PasswordTokens SET Used = 1 WHERE Token = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, otpCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error marking OTP as used: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Lấy mật khẩu mới đã hash từ OTP
    public String getHashedPasswordFromOTP(String otpCode) {
        String sql = "SELECT NewPasswordHash FROM PasswordTokens WHERE Token = ? AND Used = 0 AND ExpiresAt > GETDATE()";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, otpCode);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("NewPasswordHash");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting hashed password from OTP: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Dọn dẹp OTP hết hạn
    public void cleanupExpiredTokens() {
        String sql = "DELETE FROM PasswordTokens WHERE ExpiresAt <= GETDATE() OR Used = 1";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error cleaning up expired tokens: " + e.getMessage());
            e.printStackTrace();
        }
    }
}