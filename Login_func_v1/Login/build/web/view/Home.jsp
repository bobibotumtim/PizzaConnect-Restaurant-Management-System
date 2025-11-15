<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="models.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Map<String, Map<Product, List<ProductSize>>> productsByCategory = 
        (Map<String, Map<Product, List<ProductSize>>>) request.getAttribute("productsByCategory");
    Map<Product, List<ProductSize>> featuredProducts = 
        (Map<Product, List<ProductSize>>) request.getAttribute("featuredProducts");
    
    // Check if user is logged in
    User homeUser = (User) session.getAttribute("user");
    boolean isLoggedIn = (homeUser != null);
    
    // Format currency
    NumberFormat currencyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PizzaConnect - Home</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        /* Carousel Styles */
        .carousel {
            position: relative;
            overflow: hidden;
            border-radius: 1rem;
        }
        
        .carousel-inner {
            display: flex;
            transition: transform 0.5s ease;
        }
        
        .carousel-item {
            min-width: 100%;
            height: 400px;
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        
        .carousel-dots {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 8px;
        }
        
        .carousel-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: rgba(255,255,255,0.5);
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .carousel-dot.active {
            background: white;
            width: 32px;
            border-radius: 6px;
        }
        
        .product-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }
        
        /* Public Header Styles */
        .public-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 70px;
            background: white;
            border-bottom: 3px solid #f97316;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 40px;
            z-index: 1000;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .public-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 24px;
            font-weight: 700;
            color: #f97316;
            text-decoration: none;
        }
        
        .public-logo:hover {
            color: #ea580c;
        }
        
        .public-nav {
            display: flex;
            align-items: center;
            gap: 32px;
        }
        
        .public-nav a {
            color: #374151;
            text-decoration: none;
            font-weight: 500;
            font-size: 16px;
            transition: color 0.2s;
        }
        
        .public-nav a:hover {
            color: #f97316;
        }
        
        .public-login-btn {
            background: #f97316;
            color: white;
            padding: 10px 24px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s;
        }
        
        .public-login-btn:hover {
            background: #ea580c;
            color: white;
        }
        
        .public-content {
            margin-top: 70px;
        }
    </style>
</head>
<body class="bg-gray-50">
    <% if (isLoggedIn) { %>
        <%@ include file="Sidebar.jsp" %>
        <%@ include file="NavBar.jsp" %>
        <%@ include file="ChatBotWidget.jsp" %>
    <% } else { %>
        <!-- Public Header -->
        <div class="public-header">
            <a href="<%= request.getContextPath() %>/home" class="public-logo">
                <span>🍕</span>
                <span>PizzaConnect</span>
            </a>
            <div class="public-nav">
                <a href="<%= request.getContextPath() %>/home">Home</a>
                <a href="<%= request.getContextPath() %>/customer-menu">Menu</a>
                <a href="<%= request.getContextPath() %>/view/Login.jsp" class="public-login-btn">Login</a>
            </div>
        </div>
    <% } %>
    
    <div class="<%= isLoggedIn ? "content-wrapper" : "public-content" %>">
        <div class="max-w-7xl mx-auto px-6 py-8">
            
            <!-- Hero Carousel (Only show for guests) -->
            <% if (!isLoggedIn) { %>
            <div class="carousel mb-12">
                <div class="carousel-inner" id="carouselInner">
                    <!-- Slide 1 -->
                    <div class="carousel-item" style="background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);">
                        <div class="text-center">
                            <h1 class="text-5xl font-bold mb-4">Welcome to PizzaConnect</h1>
                            <p class="text-xl mb-6">Delicious Pizza Delivered Hot & Fresh</p>
                            <a href="#products" class="bg-white text-orange-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-all">
                                Order Now
                            </a>
                        </div>
                    </div>
                    
                    <!-- Slide 2 -->
                    <div class="carousel-item" style="background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);">
                        <div class="text-center">
                            <h1 class="text-5xl font-bold mb-4">Special Offers</h1>
                            <p class="text-xl mb-6">Get 20% Off on Your First Order!</p>
                            <a href="#products" class="bg-white text-red-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-all">
                                View Menu
                            </a>
                        </div>
                    </div>
                    
                    <!-- Slide 3 -->
                    <div class="carousel-item" style="background: linear-gradient(135deg, #059669 0%, #047857 100%);">
                        <div class="text-center">
                            <h1 class="text-5xl font-bold mb-4">Fresh Ingredients</h1>
                            <p class="text-xl mb-6">Made with Love, Served with Care</p>
                            <a href="#products" class="bg-white text-green-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-all">
                                Explore
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Carousel Dots -->
                <div class="carousel-dots">
                    <div class="carousel-dot active" onclick="goToSlide(0)"></div>
                    <div class="carousel-dot" onclick="goToSlide(1)"></div>
                    <div class="carousel-dot" onclick="goToSlide(2)"></div>
                </div>
            </div>
            <% } %>
            
            <!-- Featured Products -->
            <div id="products" class="mb-12">
                <div class="flex items-center justify-between mb-6">
                    <h2 class="text-3xl font-bold text-gray-800">Featured Products</h2>
                    <a href="customer-menu" class="text-orange-600 hover:text-orange-700 font-semibold flex items-center gap-2">
                        View Full Menu
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                    </a>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
<%
    if (featuredProducts != null && !featuredProducts.isEmpty()) {
        for (Map.Entry<Product, List<ProductSize>> entry : featuredProducts.entrySet()) {
            Product product = entry.getKey();
            List<ProductSize> sizes = entry.getValue();
            
            // Calculate min price without Stream API
            double minPrice = Double.MAX_VALUE;
            for (ProductSize size : sizes) {
                if (size.getPrice() < minPrice) {
                    minPrice = size.getPrice();
                }
            }
            if (minPrice == Double.MAX_VALUE) {
                minPrice = 0;
            }
%>
                    <div class="product-card bg-white rounded-xl shadow-md overflow-hidden">
                        <div class="h-48 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
<%
            if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) {
%>
                                <img src="<%= product.getImageUrl() %>" alt="<%= product.getProductName() %>" 
                                     class="w-full h-full object-cover">
<%
            } else {
%>
                                <span class="text-6xl">🍕</span>
<%
            }
%>
                        </div>
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
                            <div class="mb-4">
                                <div class="flex flex-wrap gap-2">
<%
            for (ProductSize size : sizes) {
                String sizeLabel = "";
                switch(size.getSizeCode()) {
                    case "S": sizeLabel = "S"; break;
                    case "M": sizeLabel = "M"; break;
                    case "L": sizeLabel = "L"; break;
                    case "F": sizeLabel = "Fixed"; break;
                    default: sizeLabel = size.getSizeCode();
                }
%>
                                    <span class="bg-gray-100 text-gray-700 px-2 py-1 rounded text-xs font-semibold">
                                        <%= sizeLabel %>: <%= currencyFormat.format(size.getPrice()) %>₫
                                    </span>
<%
            }
%>
                                </div>
                            </div>
                            <div class="text-center">
                                <span class="text-xs text-gray-500 block mb-1">From</span>
                                <span class="text-2xl font-bold text-orange-600">
                                    <%= currencyFormat.format(minPrice) %>₫
                                </span>
                            </div>
                        </div>
                    </div>
<%
        }
    }
%>
                </div>
            </div>
            

            
        </div>
    </div>
    
    <!-- Carousel Script -->
    <script>
        let currentSlide = 0;
        const slides = document.querySelectorAll('.carousel-item');
        const dots = document.querySelectorAll('.carousel-dot');
        const carouselInner = document.getElementById('carouselInner');
        
        function goToSlide(index) {
            currentSlide = index;
            carouselInner.style.transform = `translateX(-${currentSlide * 100}%)`;
            
            dots.forEach((dot, i) => {
                if (i === currentSlide) {
                    dot.classList.add('active');
                } else {
                    dot.classList.remove('active');
                }
            });
        }
        
        function nextSlide() {
            currentSlide = (currentSlide + 1) % slides.length;
            goToSlide(currentSlide);
        }
        
        // Auto-play carousel
        setInterval(nextSlide, 5000);
        
        // Initialize Lucide icons
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
    </script>
</body>
</html>
