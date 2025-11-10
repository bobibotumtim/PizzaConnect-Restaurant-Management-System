<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table Management - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        
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
        .table-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .table-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Include Sidebar -->
    <jsp:include page="Sidebar.jsp" />
    
    <div class="content-wrapper">
        <div class="max-w-7xl mx-auto px-6 py-8">
            
            <!-- Header -->
            <div class="mb-8">
                <div class="flex items-center gap-4 mb-4">
                    <div class="w-14 h-14 bg-gradient-to-br from-orange-400 to-orange-600 rounded-xl flex items-center justify-center">
                        <i data-lucide="layout-grid" class="w-8 h-8 text-white"></i>
                    </div>
                    <div>
                        <h1 class="text-4xl font-bold text-gray-800">Table Management</h1>
                        <p class="text-gray-600">Manage and monitor your assigned tables</p>
                    </div>
                </div>
            </div>
        
            <!-- Statistics -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-white rounded-xl shadow-md p-6 text-center">
                    <div class="text-4xl font-bold text-green-600" id="availableCount">0</div>
                    <div class="text-gray-600 text-sm mt-2">Available Tables</div>
                </div>
                <div class="bg-white rounded-xl shadow-md p-6 text-center">
                    <div class="text-4xl font-bold text-orange-600" id="occupiedCount">0</div>
                    <div class="text-gray-600 text-sm mt-2">Occupied Tables</div>
                </div>
                <div class="bg-white rounded-xl shadow-md p-6 text-center">
                    <div class="text-4xl font-bold text-orange-500" id="totalTables">0</div>
                    <div class="text-gray-600 text-sm mt-2">Total Tables</div>
                </div>
            </div>
            
            <!-- Filter Section -->
            <div class="bg-white rounded-xl shadow-md p-6 mb-8">
                <h3 class="text-lg font-semibold text-gray-800 mb-4">Filter by Status</h3>
                <div class="flex flex-wrap gap-3">
                    <button class="filter-btn px-6 py-2 rounded-lg font-medium transition-all bg-orange-500 text-white" data-filter="all">
                        <i class="fas fa-th"></i> All Tables
                    </button>
                    <button class="filter-btn px-6 py-2 rounded-lg font-medium transition-all bg-gray-100 text-gray-700 hover:bg-gray-200" data-filter="available">
                        <i class="fas fa-check-circle"></i> Available
                    </button>
                    <button class="filter-btn px-6 py-2 rounded-lg font-medium transition-all bg-gray-100 text-gray-700 hover:bg-gray-200" data-filter="occupied">
                        <i class="fas fa-utensils"></i> Occupied
                    </button>
                    <button class="filter-btn px-6 py-2 rounded-lg font-medium transition-all bg-gray-100 text-gray-700 hover:bg-gray-200" data-filter="unavailable">
                        <i class="fas fa-times-circle"></i> Unavailable
                    </button>
                </div>
            </div>
        
            <!-- Tables Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6" id="tablesGrid">
                <c:forEach var="table" items="${tables}">
                    <div class="table-card bg-white rounded-xl shadow-md overflow-hidden cursor-pointer border-t-4 ${table.status == 'available' ? 'border-green-500' : table.status == 'occupied' ? 'border-orange-500' : 'border-red-500'}" 
                         data-status="${table.status}" data-table-id="${table.tableID}" data-table-number="${table.tableNumber}">
                        <div class="p-6">
                            <div class="flex justify-between items-center mb-4">
                                <div class="table-number text-2xl font-bold text-gray-800">
                                    <i class="fas fa-chair text-orange-500"></i> ${table.tableNumber}
                                </div>
                                <c:choose>
                                    <c:when test="${table.status == 'available'}">
                                        <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold uppercase">Available</span>
                                    </c:when>
                                    <c:when test="${table.status == 'occupied'}">
                                        <span class="px-3 py-1 bg-orange-100 text-orange-700 rounded-full text-xs font-semibold uppercase">Occupied</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-xs font-semibold uppercase">Unavailable</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            
                            <div class="space-y-2">
                                <div class="flex items-center gap-2 text-gray-600 text-sm">
                                    <i class="fas fa-users w-5"></i>
                                    <span>Capacity: ${table.capacity} people</span>
                                </div>
                                
                                <c:if test="${table.status == 'occupied'}">
                                    <div class="flex items-center gap-2 text-gray-600 text-sm">
                                        <i class="fas fa-clock w-5"></i>
                                        <span>Has active orders</span>
                                    </div>
                                </c:if>
                            </div>
                            
                            <c:if test="${table.status == 'occupied'}">
                                <div class="mt-4 bg-orange-50 text-orange-700 p-3 rounded-lg text-center font-semibold text-sm">
                                    <i class="fas fa-receipt"></i> View Order Details
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
    
    <!-- Order Details Modal -->
    <div class="modal fade" id="orderModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content rounded-xl overflow-hidden">
                <div class="modal-header bg-gradient-to-r from-orange-400 to-orange-600 text-white border-0">
                    <h5 class="modal-title font-bold">
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
                document.querySelectorAll('.filter-btn').forEach(b => {
                    b.classList.remove('bg-orange-500', 'text-white');
                    b.classList.add('bg-gray-100', 'text-gray-700');
                });
                this.classList.remove('bg-gray-100', 'text-gray-700');
                this.classList.add('bg-orange-500', 'text-white');
                
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
                const tableNumber = this.dataset.tableNumber;
                
                console.log('Table clicked:', tableNumber, 'Status:', status, 'ID:', tableId);
                
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
