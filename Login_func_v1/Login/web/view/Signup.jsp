<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign Up Form</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" rel="stylesheet">
    <link href="css/login.css" rel="stylesheet" type="text/css"/>
    <style>
        .error-message {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
            display: none;
        }
        .form-control.is-invalid {
            border-color: #dc3545;
        }
        .password-strength {
            height: 5px;
            margin-top: 5px;
            border-radius: 3px;
            transition: all 0.3s;
        }
        .strength-weak { background-color: #dc3545; width: 33%; }
        .strength-medium { background-color: #ffc107; width: 66%; }
        .strength-strong { background-color: #28a745; width: 100%; }
    </style>
</head>
<body>
    <div class="container mt-5" style="max-width: 450px;">
        <form class="form-signup" action="${pageContext.request.contextPath}/signup" method="post" id="signupForm" novalidate>
            <h1 class="h3 mb-4 font-weight-normal text-center">Sign Up</h1>
            
            <%
                String success = (String) session.getAttribute("success");
                String error = (String) session.getAttribute("error");
                if (success != null) {
                    session.removeAttribute("success");
                    request.setAttribute("success", success);
                }
                if (error != null) {
                    session.removeAttribute("error");
                    request.setAttribute("error", error);
                }
            %>

            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success text-center" role="alert">
                    <%= request.getAttribute("success") %>
                </div>
            <% } %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger text-center" role="alert">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <!-- Full Name -->
            <div class="form-group">
                <input name="fullname" id="fullname" type="text" class="form-control" placeholder="Full Name" required>
                <div class="error-message" id="fullnameError"></div>
            </div>

            <!-- Email -->
            <div class="form-group">
                <input name="mail" id="mail" type="email" class="form-control" placeholder="Email" required>
                <div class="error-message" id="mailError"></div>
            </div>

            <!-- Phone -->
            <div class="form-group">
                <input name="phone" id="phone" type="text" class="form-control" placeholder="Phone Number (10 digits)">
                <div class="error-message" id="phoneError"></div>
            </div>

            <!-- Password -->
            <div class="form-group">
                <input name="pass" id="pass" type="password" class="form-control" placeholder="Password (min 8 characters)" required>
                <div class="password-strength" id="passwordStrength"></div>
                <div class="error-message" id="passError"></div>
                <div class="text-sm text-gray-600 mt-1">Must contain uppercase, lowercase, and number</div>
            </div>

            <!-- Repeat Password -->
            <div class="form-group">
                <input name="repass" id="repass" type="password" class="form-control" placeholder="Confirm Password" required>
                <div class="error-message" id="repassError"></div>
            </div>

            <!-- Gender -->
            <div class="form-group">
                <label for="gender" class="font-weight-bold">Gender</label>
                <select name="gender" id="gender" class="form-control" required>
                    <option value="" disabled selected>Select Gender</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Other">Other</option>
                </select>
                <div class="error-message" id="genderError"></div>
            </div>

            <!-- Birthdate -->
            <div class="form-group mb-3">
                <label for="birthdate" class="font-weight-bold">Date of Birth</label>
                <input name="birthdate" id="birthdate" type="date" class="form-control" required>
                <div class="error-message" id="birthdateError"></div>
            </div>

            <!-- Submit -->
            <button class="btn btn-primary btn-block" type="submit">
                <i class="fas fa-user-plus"></i> Sign Up
            </button>

            <!-- Back to login -->
            <a href="${pageContext.request.contextPath}/view/Login.jsp" class="btn btn-link mt-2">
                <i class="fas fa-angle-left"></i> Back to Login
            </a>

            <!-- Back to home -->
            <a href="${pageContext.request.contextPath}/home" class="btn btn-link mt-2">
                <i class="fas fa-home"></i> Back to Home
            </a>
        </form>
    </div>

    <script>
        // Password strength indicator
        document.getElementById('pass').addEventListener('input', function() {
            const password = this.value;
            const strengthBar = document.getElementById('passwordStrength');
            
            if (password.length === 0) {
                strengthBar.className = 'password-strength';
                return;
            }
            
            let strength = 0;
            if (password.length >= 8) strength++;
            if (password.length >= 12) strength++;
            if (/[a-z]/.test(password)) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/\d/.test(password)) strength++;
            if (/[^a-zA-Z0-9]/.test(password)) strength++;
            
            // Weak: less than 3 criteria
            // Medium: 3-4 criteria (meets minimum requirement)
            // Strong: 5+ criteria
            if (strength < 3) {
                strengthBar.className = 'password-strength strength-weak';
            } else if (strength <= 4) {
                strengthBar.className = 'password-strength strength-medium';
            } else {
                strengthBar.className = 'password-strength strength-strong';
            }
        });

        // Form validation
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Reset errors
            document.querySelectorAll('.error-message').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.form-control').forEach(el => el.classList.remove('is-invalid'));
            
            let isValid = true;
            
            // Validate fullname
            const fullname = document.getElementById('fullname').value.trim();
            if (fullname === '') {
                showError('fullname', 'Please enter full name');
                isValid = false;
            } else if (fullname.length < 2 || fullname.length > 100) {
                showError('fullname', 'Full name must be 2-100 characters');
                isValid = false;
            }
            
            // Validate email
            const email = document.getElementById('mail').value.trim();
            const emailRegex = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$/;
                               
            if (email === '') {
                showError('mail', 'Please enter email');
                isValid = false;
            } else if (!emailRegex.test(email)) {
                showError('mail', 'Invalid email format');
                isValid = false;
            }
            
            // Validate phone (optional but if provided must be valid)
            const phone = document.getElementById('phone').value.trim();
            if (phone !== '' && !/^[0-9]{10}$/.test(phone)) {
                showError('phone', 'Phone number must be 10 digits');
                isValid = false;
            }
            
            // Validate password
            const pass = document.getElementById('pass').value;
            const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
            if (pass === '') {
                showError('pass', 'Please enter password');
                isValid = false;
            } else if (pass.length < 8) {
                showError('pass', 'Password must be at least 8 characters');
                isValid = false;
            } else if (pass.length > 50) {
                showError('pass', 'Password cannot exceed 50 characters');
                isValid = false;
            } else if (!passwordRegex.test(pass)) {
                showError('pass', 'Password must contain uppercase, lowercase, and number');
                isValid = false;
            }
            
            // Validate repassword
            const repass = document.getElementById('repass').value;
            if (repass === '') {
                showError('repass', 'Please confirm password');
                isValid = false;
            } else if (pass !== repass) {
                showError('repass', 'Passwords do not match');
                isValid = false;
            }
            
            // Validate gender
            const gender = document.getElementById('gender').value;
            if (gender === '') {
                showError('gender', 'Please select gender');
                isValid = false;
            }
            
            // Validate birthdate
            const birthdate = document.getElementById('birthdate').value;
            if (birthdate === '') {
                showError('birthdate', 'Please select date of birth');
                isValid = false;
            } else {
                const today = new Date();
                const birth = new Date(birthdate);
                const age = today.getFullYear() - birth.getFullYear();
                if (age < 13) {
                    showError('birthdate', 'You must be at least 13 years old');
                    isValid = false;
                } else if (age > 120) {
                    showError('birthdate', 'Invalid date of birth');
                    isValid = false;
                }
            }
            
            if (isValid) {
                // Trim values before submit
                document.getElementById('fullname').value = fullname;
                document.getElementById('mail').value = email.toLowerCase();
                document.getElementById('phone').value = phone;
                this.submit();
            }
        });
        
        function showError(fieldId, message) {
            const field = document.getElementById(fieldId);
            const error = document.getElementById(fieldId + 'Error');
            field.classList.add('is-invalid');
            error.textContent = message;
            error.style.display = 'block';
        }
        
        // Remove error on input
        document.querySelectorAll('.form-control').forEach(input => {
            input.addEventListener('input', function() {
                this.classList.remove('is-invalid');
                const errorId = this.id + 'Error';
                const errorEl = document.getElementById(errorId);
                if (errorEl) {
                    errorEl.style.display = 'none';
                }
            });
        });
        
        // Set max date for birthdate (today)
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('birthdate').setAttribute('max', today);
    </script>
</body>
</html>
