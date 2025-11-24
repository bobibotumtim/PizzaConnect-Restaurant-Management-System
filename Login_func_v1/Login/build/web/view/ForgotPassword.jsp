<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Forgot Password</title>
        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" rel="stylesheet">
    </head>
    <body>
        <div class="container mt-5" style="max-width: 400px;">
            <%
                String success = (String) session.getAttribute("success");
                String error   = (String) session.getAttribute("error");
                if (success != null) { session.removeAttribute("success"); request.setAttribute("success", success); }
                if (error   != null) { session.removeAttribute("error");   request.setAttribute("error",   error); }
                String stage = (String) request.getAttribute("stage");
                if (stage == null) stage = request.getParameter("stage");
                if (stage == null) stage = "email";
            %>

            <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success text-center"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger text-center"><%= request.getAttribute("error") %></div>
            <% } %>

            <% if ("email".equals(stage)) { %>
            <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                <h1 class="h4 mb-3 text-center">Forgot Password</h1>
                <input type="hidden" name="action" value="sendOtp">
                <input name="email" type="email" class="form-control mb-3"
                       placeholder="Enter account email" required autofocus>
                <button class="btn btn-primary btn-block" type="submit">
                    <i class="fas fa-paper-plane"></i> Send OTP
                </button>
                <a href="${pageContext.request.contextPath}/view/Login.jsp" class="btn btn-link mt-2">
                    <i class="fas fa-angle-left"></i> Back to login
                </a>
            </form>
            <% } else if ("otp".equals(stage)) { %>
            <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                <h1 class="h4 mb-3 text-center">Enter OTP</h1>
                <input type="hidden" name="action" value="verifyOtp">
                <input name="otp" type="text" class="form-control mb-3"
                       placeholder="Enter 6-digit OTP" pattern="[0-9]{6}" required autofocus>
                <button class="btn btn-primary btn-block" type="submit">
                    <i class="fas fa-check"></i> Verify OTP
                </button>
                <a href="${pageContext.request.contextPath}/view/ForgotPassword.jsp?stage=email" class="btn btn-link mt-2">Resend OTP</a>
            </form>
            <% } else if ("reset".equals(stage)) { %>
            <form action="${pageContext.request.contextPath}/forgot-password" method="post" id="resetPasswordForm">
                <h1 class="h4 mb-3 text-center">Reset Password</h1>
                <input type="hidden" name="action" value="resetPassword">
                
                <div class="form-group">
                    <input name="newPassword" type="password" id="newPassword" class="form-control mb-2" 
                           placeholder="New Password" 
                           pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"
                           title="Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 digit"
                           minlength="8" required>
                    <small class="form-text text-muted">
                        Must contain: 1 uppercase, 1 lowercase, 1 digit, min 8 characters
                    </small>
                </div>
                
                <div class="form-group">
                    <input name="confirmPassword" type="password" id="confirmPassword" class="form-control mb-3" 
                           placeholder="Confirm Password" minlength="8" required>
                </div>
                
                <button class="btn btn-success btn-block" type="submit">
                    <i class="fas fa-save"></i> Save Password
                </button>
                <a href="${pageContext.request.contextPath}/view/Login.jsp" class="btn btn-link mt-2">
                    <i class="fas fa-angle-left"></i> Back to login
                </a>
            </form>
            <% } %>
        </div>
        
        <script>
            // Password validation for reset form
            document.addEventListener('DOMContentLoaded', function() {
                const resetForm = document.getElementById('resetPasswordForm');
                if (resetForm) {
                    const newPassword = document.getElementById('newPassword');
                    const confirmPassword = document.getElementById('confirmPassword');
                    
                    // Real-time password match validation
                    confirmPassword.addEventListener('input', function() {
                        if (newPassword.value !== confirmPassword.value) {
                            confirmPassword.setCustomValidity('Passwords do not match');
                        } else {
                            confirmPassword.setCustomValidity('');
                        }
                    });
                    
                    // Form submission validation
                    resetForm.addEventListener('submit', function(e) {
                        const password = newPassword.value;
                        const confirm = confirmPassword.value;
                        
                        // Validate password pattern
                        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
                        if (!passwordRegex.test(password)) {
                            e.preventDefault();
                            alert('Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 digit!');
                            return false;
                        }
                        
                        // Validate password match
                        if (password !== confirm) {
                            e.preventDefault();
                            alert('Passwords do not match!');
                            return false;
                        }
                    });
                }
            });
        </script>
    </body>
</html>