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
    <div class="container mt-5" style="max-width: 450px;">
        <form class="form-signup" action="${pageContext.request.contextPath}/signup" method="post">
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
            <input name="fullname" type="text" class="form-control mb-2" placeholder="Full Name" required>

            <!-- Password -->
            <input name="pass" type="password" class="form-control mb-2" placeholder="Password" required>

            <!-- Repeat Password -->
            <input name="repass" type="password" class="form-control mb-2" placeholder="Repeat Password" required>

            <!-- Email -->
            <input name="mail" type="email" class="form-control mb-2" placeholder="Email" required>

            <!-- Phone -->
            <input name="phone" type="text" class="form-control mb-2" placeholder="Phone number (optional)">

            <!-- Gender -->
            <div class="form-group mb-2">
                <label for="gender" class="font-weight-bold">Gender</label>
                <select name="gender" id="gender" class="form-control" required>
                    <option value="" disabled selected>Select gender</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Other">Other</option>
                </select>
            </div>

            <!-- Birthdate -->
            <div class="form-group mb-3">
                <label for="birthdate" class="font-weight-bold">Date of Birth</label>
                <input name="birthdate" id="birthdate" type="date" class="form-control" required>
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
</body>
</html>
