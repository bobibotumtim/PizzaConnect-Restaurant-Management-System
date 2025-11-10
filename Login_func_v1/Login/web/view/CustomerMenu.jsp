<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="models.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Map<String, Map<Product, List<ProductSize>>> productsByCategory = 
        (Map<String, Map<Product, List<ProductSize>>>) request.getAttribute("productsByCategory");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    
    // Format currency
    NumberFormat currencyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .product-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }
        
        .size-badge {
            transition: all 0.3s;
        }
        
        .size-badge:hover {
            transform: scale(1.05);
        }
    </style>
</head>
<body class="bg-gray-50">
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>
    <%@ include file="ChatBotWidget.jsp" %>
    
    <div class="content-wrapper">
        <div class="max-w-7xl mx-auto px-6 py-8">
            
            <!-- Header -->
            <div class="mb-8">
                <h1 class="text-4xl font-bold text-gray-800 mb-2">Our Menu</h1>
                <p class="text-gray-600">Discover our delicious selection of pizzas, drinks, and more!</p>
            </div>
            
            <!-- Category Filter -->
            <div class="mb-8 bg-white rounded-xl shadow-md p-6">
                <h3 class="text-lg font-semibold text-gray-800 mb-4">Filter by Category</h3>
                <div class="flex flex-wrap gap-3">
                    <a href="customer-menu" 
                       class="px-6 py-2 rounded-lg font-medium transition-all <%= (selectedCategory == null || selectedCategory.equals("all")) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                        All
                    </a>
                    <% if (categories != null) {
                        for (Category category : categories) { %>
                    <a href="customer-menu?category=<%= category.getCategoryName() %>" 
                       class="px-6 py-2 rounded-lg font-medium transition-all <%= (selectedCategory != null && selectedCategory.equals(category.getCategoryName())) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                        <%= category.getCategoryName() %>
                    </a>
                    <% }
                    } %>
                </div>
            </div>
            
            <!-- Products by Category -->
            <% if (productsByCategory != null && !productsByCategory.isEmpty()) {
                for (Map.Entry<String, Map<Product, List<ProductSize>>> categoryEntry : productsByCategory.entrySet()) {
                    String category = categoryEntry.getKey();
                    Map<Product, List<ProductSize>> products = categoryEntry.getValue();
            %>
            <div class="mb-12">
                <h2 class="text-3xl font-bold text-gray-800 mb-6 flex items-center">
                    <span class="bg-orange-500 text-white px-4 py-2 rounded-lg mr-3">
                        <%= category %>
                    </span>
                    <span class="text-gray-400 text-xl">(<%= products.size() %> items)</span>
                </h2>
                
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <% for (Map.Entry<Product, List<ProductSize>> productEntry : products.entrySet()) {
                        Product product = productEntry.getKey();
                        List<ProductSize> sizes = productEntry.getValue();
                    %>
                    <div class="product-card bg-white rounded-xl shadow-md overflow-hidden">
                        <!-- Product Image -->
                        <div class="h-48 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center relative">
                            <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                <img src="<%= product.getImageUrl() %>" alt="<%= product.getProductName() %>" 
                                     class="w-full h-full object-cover">
                            <% } else { %>
                                <span class="text-6xl">🍕</span>
                            <% } %>
                            <% if (product.isAvailable()) { %>
                                <span class="absolute top-3 right-3 bg-green-500 text-white text-xs px-3 py-1 rounded-full font-semibold">
                                    Available
                                </span>
                            <% } else { %>
                                <span class="absolute top-3 right-3 bg-red-500 text-white text-xs px-3 py-1 rounded-full font-semibold">
                                    Unavailable
                                </span>
                            <% } %>
                        </div>
                        
                        <!-- Product Info -->
                        <div class="p-6">
                            <div class="text-sm text-orange-600 font-semibold mb-2">
                                <%= product.getCategoryName() %>
                            </div>
                            <h3 class="text-xl font-bold text-gray-800 mb-2">
                                <%= product.getProductName() %>
                            </h3>
                            <p class="text-gray-600 text-sm mb-4">
                                <%= product.getDescription() != null ? product.getDescription() : "Delicious and fresh" %>
                            </p>
                            
                            <!-- Sizes and Prices -->
                            <div class="mb-4">
                                <h4 class="text-sm font-semibold text-gray-700 mb-2">Available Sizes:</h4>
                                <div class="flex flex-wrap gap-2">
                                    <% for (ProductSize size : sizes) { 
                                        String sizeLabel = "";
                                        String sizeColor = "";
                                        switch(size.getSizeCode()) {
                                            case "S": sizeLabel = "Small"; sizeColor = "bg-blue-100 text-blue-700"; break;
                                            case "M": sizeLabel = "Medium"; sizeColor = "bg-green-100 text-green-700"; break;
                                            case "L": sizeLabel = "Large"; sizeColor = "bg-purple-100 text-purple-700"; break;
                                            case "F": sizeLabel = "Fixed"; sizeColor = "bg-gray-100 text-gray-700"; break;
                                            default: sizeLabel = size.getSizeCode(); sizeColor = "bg-gray-100 text-gray-700";
                                        }
                                    %>
                                    <div class="size-badge <%= sizeColor %> px-3 py-1 rounded-lg text-sm font-semibold">
                                        <%= sizeLabel %>: <%= currencyFormat.format(size.getPrice()) %>₫
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            
                            <!-- Price Range -->
                            <div class="flex items-center justify-between pt-4 border-t border-gray-200">
                                <% 
                                    // Calculate min/max price without Stream API
                                    double minPrice = Double.MAX_VALUE;
                                    double maxPrice = Double.MIN_VALUE;
                                    for (ProductSize size : sizes) {
                                        if (size.getPrice() < minPrice) minPrice = size.getPrice();
                                        if (size.getPrice() > maxPrice) maxPrice = size.getPrice();
                                    }
                                    if (minPrice == Double.MAX_VALUE) minPrice = 0;
                                    if (maxPrice == Double.MIN_VALUE) maxPrice = 0;
                                %>
                                <div>
                                    <span class="text-sm text-gray-500">From</span>
                                    <span class="text-2xl font-bold text-orange-600">
                                        <%= currencyFormat.format(minPrice) %>₫
                                    </span>
                                </div>
                                <button class="bg-orange-500 text-white px-6 py-2 rounded-lg hover:bg-orange-600 transition-all font-semibold">
                                    Order
                                </button>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% }
            } else { %>
            <!-- No Products Found -->
            <div class="text-center py-16">
                <div class="text-6xl mb-4">🍕</div>
                <h3 class="text-2xl font-bold text-gray-800 mb-2">No products found</h3>
                <p class="text-gray-600 mb-6">Try selecting a different category</p>
                <a href="customer-menu" class="bg-orange-500 text-white px-6 py-3 rounded-lg hover:bg-orange-600 transition-all font-semibold">
                    View All Products
                </a>
            </div>
            <% } %>
            
        </div>
    </div>
    
    <script>
        // Initialize Lucide icons
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
    </script>
</body>
</html>
