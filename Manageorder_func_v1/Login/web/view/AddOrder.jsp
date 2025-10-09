<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Product" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Order - PizzaConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .nav {
            background: #2c3e50;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .nav .welcome {
            color: white;
            font-weight: 500;
        }
        
        .nav .back {
            background: #3498db;
            color: white;
            padding: 8px 20px;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav .back:hover {
            background: #2980b9;
        }
        
        .content {
            padding: 30px;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-weight: 500;
        }
        
        .alert.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .form-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .form-section h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 1.3em;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        
        .form-group input,
        .form-group textarea,
        .form-group select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .menu-section {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .menu-section h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 1.3em;
        }
        
        .category-section {
            margin-bottom: 30px;
        }
        
        .category-title {
            background: #3498db;
            color: white;
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
        }
        
        .product-item {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            background: #f8f9fa;
        }
        
        .product-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .product-name {
            font-weight: 600;
            color: #2c3e50;
        }
        
        .product-price {
            color: #27ae60;
            font-weight: 600;
        }
        
        .product-description {
            color: #7f8c8d;
            font-size: 0.9em;
            margin-bottom: 10px;
        }
        
        .product-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .quantity-input {
            width: 60px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 3px;
            text-align: center;
        }
        
        .instructions-input {
            flex: 1;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 3px;
            font-size: 0.9em;
        }
        
        .total-section {
            background: #e8f5e8;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 30px;
        }
        
        .total-section h3 {
            color: #27ae60;
            font-size: 1.5em;
            margin-bottom: 10px;
        }
        
        .total-amount {
            font-size: 2em;
            font-weight: 700;
            color: #27ae60;
        }
        
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 1em;
            font-weight: 600;
            transition: all 0.3s ease;
            text-align: center;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #229954;
        }
        
        .btn-warning {
            background: #f39c12;
            color: white;
        }
        
        .btn-warning:hover {
            background: #e67e22;
        }
        
        .form-actions {
            text-align: center;
            margin-top: 30px;
        }
        
        .form-actions .btn {
            margin: 0 10px;
        }
    </style>
</head>
<body>
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        List<Product> products = (List<Product>) request.getAttribute("products");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
    %>
    
    <div class="container">
        <div class="header">
            <h1>🍕 Add New Order</h1>
            <p>Create a new pizza order</p>
        </div>
        
        <div class="nav">
            <div class="welcome">
                Welcome, <strong><%= currentUser != null ? currentUser.getUsername() : "User" %></strong>
            </div>
            <a href="manage-orders" class="back">← Back to Orders</a>
        </div>
        
        <div class="content">
            <% if (message != null && !message.isEmpty()) { %>
                <div class="alert success"><%= message %></div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert error"><%= error %></div>
            <% } %>
            
            <form method="post" id="orderForm">
                <!-- Order Information -->
                <div class="form-section">
                    <h3>📋 Order Information</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="tableNumber">Table Number *</label>
                            <input type="text" id="tableNumber" name="tableNumber" required>
                        </div>
                        <div class="form-group">
                            <label for="customerName">Customer Name *</label>
                            <input type="text" id="customerName" name="customerName" required>
                        </div>
                        <div class="form-group">
                            <label for="customerPhone">Customer Phone</label>
                            <input type="text" id="customerPhone" name="customerPhone">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="notes">Special Notes</label>
                        <textarea id="notes" name="notes" placeholder="Any special instructions for the order..."></textarea>
                    </div>
                </div>
                
                <!-- Menu Selection -->
                <div class="menu-section">
                    <h3>🍕 Menu Selection</h3>
                    
                    <% if (products != null && !products.isEmpty()) { %>
                        <% 
                            String currentCategory = "";
                            for (Product product : products) {
                                if (!product.getCategory().equals(currentCategory)) {
                                    currentCategory = product.getCategory();
                        %>
                            <div class="category-section">
                                <div class="category-title"><%= currentCategory %></div>
                                <div class="product-grid">
                        <% } %>
                        
                        <div class="product-item">
                            <div class="product-header">
                                <span class="product-name"><%= product.getProductName() %></span>
                                <span class="product-price">$<%= String.format("%.2f", product.getPrice()) %></span>
                            </div>
                            <div class="product-description"><%= product.getDescription() %></div>
                            <div class="product-controls">
                                <input type="number" 
                                       name="quantity_<%= product.getProductId() %>" 
                                       class="quantity-input" 
                                       min="0" 
                                       max="10" 
                                       value="0"
                                       onchange="calculateTotal()">
                                <input type="text" 
                                       name="instructions_<%= product.getProductId() %>" 
                                       class="instructions-input" 
                                       placeholder="Special instructions...">
                            </div>
                        </div>
                        
                        <% 
                            // Check if this is the last product or next product has different category
                            boolean isLastProduct = products.indexOf(product) == products.size() - 1;
                            boolean nextProductDifferentCategory = !isLastProduct && 
                                !products.get(products.indexOf(product) + 1).getCategory().equals(currentCategory);
                            
                            if (isLastProduct || nextProductDifferentCategory) {
                        %>
                                </div>
                            </div>
                        <% } %>
                        
                        <% } %>
                    <% } else { %>
                        <div class="alert error">No products available. Please add products first.</div>
                    <% } %>
                </div>
                
                <!-- Order Total -->
                <div class="total-section">
                    <h3>💰 Order Total</h3>
                    <div class="total-amount" id="totalAmount">$0.00</div>
                </div>
                
                <!-- Form Actions -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-success">Create Order</button>
                    <a href="manage-orders" class="btn btn-warning">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function calculateTotal() {
            let total = 0;
            const quantityInputs = document.querySelectorAll('input[name^="quantity_"]');
            
            quantityInputs.forEach(input => {
                const quantity = parseInt(input.value) || 0;
                const productId = input.name.split('_')[1];
                const priceElement = input.closest('.product-item').querySelector('.product-price');
                const price = parseFloat(priceElement.textContent.replace('$', '')) || 0;
                
                total += quantity * price;
            });
            
            document.getElementById('totalAmount').textContent = '$' + total.toFixed(2);
        }
        
        // Calculate total on page load
        document.addEventListener('DOMContentLoaded', function() {
            calculateTotal();
        });
    </script>
</body>
</html>

