package dao;

import java.sql.*;
import java.util.UUID;

public class TokenDAO extends DBContext {

    // create token to change password
    public static String createToken(int userId, String newPasswordHash) {
        String token = UUID.randomUUID().toString();
        String sql = """
                    INSERT INTO PasswordToken (Token, UserID, NewPasswordHash, ExpiresAt, Used)
                    VALUES (?, ?, ?, DATEADD(MINUTE, 15, GETDATE()), 0)
                """;
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setInt(2, userId);
            ps.setString(3, newPasswordHash);
            ps.executeUpdate();
            return token;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // verify token
    public static boolean verifyToken(String token) {
        String sql = """
                    SELECT Token FROM PasswordToken
                    WHERE Token = ? AND Used = 0 AND ExpiresAt > GETDATE()
                """;
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // get userID and password from token
    public static TokenInfo getTokenInfo(String token) {
        String sql = "SELECT UserID, NewPasswordHash FROM PasswordToken WHERE Token = ?";
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new TokenInfo(
                            rs.getInt("UserID"),
                            rs.getString("NewPasswordHash"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // set token as used
    public static void expireToken(String token) {
        String sql = "UPDATE PasswordToken SET Used = 1 WHERE Token = ?";
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // class to hold token info
    public static class TokenInfo {
        public int userId;
        public String newPasswordHash;

        public TokenInfo(int userId, String newPasswordHash) {
            this.userId = userId;
            this.newPasswordHash = newPasswordHash;
        }
    }
}
