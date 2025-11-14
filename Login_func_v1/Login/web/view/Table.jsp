<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Table Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .header-buttons {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        @media (max-width: 768px) {
            .header-buttons {
                justify-content: flex-start;
                margin-top: 1rem;
            }
            .header-container {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        .table-card {
            transition: all 0.3s ease;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            height: 200px;
            border: 2px solid transparent;
        }

        .table-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }

        .table-card.active {
            border-color: #4f46e5;
        }

        .table-card.inactive {
            border-color: #6b7280;
        }

        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal.active {
            display: flex;
        }

        .table-header {
            background: #4f46e5;
            padding: 16px;
            color: white;
        }

        .capacity-badge {
            background: rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            padding: 4px 8px;
            font-weight: 500;
            font-size: 0.75rem;
        }

        /* Table view for inactive tables */
        .table-list-view {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .table-list-view .table-row {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 1fr;
            gap: 1rem;
            padding: 12px 16px;
            border-bottom: 1px solid #e5e7eb;
            align-items: center;
        }

        .table-list-view .table-row:last-child {
            border-bottom: none;
        }

        .table-list-view .table-row:hover {
            background-color: #f9fafb;
        }

        .table-list-view .table-header-row {
            background-color: #f8fafc;
            font-weight: 600;
            color: #374151;
            border-bottom: 2px solid #e5e7eb;
        }
    </style>
</head>
<body class="flex h-screen bg-gray-50 ml-20">
    <!-- Sidebar Navigation -->
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col overflow-hidden min-w-0 mt-16">
        <!-- Header and filter -->
        <div class="bg-white border-b px-6 py-4 flex-shrink-0">
            <div class="flex flex-col lg:flex-row lg:justify-between lg:items-center gap-4 header-container">
                <div class="flex items-center space-x-4">
                    <h1 class="text-2xl font-bold text-gray-800">Table Management</h1>
                    <select id="filterSelect" onchange="changeFilter(this)" 
                            class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 bg-white">
                        <option value="active" ${param.filter != 'inactive' ? 'selected' : ''}>Active Tables</option>
                        <option value="inactive" ${param.filter == 'inactive' ? 'selected' : ''}>Inactive Tables</option>
                    </select>
                </div>
                <div class="header-buttons">
                    <!-- Add New Table -->
                    <button onclick="openAddModal()" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg transition-colors flex items-center">
                        <i data-lucide="plus" class="w-4 h-4 mr-2"></i>
                        Add New Table
                    </button>
                </div>
            </div>
        </div>

        <!-- Content -->
        <div class="flex-1 p-6 overflow-auto">
            <!-- Success Message -->
            <c:if test="${not empty message}">
                <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                        <span>${message}</span>
                    </div>
                </div>
                <%
                    session.removeAttribute("message");
                %>
            </c:if>

            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                        <span>${error}</span>
                    </div>
                </div>
                <%
                    session.removeAttribute("error");
                %>
            </c:if>

            <!-- Tables Display -->
            <c:choose>
                <c:when test="${param.filter == 'inactive' && not empty tables}">
                    <!-- Table List View for Inactive Tables -->
                    <div class="table-list-view">
                        <div class="table-row table-header-row">
                            <div>Table Number</div>
                            <div>Capacity</div>
                            <div>Status</div>
                            <div>Actions</div>
                        </div>
                        <c:forEach var="table" items="${tables}">
                            <div class="table-row">
                                <div class="font-medium text-gray-900">${table.tableNumber}</div>
                                <div class="text-gray-600">${table.capacity} seats</div>
                                <div>
                                    <span class="status-badge bg-gray-100 text-gray-800">
                                        Inactive
                                    </span>
                                </div>
                                <div class="flex space-x-2">
                                    <button onclick="openRestoreModal(${table.tableID}, '${table.tableNumber}', ${table.capacity})" 
                                           class="bg-green-500 hover:bg-green-600 text-white py-1 px-3 rounded-lg text-sm font-medium transition-colors flex items-center">
                                        <i data-lucide="refresh-ccw" class="w-3 h-3 mr-1"></i>
                                        Restore
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                
                <c:when test="${not empty tables}">
                    <!-- Card View for Active Tables -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                        <c:forEach var="table" items="${tables}">
                            <div class="table-card bg-white ${table.active ? 'active' : 'inactive'}">
                                
                                <!-- Table Header -->
                                <div class="table-header">
                                    <div class="flex justify-between items-start">
                                        <h3 class="text-xl font-bold">${table.tableNumber}</h3>
                                        <div class="capacity-badge">
                                            <i data-lucide="users" class="w-3 h-3 inline mr-1"></i>
                                            ${table.capacity}
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Table Info -->
                                <div class="p-4 flex-1 flex flex-col justify-between">
                                    <div class="space-y-3">
                                        <div class="flex justify-between items-center">
                                            <span class="status-badge ${table.active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}">
                                                ${table.active ? 'Active' : 'Inactive'}
                                            </span>
                                        </div>
                                    </div>
                                    
                                    <!-- Actions -->
                                    <div class="flex space-x-2 mt-4 pt-4 border-t border-gray-100">
                                        <button onclick="openEditModal(${table.tableID}, '${table.tableNumber}', ${table.capacity})" 
                                               class="flex-1 bg-blue-500 hover:bg-blue-600 text-white py-2 px-3 rounded-lg text-sm font-medium transition-colors flex items-center justify-center">
                                            <i data-lucide="edit" class="w-4 h-4 mr-1"></i>
                                            Edit
                                        </button>
                                        <button onclick="confirmDelete(${table.tableID}, '${table.tableNumber}')" 
                                               class="flex-1 bg-red-500 hover:bg-red-600 text-white py-2 px-3 rounded-lg text-sm font-medium transition-colors flex items-center justify-center">
                                            <i data-lucide="trash-2" class="w-4 h-4 mr-1"></i>
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <!-- Empty State -->
                    <div class="col-span-full text-center py-16">
                        <div class="rounded-2xl p-12 max-w-md mx-auto">
                            <i data-lucide="rectangle-horizontal" class="w-16 h-16 text-gray-400 mx-auto mb-4"></i>
                            <h3 class="text-xl font-bold text-gray-700 mb-3">
                                <c:choose>
                                    <c:when test="${param.filter == 'active'}">No active tables found</c:when>
                                    <c:when test="${param.filter == 'inactive'}">No inactive tables found</c:when>
                                </c:choose>
                            </h3>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Add Table Modal -->
    <div id="addModal" class="modal">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Add New Table</h2>
            </div>
            <form action="${pageContext.request.contextPath}/table" method="post" onsubmit="return validateAddForm()">
                <input type="hidden" name="action" value="insert">
                <input type="hidden" name="currentFilter" value="${param.filter}">
                
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Table Number *</label>
                        <input type="text" name="tableNumber" id="addTableNumber" required
                               class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                               placeholder="e.g., T01">
                        <p class="text-xs text-gray-500 mt-1">Letters, numbers, and hyphens only (max 10 characters)</p>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Capacity *</label>
                        <input type="number" name="capacity" id="addCapacity" min="2" max="12" required
                               class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                               placeholder="Number of seats">
                        <p class="text-xs text-gray-500 mt-1">Between 2 and 12 seats</p>
                    </div>
                </div>
                
                <div class="flex justify-end space-x-3 mt-6">
                    <button type="button" onclick="closeAddModal()" 
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-4 py-2 bg-orange-500 text-white hover:bg-orange-600 rounded-lg transition-colors flex items-center">
                        <i data-lucide="plus" class="w-4 h-4 mr-2"></i>
                        Add Table
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Table Modal -->
    <div id="editModal" class="modal">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Edit Table</h2>
            </div>
            <form action="${pageContext.request.contextPath}/table" method="post" onsubmit="return validateEditForm()">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="tableID" id="editTableID">
                <input type="hidden" name="currentFilter" value="${param.filter}">
                
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Table Number</label>
                        <input type="text" name="tableNumber" id="editTableNumber" required
                               class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                        <p class="text-xs text-gray-500 mt-1">Letters, numbers, and hyphens only (max 10 characters)</p>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Capacity</label>
                        <input type="number" name="capacity" id="editCapacity" min="2" max="12" required
                               class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                        <p class="text-xs text-gray-500 mt-1">Between 2 and 12 seats</p>
                    </div>
                </div>
                
                <div class="flex justify-end space-x-3 mt-6">
                    <button type="button" onclick="closeEditModal()" 
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-4 py-2 bg-orange-500 text-white hover:bg-orange-600 rounded-lg transition-colors flex items-center">
                        <i data-lucide="save" class="w-4 h-4 mr-2"></i>
                        Update Table
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Restore Table Modal -->
    <div id="restoreModal" class="modal">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Restore Table</h2>
            </div>
            <form action="${pageContext.request.contextPath}/table" method="post" onsubmit="return validateRestoreForm()">
                <input type="hidden" name="action" value="restore">
                <input type="hidden" name="tableID" id="restoreTableID">
                <input type="hidden" name="currentFilter" value="${param.filter}">
                
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Table Number *</label>
                        <input type="text" name="tableNumber" id="restoreTableNumber" required
                               class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                               readonly>
                        <p class="text-xs text-gray-500 mt-1">Letters, numbers, and hyphens only (max 10 characters)</p>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Capacity *</label>
                        <input type="number" name="capacity" id="restoreCapacity" min="2" max="12" required
                               class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                               readonly>
                        <p class="text-xs text-gray-500 mt-1">Between 2 and 12 seats</p>
                    </div>
                </div>
                
                <div class="flex justify-end space-x-3 mt-6">
                    <button type="button" onclick="closeRestoreModal()" 
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-4 py-2 bg-green-500 text-white hover:bg-green-600 rounded-lg transition-colors flex items-center">
                        <i data-lucide="refresh-ccw" class="w-4 h-4 mr-2"></i>
                        Restore Table
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Confirm Delete</h2>
            </div>
            
            <div class="text-center">
                <i data-lucide="alert-triangle" class="w-12 h-12 text-red-500 mx-auto mb-4"></i>
                <p class="text-gray-700 mb-2">Are you sure you want to delete table <span id="deleteTableName" class="font-semibold"></span>?</p>
                <p class="text-sm text-gray-500 mb-6">This action will take effect tomorrow.</p>
                
                <div class="flex justify-center space-x-3">
                    <button onclick="closeDeleteModal()"
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <form id="deleteForm" action="${pageContext.request.contextPath}/table" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" id="deleteTableID">
                        <input type="hidden" name="currentFilter" value="${param.filter}">
                        <button type="submit"
                                class="px-4 py-2 bg-red-500 text-white hover:bg-red-600 rounded-lg transition-colors flex items-center">
                            <i data-lucide="trash-2" class="w-4 h-4 mr-2"></i>
                            Delete
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Initialize Lucide icons
        lucide.createIcons();

        // Modal functions
        function openAddModal() {
            document.getElementById('addModal').classList.add('active');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.remove('active');
        }

        function openEditModal(id, tableNumber, capacity) {
            document.getElementById('editTableID').value = id;
            document.getElementById('editTableNumber').value = tableNumber;
            document.getElementById('editCapacity').value = capacity;
            
            document.getElementById('editModal').classList.add('active');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.remove('active');
        }

        function openRestoreModal(id, tableNumber, capacity) {
            document.getElementById('restoreTableID').value = id;
            document.getElementById('restoreTableNumber').value = tableNumber;
            document.getElementById('restoreCapacity').value = capacity;
            
            document.getElementById('restoreModal').classList.add('active');
        }

        function closeRestoreModal() {
            document.getElementById('restoreModal').classList.remove('active');
        }

        function confirmDelete(tableID, tableNumber) {
            document.getElementById('deleteTableID').value = tableID;
            document.getElementById('deleteTableName').textContent = tableNumber;
            document.getElementById('deleteModal').classList.add('active');
        }

        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.remove('active');
        }

        // Form validation
        function validateAddForm() {
            return validateTableForm('addTableNumber', 'addCapacity');
        }

        function validateEditForm() {
            return validateTableForm('editTableNumber', 'editCapacity');
        }

        function validateRestoreForm() {
            return validateTableForm('restoreTableNumber', 'restoreCapacity');
        }

        function validateTableForm(tableNumberId, capacityId) {
            const tableNumber = document.getElementById(tableNumberId).value;
            const capacity = document.getElementById(capacityId).value;

            // Validate table number format
            if (!/^[A-Za-z0-9\-]+$/.test(tableNumber)) {
                alert('Table number can only contain letters, numbers, and hyphens.');
                return false;
            }

            if (tableNumber.length > 10) {
                alert('Table number cannot exceed 10 characters.');
                return false;
            }

            // Validate capacity
            if (capacity < 2 || capacity > 12) {
                alert('Capacity must be between 2 and 12.');
                return false;
            }

            return true;
        }

        // Utility functions
        function changeFilter(selectElement) {
            const filter = selectElement.value;
            const url = new URL(window.location.href);
            url.searchParams.set('filter', filter);
            window.location.href = url.toString();
        }
    </script>
</body>
</html>