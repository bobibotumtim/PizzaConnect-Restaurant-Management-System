<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pizza Order Manager - Quản lý đơn hàng pizza</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary-color: #FF5722;
            --success-color: #10B981;
            --warning-color: #FF9800;
            --bg-color: #F5F5F5;
        }
        
        body {
            background-color: var(--bg-color);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
        }
        
        .header-section {
            background: white;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .logo-box {
            width: 48px;
            height: 48px;
            background-color: var(--primary-color);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .logo-box i {
            color: white;
            font-size: 24px;
        }
        
        .stats-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 1rem;
        }
        
        .stats-label {
            color: #666;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
        }
        
        .stats-value {
            font-size: 2rem;
            font-weight: bold;
        }
        
        .stats-value.primary {
            color: var(--primary-color);
        }
        
        .stats-value.success {
            color: var(--success-color);
        }
        
        .table-card {
            background: white;
            padding: 0;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .table thead th {
            background-color: #FAFAFA;
            color: #666;
            font-weight: 600;
            font-size: 0.875rem;
            border-bottom: 2px solid #E0E0E0;
            padding: 1rem;
        }
        
        .table tbody td {
            padding: 1rem;
            vertical-align: middle;
        }
        
        .badge-pending {
            background-color: var(--warning-color);
            color: #000;
            padding: 0.375rem 0.75rem;
            border-radius: 16px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .badge-completed {
            background-color: var(--success-color);
            color: white;
            padding: 0.375rem 0.75rem;
            border-radius: 16px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .badge-preparing {
            background-color: #3B82F6;
            color: white;
            padding: 0.375rem 0.75rem;
            border-radius: 16px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .badge-cancelled {
            background-color: #EF4444;
            color: white;
            padding: 0.375rem 0.75rem;
            border-radius: 16px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background-color: #E64A19;
            border-color: #E64A19;
        }
        
        .action-btn {
            padding: 0.25rem 0.5rem;
            border: none;
            background: none;
            cursor: pointer;
            color: #666;
            font-size: 1rem;
        }
        
        .action-btn:hover {
            color: var(--primary-color);
        }
        
        .action-btn.delete:hover {
            color: #EF4444;
        }
        
        .modal-header {
            background-color: #FAFAFA;
        }
        
        .form-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 0.5rem;
        }
        
        .form-select:focus,
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(255, 87, 34, 0.25);
        }
    </style>
</head>
<body>
    <div class="container py-4" style="max-width: 1400px;">
        <!-- Header -->
        <div class="header-section">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center gap-3">
                    <div class="logo-box">
                        <i class="fas fa-pizza-slice"></i>
                    </div>
                    <div>
                        <h1 class="h4 mb-0">Pizza Order Manager</h1>
                        <p class="text-muted mb-0 small">Quản lý đơn hàng pizza</p>
                    </div>
                </div>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addOrderModal">
                    <i class="fas fa-plus"></i> Thêm đơn hàng
                </button>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="stats-card">
                    <div class="stats-label">Tổng đơn hàng</div>
                    <div class="stats-value" id="totalOrders">2</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stats-card">
                    <div class="stats-label">Đơn hoàn thành</div>
                    <div class="stats-value success" id="completedOrders">1</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stats-card">
                    <div class="stats-label">Doanh thu</div>
                    <div class="stats-value primary" id="revenue">250.000đ</div>
                </div>
            </div>
        </div>

        <!-- Orders Table -->
        <div class="table-card">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Khách hàng</th>
                            <th>Loại pizza</th>
                            <th class="text-center">Số lượng</th>
                            <th class="text-end">Giá (VNĐ)</th>
                            <th class="text-end">Tổng tiền</th>
                            <th class="text-center">Trạng thái</th>
                            <th class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody id="ordersTableBody">
                        <!-- Orders will be inserted here by JavaScript -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add Order Modal -->
    <div class="modal fade" id="addOrderModal" tabindex="-1" aria-labelledby="addOrderModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addOrderModalLabel">Thêm đơn hàng mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="orderForm">
                        <div class="mb-3">
                            <label for="customerName" class="form-label">Tên khách hàng</label>
                            <input type="text" class="form-control" id="customerName" placeholder="Nhập tên khách hàng" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="pizzaType" class="form-label">Loại pizza</label>
                            <select class="form-select" id="pizzaType" required>
                                <option value="">Chọn loại pizza</option>
                                <option value="Pepperoni" data-price="200000">Pepperoni</option>
                                <option value="Hawaiian" data-price="250000">Hawaiian</option>
                                <option value="Margherita" data-price="180000">Margherita</option>
                                <option value="Veggie" data-price="170000">Veggie</option>
                                <option value="BBQ Chicken" data-price="220000">BBQ Chicken</option>
                                <option value="Seafood" data-price="280000">Seafood</option>
                                <option value="Four Cheese" data-price="240000">Four Cheese</option>
                            </select>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="quantity" class="form-label">Số lượng</label>
                                <input type="number" class="form-control" id="quantity" value="1" min="1" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="price" class="form-label">Giá (VNĐ)</label>
                                <input type="number" class="form-control" id="price" value="0" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="status" class="form-label">Trạng thái</label>
                            <select class="form-select" id="status" required>
                                <option value="pending">Chờ xử lý</option>
                                <option value="preparing">Đang chuẩn bị</option>
                                <option value="completed">Hoàn thành</option>
                                <option value="cancelled">Đã hủy</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="addOrder()">Thêm</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Mock data - Trong JSP thật bạn sẽ lấy từ Servlet
        let orders = [
            {
                id: 1,
                customerName: "Nguyễn Văn A",
                pizzaType: "Pepperoni",
                quantity: 2,
                price: 200000,
                total: 400000,
                status: "pending"
            },
            {
                id: 2,
                customerName: "Trần Thị B",
                pizzaType: "Hawaiian",
                quantity: 1,
                price: 250000,
                total: 250000,
                status: "completed"
            }
        ];

        // Format currency
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount);
        }

        // Get status badge HTML
        function getStatusBadge(status) {
            const statusMap = {
                pending: { label: 'Chờ xử lý', class: 'badge-pending' },
                preparing: { label: 'Đang chuẩn bị', class: 'badge-preparing' },
                completed: { label: 'Hoàn thành', class: 'badge-completed' },
                cancelled: { label: 'Đã hủy', class: 'badge-cancelled' }
            };
            const statusInfo = statusMap[status] || statusMap.pending;
            return `<span class="${statusInfo.class}">${statusInfo.label}</span>`;
        }

        // Render orders table
        function renderOrders() {
            const tbody = document.getElementById('ordersTableBody');
            tbody.innerHTML = orders.map(order => `
                <tr>
                    <td><strong>#${order.id}</strong></td>
                    <td>${order.customerName}</td>
                    <td>${order.pizzaType}</td>
                    <td class="text-center">${order.quantity}</td>
                    <td class="text-end">${formatCurrency(order.price)}</td>
                    <td class="text-end"><strong>${formatCurrency(order.total)}</strong></td>
                    <td class="text-center">${getStatusBadge(order.status)}</td>
                    <td class="text-center">
                        <button class="action-btn" onclick="editOrder(${order.id})" title="Sửa">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="action-btn delete" onclick="deleteOrder(${order.id})" title="Xóa">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `).join('');
            
            updateStats();
        }

        // Update statistics
        function updateStats() {
            const totalOrders = orders.length;
            const completedOrders = orders.filter(o => o.status === 'completed').length;
            const revenue = orders.filter(o => o.status === 'completed').reduce((sum, o) => sum + o.total, 0);
            
            document.getElementById('totalOrders').textContent = totalOrders;
            document.getElementById('completedOrders').textContent = completedOrders;
            document.getElementById('revenue').textContent = formatCurrency(revenue) + 'đ';
        }

        // Auto-update price when pizza type changes
        document.getElementById('pizzaType').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const price = selectedOption.getAttribute('data-price') || 0;
            document.getElementById('price').value = price;
        });

        // Add new order
        function addOrder() {
            const customerName = document.getElementById('customerName').value;
            const pizzaType = document.getElementById('pizzaType').value;
            const quantity = parseInt(document.getElementById('quantity').value);
            const price = parseInt(document.getElementById('price').value);
            const status = document.getElementById('status').value;

            if (!customerName || !pizzaType) {
                alert('Vui lòng điền đầy đủ thông tin!');
                return;
            }

            const newOrder = {
                id: orders.length + 1,
                customerName,
                pizzaType,
                quantity,
                price,
                total: price * quantity,
                status
            };

            orders.push(newOrder);
            renderOrders();

            // Reset form and close modal
            document.getElementById('orderForm').reset();
            bootstrap.Modal.getInstance(document.getElementById('addOrderModal')).hide();

            // Trong JSP thật, bạn sẽ gọi: 
            // window.location.href = 'addOrder?name=' + customerName + '&type=' + pizzaType + ...
            // Hoặc dùng AJAX để gọi Servlet
        }

        // Delete order
        function deleteOrder(id) {
            if (confirm('Bạn có chắc muốn xóa đơn hàng này?')) {
                orders = orders.filter(o => o.id !== id);
                renderOrders();
                
                // Trong JSP thật: window.location.href = 'deleteOrder?id=' + id;
            }
        }

        // Edit order (placeholder)
        function editOrder(id) {
            alert('Chức năng sửa đơn hàng - ID: ' + id);
            // Bạn có thể tạo modal edit tương tự modal add
        }

        // Initial render
        renderOrders();
    </script>
</body>
</html>
