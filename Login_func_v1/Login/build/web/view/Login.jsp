<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login Form</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" rel="stylesheet">
    <link href="css/login.css" rel="stylesheet" type="text/css"/>
</head>
<body>
    <div class="container mt-5" style="max-width: 400px;">
        <form class="form-signin" action="${pageContext.request.contextPath}/Login" method="post">
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

            <input name="phone" type="text" class="form-control mb-2" placeholder="Phone number" required autofocus>
            <input name="pass" type="password" class="form-control mb-2" placeholder="Password" required>

            <button class="btn btn-success btn-block" type="submit">
                <i class="fas fa-sign-in-alt"></i> Sign in
            </button>

            <hr>
            <a href="${pageContext.request.contextPath}/view/Signup.jsp" class="btn btn-primary btn-block">
                <i class="fas fa-user-plus"></i> Sign up New Account
            </a>
            
            <div>
                <a href="home" class="btn btn-link mt-2">
                    <i class="fas fa-home"></i> Back to Home
                </a>

                <a href="${pageContext.request.contextPath}/view/ForgotPassword.jsp" class="btn btn-link mt-2">
                    <i class="fas fa-search"></i> Forgot password
                </a>
            </div>
        </form>
    </div>
</body>
</html>
