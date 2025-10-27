<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        .tab-btn {
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .nav-btn:hover {
            transform: translateY(-2px);
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
    </style>
</head>
<body class="flex h-screen bg-gray-50">
    <!-- Sidebar -->
    <%
        String currentPath = request.getRequestURI();
    %>
    <div class="w-20 bg-gray-800 flex flex-col items-center py-6 space-y-8 flex-shrink-0">
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
            <a href="${pageContext.request.contextPath}/admin"
               class="nav-btn <%= currentPath.contains("/admin") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Manage Users">
                <i data-lucide="users" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/orders"
               class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Orders">
                <i data-lucide="file-text" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/menu"
               class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Menu">
                <i data-lucide="utensils" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/notifications"
               class="nav-btn <%= currentPath.contains("/notifications") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Notifications">
                <i data-lucide="bell" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/profile"
               class="nav-btn <%= currentPath.contains("/profile") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Profile">
                <i data-lucide="user" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/discount"
               class="nav-btn <%= currentPath.contains("/discount") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Discount Programs">
                <i data-lucide="percent" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/settings"
               class="nav-btn <%= currentPath.contains("/settings") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Settings">
                <i data-lucide="settings" class="w-6 h-6"></i>
            </a>
        </div>
        <a href="${pageContext.request.contextPath}/logout"
           class="nav-btn <%= currentPath.contains("/logout") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
           title="Logout">
            <i data-lucide="log-out" class="w-6 h-6"></i>
        </a>
    </div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col overflow-hidden min-w-0">
        <!-- Header and filter -->
        <div class="bg-white border-b px-6 py-4 flex-shrink-0">
            <div class="flex flex-col lg:flex-row lg:justify-between lg:items-center gap-4 header-container">
                <div class="flex items-center space-x-4">
                    <h1 class="text-2xl font-bold text-gray-800">Discount Management</h1>
                    <select id="filterSelect" onchange="changeFilter(this)" 
                            class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500">
                        <option value="active" ${param.filter != 'inactive' ? 'selected' : ''}>Active Discounts</option>
                        <option value="inactive" ${param.filter == 'inactive' ? 'selected' : ''}>Inactive Discounts</option>
                    </select>
                </div>
                <div class="header-buttons">
                    <!-- Download Template -->
                    <button onclick="downloadTemplate()" class="tab-btn bg-green-500 text-white hover:bg-green-600 transition-colors flex items-center">
                        <i data-lucide="download" class="w-4 h-4 mr-2"></i>
                        Download Template
                    </button>

                    <!-- Import Discounts -->
                    <button onclick="openImportModal()" 
                            class="tab-btn bg-blue-500 text-white hover:bg-blue-600 transition-colors flex items-center">
                        <i data-lucide="upload" class="w-4 h-4 mr-2"></i>
                        Import Discounts
                    </button>

                    <!-- Add New Discount -->
                    <button onclick="openAddModal()" class="tab-btn bg-orange-500 text-white hover:bg-orange-600 transition-colors flex items-center">
                        <i data-lucide="plus" class="w-4 h-4 mr-2"></i>
                        Add New Discount
                    </button>
                </div>
            </div>
        </div>

        <!-- Content -->
        <div class="flex-1 p-6 overflow-auto">
            <!-- Success Message -->
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

            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                        <span>${error}</span>
                    </div>
                </div>
            </c:if>

            <!-- Discount Cards Summary -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-600">Total Discounts</p>
                            <p class="text-2xl font-bold text-gray-800 mt-1">
                                <c:choose>
                                    <c:when test="${not empty totalDiscounts}">${totalDiscounts}</c:when>
                                    <c:otherwise>0</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="p-3 bg-blue-100 rounded-lg">
                            <i data-lucide="percent" class="w-6 h-6 text-blue-600"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-600">Active Discounts</p>
                            <p class="text-2xl font-bold text-green-600 mt-1">
                                <c:choose>
                                    <c:when test="${not empty activeDiscounts}">${activeDiscounts}</c:when>
                                    <c:otherwise>0</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="p-3 bg-green-100 rounded-lg">
                            <i data-lucide="check-circle" class="w-6 h-6 text-green-600"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-600">Inactive Discounts</p>
                            <p class="text-2xl font-bold text-gray-500 mt-1">
                                <c:choose>
                                    <c:when test="${not empty inactiveDiscounts}">${inactiveDiscounts}</c:when>
                                    <c:otherwise>0</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="p-3 bg-gray-100 rounded-lg">
                            <i data-lucide="x-circle" class="w-6 h-6 text-gray-500"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Discounts Table -->
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
                                                <button onclick="openEditModal(${discount.discountId}, '${discount.description}', '${discount.discountType}', ${discount.value}, ${discount.maxDiscount != null ? discount.maxDiscount : 'null'}, ${discount.minOrderTotal}, '${discount.startDate}', '${discount.endDate != null ? discount.endDate : ''}')"
                                                        class="text-blue-600 hover:text-blue-800 text-sm font-medium flex items-center p-2 rounded hover:bg-blue-50 transition-colors"
                                                        title="Edit Discount">
                                                    <i data-lucide="edit" class="w-4 h-4"></i>
                                                </button>
                                                <form action="${pageContext.request.contextPath}/discount" method="post" onsubmit="return confirm('Are you sure you want to deactivate this discount?')" class="inline">
                                                    <input type="hidden" name="action" value="deactivate">
                                                    <input type="hidden" name="discountId" value="${discount.discountId}">
                                                    <input type="hidden" name="currentFilter" value="${param.filter != 'inactive' ? 'active' : 'inactive'}">
                                                    <input type="hidden" name="currentPage" value="${currentPage}">
                                                    <button type="submit" class="text-red-600 hover:text-red-800 text-sm font-medium flex items-center p-2 rounded hover:bg-red-50 transition-colors"
                                                            title="Delete Discount">
                                                        <i data-lucide="trash-2" class="w-4 h-4"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
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
            </div>
        </div>
    </div>

    <!-- Import Modal -->
    <div id="importModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded-lg p-6 w-full max-w-2xl mx-4">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-800">Import Discounts</h2>
                <button onclick="closeImportModal()" class="text-gray-400 hover:text-gray-600">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <!-- Simple Form -->
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
                <button onclick="closeAddModal()" class="text-gray-400 hover:text-gray-600">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/discount" method="post" onsubmit="return validateAddForm()">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="currentFilter" value="${param.filter != 'inactive' ? 'active' : 'inactive'}">
                <input type="hidden" name="currentPage" value="${currentPage}">
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <input type="text" name="description" id="addDescription" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
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
                        <input type="number" step="0.01" name="value" id="addValue" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Max Discount (Optional)</label>
                        <input type="number" step="0.01" name="maxDiscount" id="addMaxDiscount" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Min Order Total</label>
                        <input type="number" step="0.01" name="minOrderTotal" id="addMinOrderTotal" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
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
                <button onclick="closeEditModal()" class="text-gray-400 hover:text-gray-600">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/discount" method="post" onsubmit="return validateEditForm()">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="discountId" id="editDiscountId">
                <input type="hidden" name="currentFilter" value="${param.filter != 'inactive' ? 'active' : 'inactive'}">
                <input type="hidden" name="currentPage" value="${currentPage}">

                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <input type="text" name="description" id="editDescription" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
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
                        <input type="number" step="0.01" name="value" id="editValue" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Max Discount (Optional)</label>
                        <input type="number" step="0.01" name="maxDiscount" id="editMaxDiscount" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Min Order Total</label>
                        <input type="number" step="0.01" name="minOrderTotal" id="editMinOrderTotal" class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500" required>
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

    <script>
        // Initialize Lucide icons
        lucide.createIcons();

        // Modal functions
        function openImportModal() {
            document.getElementById('importModal').classList.remove('hidden');
        }

        function closeImportModal() {
            document.getElementById('importModal').classList.add('hidden');
        }

        function openAddModal() {
            document.getElementById('addModal').classList.remove('hidden');
            setDefaultDates('addStartDate');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.add('hidden');
        }

        function openEditModal(id, description, type, value, maxDiscount, minOrderTotal, startDate, endDate) {
            document.getElementById('editDiscountId').value = id;
            document.getElementById('editDescription').value = description;
            document.getElementById('editDiscountType').value = type;
            document.getElementById('editValue').value = value;
            document.getElementById('editMaxDiscount').value = maxDiscount === 'null' ? '' : maxDiscount;
            document.getElementById('editMinOrderTotal').value = minOrderTotal;
            document.getElementById('editStartDate').value = startDate;
            document.getElementById('editEndDate').value = endDate === '' ? '' : endDate;
            document.getElementById('editModal').classList.remove('hidden');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }

        function setDefaultDates(dateFieldId) {
            const today = new Date().toISOString().split('T')[0];
            const dateField = document.getElementById(dateFieldId);
            if (dateField) {
                dateField.value = today;
                dateField.min = today;
            }
        }

        // Utility functions
        function changeFilter(selectElement) {
            const filter = selectElement.value;
            const url = new URL(window.location.href);
            url.searchParams.set('filter', filter);
            url.searchParams.set('page', '1');
            window.location.href = url.toString();
        }

        function downloadTemplate() {
            window.location.href = '${pageContext.request.contextPath}/discount/import?action=template';
        }

        function validateAddForm() {
            return validateDiscountForm('addStartDate', 'addEndDate');
        }

        function validateEditForm() {
            return validateDiscountForm('editStartDate', 'editEndDate');
        }

        function validateDiscountForm(startDateId, endDateId) {
            const startDate = document.getElementById(startDateId).value;
            const endDate = document.getElementById(endDateId).value;
            const today = new Date().toISOString().split('T')[0];

            if (startDate < today) {
                alert('Start date cannot be in the past');
                return false;
            }

            if (endDate && endDate < startDate) {
                alert('End date cannot be before start date');
                return false;
            }

            return true;
        }

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

        // Initialize
        document.addEventListener('DOMContentLoaded', function () {
            // Set default date for add modal
            const today = new Date().toISOString().split('T')[0];
            const addStartDate = document.getElementById('addStartDate');
            if (addStartDate) {
                addStartDate.value = today;
                addStartDate.min = today;
            }
        });
    </script>
</body>
</html>