<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@ page import="dao.MonitorDAO" %>
<%@ page import="models.*" %>

<%
    // Get 100% real data from database - no sample data
    MonitorDAO monitorDAO = new MonitorDAO();
    DashboardMetrics metrics = null;
    List<MonitorDAO.InventoryDisplayItem> displayItems = new ArrayList<>();
    String errorMessage = null;
    
    try {
        metrics = monitorDAO.getDashboardMetrics();
        displayItems = monitorDAO.getAllInventoryForDisplay();
    } catch (Exception e) {
        errorMessage = "Lỗi kết nối database: " + e.getMessage();
        e.printStackTrace();
    }
    
    if (metrics == null) {
        metrics = new DashboardMetrics();
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss - dd/MM/yyyy");
    String currentTime = sdf.format(new Date());
    
    // Count status from real data
    int okCount = 0;
    int lowCount = 0;
    int criticalCount = 0;
    
    for (MonitorDAO.InventoryDisplayItem item : displayItems) {
        String status = item.getStatus();
        switch (status) {
            case "ok": okCount++; break;
            case "low": lowCount++; break;
            case "critical": criticalCount++; break;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitor Tồn Kho - Pizza Store</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .header {
            background: white;
            padding: 25px 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            color: #333;
            font-size: 28px;
        }

        .header .time {
            color: #666;
            font-size: 16px;
        }

        .header .back-btn {
            background: #6c757d;
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
            transition: background 0.3s;
        }

        .header .back-btn:hover {
            background: #5a6268;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
        }

        .stat-icon.ok {
            background: #d4edda;
            color: #155724;
        }

        .stat-icon.warning {
            background: #fff3cd;
            color: #856404;
        }

        .stat-icon.critical {
            background: #f8d7da;
            color: #721c24;
        }

        .stat-info h3 {
            color: #666;
            font-size: 14px;
            font-weight: normal;
            margin-bottom: 5px;
        }

        .stat-info .value {
            color: #333;
            font-size: 32px;
            font-weight: bold;
        }

        .inventory-table {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .table-header {
            padding: 25px 30px;
            border-bottom: 2px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .table-header h2 {
            color: #333;
            font-size: 22px;
        }

        .refresh-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: background 0.3s;
        }

        .refresh-btn:hover {
            background: #5568d3;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: #f8f9fa;
        }

        th {
            padding: 15px 20px;
            text-align: left;
            color: #666;
            font-weight: 600;
            font-size: 14px;
            text-transform: uppercase;
        }

        td {
            padding: 20px;
            border-top: 1px solid #f0f0f0;
            color: #333;
        }

        tbody tr {
            transition: background 0.2s;
        }

        tbody tr:hover {
            background: #f8f9fa;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-ok {
            background: #d4edda;
            color: #155724;
        }

        .status-low {
            background: #fff3cd;
            color: #856404;
        }

        .status-critical {
            background: #f8d7da;
            color: #721c24;
        }

        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e9ecef;
            border-radius: 10px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 10px;
            transition: width 0.3s;
        }

        .progress-ok {
            background: #28a745;
        }

        .progress-low {
            background: #ffc107;
        }

        .progress-critical {
            background: #dc3545;
        }

        .category-tag {
            display: inline-block;
            padding: 4px 10px;
            background: #e9ecef;
            color: #495057;
            border-radius: 5px;
            font-size: 12px;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
        }

        .pulse {
            animation: pulse 2s infinite;
        }

        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>🍕 Monitor Tồn Kho Pizza Store</h1>
            </div>
            <div style="display: flex; align-items: center; gap: 20px;">
                <div class="time">
                    <strong>Cập nhật:</strong> <%= currentTime %>
                </div>
                <a href="${pageContext.request.contextPath}/dashboard" class="back-btn">
                    ← Quay lại Dashboard
                </a>
            </div>
        </div>

        <% if (errorMessage != null) { %>
            <div class="error-message">
                <strong>Lỗi:</strong> <%= errorMessage %>
            </div>
        <% } %>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon ok">
                    ✓
                </div>
                <div class="stat-info">
                    <h3>Đủ hàng</h3>
                    <div class="value"><%= okCount %></div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon warning">
                    ⚠
                </div>
                <div class="stat-info">
                    <h3>Sắp hết</h3>
                    <div class="value"><%= lowCount %></div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon critical <%= criticalCount > 0 ? "pulse" : "" %>">
                    ⚡
                </div>
                <div class="stat-info">
                    <h3>Cần nhập gấp</h3>
                    <div class="value"><%= criticalCount %></div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon ok">
                    📦
                </div>
                <div class="stat-info">
                    <h3>Tổng mặt hàng</h3>
                    <div class="value"><%= displayItems.size() %></div>
                </div>
            </div>
        </div>

        <div class="inventory-table">
            <div class="table-header">
                <h2>Chi tiết tồn kho</h2>
                <button class="refresh-btn" onclick="location.reload()">
                    <span>🔄</span> Làm mới
                </button>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Tên nguyên liệu</th>
                        <th>Danh mục</th>
                        <th>Số lượng</th>
                        <th>Tình trạng</th>
                        <th>Mức độ</th>
                        <th>Trạng thái</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (MonitorDAO.InventoryDisplayItem item : displayItems) { %>
                    <tr>
                        <td><strong><%= item.getVietnameseName() %></strong></td>
                        <td><span class="category-tag"><%= item.getVietnameseCategory() %></span></td>
                        <td><%= String.format("%.1f", item.quantity) %> <%= item.unit %> 
                            <small style="color: #666;">(Ngưỡng: <%= String.format("%.0f", item.lowThreshold) %>)</small></td>
                        <td>
                            <div class="progress-bar">
                                <div class="progress-fill progress-<%= item.getStatus() %>"
                                     style="width: <%= item.getPercentage() %>%"></div>
                            </div>
                        </td>
                        <td><strong><%= item.getPercentage() %>%</strong></td>
                        <td><span class="status-badge status-<%= item.getStatus() %>"><%= item.getStatusText() %></span></td>
                    </tr>
                    <% } %>
                    
                    <% if (displayItems.isEmpty()) { %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: #666;">
                            Không có dữ liệu inventory để hiển thị
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // Auto refresh every 30 seconds
        setTimeout(function() {
            location.reload();
        }, 30000);
        
        // Add some interactivity
        document.querySelectorAll('.stat-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-5px)';
                this.style.boxShadow = '0 15px 35px rgba(0,0,0,0.2)';
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0)';
                this.style.boxShadow = '0 5px 15px rgba(0,0,0,0.1)';
            });
        });
    </script>
</body>
</html>