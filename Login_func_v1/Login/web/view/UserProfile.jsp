<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>User Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .discount-expiring { border-left: 4px solid #f59e0b; background-color: #fffbeb; }
        .scroll-container { max-height: 500px; overflow-y: auto; }
        .order-status-0 { background-color: #fef3c7; color: #d97706; }
        .order-status-1 { background-color: #dbeafe; color: #1d4ed8; }
        .order-status-2 { background-color: #dcfce7; color: #16a34a; }
        .order-status-3 { background-color: #dcfce7; color: #15803d; }
        .order-status-4 { background-color: #fee2e2; color: #dc2626; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen ml-20">
    <%-- Sidebar and Navbar --%>
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>

    <div class="flex">
        <!-- Tabbar -->
        <div class="w-64 bg-white shadow-lg min-h-screen p-6 mt-16">
            <div class="text-center mb-8">
                <div class="w-20 h-20 bg-orange-500 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i data-lucide="user" class="w-10 h-10 text-white"></i>
                </div>
                <h1 class="text-2xl font-bold text-gray-800">${user.name}</h1>
                <c:choose>
                    <c:when test="${user.role == 1}"><p class="text-gray-600">Administrator</p></c:when>
                    <c:when test="${user.role == 2}"><p class="text-gray-600">${employeeRole}</p></c:when>
                    <c:when test="${user.role == 3}"><p class="text-gray-600">Customer</p></c:when>
                </c:choose>
            </div>

            <nav class="space-y-2">
                <button onclick="showTab('personal')" class="w-full text-left px-4 py-3 rounded-lg bg-orange-500 text-white flex items-center">
                    <i data-lucide="user" class="w-5 h-5 mr-3"></i>Personal Information
                </button>
                <button onclick="showTab('password')" class="w-full text-left px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100 flex items-center">
                    <i data-lucide="lock" class="w-5 h-5 mr-3"></i>Password
                </button>
                
                <c:if test="${user.role == 3}">
                    <button onclick="showTab('loyalty')" class="w-full text-left px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100 flex items-center">
                        <i data-lucide="award" class="w-5 h-5 mr-3"></i>Loyalty & Vouchers
                    </button>
                    <button onclick="showTab('orders')" class="w-full text-left px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100 flex items-center">
                        <i data-lucide="history" class="w-5 h-5 mr-3"></i>Order History
                        <c:if test="${orderTotalOrders > 0}">
                            <span class="ml-2 bg-orange-500 text-white text-xs px-2 py-1 rounded-full">${orderTotalOrders}</span>
                        </c:if>
                    </button>
                </c:if>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="flex-1 p-8 mt-16">
            <!-- Personal Information Tab -->
            <div id="personal" class="tab-content active">
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-bold mb-6">Personal Information</h2>
                    
                    <c:if test="${not empty message}">
                        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">${message}</div>
                    </c:if>
                    
                    <c:if test="${not empty error}">
                        <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">${error}</div>
                    </c:if>

                    <form action="profile" method="post" class="space-y-4">
                        <div class="grid grid-cols-2 gap-4">
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
                                <input type="text" name="name" value="${user.name}" class="w-full p-2 border border-gray-300 rounded-lg" readonly></div>
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                                <input type="email" name="email" value="${user.email}" class="w-full p-2 border border-gray-300 rounded-lg"></div>
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                                <input type="text" name="phone" value="${user.phone}" class="w-full p-2 border border-gray-300 rounded-lg"></div>
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Gender</label>
                                <select name="gender" class="w-full p-2 border border-gray-300 rounded-lg">
                                    <option value="Male" ${user.gender == 'Male' ? 'selected' : ''}>Male</option>
                                    <option value="Female" ${user.gender == 'Female' ? 'selected' : ''}>Female</option>
                                    <option value="Other" ${user.gender == 'Other' ? 'selected' : ''}>Other</option>
                                </select></div>
                        </div>
                        <div class="flex justify-end">
                            <button type="submit" class="bg-orange-500 text-white px-6 py-2 rounded-lg hover:bg-orange-600">Update Information</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Password Tab -->
            <div id="password" class="tab-content">
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-bold mb-6">Change Password</h2>
                    <form action="profile" method="post" class="space-y-4">
                        <input type="hidden" name="action" value="changePassword">
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
                            <input type="password" name="oldPassword" class="w-full p-2 border border-gray-300 rounded-lg" required></div>
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                            <input type="password" name="newPassword" class="w-full p-2 border border-gray-300 rounded-lg" required></div>
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                            <input type="password" name="confirmPassword" class="w-full p-2 border border-gray-300 rounded-lg" required></div>
                        <div class="flex justify-end">
                            <button type="submit" class="bg-orange-500 text-white px-6 py-2 rounded-lg hover:bg-orange-600">Change Password</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Loyalty & Vouchers Tab -->
            <c:if test="${user.role == 3}">
                <div id="loyalty" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <h2 class="text-xl font-bold mb-6">Loyalty Points & Vouchers</h2>
                        
                        <!-- Loyalty Points -->
                        <div class="mb-8 p-6 bg-gradient-to-r from-orange-500 to-red-500 rounded-lg text-white">
                            <div class="flex justify-between items-center">
                                <div>
                                    <h3 class="text-lg font-semibold">Your Loyalty Points</h3>
                                    <p class="text-3xl font-bold">${loyaltyPoints} points</p>
                                    <p class="text-orange-100">≈ <fmt:formatNumber value="${loyaltyPoints * 1000}" type="currency" currencyCode="VND" /> value</p>
                                </div>
                                <i data-lucide="award" class="w-12 h-12"></i>
                            </div>
                        </div>

                        <!-- Vouchers -->
                        <div class="mb-8">
                            <h3 class="text-lg font-semibold mb-4">Your Vouchers</h3>
                            <c:choose>
                                <c:when test="${not empty customerDiscounts}">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <c:forEach var="discount" items="${customerDiscounts}">
                                            <div class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                                                <div class="flex justify-between items-start mb-2">
                                                    <h4 class="font-semibold">${discount.description} x${discount.quantity}</h4>
                                                    <span class="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full">${discount.discountType}</span>
                                                </div>
                                                <p class="text-sm text-gray-600 mb-2">
                                                    <c:choose>
                                                        <c:when test="${discount.discountType == 'Percentage'}">${discount.value}% off</c:when>
                                                        <c:when test="${discount.discountType == 'Fixed'}"><fmt:formatNumber value="${discount.value}" type="currency" currencyCode="VND" /> off</c:when>
                                                    </c:choose>
                                                    <c:if test="${discount.minOrderTotal > 0}">on orders over <fmt:formatNumber value="${discount.minOrderTotal}" type="currency" currencyCode="VND" /></c:if>
                                                </p>
                                                <c:if test="${discount.expiryDate != null}">
                                                    <p class="text-xs text-gray-500">Expires: <fmt:formatDate value="${discount.expiryDate}" pattern="MMM dd, yyyy" /></p>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-gray-500 text-center py-4">No vouchers available</p>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Available Discounts -->
                        <div>
                            <h3 class="text-lg font-semibold mb-4">Available Discounts</h3>
                            <c:choose>
                                <c:when test="${not empty activeDiscounts}">
                                    <div class="grid grid-cols-1 gap-3">
                                        <c:forEach var="discount" items="${activeDiscounts}">
                                            <c:set var="now" value="<%= new java.util.Date() %>" />
                                            <c:set var="sevenDaysFromNow" value="<%= new java.util.Date(new java.util.Date().getTime() + 7 * 24 * 60 * 60 * 1000) %>" />
                                            
                                            <div class="border rounded-lg p-4 ${discount.endDate != null && discount.endDate.time <= sevenDaysFromNow.time ? 'discount-expiring' : ''}">
                                                <div class="flex justify-between items-start">
                                                    <div>
                                                        <h4 class="font-semibold">${discount.description}</h4>
                                                        <p class="text-sm text-gray-600">
                                                            <c:choose>
                                                                <c:when test="${discount.discountType == 'Percentage'}">${discount.value}% off</c:when>
                                                                <c:when test="${discount.discountType == 'Fixed'}"><fmt:formatNumber value="${discount.value}" type="currency" currencyCode="VND" /> off</c:when>
                                                                <c:when test="${discount.discountType == 'Loyalty'}">${discount.value} points</c:when>
                                                            </c:choose>
                                                            <c:if test="${discount.minOrderTotal > 0}">• Min order: <fmt:formatNumber value="${discount.minOrderTotal}" type="currency" currencyCode="VND" /></c:if>
                                                        </p>
                                                    </div>
                                                    <div class="text-right">
                                                        <c:if test="${discount.endDate != null}">
                                                            <p class="text-sm ${discount.endDate.time <= sevenDaysFromNow.time ? 'text-orange-600 font-semibold' : 'text-gray-500'}">
                                                                Ends: <fmt:formatDate value="${discount.endDate}" pattern="MMM dd, yyyy" />
                                                            </p>
                                                        </c:if>
                                                        <c:if test="${discount.endDate == null}"><p class="text-sm text-green-600">No expiry</p></c:if>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-gray-500 text-center py-4">No active discounts available</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Order History Tab -->
                <div id="orders" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <h2 class="text-xl font-bold mb-6">Order History</h2>
                        
                        <c:choose>
                            <c:when test="${empty orders}">
                                <div class="text-center py-8 text-gray-500">
                                    <i data-lucide="shopping-cart" class="w-16 h-16 mx-auto mb-4 text-gray-300"></i>
                                    <p>No orders found.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-sm text-gray-600 mb-4">Showing ${orders.size()} of ${orderTotalOrders} orders</div>

                                <div class="scroll-container space-y-4">
                                    <c:forEach var="order" items="${orders}">
                                        <div class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                                            <div class="flex justify-between items-start mb-3">
                                                <div>
                                                    <h3 class="font-semibold">Order #${order.orderId}</h3>
                                                    <p class="text-sm text-gray-600"><fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy HH:mm" /></p>
                                                </div>
                                                <div class="text-right">
                                                    <p class="font-semibold text-lg"><fmt:formatNumber value="${order.totalPrice}" type="currency" currencyCode="VND" /></p>
                                                    <div class="flex items-center gap-2 mt-1">
                                                        <span class="px-2 py-1 text-xs rounded-full ${order.paymentStatus == 'Paid' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}">${order.paymentStatus}</span>
                                                        <span class="px-2 py-1 text-xs rounded-full order-status-${order.status}">
                                                            <c:choose>
                                                                <c:when test="${order.status == 0}">Pending</c:when>
                                                                <c:when test="${order.status == 1}">Preparing</c:when>
                                                                <c:when test="${order.status == 2}">Served</c:when>
                                                                <c:when test="${order.status == 3}">Completed</c:when>
                                                                <c:when test="${order.status == 4}">Cancelled</c:when>
                                                            </c:choose>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="flex justify-between items-center text-sm text-gray-600">
                                                <div>
                                                    <c:if test="${order.tableNumber != null}">Table ${order.tableNumber} • </c:if>
                                                    ${order.itemCount} items
                                                </div>
                                                
                                                <c:if test="${order.paymentStatus == 'Paid' && order.status == 3}">
                                                    <button onclick="openFeedbackModal(${order.orderId})" class="bg-orange-500 text-white px-3 py-1 rounded text-sm hover:bg-orange-600 flex items-center">
                                                        <i data-lucide="star" class="w-3 h-3 mr-1"></i>Give Feedback
                                                    </button>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Pagination -->
                                <div class="text-center text-sm text-gray-600 mt-6">
                                    Page ${orderCurrentPage} of ${orderTotalPages}
                                    <div class="flex justify-center gap-2 mt-2">
                                        <c:if test="${orderCurrentPage > 1}">
                                            <button onclick="loadOrderPage(${orderCurrentPage - 1})" class="px-3 py-1 border border-gray-300 rounded hover:bg-gray-100">Previous</button>
                                        </c:if>
                                        <c:if test="${orderCurrentPage < orderTotalPages}">
                                            <button onclick="loadOrderPage(${orderCurrentPage + 1})" class="px-3 py-1 border border-gray-300 rounded hover:bg-gray-100">Next</button>
                                        </c:if>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <script>
        lucide.createIcons();

        function showTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
            document.getElementById(tabName).classList.add('active');
            
            document.querySelectorAll('nav button').forEach(btn => {
                btn.classList.remove('bg-orange-500', 'text-white');
                btn.classList.add('text-gray-700', 'hover:bg-gray-100');
            });
            
            event.currentTarget.classList.add('bg-orange-500', 'text-white');
            event.currentTarget.classList.remove('text-gray-700', 'hover:bg-gray-100');
            
            sessionStorage.setItem('activeTab', tabName);
        }

        window.addEventListener('load', () => {
            const activeTab = sessionStorage.getItem('activeTab') || 'personal';
            showTab(activeTab);
        });

        function loadOrderPage(page) {
            sessionStorage.setItem('orderScrollData', JSON.stringify({
                page: ${orderCurrentPage},
                direction: page > ${orderCurrentPage} ? 'down' : 'up'
            }));
            window.location.href = `profile?orderPage=${page}`;
        }

        const scrollContainer = document.querySelector('.scroll-container');
        if (scrollContainer) {
            scrollContainer.addEventListener('scroll', () => {
                const scrollTop = scrollContainer.scrollTop;
                const scrollBottom = scrollContainer.clientHeight + scrollTop;

                if (scrollBottom >= scrollContainer.scrollHeight - 50 && ${orderCurrentPage} < ${orderTotalPages}) {
                    loadOrderPage(${orderCurrentPage} + 1);
                }

                if (scrollTop <= 0 && ${orderCurrentPage} > 1) {
                    loadOrderPage(${orderCurrentPage} - 1);
                }
            });

            const scrollData = sessionStorage.getItem('orderScrollData');
            if (scrollData) {
                const { page, direction } = JSON.parse(scrollData);
                sessionStorage.removeItem('orderScrollData');

                if (direction === 'down' && page + 1 === ${orderCurrentPage}) {
                    scrollContainer.scrollTop = 10;
                }
                if (direction === 'up' && page - 1 === ${orderCurrentPage}) {
                    scrollContainer.scrollTop = scrollContainer.scrollHeight - scrollContainer.clientHeight - 10;
                }
            }
        }

        function openFeedbackModal(orderId) {
            alert('Feedback functionality for order #' + orderId + ' will be implemented here');
        }
    </script>
</body>
</html>