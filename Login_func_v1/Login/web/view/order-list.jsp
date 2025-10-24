<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, models.Order" %>
<html>
<head>
    <title>Pizza Order Manager</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #f5f5f5; 
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-top: 20px;
        }
        
        .header {
            background: white;
            padding: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .header-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .logo {
            width: 60px;
            height: 60px;
            background: #ff6b6b;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            color: white;
        }
        
        .title-section h1 {
            font-size: 2em;
            margin: 0;
            color: #333;
        }
        
        .title-section p {
            margin: 5px 0 0 0;
            color: #666;
            font-size: 1em;
        }
        
        .btn-add-order {
            background: #ff6b6b;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: background 0.3s;
            border: none;
            cursor: pointer;
        }
        
        .btn-add-order:hover {
            background: #ff5252;
        }
        
        .btn-add-order span {
            font-size: 1.2em;
        }
        
        .stats-container {
            display: flex;
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        
        .stat-card {
            background: white;
            padding: 24px;
            border-radius: 12px;
            flex: 1;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .stat-card.completed .stat-value {
            color: #4caf50;
        }
        
        .stat-card.revenue .stat-value {
            color: #ff6b6b;
        }
        
        .stat-label {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 8px;
        }
        
        .stat-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #333;
        }
        
        .table-container {
            padding: 30px;
        }
        
        table { 
            width:100%; 
            border-collapse:collapse; 
            background:white; 
            border-radius:8px; 
            overflow:hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        th, td { 
            padding:15px; 
            text-align:left; 
            border-bottom:1px solid #ecf0f1; 
        }
        
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-pending {
            background: #f39c12;
            color: white;
        }
        
        .status-processing {
            background: #3498db;
            color: white;
        }
        
        .status-completed {
            background: #27ae60;
            color: white;
        }
        
        .status-cancelled {
            background: #e74c3c;
            color: white;
        }
        
        .actions {
            display: flex;
            gap: 8px;
            justify-content: center;
        }
        
        .actions .btn {
            padding: 8px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 16px;
            transition: all 0.3s;
        }
        
        .actions .btn:hover {
            transform: scale(1.1);
        }
        
        .btn-info {
            background: #3498db;
            color: white;
        }
        
        .btn-danger {
            background: #e74c3c;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 50px;
            color: #7f8c8d;
        }
        
        .empty-state i {
            font-size: 4em;
            margin-bottom: 20px;
            display: block;
        }
        
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            animation: fadeIn 0.3s ease;
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 0;
            border-radius: 15px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            animation: slideIn 0.3s ease;
        }
        
        .modal-header {
            background: linear-gradient(135deg, #ff6b6b, #ff8e8e);
            color: white;
            padding: 25px 30px;
            border-radius: 15px 15px 0 0;
            text-align: center;
        }
        
        .modal-header h2 {
            margin: 0;
            font-size: 1.5em;
            font-weight: 600;
        }
        
        .modal-header p {
            margin: 8px 0 0 0;
            opacity: 0.9;
            font-size: 0.9em;
        }
        
        .modal-body {
            padding: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 0.9em;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s, box-shadow 0.3s;
            background: white;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #ff6b6b;
            box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.1);
        }
        
        .form-group input[type="number"] {
            text-align: right;
        }
        
        .modal-footer {
            padding: 20px 30px 30px;
            display: flex;
            gap: 15px;
            justify-content: flex-end;
        }
        
        .btn-modal {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            min-width: 100px;
        }
        
        .btn-cancel {
            background: #6c757d;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #5a6268;
        }
        
        .btn-add {
            background: #ff6b6b;
            color: white;
        }
        
        .btn-add:hover {
            background: #ff5252;
            transform: translateY(-1px);
        }
        
        .close {
            position: absolute;
            right: 20px;
            top: 20px;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            opacity: 0.8;
            transition: opacity 0.3s;
        }
        
        .close:hover {
            opacity: 1;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .modal-content {
                width: 95%;
                margin: 10% auto;
            }
            
            .modal-header,
            .modal-body,
            .modal-footer {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <%
        List<Order> orders = (List<Order>) request.getAttribute("orders");
        if (orders == null) orders = new ArrayList<>();
        
        // Tính thống kê
        int totalOrders = orders.size();
        int completedOrders = 0;
        double totalRevenue = 0.0;
        
        for (Order order : orders) {
            if (order.getStatus() == 2) { // Completed
                completedOrders++;
            }
            totalRevenue += order.getTotalPrice();
        }
    %>
    
    <div class="container">
        <!-- Header với logo và nút thêm đơn hàng -->
    <div class="header">
            <div class="header-left">
                <div class="logo">🍕</div>
                <div class="title-section">
                    <h1>Pizza Order Manager</h1>
                    <p>Quản lý đơn hàng pizza</p>
                </div>
            </div>
            <div class="header-right">
                <button onclick="openAddOrderModal()" class="btn-add-order">
                    <span>+</span> Thêm đơn hàng
                </button>
            </div>
        </div>
        
        <!-- Thống kê -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-label">Tổng đơn hàng</div>
                <div class="stat-value"><%= totalOrders %></div>
            </div>
            <div class="stat-card completed">
                <div class="stat-label">Đơn hoàn thành</div>
                <div class="stat-value"><%= completedOrders %></div>
            </div>
            <div class="stat-card revenue">
                <div class="stat-label">Doanh thu</div>
                <div class="stat-value"><%= String.format("%.0f", totalRevenue) %>₫</div>
            </div>
    </div>

        <div class="table-container">
            <% if (orders.isEmpty()) { %>
                <div class="empty-state">
                    <i>📦</i>
                    <h3>Chưa có đơn hàng nào</h3>
                    <p>Hãy thêm đơn hàng đầu tiên!</p>
                </div>
            <% } else { %>
    <table>
                    <thead>
        <tr>
            <th>ID</th>
            <th>Khách hàng</th>
                            <th>Loại pizza</th>
                            <th>Số lượng</th>
                            <th>Giá (VNĐ)</th>
                            <th>Tổng tiền</th>
            <th>Trạng thái</th>
            <th>Thao tác</th>
        </tr>
                    </thead>
                    <tbody>
                        <% for (Order order : orders) { %>
                            <tr>
                                <td><strong>#<%= order.getOrderID() %></strong></td>
                                <td><%= order.getCustomerName() %></td>
                                <td>
                                    <% 
                                        // Lấy thông tin pizza từ OrderDetail
                                        String pizzaInfo = "Pepperoni"; // Default
                                        if (order.getDetails() != null && !order.getDetails().isEmpty()) {
                                            String specialInstructions = order.getDetails().get(0).getSpecialInstructions();
                                            if (specialInstructions != null && specialInstructions.contains("Loại:")) {
                                                pizzaInfo = specialInstructions.replace("Loại: ", "");
                                            }
                                        }
                                    %>
                                    <%= pizzaInfo %>
                                </td>
                                <td>
                                    <% 
                                        int quantity = 2; // Default
                                        if (order.getDetails() != null && !order.getDetails().isEmpty()) {
                                            quantity = order.getDetails().get(0).getQuantity();
                                        }
                                    %>
                                    <%= quantity %>
                                </td>
                                <td>
                                    <% 
                                        double unitPrice = 200000; // Default
                                        if (order.getDetails() != null && !order.getDetails().isEmpty()) {
                                            unitPrice = order.getDetails().get(0).getTotalPrice() / order.getDetails().get(0).getQuantity();
                                        }
                                    %>
                                    <%= String.format("%.0f", unitPrice) %>
                                </td>
                                <td><strong><%= String.format("%.0f", order.getTotalMoney()) %>₫</strong></td>
                                <td>
                                    <% 
                                        String statusClass = "";
                                        switch(order.getStatus()) {
                                            case 0: statusClass = "status-pending"; break;
                                            case 1: statusClass = "status-processing"; break;
                                            case 2: statusClass = "status-completed"; break;
                                            case 3: statusClass = "status-cancelled"; break;
                                        }
                                    %>
                                    <span class="status-badge <%= statusClass %>"><%= order.getStatusText() %></span>
                                </td>
                                <td>
                                    <div class="actions">
                                        <button onclick="openEditOrderModal(<%= order.getOrderID() %>)" class="btn btn-info">Sửa</button>
                                        <a href="OrderController?action=delete&id=<%= order.getOrderID() %>" class="btn btn-danger" onclick="return confirm('Xóa đơn hàng này?')">Xóa</a>
                                    </div>
                                </td>
            </tr>
                        <% } %>
                    </tbody>
    </table>
            <% } %>
        </div>
    </div>
    
    <!-- Modal Thêm Đơn Hàng -->
    <div id="addOrderModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeAddOrderModal()">&times;</span>
                <h2>Thêm đơn hàng mới</h2>
                <p>Điền thông tin để tạo đơn hàng mới</p>
            </div>
            <form id="addOrderForm" onsubmit="submitOrder(event)">
                <div class="modal-body">
                    <div class="form-group">
                        <label for="customerName">Tên khách hàng</label>
                        <input type="text" id="customerName" name="customerName" placeholder="Nhập tên khách hàng" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="pizzaType">Loại pizza</label>
                        <select id="pizzaType" name="pizzaType" required>
                            <option value="">Chọn loại pizza</option>
                            <option value="pepperoni">Pepperoni</option>
                            <option value="hawaiian">Hawaiian</option>
                            <option value="margherita">Margherita</option>
                            <option value="meat-lovers">Meat Lovers</option>
                            <option value="vegetarian">Vegetarian</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="quantity">Số lượng</label>
                        <input type="number" id="quantity" name="quantity" value="1" min="1" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="price">Giá (VNĐ)</label>
                        <input type="number" id="price" name="price" value="200000" min="0" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="status">Trạng thái</label>
                        <select id="status" name="status" required>
                            <option value="0">Chờ xử lý</option>
                            <option value="1">Đang xử lý</option>
                            <option value="2">Hoàn thành</option>
                            <option value="3">Hủy</option>
                        </select>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn-modal btn-cancel" onclick="closeAddOrderModal()">Hủy</button>
                    <button type="submit" class="btn-modal btn-add">Thêm</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal Chỉnh Sửa Đơn Hàng -->
    <div id="editOrderModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeEditOrderModal()">&times;</span>
                <h2>Chỉnh sửa đơn hàng</h2>
                <p>Cập nhật thông tin đơn hàng</p>
            </div>
            <form id="editOrderForm" onsubmit="submitEditOrder(event)">
                <div class="modal-body">
                    <input type="hidden" id="editOrderID" name="orderID">
                    
                    <div class="form-group">
                        <label for="editCustomerID">Customer ID</label>
                        <input type="number" id="editCustomerID" name="customerID" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editEmployeeID">Employee ID</label>
                        <input type="number" id="editEmployeeID" name="employeeID" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editTableID">Table ID</label>
                        <input type="number" id="editTableID" name="tableID" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editOrderDate">Ngày đặt hàng</label>
                        <input type="datetime-local" id="editOrderDate" name="orderDate" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editStatus">Trạng thái</label>
                        <select id="editStatus" name="status" required>
                            <option value="0">Chờ xử lý</option>
                            <option value="1">Đang xử lý</option>
                            <option value="2">Hoàn thành</option>
                            <option value="3">Hủy</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="editPaymentStatus">Trạng thái thanh toán</label>
                        <select id="editPaymentStatus" name="paymentStatus" required>
                            <option value="Unpaid">Chưa thanh toán</option>
                            <option value="Paid">Đã thanh toán</option>
                            <option value="Partial">Thanh toán một phần</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="editTotalPrice">Tổng tiền (VNĐ)</label>
                        <input type="number" id="editTotalPrice" name="totalPrice" readonly style="background-color: #f5f5f5;">
                        <small style="color: #666;">Giá tiền được tính tự động từ chi tiết đơn hàng</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editNote">Ghi chú</label>
                        <textarea id="editNote" name="note" rows="3" placeholder="Nhập ghi chú cho đơn hàng"></textarea>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn-modal btn-cancel" onclick="closeEditOrderModal()">Hủy</button>
                    <button type="submit" class="btn-modal btn-add">Cập nhật</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function openAddOrderModal() {
            document.getElementById('addOrderModal').style.display = 'block';
            document.getElementById('customerName').focus();
        }
        
        function closeAddOrderModal() {
            document.getElementById('addOrderModal').style.display = 'none';
            document.getElementById('addOrderForm').reset();
            document.getElementById('quantity').value = '1';
            document.getElementById('price').value = '200000';
        }
        
        function submitOrder(event) {
            event.preventDefault();
            
            const formData = new FormData(event.target);
            const orderData = {
                customerName: formData.get('customerName'),
                pizzaType: formData.get('pizzaType'),
                quantity: parseInt(formData.get('quantity')),
                price: parseFloat(formData.get('price')),
                status: parseInt(formData.get('status'))
            };
            
            // Tính tổng tiền
            const totalPrice = orderData.quantity * orderData.price;
            
            // Gửi request đến servlet
            fetch('OrderController', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    action: 'add',
                    customerName: orderData.customerName,
                    pizzaType: orderData.pizzaType,
                    quantity: orderData.quantity,
                    price: orderData.price,
                    totalPrice: totalPrice,
                    status: orderData.status
                })
            })
            .then(response => {
                if (response.ok) {
                    closeAddOrderModal();
                    // Reload trang để cập nhật dữ liệu
                    window.location.reload();
                } else {
                    alert('Có lỗi xảy ra khi thêm đơn hàng');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi thêm đơn hàng');
            });
        }
        
        // Đóng modal khi click bên ngoài
        window.onclick = function(event) {
            const modal = document.getElementById('addOrderModal');
            if (event.target == modal) {
                closeAddOrderModal();
            }
        }
        
        // Đóng modal bằng phím ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeAddOrderModal();
                closeEditOrderModal();
            }
        });
        
        // ===== EDIT ORDER MODAL FUNCTIONS =====
        function openEditOrderModal(orderId) {
            // Lấy thông tin đơn hàng từ server
            fetch('OrderController?action=getOrder&id=' + orderId)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const order = data.order;
                        
                        // Điền dữ liệu vào form
                        document.getElementById('editOrderID').value = order.orderID;
                        document.getElementById('editCustomerID').value = order.customerID;
                        document.getElementById('editEmployeeID').value = order.employeeID;
                        document.getElementById('editTableID').value = order.tableID;
                        
                        // Format datetime cho input datetime-local
                        const orderDate = new Date(order.orderDate);
                        const formattedDate = orderDate.toISOString().slice(0, 16);
                        document.getElementById('editOrderDate').value = formattedDate;
                        
                        document.getElementById('editStatus').value = order.status;
                        document.getElementById('editPaymentStatus').value = order.paymentStatus;
                        document.getElementById('editTotalPrice').value = order.totalPrice;
                        document.getElementById('editNote').value = order.note || '';
                        
                        // Hiển thị modal
                        document.getElementById('editOrderModal').style.display = 'block';
                    } else {
                        alert('Không thể tải thông tin đơn hàng');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi tải thông tin đơn hàng');
                });
        }
        
        function closeEditOrderModal() {
            document.getElementById('editOrderModal').style.display = 'none';
            document.getElementById('editOrderForm').reset();
        }
        
        function submitEditOrder(event) {
            event.preventDefault();
            
            const formData = new FormData(event.target);
            const orderData = {
                orderID: formData.get('orderID'),
                customerID: parseInt(formData.get('customerID')),
                employeeID: parseInt(formData.get('employeeID')),
                tableID: parseInt(formData.get('tableID')),
                orderDate: formData.get('orderDate'),
                status: parseInt(formData.get('status')),
                paymentStatus: formData.get('paymentStatus'),
                totalPrice: parseFloat(formData.get('totalPrice')),
                note: formData.get('note')
            };
            
            // Gửi request đến servlet
            fetch('OrderController', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    action: 'update',
                    orderID: orderData.orderID,
                    customerID: orderData.customerID,
                    employeeID: orderData.employeeID,
                    tableID: orderData.tableID,
                    orderDate: orderData.orderDate,
                    status: orderData.status,
                    paymentStatus: orderData.paymentStatus,
                    totalPrice: orderData.totalPrice,
                    note: orderData.note
                })
            })
            .then(response => {
                if (response.ok) {
                    closeEditOrderModal();
                    // Reload trang để cập nhật dữ liệu
                    window.location.reload();
                } else {
                    alert('Có lỗi xảy ra khi cập nhật đơn hàng');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi cập nhật đơn hàng');
            });
        }
        
        // Đóng modal khi click bên ngoài
        window.onclick = function(event) {
            const addModal = document.getElementById('addOrderModal');
            const editModal = document.getElementById('editOrderModal');
            if (event.target == addModal) {
                closeAddOrderModal();
            } else if (event.target == editModal) {
                closeEditOrderModal();
            }
        }
    </script>
</body>
</html>
