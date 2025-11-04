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
<body class="h-screen bg-gray-100 flex flex-col overflow-hidden">
    <% 
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("Login");
            return;
        }
    %>

    <!-- Header -->
    <div class="bg-white shadow-sm border-b px-6 py-3 flex items-center justify-between">
        <div class="flex items-center gap-4">
            <div class="text-2xl font-bold text-orange-600">🍕 PIZZA POS</div>
            <div class="relative">
                <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
                <input type="text" id="searchInput" placeholder="Search menu..." 
                       class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none focus:ring-2 focus:ring-orange-500">
            </div>
        </div>
        <div class="flex items-center gap-4">
            <div class="text-right">
                <div class="font-semibold"><%= user.getName() %></div>
                <div class="text-sm text-gray-600"><%= user.getRole() == 1 ? "Admin" : "Employee" %></div>
            </div>
            <a href="manage-orders" class="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-all">
                📋 Orders
            </a>
            <a href="Login?action=logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition-all">
                Logout
            </a>
        </div>
    </div>

    <div class="flex flex-1 overflow-hidden">
        <!-- Left Panel - Products -->
        <div class="flex-1 flex flex-col bg-white">
            <!-- Category Tabs -->
            <div class="flex border-b bg-gray-50">
                <button onclick="selectCategory('PIZZA')" class="category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all bg-white text-orange-600 border-b-2 border-orange-600" data-category="PIZZA">
                    PIZZA
                </button>
                <button onclick="selectCategory('BEVERAGES')" class="category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all text-gray-600 hover:bg-gray-100" data-category="BEVERAGES">
                    DRINKS
                </button>
                <button onclick="selectCategory('SIDES')" class="category-tab flex-1 py-4 px-4 text-sm font-semibold transition-all text-gray-600 hover:bg-gray-100" data-category="SIDES">
                    TOPPINGS
                </button>
            </div>

            <!-- Product Grid -->
            <div class="flex-1 overflow-y-auto p-4">
                <div id="productGrid" class="grid grid-cols-3 gap-3">
                    <!-- Products will be loaded here -->
                </div>
            </div>
        </div>

        <!-- Right Panel - Cart -->
        <div class="w-96 bg-white border-l flex flex-col">
            <!-- Customer Info -->
            <div class="p-4 border-b bg-gray-50">
                <div class="relative">
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                    <input type="text" id="customerName" placeholder="Customer name (optional)"
                           class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg w-full focus:outline-none focus:ring-2 focus:ring-orange-500">
                </div>
            </div>

            <!-- Cart Items -->
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

            <!-- Summary -->
            <div class="border-t bg-gray-50 p-4 space-y-3">
                <!-- Discount -->
                <div class="flex items-center gap-2">
                    <svg class="text-gray-600" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 8h6m-5 0a3 3 0 110 6H9l3 3m-3-6h6m6 1a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <input type="number" id="discountInput" placeholder="Discount %" min="0" max="100"
                           class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                </div>

                <!-- Totals -->
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between text-gray-600">
                        <span>Subtotal:</span>
                        <span id="subtotalAmount" class="font-semibold">0đ</span>
                    </div>
                    <div id="discountRow" class="flex justify-between text-red-600 hidden">
                        <span>Discount (<span id="discountPercent">0</span>%):</span>
                        <span id="discountAmount" class="font-semibold">-0đ</span>
                    </div>
                    <div class="flex justify-between text-lg font-bold text-gray-800 pt-2 border-t">
                        <span>Total:</span>
                        <span id="totalAmount" class="text-orange-600">0đ</span>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="grid grid-cols-2 gap-2 pt-2">
                    <button onclick="clearOrder()" id="clearBtn" disabled
                            class="py-3 px-4 bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold rounded-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                        </svg>
                        Clear
                    </button>
                    <button onclick="completeOrder()" id="payBtn" disabled
                            class="py-3 px-4 bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-bold rounded-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-lg">
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                        </svg>
                        Pay
                    </button>
                </div>

                <button onclick="printBill()" id="printBtn" disabled
                        class="w-full py-3 px-4 bg-green-500 hover:bg-green-600 text-white font-bold rounded-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                    <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                    </svg>
                    Print Bill
                </button>
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
        let selectedCategory = 'Pizza'; // Updated to match database categories
        let selectedProduct = null;
        let selectedSize = null;
        let selectedToppings = [];
        let orderCounter = 1;

        // Initialize
        document.addEventListener('DOMContentLoaded', async function() {
            await loadSampleProducts();
            loadSampleToppings();
            setupEventListeners();
            selectCategory('PIZZA'); // This will set selectedCategory and display products
        });

        function setupEventListeners() {
            document.getElementById('searchInput').addEventListener('input', filterProducts);
            document.getElementById('discountInput').addEventListener('input', updateTotals);
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

        // Load sample toppings
        function loadSampleToppings() {
            toppings = [
                'Extra Cheese', 'Mushrooms', 'Pepperoni', 'Sausage',
                'Onions', 'Bell Peppers', 'Olives', 'Bacon',
                'Ham', 'Pineapple', 'Jalapeños', 'Tomatoes'
            ];
        }

        // Select category
        function selectCategory(category) {
            // Map UI categories to database categories
            const categoryMap = {
                'PIZZA': 'Pizza',
                'BEVERAGES': 'Drink', 
                'SIDES': 'Topping',
                'DESSERTS': 'Dessert'
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
                    '<button onclick="toggleTopping(\'' + topping + '\')" ' +
                            'class="topping-btn p-2 rounded-lg border-2 transition-all font-semibold bg-white text-gray-700 border-gray-300 hover:border-orange-400 text-sm" ' +
                            'data-topping="' + topping + '">' +
                        topping +
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
        function toggleTopping(topping) {
            const index = selectedToppings.indexOf(topping);
            if (index > -1) {
                selectedToppings.splice(index, 1);
            } else {
                selectedToppings.push(topping);
            }
            
            // Update button style
            const btn = document.querySelector('[data-topping="' + topping + '"]');
            if (selectedToppings.includes(topping)) {
                btn.className = 'topping-btn p-3 rounded-lg border-2 transition-all font-semibold bg-orange-500 text-white border-orange-600';
            } else {
                btn.className = 'topping-btn p-3 rounded-lg border-2 transition-all font-semibold bg-white text-gray-700 border-gray-300 hover:border-orange-400';
            }
            
            updateSelectedToppingsDisplay();
        }

        // Update selected toppings display
        function updateSelectedToppingsDisplay() {
            const display = document.getElementById('selectedToppings');
            display.textContent = selectedToppings.length > 0 ? selectedToppings.join(', ') : 'No toppings selected';
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
                        '<button onclick="removeFromCart(\'' + item.uniqueId + '\')" ' +
                                'class="absolute top-2 right-2 text-white hover:text-red-200 bg-red-500 rounded-full p-1">' +
                            '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>' +
                            '</svg>' +
                        '</button>' +
                        
                        '<div class="text-xs font-semibold mb-1">' + item.orderId + '</div>' +
                        
                        '<div class="flex justify-between items-start mb-2">' +
                            '<div class="font-bold text-lg pr-6">' + 
                                item.name + 
                                '<div class="text-sm font-normal">(' + item.sizeName + ')</div>' +
                            '</div>' +
                            '<div class="text-2xl font-bold">' + item.quantity + '</div>' +
                        '</div>' +
                        
                        '<div class="text-sm mb-3">' +
                            (item.toppings && item.toppings.length > 0 
                                ? '+ ' + item.toppings.join(', ')
                                : '<span class="text-blue-200 italic">(No toppings)</span>'
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
                                formatCurrency(item.price * item.quantity) + 'đ' +
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
            document.getElementById('payBtn').disabled = !enabled;
            document.getElementById('printBtn').disabled = !enabled;
        }

        // Update totals
        function updateTotals() {
            const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            const discount = parseFloat(document.getElementById('discountInput').value) || 0;
            const discountAmount = (subtotal * discount) / 100;
            const total = subtotal - discountAmount;
            
            document.getElementById('subtotalAmount').textContent = formatCurrency(subtotal) + 'đ';
            document.getElementById('totalAmount').textContent = formatCurrency(total) + 'đ';
            
            const discountRow = document.getElementById('discountRow');
            if (discount > 0) {
                discountRow.classList.remove('hidden');
                document.getElementById('discountPercent').textContent = discount;
                document.getElementById('discountAmount').textContent = '-' + formatCurrency(discountAmount) + 'đ';
            } else {
                discountRow.classList.add('hidden');
            }
        }

        // Format currency
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount);
        }

        // Clear order
        function clearOrder() {
            cart = [];
            document.getElementById('customerName').value = '';
            document.getElementById('discountInput').value = '';
            orderCounter = 1;
            updateCartDisplay();
            updateTotals();
        }

        // Complete order
        async function completeOrder() {
            console.log('🔔 completeOrder() called!');
            console.log('🛒 Cart length:', cart.length);
            
            if (cart.length === 0) {
                console.log('⚠️ Cart is empty, returning');
                return;
            }
            
            const customerName = document.getElementById('customerName').value.trim() || 'Walk-in Customer';
            console.log('👤 Customer name:', customerName);
            const discount = parseFloat(document.getElementById('discountInput').value) || 0;
            const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            const discountAmount = (subtotal * discount) / 100;
            const total = subtotal - discountAmount;
            
            // Prepare order data
            const orderData = {
                customerName: customerName,
                items: cart,
                subtotal: subtotal,
                discount: discount,
                discountAmount: discountAmount,
                total: total,
                timestamp: Date.now()
            };
            
            // Disable pay button during processing
            const payBtn = document.getElementById('payBtn');
            payBtn.disabled = true;
            payBtn.textContent = 'Processing...';
            
            try {
                // Send order to server
                console.log('🚀 Sending order data:', orderData);
                console.log('🌐 Calling: simple-pos');
                const response = await fetch('simple-pos', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8'
                    },
                    body: JSON.stringify(orderData)
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
                    // Show success message with Order ID
                    alert('✅ Order created successfully!\n\n' +
                          'Order ID: #' + result.orderId + '\n' +
                          'Customer: ' + customerName + '\n' +
                          'Total: ' + formatCurrency(total) + 'đ\n\n' +
                          'Order has been saved to database!');
                    
                    // Clear cart after successful order
                    clearOrder();
                } else {
                    alert('❌ Failed to create order: ' + result.message);
                }
                
            } catch (error) {
                console.error('❌ Error creating order:', error);
                console.error('❌ Error type:', error.constructor.name);
                console.error('❌ Error message:', error.message);
                console.error('❌ Error stack:', error.stack);
                alert('❌ Network error: ' + error.message);
            } finally {
                // Re-enable pay button
                payBtn.disabled = false;
                payBtn.innerHTML = '<svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                   '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>' +
                                   '</svg> Pay';
            }
        }

        // Print bill
        function printBill() {
            if (cart.length === 0) return;
            
            const customerName = document.getElementById('customerName').value.trim() || 'Walk-in Customer';
            const discount = parseFloat(document.getElementById('discountInput').value) || 0;
            const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            const discountAmount = (subtotal * discount) / 100;
            const total = subtotal - discountAmount;
            
            // Create print window
            const printWindow = window.open('', '_blank');
            printWindow.document.write(
                '<html>' +
                '<head>' +
                    '<title>Pizza Bill</title>' +
                    '<style>' +
                        'body { font-family: Arial, sans-serif; margin: 20px; }' +
                        '.header { text-align: center; margin-bottom: 20px; }' +
                        '.item { display: flex; justify-content: space-between; margin: 5px 0; }' +
                        '.total { border-top: 1px solid #000; margin-top: 10px; padding-top: 10px; font-weight: bold; }' +
                    '</style>' +
                '</head>' +
                '<body>' +
                    '<div class="header">' +
                        '<h2>🍕 PizzaConnect</h2>' +
                        '<p>Customer: ' + customerName + '</p>' +
                        '<p>Date: ' + new Date().toLocaleString('vi-VN') + '</p>' +
                    '</div>' +
                    
                    cart.map(item => 
                        '<div class="item">' +
                            '<span>' + item.name + (item.toppings.length > 0 ? ' + ' + item.toppings.join(', ') : '') + '</span>' +
                            '<span>' + item.quantity + ' x ' + formatCurrency(item.price) + 'đ = ' + formatCurrency(item.price * item.quantity) + 'đ</span>' +
                        '</div>'
                    ).join('') +
                    
                    '<div class="total">' +
                        '<div class="item">' +
                            '<span>Subtotal:</span>' +
                            '<span>' + formatCurrency(subtotal) + 'đ</span>' +
                        '</div>' +
                        (discount > 0 ? 
                            '<div class="item">' +
                                '<span>Discount (' + discount + '%):</span>' +
                                '<span>-' + formatCurrency(discountAmount) + 'đ</span>' +
                            '</div>'
                        : '') +
                        '<div class="item">' +
                            '<span>Total:</span>' +
                            '<span>' + formatCurrency(total) + 'đ</span>' +
                        '</div>' +
                    '</div>' +
                '</body>' +
                '</html>'
            );
            
            printWindow.document.close();
            printWindow.print();
        }
    </script>
</body>
</html>