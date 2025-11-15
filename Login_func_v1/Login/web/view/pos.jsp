<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🍕 PIZZA POS - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 50;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }
        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .fade-in {
            animation: fadeIn 0.3s;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="h-screen bg-gray-100 flex overflow-hidden">
    <% 
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("Login");
            return;
        }
    %>

    <!-- Sidebar -->
    <jsp:include page="Sidebar.jsp" />

    <div class="flex flex-col flex-1 overflow-hidden" style="margin-left: 80px;">
        <!-- Header - ✅ Màu cam đồng nhất -->
        <div class="bg-white shadow-md border-b px-6 py-3 flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="text-2xl font-bold text-orange-600">🍕 PIZZA POS</div>
                <div id="selectedTableDisplay" class="px-4 py-2 bg-orange-100 text-orange-800 rounded-lg font-semibold">
                    No table selected
                </div>
                <div class="relative">
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                    <input type="text" id="searchInput" placeholder="Search items..." 
                           class="pl-10 pr-4 py-2 border border-orange-300 rounded-lg w-80 focus:outline-none focus:ring-2 focus:ring-orange-500">
                </div>
            </div>
            <div class="flex items-center gap-3">
                <div class="text-right">
                    <div class="font-semibold text-gray-800"><%= user.getName() %></div>
                    <div class="text-xs text-gray-500"><%= user.getRole() == 1 ? "Admin" : "Employee" %></div>
                </div>
                <a href="logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 shadow-sm hover:shadow-md transition-all duration-200">
                    🚪 Logout
                </a>
            </div>
        </div>

        <div class="flex flex-1 overflow-hidden">
        <!-- LEFT PANEL - Table Selection -->
        <div class="w-64 bg-white border-r shadow-sm flex flex-col">
            <!-- Header - Đồng nhất với Cart -->
            <div class="p-4 border-b bg-gradient-to-r from-orange-500 to-orange-600 text-white">
                <h3 class="font-bold text-lg mb-2">Table Management</h3>
                <input type="text" id="tableSearch" placeholder="Search table..." 
                       class="w-full px-3 py-2 rounded-lg text-gray-800 text-sm focus:outline-none focus:ring-2 focus:ring-orange-300 border-0 shadow-sm">
            </div>
            
            <!-- Table Grid - Consistent padding -->
            <div class="flex-1 overflow-y-auto p-3">
                <div id="tableGrid" class="grid grid-cols-2 gap-2">
                    <!-- Tables will be loaded here -->
                    <div class="text-center text-gray-400 col-span-2 py-8">
                        <div class="text-3xl mb-2">🪑</div>
                        <div class="text-sm">Loading tables...</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- MIDDLE PANEL - Products -->
        <div class="flex-1 flex flex-col bg-white">
            <!-- Category Tabs - Flush edges, no extra padding -->
            <div id="categoryTabs" class="flex border-b bg-orange-50">
                <!-- Categories will be loaded here dynamically -->
                <div class="flex-1 text-center py-4 text-orange-400 text-sm">
                    <div class="animate-pulse">Loading categories...</div>
                </div>
            </div>

            <!-- Product Grid -->
            <div class="flex-1 overflow-y-auto p-4">
                <div id="productGrid" class="grid grid-cols-3 gap-3">
                    <!-- Products will be loaded here -->
                </div>
            </div>
        </div>

        <!-- Right Panel - Cart -->
        <div class="w-96 bg-white border-l shadow-sm flex flex-col">
            <!-- Cart Header - Đồng nhất với Table -->
            <div class="p-4 border-b bg-gradient-to-r from-orange-500 to-orange-600 text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-1.5 6M7 13l-1.5-6m0 0h15M17 21a2 2 0 100-4 2 2 0 000 4zM9 21a2 2 0 100-4 2 2 0 000 4z"/>
                    </svg>
                    Cart Items
                </h3>
            </div>

            <!-- Cart Items - Consistent padding -->
            <div class="flex-1 overflow-y-auto p-4">
                <div id="cartContainer">
                    <div id="emptyCart" class="flex flex-col items-center justify-center h-full text-gray-400">
                        <svg width="48" height="48" class="mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-1.5 6M7 13l-1.5-6m0 0h15M17 21a2 2 0 100-4 2 2 0 000 4zM9 21a2 2 0 100-4 2 2 0 000 4z"/>
                        </svg>
                        <p class="text-sm">No items in cart</p>
                    </div>
                    <div id="cartItems" class="space-y-3 hidden">
                        <!-- Cart items will be added here -->
                    </div>
                </div>
            </div>

            <!-- Summary - Consistent styling -->
            <div class="border-t bg-gray-50 p-4 space-y-3">
                <!-- Totals -->
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between text-gray-600">
                        <span>Subtotal:</span>
                        <span id="subtotalAmount" class="font-semibold">0đ</span>
                    </div>
                    <div class="flex justify-between text-gray-600">
                        <span>Tax (10%):</span>
                        <span id="taxAmount" class="font-semibold">0đ</span>
                    </div>
                    <div class="flex justify-between text-lg font-bold text-gray-800 pt-2 border-t">
                        <span>Total:</span>
                        <span id="totalAmount" class="text-orange-600">0đ</span>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="grid grid-cols-2 gap-2 pt-2">
                    <button onclick="clearOrder()" id="clearBtn" disabled
                            class="py-3 px-4 bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold rounded-lg transition-all duration-200 shadow-sm hover:shadow-md disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                        </svg>
                        Clear
                    </button>
                    <button onclick="completeOrder()" id="orderBtn" disabled
                            class="py-3 px-4 bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-bold rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                        </svg>
                        Order
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Size Selection Modal -->
    <div id="sizeModal" class="modal">
        <div class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full p-6 m-4 fade-in">
            <div class="flex justify-between items-center mb-4">
                <h2 id="modalTitle" class="text-2xl font-bold text-gray-800">Select Size</h2>
                <button onclick="closeSizeModal()" class="text-gray-500 hover:text-gray-700">
                    <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>

            <!-- Size Selection -->
            <div class="mb-6">
                <div class="text-lg font-semibold mb-3">Choose Size:</div>
                <div id="sizeGrid" class="grid grid-cols-2 gap-3">
                    <!-- Sizes will be loaded here -->
                </div>
            </div>

            <!-- Toppings (for Pizza only) -->
            <div id="toppingsSection" class="mb-6 hidden">
                <div class="text-lg font-semibold mb-3">Add Toppings (Optional):</div>
                <div id="toppingGrid" class="grid grid-cols-3 gap-3 max-h-48 overflow-y-auto">
                    <!-- Toppings will be loaded here -->
                </div>
                <div class="mt-3 p-3 bg-blue-50 rounded-lg">
                    <div class="text-sm text-gray-600 mb-1">Selected toppings:</div>
                    <div id="selectedToppings" class="font-semibold text-gray-800">No toppings selected</div>
                </div>
            </div>

            <div class="flex gap-3">
                <button onclick="closeSizeModal()" 
                        class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-3 px-4 rounded-lg transition-all">
                    Cancel
                </button>
                <button onclick="confirmSelection()" id="confirmBtn" disabled
                        class="flex-1 bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-bold py-3 px-4 rounded-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed">
                    Add to Cart
                </button>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let cart = [];
        let products = {};
        let toppings = [];
        let tables = [];
        let categories = []; // ✅ MỚI: Store categories from database
        let selectedCategory = null; // ✅ SỬA: Will be set after loading categories
        let selectedProduct = null;
        let selectedSize = null;
        let selectedToppings = [];
        let selectedTable = null;
        let orderCounter = 1;
        let editOrderId = null; // For editing existing order
        let existingOrder = null; // Store existing order data

        // Initialize
        document.addEventListener('DOMContentLoaded', async function() {
            // Check if we're in edit mode
            const urlParams = new URLSearchParams(window.location.search);
            const orderIdParam = urlParams.get('orderId');
            
            if (orderIdParam) {
                editOrderId = parseInt(orderIdParam);
                console.log('📝 EDIT MODE: Loading Order #' + editOrderId);
                await loadExistingOrder(editOrderId);
            } else {
                console.log('🆕 CREATE MODE: New order');
                await loadTables();
            }
            
            // ✅ MỚI: Load categories first
            await loadCategories();
            await loadSampleProducts();
            loadSampleToppings();
            setupEventListeners();
            
            // ✅ SỬA: Select first category after loading
            if (categories.length > 0) {
                selectCategory(categories[0].categoryName);
            }
        });

        function setupEventListeners() {
            document.getElementById('searchInput').addEventListener('input', filterProducts);
            document.getElementById('tableSearch').addEventListener('input', filterTables);
        }

        // ✅ MỚI: Load categories from database
        async function loadCategories() {
            try {
                console.log('🔄 Loading categories from database...');
                const response = await fetch('pos?action=getCategories');
                const data = await response.json();
                
                if (data.success) {
                    categories = data.categories;
                    console.log('✅ Categories loaded:', categories);
                    displayCategoryTabs(categories);
                } else {
                    console.error('❌ Failed to load categories:', data.message);
                    showCategoryError();
                }
            } catch (error) {
                console.error('❌ Error loading categories:', error);
                showCategoryError();
            }
        }

        // ✅ CHUẨN: Display category tabs với CSS professional
        function displayCategoryTabs(categoriesToDisplay) {
            const tabsContainer = document.getElementById('categoryTabs');
            
            if (!categoriesToDisplay || categoriesToDisplay.length === 0) {
                tabsContainer.innerHTML = '<div class="flex-1 text-center py-4 text-orange-400 text-sm animate-pulse">No categories available</div>';
                return;
            }
            
            // Icon mapping for categories
            const categoryIcons = {
                'Pizza': '🍕',
                'Appetizer': '🥗',
                'Drink': '🥤',
                'Beverages': '🥤',
                'SideDish': '🍟',
                'Side Dishes': '🍟',
                'Sides': '🍟',
                'Dessert': '🍰'
            };
            
            tabsContainer.innerHTML = categoriesToDisplay.map((category, index) => {
                const icon = categoryIcons[category.categoryName] || '🍽️';
                const isFirst = index === 0;
                // ✅ CHUẨN: border-b-4 (dày hơn), shadow-md (rõ hơn)
                const activeClass = isFirst ? 
                    'bg-white text-orange-600 border-b-4 border-orange-600 shadow-md' : 
                    'text-gray-600 hover:bg-orange-50 hover:text-orange-600 hover:shadow-sm';
                
                return '<button onclick="selectCategory(\'' + category.categoryName + '\')" ' +
                       'class="category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all duration-200 ' + activeClass + '" ' +
                       'data-category="' + category.categoryName + '">' +
                       '<div class="flex flex-col items-center gap-1">' +
                       '<span class="text-2xl">' + icon + '</span>' +
                       '<span>' + category.categoryName.toUpperCase() + '</span>' +
                       '</div>' +
                       '</button>';
            }).join('');
        }

        // ✅ MỚI: Show category error
        function showCategoryError() {
            const tabsContainer = document.getElementById('categoryTabs');
            tabsContainer.innerHTML = '<div class="flex-1 text-center py-4 text-red-400 text-sm">' +
                                     '⚠️ Error loading categories' +
                                     '<button onclick="loadCategories()" class="ml-2 px-3 py-1 bg-orange-500 text-white rounded-lg text-xs hover:bg-orange-600">Retry</button>' +
                                     '</div>';
        }

        // Load tables from database
        async function loadTables() {
            try {
                console.log('🔄 Loading tables from database...');
                const response = await fetch('pos?action=getTables');
                const data = await response.json();
                
                if (data.success) {
                    tables = data.tables;
                    console.log('✅ Tables loaded:', tables);
                    displayTables(tables);
                } else {
                    console.error('❌ Failed to load tables:', data.message);
                    showTableError();
                }
            } catch (error) {
                console.error('❌ Error loading tables:', error);
                showTableError();
            }
        }

        // Display tables
        function displayTables(tablesToDisplay) {
            const grid = document.getElementById('tableGrid');
            
            if (!tablesToDisplay || tablesToDisplay.length === 0) {
                grid.innerHTML = '<div class="text-center text-gray-400 col-span-2 py-8">' +
                                '<div class="text-3xl mb-2">🪑</div>' +
                                '<div class="text-sm">No tables</div>' +
                                '</div>';
                return;
            }
            
            grid.innerHTML = tablesToDisplay.map(table => {
                const isAvailable = table.status === 'available';
                const bgColor = isAvailable ? 'bg-green-100 hover:bg-green-200 border-green-300' : 'bg-red-100 border-red-300';
                const textColor = isAvailable ? 'text-green-800' : 'text-red-800';
                const statusText = isAvailable ? 'Available' : 'Occupied';
                const cursorClass = isAvailable ? 'cursor-pointer' : 'cursor-not-allowed opacity-60';
                
                return '<button onclick="' + (isAvailable ? 'selectTable(' + table.tableID + ')' : 'void(0)') + '" ' +
                        'class="table-btn p-3 rounded-lg border-2 transition-all ' + bgColor + ' ' + textColor + ' ' + cursorClass + '" ' +
                        'data-table-id="' + table.tableID + '" ' +
                        'data-table-number="' + table.tableNumber + '" ' +
                        (isAvailable ? '' : 'disabled') + '>' +
                    '<div class="font-bold text-lg">' + table.tableNumber + '</div>' +
                    '<div class="text-xs">👥 ' + table.capacity + '</div>' +
                    '<div class="text-xs font-semibold mt-1">' + statusText + '</div>' +
                '</button>';
            }).join('');
        }

        // Filter tables
        function filterTables() {
            const searchTerm = document.getElementById('tableSearch').value.toLowerCase();
            const filteredTables = tables.filter(table =>
                table.tableNumber.toLowerCase().includes(searchTerm)
            );
            displayTables(filteredTables);
        }

        // Select table - ✅ Màu cam đồng nhất
        function selectTable(tableId) {
            const table = tables.find(t => t.tableID === tableId);
            if (!table || table.status !== 'available') {
                alert('⚠️ This table is not available!');
                return;
            }
            
            selectedTable = tableId;
            
            // Update UI - highlight selected table với màu cam
            document.querySelectorAll('.table-btn').forEach(btn => {
                if (btn.dataset.tableId == tableId) {
                    btn.classList.add('ring-4', 'ring-orange-500');
                } else {
                    btn.classList.remove('ring-4', 'ring-orange-500');
                }
            });
            
            // Update header display với màu cam
            document.getElementById('selectedTableDisplay').textContent = 'Table ' + table.tableNumber;
            document.getElementById('selectedTableDisplay').classList.remove('bg-orange-100', 'text-orange-800');
            document.getElementById('selectedTableDisplay').classList.add('bg-orange-600', 'text-white', 'shadow-sm');
            
            console.log('✅ Selected table:', table.tableNumber, '(ID:', tableId + ')');
        }

        // Show table error
        function showTableError() {
            const grid = document.getElementById('tableGrid');
            grid.innerHTML = '<div class="text-center text-red-400 col-span-2 py-8">' +
                            '<div class="text-3xl mb-2">⚠️</div>' +
                            '<div class="text-sm">Error loading tables</div>' +
                            '<button onclick="loadTables()" class="mt-2 px-3 py-1 bg-orange-500 text-white rounded-lg text-xs hover:bg-orange-600">Retry</button>' +
                            '</div>';
        }

        // ✅ SỬA: Select category (không dùng categoryMap cố định) - Màu cam đồng nhất
        function selectCategory(category) {
            // Sử dụng category name trực tiếp từ database
            selectedCategory = category;
            
            console.log('📂 Selected category:', selectedCategory);
            
            // ✅ CHUẨN: Update tab styles với border-b-4 và shadow-md
            document.querySelectorAll('.category-tab').forEach(tab => {
                if (tab.dataset.category === category) {
                    tab.className = 'category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all duration-200 bg-white text-orange-600 border-b-4 border-orange-600 shadow-md';
                } else {
                    tab.className = 'category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all duration-200 text-gray-600 hover:bg-orange-50 hover:text-orange-600 hover:shadow-sm';
                }
            });
            
            displayProducts();
        }

        // Load existing order for editing
        async function loadExistingOrder(orderId) {
            try {
                console.log('🔄 Loading existing order #' + orderId);
                const response = await fetch('pos?action=getOrder&orderId=' + orderId);
                const data = await response.json();
                
                if (data.success) {
                    existingOrder = data.order;
                    console.log('✅ Order loaded:', existingOrder);
                    console.log('✅ Order TableID:', existingOrder.tableID);
                    
                    // Hide table selection panel
                    const tablePanel = document.querySelector('.w-64.bg-white.border-r');
                    if (tablePanel) {
                        tablePanel.style.display = 'none';
                        console.log('✅ Table panel hidden');
                    }
                    
                    // Hide Clear buttons in EDIT mode
                    const clearBtn = document.getElementById('clearBtn');
                    if (clearBtn) {
                        clearBtn.style.display = 'none';
                        console.log('✅ Clear button hidden');
                    }
                    
                    // Set selected table (order already has table, no need to select)
                    selectedTable = existingOrder.tableID;
                    console.log('✅ selectedTable set to:', selectedTable);
                    
                    // Update header to show order info
                    document.getElementById('selectedTableDisplay').textContent = 
                        'Order #' + existingOrder.orderID + ' - Table ' + existingOrder.tableID;
                    document.getElementById('selectedTableDisplay').classList.remove('bg-purple-100', 'text-purple-800');
                    document.getElementById('selectedTableDisplay').classList.add('bg-blue-600', 'text-white');
                    
                    // Load existing items into cart
                    if (existingOrder.items && existingOrder.items.length > 0) {
                        cart = existingOrder.items.map(item => ({
                            id: item.productSizeID,
                            sizeId: item.productSizeID,
                            name: item.productName,
                            sizeName: item.sizeName,
                            price: item.totalPrice / item.quantity,
                            orderId: '#' + existingOrder.orderID, // Display only - not sent to server
                            toppings: item.specialInstructions ? [item.specialInstructions] : [],
                            quantity: item.quantity,
                            uniqueId: 'existing-' + item.orderDetailID,
                            isExisting: true // Mark as existing item
                        }));
                        
                        updateCartDisplay();
                        updateTotals();
                    }
                    
                } else {
                    console.error('❌ Failed to load order:', data.message);
                    alert('❌ Cannot load order: ' + data.message);
                    window.location.href = 'manage-orders';
                }
            } catch (error) {
                console.error('❌ Error loading order:', error);
                alert('❌ Error loading order!');
                window.location.href = 'manage-orders';
            }
        }

        // Load products from database
        async function loadSampleProducts() {
            try {
                console.log('🔄 Loading products from database...');
                const response = await fetch('pos?action=getProducts');
                const data = await response.json();
                
                if (data.success) {
                    products = data.categories;
                    console.log('✅ Products loaded:', products);
                } else {
                    console.error('❌ Failed to load products:', data.message);
                    // Fallback to sample data
                    loadFallbackProducts();
                }
            } catch (error) {
                console.error('❌ Error loading products:', error);
                // Fallback to sample data
                loadFallbackProducts();
            }
        }
        
        // Fallback sample products
        function loadFallbackProducts() {
            products = {
                Pizza: [
                    { id: 1, name: 'Hawaiian Pizza', sizes: [
                        { sizeId: 1, sizeCode: 'S', sizeName: 'Small', price: 120000 },
                        { sizeId: 2, sizeCode: 'M', sizeName: 'Medium', price: 160000 },
                        { sizeId: 3, sizeCode: 'L', sizeName: 'Large', price: 200000 }
                    ]},
                    { id: 2, name: 'Pepperoni Pizza', sizes: [
                        { sizeId: 4, sizeCode: 'S', sizeName: 'Small', price: 150000 },
                        { sizeId: 5, sizeCode: 'M', sizeName: 'Medium', price: 190000 },
                        { sizeId: 6, sizeCode: 'L', sizeName: 'Large', price: 230000 }
                    ]}
                ],
                Drink: [
                    { id: 3, name: 'Iced Milk Coffee', sizes: [
                        { sizeId: 4, sizeCode: 'F', sizeName: 'Fixed', price: 25000 }
                    ]},
                    { id: 4, name: 'Peach Orange Tea', sizes: [
                        { sizeId: 5, sizeCode: 'F', sizeName: 'Fixed', price: 30000 }
                    ]}
                ]
            };
        }

        // Load toppings from database
        async function loadSampleToppings() {
            try {
                console.log('🔄 Loading toppings from database...');
                const response = await fetch('pos?action=getToppings');
                const data = await response.json();
                
                if (data.success) {
                    toppings = data.toppings;
                    console.log('✅ Toppings loaded:', toppings);
                } else {
                    console.error('❌ Failed to load toppings:', data.message);
                    toppings = [];
                }
            } catch (error) {
                console.error('❌ Error loading toppings:', error);
                toppings = [];
            }
        }

        // Select category
        function selectCategory(category) {
            // Map UI categories to database categories
            const categoryMap = {
                'PIZZA': 'Pizza',
                'APPETIZER': 'Appetizer',
                'BEVERAGES': 'Drink', 
                'SIDES': 'SideDish',  // ✅ Fixed: Match database CategoryName (no space)
                'DESSERT': 'Dessert'
            };
            
            selectedCategory = categoryMap[category] || category;
            
            // Update tab styles
            document.querySelectorAll('.category-tab').forEach(tab => {
                if (tab.dataset.category === category) {
                    tab.className = 'category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all bg-white text-orange-600 border-b-2 border-orange-600';
                } else {
                    tab.className = 'category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all text-gray-600 hover:bg-gray-100';
                }
            });
            
            displayProducts();
        }

        // Display products
        function displayProducts() {
            const grid = document.getElementById('productGrid');
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const categoryProducts = products[selectedCategory] || [];
            
            const filteredProducts = categoryProducts.filter(product =>
                product.name.toLowerCase().includes(searchTerm)
            );
            
            grid.innerHTML = filteredProducts.map(product => {
                // Get price range for display
                const prices = product.sizes.map(size => size.price);
                const minPrice = Math.min(...prices);
                const maxPrice = Math.max(...prices);
                const priceDisplay = minPrice === maxPrice ? 
                    formatCurrency(minPrice) + 'đ' : 
                    formatCurrency(minPrice) + 'đ - ' + formatCurrency(maxPrice) + 'đ';
                
                return '<button onclick="handleProductClick(' + product.id + ')" ' +
                        'class="bg-gradient-to-br from-orange-50 to-orange-100 hover:from-orange-100 hover:to-orange-200 p-4 rounded-lg border border-orange-200 transition-all text-left group hover:shadow-md">' +
                    '<div class="font-semibold text-gray-800 text-sm mb-2 group-hover:text-orange-700">' +
                        product.name +
                    '</div>' +
                    '<div class="text-orange-600 font-bold text-lg">' +
                        priceDisplay +
                    '</div>' +
                    '<div class="text-xs text-gray-500 mt-1">' +
                        product.sizes.length + ' size' + (product.sizes.length > 1 ? 's' : '') + ' available' +
                    '</div>' +
                '</button>';
            }).join('');
        }

        // Filter products
        function filterProducts() {
            displayProducts();
        }

        // Handle product click - now shows size selection
        function handleProductClick(productId) {
            const product = findProductById(productId);
            if (!product) return;
            
            selectedProduct = product;
            selectedToppings = [];
            
            // Always show size selection modal (which includes toppings for pizza)
            showSizeSelectionModal();
        }

        // Find product by ID
        function findProductById(id) {
            for (const category in products) {
                const product = products[category].find(p => p.id === id);
                if (product) return product;
            }
            return null;
        }

        // Show size selection modal
        function showSizeSelectionModal() {
            if (!selectedProduct) return;
            
            document.getElementById('modalTitle').textContent = 'Select Size for ' + selectedProduct.name;
            
            // Show sizes
            const sizeGrid = document.getElementById('sizeGrid');
            sizeGrid.innerHTML = selectedProduct.sizes.map(size => 
                '<button onclick="selectSize(' + size.sizeId + ')" ' +
                        'class="size-btn p-4 rounded-lg border-2 transition-all font-semibold bg-white text-gray-700 border-gray-300 hover:border-orange-400 text-left" ' +
                        'data-size-id="' + size.sizeId + '">' +
                    '<div class="font-bold text-lg">' + size.sizeName + '</div>' +
                    '<div class="text-orange-600 font-bold">' + formatCurrency(size.price) + 'đ</div>' +
                '</button>'
            ).join('');
            
            // Show toppings section only for Pizza
            const toppingsSection = document.getElementById('toppingsSection');
            if (selectedCategory === 'Pizza') {
                toppingsSection.classList.remove('hidden');
                const toppingGrid = document.getElementById('toppingGrid');
                toppingGrid.innerHTML = toppings.map(topping => 
                    '<button onclick="toggleTopping(' + topping.toppingID + ')" ' +
                            'class="topping-btn p-3 rounded-lg border-2 transition-all bg-white text-gray-700 border-gray-300 hover:border-orange-400 text-left" ' +
                            'data-topping-id="' + topping.toppingID + '">' +
                        '<div class="font-semibold text-sm">' + topping.toppingName + '</div>' +
                        '<div class="text-xs text-orange-600 font-bold">+' + formatCurrency(topping.price) + '</div>' +
                    '</button>'
                ).join('');
                updateSelectedToppingsDisplay();
            } else {
                toppingsSection.classList.add('hidden');
            }
            
            selectedSize = null;
            selectedToppings = [];
            document.getElementById('confirmBtn').disabled = true;
            document.getElementById('sizeModal').classList.add('show');
        }

        // Select size
        function selectSize(sizeId) {
            selectedSize = selectedProduct.sizes.find(size => size.sizeId === sizeId);
            
            // Update size button styles
            document.querySelectorAll('.size-btn').forEach(btn => {
                if (btn.dataset.sizeId == sizeId) {
                    btn.className = 'size-btn p-4 rounded-lg border-2 transition-all font-semibold bg-orange-500 text-white border-orange-600 text-left';
                } else {
                    btn.className = 'size-btn p-4 rounded-lg border-2 transition-all font-semibold bg-white text-gray-700 border-gray-300 hover:border-orange-400 text-left';
                }
            });
            
            // Enable confirm button
            document.getElementById('confirmBtn').disabled = false;
        }

        // Close size modal
        function closeSizeModal() {
            document.getElementById('sizeModal').classList.remove('show');
            selectedProduct = null;
            selectedSize = null;
            selectedToppings = [];
        }

        // Toggle topping
        function toggleTopping(toppingID) {
            const topping = toppings.find(t => t.toppingID === toppingID);
            if (!topping) return;
            
            const index = selectedToppings.findIndex(t => t.toppingID === toppingID);
            
            if (index > -1) {
                // Remove topping
                selectedToppings.splice(index, 1);
            } else {
                // Check limit: Max 3 toppings
                if (selectedToppings.length >= 3) {
                    alert('⚠️ Maximum 3 toppings allowed per pizza!');
                    return;
                }
                // Add topping
                selectedToppings.push(topping);
            }
            
            // Update button style
            const btn = document.querySelector('[data-topping-id="' + toppingID + '"]');
            if (selectedToppings.find(t => t.toppingID === toppingID)) {
                btn.className = 'topping-btn p-3 rounded-lg border-2 transition-all bg-orange-500 text-white border-orange-600 text-left';
            } else {
                btn.className = 'topping-btn p-3 rounded-lg border-2 transition-all bg-white text-gray-700 border-gray-300 hover:border-orange-400 text-left';
            }
            
            updateSelectedToppingsDisplay();
        }

        // Update selected toppings display
        function updateSelectedToppingsDisplay() {
            const display = document.getElementById('selectedToppings');
            if (selectedToppings.length === 0) {
                display.innerHTML = '<span class="text-gray-500">No toppings selected</span>';
            } else {
                const toppingNames = selectedToppings.map(t => t.toppingName + ' (+' + formatCurrency(t.price) + ')');
                const totalToppingPrice = selectedToppings.reduce((sum, t) => sum + t.price, 0);
                display.innerHTML = toppingNames.join(', ') + 
                    '<br><span class="text-orange-600 font-bold">Total toppings: ' + formatCurrency(totalToppingPrice) + '</span>' +
                    '<br><span class="text-gray-500 text-xs">(' + selectedToppings.length + '/3 selected)</span>';
            }
        }

        // Confirm selection
        function confirmSelection() {
            if (selectedProduct && selectedSize) {
                addToCart(selectedProduct, selectedSize, [...selectedToppings]);
                closeSizeModal();
            }
        }

        // Add to cart
        function addToCart(product, size, toppings) {
            const newItem = {
                id: product.id,
                sizeId: size.sizeId,
                name: product.name,
                sizeName: size.sizeName,
                price: size.price,
                orderId: '#' + orderCounter,
                toppings: toppings,
                quantity: 1,
                uniqueId: product.id + '-' + size.sizeId + '-' + Date.now()
            };
            cart.push(newItem);
            orderCounter++;
            updateCartDisplay();
            updateTotals();
        }

        // Update cart display
        function updateCartDisplay() {
            const emptyCart = document.getElementById('emptyCart');
            const cartItems = document.getElementById('cartItems');
            
            if (cart.length === 0) {
                emptyCart.classList.remove('hidden');
                cartItems.classList.add('hidden');
                updateButtonStates(false);
            } else {
                emptyCart.classList.add('hidden');
                cartItems.classList.remove('hidden');
                updateButtonStates(true);
                
                cartItems.innerHTML = cart.map(item => 
                    '<div class="bg-blue-500 text-white rounded-lg p-3 relative">' +
                        // Only show remove button for NEW items (not existing items)
                        (item.isExisting ? '' : 
                            '<button onclick="removeFromCart(\'' + item.uniqueId + '\')" ' +
                                    'class="absolute top-2 right-2 text-white hover:text-red-200 bg-red-500 rounded-full p-1">' +
                                '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>' +
                                '</svg>' +
                            '</button>'
                        ) +
                        
                        '<div class="text-xs font-semibold mb-1">' + item.orderId + '</div>' +
                        
                        '<div class="flex justify-between items-start mb-2">' +
                            '<div class="pr-6">' + 
                                '<div class="font-bold text-lg">' + item.name + '</div>' +
                                '<div class="text-sm font-normal">(' + item.sizeName + ')</div>' +
                                '<div class="text-xs text-blue-200 mt-1">Base: ' + formatCurrency(parseFloat(item.price) || 0) + 'đ</div>' +
                            '</div>' +
                            '<div class="text-2xl font-bold">' + item.quantity + '</div>' +
                        '</div>' +
                        
                        '<div class="text-sm mb-3">' +
                            (item.toppings && item.toppings.length > 0 
                                ? (() => {
                                    // Handle both object array and string array
                                    if (typeof item.toppings[0] === 'object') {
                                        // NEW ITEMS - Show detailed toppings with prices
                                        const toppingList = item.toppings.map(t => 
                                            '<div class="flex justify-between items-center text-xs text-blue-100 mb-1">' +
                                                '<span>🧀 ' + t.toppingName + '</span>' +
                                                '<span class="font-semibold">+' + formatCurrency(t.price) + 'đ</span>' +
                                            '</div>'
                                        ).join('');
                                        return '<div class="bg-blue-600 bg-opacity-50 rounded p-2 mt-2">' +
                                               '<div class="text-xs font-semibold text-blue-100 mb-1">Toppings:</div>' +
                                               toppingList +
                                               '</div>';
                                    } else {
                                        // EXISTING ITEMS - Show topping names only (no prices)
                                        const toppingText = item.toppings[0]; // e.g. "Hawaiian Pizza (Small)"
                                        return '<div class="bg-blue-600 bg-opacity-30 rounded p-2 mt-2">' +
                                               '<div class="text-xs font-semibold text-blue-100 mb-1">🧀 Toppings:</div>' +
                                               '<div class="text-xs text-blue-100">' + toppingText + '</div>' +
                                               '</div>';
                                    }
                                })()
                                : ''
                            ) +
                        '</div>' +
                        
                        '<div class="flex items-center gap-2">' +
                            '<button onclick="updateQuantity(\'' + item.uniqueId + '\', -1)" ' +
                                    'class="bg-white text-blue-500 px-3 py-1 rounded font-bold hover:bg-blue-50">' +
                                '-' +
                            '</button>' +
                            '<button onclick="updateQuantity(\'' + item.uniqueId + '\', 1)" ' +
                                    'class="bg-white text-blue-500 px-3 py-1 rounded font-bold hover:bg-blue-50">' +
                                '+' +
                            '</button>' +
                            '<div class="ml-auto text-lg font-bold">' +
                                (() => {
                                    const itemPrice = parseFloat(item.price) || 0;
                                    let toppingPrice = 0;
                                    if (item.toppings && Array.isArray(item.toppings)) {
                                        toppingPrice = item.toppings.reduce((sum, t) => sum + (typeof t === 'object' && t.price ? t.price : 0), 0);
                                    }
                                    return formatCurrency((itemPrice + toppingPrice) * item.quantity) + 'đ';
                                })() +
                            '</div>' +
                        '</div>' +
                    '</div>'
                ).join('');
            }
        }

        // Update quantity
        function updateQuantity(uniqueId, change) {
            const item = cart.find(item => item.uniqueId === uniqueId);
            if (item) {
                item.quantity = Math.max(1, item.quantity + change);
                updateCartDisplay();
                updateTotals();
            }
        }

        // Remove from cart
        function removeFromCart(uniqueId) {
            cart = cart.filter(item => item.uniqueId !== uniqueId);
            updateCartDisplay();
            updateTotals();
        }

        // Update button states
        function updateButtonStates(enabled) {
            document.getElementById('clearBtn').disabled = !enabled;
            document.getElementById('orderBtn').disabled = !enabled;
        }

        // Update totals
        function updateTotals() {
            console.log('💰 updateTotals() called');
            console.log('🛒 Cart:', cart);
            
            // Calculate subtotal including toppings
            const subtotal = cart.reduce((sum, item) => {
                // Handle toppings - can be array of objects or array of strings
                let toppingPrice = 0;
                if (item.toppings && Array.isArray(item.toppings)) {
                    toppingPrice = item.toppings.reduce((tSum, t) => {
                        // If t is object with price, use it; otherwise 0
                        return tSum + (typeof t === 'object' && t.price ? t.price : 0);
                    }, 0);
                }
                const itemPrice = parseFloat(item.price) || 0;
                const itemQty = parseInt(item.quantity) || 1;
                const itemTotal = (itemPrice + toppingPrice) * itemQty;
                
                console.log('  Item:', item.name, '- Base:', itemPrice, '+ Toppings:', toppingPrice, '× Qty:', itemQty, '= Total:', itemTotal);
                
                return sum + itemTotal;
            }, 0);
            
            // Calculate tax (10%)
            const tax = subtotal * 0.1;
            const total = subtotal + tax;
            
            console.log('💰 Subtotal:', subtotal);
            console.log('💰 Tax (10%):', tax);
            console.log('💰 Total:', total);
            
            // Update UI
            const subtotalElement = document.getElementById('subtotalAmount');
            const taxElement = document.getElementById('taxAmount');
            const totalElement = document.getElementById('totalAmount');
            
            if (subtotalElement) {
                subtotalElement.textContent = formatCurrency(subtotal) + 'đ';
                console.log('✅ Updated subtotalAmount');
            } else {
                console.error('❌ Element subtotalAmount not found!');
            }
            
            if (taxElement) {
                taxElement.textContent = formatCurrency(tax) + 'đ';
                console.log('✅ Updated taxAmount');
            } else {
                console.error('❌ Element taxAmount not found!');
            }
            
            if (totalElement) {
                totalElement.textContent = formatCurrency(total) + 'đ';
                console.log('✅ Updated totalAmount');
            } else {
                console.error('❌ Element totalAmount not found!');
            }
        }

        // Format currency
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount);
        }

        // Clear order
        function clearOrder() {
            cart = [];
            selectedTable = null;
            orderCounter = 1;
            
            // Reset table selection UI
            document.querySelectorAll('.table-btn').forEach(btn => {
                btn.classList.remove('ring-4', 'ring-purple-500');
            });
            
            // Reset header display
            document.getElementById('selectedTableDisplay').textContent = 'Chưa chọn bàn';
            document.getElementById('selectedTableDisplay').classList.remove('bg-purple-600', 'text-white');
            document.getElementById('selectedTableDisplay').classList.add('bg-purple-100', 'text-purple-800');
            
            updateCartDisplay();
            updateTotals();
        }

        // Complete order
        async function completeOrder() {
            console.log('🔔 completeOrder() called!');
            console.log('🛒 Cart length:', cart.length);
            console.log('📝 Edit mode:', editOrderId ? 'YES (Order #' + editOrderId + ')' : 'NO');
            
            if (cart.length === 0) {
                console.log('⚠️ Cart is empty, returning');
                alert('⚠️ Giỏ hàng trống!');
                return;
            }
            
            // Check if table is selected (ONLY for new orders, NOT for edit mode)
            if (!editOrderId && !selectedTable) {
                alert('⚠️ Vui lòng chọn bàn trước khi tạo đơn!');
                return;
            }
            
            console.log('🪑 Selected table ID:', selectedTable);
            
            // Calculate totals including toppings
            const subtotal = cart.reduce((sum, item) => {
                let toppingPrice = 0;
                if (item.toppings && Array.isArray(item.toppings)) {
                    toppingPrice = item.toppings.reduce((tSum, t) => {
                        return tSum + (typeof t === 'object' && t.price ? t.price : 0);
                    }, 0);
                }
                const itemPrice = parseFloat(item.price) || 0;
                const itemQty = parseInt(item.quantity) || 1;
                return sum + ((itemPrice + toppingPrice) * itemQty);
            }, 0);
            
            const tax = subtotal * 0.1;
            const total = subtotal + tax;
            
            // Prepare order data
            const orderData = {
                customerName: 'Walk-in Customer',
                items: cart,
                subtotal: subtotal,
                discount: 0,
                discountAmount: 0,
                total: total,
                timestamp: Date.now()
            };
            
            // Add orderId if in edit mode, otherwise add tableID
            if (editOrderId) {
                orderData.orderId = parseInt(editOrderId); // ✅ Send as integer, not string
                console.log('📝 EDIT MODE: Adding items to existing order #' + editOrderId);
                console.log('📝 NOT sending tableID (order already has table)');
                console.log('📝 orderData.orderId =', orderData.orderId, '(type:', typeof orderData.orderId + ')');
            } else {
                orderData.tableID = parseInt(selectedTable); // ✅ Send as integer
                console.log('🆕 CREATE MODE: Creating new order for table #' + selectedTable);
                console.log('🆕 Sending tableID:', selectedTable);
                console.log('🆕 orderData.tableID =', orderData.tableID, '(type:', typeof orderData.tableID + ')');
            }
            
            console.log('📤 Final orderData:', orderData);
            console.log('📤 JSON.stringify(orderData):', JSON.stringify(orderData));
            
            // Disable order button during processing
            const orderBtn = document.getElementById('orderBtn');
            orderBtn.disabled = true;
            orderBtn.innerHTML = '<svg class="animate-spin h-5 w-5 mx-auto" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>';
            
            try {
                // Send order to server
                const jsonString = JSON.stringify(orderData);
                console.log('🚀 Sending order data:', orderData);
                console.log('📤 JSON string to send:', jsonString);
                console.log('🌐 Calling: pos');
                
                const response = await fetch('pos', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8'
                    },
                    body: jsonString
                });
                
                console.log('📡 Response status:', response.status);
                console.log('📡 Response headers:', response.headers);
                
                const responseText = await response.text();
                console.log('📥 Raw response:', responseText);
                
                let result;
                try {
                    result = JSON.parse(responseText);
                } catch (e) {
                    console.error('❌ JSON parse error:', e);
                    throw new Error('Invalid JSON response: ' + responseText);
                }
                
                console.log('✅ Parsed result:', result);
                
                if (result.success) {
                    if (editOrderId) {
                        // Edit mode success
                        alert('✅ Đã thêm món vào đơn #' + result.orderId + ' thành công!\n\n' +
                              'Tổng tiền mới: ' + formatCurrency(total) + 'đ');
                    } else {
                        // Create mode success
                        const table = tables.find(t => t.tableID === selectedTable);
                        const tableName = table ? table.tableNumber : selectedTable;
                        
                        alert('✅ Đơn hàng đã được tạo thành công!\n\n' +
                              'Order ID: #' + result.orderId + '\n' +
                              'Bàn: ' + tableName + '\n' +
                              'Tổng tiền: ' + formatCurrency(total) + 'đ');
                    }
                    
                    // Redirect to manage-orders
                    window.location.href = 'manage-orders';
                } else {
                    alert('❌ Thất bại: ' + result.message);
                }
                
            } catch (error) {
                console.error('❌ Error creating order:', error);
                console.error('❌ Error type:', error.constructor.name);
                console.error('❌ Error message:', error.message);
                console.error('❌ Error stack:', error.stack);
                alert('❌ Network error: ' + error.message);
            } finally {
                // Re-enable order button
                orderBtn.disabled = false;
                orderBtn.innerHTML = '<svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                   '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>' +
                                   '</svg> Order';
            }
        }
    </script>
        </div> <!-- Close flex flex-1 overflow-hidden -->
    </div> <!-- Close flex-1 wrapper with margin-left -->
</body>
</html>