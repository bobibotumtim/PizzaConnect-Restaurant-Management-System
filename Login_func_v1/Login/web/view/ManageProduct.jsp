<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Products - PizzaConnect</title>
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
        .nav-btn:hover { transform: translateY(-2px); }
    </style>
</head>
<body class="flex h-screen bg-gray-50">

<%
    String currentPath = request.getRequestURI();
    User currentUser = (User) request.getAttribute("currentUser");

    // Mock product data (tạm thời)
    class ProductMock {
        int id;
        String name;
        String category;
        double price;
        int stock;
        int status;
        ProductMock(int id, String name, String category, double price, int stock, int status) {
            this.id = id; this.name = name; this.category = category; this.price = price; this.stock = stock; this.status = status;
        }
    }
    List<ProductMock> products = new ArrayList<>();
    products.add(new ProductMock(1, "Pepperoni Pizza", "Pizza", 12.99, 25, 1));
    products.add(new ProductMock(2, "Cheese Pizza", "Pizza", 10.50, 0, 0));
    products.add(new ProductMock(3, "Coca-Cola", "Drink", 2.00, 50, 1));
    products.add(new ProductMock(4, "Garlic Bread", "Side Dish", 5.50, 15, 1));
%>

<!-- Sidebar -->
<div class="w-20 bg-gray-800 flex flex-col items-center py-6 justify-between">
    <div class="flex flex-col items-center space-y-6">
        <!-- Logo -->
        <a href="${pageContext.request.contextPath}/dashboard"
           class="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-lg">
            <i data-lucide="pizza" class="w-7 h-7 text-white"></i>
        </a>

        <!-- Navigation -->
        <div class="flex flex-col items-center space-y-4 mt-8">
            <a href="${pageContext.request.contextPath}/dashboard"
               class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Dashboard">
                <i data-lucide="grid" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/manage-products"
               class="nav-btn <%= currentPath.contains("/manage-products") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Products">
                <i data-lucide="box" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/manage-orders"
               class="nav-btn <%= currentPath.contains("/manage-orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Orders">
                <i data-lucide="file-text" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/manage-customers"
               class="nav-btn text-gray-400 hover:bg-gray-700" title="Customers">
                <i data-lucide="users" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/reports"
               class="nav-btn text-gray-400 hover:bg-gray-700" title="Reports">
                <i data-lucide="bar-chart-2" class="w-6 h-6"></i>
            </a>
        </div>
    </div>

    <!-- Footer (User Avatar + Logout) -->
    <div class="flex flex-col items-center space-y-4">
        <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center">
            <i data-lucide="user" class="w-5 h-5 text-gray-200"></i>
        </div>
        <a href="${pageContext.request.contextPath}/logout"
           class="nav-btn text-gray-400 hover:bg-red-500 hover:text-white" title="Logout">
            <i data-lucide="log-out" class="w-6 h-6"></i>
        </a>
    </div>
</div>

<!-- Main Content -->
<div class="flex-1 flex flex-col overflow-hidden">
    <!-- Header -->
    <div class="bg-white border-b px-6 py-4 flex justify-between items-center">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">Manage Products</h1>
            <p class="text-sm text-gray-500">PizzaConnect Restaurant Management System</p>
        </div>
        <div class="text-gray-600">
            Welcome, <strong><%= currentUser != null ? currentUser.getName() : "Admin" %></strong>
        </div>
    </div>

    <!-- Content -->
    <div class="flex-1 p-6 overflow-auto">
        <div class="bg-gray-50 p-4 rounded-xl mb-6 flex flex-wrap gap-4 items-center">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Filter by Status</label>
                <select class="border border-gray-300 rounded-lg px-3 py-2">
                    <option>All Products</option>
                    <option>Active</option>
                    <option>Inactive</option>
                </select>
            </div>
            <div class="flex gap-2">
                <a href="#" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg">Refresh</a>
                <a href="#" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg">Add Product</a>
                <a href="dashboard" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg">Dashboard</a>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="bg-gray-800 text-white text-lg font-semibold px-6 py-3">📦 Product Management</div>

            <table class="min-w-full border-t">
                <thead class="bg-gray-100">
                <tr>
                    <th class="px-4 py-2 text-left">Product ID</th>
                    <th class="px-4 py-2 text-left">Name</th>
                    <th class="px-4 py-2 text-left">Category</th>
                    <th class="px-4 py-2 text-left">Price</th>
                    <th class="px-4 py-2 text-left">Stock</th>
                    <th class="px-4 py-2 text-left">Status</th>
                    <th class="px-4 py-2 text-left">Actions</th>
                </tr>
                </thead>
                <tbody class="divide-y">
                <% for (ProductMock p : products) { %>
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-2 font-semibold">#<%= p.id %></td>
                        <td class="px-4 py-2"><%= p.name %></td>
                        <td class="px-4 py-2"><%= p.category %></td>
                        <td class="px-4 py-2 font-semibold">$<%= String.format("%.2f", p.price) %></td>
                        <td class="px-4 py-2"><%= p.stock %></td>
                        <td class="px-4 py-2">
                            <%
                                String statusClass = p.status == 1 ? "bg-green-500" : "bg-gray-400";
                                String statusText = p.status == 1 ? "Active" : "Inactive";
                            %>
                            <span class="px-3 py-1 text-white rounded-full text-xs font-semibold <%= statusClass %>">
                                <%= statusText %>
                            </span>
                        </td>
                        <td class="px-4 py-2">
                            <div class="flex flex-wrap gap-2">
                                <a href="#" class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1 rounded text-xs">Edit</a>
                                <a href="#" class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs">Delete</a>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
