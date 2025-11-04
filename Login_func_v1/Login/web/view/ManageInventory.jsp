<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Inventory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { background: #f8f9fa; }
        .sidebar { width: 220px; min-height: 100vh; background:#222831; color: #eee; }
        .main { padding: 24px; }
        .nav-btn { display:block; padding:12px 18px; color:#d1d5db; text-decoration:none; }
        .nav-btn.active { background:#ff7f2a; color:#fff; border-radius:6px; }
        .pagination .page-item.active .page-link {
            background-color: #fd7e14; border-color:#fd7e14; color:white;
        }
    </style>
</head>
<body>
<div class="d-flex">
    <!-- SIDEBAR -->
    <div class="sidebar p-3">
        <h4 class="text-white">Dashboard</h4>
        <hr style="border-color:#333;">
        <a class="nav-btn" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a class="nav-btn" href="${pageContext.request.contextPath}/manageproduct">Products</a>
        <a class="nav-btn active" href="${pageContext.request.contextPath}/manageinventory">Inventory</a>
        <a class="nav-btn" href="${pageContext.request.contextPath}/manage-orders">Orders</a>
        <a class="nav-btn" href="${pageContext.request.contextPath}/manage-customers">Customers</a>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main flex-fill">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h2 class="text-primary">Manage Inventory</h2>
                <small class="text-muted">PizzaConnect Restaurant Management System</small>
            </div>
            <div>
                <a href="manageinventory?action=add" class="btn btn-success">+ Add New Inventory</a>
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

        <!-- Results Summary -->
        <div class="mb-3">
            <small class="text-muted">
                Showing ${totalItems} item(s)
                <c:if test="${not empty searchName}"> matching "${searchName}"</c:if>
                <c:if test="${statusFilter != 'all'}"> with status "${statusFilter}"</c:if>
            </small>
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
                                    <c:url var="editUrl" value="manageinventory">
                                        <c:param name="action" value="edit"/>
                                        <c:param name="id" value="${inv.inventoryID}"/>
                                        <c:if test="${not empty searchName}">
                                            <c:param name="searchName" value="${searchName}"/>
                                        </c:if>
                                        <c:if test="${statusFilter != 'all'}">
                                            <c:param name="statusFilter" value="${statusFilter}"/>
                                        </c:if>
                                        <c:param name="page" value="${currentPage}"/>
                                    </c:url>
                                    <c:url var="toggleUrl" value="manageinventory">
                                        <c:param name="action" value="toggle"/>
                                        <c:param name="id" value="${inv.inventoryID}"/>
                                        <c:if test="${not empty searchName}">
                                            <c:param name="searchName" value="${searchName}"/>
                                        </c:if>
                                        <c:if test="${statusFilter != 'all'}">
                                            <c:param name="statusFilter" value="${statusFilter}"/>
                                        </c:if>
                                        <c:param name="page" value="${currentPage}"/>
                                    </c:url>
                                    
                                    <a class="btn btn-sm btn-warning" href="${editUrl}">
                                        Edit
                                    </a>
                                    <c:choose>
                                        <c:when test="${inv.status == 'Active'}">
                                            <a class="btn btn-sm btn-danger" href="${toggleUrl}" 
                                               onclick="return confirm('Are you sure you want to deactivate this item?');">
                                                Deactivate
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="btn btn-sm btn-success" href="${toggleUrl}"
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

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="d-flex justify-content-center mt-3">
                <ul class="pagination">
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
                            </c:url>
                            <a class="page-link" href="${prevUrl}">&laquo;</a>
                        </li>
                    </c:if>
                    <c:if test="${currentPage == 1}">
                        <li class="page-item disabled">
                            <span class="page-link">&laquo;</span>
                        </li>
                    </c:if>
                    
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:url var="pageUrl" value="manageinventory">
                            <c:param name="page" value="${p}"/>
                            <c:if test="${not empty searchName}">
                                <c:param name="searchName" value="${searchName}"/>
                            </c:if>
                            <c:if test="${statusFilter != 'all'}">
                                <c:param name="statusFilter" value="${statusFilter}"/>
                            </c:if>
                        </c:url>
                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                            <a class="page-link" href="${pageUrl}">${p}</a>
                        </li>
                    </c:forEach>
                    
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
                            </c:url>
                            <a class="page-link" href="${nextUrl}">&raquo;</a>
                        </li>
                    </c:if>
                    <c:if test="${currentPage == totalPages}">
                        <li class="page-item disabled">
                            <span class="page-link">&raquo;</span>
                        </li>
                    </c:if>
                </ul>
            </div>
        </c:if>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>

