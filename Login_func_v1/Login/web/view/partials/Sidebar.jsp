<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String currentPath = request.getRequestURI();
    String activePage = request.getParameter("activePage");
    if (activePage == null) {
        activePage = "";
    }
%>

<!-- Sidebar Navigation -->
<div class="sidebar w-20 bg-gray-800 flex flex-col items-center py-6 justify-between">
    <div class="flex flex-col items-center space-y-6">
        <!-- Logo -->
        <a href="${pageContext.request.contextPath}/dashboard"
           class="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-lg">
            <i data-lucide="pizza" class="w-7 h-7 text-white"></i>
        </a>
        
        <!-- Navigation Links -->
        <div class="flex flex-col items-center space-y-4 mt-8">
            <!-- Dashboard -->
            <a href="${pageContext.request.contextPath}/dashboard"
               class="nav-btn <%= currentPath.contains("/dashboard") || "dashboard".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Dashboard">
                <i data-lucide="grid" class="w-6 h-6"></i>
            </a>

            <!-- Orders -->
            <a href="${pageContext.request.contextPath}/manage-orders"
               class="nav-btn <%= currentPath.contains("/orders") || "orders".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Orders">
                <i data-lucide="file-text" class="w-6 h-6"></i>
            </a>

            <!-- Products -->
            <a href="${pageContext.request.contextPath}/manageproduct"
               class="nav-btn <%= currentPath.contains("/manageproduct") || "products".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Products">
                <i data-lucide="utensils" class="w-6 h-6"></i>
            </a>

            <!-- POS -->
            <a href="${pageContext.request.contextPath}/pos"
               class="nav-btn <%= currentPath.contains("/pos") || "pos".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="POS">
                <i data-lucide="shopping-cart" class="w-6 h-6"></i>
            </a>

            <!-- Categories -->
            <a href="${pageContext.request.contextPath}/managecategory"
               class="nav-btn <%= currentPath.contains("/managecategory") || "categories".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Categories">
                <i data-lucide="package" class="w-6 h-6"></i>
            </a>

            <!-- Inventory -->
            <a href="${pageContext.request.contextPath}/manageinventory"
               class="nav-btn <%= currentPath.contains("/manageinventory") || "inventory".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Inventory">
                <i data-lucide="box" class="w-6 h-6"></i>
            </a>

            <!-- Inventory Monitor -->
            <a href="${pageContext.request.contextPath}/view/InventoryMonitorBeautiful.jsp"
               class="nav-btn <%= currentPath.contains("/InventoryMonitor") || "monitor".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Inventory Monitor">
                <i data-lucide="activity" class="w-6 h-6"></i>
            </a>

            <!-- Sales Reports -->
            <a href="${pageContext.request.contextPath}/sales-reports"
               class="nav-btn <%= currentPath.contains("/sales-reports") || "reports".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Sales Reports">
                <i data-lucide="bar-chart-2" class="w-6 h-6"></i>
            </a>

            <!-- Customer Feedback -->
            <a href="${pageContext.request.contextPath}/view/CustomerFeedbackWorking.jsp"
               class="nav-btn <%= currentPath.contains("/customer-feedback") || "feedback".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Customer Feedback">
                <i data-lucide="message-circle" class="w-6 h-6"></i>
            </a>

            <!-- Admin/Users (Admin only) -->
            <a href="${pageContext.request.contextPath}/admin"
               class="nav-btn <%= currentPath.contains("/admin") || "admin".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Manage Users">
                <i data-lucide="users" class="w-6 h-6"></i>
            </a>

            <!-- Tables -->
            <a href="${pageContext.request.contextPath}/table"
               class="nav-btn <%= currentPath.contains("/table") || "tables".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Tables">
                <i data-lucide="layout-grid" class="w-6 h-6"></i>
            </a>
        </div>
    </div>
    
    <!-- Bottom Section -->
    <div class="flex flex-col items-center space-y-4">
        <!-- Profile -->
        <a href="${pageContext.request.contextPath}/profile"
           class="nav-btn <%= currentPath.contains("/profile") || "profile".equals(activePage) ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
           title="Profile">
            <i data-lucide="user" class="w-6 h-6"></i>
        </a>

        <!-- Logout -->
        <a href="${pageContext.request.contextPath}/logout"
           class="nav-btn text-gray-400 hover:bg-red-600 hover:text-white"
           title="Logout">
            <i data-lucide="log-out" class="w-6 h-6"></i>
        </a>
    </div>
</div>

<!-- Mobile Navigation Toggle -->
<div class="md:hidden fixed top-4 left-4 z-50">
    <button id="mobile-menu-toggle"
            class="p-2 bg-orange-500 text-white rounded-lg shadow-lg hover:bg-orange-600 transition-colors">
        <i data-lucide="menu" class="w-6 h-6"></i>
    </button>
</div>

<!-- Mobile Navigation Overlay -->
<div id="mobile-menu-overlay" class="md:hidden fixed inset-0 bg-black bg-opacity-50 z-40 hidden">
    <div class="fixed left-0 top-0 h-full w-64 bg-gray-800 transform -translate-x-full transition-transform duration-300" id="mobile-menu">
        <div class="p-6">
            <div class="flex items-center justify-between mb-8">
                <h2 class="text-white text-xl font-bold">🍕 Pizza Store</h2>
                <button id="mobile-menu-close" class="text-gray-400 hover:text-white">
                    <i data-lucide="x" class="w-6 h-6"></i>
                </button>
            </div>
            
            <nav class="space-y-4">
                <a href="${pageContext.request.contextPath}/dashboard" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="grid" class="w-5 h-5"></i>
                    <span>Dashboard</span>
                </a>
                <a href="${pageContext.request.contextPath}/manage-orders" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="file-text" class="w-5 h-5"></i>
                    <span>Orders</span>
                </a>
                <a href="${pageContext.request.contextPath}/manageproduct" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="utensils" class="w-5 h-5"></i>
                    <span>Products</span>
                </a>
                <a href="${pageContext.request.contextPath}/pos" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="shopping-cart" class="w-5 h-5"></i>
                    <span>POS</span>
                </a>
                <a href="${pageContext.request.contextPath}/manageinventory" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="box" class="w-5 h-5"></i>
                    <span>Inventory</span>
                </a>
                <a href="${pageContext.request.contextPath}/view/InventoryMonitorBeautiful.jsp" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="activity" class="w-5 h-5"></i>
                    <span>Inventory Monitor</span>
                </a>
                <a href="${pageContext.request.contextPath}/sales-reports" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="bar-chart-2" class="w-5 h-5"></i>
                    <span>Sales Reports</span>
                </a>
                <a href="${pageContext.request.contextPath}/view/CustomerFeedbackWorking.jsp" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="message-circle" class="w-5 h-5"></i>
                    <span>Customer Feedback</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin" class="flex items-center space-x-3 text-gray-300 hover:text-white hover:bg-gray-700 p-3 rounded-lg">
                    <i data-lucide="users" class="w-5 h-5"></i>
                    <span>Manage Users</span>
                </a>
            </nav>
        </div>
    </div>
</div>

<script>
    // Mobile menu toggle functionality
    document.addEventListener('DOMContentLoaded', function() {
        const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
        const mobileMenuOverlay = document.getElementById('mobile-menu-overlay');
        const mobileMenu = document.getElementById('mobile-menu');
        const mobileMenuClose = document.getElementById('mobile-menu-close');

        function openMobileMenu() {
            mobileMenuOverlay.classList.remove('hidden');
            setTimeout(() => {
                mobileMenu.classList.remove('-translate-x-full');
            }, 10);
        }

        function closeMobileMenu() {
            mobileMenu.classList.add('-translate-x-full');
            setTimeout(() => {
                mobileMenuOverlay.classList.add('hidden');
            }, 300);
        }

        if (mobileMenuToggle) {
            mobileMenuToggle.addEventListener('click', openMobileMenu);
        }

        if (mobileMenuClose) {
            mobileMenuClose.addEventListener('click', closeMobileMenu);
        }

        if (mobileMenuOverlay) {
            mobileMenuOverlay.addEventListener('click', function(e) {
                if (e.target === mobileMenuOverlay) {
                    closeMobileMenu();
                }
            });
        }
    });
</script>