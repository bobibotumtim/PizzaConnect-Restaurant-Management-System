<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.*, java.util.*, java.text.*" %>
<%@ page import="dao.CustomerDAO" %>
<%@ page import="dao.ProductSizeDAO" %>
<%
    Order order = (Order) request.getAttribute("order");
    List<Discount> discounts = (List<Discount>) request.getAttribute("discounts");
    Double tax = (Double) request.getAttribute("tax");
    Double taxRate = (Double) request.getAttribute("taxRate");
    Double totalWithTax = (Double) request.getAttribute("totalWithTax");
    Discount loyaltyDiscount = (Discount) request.getAttribute("loyaltyDiscount");
    Integer conversionRate = (Integer) request.getAttribute("conversionRate");
    Double currentDiscount = (Double) request.getAttribute("currentDiscount");
    
    // Get search results
    List<User> searchResults = (List<User>) request.getAttribute("searchResults");
    List<Customer> customerSearchResults = (List<Customer>) request.getAttribute("customerSearchResults");
    String searchPhone = (String) request.getAttribute("searchPhone");
    
    // Default values
    if (conversionRate == null) conversionRate = 100;
    if (searchResults == null) searchResults = new ArrayList<>();
    if (customerSearchResults == null) customerSearchResults = new ArrayList<>();
    if (currentDiscount == null) currentDiscount = 0.0;
    if (discounts == null) discounts = new ArrayList<>();
    if (tax == null) tax = 0.0;
    if (taxRate == null) taxRate = 0.1;
    if (totalWithTax == null) totalWithTax = order != null ? order.getTotalPrice() * 1.1 : 0;
    
    CustomerDAO customerDAO = new CustomerDAO();
    
    NumberFormat numberFormat = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    
    // Create JavaScript variables from JSP
    double orderTotalPrice = order != null ? order.getTotalPrice() : 0;
    int orderId = order != null ? order.getOrderID() : 0;

    ProductSizeDAO productSizeDAO = new ProductSizeDAO();
    
    // Create map to save base price of each product size
    Map<Integer, Double> originalPriceMap = new HashMap<>();
    if (order != null) {
        for (OrderDetail item : order.getDetails()) {
            try {
                ProductSize productSize = productSizeDAO.getProductSizeById(item.getProductSizeID());
                if (productSize != null) {
                    originalPriceMap.put(item.getProductSizeID(), productSize.getPrice());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Order #<%= order != null ? order.getOrderID() : "" %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .selected-row {
            background-color: #3b82f6 !important;
            color: white !important; 
        }
        .selected-row h4,
        .selected-row .text-sm,
        .selected-row .text-xs {
            color: white !important; 
        }
        .discount-row:hover {
            background-color: #f3f4f6;
            cursor: pointer;
        }
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
        .customer-option {
            padding: 8px 12px;
            border-bottom: 1px solid #e5e7eb;
            cursor: pointer;
        }
        .customer-option:hover {
            background-color: #f3f4f6;
        }
        .customer-option:last-child {
            border-bottom: none;
        }
        
        .payment-container {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            grid-template-rows: auto 1fr;
            gap: 1rem;
            height: calc(100vh - 200px);
            min-height: 600px;
        }
        
        .scrollable-section {
            overflow-y: auto;
            max-height: 100%;
        }
        
        .fixed-section {
            display: flex;
            flex-direction: column;
        }
        
        .section-content {
            display: flex;
            flex-direction: column;
            height: 100%;
        }
    </style>
</head>
<body class="bg-gray-50">
    <div class="min-h-screen">
        <!-- Header -->
        <div class="bg-blue-600 text-white shadow-lg">
            <div class="max-w-full mx-auto px-6 py-4">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center">
                            POS
                        </div>
                        <div>
                            <h1 class="text-2xl font-bold">Payment Processing</h1>
                            <p class="text-blue-100">Order #<%= order != null ? order.getOrderID() : "" %></p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/manage-orders"
                        class="bg-white text-blue-600 px-4 py-2 rounded-lg font-semibold hover:bg-blue-50 transition-all">
                        Back to Orders
                    </a>
                </div>
            </div>
        </div>

        <div class="max-w-full mx-auto px-6 py-4">
            <% if (order == null) { %>
                <div class="text-center py-16">
                    <h3 class="text-xl font-semibold text-gray-700 mb-2">Order Not Found</h3>
                    <p class="text-gray-500">The requested order could not be found.</p>
                </div>
            <% } else { %>
            <!-- 3-Column Layout Container -->
            <div class="payment-container">
                
                <!-- Column 1: Order Details (Left) -->
                <div class="bg-white rounded-xl shadow-md p-6 fixed-section">
                    <h2 class="text-xl font-bold text-gray-800 mb-4">Order Details</h2>
                    
                    <div class="section-content">
                        <!-- Fixed Order Info -->
                        <div class="space-y-4 mb-4">
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-sm font-semibold text-gray-700 mb-1">Order ID</label>
                                    <div class="px-4 py-2 bg-gray-100 rounded-lg text-gray-800 font-mono">
                                        <%= order.getOrderID() %>
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-semibold text-gray-700 mb-1">Table ID</label>
                                    <div class="px-4 py-2 bg-gray-100 rounded-lg text-gray-800">
                                        <%= order.getTableID() > 0 ? order.getTableID() : "Takeaway" %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Scrollable Order Items -->
                        <div class="flex-1 scrollable-section">
                            <label class="block text-sm font-semibold text-gray-700 mb-3">Order Items</label>
                            <div class="space-y-3">
                                <% for (OrderDetail item : order.getDetails()) { 
                                    // Get base price from map
                                    Double originalUnitPrice = originalPriceMap.get(item.getProductSizeID());
                                    if (originalUnitPrice == null) originalUnitPrice = 0.0;
                                    Double originalItemPrice = originalUnitPrice * item.getQuantity();
                                %>
                                <div class="border border-gray-200 rounded-lg p-4">
                                    <div class="flex justify-between items-start mb-2">
                                        <div>
                                            <h4 class="font-semibold text-gray-800"><%= item.getProductName() %></h4>
                                            <% if (item.getSizeName() != null && !item.getSizeName().isEmpty()) { %>
                                                <span class="text-sm text-gray-600">Size: <%= item.getSizeName() %></span>
                                            <% } %>
                                        </div>
                                        <div class="text-right">
                                            <!-- Display item base price by product size price * item quantity -->
                                            <div class="font-bold text-gray-900">
                                                <%= numberFormat.format(originalItemPrice) %> VND
                                            </div>
                                            <div class="text-sm text-gray-600">
                                                × <%= item.getQuantity() %>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <% if (item.getToppings() != null && !item.getToppings().isEmpty()) { %>
                                    <div class="mt-2">
                                        <h5 class="text-sm font-semibold text-gray-700 mb-1">Toppings:</h5>
                                        <div class="space-y-1">
                                            <% for (OrderDetailTopping topping : item.getToppings()) { %>
                                            <div class="flex justify-between text-sm">
                                                <span class="text-gray-600">+ <%= topping.getToppingName() %></span>
                                                <span class="text-gray-600"><%= numberFormat.format(topping.getToppingPrice() * item.getQuantity()) %> VND</span>
                                            </div>
                                            <% } %>
                                        </div>
                                    </div>
                                    <% } %>
                                    
                                    <!-- Display item total price (include topping) -->
                                    <div class="mt-2 pt-2 border-t text-sm">
                                        <div class="flex justify-between">
                                            <span class="text-gray-600">Item total:</span>
                                            <span class="font-semibold text-gray-800">
                                                <%= numberFormat.format(item.getTotalPrice()) %> VND
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        </div>

                        <!-- Fixed Total Amount -->
                        <div class="border-t pt-4 mt-4">
                            <div class="flex justify-between items-center text-lg font-bold">
                                <span>Total Amount:</span>
                                <span class="text-green-600"><%= numberFormat.format(order.getTotalPrice()) %> VND</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Column 2: Customer Information (Middle) -->
                <div class="bg-white rounded-xl shadow-md p-6 fixed-section">
                    <h2 class="text-xl font-bold text-gray-800 mb-4">Customer Information</h2>
                    
                    <div class="section-content">
                        <!-- Fixed Search Form -->
                        <div class="space-y-4 mb-4">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    Search Customer by Phone (Optional)
                                </label>
                                <form method="post" action="${pageContext.request.contextPath}/payment" class="relative">
                                    <input type="hidden" name="action" value="searchCustomer">
                                    <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                    <div class="flex gap-2">
                                        <input type="text" name="searchPhone" 
                                               class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                                               placeholder="Enter phone number..."
                                               value="<%= searchPhone != null ? searchPhone : "" %>">
                                        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
                                            Search
                                        </button>
                                    </div>
                                </form>
                                <div class="text-xs text-gray-500 mt-1">
                                    * Customer selection is optional. You can proceed without selecting a customer.
                                </div>
                            </div>
                        </div>

                        <!-- Scrollable Search Results -->
                        <div class="flex-1 scrollable-section">
                            <!-- Search Results -->
                            <% if (!customerSearchResults.isEmpty()) { %>
                            <div class="border border-gray-300 rounded-lg bg-white shadow-lg mb-4">
                                <div class="p-2 bg-gray-50 border-b">
                                    <span class="text-sm font-semibold text-gray-700">Search Results:</span>
                                </div>
                                <% for (Customer customer : customerSearchResults) { %>
                                <div class="customer-option" 
                                     onclick="selectCustomer(<%= customer.getCustomerID() %>, 
                                                            '<%= customer.getName() != null ? customer.getName().replace("'", "\\'") : "" %>', 
                                                            '<%= customer.getPhone() != null ? customer.getPhone() : "" %>', 
                                                            <%= customer.getLoyaltyPoint() %>)">
                                    <div class="font-semibold"><%= customer.getName() != null ? customer.getName() : "N/A" %></div>
                                    <div class="text-sm text-gray-600">
                                        <%= customer.getPhone() != null ? customer.getPhone() : "N/A" %> 
                                        <% if (customer.getLoyaltyPoint() > 0) { %>
                                            • <%= customer.getLoyaltyPoint() %> points
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <% } else if (searchPhone != null && !searchPhone.isEmpty()) { %>
                            <div class="p-3 text-center text-gray-500 border border-gray-300 rounded-lg bg-white mb-4">
                                No customers found for "<%= searchPhone %>"
                            </div>
                            <% } %>

                            <!-- Selected Customer Info -->
                            <div id="customerInfo" class="hidden border border-gray-200 rounded-lg p-4 bg-gray-50 mb-4">
                                <div class="flex justify-between items-start mb-2">
                                    <h3 class="font-semibold text-gray-800" id="customerName"></h3>
                                    <button onclick="clearCustomer()" class="text-gray-500 hover:text-gray-700">
                                        Remove
                                    </button>
                                </div>
                                <div class="grid grid-cols-2 gap-2 text-sm">
                                    <div>
                                        <span class="text-gray-600">Phone:</span>
                                        <span id="customerPhone" class="font-medium"></span>
                                    </div>
                                    <div>
                                        <span class="text-gray-600">Loyalty Points:</span>
                                        <span id="customerPoints" class="font-medium text-green-600"></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Loyalty Points Usage -->
                            <div id="loyaltySection" class="hidden">
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    Use Loyalty Points
                                </label>
                                <div class="flex gap-2 mb-2">
                                    <input type="number" id="loyaltyPointsInput" 
                                           class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                                           placeholder="Enter points to use"
                                           min="1">
                                    <button onclick="applyLoyaltyPoints()" 
                                            class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-all">
                                        Apply
                                    </button>
                                    <button onclick="useAllLoyaltyPoints()" 
                                            class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-all">
                                        Apply All
                                    </button>
                                </div>
                                <div id="loyaltyError" class="text-red-600 text-sm mt-1 hidden"></div>
                                <div class="text-xs text-gray-500 mt-1">
                                    Conversion rate: <%= conversionRate %> points = 1,000 VND
                                </div>
                            </div>

                            <!-- No Customer Selected Info -->
                            <div id="noCustomerInfo" class="border border-gray-200 rounded-lg p-4 bg-blue-50 mb-4">
                                <div class="flex items-center">
                                    <div class="mr-3">
                                        <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                        </svg>
                                    </div>
                                    <div>
                                        <h3 class="font-semibold text-blue-800">No Customer Selected</h3>
                                        <p class="text-sm text-blue-600">Proceeding as walk-in customer. You can still apply discounts.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Column 3: Discounts & Payment (Right) -->
                <div class="bg-white rounded-xl shadow-md p-6 fixed-section">
                    <h2 class="text-xl font-bold text-gray-800 mb-4">Available Discounts</h2>
                    
                    <div class="section-content">
                        <!-- Scrollable Discounts -->
                        <div class="flex-1 scrollable-section mb-4">
                            <% if (discounts.isEmpty()) { %>
                                <div class="text-center py-8 text-gray-500">
                                    <svg class="w-12 h-12 mx-auto text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"></path>
                                    </svg>
                                    <p class="mt-2">No discounts available for this order amount.</p>
                                </div>
                            <% } else { %>
                                <div class="space-y-2">
                                    <% for (Discount discount : discounts) { %>
                                    <div class="discount-row border border-gray-200 rounded-lg p-3 hover:bg-gray-50 cursor-pointer"
                                         onclick="selectDiscount(this, <%= discount.getDiscountId() %>)"
                                         data-discount-id="<%= discount.getDiscountId() %>"
                                         data-discount-type="<%= discount.getDiscountType() %>"
                                         data-discount-value="<%= discount.getValue() %>"
                                         data-max-discount="<%= discount.getMaxDiscount() != null ? discount.getMaxDiscount() : 0 %>">
                                        <div class="flex justify-between items-start">
                                            <div>
                                                <h4 class="font-semibold text-gray-800"><%= discount.getDescription() %></h4>
                                                <div class="text-sm text-gray-600">
                                                    Type: <%= discount.getDiscountType() %> | 
                                                    Value: <%= discount.getValue() %> <%= "Percentage".equals(discount.getDiscountType()) ? "%" : "VND" %>
                                                    <% if (discount.getMaxDiscount() != null && discount.getMaxDiscount() > 0) { %>
                                                        | Max: <%= numberFormat.format(discount.getMaxDiscount()) %> VND
                                                    <% } %>
                                                </div>
                                                <% if (discount.getMinOrderTotal() > 0) { %>
                                                <div class="text-xs text-gray-500">
                                                    Min order: <%= numberFormat.format(discount.getMinOrderTotal()) %> VND
                                                </div>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>

                        <!-- Fixed Payment Summary -->
                        <div class="border-t pt-4">
                            <h2 class="text-xl font-bold text-gray-800 mb-4">Payment Summary</h2>
                            
                            <div class="space-y-2">
                                <div class="flex justify-between">
                                    <span>Original Total:</span>
                                    <span id="originalTotal"><%= numberFormat.format(order.getTotalPrice()) %> VND</span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Tax (10%):</span>
                                    <span id="taxDisplay"><%= numberFormat.format(tax) %> VND</span>
                                </div>
                                <div class="flex justify-between text-green-600">
                                    <span>Loyalty Discount:</span>
                                    <span id="loyaltyDiscount">0 VND</span>
                                </div>
                                <div class="flex justify-between text-blue-600">
                                    <span>Regular Discount:</span>
                                    <span id="regularDiscount">0 VND</span>
                                </div>
                                <div class="border-t pt-2 flex justify-between font-bold text-lg">
                                    <span>Final Amount:</span>
                                    <span id="finalAmount" class="text-green-600"><%= numberFormat.format(totalWithTax) %> VND</span>
                                </div>
                            </div>

                            <button id="confirmPaymentBtn" 
                                    onclick="openPaymentModal()"
                                    class="w-full mt-4 px-6 py-3 bg-green-500 text-white rounded-lg font-semibold hover:bg-green-600 transition-all">
                                Process Payment
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Payment Confirmation Modal -->
    <div id="paymentModal" class="modal">
        <div class="bg-white rounded-xl shadow-2xl max-w-4xl w-full m-4 max-h-[90vh] overflow-hidden">
            <div class="bg-gradient-to-r from-green-500 to-green-600 text-white px-6 py-4 flex items-center justify-between rounded-t-xl">
                <h3 class="text-xl font-bold">Payment Confirmation</h3>
            </div>
            
            <div class="p-0 overflow-auto" style="max-height: 70vh;">
                <div id="billContent" class="p-6">
                    <!-- Loading state -->
                    <div id="billLoading" class="text-center py-8">
                        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-green-500 mx-auto mb-4"></div>
                        <p>Loading bill...</p>
                    </div>
                    <!-- Error state -->
                    <div id="billError" class="hidden text-center py-8 text-red-600">
                        <p>Failed to load bill. Please try again.</p>
                    </div>
                    <!-- Bill content -->
                    <iframe 
                        id="billIframe"
                        class="hidden w-full" 
                        height="500px" 
                        style="border: none;"
                        onload="onBillLoaded()"
                        onerror="onBillError()"
                    ></iframe>
                </div>
            </div>
            
            <div class="bg-gray-50 px-6 py-4 border-t flex justify-between">
                <div class="flex gap-2">
                    <button onclick="printBill()" 
                            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
                        </svg>
                        Print Bill
                    </button>
                    <button id="finalConfirmBtn" 
                            onclick="finalConfirmPayment()"
                            class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                        </svg>
                        Confirm Payment
                    </button>
                </div>
                <button onclick="closePaymentModal()" 
                        class="px-6 py-2 bg-gray-500 text-white rounded hover:bg-gray-600">
                    Close
                </button>
            </div>
        </div>
    </div>

    <!-- Hidden form for final payment confirmation -->
    <form id="paymentForm" action="${pageContext.request.contextPath}/payment" method="post" class="hidden">
        <input type="hidden" name="action" value="confirmPayment">
        <input type="hidden" name="orderId" value="<%= order != null ? order.getOrderID() : "" %>">
        <input type="hidden" name="customerId" id="formCustomerId" value="0">
        <input type="hidden" name="loyaltyPointsUsed" id="formLoyaltyPointsUsed" value="0">
        <input type="hidden" name="discountId" id="formDiscountId" value="0">
        <input type="hidden" name="finalAmount" id="formFinalAmount">
        <input type="hidden" name="customerName" id="formCustomerName" value="Khách vãng lai">
    </form>

<script>
    // JavaScript variables from JSP
    let selectedCustomer = null;
    let selectedDiscountId = null;
    let loyaltyDiscountAmount = 0;
    let regularDiscountAmount = 0;
    let conversionRate = <%= conversionRate %>;
    let originalTotal = <%= orderTotalPrice %>;
    let taxRate = <%= taxRate %>;
    let currentOrderId = <%= orderId %>;

    // Create discounts array from JSP
    let availableDiscounts = [
        <% for (int i = 0; i < discounts.size(); i++) { 
            Discount discount = discounts.get(i);
            if (i > 0) { %>,<% } %>
        {
            discountId: <%= discount.getDiscountId() %>,
            discountType: '<%= discount.getDiscountType() %>',
            value: <%= discount.getValue() %>,
            maxDiscount: <%= discount.getMaxDiscount() != null ? discount.getMaxDiscount() : 0 %>,
            minOrderTotal: <%= discount.getMinOrderTotal() %>
        }
        <% } %>
    ];

    function selectCustomer(customerId, name, phone, loyaltyPoints) {
        selectedCustomer = {
            customerId: customerId,
            name: name,
            phone: phone,
            loyaltyPoints: loyaltyPoints
        };
        
        document.getElementById('customerName').textContent = name;
        document.getElementById('customerPhone').textContent = phone;
        document.getElementById('customerPoints').textContent = loyaltyPoints || 0;
        
        document.getElementById('customerInfo').classList.remove('hidden');
        document.getElementById('loyaltySection').classList.remove('hidden');
        document.getElementById('noCustomerInfo').classList.add('hidden');
        
        updateConfirmButton();
    }

    function clearCustomer() {
        selectedCustomer = null;
        document.getElementById('customerInfo').classList.add('hidden');
        document.getElementById('loyaltySection').classList.add('hidden');
        document.getElementById('noCustomerInfo').classList.remove('hidden');
        document.getElementById('loyaltyPointsInput').value = '';
        loyaltyDiscountAmount = 0;
        updatePaymentSummary();
        updateConfirmButton();
    }

    function selectDiscount(element, discountId) {
        // Remove selected class from all discount rows
        document.querySelectorAll('.discount-row').forEach(row => {
            row.classList.remove('selected-row');
            row.style.backgroundColor = '';
            row.style.color = '';
        });
        
        // Add selected class to clicked row
        element.classList.add('selected-row');
        element.style.backgroundColor = '#3b82f6';
        element.style.color = 'white';
        
        selectedDiscountId = discountId;
        
        // Calculate regular discount amount
        regularDiscountAmount = calculateRegularDiscount();
        updatePaymentSummary();
        updateConfirmButton();
    }

    function calculateRegularDiscount() {
        // Find selected discount
        let selectedDiscount = availableDiscounts.find(d => d.discountId === selectedDiscountId);
        if (!selectedDiscount) return 0;

        let discount = 0;
        const taxAmount = originalTotal * taxRate;
        const totalWithTax = originalTotal + taxAmount;
        
        if (selectedDiscount.discountType === 'Percentage') {
            discount = totalWithTax * (selectedDiscount.value / 100);
            if (selectedDiscount.maxDiscount > 0 && discount > selectedDiscount.maxDiscount) {
                discount = selectedDiscount.maxDiscount;
            }
        } else if (selectedDiscount.discountType === 'Fixed') {
            discount = Math.min(selectedDiscount.value, totalWithTax); // Not exceed total + tax
        }
        
        return discount;
    }

    function useAllLoyaltyPoints() {
        if (!selectedCustomer) {
            alert('Please select a customer first to use loyalty points');
            return;
        }
        
        const taxAmount = originalTotal * taxRate;
        const totalWithTax = originalTotal + taxAmount;
        const maxDiscountFromPoints = (selectedCustomer.loyaltyPoints / conversionRate) * 1000;
        
        let pointsToUse;
        if (maxDiscountFromPoints >= totalWithTax) {
            pointsToUse = Math.min(
                selectedCustomer.loyaltyPoints, 
                Math.ceil((totalWithTax / 1000) * conversionRate)
            );
        } else {
            pointsToUse = selectedCustomer.loyaltyPoints;
        }
        
        pointsToUse = Math.min(pointsToUse, selectedCustomer.loyaltyPoints);
        
        document.getElementById('loyaltyPointsInput').value = pointsToUse;
        loyaltyDiscountAmount = (pointsToUse / conversionRate) * 1000;
        
        document.getElementById('loyaltyError').classList.add('hidden');
        updatePaymentSummary();
        updateConfirmButton();
    }

    function applyLoyaltyPoints() {
        if (!selectedCustomer) {
            alert('Please select a customer first to use loyalty points');
            return;
        }
        
        const pointsInput = document.getElementById('loyaltyPointsInput');
        const points = parseInt(pointsInput.value);
        const errorDiv = document.getElementById('loyaltyError');
        
        if (!points || points <= 0) {
            errorDiv.textContent = 'Points must be greater than 0';
            errorDiv.classList.remove('hidden');
            return;
        }
        
        if (points > selectedCustomer.loyaltyPoints) {
            errorDiv.textContent = 'Not enough loyalty points. Available: ' + selectedCustomer.loyaltyPoints;
            errorDiv.classList.remove('hidden');
            return;
        }
        
        loyaltyDiscountAmount = (points / conversionRate) * 1000;
        errorDiv.classList.add('hidden');
        
        updatePaymentSummary();
        updateConfirmButton();
    }

    function updatePaymentSummary() {
        const taxAmount = originalTotal * taxRate;
        const totalWithTax = originalTotal + taxAmount;
        const finalAmount = Math.max(0, totalWithTax - loyaltyDiscountAmount - regularDiscountAmount);
        
        // Update display
        document.getElementById('taxDisplay').textContent = formatCurrency(taxAmount);
        document.getElementById('loyaltyDiscount').textContent = formatCurrency(loyaltyDiscountAmount);
        document.getElementById('regularDiscount').textContent = formatCurrency(regularDiscountAmount);
        document.getElementById('finalAmount').textContent = formatCurrency(finalAmount);
    }

    function updateConfirmButton() {
        const confirmBtn = document.getElementById('confirmPaymentBtn');
        // Allow payment even though there's no customer
        confirmBtn.disabled = false;
    }

    function formatCurrency(amount) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    }

    function openPaymentModal() {
        // Calculate current values
        const currentTaxAmount = originalTotal * taxRate;
        const currentLoyaltyDiscount = loyaltyDiscountAmount;
        const currentRegularDiscount = regularDiscountAmount;
        const totalDiscount = currentLoyaltyDiscount + currentRegularDiscount;
        const finalAmount = Math.max(0, originalTotal + currentTaxAmount - totalDiscount);
        
        // Create customer info
        let customerName = "Khách vãng lai";
        let customerId = 0;
        
        if (selectedCustomer) {
            customerName = selectedCustomer.name;
            customerId = selectedCustomer.customerId;
        }
        
        // Create URL with ALL parameters including tax
        const billUrl = '${pageContext.request.contextPath}/bill?orderId=' + currentOrderId + 
                       '&embedded=true' +
                       '&taxAmount=' + currentTaxAmount +
                       '&taxRate=' + taxRate +
                       '&loyaltyDiscount=' + currentLoyaltyDiscount +
                       '&regularDiscount=' + currentRegularDiscount +
                       '&totalDiscount=' + totalDiscount +
                       '&finalAmount=' + finalAmount +
                       '&customerName=' + encodeURIComponent(customerName) +
                       '&originalTotal=' + originalTotal +
                       '&customerId=' + customerId;
        
        console.log('Loading bill from:', billUrl);
        
        // Reset states and load bill
        document.getElementById('billLoading').classList.remove('hidden');
        document.getElementById('billError').classList.add('hidden');
        document.getElementById('billIframe').classList.add('hidden');
        
        const iframe = document.getElementById('billIframe');
        iframe.src = billUrl;
        document.getElementById('paymentModal').classList.add('show');
        
        setTimeout(() => {
            if (iframe.classList.contains('hidden')) {
                onBillError();
            }
        }, 5000);
    }

    function onBillLoaded() {
        console.log('Bill loaded successfully');
        document.getElementById('billLoading').classList.add('hidden');
        document.getElementById('billError').classList.add('hidden');
        document.getElementById('billIframe').classList.remove('hidden');
    }

    function onBillError() {
        console.error('Failed to load bill');
        document.getElementById('billLoading').classList.add('hidden');
        document.getElementById('billError').classList.remove('hidden');
        document.getElementById('billIframe').classList.add('hidden');
    }

    function closePaymentModal() {
        document.getElementById('paymentModal').classList.remove('show');
    }

    function printBill() {
        const iframe = document.getElementById('billIframe');
        if (iframe && iframe.contentWindow) {
            iframe.contentWindow.print();
        } else {
            alert('Bill is not loaded yet');
        }
    }

    function finalConfirmPayment() {
        if (!confirm('Are you sure you want to confirm this payment?')) {
            return;
        }
        
        // Calculate final values
        const currentTaxAmount = originalTotal * taxRate;
        const totalDiscount = loyaltyDiscountAmount + regularDiscountAmount;
        const finalAmount = Math.max(0, originalTotal + currentTaxAmount - totalDiscount);
        
        // Set form values
        document.getElementById('formCustomerId').value = selectedCustomer ? selectedCustomer.customerId : 0;
        document.getElementById('formLoyaltyPointsUsed').value = selectedCustomer ? (document.getElementById('loyaltyPointsInput').value || 0) : 0;
        document.getElementById('formDiscountId').value = selectedDiscountId || 0;
        document.getElementById('formCustomerName').value = selectedCustomer ? selectedCustomer.name : 'Khách vãng lai';
        document.getElementById('formFinalAmount').value = finalAmount;
        
        document.getElementById('finalConfirmBtn').disabled = true;
        document.getElementById('finalConfirmBtn').innerHTML = 'Processing...';
        
        document.getElementById('paymentForm').submit();
    }

    // Initialize payment summary
    updatePaymentSummary();
</script>
</body>
</html>