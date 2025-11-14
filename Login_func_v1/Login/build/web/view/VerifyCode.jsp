<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Verify Code</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 min-h-screen flex items-center justify-center">
    <div class="max-w-md w-full bg-white rounded-lg shadow-md p-6">
        <div class="text-center mb-6">
            <h1 class="text-2xl font-bold text-gray-800">Verify Your Identity</h1>
            <p class="text-gray-600 mt-2">Enter the verification code sent to your email</p>
        </div>

        <%-- Success/Error messages --%>
        <c:if test="${not empty success}">
            <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                ${success}
                <p class="mt-2">You will be redirected to login page shortly...</p>
            </div>
            
            <script>
                // Tự động chuyển hướng sau 3 giây
                setTimeout(function() {
                    window.location.href = 'Login';
                }, 3000);
            </script>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                ${error}
            </div>
        </c:if>

        <c:if test="${empty success}">
            <form action="verifyCode" method="post" class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Verification Code</label>
                    <input type="text" name="otp" 
                           class="w-full p-3 border border-gray-300 rounded-lg text-center text-xl font-mono"
                           placeholder="Enter 6-digit code"
                           maxlength="6"
                           pattern="[0-9]{6}"
                           required autofocus>
                    <p class="text-sm text-gray-500 mt-1">Enter the 6-digit code from your email</p>
                </div>
                
                <button type="submit" class="w-full bg-orange-500 text-white p-3 rounded-lg hover:bg-orange-600 transition duration-200">
                    Verify Code
                </button>
            </form>

            <div class="mt-4 text-center">
                <p class="text-sm text-gray-600 mb-2">Didn't receive the code?</p>
                <a href="profile" class="text-orange-500 hover:text-orange-600">Back to Profile</a>
            </div>
        </c:if>

        <c:if test="${not empty success}">
            <div class="mt-4 text-center">
                <a href="Login" class="text-orange-500 hover:text-orange-600">Go to Login Page</a>
            </div>
        </c:if>
    </div>
</body>
</html>