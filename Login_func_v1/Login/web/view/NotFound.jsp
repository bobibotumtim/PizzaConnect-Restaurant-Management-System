<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Page Not Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="bg-gray-50 min-h-screen flex items-center justify-center">
    <div class="text-center">
        <i data-lucide="triangle-alert" class="w-24 h-24 text-orange-500 mx-auto mb-6"></i>
        <h1 class="text-3xl font-bold text-gray-900 mb-4">Page Not Found</h1>
        <p class="text-gray-600 text-lg mb-2">Sorry, the page you are looking for doesn't exist.</p>
        <p class="text-gray-500 mb-8">You may not have permission to access this page or it has been moved.</p>
        <div class="flex gap-4 justify-center">
            <a href="${pageContext.request.contextPath}/home" 
               class="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg transition-colors flex items-center">
                <i data-lucide="home" class="w-5 h-5 mr-2"></i>
                Go Home
            </a>
            <button onclick="history.back()" 
                    class="border border-gray-300 text-gray-700 hover:bg-gray-50 px-6 py-3 rounded-lg transition-colors flex items-center">
                <i data-lucide="arrow-left" class="w-5 h-5 mr-2"></i>
                Go Back
            </button>
        </div>
    </div>
    <script>lucide.createIcons();</script>
</body>
</html>