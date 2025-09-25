package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.User;

public class UserDAO extends DBContext {

    // ✅ Kiểm tra user đã tồn tại hay chưa (username hoặc email)
    public boolean isUserExists(String user) {
    String sql = "SELECT 1 FROM [User] WHERE Username = ? OR Email = ? OR Phone = ?";
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, user);
        ps.setString(2, user);
        ps.setString(3, user);
        try (ResultSet rs = ps.executeQuery()) {
            return rs.next(); // true nếu tồn tại ít nhất một user
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

    // ✅ Thêm user mới
    
    public int insertUser(User user) {
    String sql = "INSERT INTO [User] (Username, Email, Password, Phone, Role) VALUES (?,?,?,?,?)";
    try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        ps.setString(1, user.getUsername());
        ps.setString(2, user.getEmail());
        ps.setString(3, user.getPassword());
        ps.setString(4, user.getPhone());
        ps.setInt(5, user.getRole());

        int affectedRows = ps.executeUpdate();
        if (affectedRows > 0) {
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // trả về UserID
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return -1; // thất bại
}

    // ✅ Kiểm tra đăng nhập
    public User checkLogin(String username, String password) {
        String sql = "SELECT * FROM [User] WHERE Username = ? AND Password = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Lấy thông tin user theo ID
    public User getUserId(int userId) {
        String sql = "SELECT * FROM [User] WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Lấy danh sách tất cả user
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User]";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Cập nhật thông tin user
    public boolean updateUser(User user) {
        String sql = "UPDATE [User] SET Username=?, Email=?, Password=?, Phone=?, Role=? WHERE UserID=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setInt(5, user.getRole());
            ps.setInt(6, user.getUserID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Xóa user theo ID
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM [User] WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Đặt lại mật khẩu bằng username/email/phone
    public boolean resetPassword(String identifier, String newPassword) {
        Integer userId = findUserIdByIdentifier(identifier);
        if (userId == null) return false;

        String sql = "UPDATE [User] SET Password = ? WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Tìm UserID dựa trên username/email/phone
    public Integer findUserIdByIdentifier(String identifier) {
        String sql = "SELECT UserID FROM [User] WHERE Username = ? OR Email = ? OR Phone = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            ps.setString(3, identifier);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("UserID");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Hàm tiện ích: chuyển ResultSet -> User
    private User mapUser(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("UserID"),
            rs.getString("Username"),
            rs.getString("Email"),
            rs.getString("Password"),
            rs.getString("Phone"),
            rs.getInt("Role")
        );
    }
}
