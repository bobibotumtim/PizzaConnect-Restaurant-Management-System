<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Discount Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .nav-btn {
            width: 3rem;
            height: 3rem;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        .nav-btn:hover {
            transform: translateY(-2px);
        }
        
        .tab-btn {
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            transition: all 0.2s;
            white-space: nowrap;
        }
        
        .overflow-auto::-webkit-scrollbar {
            width: 8px;
        }
        .overflow-auto::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }
        .overflow-auto::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 4px;
        }
        .overflow-auto::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }
    </style>
</head>
<body class="flex h-screen bg-gray-50">
    <!-- Sidebar Navigation -->
    <%
        String currentPath = request.getRequestURI();
    %>
    <div class="w-20 bg-gray-800 flex flex-col items-center py-6 space-y-8">
        <a href="${pageContext.request.contextPath}/home"
           class="nav-btn <%= currentPath.contains("/home") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
           title="Home">
            <i data-lucide="home" class="w-6 h-6"></i>
        </a>
        <div class="flex-1 flex flex-col space-y-6 mt-8">
            <a href="${pageContext.request.contextPath}/dashboard"
                class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Dashboard">
                <i data-lucide="grid" class="w-6 h-6"></i>
            </a>
            
            <a href="${pageContext.request.contextPath}/orders"
                class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Orders">
                <i data-lucide="file-text" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/manageproduct"
                class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Menu">
                <i data-lucide="utensils" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/table" 
            class="nav-btn <%= currentPath.contains("/table") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
            title="Table Booking">
                <i data-lucide="rectangle-horizontal" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/discount"
                class="nav-btn <%= currentPath.contains("/discount") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Discount Programs">
                <i data-lucide="percent" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/notifications"
                class="nav-btn <%= currentPath.contains("/notifications") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Notifications">
                <i data-lucide="bell" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/admin"
                class="nav-btn <%= currentPath.contains("/admin") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Manage Users">
                <i data-lucide="users" class="w-6 h-6"></i>
            </a>
        </div>
        <a href="${pageContext.request.contextPath}/profile"
            class="nav-btn <%= currentPath.contains("/profile") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
            title="Profile">
            <i data-lucide="user" class="w-6 h-6"></i>
        </a>
        <a href="${pageContext.request.contextPath}/settings"
            class="nav-btn <%= currentPath.contains("/settings") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
            title="Settings">
            <i data-lucide="settings" class="w-6 h-6"></i>
        </a>
        <a href="${pageContext.request.contextPath}/logout"
           class="nav-btn <%= currentPath.contains("/logout") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
           title="Logout">
            <i data-lucide="log-out" class="w-6 h-6"></i>
        </a>
    </div>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col overflow-hidden min-w-0">
        <!-- Header Section with Search -->
        <div class="bg-white border-b px-6 py-4 flex-shrink-0">
            <div class="flex flex-col lg:flex-row lg:justify-between lg:items-center gap-4">
                <div class="flex items-center space-x-4 flex-1">
                    <h1 class="text-2xl font-bold text-gray-800 whitespace-nowrap">Discount Management</h1>
                    
                    <!-- Search Input -->
                    <div class="flex flex-1 max-w-2xl">
                        <input type="text" name="search" value="${param.search}" 
                               placeholder="Search by description or value..." 
                               class="border border-gray-300 rounded-l-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-full"
                               onkeypress="handleSearchKeyPress(event)">
                        <button type="button" onclick="performSearch()"
                                class="bg-orange-500 text-white px-6 py-2 rounded-r-lg hover:bg-orange-600 transition-colors flex items-center whitespace-nowrap">
                            <i data-lucide="search" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
                <div class="flex gap-3 flex-wrap">
                    <button onclick="downloadTemplate()" class="tab-btn bg-green-500 text-white hover:bg-green-600 transition-colors flex items-center">
                        <i data-lucide="download" class="w-4 h-4 mr-2"></i>
                        Download Template
                    </button>

                    <button onclick="openImportModal()" 
                            class="tab-btn bg-blue-500 text-white hover:bg-blue-600 transition-colors flex items-center">
                        <i data-lucide="upload" class="w-4 h-4 mr-2"></i>
                        Import Discounts
                    </button>

                    <button onclick="openAddModal()" class="tab-btn bg-orange-500 text-white hover:bg-orange-600 transition-colors flex items-center">
                        <i data-lucide="plus" class="w-4 h-4 mr-2"></i>
                        Add New Discount
                    </button>
                </div>
            </div>
            
            <!-- Filter Controls -->
            <div class="mt-4 pt-4 border-t border-gray-200">
                <form id="filterForm" action="${pageContext.request.contextPath}/discount" method="get" class="flex flex-col md:flex-row gap-4 items-start md:items-end">
                    <div class="flex flex-col">
                        <label class="text-sm font-medium text-gray-700 mb-1">Status</label>
                        <select name="filter" onchange="applyFilters()" class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-48">
                            <option value="active" ${param.filter != 'inactive' ? 'selected' : ''}>Active Discounts</option>
                            <option value="inactive" ${param.filter == 'inactive' ? 'selected' : ''}>Inactive Discounts</option>
                        </select>
                    </div>
                    
                    <div class="flex flex-col">
                        <label class="text-sm font-medium text-gray-700 mb-1">Discount Type</label>
                        <select name="type" onchange="applyFilters()" class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-48">
                            <option value="">All Types</option>
                            <option value="Percentage" ${param.type == 'Percentage' ? 'selected' : ''}>Percentage</option>
                            <option value="Fixed" ${param.type == 'Fixed' ? 'selected' : ''}>Fixed</option>
                            <option value="Loyalty" ${param.type == 'Loyalty' ? 'selected' : ''}>Loyalty</option>
                        </select>
                    </div>
                    
                    <div class="flex flex-col">
                        <label class="text-sm font-medium text-gray-700 mb-1">Start Date From</label>
                        <input type="date" name="startDate" value="${param.startDate}" 
                               class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-48"
                               onchange="applyFilters()">
                    </div>
                    
                    <div class="flex flex-col">
                        <label class="text-sm font-medium text-gray-700 mb-1">End Date To</label>
                        <input type="date" name="endDate" value="${param.endDate}" 
                               class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-48"
                               onchange="applyFilters()">
                    </div>
                    
                    <div class="flex flex-col">
                        <button type="button" onclick="resetFilters()" 
                                class="text-gray-600 bg-gray-100 hover:bg-gray-200 px-4 py-2 rounded-lg transition-colors h-[42px] flex items-center">
                            <i data-lucide="refresh-cw" class="w-4 h-4 mr-2"></i>
                            Reset Filters
                        </button>
                    </div>
                    
                    <input type="hidden" name="page" value="1">
                    <input type="hidden" name="search" id="searchInput" value="${param.search}">
                </form>
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1 p-6 overflow-auto">
            <!-- Success Message Display -->
            <c:if test="${not empty success}">
                <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                        <span>${success}</span>
                    </div>
                    <c:if test="${not empty importErrorResults}">
                        <div class="mt-2">
                            <a href="${pageContext.request.contextPath}/discount/import?action=error-report" 
                               class="text-red-600 hover:text-red-800 underline flex items-center">
                                <i data-lucide="file-text" class="w-4 h-4 mr-1"></i>
                                Download Error Report
                            </a>
                        </div>
                    </c:if>
                </div>
                <%
                    session.removeAttribute("success");
                %>
            </c:if>

            <!-- Error Message Display -->
            <c:if test="${not empty error}">
                <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                        <span>${error}</span>
                    </div>
                </div>
            </c:if>

            <!-- Discounts Table Container -->
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                <div class="flex justify-between items-center mb-6">
                    <h2 class="text-lg font-bold ${param.filter != 'inactive' ? 'text-green-700' : 'text-gray-600'} flex items-center">
                        <i data-lucide="${param.filter != 'inactive' ? 'check-circle' : 'x-circle'}" class="w-5 h-5 mr-2"></i>
                        ${param.filter != 'inactive' ? 'Active Discounts' : 'Inactive Discounts'}
                    </h2>
                    <div class="text-sm text-gray-500">
                        Showing ${discounts.size()} of ${totalItems} discounts
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not empty discounts}">
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm text-left text-gray-500">
                                <thead class="text-xs text-gray-700 uppercase ${param.filter != 'inactive' ? 'bg-green-50' : 'bg-gray-100'} border-b">
                                    <tr>
                                        <th class="px-4 py-3 font-semibold">ID</th>
                                        <th class="px-4 py-3 font-semibold">Description</th>
                                        <th class="px-4 py-3 font-semibold">Type</th>
                                        <th class="px-4 py-3 font-semibold">Value</th>
                                        <th class="px-4 py-3 font-semibold">Max Discount</th>
                                        <th class="px-4 py-3 font-semibold">Min Order</th>
                                        <th class="px-4 py-3 font-semibold">Start Date</th>
                                        <th class="px-4 py-3 font-semibold">End Date</th>
                                        <th class="px-4 py-3 font-semibold">Status</th>
                                        <c:if test="${param.filter != 'inactive'}">
                                            <th class="px-4 py-3 font-semibold text-center">Actions</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-200">
                                    <c:forEach var="discount" items="${discounts}">
                                        <tr class="bg-white hover:${param.filter != 'inactive' ? 'bg-green-50' : 'bg-gray-50'} transition-colors">
                                            <td class="px-4 py-4 font-medium text-gray-900">${discount.discountId}</td>
                                            <td class="px-4 py-4 font-medium text-gray-900 ${not discount.active ? 'line-through text-gray-500' : ''}">
                                                ${discount.description}
                                            </td>
                                            <td class="px-4 py-4">
                                                <span class="px-3 py-1 text-xs font-medium rounded-full
                                                    ${discount.discountType == 'Percentage' ? 'bg-purple-100 text-purple-800' : 
                                                    discount.discountType == 'Fixed' ? 'bg-blue-100 text-blue-800' : 
                                                    'bg-yellow-100 text-yellow-800'}">
                                                    ${discount.discountType}
                                                </span>
                                            </td>
                                            <td class="px-4 py-4 font-medium text-gray-900">
                                                <c:choose>
                                                    <c:when test="${discount.discountType == 'Percentage'}">${discount.value}%</c:when>
                                                    <c:when test="${discount.discountType == 'Fixed'}">${discount.value}₫</c:when>
                                                    <c:otherwise>${discount.value} pts</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-4 py-4">
                                                <c:choose>
                                                    <c:when test="${discount.maxDiscount != null}">${discount.maxDiscount}₫</c:when>
                                                    <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-4 py-4">${discount.minOrderTotal}₫</td>
                                            <td class="px-4 py-4">${discount.startDate}</td>
                                            <td class="px-4 py-4">
                                                <c:choose>
                                                    <c:when test="${discount.endDate != null}">${discount.endDate}</c:when>
                                                    <c:otherwise>No expiry</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-4 py-4">
                                                <span class="px-2 py-1 text-xs font-medium rounded-full
                                                    ${discount.active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}">
                                                    ${discount.active ? 'Active' : 'Inactive'}
                                                </span>
                                            </td>
                                            <c:if test="${param.filter != 'inactive'}">
                                                <td class="px-4 py-4">
                                                    <div class="flex justify-center space-x-2">
                                                        <!-- Only show edit button if discount can be edited (start date > today) -->
                                                        <c:if test="${requestScope['canEdit_' += discount.discountId]}">
                                                            <button onclick="openEditModal(${discount.discountId}, '<c:out value="${discount.description}" />', '${discount.discountType}', ${discount.value}, ${discount.maxDiscount != null ? discount.maxDiscount : 'null'}, ${discount.minOrderTotal}, '${discount.startDate}', '<c:out value="${discount.endDate}" />')"
                                                                    class="text-blue-600 hover:text-blue-800 text-sm font-medium flex items-center p-2 rounded hover:bg-blue-50 transition-colors"
                                                                    title="Edit Discount">
                                                                <i data-lucide="edit" class="w-4 h-4"></i>
                                                            </button>
                                                        </c:if>
                                                        <button onclick="confirmDelete(${discount.discountId}, '${discount.startDate}')" 
                                                                class="text-red-600 hover:text-red-800 text-sm font-medium flex items-center p-2 rounded hover:bg-red-50 transition-colors"
                                                                title="Delete Discount">
                                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination Controls -->
                        <c:if test="${totalPages > 1}">
                            <div class="flex justify-between items-center mt-6">
                                <div class="text-sm text-gray-500">
                                    Showing page ${currentPage} of ${totalPages}
                                </div>
                                <div class="flex items-center space-x-2">
                                    <button onclick="goToPage(1)" 
                                            class="px-3 py-2 border border-gray-300 rounded ${currentPage == 1 ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'hover:bg-gray-100 text-gray-700'} transition-colors">
                                        <i data-lucide="chevrons-left" class="w-4 h-4"></i>
                                    </button>
                                    <button onclick="goToPage(${currentPage - 1})" 
                                            class="px-3 py-2 border border-gray-300 rounded ${currentPage == 1 ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'hover:bg-gray-100 text-gray-700'} transition-colors">
                                        <i data-lucide="chevron-left" class="w-4 h-4"></i>
                                    </button>
                                    <span class="mx-2 text-sm text-gray-700">
                                        Page 
                                        <input type="number" id="pageInput" value="${currentPage}" 
                                            min="1" max="${totalPages}" 
                                            onchange="goToPage(this.value)"
                                            class="w-12 text-center border border-gray-300 rounded mx-1 px-2 py-1 focus:outline-none focus:ring-2 focus:ring-orange-500">
                                        of ${totalPages}
                                    </span>
                                    <button onclick="goToPage(${currentPage + 1})" 
                                            class="px-3 py-2 border border-gray-300 rounded ${currentPage == totalPages ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'hover:bg-gray-100 text-gray-700'} transition-colors">
                                        <i data-lucide="chevron-right" class="w-4 h-4"></i>
                                    </button>
                                    <button onclick="goToPage(${totalPages})" 
                                            class="px-3 py-2 border border-gray-300 rounded ${currentPage == totalPages ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'hover:bg-gray-100 text-gray-700'} transition-colors">
                                        <i data-lucide="chevrons-right" class="w-4 h-4"></i>
                                    </button>
                                </div>
                            </div>
                        </c:if>
                    </c:when>
                    
                    <c:otherwise>
                        <!-- Empty State -->
                        <div class="text-center py-16">
                            <div class="bg-white p-12 mx-auto">
                                <i data-lucide="percent" class="w-16 h-16 text-gray-400 mx-auto mb-4"></i>
                                <h3 class="text-xl font-bold text-gray-700 mb-3">
                                    <c:choose>
                                        <c:when test="${param.filter == 'active'}">No active discounts found</c:when>
                                        <c:when test="${param.filter == 'inactive'}">No inactive discounts found</c:when>
                                    </c:choose>
                                </h3>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Import Discounts Modal -->
    <div id="importModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded-lg p-6 w-full max-w-2xl mx-4">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Import Discounts</h2>
            </div>

            <form action="${pageContext.request.contextPath}/discount/import/import" 
                  method="post" enctype="multipart/form-data">
                <div class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                    <i data-lucide="upload-cloud" class="w-16 h-16 text-gray-400 mx-auto mb-4"></i>
                    <p class="text-gray-600 mb-2 text-lg">Choose your Excel file</p>
                    <input type="file" name="file" id="fileInput" accept=".xlsx,.xls" 
                           class="block mx-auto mb-4" required>
                    <p class="text-sm text-gray-500 mt-3">Supported formats: .xlsx, .xls (Max 10MB)</p>
                </div>
                
                <div class="flex justify-end space-x-3 mt-6">
                    <button type="button" onclick="closeImportModal()" 
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 bg-orange-500 text-white hover:bg-orange-600 rounded-lg transition-colors flex items-center">
                        <i data-lucide="upload" class="w-4 h-4 mr-2"></i>
                        Import Discounts
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add Discount Modal -->
    <div id="addModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Add New Discount</h2>
            </div>
            <form id="addForm" action="${pageContext.request.contextPath}/discount" method="post" onsubmit="return validateAddForm()">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="currentFilter" value="${param.filter != 'inactive' ? 'active' : 'inactive'}">
                <input type="hidden" name="currentPage" value="${currentPage}">
                <input type="hidden" name="currentType" value="${param.type}">
                <input type="hidden" name="currentStartDate" value="${param.startDate}">
                <input type="hidden" name="currentEndDate" value="${param.endDate}">
                <input type="hidden" name="currentSearch" value="${param.search}">
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <input type="text" name="description" id="addDescription" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                        <div id="addDescriptionError" class="text-red-500 text-sm mt-1 hidden">This description already exists</div>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Discount Type</label>
                        <select name="discountType" id="addDiscountType" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                            <option value="Percentage">Percentage</option>
                            <option value="Fixed">Fixed</option>
                            <option value="Loyalty">Loyalty</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Value</label>
                        <input type="number" step="0.1" name="value" id="addValue" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" min="1" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Max Discount (Optional)</label>
                        <input type="number" step="0.1" name="maxDiscount" id="addMaxDiscount" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" min="1000">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Min Order Total</label>
                        <input type="number" step="0.1" name="minOrderTotal" id="addMinOrderTotal" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" min="0" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Start Date</label>
                        <input type="date" name="startDate" id="addStartDate" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">End Date (Optional)</label>
                        <input type="date" name="endDate" id="addEndDate" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                    </div>
                </div>
                <div class="flex justify-end space-x-3 mt-6">
                    <button type="button" onclick="closeAddModal()" class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-orange-500 text-white hover:bg-orange-600 rounded-lg transition-colors">Add Discount</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Discount Modal -->
    <div id="editModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Edit Discount</h2>
            </div>
            <form id="editForm" action="${pageContext.request.contextPath}/discount" method="post" onsubmit="return validateEditForm()">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="discountId" id="editDiscountId">
                <input type="hidden" name="currentFilter" value="${param.filter != 'inactive' ? 'active' : 'inactive'}">
                <input type="hidden" name="currentPage" value="${currentPage}">
                <input type="hidden" name="currentType" value="${param.type}">
                <input type="hidden" name="currentStartDate" value="${param.startDate}">
                <input type="hidden" name="currentEndDate" value="${param.endDate}">
                <input type="hidden" name="currentSearch" value="${param.search}">
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <input type="text" name="description" id="editDescription" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                        <div id="editDescriptionError" class="text-red-500 text-sm mt-1 hidden">This description already exists</div>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Discount Type</label>
                        <select name="discountType" id="editDiscountType" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                            <option value="Percentage">Percentage</option>
                            <option value="Fixed">Fixed</option>
                            <option value="Loyalty">Loyalty</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Value</label>
                        <input type="number" step="0.1" name="value" id="editValue" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" min="1" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Max Discount (Optional)</label>
                        <input type="number" step="0.1" name="maxDiscount" id="editMaxDiscount" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" min="1000">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Min Order Total</label>
                        <input type="number" step="0.1" name="minOrderTotal" id="editMinOrderTotal" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" min="0" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Start Date</label>
                        <input type="date" name="startDate" id="editStartDate" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">End Date (Optional)</label>
                        <input type="date" name="endDate" id="editEndDate" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                    </div>
                </div>
                <div class="flex justify-end space-x-3 mt-6">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-orange-500 text-white hover:bg-orange-600 rounded-lg transition-colors">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
            <div class="flex items-center mb-4">
                <div class="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center mr-3">
                    <i data-lucide="alert-triangle" class="w-5 h-5 text-red-600"></i>
                </div>
                <h2 class="text-lg font-bold text-gray-800">Confirm Delete</h2>
            </div>
            <div class="mb-6">
                <p id="deleteMessage" class="text-gray-700"></p>
            </div>
            <form id="deleteForm" action="${pageContext.request.contextPath}/discount" method="post">
                <input type="hidden" name="action" value="deactivate">
                <input type="hidden" name="discountId" id="deleteDiscountId">
                <input type="hidden" name="currentFilter" value="${param.filter != 'inactive' ? 'active' : 'inactive'}">
                <input type="hidden" name="currentPage" value="${currentPage}">
                <input type="hidden" name="currentType" value="${param.type}">
                <input type="hidden" name="currentStartDate" value="${param.startDate}">
                <input type="hidden" name="currentEndDate" value="${param.endDate}">
                <input type="hidden" name="currentSearch" value="${param.search}">
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closeDeleteModal()" 
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 bg-red-500 text-white hover:bg-red-600 rounded-lg transition-colors flex items-center">
                        <i data-lucide="trash-2" class="w-4 h-4 mr-2"></i>
                        Delete
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Initialize Lucide icons
        lucide.createIcons();

        // ===== MODAL CONTROL FUNCTIONS =====
        
        /**
         * Open import discounts modal
         */
        function openImportModal() {
            document.getElementById('importModal').classList.remove('hidden');
        }

        /**
         * Close import discounts modal
         */
        function closeImportModal() {
            document.getElementById('importModal').classList.add('hidden');
        }

        /**
         * Open add discount modal and set default dates
         */
        function openAddModal() {
            document.getElementById('addModal').classList.remove('hidden');
            setDefaultDates('addStartDate', 'addEndDate');
        }

        /**
         * Close add discount modal and reset error messages
         */
        function closeAddModal() {
            document.getElementById('addModal').classList.add('hidden');
            document.getElementById('addDescriptionError').classList.add('hidden');
        }

        /**
        * Open edit discount modal with pre-filled data
        */
        function openEditModal(id, description, type, value, maxDiscount, minOrderTotal, startDate, endDate) {
            document.getElementById('editDiscountId').value = id;
            document.getElementById('editDescription').value = description;
            document.getElementById('editDiscountType').value = type;
            document.getElementById('editValue').value = value;
            document.getElementById('editMaxDiscount').value = maxDiscount === 'null' ? '' : maxDiscount;
            document.getElementById('editMinOrderTotal').value = minOrderTotal;

            // Set start date constraints for edit - must be tomorrow or later
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const tomorrowStr = tomorrow.toISOString().split('T')[0];
            const startDateField = document.getElementById('editStartDate');
            startDateField.value = startDate; // Use original start date
            startDateField.min = tomorrowStr; // Cannot be before tomorrow

            // Set end date constraints - must be tomorrow or later if provided
            const endDateField = document.getElementById('editEndDate');
            endDateField.min = tomorrowStr;

            // If original end date exists, use it
            if (endDate && endDate !== '' && endDate !== 'null') {
                endDateField.value = endDate;
            } else {
                endDateField.value = '';
            }

            document.getElementById('editModal').classList.remove('hidden');
            document.getElementById('editDescriptionError').classList.add('hidden');
        }

        /**
         * Close edit discount modal
         */
        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }

        // ===== DELETE OPERATION FUNCTIONS =====

        /**
        * Show delete confirmation modal with discount ID and smart deletion info
        * @param {number} discountId - The ID of discount to delete
        * @param {string} startDate - The start date of the discount (YYYY-MM-DD format)
        */
        function confirmDelete(discountId, startDate) {
            const deleteMessage = document.getElementById('deleteMessage');
            const today = new Date().toISOString().split('T')[0];
            
            const isFutureDiscount = startDate > today;
            
            let messageText = 'Are you sure you want to delete discount with ID <strong>' + discountId + '</strong>?';
            
            if (isFutureDiscount) {
                messageText += `
                    <div class="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start">
                        <i data-lucide="alert-triangle" class="w-5 h-5 text-red-600 mr-2 mt-0.5 flex-shrink-0"></i>
                        <div>
                            <p class="text-red-800 font-medium text-sm">Immediate Permanent Delete</p>
                            <p class="text-red-600 text-xs mt-1">This discount hasn't started yet and will be permanently deleted immediately.</p>
                        </div>
                    </div>
                `;
            } else {
                messageText += `
                    <div class="mt-3 p-3 bg-orange-50 border border-orange-200 rounded-lg flex items-start">
                        <i data-lucide="clock" class="w-5 h-5 text-orange-600 mr-2 mt-0.5 flex-shrink-0"></i>
                        <div>
                            <p class="text-orange-800 font-medium text-sm">Scheduled Deactivation</p>
                            <p class="text-orange-600 text-xs mt-1">This discount will be deactivated at the end of today.</p>
                        </div>
                    </div>
                `;
            }
            
            deleteMessage.innerHTML = messageText;
            lucide.createIcons();
            document.getElementById('deleteDiscountId').value = discountId;
            document.getElementById('deleteModal').classList.remove('hidden');
        }

        /**
         * Close delete confirmation modal
         */
        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.add('hidden');
        }

        // ===== UTILITY FUNCTIONS =====
        
        /**
         * Set default dates for date fields
         * @param {string} startDateFieldId - The ID of start date input field
         */
        function setDefaultDates(startDateFieldId, endDateFieldId) {
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const tomorrowStr = tomorrow.toISOString().split('T')[0];
            
            // Set start date to tomorrow and set min to tomorrow
            const startDateField = document.getElementById(startDateFieldId);
            if (startDateField) {
                startDateField.value = tomorrowStr;
                startDateField.min = tomorrowStr;
            }

            // Set end date min to tomorrow
            const endDateField = document.getElementById(endDateFieldId);
            if (endDateField) {
                endDateField.min = tomorrowStr;
            }
        }

        /**
         * Apply filters and submit filter form
         */
        function applyFilters() {
            document.getElementById('filterForm').submit();
        }

        /**
         * Reset all filters to default values
         */
        function resetFilters() {
            document.querySelector('select[name="filter"]').value = 'active';
            document.querySelector('select[name="type"]').value = '';
            document.querySelector('input[name="startDate"]').value = '';
            document.querySelector('input[name="endDate"]').value = '';
            document.getElementById('filterForm').submit();
        }

        /**
         * Perform search operation
         */
        function performSearch() {
            const searchValue = document.querySelector('input[name="search"]').value;
            document.getElementById('searchInput').value = searchValue;
            document.querySelector('input[name="page"]').value = '1';
            document.getElementById('filterForm').submit();
        }

        /**
         * Handle enter key press in search input
         * @param {Event} event - Keyboard event
         */
        function handleSearchKeyPress(event) {
            if (event.key === 'Enter') {
                performSearch();
                event.preventDefault();
            }
        }

        /**
         * Download Excel template for discount import
         */
        function downloadTemplate() {
            window.location.href = '${pageContext.request.contextPath}/discount/import?action=template';
        }

        /**
         * Navigate to specific page in pagination
         * @param {number} page - Page number to navigate to
         */
        function goToPage(page) {
            const currentPage = parseInt('${currentPage}');
            const totalPages = parseInt('${totalPages}');

            if (page < 1 || page > totalPages || page === currentPage) {
                return;
            }

            const url = new URL(window.location.href);
            url.searchParams.set('page', page);
            window.location.href = url.toString();
        }

        // ===== FORM VALIDATION FUNCTIONS =====
        
        /**
         * Validate add discount form
         * @returns {boolean} - Validation result
         */
        function validateAddForm() {
            if (!validateDiscountForm('addStartDate', 'addEndDate')) {
                return false;
            }
            
            const description = document.getElementById('addDescription').value;
            return checkDuplicateDescription(description, 'addDescriptionError');
        }

        /**
        * Validate edit discount form
        * @returns {boolean} - Validation result
        */
        function validateEditForm() {
            if (!validateDiscountForm('editStartDate', 'editEndDate')) {
                return false;
            }
            
            const description = document.getElementById('editDescription').value;
            const discountId = document.getElementById('editDiscountId').value;
            
            // Show confirmation message for edit
            const today = new Date();
            const startDate = new Date(document.getElementById('editStartDate').value);
            const isFutureDiscount = startDate > today;
            
            if (isFutureDiscount) {
                // Future discount - immediate update
                const confirmed = confirm('This discount hasn\'t started yet. Changes will be applied immediately. Continue?');
                if (!confirmed) {
                    return false;
                }
            } else {
                // Should not reach here as edit button should be hidden for started discounts
                alert('Cannot edit discount that has already started.');
                return false;
            }
            
            return checkDuplicateDescription(description, 'editDescriptionError', discountId);
        }

        /**
        * Validate discount date fields
        * @param {string} startDateId - Start date field ID
        * @param {string} endDateId - End date field ID
        * @returns {boolean} - Validation result
        */
        function validateDiscountForm(startDateId, endDateId) {
            const startDate = document.getElementById(startDateId).value;
            const endDate = document.getElementById(endDateId).value;
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const tomorrowStr = tomorrow.toISOString().split('T')[0];
            
            // Start date must be tomorrow or later
            if (startDate < tomorrowStr) {
                alert('Start date must be tomorrow or later');
                return false;
            }

            if (endDate && endDate < startDate) {
                alert('End date cannot be before start date');
                return false;
            }

            return true;
        }

        /**
        * Check for duplicate discount descriptions using AJAX call to server
        * Note: This function returns true immediately and handles validation asynchronously
        * The actual validation result will be shown via the error element
        * 
        * @param {string} description - The discount description to check for duplicates
        * @param {string} errorElementId - The ID of the HTML element to show error messages
        * @param {number} excludeId - Discount ID to exclude from duplicate check (used for edit operations)
        * @returns {boolean} - Always returns true initially; validation happens asynchronously
        */
        function checkDuplicateDescription(description, errorElementId, excludeId = null) {
            // Hide any previous error messages
            document.getElementById(errorElementId).classList.add('hidden');
            
            // Build the URL for the duplicate check API endpoint
            let url = '${pageContext.request.contextPath}/discount/check-description?description=' + encodeURIComponent(description);
            if (excludeId) {
                url += '&excludeId=' + excludeId;
            }
            
            // Make asynchronous AJAX request to server for duplicate validation
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        // Show error message if duplicate description is found
                        document.getElementById(errorElementId).classList.remove('hidden');
                        // Note: This doesn't prevent form submission as it's asynchronous
                    }
                })
                .catch(error => {
                    console.error('Error checking duplicate description:', error);
                    // In case of error, allow the form to submit and let server handle validation
                });
            
            // Return true immediately to allow form submission
            // Server-side validation will handle the actual duplicate check
            return true;
        }

        // ===== INITIALIZATION =====
        
        /**
        * Initialize page when DOM is loaded
        */
        document.addEventListener('DOMContentLoaded', function () {
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const tomorrowStr = tomorrow.toISOString().split('T')[0];

            console.log(tomorrowStr);
            
            // Set add modal date constraints
            const addStartDate = document.getElementById('addStartDate');
            if (addStartDate) {
                addStartDate.value = tomorrowStr;
                addStartDate.min = tomorrowStr;
            }
            
            const addEndDate = document.getElementById('addEndDate');
            if (addEndDate) {
                addEndDate.min = tomorrowStr;
            }
            
            // Add description duplicate check
            const addDescription = document.getElementById('addDescription');
            if (addDescription) {
                addDescription.addEventListener('blur', function() {
                    checkDuplicateDescription(this.value, 'addDescriptionError');
                });
            }
            
            // Edit description duplicate check
            const editDescription = document.getElementById('editDescription');
            if (editDescription) {
                editDescription.addEventListener('blur', function() {
                    const discountId = document.getElementById('editDiscountId').value;
                    checkDuplicateDescription(this.value, 'editDescriptionError', discountId);
                });
            }
        });
    </script>
</body>
</html>