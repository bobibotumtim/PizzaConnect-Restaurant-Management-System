# Requirements Document

## Introduction

The forgot password functionality in the PizzaConnect Restaurant Management System is currently broken due to a password hashing mismatch. When users reset their password through the forgot password flow, the new password is stored as plain text in the database. However, the login system expects BCrypt-hashed passwords, preventing users from logging in after a password reset.

## Glossary

- **System**: The PizzaConnect Restaurant Management System
- **ForgotPasswordServlet**: The servlet handling the forgot password workflow
- **UserDAO**: Data Access Object for user-related database operations
- **BCrypt**: Password hashing algorithm used for secure password storage
- **OTP**: One-Time Password sent via email for verification
- **Plain Text Password**: Unencrypted password stored directly in the database
- **Hashed Password**: Password encrypted using BCrypt before storage

## Requirements

### Requirement 1

**User Story:** As a user who forgot my password, I want to reset it securely so that I can log in with my new password

#### Acceptance Criteria

1. WHEN a user submits a new password through the forgot password flow, THE System SHALL hash the password using BCrypt before storing it in the database
2. WHEN a user completes the password reset process, THE System SHALL store the hashed password in the User table
3. WHEN a user attempts to login after resetting their password, THE System SHALL successfully authenticate them using the BCrypt verification
4. THE System SHALL use the same BCrypt hashing algorithm for password reset as used during user registration
5. THE System SHALL maintain backward compatibility with existing hashed passwords in the database

### Requirement 2

**User Story:** As a system administrator, I want all passwords stored securely so that user accounts remain protected

#### Acceptance Criteria

1. THE System SHALL never store plain text passwords in the database
2. WHEN the resetPassword method is called, THE System SHALL hash the password before the database update
3. THE System SHALL use BCrypt with appropriate salt generation for all password hashing operations
4. THE System SHALL ensure consistent password hashing across all password modification flows (registration, reset, profile update)
