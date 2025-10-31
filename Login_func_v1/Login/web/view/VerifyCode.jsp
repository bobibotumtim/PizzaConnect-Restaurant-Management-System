<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Verify Code</title>
</head>
<body>
    <h2>Enter Verification Code</h2>
    <form action="VerifyCodeServlet" method="post">
        <label for="otp">Verification Code:</label>
        <input type="text" id="otp" name="otp" required maxlength="6">
        <button type="submit">Verify</button>
    </form>

    <c:if test="${not empty error}">
        <p style="color:red">${error}</p>
    </c:if>
    <c:if test="${not empty message}">
        <p style="color:green">${message}</p>
    </c:if>
</body>
</html>
