<%@ page contentType="text/html;charset=UTF-8" %>
<div class="h-screen w-20 bg-gray-900 text-white flex flex-col justify-between fixed top-0 left-0">
    <div>
        <div class="flex flex-col items-center space-y-6 mt-6">
            <a href="${pageContext.request.contextPath}/dashboard" class="text-gray-400 hover:text-white">
                <i class="fa fa-home text-xl"></i>
            </a>
            <a href="${pageContext.request.contextPath}/manage-orders" class="text-gray-400 hover:text-white">
                <i class="fa fa-clipboard-list text-xl"></i>
            </a>
            <a href="${pageContext.request.contextPath}/products" class="text-gray-400 hover:text-white">
                <i class="fa fa-pizza-slice text-xl"></i>
            </a>
            <a href="${pageContext.request.contextPath}/customers" class="text-gray-400 hover:text-white">
                <i class="fa fa-users text-xl"></i>
            </a>
            <a href="${pageContext.request.contextPath}/settings" class="text-gray-400 hover:text-white">
                <i class="fa fa-cog text-xl"></i>
            </a>
        </div>
    </div>

    <div class="flex flex-col items-center mb-6">
        <a href="${pageContext.request.contextPath}/logout" class="text-gray-400 hover:text-red-500">
            <i class="fa fa-sign-out-alt text-xl"></i>
        </a>
    </div>
</div>
