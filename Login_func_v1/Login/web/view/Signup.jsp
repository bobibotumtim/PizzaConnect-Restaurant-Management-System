<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign Up Form</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" rel="stylesheet">
    <link href="css/login.css" rel="stylesheet" type="text/css"/>
</head>
<body>
    <div class="container mt-5" style="max-width: 400px;">
        <form class="form-signup" action="${pageContext.request.contextPath}/signup" method="post">
            <h1 class="h3 mb-3 font-weight-normal text-center">Sign up</h1>
            
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

            <input name="user" type="text" class="form-control mb-2" placeholder="User name" required autofocus>
            
            <input name="fullname" type="text" class="form-control mb-2" placeholder="Full Name" required>

            <input name="pass" type="password" class="form-control mb-2" placeholder="Password" required>


            <input name="repass" type="password" class="form-control mb-2" placeholder="Repeat Password" required>
            
            
            <input name="mail" type="text" class="form-control mb-2" placeholder="Mail" required>


            <input name="phone" type="text" class="form-control mb-3" placeholder="Phone number (optional)">


            <button class="btn btn-primary btn-block" type="submit">
                <i class="fas fa-user-plus"></i> Sign Up
            </button>


            <a href="${pageContext.request.contextPath}/view/Login.jsp" class="btn btn-link mt-2">
                <i class="fas fa-angle-left"></i> Back to Login
            </a>
            
            <a href="${pageContext.request.contextPath}/home" class="btn btn-link mt-2">
                <i class="fas fa-home"></i> Back to Home
            </a>
        </form>
    </div>
</body>
</html>
