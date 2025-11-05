<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="models.Product" %>
<%
    Map<String, List<Product>> productsByCategory = 
        (Map<String, List<Product>>) request.getAttribute("productsByCategory");
    List<Product> featuredProducts = 
        (List<Product>) request.getAttribute("featuredProducts");
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
    </style>
</head>
<body class="bg-gray-50">
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>
    
    <div class="content-wrapper">
        <div class="max-w-7xl mx-auto px-6 py-8">
            
            <!-- Hero Carousel -->
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
            
            <!-- Featured Products -->
            <div id="products" class="mb-12">
                <h2 class="text-3xl font-bold text-gray-800 mb-6">Featured Products</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <% if (featuredProducts != null) {
                        for (Product product : featuredProducts) { %>
                    <div class="product-card bg-white rounded-xl shadow-md overflow-hidden">
                        <div class="h-48 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                            <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                <img src="<%= product.getImageUrl() %>" alt="<%= product.getProductName() %>" 
                                     class="w-full h-full object-cover">
                            <% } else { %>
                                <span class="text-6xl">&#127829;</span>
                            <% } %>
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
                            <div class="flex items-center justify-between">
                                <span class="text-2xl font-bold text-orange-600">
                                    From 50,000&#8363;
                                </span>
                                <button class="bg-orange-500 text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition-all">
                                    Order
                                </button>
                            </div>
                        </div>
                    </div>
                    <% }
                    } %>
                </div>
            </div>
            
            <!-- Products by Category -->
            <% if (productsByCategory != null) {
                for (Map.Entry<String, List<Product>> entry : productsByCategory.entrySet()) {
                    String category = entry.getKey();
                    List<Product> products = entry.getValue();
            %>
            <div class="mb-12">
                <h2 class="text-3xl font-bold text-gray-800 mb-6"><%= category %></h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <% for (Product product : products) { %>
                    <div class="product-card bg-white rounded-xl shadow-md overflow-hidden">
                        <div class="h-40 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                            <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                <img src="<%= product.getImageUrl() %>" alt="<%= product.getProductName() %>" 
                                     class="w-full h-full object-cover">
                            <% } else { %>
                                <span class="text-5xl">&#127829;</span>
                            <% } %>
                        </div>
                        <div class="p-4">
                            <h3 class="text-lg font-bold text-gray-800 mb-2">
                                <%= product.getProductName() %>
                            </h3>
                            <button class="w-full bg-orange-500 text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition-all">
                                Order Now
                            </button>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% }
            } %>
            
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
