<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dish Monitor - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .dish-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .dish-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.8; }
        }
        .pulse-animation {
            animation: pulse 2s infinite;
        }
    </style>
</head>
<body class="bg-gray-50">
    <%@ include file="Sidebar.jsp" %>
    
    <div class="content-wrapper">
        <div class="max-w-7xl mx-auto px-6 py-8">
            
            <!-- Header -->
            <div class="mb-8">
                <div class="flex items-center gap-4 mb-4">
                    <div class="w-14 h-14 bg-gradient-to-br from-orange-400 to-orange-600 rounded-xl flex items-center justify-center">
                        <i class="fas fa-bell text-white text-2xl"></i>
                    </div>
                    <div>
                        <h1 class="text-4xl font-bold text-gray-800">Dish Monitor</h1>
                        <p class="text-gray-600">Track ready dishes and serve customers</p>
                    </div>
                </div>
            </div>

            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle mr-2"></i>
                        <span>${error}</span>
                    </div>
                </div>
            </c:if>

            <!-- Ready Section -->
            <div class="bg-white rounded-xl shadow-md p-6 mb-8">
                <div class="flex justify-between items-center mb-6">
                    <h2 class="text-2xl font-bold text-gray-800 flex items-center gap-3">
                        <span class="relative">
                            <i class="fas fa-bell text-orange-500"></i>
                            <c:if test="${not empty readyList}">
                                <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                                    ${readyList.size()}
                                </span>
                            </c:if>
                        </span>
                        READY TO SERVE
                    </h2>
                    <span class="px-4 py-2 bg-orange-100 text-orange-700 rounded-full font-semibold">
                        ${readyList.size()} dishes
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty readyList}">
                        <div class="text-center py-16">
                            <i class="fas fa-check-circle text-6xl text-gray-300 mb-4"></i>
                            <p class="text-gray-500 text-lg">No dishes ready to serve</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="space-y-4">
                            <c:forEach var="item" items="${readyList}">
                                <div class="dish-card pulse-animation bg-orange-50 border-l-4 border-orange-500 rounded-lg p-4">
                                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-center">
                                        <div class="md:col-span-2">
                                            <h3 class="text-xl font-bold text-gray-800 mb-2">
                                                <i class="fas fa-utensils text-orange-500"></i>
                                                ${item.productName} (${item.sizeCode})
                                            </h3>
                                            <p class="mb-2">
                                                <span class="font-semibold text-gray-700">Order #${item.orderID}</span>
                                                <span class="ml-2 px-3 py-1 bg-orange-500 text-white rounded-full text-xs font-semibold">
                                                    Ready
                                                </span>
                                            </p>
                                            <p class="text-gray-600 text-sm">
                                                <i class="fas fa-info-circle"></i>
                                                Quantity: ${item.quantity}
                                                <c:if test="${not empty item.specialInstructions}">
                                                    | Note: ${item.specialInstructions}
                                                </c:if>
                                            </p>
                                            <p class="text-gray-500 text-sm mt-2">
                                                <i class="fas fa-clock"></i>
                                                Completed: ${item.endTime}
                                            </p>
                                        </div>
                                        <div class="text-right">
                                            <form method="post" action="WaiterMonitor">
                                                <input type="hidden" name="action" value="served">
                                                <input type="hidden" name="orderDetailId" value="${item.orderDetailID}">
                                                <input type="hidden" name="orderId" value="${item.orderID}">
                                                <button type="submit" class="bg-green-500 hover:bg-green-600 text-white font-semibold px-6 py-3 rounded-lg transition-all transform hover:scale-105">
                                                    <i class="fas fa-check"></i> Mark as Served
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Served Section -->
            <div class="bg-white rounded-xl shadow-md p-6">
                <div class="flex justify-between items-center mb-6">
                    <h2 class="text-2xl font-bold text-gray-800 flex items-center gap-3">
                        <i class="fas fa-check-circle text-green-500"></i>
                        SERVED
                    </h2>
                    <span class="px-4 py-2 bg-green-100 text-green-700 rounded-full font-semibold">
                        ${servedList.size()} dishes
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty servedList}">
                        <div class="text-center py-16">
                            <i class="fas fa-inbox text-6xl text-gray-300 mb-4"></i>
                            <p class="text-gray-500 text-lg">No dishes served yet</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="space-y-4">
                            <c:forEach var="item" items="${servedList}">
                                <div class="dish-card bg-gray-50 border-l-4 border-green-500 rounded-lg p-4 opacity-80">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
                                        <div>
                                            <h3 class="text-xl font-bold text-gray-800 mb-2">
                                                <i class="fas fa-utensils text-green-500"></i>
                                                ${item.productName} (${item.sizeCode})
                                            </h3>
                                            <p class="mb-2">
                                                <span class="font-semibold text-gray-700">Order #${item.orderID}</span>
                                                <span class="ml-2 px-3 py-1 bg-green-500 text-white rounded-full text-xs font-semibold">
                                                    Served
                                                </span>
                                            </p>
                                            <p class="text-gray-600 text-sm">
                                                <i class="fas fa-info-circle"></i>
                                                Quantity: ${item.quantity}
                                            </p>
                                        </div>
                                        <div class="text-right">
                                            <p class="text-gray-500 text-sm">
                                                <i class="fas fa-clock"></i>
                                                Served at: ${item.endTime}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script>
        // Initialize Lucide icons
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
        
        // Auto-refresh every 10 seconds
        setTimeout(function() {
            location.reload();
        }, 10000);

        // Play notification sound when there are ready items
        <c:if test="${not empty readyList}">
            console.log('${readyList.size()} dishes ready to serve!');
        </c:if>
    </script>
</body>
</html>
