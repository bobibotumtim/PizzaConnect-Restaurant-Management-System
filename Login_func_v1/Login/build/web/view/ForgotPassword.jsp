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
    <form action="${pageContext.request.contextPath}/forgot-password" method="post">
        <h1 class="h4 mb-3 text-center">Forgot password</h1>

        <%
            String success = (String) session.getAttribute("success");
            String error   = (String) session.getAttribute("error");
            if (success != null) { session.removeAttribute("success"); request.setAttribute("success", success); }
            if (error   != null) { session.removeAttribute("error");   request.setAttribute("error",   error); }
        %>

        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success text-center"><%= request.getAttribute("success") %></div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger text-center"><%= request.getAttribute("error") %></div>
        <% } %>

        <%
            Boolean otpPhase = (Boolean) session.getAttribute("otpPhase");
            if (otpPhase == null) otpPhase = Boolean.FALSE;
        %>

        <% if (!otpPhase) { %>
            <input name="identifier" type="text" class="form-control mb-3"
                   placeholder="Nhập email hoặc số điện thoại" required autofocus>
            <input type="hidden" name="action" value="request_otp" />
            <button class="btn btn-primary btn-block" type="submit">
                <i class="fas fa-paper-plane"></i> Gửi mã OTP
            </button>
        <% } else { %>
            <div class="form-group">
                <label>Mã OTP</label>
                <input name="otp" type="text" class="form-control" maxlength="6" placeholder="Nhập 6 chữ số" required>
            </div>
            <div class="form-group mt-3">
                <label>Mật khẩu mới</label>
                <input name="newPassword" type="password" class="form-control" minlength="6" required>
            </div>
            <div class="form-group mt-3">
                <label>Nhập lại mật khẩu mới</label>
                <input name="confirmPassword" type="password" class="form-control" minlength="6" required>
            </div>
            <input type="hidden" name="action" value="verify_otp" />
            <button class="btn btn-success btn-block mt-3" type="submit">
                <i class="fas fa-check"></i> Xác nhận & đổi mật khẩu
            </button>
        <% } %>

        <a href="${pageContext.request.contextPath}/view/Login.jsp" class="btn btn-link mt-2">
            <i class="fas fa-angle-left"></i> Back to Login
        </a>
    </form>
</div>
</body>
</html>
