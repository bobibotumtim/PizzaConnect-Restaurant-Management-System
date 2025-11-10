<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assigned Tables - Waiter</title>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            transition: margin-left 0.3s ease;
        }
        
        .header-section {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .header-title {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
        }
        
        .header-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .table-card {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        
        .table-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        }
        
        .table-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
        }
        
        .table-card.available::before {
            background: linear-gradient(90deg, #10b981, #059669);
        }
        
        .table-card.occupied::before {
            background: linear-gradient(90deg, #f59e0b, #d97706);
        }
        
        .table-card.unavailable::before {
            background: linear-gradient(90deg, #ef4444, #dc2626);
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .table-number {
            font-size: 24px;
            font-weight: bold;
            color: #1f2937;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-badge.available {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-badge.occupied {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-badge.unavailable {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .table-info {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 15px;
        }
        
        .info-row {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #6b7280;
            font-size: 14px;
        }
        
        .info-row i {
            width: 20px;
            color: #9ca3af;
        }
        
        .order-count {
            background: #f3f4f6;
            padding: 10px;
            border-radius: 8px;
            margin-top: 10px;
            text-align: center;
            font-weight: 600;
            color: #374151;
        }
        
        .filter-section {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        
        .filter-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .filter-btn {
            padding: 10px 20px;
            border: 2px solid #e5e7eb;
            background: white;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            font-weight: 500;
        }
        
        .filter-btn:hover {
            border-color: #667eea;
            color: #667eea;
        }
        
        .filter-btn.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: transparent;
        }
        
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            text-align: center;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6b7280;
            font-size: 14px;
        }
        
        /* Modal Styles */
        .modal-content {
            border-radius: 15px;
            border: none;
        }
        
        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0;
        }
        
        .order-item {
            background: #f9fafb;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 10px;
        }
        
        .order-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .order-id {
            font-weight: bold;
            color: #1f2937;
        }
        
        .order-price {
            font-size: 18px;
            font-weight: bold;
            color: #667eea;
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="Sidebar.jsp" />
    
    <div class="main-content">
        <!-- Header -->
        <div class="header-section">
            <div class="header-title">
                <div class="header-icon">
                    <i data-lucide="layout-grid" style="width: 28px; height: 28px;"></i>
                </div>
                <div>
                    <h1 style="margin: 0; font-size: 28px; font-weight: bold; color: #1f2937;">Assigned Tables</h1>
                    <p style="margin: 0; color: #6b7280;">Manage and monitor your assigned tables</p>
                </div>
            </div>
        </div>
        
        <!-- Statistics -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-number" style="color: #10b981;" id="availableCount">0</div>
                <div class="stat-label">Available Tables</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" style="color: #f59e0b;" id="occupiedCount">0</div>
                <div class="stat-label">Occupied Tables</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" style="color: #667eea;" id="totalTables">0</div>
                <div class="stat-label">Total Tables</div>
            </div>
        </div>
        
        <!-- Filter Section -->
        <div class="filter-section">
            <div class="filter-buttons">
                <button class="filter-btn active" data-filter="all">
                    <i class="fas fa-th"></i> All Tables
                </button>
                <button class="filter-btn" data-filter="available">
                    <i class="fas fa-check-circle"></i> Available
                </button>
                <button class="filter-btn" data-filter="occupied">
                    <i class="fas fa-utensils"></i> Occupied
                </button>
                <button class="filter-btn" data-filter="unavailable">
                    <i class="fas fa-times-circle"></i> Unavailable
                </button>
            </div>
        </div>
        
        <!-- Tables Grid -->
        <div class="tables-grid" id="tablesGrid">
            <c:forEach var="table" items="${tables}">
                <div class="table-card ${table.status}" data-status="${table.status}" data-table-id="${table.tableID}">
                    <div class="table-header">
                        <div class="table-number">
                            <i class="fas fa-chair"></i> ${table.tableNumber}
                        </div>
                        <span class="status-badge ${table.status}">
                            <c:choose>
                                <c:when test="${table.status == 'available'}">Available</c:when>
                                <c:when test="${table.status == 'occupied'}">Occupied</c:when>
                                <c:otherwise>Unavailable</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    
                    <div class="table-info">
                        <div class="info-row">
                            <i class="fas fa-users"></i>
                            <span>Capacity: ${table.capacity} people</span>
                        </div>
                        
                        <c:if test="${table.status == 'occupied'}">
                            <div class="info-row">
                                <i class="fas fa-clock"></i>
                                <span>Has active orders</span>
                            </div>
                        </c:if>
                    </div>
                    
                    <c:if test="${table.status == 'occupied'}">
                        <div class="order-count">
                            <i class="fas fa-receipt"></i> View Order Details
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <!-- Order Details Modal -->
    <div class="modal fade" id="orderModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-receipt"></i> Order Details - <span id="modalTableNumber"></span>
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="orderModalBody">
                    <div class="text-center">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Initialize Lucide icons
        lucide.createIcons();
        
        // Update statistics
        function updateStats() {
            const cards = document.querySelectorAll('.table-card');
            let available = 0, occupied = 0, total = cards.length;
            
            cards.forEach(card => {
                const status = card.dataset.status;
                if (status === 'available') available++;
                else if (status === 'occupied') occupied++;
            });
            
            document.getElementById('availableCount').textContent = available;
            document.getElementById('occupiedCount').textContent = occupied;
            document.getElementById('totalTables').textContent = total;
        }
        
        // Filter functionality
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                // Update active button
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                
                const filter = this.dataset.filter;
                const cards = document.querySelectorAll('.table-card');
                
                cards.forEach(card => {
                    if (filter === 'all' || card.dataset.status === filter) {
                        card.style.display = 'block';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        });
        
        // Table card click handler
        document.querySelectorAll('.table-card').forEach(card => {
            card.addEventListener('click', function() {
                const status = this.dataset.status;
                const tableId = this.dataset.tableId;
                const tableNumber = this.querySelector('.table-number').textContent.trim();
                
                if (status === 'occupied') {
                    // Show modal with orders
                    document.getElementById('modalTableNumber').textContent = tableNumber;
                    const modal = new bootstrap.Modal(document.getElementById('orderModal'));
                    modal.show();
                    
                    // Load orders via AJAX
                    loadTableOrders(tableId);
                } else if (status === 'available') {
                    // Redirect to POS to create new order
                    if (confirm('This table is available. Do you want to create a new order?')) {
                        window.location.href = 'pos?tableId=' + tableId;
                    }
                }
            });
        });
        
        // Load table orders via AJAX
        function loadTableOrders(tableId) {
            const modalBody = document.getElementById('orderModalBody');
            modalBody.innerHTML = '<div class="text-center"><div class="spinner-border text-primary"></div></div>';
            
            fetch('assign-table', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=getTableOrders&tableId=' + tableId
            })
            .then(response => response.json())
            .then(data => {
                if (data.orders && data.orders.length > 0) {
                    let html = '';
                    data.orders.forEach(order => {
                        html += '<div class="order-item">';
                        html += '<div class="order-item-header">';
                        html += '<div>';
                        html += '<span class="order-id">Order #' + order.orderId + '</span>';
                        html += '<span class="badge bg-' + getStatusColor(order.status) + ' ms-2">' + order.statusText + '</span>';
                        html += '</div>';
                        html += '<div class="order-price">' + formatPrice(order.totalPrice) + '</div>';
                        html += '</div>';
                        html += '<div class="info-row">';
                        html += '<i class="fas fa-user"></i>';
                        html += '<span>' + (order.customerName || 'Customer') + '</span>';
                        html += '</div>';
                        html += '<div class="info-row">';
                        html += '<i class="fas fa-credit-card"></i>';
                        html += '<span>Payment: ' + order.paymentStatus + '</span>';
                        html += '</div>';
                        if (order.note) {
                            html += '<div class="info-row">';
                            html += '<i class="fas fa-sticky-note"></i>';
                            html += '<span>' + order.note + '</span>';
                            html += '</div>';
                        }
                        html += '<div class="mt-2">';
                        html += '<a href="manage-orders?orderId=' + order.orderId + '" class="btn btn-sm btn-primary">';
                        html += '<i class="fas fa-eye"></i> View Details';
                        html += '</a>';
                        html += '</div>';
                        html += '</div>';
                    });
                    modalBody.innerHTML = html;
                } else {
                    modalBody.innerHTML = '<div class="alert alert-info">No orders found for this table.</div>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                modalBody.innerHTML = '<div class="alert alert-danger">Error loading order data.</div>';
            });
        }
        
        function getStatusColor(status) {
            switch(status) {
                case 0: return 'warning';
                case 1: return 'info';
                case 2: return 'primary';
                case 3: return 'success';
                case 4: return 'secondary';
                default: return 'secondary';
            }
        }
        
        function formatPrice(price) {
            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
        }
        
        // Auto refresh every 30 seconds
        setInterval(() => {
            location.reload();
        }, 30000);
        
        // Initialize stats on load
        updateStats();
    </script>
</body>
</html>
