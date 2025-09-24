package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.User;

public class UserDAO extends MyDAO {

    // Đăng ký User mới
    public boolean insertUser(User user) {
    xSql = "INSERT INTO [User] (Username, Email, Password, Phone, Role) VALUES (?, ?, ?, ?, ?)";
    try {
        ps = con.prepareStatement(xSql);
        ps.setString(1, user.getUsername());
        ps.setString(2, user.getEmail());
        ps.setString(3, user.getPassword());
        ps.setString(4, user.getPhone());
        ps.setInt(5, user.getRole()); // caller phải set role (ví dụ 1=admin,2=user)
        return ps.executeUpdate() > 0;
    } catch (java.sql.SQLIntegrityConstraintViolationException icv) {
        // duplicate key (username/email/phone) - xử lý theo ý bạn (log / trả về false)
        icv.printStackTrace();
        return false;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    } finally {
        close();
    }
}


    // Kiểm tra login
    public User checkLogin(String username, String password) {
    User user = null;
        System.out.println("check");
    xSql = "SELECT * FROM [User] WHERE Username = ? AND Password = ?";
    try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
                user = new User(
                        rs.getInt("UserID"),
                        rs.getString("Username"),
                        rs.getString("Email"),
                        rs.getString("Password"),
                        rs.getString("Phone"),
                        rs.getInt("Role")
                );
            }
        } catch (Exception e) {
        e.printStackTrace();
    }
    return user;
}
    
    public User getUserId(int id) {
    User user = null;
        System.out.println("check");
    xSql = "SELECT * FROM [User] WHERE UserID = ?";
    try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                user = new User(
                        rs.getInt("UserID"),
                        rs.getString("Username"),
                        rs.getString("Email"),
                        rs.getString("Password"),
                        rs.getString("Phone"),
                        rs.getInt("Role")
                );
            }
        } catch (Exception e) {
        e.printStackTrace();
    }
    return user;
}

    // Lấy toàn bộ User
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User]";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new User(
                        rs.getInt("UserID"),
                        rs.getString("Email"),
                        rs.getString("Password"),
                        rs.getString("Phone"),
                        rs.getInt("Role")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Cập nhật thông tin User
    public boolean updateUser(User user) {
    String sql = "UPDATE [User] SET Username=?, Email=?, Password=?, Phone=?, Role=? WHERE UserID=?";
    try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, user.getUsername());
        ps.setString(2, user.getEmail());
        ps.setString(3, user.getPassword());
        ps.setString(4, user.getPhone());
        ps.setInt(5, user.getRole());
        ps.setInt(6, user.getUserID());
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}


    // Xóa User
    public boolean deleteUser(int userID) {
        String sql = "DELETE FROM [User] WHERE UserID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isUserExists(String user) {
        xSql = "SELECT 1 FROM [User] WHERE Username = ? OR Email = ? OR Phone = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, user);
            ps.setString(2, user);
            ps.setString(3, user);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    public boolean resetPassword(String user, String newPass) {
        Integer userId = findUserIdByIdentifier(user);
        if (userId == null) return false;

        xSql = "UPDATE [User] SET Password = ? WHERE UserID = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, newPass);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    public Integer findUserIdByIdentifier(String identifier) {
        xSql = "SELECT UserID FROM [User] WHERE Username = ? OR Email = ? OR Phone = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            ps.setString(3, identifier);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return null;
    }
    private void close() {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (Exception e) {
        }
        try {
            if (ps != null) {
                ps.close();
            }
        } catch (Exception e) {
        }
    }
}
