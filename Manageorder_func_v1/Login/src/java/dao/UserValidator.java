// File: src/main/java/dao/UserValidator.java
package dao;

import models.User;

public class UserValidator {
    private static final String PHONE_REGEX = "^0[1-9]\\d{8}$";
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

    public String validateProfileUpdate(User user, String email, String phone, String oldPassword, String newPassword, String confirmPassword) {
        if (email == null || email.isEmpty() || phone == null || phone.isEmpty()) {
            return "Required fields cannot be empty!";
        }
        if (!email.matches(EMAIL_REGEX)) {
            return "Invalid email format!";
        }
        
        // --- GIẢ LẬP LỖI Ở ĐÂY ---
        // Giả sử lập trình viên quên mất dòng kiểm tra số điện thoại này
        /* if (!phone.matches(PHONE_REGEX)) {
            return "Invalid phone number!";
        }
        */
        // -------------------------

        if (oldPassword != null && !oldPassword.isEmpty()) {
            if (!oldPassword.equals(user.getPassword())) {
                return "Old password is incorrect!";
            }
            if (newPassword == null || newPassword.isEmpty() || !newPassword.equals(confirmPassword)) {
                return "New password does not match or is empty!";
            }
        }
        return null; // Trả về null nghĩa là không có lỗi
    }
}