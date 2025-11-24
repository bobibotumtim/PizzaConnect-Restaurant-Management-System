<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Order" %>
<%@ page import="models.User" %>
<%@ page import="dao.CustomerFeedbackDAO" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PizzaConnect - Order History</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-waiting {
            background: #f59e0b;  /* Orange - Chờ chef làm */
            color: white;
        }

        .status-ready {
            background: #3b82f6;  /* Blue - Chef làm xong */
            color: white;
        }

        .status-dining {
            background: #8b5cf6;  /* Purple - Khách đang ăn */
            color: white;
        }

        .status-completed {
            background: #10b981;  /* Green - Đã thanh toán */
            color: white;
        }

        .status-cancelled {
            background: #ef4444;  /* Red - Đã hủy */
            color: white;
        }

        .payment-paid {
            background: #d1fae5;
            color: #065f46;
        }

        .payment-unpaid {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.3s;
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background-color: #fefefe;
            padding: 0;
            border-radius: 15px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            animation: slideIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 15px 15px 0 0;
        }

        .modal-body {
            padding: 30px;
        }

        .close {
            color: white;
            float: right;
            font-size: 32px;
            font-weight: bold;
            line-height: 1;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .close:hover {
            transform: scale(1.2);
        }

        .stars {
            font-size: 50px;
            margin: 20px 0;
            text-align: center;
        }

        .star {
            cursor: pointer;
            color: #ddd;
            transition: all 0.2s;
            display: inline-block;
        }

        .star:hover {
            transform: scale(1.2);
        }

        .star.selected {
            color: #ffd700;
            text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
        }

        .rating-label {
            text-align: center;
            font-size: 18px;
            font-weight: 600;
            color: #667eea;
            margin-bottom: 20px;
            min-height: 30px;
        }

        .feedback-textarea {
            width: 100%;
            min-height: 120px;
            padding: 15px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            resize: vertical;
            transition: border-color 0.3s;
        }

        .feedback-textarea:focus {
            outline: none;
            border-color: #667eea;
        }

        .submit-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 15px 40px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            width: 100%;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }

        .submit-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .alert {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            animation: slideIn 0.3s;
        }

        .alert-success {
            background: #d1fae5;
            border: 1px solid #6ee7b7;
            color: #065f46;
        }

        .alert-error {
            background: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
        }
    </style>
</head>

<body class="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50">
    <% 
        User currentUser = (User) request.getAttribute("currentUser");
        User sessionUser = (User) session.getAttribute("user");
        User user = currentUser != null ? currentUser : sessionUser;
        List<Order> orders = (List<Order>) request.getAttribute("orders");
        Integer totalOrders = (Integer) request.getAttribute("totalOrders");
        Integer completedOrders = (Integer) request.getAttribute("completedOrders");
        Double totalSpent = (Double) request.getAttribute("totalSpent");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer totalPages = (Integer) request.getAttribute("totalPages");
        Integer pageSize = (Integer) request.getAttribute("pageSize");
        
        if (totalOrders == null) totalOrders = 0;
        if (completedOrders == null) completedOrders = 0;
        if (totalSpent == null) totalSpent = 0.0;
        if (currentPage == null) currentPage = 1;
        if (totalPages == null) totalPages = 1;
        if (pageSize == null) pageSize = 5;
    %>

    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>

    <!-- Main Content -->
    <div class="content-wrapper">
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Header -->
            <div class="bg-gradient-to-r from-red-500 to-orange-500 text-white shadow-lg">
                <div class="max-w-7xl mx-auto px-6 py-6">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-4">
                            <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center text-4xl shadow-lg">
                                🍕
                            </div>
                            <div>
                                <h1 class="text-3xl font-bold">Order History</h1>
                                <p class="text-red-100">View your past orders</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4">
                            <div class="text-right">
                                <div class="font-semibold"><%= user != null ? user.getName() : "User" %></div>
                                <div class="text-sm text-red-100">Customer</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="max-w-7xl mx-auto px-6 py-8 w-full">
                <!-- Statistics -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-blue-500">
                        <div class="text-sm text-gray-600 mb-2">Total Orders</div>
                        <div class="text-3xl font-bold text-blue-600"><%= totalOrders %></div>
                    </div>
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-green-500">
                        <div class="text-sm text-gray-600 mb-2">Completed</div>
                        <div class="text-3xl font-bold text-green-600">
                            <%= completedOrders %>
                        </div>
                    </div>
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-red-500">
                        <div class="text-sm text-gray-600 mb-2">Total Spent</div>
                        <div class="text-3xl font-bold text-red-600">
                            <%= String.format("%,.0f", totalSpent) %>đ
                        </div>
                    </div>
                </div>

                <!-- Orders List -->
                <div class="space-y-6">
                    <% if (orders == null || orders.isEmpty()) { %>
                        <div class="bg-white rounded-xl shadow-md p-12 text-center">
                            <div class="text-6xl mb-4">📦</div>
                            <h3 class="text-xl font-semibold text-gray-700 mb-2">No Orders Yet</h3>
                            <p class="text-gray-500 mb-6">You haven't placed any orders yet.</p>
                            <a href="${pageContext.request.contextPath}/customer-menu" 
                               class="inline-block bg-orange-500 text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-600 transition-all">
                                Browse Menu
                            </a>
                        </div>
                    <% } else { 
                        for (Order order : orders) { 
                            Integer tableId = order.getTableID();
                            String paymentStatus = order.getPaymentStatus();
                            
                            String statusClass = "";
                            String statusIcon = "";
                            switch(order.getStatus()) {
                                case 0: 
                                    statusClass = "status-waiting"; 
                                    statusIcon = "⏳";
                                    break;
                                case 1: 
                                    statusClass = "status-ready"; 
                                    statusIcon = "✅";
                                    break;
                                case 2: 
                                    statusClass = "status-dining"; 
                                    statusIcon = "🍽️";
                                    break;
                                case 3: 
                                    statusClass = "status-completed"; 
                                    statusIcon = "✔️";
                                    break;
                                case 4: 
                                    statusClass = "status-cancelled"; 
                                    statusIcon = "❌";
                                    break;
                            }
                            
                            String paymentClass = "payment-unpaid";
                            if ("Paid".equals(paymentStatus)) paymentClass = "payment-paid";
                    %>
                        <!-- Order Card -->
                        <div class="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                            <!-- Order Header -->
                            <div class="bg-gradient-to-r from-orange-50 to-red-50 px-6 py-4 border-b border-orange-100">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-4">
                                        <div class="text-3xl"><%= statusIcon %></div>
                                        <div>
                                            <div class="flex items-center gap-3">
                                                <span class="text-lg font-bold text-gray-900">Order #<%= order.getOrderID() %></span>
                                                <span class="status-badge <%= statusClass %>">
                                                    <%= order.getStatusText() %>
                                                </span>
                                                <span class="px-3 py-1 rounded-full text-xs font-semibold <%= paymentClass %>">
                                                    <%= paymentStatus != null ? paymentStatus : "Unpaid" %>
                                                </span>
                                            </div>
                                            <div class="text-sm text-gray-600 mt-1">
                                                <%= order.getOrderDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(order.getOrderDate()) : "N/A" %>
                                                <% if (tableId != null && tableId != 0) { %>
                                                    • Table <%= tableId %>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <div class="text-2xl font-bold text-orange-600">
                                            <%= String.format("%,.0f", order.getTotalPrice()) %>đ
                                        </div>
                                        <div class="text-xs text-gray-500">Total Amount</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Order Items -->
                            <div class="px-6 py-4">
                                <% if (order.getDetails() != null && !order.getDetails().isEmpty()) { %>
                                    <div class="space-y-3">
                                        <div class="text-sm font-semibold text-gray-700 mb-3">Order Items:</div>
                                        <% for (models.OrderDetail detail : order.getDetails()) { %>
                                            <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center text-orange-600 font-bold">
                                                        <%= detail.getQuantity() %>x
                                                    </div>
                                                    <div>
                                                        <div class="font-medium text-gray-900">
                                                            <%= detail.getProductName() != null ? detail.getProductName() : "Product #" + detail.getProductSizeID() %>
                                                        </div>
                                                        <% if (detail.getSpecialInstructions() != null && !detail.getSpecialInstructions().isEmpty()) { %>
                                                            <div class="text-xs text-gray-500 italic">
                                                                Note: <%= detail.getSpecialInstructions() %>
                                                            </div>
                                                        <% } %>
                                                    </div>
                                                </div>
                                                <div class="font-semibold text-gray-900">
                                                    <%= String.format("%,.0f", detail.getTotalPrice()) %>đ
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } else { %>
                                    <div class="text-sm text-gray-500 italic">No items found</div>
                                <% } %>

                                <% if (order.getNote() != null && !order.getNote().isEmpty()) { %>
                                    <div class="mt-4 pt-4 border-t border-gray-200">
                                        <div class="text-xs font-semibold text-gray-600 mb-1">Order Note:</div>
                                        <div class="text-sm text-gray-700 bg-gray-50 rounded-lg p-3">
                                            <%= order.getNote() %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>

                            <!-- Feedback Section -->
                            <% if (order.getStatus() == 3 && "Paid".equals(paymentStatus)) { 
                                // Check if feedback exists for this order
                                dao.CustomerFeedbackDAO feedbackDAO = new dao.CustomerFeedbackDAO();
                                boolean hasFeedback = feedbackDAO.hasFeedbackForOrder(order.getOrderID());
                                
                                if (!hasFeedback) { %>
                                    <div class="px-6 py-4 bg-gradient-to-r from-yellow-50 to-orange-50 border-t border-orange-100">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center gap-3">
                                                <div class="text-2xl">⭐</div>
                                                <div>
                                                    <div class="font-semibold text-gray-900">How was your experience?</div>
                                                    <div class="text-sm text-gray-600">Share your feedback with us</div>
                                                </div>
                                            </div>
                                            <button 
                                               onclick="openFeedbackModal(<%= order.getOrderID() %>)"
                                               class="inline-flex items-center gap-2 bg-orange-500 text-white px-5 py-2.5 rounded-lg font-semibold hover:bg-orange-600 transition-all shadow-md hover:shadow-lg">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                                                </svg>
                                                Provide Feedback
                                            </button>
                                        </div>
                                    </div>
                                <% } else { %>
                                    <div class="px-6 py-4 bg-gradient-to-r from-green-50 to-emerald-50 border-t border-green-100">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center gap-3">
                                                <div class="text-2xl">✅</div>
                                                <div>
                                                    <div class="font-semibold text-green-900">Feedback Submitted</div>
                                                    <div class="text-sm text-green-700">Thank you for your feedback!</div>
                                                </div>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/feedback-form?orderId=<%= order.getOrderID() %>" 
                                               class="inline-flex items-center gap-2 bg-green-600 text-white px-5 py-2.5 rounded-lg font-semibold hover:bg-green-700 transition-all shadow-md">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                                </svg>
                                                View Feedback
                                            </a>
                                        </div>
                                    </div>
                                <% } %>
                            <% } %>
                        </div>
                    <% } %>
                    <% } %>
                </div>

                <!-- Pagination -->
                <% if (totalPages > 1) { %>
                <div class="mt-8 flex items-center justify-center gap-2">
                    <!-- Previous Button -->
                    <% if (currentPage > 1) { %>
                        <a href="?page=<%= currentPage - 1 %>" 
                           class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
                            ← Previous
                        </a>
                    <% } else { %>
                        <span class="px-4 py-2 bg-gray-100 border border-gray-200 rounded-lg text-gray-400 cursor-not-allowed">
                            ← Previous
                        </span>
                    <% } %>

                    <!-- Page Numbers -->
                    <div class="flex gap-2">
                        <% 
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);
                            
                            if (startPage > 1) { %>
                                <a href="?page=1" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50">1</a>
                                <% if (startPage > 2) { %>
                                    <span class="px-4 py-2 text-gray-400">...</span>
                                <% } %>
                            <% }
                            
                            for (int i = startPage; i <= endPage; i++) { 
                                if (i == currentPage) { %>
                                    <span class="px-4 py-2 bg-orange-500 text-white rounded-lg font-semibold"><%= i %></span>
                                <% } else { %>
                                    <a href="?page=<%= i %>" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"><%= i %></a>
                                <% } %>
                            <% }
                            
                            if (endPage < totalPages) { 
                                if (endPage < totalPages - 1) { %>
                                    <span class="px-4 py-2 text-gray-400">...</span>
                                <% } %>
                                <a href="?page=<%= totalPages %>" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"><%= totalPages %></a>
                            <% } %>
                    </div>

                    <!-- Next Button -->
                    <% if (currentPage < totalPages) { %>
                        <a href="?page=<%= currentPage + 1 %>" 
                           class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
                            Next →
                        </a>
                    <% } else { %>
                        <span class="px-4 py-2 bg-gray-100 border border-gray-200 rounded-lg text-gray-400 cursor-not-allowed">
                            Next →
                        </span>
                    <% } %>
                </div>

                <!-- Page Info -->
                <div class="mt-4 text-center text-sm text-gray-600">
                    Showing <%= Math.min((currentPage - 1) * pageSize + 1, totalOrders) %> 
                    to <%= Math.min(currentPage * pageSize, totalOrders) %> 
                    of <%= totalOrders %> orders
                </div>
                <% } %>

            </div>
        </div>
    </div>

    <!-- Feedback Modal -->
    <div id="feedbackModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeFeedbackModal()">&times;</span>
                <h2 style="margin: 0; font-size: 24px;">⭐ Rate Your Experience</h2>
                <p style="margin: 5px 0 0 0; opacity: 0.9; font-size: 14px;">Order #<span id="modalOrderId"></span></p>
            </div>
            <div class="modal-body">
                <div id="feedbackMessage" style="display: none;"></div>
                
                <form id="feedbackForm">
                    <input type="hidden" id="feedbackOrderId" name="orderId" value="" />
                    <input type="hidden" name="productId" value="1" />
                    <input type="hidden" id="rating" name="rating" value="" />

                    <div class="rating-label" id="ratingLabel">Select your rating</div>
                    
                    <div class="stars" id="stars">
                        <span class="star" data-rating="1">★</span>
                        <span class="star" data-rating="2">★</span>
                        <span class="star" data-rating="3">★</span>
                        <span class="star" data-rating="4">★</span>
                        <span class="star" data-rating="5">★</span>
                    </div>

                    <textarea
                        class="feedback-textarea"
                        name="comment"
                        placeholder="Share your experience about the food, service... (optional)"
                    ></textarea>

                    <button type="submit" class="submit-btn" id="submitBtn">
                        <span id="submitBtnText">Submit Rating</span>
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- Initialize Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        lucide.createIcons();
        
        // Store context path from JSP
        const contextPath = '${pageContext.request.contextPath}';

        // Modal Functions
        let currentOrderId = null;
        
        function openFeedbackModal(orderId) {
            console.log('Opening feedback modal for Order ID:', orderId);
            
            if (!orderId || orderId === '' || orderId === 'undefined') {
                alert('Lỗi: Order ID không hợp lệ');
                console.error('Invalid orderId:', orderId);
                return;
            }
            
            // Store orderId
            currentOrderId = orderId;
            
            document.getElementById('feedbackModal').classList.add('show');
            document.getElementById('modalOrderId').textContent = orderId;
            document.getElementById('feedbackOrderId').value = orderId;
            document.body.style.overflow = 'hidden';
            
            // Verify orderId was set
            const setOrderId = document.getElementById('feedbackOrderId').value;
            console.log('OrderID set in hidden input:', setOrderId);
            
            // Reset form but keep orderId
            resetFeedbackForm(orderId);
        }

        function closeFeedbackModal() {
            document.getElementById('feedbackModal').classList.remove('show');
            document.body.style.overflow = 'auto';
            currentOrderId = null;
            resetFeedbackForm();
        }

        function resetFeedbackForm(orderIdToKeep) {
            selectedRating = 0;
            document.getElementById('rating').value = '';
            document.getElementById('ratingLabel').textContent = 'Select your rating';
            document.querySelectorAll('.star').forEach(star => {
                star.classList.remove('selected');
            });
            document.querySelector('textarea[name="comment"]').value = '';
            document.getElementById('feedbackMessage').style.display = 'none';
            document.getElementById('submitBtn').disabled = false;
            document.getElementById('submitBtnText').textContent = 'Submit Rating';
            
            // Keep orderId if provided
            if (orderIdToKeep) {
                document.getElementById('feedbackOrderId').value = orderIdToKeep;
            } else if (currentOrderId) {
                document.getElementById('feedbackOrderId').value = currentOrderId;
            }
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('feedbackModal');
            if (event.target == modal) {
                closeFeedbackModal();
            }
        }

        // Star Rating Logic
        const stars = document.querySelectorAll('.star');
        const ratingInput = document.getElementById('rating');
        const ratingLabel = document.getElementById('ratingLabel');
        let selectedRating = 0;

        const ratingTexts = {
            1: '⭐ Very Poor',
            2: '⭐⭐ Poor',
            3: '⭐⭐⭐ Average',
            4: '⭐⭐⭐⭐ Good',
            5: '⭐⭐⭐⭐⭐ Excellent'
        };

        stars.forEach(star => {
            star.addEventListener('click', function() {
                selectedRating = parseInt(this.dataset.rating);
                ratingInput.value = selectedRating;
                ratingLabel.textContent = ratingTexts[selectedRating];

                stars.forEach((s, i) => {
                    if (i < selectedRating) {
                        s.classList.add('selected');
                    } else {
                        s.classList.remove('selected');
                    }
                });
            });

            // Hover effect
            star.addEventListener('mouseenter', function() {
                const hoverRating = parseInt(this.dataset.rating);
                stars.forEach((s, i) => {
                    if (i < hoverRating) {
                        s.style.color = '#ffd700';
                    } else {
                        s.style.color = '#ddd';
                    }
                });
            });
        });

        document.getElementById('stars').addEventListener('mouseleave', function() {
            stars.forEach((s, i) => {
                if (i < selectedRating) {
                    s.style.color = '#ffd700';
                } else {
                    s.style.color = '#ddd';
                }
            });
        });

        // Form Submission
        document.getElementById('feedbackForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            if (!selectedRating) {
                showMessage('Please select a rating!', 'error');
                return;
            }

            // Get orderId - try multiple sources
            let orderIdValue = document.getElementById('feedbackOrderId').value;
            if (!orderIdValue || orderIdValue.trim() === '') {
                orderIdValue = currentOrderId;
            }
            
            // Validate orderId before submit
            if (!orderIdValue || orderIdValue === '' || orderIdValue === 'undefined' || orderIdValue.trim() === '') {
                showMessage('Error: Order ID not found. Please try again.', 'error');
                console.error('OrderID is empty. Current:', currentOrderId, 'Form value:', document.getElementById('feedbackOrderId').value);
                return;
            }

            // Ensure orderId is set in form before submission
            document.getElementById('feedbackOrderId').value = orderIdValue;

            const submitBtn = document.getElementById('submitBtn');
            const submitBtnText = document.getElementById('submitBtnText');
            submitBtn.disabled = true;
            submitBtnText.textContent = 'Submitting...';

            const formData = new FormData(this);
            
            // Debug: Log form data
            console.log('Submitting feedback with data:');
            for (let [key, value] of formData.entries()) {
                console.log(`  ${key}: ${value}`);
            }
            
            // Verify orderId in FormData
            const formOrderId = formData.get('orderId');
            if (!formOrderId || formOrderId.trim() === '') {
                showMessage('Error: Order ID not included. Please try again.', 'error');
                console.error('OrderID missing in FormData');
                submitBtn.disabled = false;
                submitBtnText.textContent = 'Submit Rating';
                return;
            }

            try {
                // Use contextPath variable instead of JSP expression in JavaScript
                const submitUrl = contextPath + '/submit-feedback';
                console.log('Submitting to URL:', submitUrl);
                
                // Build URLSearchParams from FormData to ensure proper encoding
                const params = new URLSearchParams();
                params.append('orderId', formOrderId);
                params.append('rating', formData.get('rating') || '');
                params.append('productId', formData.get('productId') || '1');
                const comment = formData.get('comment');
                if (comment) {
                    params.append('comment', comment);
                }
                
                console.log('Final submission params:');
                console.log('  orderId:', params.get('orderId'));
                console.log('  rating:', params.get('rating'));
                console.log('  productId:', params.get('productId'));
                console.log('  comment:', params.get('comment'));
                
                const response = await fetch(submitUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                    },
                    body: params.toString()
                });

                const result = await response.json();

                if (result.success) {
                    showMessage('✓ Thank you for your feedback! Page will reload...', 'success');
                    
                    setTimeout(() => {
                        window.location.reload();
                    }, 2000);
                } else {
                    showMessage('Error: ' + result.message, 'error');
                    submitBtn.disabled = false;
                    submitBtnText.textContent = 'Submit Rating';
                }
            } catch (error) {
                showMessage('Connection error: ' + error.message, 'error');
                submitBtn.disabled = false;
                submitBtnText.textContent = 'Submit Rating';
            }
        });

        function showMessage(message, type) {
            const messageDiv = document.getElementById('feedbackMessage');
            messageDiv.className = 'alert alert-' + type;
            messageDiv.innerHTML = '<strong>' + message + '</strong>';
            messageDiv.style.display = 'block';
            
            // Scroll to message
            messageDiv.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    </script>
</body>
</html>
