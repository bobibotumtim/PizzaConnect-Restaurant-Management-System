<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<%
    HttpSession userSession = request.getSession(false);
    User user = (userSession != null) ? (User) userSession.getAttribute("user") : null;
    Employee employee = (userSession != null) ? (Employee) userSession.getAttribute("employee") : null;
    
    if (user == null || user.getRole() != 2) {
        response.sendRedirect("view/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Waiter Dashboard - Pizza Store</title>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .main-content {
            margin-left: 80px;
            padding: 30px;
        }
        
        .welcome-section {
            background: white;
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .welcome-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
        }
        
        .welcome-title {
            font-size: 32px;
            font-weight: bold;
            color: #1f2937;
            margin-bottom: 10px;
        }
        
        .welcome-subtitle {
            font-size: 18px;
            color: #6b7280;
        }
        
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }
        
        .menu-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: block;
            position: relative;
            overflow: hidden;
        }
        
        .menu-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }
        
        .menu-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }
        
        .menu-card:hover::before {
            transform: scaleX(1);
        }
        
        .menu-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
        }
        
        .menu-title {
            font-size: 22px;
            font-weight: bold;
            color: #1f2937;
            margin-bottom: 10px;
        }
        
        .menu-description {
            color: #6b7280;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            text-align: center;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .stat-label {
            color: #6b7280;
            font-size: 14px;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="Sidebar.jsp" />
    
    <div class="main-content">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-icon">
                <i data-lucide="user" style="width: 40px; height: 40px; color: white;"></i>
            </div>
            <div class="welcome-title">Welcome, <%= employee != null ? employee.getName() : user.getName() %>!</div>
            <div class="welcome-subtitle">Welcome to Pizza Store Restaurant Management System</div>
        </div>
        
        <!-- Quick Stats -->
        <div class="stats-section">
            <div class="stat-card">
                <div class="stat-number">
                    <i data-lucide="clock" style="width: 36px; height: 36px;"></i>
                </div>
                <div class="stat-label">Current Shift</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">
                    <i data-lucide="check-circle" style="width: 36px; height: 36px;"></i>
                </div>
                <div class="stat-label">Ready to Serve</div>
            </div>
        </div>
        
        <!-- Menu Grid -->
        <div class="menu-grid">
            <!-- POS -->
            <a href="pos" class="menu-card">
                <div class="menu-icon">
                    <i data-lucide="shopping-cart" style="width: 30px; height: 30px; color: white;"></i>
                </div>
                <div class="menu-title">Point of Sale (POS)</div>
                <div class="menu-description">
                    Create new orders, add items, and process payments for customers
                </div>
            </a>
            
            <!-- Assign Tables -->
            <a href="assign-table" class="menu-card">
                <div class="menu-icon">
                    <i data-lucide="layout-grid" style="width: 30px; height: 30px; color: white;"></i>
                </div>
                <div class="menu-title">Table Management</div>
                <div class="menu-description">
                    View table status, check orders and manage assigned tables
                </div>
            </a>
            
            <!-- Waiter Monitor -->
            <a href="WaiterMonitor" class="menu-card">
                <div class="menu-icon">
                    <i data-lucide="bell" style="width: 30px; height: 30px; color: white;"></i>
                </div>
                <div class="menu-title">Dish Monitor</div>
                <div class="menu-description">
                    Track ready dishes from kitchen and mark dishes as served
                </div>
            </a>
            
            <!-- Manage Orders -->
            <a href="manage-orders" class="menu-card">
                <div class="menu-icon">
                    <i data-lucide="file-text" style="width: 30px; height: 30px; color: white;"></i>
                </div>
                <div class="menu-title">Order Management</div>
                <div class="menu-description">
                    View order details, update status and handle customer requests
                </div>
            </a>
            
            <!-- Profile -->
            <a href="profile" class="menu-card">
                <div class="menu-icon">
                    <i data-lucide="user-circle" style="width: 30px; height: 30px; color: white;"></i>
                </div>
                <div class="menu-title">Personal Profile</div>
                <div class="menu-description">
                    View and update personal information, change password
                </div>
            </a>
        </div>
    </div>
    
    <script>
        // Initialize Lucide icons
        lucide.createIcons();
        
        // Add animation on load
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.menu-card');
            cards.forEach((card, index) => {
                setTimeout(() => {
                    card.style.opacity = '0';
                    card.style.transform = 'translateY(20px)';
                    card.style.transition = 'all 0.5s ease';
                    
                    setTimeout(() => {
                        card.style.opacity = '1';
                        card.style.transform = 'translateY(0)';
                    }, 50);
                }, index * 100);
            });
        });
    </script>
</body>
</html>
