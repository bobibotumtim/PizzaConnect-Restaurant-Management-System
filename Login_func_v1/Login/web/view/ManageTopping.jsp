<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Toppings - PizzaConnect</title>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #f3f4f6;
        }
        
        .main-content {
            margin-left: 80px;
            margin-top: 60px;
            padding: 24px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        
        .header h1 {
            font-size: 28px;
            color: #111827;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background: #f97316;
            color: white;
        }
        
        .btn-primary:hover {
            background: #ea580c;
        }
        
        .btn-success {
            background: #10b981;
            color: white;
        }
        
        .btn-danger {
            background: #ef4444;
            color: white;
        }
        
        .btn-warning {
            background: #f59e0b;
            color: white;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: #f9fafb;
        }
        
        th {
            padding: 12px 16px;
            text-align: left;
            font-size: 12px;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        td {
            padding: 16px;
            border-top: 1px solid #e5e7eb;
        }
        
        tbody tr:hover {
            background: #f9fafb;
        }
        
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .badge-success {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-danger {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }
        
        .modal.active {
            display: flex;
        }
        
        .modal-content {
            background: white;
            border-radius: 8px;
            padding: 24px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .modal-header h2 {
            font-size: 20px;
            color: #111827;
        }
        
        .close-btn {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #6b7280;
        }
        
        .form-group {
            margin-bottom: 16px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-size: 14px;
            font-weight: 500;
            color: #374151;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #f97316;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .price-display {
            font-weight: 600;
            color: #059669;
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="Sidebar.jsp" />
    
    <!-- Include Navbar -->
    <jsp:include page="NavBar.jsp" />
    
    <div class="main-content">
        <div class="header">
            <h1>🍕 Manage Toppings</h1>
            <button class="btn btn-primary" onclick="openAddModal()">
                <i data-lucide="plus"></i>
                Add New Topping
            </button>
        </div>
        
        <div class="card">
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Topping Name</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="topping" items="${toppings}">
                            <tr>
                                <td>${topping.toppingID}</td>
                                <td>${topping.toppingName}</td>
                                <td class="price-display">
                                    <fmt:formatNumber value="${topping.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${topping.available}">
                                            <span class="badge badge-success">Available</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-danger">Unavailable</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn btn-warning btn-sm" 
                                                onclick="openEditModal(${topping.toppingID}, '${topping.toppingName}', ${topping.price}, ${topping.available})">
                                            <i data-lucide="edit"></i>
                                        </button>
                                        <a href="manage-topping?action=toggle&id=${topping.toppingID}" 
                                           class="btn btn-success btn-sm">
                                            <i data-lucide="toggle-left"></i>
                                        </a>
                                        <a href="manage-topping?action=delete&id=${topping.toppingID}" 
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Delete this topping?')">
                                            <i data-lucide="trash-2"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <!-- Add Topping Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add New Topping</h2>
                <button class="close-btn" onclick="closeAddModal()">&times;</button>
            </div>
            <form method="post" action="manage-topping">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label>Topping Name</label>
                    <input type="text" name="toppingName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Price (₫)</label>
                    <input type="number" name="price" class="form-control" step="1000" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    Add Topping
                </button>
            </form>
        </div>
    </div>
    
    <!-- Edit Topping Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Topping</h2>
                <button class="close-btn" onclick="closeEditModal()">&times;</button>
            </div>
            <form method="post" action="manage-topping">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="toppingID" id="editToppingID">
                <div class="form-group">
                    <label>Topping Name</label>
                    <input type="text" name="toppingName" id="editToppingName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Price (₫)</label>
                    <input type="number" name="price" id="editPrice" class="form-control" step="1000" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="isAvailable" id="editIsAvailable" class="form-control">
                        <option value="1">Available</option>
                        <option value="0">Unavailable</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    Update Topping
                </button>
            </form>
        </div>
    </div>
    
    <script>
        // Initialize Lucide icons
        lucide.createIcons();
        
        // Add Modal
        function openAddModal() {
            document.getElementById('addModal').classList.add('active');
        }
        
        function closeAddModal() {
            document.getElementById('addModal').classList.remove('active');
        }
        
        // Edit Modal
        function openEditModal(id, name, price, isAvailable) {
            document.getElementById('editToppingID').value = id;
            document.getElementById('editToppingName').value = name;
            document.getElementById('editPrice').value = price;
            document.getElementById('editIsAvailable').value = isAvailable ? '1' : '0';
            document.getElementById('editModal').classList.add('active');
        }
        
        function closeEditModal() {
            document.getElementById('editModal').classList.remove('active');
        }
        
        // Close modal on outside click
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.classList.remove('active');
            }
        }
    </script>
</body>
</html>
