package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.User;

public class UserDAO extends DBContext {

    // ✅ Kiểm tra user đã tồn tại hay chưa (Email)
    public boolean isUserExists(String email) {
        String sql = "SELECT 1 FROM [User] WHERE Email = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Thêm user mới
    public int insertUser(User user) {
        String sql = """
            INSERT INTO [User] 
            (Name, Password, Role, Email, Phone, DateOfBirth, Gender, IsActive)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getPassword());
            ps.setInt(3, user.getRole());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            if (user.getDateOfBirth() != null) {
                ps.setDate(6, new java.sql.Date(user.getDateOfBirth().getTime()));
            } else {
                ps.setNull(6, Types.DATE);
            }
            ps.setString(7, user.getGender());
            ps.setBoolean(8, user.isActive());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1); // Trả về UserID
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Thất bại
    }

    // ✅ Kiểm tra đăng nhập
    public User checkLogin(String EmailOrPhone, String password) {
        String sql = """
            SELECT * FROM [User] 
            WHERE (Email = ? OR Phone = ?) 
              AND Password = ? AND IsActive = 1
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, EmailOrPhone);
            ps.setString(2, EmailOrPhone);
            ps.setString(3, password);
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

    public User getUserById(int userId) {
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
    // Debug: in ra số bản ghi khi lấy tất cả users
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User]";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("[UserDAO] getAllUsers -> " + list.size());
        return list;
    }

    // Lấy danh sách user theo Role
    public List<User> getUsersByRole(int role, int page, int pageSize) {
        List<User> list = new ArrayList<>();
        if (page <= 0) {
            page = 1;
        }
        if (pageSize <= 0) {
            pageSize = 10;
        }
        int offset = (page - 1) * pageSize;

        StringBuilder sb = new StringBuilder("SELECT * FROM [User]");
        if (role >= 0) {
            sb.append(" WHERE Role = ?");
        }
        sb.append(" ORDER BY UserID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        String sql = sb.toString();

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            if (role >= 0) {
                ps.setInt(idx++, role);
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("[UserDAO] getUsersByRole(" + role + ", page=" + page + ", size=" + pageSize + ") -> " + list.size());
        return list;
    }

    // ✅ Cập nhật thông tin user
    public boolean updateUser(User user) {
        String sql = """
            UPDATE [User]
            SET Name=?, Password=?, Role=?, Email=?, Phone=?, DateOfBirth=?, Gender=?, IsActive=?
            WHERE UserID=?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getPassword());
            ps.setInt(3, user.getRole());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            if (user.getDateOfBirth() != null) {
                ps.setDate(6, new java.sql.Date(user.getDateOfBirth().getTime()));
            } else {
                ps.setNull(6, Types.DATE);
            }
            ps.setString(7, user.getGender());
            ps.setBoolean(8, user.isActive());
            ps.setInt(9, user.getUserID());
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

    public boolean suspendUser(int userId) {
        String sql = "UPDATE [User] SET IsActive = 0 WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Đặt lại mật khẩu bằng email
    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE [User] SET Password = ? WHERE Email = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Tìm UserID dựa trên name/email/phone
    public Integer findUserIdByIdentifier(String identifier) {
        String sql = "SELECT UserID FROM [User] WHERE Name = ? OR Email = ? OR Phone = ?";
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

    // ✅ Hàm tiện ích: chuyển ResultSet → User
    private User mapUser(ResultSet rs) throws SQLException {
        java.sql.Date dobSql = rs.getDate("DateOfBirth");
        java.util.Date dob = (dobSql != null) ? new java.util.Date(dobSql.getTime()) : null;

        return new User(
                rs.getInt("UserID"),
                rs.getString("Name"),
                rs.getString("Password"),
                rs.getInt("Role"),
                rs.getString("Email"),
                rs.getString("Phone"),
                dob,
                rs.getString("Gender"),
                rs.getBoolean("IsActive")
        );
    }

    public int countUsersByRole(int roleInt) {
        if (roleInt < 0) {
            return countAllUsers();
        }
        String sql = "SELECT COUNT(*) AS cnt FROM [User] WHERE Role = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roleInt);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countAllUsers() {
        String sql = "SELECT COUNT(*) AS cnt FROM [User]";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
