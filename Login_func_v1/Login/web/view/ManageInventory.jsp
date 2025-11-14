<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Inventory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            background: #f5f6fa; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        /* Expandable Sidebar Styles */
        .sidebar {
            width: 5rem;
            transition: width 0.3s ease;
        }
        .sidebar:hover {
            width: 16rem;
        }
        .sidebar-text {
            opacity: 0;
            white-space: nowrap;
            transition: opacity 0.3s ease;
        }
        .sidebar:hover .sidebar-text {
            opacity: 1;
        }
        
        /* Main Content */
        .main-content {
            margin-left: 5rem;
            padding: 30px;
            min-height: 100vh;
        }
        
        .page-header {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 25px;
        }
        
        .page-header h2 {
            color: #2c3e50;
            margin-bottom: 5px;
        }
        
        .page-header small {
            color: #7f8c8d;
        }
        
        .btn-add {
            background: #27ae60;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 500;
        }
        
        .btn-add:hover {
            background: #229954;
        }
        
        .pagination .page-item.active .page-link {
            background-color: #3498db; 
            border-color: #3498db; 
            color: white;
        }
        
        /* Card Styling */
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        /* Table Styling */
        .table-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .table thead {
            background: #34495e;
            color: white;
        }
        
        .table thead th {
            border: none;
            padding: 15px;
            font-weight: 500;
        }
        
        .table tbody tr {
            transition: background 0.2s ease;
        }
        
        .table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 500;
        }
        
        /* Modal Styling */
        .modal-content {
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .modal-header {
            background-color: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
        }
        
        .modal-title {
            color: #0d6efd;
            font-weight: 600;
        }
        
        .modal-footer {
            border-top: 1px solid #dee2e6;
        }
        
        #modalErrorMessage {
            margin-bottom: 1rem;
        }
        
        /* Responsive modal */
        @media (max-width: 576px) {
            .modal-dialog {
                margin: 0.5rem;
            }
        }
    </style>
</head>
<body class="ml-20">
    
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>

    <!-- Main Content -->
    <div class="main-content mt-16">
        <div class="page-header d-flex justify-content-between align-items-center">
            <div>
                <h2>Manage Inventory</h2>
                <small>PizzaConnect Restaurant Management System</small>
            </div>
            <div>
                <button type="button" class="btn-add" onclick="openAddModal()">+ Add Inventory</button>
            </div>
        </div>

        <!-- Success/Error Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Search and Filter Form -->
        <div class="card mb-3">
            <div class="card-body">
                <form method="GET" action="manageinventory" class="row g-3">
                    <div class="col-md-6">
                        <label for="searchName" class="form-label">Search by Item Name</label>
                        <input type="text" class="form-control" id="searchName" name="searchName" 
                               value="${searchName}" placeholder="Enter item name...">
                    </div>
                    <div class="col-md-3">
                        <label for="statusFilter" class="form-label">Status Filter</label>
                        <select class="form-select" id="statusFilter" name="statusFilter">
                            <option value="all" ${statusFilter == 'all' ? 'selected' : ''}>All Status</option>
                            <option value="active" ${statusFilter == 'active' ? 'selected' : ''}>Active Only</option>
                            <option value="inactive" ${statusFilter == 'inactive' ? 'selected' : ''}>Inactive Only</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary me-2">
                            🔍 Search
                        </button>
                        <a href="manageinventory" class="btn btn-outline-secondary">
                            ✖ Clear
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Results Summary and Page Size Selector -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <small class="text-muted">
                    Showing ${startItem}-${endItem} of ${totalItems} item(s)
                    <c:if test="${not empty searchName}"> matching "${searchName}"</c:if>
                    <c:if test="${statusFilter != 'all'}"> with status "${statusFilter}"</c:if>
                </small>
            </div>
            <div class="d-flex align-items-center">
                <label class="form-label me-2 mb-0">Items per page:</label>
                <select class="form-select form-select-sm" style="width: auto;" onchange="changePageSize(this.value)">
                    <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                    <option value="25" ${pageSize == 25 ? 'selected' : ''}>25</option>
                    <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                </select>
            </div>
        </div>

        <div class="card">
            <div class="card-body p-0">
                <table class="table table-bordered mb-0 text-center align-middle">
                    <thead class="table-primary">
                        <tr>
                            <th>ID</th><th>Item Name</th><th>Quantity</th><th>Unit</th><th>Last Updated</th><th>Status</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inv" items="${inventoryList}">
                            <tr>
                                <td>${inv.inventoryID}</td>
                                <td>${inv.itemName}</td>
                                <td>${inv.quantity}</td>
                                <td>${inv.unit}</td>
                                <td>${inv.lastUpdated}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${inv.status == 'Active'}">
                                            <span class="badge bg-success">Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">Inactive</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <%-- Build toggle URL --%>
                                    <c:set var="toggleUrl" value="${pageContext.request.contextPath}/manageinventory?action=toggle&id=${inv.inventoryID}&page=${currentPage}"/>
                                    <c:if test="${not empty searchName}">
                                        <c:set var="toggleUrl" value="${toggleUrl}&searchName=${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter ne 'all'}">
                                        <c:set var="toggleUrl" value="${toggleUrl}&statusFilter=${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize ne 10}">
                                        <c:set var="toggleUrl" value="${toggleUrl}&pageSize=${pageSize}"/>
                                    </c:if>
                                    
                                    <button type="button" class="btn btn-sm btn-warning edit-btn" 
                                            data-id="${inv.inventoryID}" 
                                            data-name="${inv.itemName}" 
                                            data-quantity="${inv.quantity}" 
                                            data-unit="${inv.unit}">
                                        Edit
                                    </button>
                                    <c:choose>
                                        <c:when test="${inv.status == 'Active'}">
                                            <a class="btn btn-sm btn-danger" 
                                               href="${toggleUrl}" 
                                               onclick="return confirm('Are you sure you want to deactivate this item?');">
                                                Deactivate
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="btn btn-sm btn-success" 
                                               href="${toggleUrl}"
                                               onclick="return confirm('Are you sure you want to activate this item?');">
                                                Activate
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty inventoryList}">
                            <tr><td colspan="7">No inventory found.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Enhanced Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="d-flex justify-content-between align-items-center mt-4">
                <!-- Pagination Info -->
                <div>
                    <small class="text-muted">
                        Page ${currentPage} of ${totalPages} (${totalItems} total items)
                    </small>
                </div>
                
                <!-- Pagination Controls -->
                <nav aria-label="Inventory pagination">
                    <ul class="pagination mb-0">
                        <!-- First Page -->
                        <c:if test="${currentPage > 1}">
                            <li class="page-item">
                                <c:url var="firstUrl" value="manageinventory">
                                    <c:param name="page" value="1"/>
                                    <c:if test="${not empty searchName}">
                                        <c:param name="searchName" value="${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter != 'all'}">
                                        <c:param name="statusFilter" value="${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize != 10}">
                                        <c:param name="pageSize" value="${pageSize}"/>
                                    </c:if>
                                </c:url>
                                <a class="page-link" href="${firstUrl}" title="First page">&laquo;&laquo;</a>
                            </li>
                        </c:if>
                        
                        <!-- Previous Page -->
                        <c:if test="${currentPage > 1}">
                            <li class="page-item">
                                <c:url var="prevUrl" value="manageinventory">
                                    <c:param name="page" value="${currentPage - 1}"/>
                                    <c:if test="${not empty searchName}">
                                        <c:param name="searchName" value="${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter != 'all'}">
                                        <c:param name="statusFilter" value="${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize != 10}">
                                        <c:param name="pageSize" value="${pageSize}"/>
                                    </c:if>
                                </c:url>
                                <a class="page-link" href="${prevUrl}" title="Previous page">&laquo;</a>
                            </li>
                        </c:if>
                        
                        <!-- Smart Page Numbers -->
                        <c:set var="startPage" value="${currentPage - 2 > 1 ? currentPage - 2 : 1}"/>
                        <c:set var="endPage" value="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}"/>
                        
                        <!-- Show first page if not in range -->
                        <c:if test="${startPage > 1}">
                            <li class="page-item">
                                <c:url var="pageUrl" value="manageinventory">
                                    <c:param name="page" value="1"/>
                                    <c:if test="${not empty searchName}">
                                        <c:param name="searchName" value="${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter != 'all'}">
                                        <c:param name="statusFilter" value="${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize != 10}">
                                        <c:param name="pageSize" value="${pageSize}"/>
                                    </c:if>
                                </c:url>
                                <a class="page-link" href="${pageUrl}">1</a>
                            </li>
                            <c:if test="${startPage > 2}">
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            </c:if>
                        </c:if>
                        
                        <!-- Page range -->
                        <c:forEach begin="${startPage}" end="${endPage}" var="p">
                            <c:url var="pageUrl" value="manageinventory">
                                <c:param name="page" value="${p}"/>
                                <c:if test="${not empty searchName}">
                                    <c:param name="searchName" value="${searchName}"/>
                                </c:if>
                                <c:if test="${statusFilter != 'all'}">
                                    <c:param name="statusFilter" value="${statusFilter}"/>
                                </c:if>
                                <c:if test="${pageSize != 10}">
                                    <c:param name="pageSize" value="${pageSize}"/>
                                </c:if>
                            </c:url>
                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                <a class="page-link" href="${pageUrl}">${p}</a>
                            </li>
                        </c:forEach>
                        
                        <!-- Show last page if not in range -->
                        <c:if test="${endPage < totalPages}">
                            <c:if test="${endPage < totalPages - 1}">
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            </c:if>
                            <li class="page-item">
                                <c:url var="pageUrl" value="manageinventory">
                                    <c:param name="page" value="${totalPages}"/>
                                    <c:if test="${not empty searchName}">
                                        <c:param name="searchName" value="${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter != 'all'}">
                                        <c:param name="statusFilter" value="${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize != 10}">
                                        <c:param name="pageSize" value="${pageSize}"/>
                                    </c:if>
                                </c:url>
                                <a class="page-link" href="${pageUrl}">${totalPages}</a>
                            </li>
                        </c:if>
                        
                        <!-- Next Page -->
                        <c:if test="${currentPage < totalPages}">
                            <li class="page-item">
                                <c:url var="nextUrl" value="manageinventory">
                                    <c:param name="page" value="${currentPage + 1}"/>
                                    <c:if test="${not empty searchName}">
                                        <c:param name="searchName" value="${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter != 'all'}">
                                        <c:param name="statusFilter" value="${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize != 10}">
                                        <c:param name="pageSize" value="${pageSize}"/>
                                    </c:if>
                                </c:url>
                                <a class="page-link" href="${nextUrl}" title="Next page">&raquo;</a>
                            </li>
                        </c:if>
                        
                        <!-- Last Page -->
                        <c:if test="${currentPage < totalPages}">
                            <li class="page-item">
                                <c:url var="lastUrl" value="manageinventory">
                                    <c:param name="page" value="${totalPages}"/>
                                    <c:if test="${not empty searchName}">
                                        <c:param name="searchName" value="${searchName}"/>
                                    </c:if>
                                    <c:if test="${statusFilter != 'all'}">
                                        <c:param name="statusFilter" value="${statusFilter}"/>
                                    </c:if>
                                    <c:if test="${pageSize != 10}">
                                        <c:param name="pageSize" value="${pageSize}"/>
                                    </c:if>
                                </c:url>
                                <a class="page-link" href="${lastUrl}" title="Last page">&raquo;&raquo;</a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
                
                <!-- Jump to Page -->
                <div class="d-flex align-items-center">
                    <label class="form-label me-2 mb-0">Go to page:</label>
                    <input type="number" class="form-control form-control-sm" style="width: 80px;" 
                           min="1" max="${totalPages}" value="${currentPage}" 
                           onkeypress="if(event.key==='Enter') jumpToPage(this.value)">
                    <button class="btn btn-sm btn-outline-primary ms-1" onclick="jumpToPage(document.querySelector('input[type=number]').value)">
                        Go
                    </button>
                </div>
            </div>
        </c:if>
    </div>
</div>

<!-- Add/Edit Inventory Modal -->
<div class="modal fade" id="inventoryModal" tabindex="-1" aria-labelledby="inventoryModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="inventoryModalLabel">Add New Inventory</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="inventoryForm" method="POST" action="manageinventory">
                <div class="modal-body">
                    <!-- Hidden fields for preserving context -->
                    <input type="hidden" id="inventoryId" name="id" value="">
                    <input type="hidden" name="returnSearchName" value="${searchName}">
                    <input type="hidden" name="returnStatusFilter" value="${statusFilter}">
                    <input type="hidden" name="returnPage" value="${currentPage}">
                    <input type="hidden" name="returnPageSize" value="${pageSize}">
                    
                    <!-- Error message display -->
                    <div id="modalErrorMessage" class="alert alert-danger d-none" role="alert"></div>
                    
                    <!-- Item Name -->
                    <div class="mb-3">
                        <label for="itemName" class="form-label">Item Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="itemName" name="itemName" required 
                               placeholder="Enter item name" aria-label="Item Name" tabindex="1">
                    </div>
                    
                    <!-- Quantity -->
                    <div class="mb-3">
                        <label for="quantity" class="form-label">Quantity <span class="text-danger">*</span></label>
                        <input type="number" step="0.01" class="form-control" id="quantity" name="quantity" 
                               required min="0" placeholder="Enter quantity" aria-label="Quantity" tabindex="2">
                    </div>
                    
                    <!-- Unit -->
                    <div class="mb-3">
                        <label for="unit" class="form-label">Unit <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="unit" name="unit" required 
                               placeholder="e.g., kg, liters, pieces" aria-label="Unit" tabindex="3">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" tabindex="5" aria-label="Cancel">Cancel</button>
                    <button type="submit" class="btn btn-success" tabindex="4" aria-label="Save Inventory">Save Inventory</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Function to change page size
    function changePageSize(newPageSize) {
        const url = new URL(window.location);
        url.searchParams.set('pageSize', newPageSize);
        url.searchParams.set('page', '1'); // Reset to first page when changing page size
        window.location.href = url.toString();
    }
    
    // Function to jump to specific page
    function jumpToPage(pageNumber) {
        const maxPages = ${totalPages};
        const page = parseInt(pageNumber);
        
        if (isNaN(page) || page < 1 || page > maxPages) {
            alert('Please enter a valid page number between 1 and ' + maxPages);
            return;
        }
        
        const url = new URL(window.location);
        url.searchParams.set('page', page);
        window.location.href = url.toString();
    }
    
    // Auto-submit search form when status filter changes
    document.getElementById('statusFilter').addEventListener('change', function() {
        this.form.submit();
    });
    
    // Modal Functions
    
    // Open modal for adding new inventory
    function openAddModal() {
        // Reset form
        document.getElementById('inventoryForm').reset();
        document.getElementById('inventoryId').value = '';
        document.getElementById('modalErrorMessage').classList.add('d-none');
        
        // Set title
        document.getElementById('inventoryModalLabel').textContent = 'Add New Inventory';
        
        // Show modal
        const modal = new bootstrap.Modal(document.getElementById('inventoryModal'));
        modal.show();
        
        // Focus first field after modal animation
        setTimeout(() => {
            document.getElementById('itemName').focus();
        }, 500);
    }
    
    // Open modal for editing existing inventory
    function openEditModal(id, itemName, quantity, unit) {
        // Populate form with existing data
        document.getElementById('inventoryId').value = id;
        document.getElementById('itemName').value = itemName;
        document.getElementById('quantity').value = quantity;
        document.getElementById('unit').value = unit;
        document.getElementById('modalErrorMessage').classList.add('d-none');
        
        // Set title
        document.getElementById('inventoryModalLabel').textContent = 'Edit Inventory Item';
        
        // Show modal
        const modal = new bootstrap.Modal(document.getElementById('inventoryModal'));
        modal.show();
        
        // Focus first field after modal animation
        setTimeout(() => {
            document.getElementById('itemName').focus();
        }, 500);
    }
    
    // Client-side form validation
    document.getElementById('inventoryForm').addEventListener('submit', function(e) {
        const itemName = document.getElementById('itemName').value.trim();
        const quantity = document.getElementById('quantity').value;
        const unit = document.getElementById('unit').value.trim();
        
        let errors = [];
        
        // Validate item name
        if (!itemName) {
            errors.push('Item name cannot be empty');
        }
        
        // Validate unit
        if (!unit) {
            errors.push('Unit cannot be empty');
        }
        
        // Validate quantity
        if (!quantity || parseFloat(quantity) < 0) {
            errors.push('Quantity must be a non-negative number');
        }
        
        // Display errors if any
        if (errors.length > 0) {
            e.preventDefault();
            const errorDiv = document.getElementById('modalErrorMessage');
            errorDiv.textContent = errors.join('. ') + '.';
            errorDiv.classList.remove('d-none');
            return false;
        }
    });
    
    // Add event listeners to all edit buttons
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.edit-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const id = this.getAttribute('data-id');
                const name = this.getAttribute('data-name');
                const quantity = this.getAttribute('data-quantity');
                const unit = this.getAttribute('data-unit');
                openEditModal(id, name, quantity, unit);
            });
        });
        
        // Initialize Lucide icons
        lucide.createIcons();
    });
</script>

</body>
</html>

