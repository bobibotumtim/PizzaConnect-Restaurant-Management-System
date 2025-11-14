<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<%
    // Get user and employee from session
    HttpSession sidebarSession = request.getSession(false);
    User sidebarUser = (sidebarSession != null) ? (User) sidebarSession.getAttribute("user") : null;
    Employee sidebarEmployee = (sidebarSession != null) ? (Employee) sidebarSession.getAttribute("employee") : null;
    
    // Determine current page for active state
    String sidebarCurrentPath = request.getRequestURI();
    String sidebarContextPath = request.getContextPath();
    
    // Check if user is Chef
    boolean sidebarIsChef = (sidebarEmployee != null && sidebarEmployee.isChef());
    boolean sidebarIsAdmin = (sidebarUser != null && sidebarUser.getRole() == 1);
    boolean sidebarIsWaiter = (sidebarUser != null && sidebarUser.getRole() == 2 && !sidebarIsChef);
%>

<style>
    /* Sidebar Styles */
    .sidebar {
        position: fixed;
        left: 0;
        top: 0;
        height: 100vh;
        width: 80px;
        background: #1f2937;
        transition: width 0.3s ease;
        z-index: 1000;
        overflow-x: hidden;
        overflow-y: auto;
        box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        display: flex;
        flex-direction: column;
    }
    
    .sidebar:hover {
        width: 240px;
    }
    
    /* Hide scrollbar completely */
    .sidebar::-webkit-scrollbar {
        display: none;
        width: 0;
        height: 0;
    }
    
    .sidebar {
        -ms-overflow-style: none;  /* IE and Edge */
        scrollbar-width: none;  /* Firefox */
    }
    
    /* Also hide for the navigation items container */
    .sidebar > div::-webkit-scrollbar {
        display: none;
        width: 0;
        height: 0;
    }
    
    .sidebar-item {
        display: flex;
        align-items: center;
        padding: 16px 20px;
        color: #9ca3af;
        text-decoration: none;
        transition: all 0.2s ease;
        white-space: nowrap;
        cursor: pointer;
    }
    
    .sidebar-item:hover {
        background: #374151;
        color: #f97316;
    }
    
    .sidebar-item.active {
        background: #f97316;
        color: white;
    }
    
    .sidebar-icon {
        min-width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .sidebar-text {
        margin-left: 16px;
        font-size: 14px;
        font-weight: 500;
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .sidebar:hover .sidebar-text {
        opacity: 1;
    }
    
    .sidebar-divider {
        height: 1px;
        background: rgba(255,255,255,0.1);
        margin: 8px 20px;
    }
    
    .sidebar-header {
        padding: 24px 20px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
        text-align: center;
    }
    
    .sidebar-logo {
        font-size: 32px;
    }
</style>

<!-- Load Lucide Icons if not already loaded -->
<script>
    if (typeof lucide === 'undefined') {
        document.write('<script src="https://unpkg.com/lucide@latest"><\/script>');
    }
</script>

<!-- Sidebar Navigation -->
<div class="sidebar">
    <!-- Header/Logo -->
    <div class="sidebar-header">
        <% 
            String logoLink = sidebarContextPath + "/home"; // Default for customer
            if (sidebarIsAdmin) {
                logoLink = sidebarContextPath + "/dashboard";
            } else if (sidebarIsChef) {
                logoLink = sidebarContextPath + "/ChefMonitor";
            } else if (sidebarIsWaiter) {
                logoLink = sidebarContextPath + "/waiter-dashboard";
            }
        %>
        <a href="<%= logoLink %>" style="text-decoration: none; color: inherit;">
            <div class="sidebar-logo">&#127829;</div>
        </a>
    </div>
    
    <!-- Navigation Items -->
    <div style="flex: 1; overflow-y: auto; overflow-x: hidden; padding: 8px 0;">
        <% if (sidebarIsAdmin) { %>
            <!-- ADMIN MENU -->
            <a href="<%= sidebarContextPath %>/dashboard" class="sidebar-item <%= sidebarCurrentPath.contains("/dashboard") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="layout-dashboard"></i></div>
                <span class="sidebar-text">Dashboard</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/manageproduct" class="sidebar-item <%= sidebarCurrentPath.contains("/manageproduct") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="package"></i></div>
                <span class="sidebar-text">Products</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/managecategory" class="sidebar-item <%= sidebarCurrentPath.contains("/managecategory") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="folder"></i></div>
                <span class="sidebar-text">Categories</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/admin" class="sidebar-item <%= sidebarCurrentPath.contains("/admin") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="users"></i></div>
                <span class="sidebar-text">Users</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/discount" class="sidebar-item <%= sidebarCurrentPath.contains("/discount") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="percent"></i></div>
                <span class="sidebar-text">Discounts</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/table" class="sidebar-item <%= sidebarCurrentPath.contains("/table") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="layout-grid"></i></div>
                <span class="sidebar-text">Tables</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/inventory" class="sidebar-item <%= sidebarCurrentPath.contains("/inventory") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="box"></i></div>
                <span class="sidebar-text">Inventory</span>
            </a>
            
            <div class="sidebar-divider"></div>
            
            <a href="<%= sidebarContextPath %>/profile" class="sidebar-item <%= sidebarCurrentPath.contains("/profile") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="user"></i></div>
                <span class="sidebar-text">Profile</span>
            </a>
            
        <% } else if (sidebarIsChef) { %>
            <!-- CHEF MENU -->
            <a href="<%= sidebarContextPath %>/ChefMonitor" class="sidebar-item <%= sidebarCurrentPath.contains("/ChefMonitor") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="cooking-pot"></i></div>
                <span class="sidebar-text">Chef Monitor</span>
            </a>

            <a href="<%= sidebarContextPath %>/profile" class="sidebar-item <%= sidebarCurrentPath.contains("/profile") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="user"></i></div>
                <span class="sidebar-text">Profile</span>
            </a>
            
        <% } else if (sidebarIsWaiter) { %>
            <!-- WAITER MENU -->
            <a href="<%= sidebarContextPath %>/pos" class="sidebar-item <%= sidebarCurrentPath.contains("/pos") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="shopping-cart"></i></div>
                <span class="sidebar-text">POS</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/WaiterMonitor" class="sidebar-item <%= sidebarCurrentPath.contains("/WaiterMonitor") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="bell"></i></div>
                <span class="sidebar-text">Waiter Monitor</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/assign-table" class="sidebar-item <%= sidebarCurrentPath.contains("/assign-table") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="layout-grid"></i></div>
                <span class="sidebar-text">Assign Table</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/manage-orders" class="sidebar-item <%= sidebarCurrentPath.contains("/manage-orders") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="file-text"></i></div>
                <span class="sidebar-text">Manage Orders</span>
            </a>

            <a href="<%= sidebarContextPath %>/profile" class="sidebar-item <%= sidebarCurrentPath.contains("/profile") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="user"></i></div>
                <span class="sidebar-text">Profile</span>
            </a>
        <% } else { %>
            <!-- CUSTOMER MENU -->
            <a href="<%= sidebarContextPath %>/home" class="sidebar-item <%= sidebarCurrentPath.contains("/home") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="home"></i></div>
                <span class="sidebar-text">Home</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/customer-menu" class="sidebar-item <%= sidebarCurrentPath.contains("/customer-menu") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="utensils"></i></div>
                <span class="sidebar-text">Menu</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/order-history" class="sidebar-item <%= sidebarCurrentPath.contains("/order-history") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="shopping-bag"></i></div>
                <span class="sidebar-text">Order History</span>
            </a>
            
            <div class="sidebar-divider"></div>
            
            <a href="<%= sidebarContextPath %>/profile" class="sidebar-item <%= sidebarCurrentPath.contains("/profile") ? "active" : "" %>">
                <div class="sidebar-icon"><i data-lucide="user"></i></div>
                <span class="sidebar-text">Profile</span>
            </a>
        <% } %>
    </div>
</div>

<!-- Initialize Lucide Icons -->
<script>
    // Wait for Lucide to load, then initialize icons
    (function initLucide() {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        } else {
            setTimeout(initLucide, 100);
        }
    })();
</script>
