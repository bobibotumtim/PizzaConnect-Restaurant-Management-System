<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Discount Management</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest"></script>
    </head>
    <body class="flex h-screen bg-gray-50">
        <!-- Sidebar -->
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
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Header -->
            <div class="bg-white border-b px-6 py-4 flex justify-between items-center flex-shrink-0">
                <h1 class="text-2xl font-bold text-gray-800">Discount Management</h1>
                <button onclick="openAddModal()" class="tab-btn bg-orange-500 text-white">Add New Discount</button>
            </div>

            <!-- Content -->
            <div class="flex-1 p-4 overflow-auto">
                <div class="bg-white rounded-xl p-4 shadow-sm">
                    <h2 class="text-base font-bold text-gray-800 mb-4">Active Discounts</h2>
                    <table class="w-full text-sm text-left text-gray-500">
                        <thead class="text-xs text-gray-700 uppercase bg-gray-50">
                            <tr>
                                <th class="px-6 py-3">ID</th>
                                <th class="px-6 py-3">Description</th>
                                <th class="px-6 py-3">Type</th>
                                <th class="px-6 py-3">Value</th>
                                <th class="px-6 py-3">Max Discount</th>
                                <th class="px-6 py-3">Min Order</th>
                                <th class="px-6 py-3">Start Date</th>
                                <th class="px-6 py-3">End Date</th>
                                <th class="px-6 py-3">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="discount" items="${discounts}">
                                <tr class="bg-white border-b hover:bg-gray-50">
                                    <td class="px-6 py-4">${discount.discountId}</td>
                                    <td class="px-6 py-4">${discount.description}</td>
                                    <td class="px-6 py-4">${discount.discountType}</td>
                                    <td class="px-6 py-4">${discount.value}</td>
                                    <td class="px-6 py-4">${discount.maxDiscount != null ? discount.maxDiscount : 'N/A'}</td>
                                    <td class="px-6 py-4">${discount.minOrderTotal}</td>
                                    <td class="px-6 py-4">${discount.startDate}</td>
                                    <td class="px-6 py-4">${discount.endDate != null ? discount.endDate : 'N/A'}</td>
                                    <td class="px-6 py-4 flex space-x-2">
                                        <button onclick="openEditModal(${discount.discountId}, '${discount.description}', '${discount.discountType}', ${discount.value}, ${discount.maxDiscount != null ? discount.maxDiscount : 'null'}, ${discount.minOrderTotal}, '${discount.startDate}', '${discount.endDate != null ? discount.endDate : ''}')"
                                                class="text-blue-600 hover:text-blue-800">Edit</button>
                                        <form action="${pageContext.request.contextPath}/discount" method="post" onsubmit="return confirm('Are you sure you want to deactivate this discount?')">
                                            <input type="hidden" name="action" value="deactivate">
                                            <input type="hidden" name="discountId" value="${discount.discountId}">
                                            <button type="submit" class="text-red-600 hover:text-red-800">Deactivate</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Add Discount Modal -->
        <div id="addModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden">
            <div class="bg-white rounded-lg p-6 w-full max-w-md">
                <h2 class="text-lg font-bold mb-4">Add New Discount</h2>
                <form action="${pageContext.request.contextPath}/discount" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Description</label>
                        <input type="text" name="description" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Discount Type</label>
                        <select name="discountType" class="mt-1 p-2 w-full border rounded" required>
                            <option value="Percentage">Percentage</option>
                            <option value="Fixed">Fixed</option>
                            <option value="Loyalty">Loyalty</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Value</label>
                        <input type="number" step="0.01" name="value" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Max Discount (Optional)</label>
                        <input type="number" step="0.01" name="maxDiscount" class="mt-1 p-2 w-full border rounded">
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Min Order Total</label>
                        <input type="number" step="0.01" name="minOrderTotal" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Start Date</label>
                        <input type="date" name="startDate" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">End Date (Optional)</label>
                        <input type="date" name="endDate" class="mt-1 p-2 w-full border rounded">
                    </div>
                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeAddModal()" class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">Cancel</button>
                        <button type="submit" class="tab-btn bg-orange-500 text-white">Add Discount</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Edit Discount Modal -->
        <div id="editModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden">
            <div class="bg-white rounded-lg p-6 w-full max-w-md">
                <h2 class="text-lg font-bold mb-4">Edit Discount</h2>
                <form action="${pageContext.request.contextPath}/discount" method="post">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="discountId" id="editDiscountId">
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Description</label>
                        <input type="text" name="description" id="editDescription" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Discount Type</label>
                        <select name="discountType" id="editDiscountType" class="mt-1 p-2 w-full border rounded" required>
                            <option value="Percentage">Percentage</option>
                            <option value="Fixed">Fixed</option>
                            <option value="Loyalty">Loyalty</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Value</label>
                        <input type="number" step="0.01" name="value" id="editValue" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Max Discount (Optional)</label>
                        <input type="number" step="0.01" name="maxDiscount" id="editMaxDiscount" class="mt-1 p-2 w-full border rounded">
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Min Order Total</label>
                        <input type="number" step="0.01" name="minOrderTotal" id="editMinOrderTotal" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Start Date</label>
                        <input type="date" name="startDate" id="editStartDate" class="mt-1 p-2 w-full border rounded" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">End Date (Optional)</label>
                        <input type="date" name="endDate" id="editEndDate" class="mt-1 p-2 w-full border rounded">
                    </div>
                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeEditModal()" class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">Cancel</button>
                        <button type="submit" class="tab-btn bg-orange-500 text-white">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            lucide.createIcons();

            function openAddModal() {
                document.getElementById('addModal').classList.remove('hidden');
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
        </script>

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
                padding: 0.375rem 1rem;
                border-radius: 0.5rem;
                font-weight: 500;
                font-size: 0.875rem;
                transition: all 0.2s;
            }
            .nav-btn:hover {
                transform: translateY(-2px);
            }
        </style>
    </body>
</html>