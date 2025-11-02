# Design Document

## Overview

This design addresses the password hashing issue in the forgot password functionality. The root cause is that the `resetPassword` method in `UserDAO` stores passwords as plain text, while the `checkLogin` method expects BCrypt-hashed passwords. The fix involves modifying the `resetPassword` method to hash passwords before storage, ensuring consistency across all password operations.

## Architecture

The fix follows the existing MVC architecture:
- **Controller Layer**: `ForgotPasswordServlet` handles the forgot password workflow
- **DAO Layer**: `UserDAO` manages database operations for user data
- **Security Layer**: BCrypt library handles password hashing

No architectural changes are needed; we're fixing the existing implementation.

## Components and Interfaces

### Modified Components

#### UserDAO.resetPassword()
**Current Implementation:**
```java
public boolean resetPassword(String identifier, String newPassword) {
    Integer userId = findUserIdByIdentifier(identifier);
    if (userId == null) return false;
    
    String sql = "UPDATE [User] SET Password = ? WHERE UserID = ?";
    try (Connection connection = getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, newPassword); // ❌ Plain text password
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}
```

**Fixed Implementation:**
```java
public boolean resetPassword(String identifier, String newPassword) {
    Integer userId = findUserIdByIdentifier(identifier);
    if (userId == null) return false;
    
    String sql = "UPDATE [User] SET Password = ? WHERE UserID = ?";
    try (Connection connection = getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt()); // ✅ Hash password
        ps.setString(1, hashedPassword);
        ps.setInt(2, userId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}
```

### Consistency Check

Verify that all password modification methods use BCrypt hashing:

1. **insertUser()** - ✅ Already hashes: `BCrypt.hashpw(user.getPassword(), BCrypt.gensalt())`
2. **updatePassword()** - ⚠️ Expects pre-hashed password (caller responsibility)
3. **updateUser()** - ⚠️ Expects pre-hashed password (caller responsibility)
4. **resetPassword()** - ❌ Currently stores plain text (needs fix)

## Data Models

No changes to database schema or User model required. The Password field in the User table already stores VARCHAR(255) which accommodates BCrypt hashes (60 characters).

## Error Handling

### Existing Error Handling (Maintained)
- Database connection failures return `false`
- User not found returns `false`
- SQL exceptions are logged and return `false`

### Additional Considerations
- BCrypt hashing failures are unlikely but would throw `IllegalArgumentException`
- No additional error handling needed as BCrypt is well-tested

## Testing Strategy

### Unit Testing
1. Test `resetPassword()` with valid email
   - Verify password is hashed before storage
   - Verify BCrypt hash format (starts with `$2a$`)
   
2. Test `resetPassword()` with invalid identifier
   - Verify returns `false`
   - Verify no database update occurs

### Integration Testing
1. Complete forgot password flow:
   - Request OTP
   - Verify OTP
   - Reset password
   - Login with new password
   - Verify successful authentication

2. Test backward compatibility:
   - Existing users with hashed passwords can still login
   - Password reset works for users with existing hashed passwords

### Manual Testing
1. Reset password through forgot password flow
2. Verify new password is hashed in database (check User table)
3. Login with new password
4. Verify successful login and session creation

## Implementation Notes

### Why This Fix Works
- BCrypt hashing is deterministic for verification but generates unique hashes for storage
- `BCrypt.checkpw(plainText, hash)` in `checkLogin()` will work with any BCrypt hash
- The fix ensures consistency: all passwords stored are hashed, all logins verify against hashes

### Alternative Approaches Considered
1. **Modify ForgotPasswordServlet to hash before calling resetPassword**
   - ❌ Rejected: Violates separation of concerns; DAO should handle data persistence logic
   
2. **Create separate method resetPasswordHashed()**
   - ❌ Rejected: Adds unnecessary complexity; resetPassword should always hash

3. **Modify updatePassword() to hash automatically**
   - ⚠️ Risky: May break existing callers that pre-hash passwords
   - Better to fix resetPassword first, then audit other methods separately

### Security Considerations
- BCrypt automatically generates salt, preventing rainbow table attacks
- BCrypt is computationally expensive, providing protection against brute force
- No plain text passwords are logged or stored
