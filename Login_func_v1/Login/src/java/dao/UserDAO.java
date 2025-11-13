package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

import models.Customer;
import models.User;

public class UserDAO extends DBContext {

    // Check if user with given email exists
    public boolean isUserExists(String email) {
        String sql = "SELECT 1 FROM [User] WHERE Email = ?";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Add new user and return generated UserID
    public int insertUser(User user) {
        String sql = """
                    INSERT INTO [User]
                    (Name, Password, Role, Email, Phone, DateOfBirth, Gender, IsActive)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            String hashed = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            ps.setString(1, user.getName());
            ps.setString(2, hashed);
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
                    if (rs.next())
                        return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Check login credentials
    public User checkLogin(String Phone, String password) {
        String sql = """
                    SELECT * FROM [User]
                    WHERE Phone = ? AND IsActive = 1
                """;
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, Phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hash = rs.getString("Password");
                    if (BCrypt.checkpw(password, hash)) {
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM [User] WHERE UserID = ?";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
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

    // Get all users
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User]";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Update user password (expects plain text password, will hash it)
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE [User] SET Password = ? WHERE UserID = ?";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            ps.setString(1, hashed);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // update user info
    public boolean updateUser(User user) {
        String sql = """
                    UPDATE [User]
                    SET Name=?, Password=?, Role=?, Email=?, Phone=?, DateOfBirth=?, Gender=?, IsActive=?
                    WHERE UserID=?
                """;
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            // Hash password if it's not already hashed (BCrypt hashes start with $2a$, $2b$, or $2y$)
            String password = user.getPassword();
            if (password != null && !password.startsWith("$2")) {
                password = BCrypt.hashpw(password, BCrypt.gensalt());
            }
            ps.setString(2, password);
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

    // Delete user by ID
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM [User] WHERE UserID = ?";
        try( Connection connection = getConnection()) {
            System.out.println("[DEBUG] Starting delete for UserID: " + userId);

            if (connection == null || connection.isClosed()) {
                System.out.println("[ERROR] Database connection is null or closed!");
                return false;
            }

            // ✅ Tắt kiểm tra khóa ngoại tạm thời (SQL Server)
            try (Statement st = connection.createStatement()) {
                st.execute("EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'");
            }

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, userId);
                int rows = ps.executeUpdate();
                System.out.println("[DEBUG] Rows affected in User table: " + rows);
                return rows > 0;
            } finally {
                // ✅ Bật lại constraint
                try (Statement st2 = connection.createStatement()) {
                    st2.execute("EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'");
                }
            }

        } catch (SQLException e) {
            System.out.println("[SQL ERROR] Delete user failed!");
            System.out.println("Message: " + e.getMessage());
            System.out.println("SQLState: " + e.getSQLState());
            System.out.println("ErrorCode: " + e.getErrorCode());
            e.printStackTrace();
        }
        return false;
    }

    // Test database connection
    public boolean testConnection() {
        try ( Connection connection = getConnection()) {
            if (connection == null || connection.isClosed()) {
                System.out.println("Database connection is null or closed!");
                return false;
            }

            String sql = "SELECT 1";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("Database connection test: SUCCESS");
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Database connection test: FAILED - " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Check if user exists by ID
    public boolean userExists(int userId) {
        System.out.println("Checking if user exists with ID: " + userId);

        // Test connection trước
        if (!testConnection()) {
            System.out.println("Cannot check user existence - database connection failed");
            return false;
        }

        String sql = "SELECT COUNT(*) FROM [User] WHERE UserID = ?";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("User exists check: " + (count > 0) + " (count: " + count + ")");
                    return count > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("SQL Error in userExists: " + e.getMessage());
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        }
        return false;
    }

    // Verify if email exists
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM [User] WHERE Email = ?";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // if at least one record found, email exists
            }
        } catch (SQLException e) {
            System.err.println("Error checking email existence: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Reset password using name/email/phone
    public boolean resetPassword(String identifier, String newPassword) {
        Integer userId = findUserIdByIdentifier(identifier);
        if (userId == null)
            return false;

        String sql = "UPDATE [User] SET Password = ? WHERE UserID = ?";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            ps.setString(1, hashed);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Find UserID by name, email, or phone
    public Integer findUserIdByIdentifier(String identifier) {
        String sql = "SELECT UserID FROM [User] WHERE Name = ? OR Email = ? OR Phone = ?";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
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

    // Map ResultSet to User object
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
                rs.getBoolean("IsActive"));
    }

    public List<User> searchCustomersByPhone(String phone, int limit) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.* FROM [User] u WHERE u.Role = 3 AND u.Phone LIKE ? AND u.IsActive = 1 ORDER BY u.Phone";
        
        try (Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone + "%");
            if (limit > 0) {
                ps.setMaxRows(limit);
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setUserID(rs.getInt("UserID"));
                user.setName(rs.getString("Name"));
                user.setPhone(rs.getString("Phone"));
                user.setEmail(rs.getString("Email"));
                user.setDateOfBirth(rs.getDate("DateOfBirth"));
                user.setGender(rs.getString("Gender"));
                users.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public Customer getCustomerByUserId(int userId) {
        String sql = """
                    SELECT
                        c.CustomerID, c.UserID, c.LoyaltyPoint, c.LastEarnedDate,
                        u.Name, u.Email, u.Phone, u.DateOfBirth, u.Gender, u.IsActive
                    FROM Customer c
                    INNER JOIN [User] u ON c.UserID = u.UserID
                    WHERE c.UserID = ? AND u.IsActive = 1
                """;

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setUserID(rs.getInt("UserID"));
                customer.setLoyaltyPoint(rs.getInt("LoyaltyPoint"));
                customer.setLastEarnedDate(rs.getTimestamp("LastEarnedDate"));
                customer.setName(rs.getString("Name"));
                customer.setPhone(rs.getString("Phone"));
                customer.setEmail(rs.getString("Email"));
                customer.setDateOfBirth(rs.getDate("DateOfBirth"));
                customer.setGender(rs.getString("Gender"));
                return customer;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Customer getCustomerByCustomerId(int customerId) {
        String sql = "SELECT c.*, u.Name, u.Phone, u.Email, u.DateOfBirth, u.Gender " +
                    "FROM Customer c " +
                    "JOIN [User] u ON c.UserID = u.UserID " +
                    "WHERE c.CustomerID = ?";
        
        try (Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setUserID(rs.getInt("UserID"));
                customer.setLoyaltyPoint(rs.getInt("LoyaltyPoint"));
                customer.setLastEarnedDate(rs.getTimestamp("LastEarnedDate"));
                // Set user information
                customer.setName(rs.getString("Name"));
                customer.setPhone(rs.getString("Phone"));
                customer.setEmail(rs.getString("Email"));
                customer.setDateOfBirth(rs.getDate("DateOfBirth"));
                customer.setGender(rs.getString("Gender"));
                return customer;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateCustomerLoyaltyPoints(int customerId, int newPoints) {
        newPoints = Math.max(0, newPoints);

        String sql = "UPDATE Customer SET LoyaltyPoint = ?, LastEarnedDate = GETDATE() WHERE CustomerID = ?";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, newPoints);
            ps.setInt(2, customerId);

            int result = ps.executeUpdate();
            if (result > 0) {
                System.out.println("✅ Updated loyalty points for customer " + customerId + ": " + newPoints);
                return true;
            }
        } catch (Exception e) {
            System.err.println("❌ Error updating loyalty points for customer " + customerId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Count users by role
    public int countUsersByRole(int roleInt) {
        if (roleInt < 0) {
            return countAllUsers();
        }
        String sql = "SELECT COUNT(*) AS cnt FROM [User] WHERE Role = ?";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
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

    // Count all users
    public int countAllUsers() {
        String sql = "SELECT COUNT(*) AS cnt FROM [User]";
        try ( Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
