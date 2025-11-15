<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login Form</title>
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
    </style>
</head>
<body>
    <div class="container mt-5" style="max-width: 400px;">
        <form class="form-signin" action="${pageContext.request.contextPath}/Login" method="post" id="loginForm" novalidate>
            <h1 class="h3 mb-3 font-weight-normal text-center">Sign in</h1>

            <%
                String mess = (String) request.getAttribute("mess");
                if (mess != null && !mess.isEmpty()) {
            %>
                <div class="alert alert-danger text-center" role="alert">
                    <%= mess %>
                </div>
            <%
                }
            %>

            <div class="form-group">
                <input name="phone" id="phone" type="text" class="form-control" 
                       placeholder="Phone number (10 digits)" required autofocus>
                <div class="error-message" id="phoneError"></div>
            </div>

            <div class="form-group">
                <input name="pass" id="pass" type="password" class="form-control" 
                       placeholder="Password" required>
                <div class="error-message" id="passError"></div>
            </div>

            <button class="btn btn-success btn-block" type="submit">
                <i class="fas fa-sign-in-alt"></i> Sign in
            </button>

            <hr>
            <a href="${pageContext.request.contextPath}/view/Signup.jsp" class="btn btn-primary btn-block">
                <i class="fas fa-user-plus"></i> Sign up New Account
            </a>
            
            <div>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-link mt-2">
                    <i class="fas fa-home"></i> Back to Home
                </a>

                <a href="${pageContext.request.contextPath}/view/ForgotPassword.jsp" class="btn btn-link mt-2">
                    <i class="fas fa-search"></i> Forgot password
                </a>
            </div>
        </form>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Reset errors
            document.querySelectorAll('.error-message').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.form-control').forEach(el => el.classList.remove('is-invalid'));
            
            let isValid = true;
            
            // Validate phone
            const phone = document.getElementById('phone').value.trim();
            const phoneError = document.getElementById('phoneError');
            
            if (phone === '') {
                phoneError.textContent = 'Please enter phone number';
                phoneError.style.display = 'block';
                document.getElementById('phone').classList.add('is-invalid');
                isValid = false;
            } else if (!/^[0-9]{10}$/.test(phone)) {
                phoneError.textContent = 'Phone number must be 10 digits';
                phoneError.style.display = 'block';
                document.getElementById('phone').classList.add('is-invalid');
                isValid = false;
            }
            
            // Validate password
            const pass = document.getElementById('pass').value;
            const passError = document.getElementById('passError');
            
            if (pass === '') {
                passError.textContent = 'Please enter password';
                passError.style.display = 'block';
                document.getElementById('pass').classList.add('is-invalid');
                isValid = false;
            }
            // For login, we don't enforce minimum length
            // This allows users with old passwords to still login
            
            if (isValid) {
                // Trim phone before submit
                document.getElementById('phone').value = phone;
                this.submit();
            }
        });
        
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
    </script>
</body>
</html>
