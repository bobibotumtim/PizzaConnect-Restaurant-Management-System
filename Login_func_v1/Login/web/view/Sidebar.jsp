<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        width: 60px;
        background: linear-gradient(180deg, #1f2937 0%, #111827 100%);
        transition: width 0.3s ease;
        z-index: 1000;
        overflow-x: hidden;
        overflow-y: auto;
        box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        display: flex;
        flex-direction: column;
    }
    
    /* Hide scrollbar but keep functionality */
    .sidebar::-webkit-scrollbar {
        width: 0px;
        background: transparent;
    }
    
    .sidebar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
    
    .sidebar:hover {
        width: 240px;
    }
    
    .sidebar-item {
        display: flex;
        align-items: center;
        padding: 12px 16px;
        color: #9ca3af;
        text-decoration: none;
        transition: all 0.2s ease;
        white-space: nowrap;
        cursor: pointer;
    }
    
    .sidebar-item:hover {
        background: rgba(249, 115, 22, 0.1);
        color: #f97316;
    }
    
    .sidebar-item.active {
        background: #f97316;
        color: white;
    }
    
    .sidebar-icon {
        min-width: 28px;
        font-size: 20px;
        text-align: center;
    }
    
    .sidebar-text {
        margin-left: 12px;
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
        margin: 8px 16px;
    }
    
    .sidebar-header {
        padding: 20px 16px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    
    .sidebar-logo {
        font-size: 24px;
        text-align: center;
    }
</style>

<!-- Sidebar Navigation -->
<div class="sidebar">
    <!-- Header/Logo -->
    <div class="sidebar-header">
        <div class="sidebar-logo">🍕</div>
    </div>
    
    <!-- Navigation Items -->
    <div style="flex: 1; overflow-y: auto; overflow-x: hidden; padding: 8px 0;">
        <% if (sidebarIsAdmin) { %>
            <!-- ADMIN MENU -->
            <a href="<%= sidebarContextPath %>/home" class="sidebar-item <%= sidebarCurrentPath.contains("/home") ? "active" : "" %>">
                <span class="sidebar-icon">🏠</span>
                <span class="sidebar-text">Home</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/dashboard" class="sidebar-item <%= sidebarCurrentPath.contains("/dashboard") ? "active" : "" %>">
                <span class="sidebar-icon">📊</span>
                <span class="sidebar-text">Dashboard</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/manage-orders" class="sidebar-item <%= sidebarCurrentPath.contains("/manage-orders") ? "active" : "" %>">
                <span class="sidebar-icon">📋</span>
                <span class="sidebar-text">Orders</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/menu" class="sidebar-item <%= sidebarCurrentPath.contains("/menu") ? "active" : "" %>">
                <span class="sidebar-icon">🍕</span>
                <span class="sidebar-text">Menu</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/pos" class="sidebar-item <%= sidebarCurrentPath.contains("/pos") ? "active" : "" %>">
                <span class="sidebar-icon">🛒</span>
                <span class="sidebar-text">POS</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/manageproduct" class="sidebar-item <%= sidebarCurrentPath.contains("/manageproduct") ? "active" : "" %>">
                <span class="sidebar-icon">📦</span>
                <span class="sidebar-text">Products</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/admin" class="sidebar-item <%= sidebarCurrentPath.contains("/admin") ? "active" : "" %>">
                <span class="sidebar-icon">👥</span>
                <span class="sidebar-text">Users</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/discount" class="sidebar-item <%= sidebarCurrentPath.contains("/discount") ? "active" : "" %>">
                <span class="sidebar-icon">💰</span>
                <span class="sidebar-text">Discount</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/table" class="sidebar-item <%= sidebarCurrentPath.contains("/table") ? "active" : "" %>">
                <span class="sidebar-icon">🪑</span>
                <span class="sidebar-text">Tables</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/inventory" class="sidebar-item <%= sidebarCurrentPath.contains("/inventory") ? "active" : "" %>">
                <span class="sidebar-icon">📦</span>
                <span class="sidebar-text">Inventory</span>
            </a>
            
            <div class="sidebar-divider"></div>
            
            <a href="<%= sidebarContextPath %>/profile" class="sidebar-item <%= sidebarCurrentPath.contains("/profile") ? "active" : "" %>">
                <span class="sidebar-icon">👤</span>
                <span class="sidebar-text">Profile</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/settings" class="sidebar-item <%= sidebarCurrentPath.contains("/settings") ? "active" : "" %>">
                <span class="sidebar-icon">⚙️</span>
                <span class="sidebar-text">Settings</span>
            </a>
            
        <% } else if (sidebarIsChef) { %>
            <!-- CHEF MENU -->
            <a href="<%= sidebarContextPath %>/ChefMonitor" class="sidebar-item <%= sidebarCurrentPath.contains("/ChefMonitor") ? "active" : "" %>">
                <span class="sidebar-icon">🍳</span>
                <span class="sidebar-text">Chef Monitor</span>
            </a>
            
        <% } else if (sidebarIsWaiter) { %>
            <!-- WAITER MENU -->
            <a href="<%= sidebarContextPath %>/pos" class="sidebar-item <%= sidebarCurrentPath.contains("/pos") ? "active" : "" %>">
                <span class="sidebar-icon">📝</span>
                <span class="sidebar-text">POS</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/WaiterMonitor" class="sidebar-item <%= sidebarCurrentPath.contains("/WaiterMonitor") ? "active" : "" %>">
                <span class="sidebar-icon">🔔</span>
                <span class="sidebar-text">Waiter Monitor</span>
            </a>
            
            <a href="<%= sidebarContextPath %>/manage-orders" class="sidebar-item <%= sidebarCurrentPath.contains("/manage-orders") ? "active" : "" %>">
                <span class="sidebar-icon">📋</span>
                <span class="sidebar-text">Manage Orders</span>
            </a>
        <% } %>
    </div>
    
    <!-- Logout at bottom -->
    <div style="margin-top: auto;">
        <div class="sidebar-divider"></div>
        <a href="<%= sidebarContextPath %>/Login?action=logout" class="sidebar-item">
            <span class="sidebar-icon">🚪</span>
            <span class="sidebar-text">Logout</span>
        </a>
    </div>
</div>
