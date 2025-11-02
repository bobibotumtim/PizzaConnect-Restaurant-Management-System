# Implementation Plan

- [ ] 1. Fix password hashing in UserDAO.resetPassword()
  - Modify the `resetPassword()` method in `UserDAO.java` to hash the password using BCrypt before storing it in the database
  - Add BCrypt hashing: `String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());`
  - Update the PreparedStatement to use the hashed password instead of plain text
  - _Requirements: 1.1, 1.2, 1.4, 2.1, 2.2, 2.3_

- [ ] 2. Verify BCrypt import exists in UserDAO
  - Confirm that `import org.mindrot.jbcrypt.BCrypt;` is present at the top of UserDAO.java
  - If missing, add the import statement
  - _Requirements: 1.4, 2.3_

- [ ] 3. Test the forgot password flow end-to-end
  - Manually test the complete forgot password workflow: request OTP, verify OTP, reset password, and login
  - Verify that the password is stored as a BCrypt hash in the database (check the User table)
  - Verify that login works successfully with the new password
  - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.4_

- [ ]* 4. Add unit tests for resetPassword method
  - Write unit test to verify password is hashed before storage
  - Write unit test to verify BCrypt hash format (starts with `$2a$`)
  - Write unit test for invalid identifier handling
  - _Requirements: 1.1, 2.2, 2.3_
