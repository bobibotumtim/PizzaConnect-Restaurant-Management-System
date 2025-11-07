<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<%
    // Get user and employee from session
    HttpSession navbarSession = request.getSession(false);
    User navbarUser = (navbarSession != null) ? (User) navbarSession.getAttribute("user") : null;
    Employee navbarEmployee = (navbarSession != null) ? (Employee) navbarSession.getAttribute("employee") : null;
    
    String navbarContextPath = request.getContextPath();
    String navbarCurrentPath = request.getRequestURI();
    
    // Determine page title
    String pageTitle = "PizzaConnect";
    if (navbarCurrentPath.contains("/dashboard")) pageTitle = "Dashboard";
    else if (navbarCurrentPath.contains("/ChefMonitor")) pageTitle = "Chef Monitor";
    else if (navbarCurrentPath.contains("/WaiterMonitor")) pageTitle = "Waiter Monitor";
    else if (navbarCurrentPath.contains("/manage-orders")) pageTitle = "Manage Orders";
    else if (navbarCurrentPath.contains("/pos")) pageTitle = "POS";
    else if (navbarCurrentPath.contains("/menu")) pageTitle = "Menu";
    else if (navbarCurrentPath.contains("/manageproduct")) pageTitle = "Products";
    else if (navbarCurrentPath.contains("/admin")) pageTitle = "Users";
    else if (navbarCurrentPath.contains("/table")) pageTitle = "Tables";
    else if (navbarCurrentPath.contains("/inventory")) pageTitle = "Inventory";
    
    // Check user role
    boolean navbarIsChef = (navbarEmployee != null && navbarEmployee.isChef());
    boolean navbarIsAdmin = (navbarUser != null && navbarUser.getRole() == 1);
    boolean navbarIsWaiter = (navbarUser != null && navbarUser.getRole() == 2 && !navbarIsChef);
%>

<style>
    /* Top Navbar Styles */
    .top-navbar {
        position: fixed;
        top: 0;
        left: 60px;
        right: 0;
        height: 60px;
        background: white;
        border-bottom: 1px solid #e5e7eb;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 24px;
        z-index: 999;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    
    .navbar-title {
        font-size: 20px;
        font-weight: 600;
        color: #111827;
    }
    
    .navbar-user-section {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    
    .navbar-user-info {
        text-align: right;
    }
    
    .navbar-user-name {
        font-size: 14px;
        font-weight: 600;
        color: #111827;
    }
    
    .navbar-user-role {
        font-size: 12px;
        color: #6b7280;
    }
    
    .navbar-logout-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: #ef4444;
        color: white;
        border-radius: 6px;
        text-decoration: none;
        font-size: 14px;
        font-weight: 500;
        transition: background 0.2s;
    }
    
    .navbar-logout-btn:hover {
        background: #dc2626;
        color: white;
    }
    
    /* Content wrapper adjustment for both sidebar and navbar */
    .content-wrapper {
        margin-left: 60px;
        margin-top: 60px;
        min-height: calc(100vh - 60px);
        transition: margin-left 0.3s ease;
    }
</style>

<!-- Top Navbar -->
<div class="top-navbar">
    <!-- Page Title -->
    <div class="navbar-title">
        &#127829; <%= pageTitle %>
    </div>
    
    <!-- User Info & Logout -->
    <div class="navbar-user-section">
        <% if (navbarUser != null) { %>
        <div class="navbar-user-info">
            <div class="navbar-user-name"><%= navbarUser.getName() %></div>
            <div class="navbar-user-role">
                <% if (navbarIsAdmin) { %>
                    &#128081; Admin
                <% } else if (navbarIsChef && navbarEmployee != null) { %>
                    &#128104;&#8205;&#127859; Chef - <%= navbarEmployee.getSpecialization() %>
                <% } else if (navbarIsWaiter) { %>
                    &#128084; Waiter
                <% } else { %>
                    Employee
                <% } %>
            </div>
        </div>
        <% } %>
        
        <a href="<%= navbarContextPath %>/Login?action=logout" class="navbar-logout-btn">
            <span>&#128682;</span>
            <span>Logout</span>
        </a>
    </div>
</div>
