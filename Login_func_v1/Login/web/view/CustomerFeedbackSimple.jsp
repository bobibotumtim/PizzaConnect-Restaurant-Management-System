<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%@ page import="models.CustomerFeedback" %>
<%@ page import="models.FeedbackStats" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Feedback - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            background: linear-gradient(135deg, #fed7aa 0%, #ffffff 50%, #fee2e2 100%);
            min-height: 100vh;
        }
        .sidebar {
            width: 5rem;
            transition: width 0.3s ease;
        }
        .sidebar:hover {
            width: 16rem;
        }
        .sidebar-text {
            opacity: 0;
            white-space: nowrap;
            transition: opacity 0.3s ease;
        }
        .sidebar:hover .sidebar-text {
            opacity: 1;
        }
        .main-content {
            margin-left: 5rem;
            transition: margin-left 0.3s ease;
        }
    </style>
</head>
<body>
    <!-- Check authentication -->
    <%
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
            return;
        }
        
        String userName = currentUser.getName();
        List<CustomerFeedback> feedbackList = (List<CustomerFeedback>) request.getAttribute("feedbackList");
        FeedbackStats stats = (FeedbackStats) request.getAttribute("feedbackStats");
    %>

    <!-- Expandable Sidebar -->
    <div class="sidebar fixed left-0 top-0 h-full bg-gray-900 flex flex-col py-6 z-50 overflow-hidden">
        <!-- Logo -->
        <div class="flex items-center px-4 mb-8">
            <div class="text-3xl min-w-[3rem] flex justify-center">
                🍕
            </div>
            <span class="sidebar-text ml-3 text-white text-xl font-bold">PizzaConnect</span>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 flex flex-col space-y-2 px-3">
            <a href="${pageContext.request.contextPath}/manager-dashboard"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="home" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Dashboard</span>
            </a>

            <a href="${pageContext.request.contextPath}/inventorymonitor"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="package" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Inventory Monitor</span>
            </a>

            <a href="${pageContext.request.contextPath}/sales-reports"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="file-text" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Sales Reports</span>
            </a>

            <a href="${pageContext.request.contextPath}/profile"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="user-circle" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Edit Profile</span>
            </a>

            <a href="${pageContext.request.contextPath}/customer-feedback"
               class="flex items-center px-3 py-3 rounded-lg bg-orange-500 text-white">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="message-circle" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Customer Feedback</span>
            </a>
        </nav>
    </div>

    <!-- Top Navigation Bar -->
    <div class="fixed top-0 left-20 right-0 bg-white shadow-md border-b px-6 py-3 flex items-center justify-between z-40">
        <div class="text-2xl font-bold text-orange-600">🍕 PizzaConnect</div>
        <div class="flex items-center gap-3">
            <div class="text-right">
                <div class="font-semibold text-gray-800"><%= userName %></div>
                <div class="text-xs text-gray-500">Manager</div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 shadow-sm hover:shadow-md transition-all duration-200 flex items-center gap-2">
                <i data-lucide="log-out" class="w-4 h-4"></i>
                Logout
            </a>
        </div>
    </div>

    <!-- Main Content with left margin for sidebar -->
    <div class="main-content p-6 mt-16">

        <!-- Statistics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="bg-blue-500 text-white rounded-xl p-6 shadow-lg">
                <p class="text-sm opacity-80">Total Feedback</p>
                <p class="text-3xl font-bold"><%= stats != null ? stats.getTotalFeedback() : 0 %></p>
            </div>
            
            <div class="bg-green-500 text-white rounded-xl p-6 shadow-lg">
                <p class="text-sm opacity-80">Average Rating</p>
                <p class="text-3xl font-bold"><%= stats != null ? String.format("%.1f", stats.getAverageRating()) : "0.0" %>/5.0</p>
            </div>
            
            <div class="bg-purple-500 text-white rounded-xl p-6 shadow-lg">
                <p class="text-sm opacity-80">Positive Rate</p>
                <p class="text-3xl font-bold"><%= stats != null ? stats.getFormattedPositiveRate() : "0%" %></p>
            </div>
            
        </div>

        <!-- Search and Filter Section -->
        <div class="bg-white rounded-xl shadow-lg p-6 mb-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i data-lucide="search" class="inline-block w-5 h-5 mr-2 text-orange-500"></i>
                Search & Filter
            </h3>
            
            <form method="GET" action="${pageContext.request.contextPath}/customer-feedback" class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <!-- Search by Name -->
                    <div>
                        <label for="search" class="block text-sm font-medium text-gray-700 mb-2">
                            <i data-lucide="user" class="inline-block w-4 h-4 mr-1"></i>
                            Search by customer name
                        </label>
                        <input 
                            type="text" 
                            id="search" 
                            name="search" 
                            value="<%= request.getAttribute("searchTerm") != null ? request.getAttribute("searchTerm") : "" %>"
                            placeholder="Enter customer name..."
                            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                        />
                    </div>
                    
                    <!-- Filter by Rating -->
                    <div>
                        <label for="rating" class="block text-sm font-medium text-gray-700 mb-2">
                            <i data-lucide="star" class="inline-block w-4 h-4 mr-1"></i>
                            Filter by rating
                        </label>
                        <select 
                            id="rating" 
                            name="rating"
                            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                        >
                            <option value="all" <%= "all".equals(request.getAttribute("ratingFilter")) || request.getAttribute("ratingFilter") == null ? "selected" : "" %>>
                                All ratings
                            </option>
                            <option value="5" <%= "5".equals(request.getAttribute("ratingFilter")) ? "selected" : "" %>>
                                ★★★★★ (5 stars - Excellent)
                            </option>
                            <option value="4" <%= "4".equals(request.getAttribute("ratingFilter")) ? "selected" : "" %>>
                                ★★★★☆ (4 stars - Good)
                            </option>
                            <option value="3" <%= "3".equals(request.getAttribute("ratingFilter")) ? "selected" : "" %>>
                                ★★★☆☆ (3 stars - Average)
                            </option>
                            <option value="2" <%= "2".equals(request.getAttribute("ratingFilter")) ? "selected" : "" %>>
                                ★★☆☆☆ (2 stars - Poor)
                            </option>
                            <option value="1" <%= "1".equals(request.getAttribute("ratingFilter")) ? "selected" : "" %>>
                                ★☆☆☆☆ (1 star - Very Poor)
                            </option>
                        </select>
                    </div>
                </div>
                
                <!-- Action Buttons -->
                <div class="flex gap-3">
                    <button 
                        type="submit"
                        class="px-6 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition flex items-center gap-2"
                    >
                        <i data-lucide="search" class="w-4 h-4"></i>
                        Search
                    </button>
                    <a 
                        href="${pageContext.request.contextPath}/customer-feedback"
                        class="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition flex items-center gap-2"
                    >
                        <i data-lucide="x" class="w-4 h-4"></i>
                        Clear filters
                    </a>
                </div>
                
                <!-- Active Filters Display -->
                <% 
                    String searchTerm = (String) request.getAttribute("searchTerm");
                    String ratingFilter = (String) request.getAttribute("ratingFilter");
                    boolean hasFilters = (searchTerm != null && !searchTerm.trim().isEmpty()) || 
                                        (ratingFilter != null && !"all".equals(ratingFilter) && !ratingFilter.isEmpty());
                    
                    if (hasFilters) {
                %>
                    <div class="flex flex-wrap gap-2 pt-2 border-t">
                        <span class="text-sm text-gray-600">Active filters:</span>
                        <% if (searchTerm != null && !searchTerm.trim().isEmpty()) { %>
                            <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm flex items-center gap-1">
                                <i data-lucide="user" class="w-3 h-3"></i>
                                Name: <%= searchTerm %>
                            </span>
                        <% } %>
                        <% if (ratingFilter != null && !"all".equals(ratingFilter) && !ratingFilter.isEmpty()) { %>
                            <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm flex items-center gap-1">
                                <i data-lucide="star" class="w-3 h-3"></i>
                                <%= ratingFilter %> stars
                            </span>
                        <% } %>
                    </div>
                <% } %>
            </form>
        </div>

        <!-- Feedback List -->
        <div class="bg-white rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                Feedback List (<%= feedbackList != null ? feedbackList.size() : 0 %> items)
            </h3>
            
            <% if (feedbackList == null || feedbackList.isEmpty()) { %>
                <div class="text-center py-12">
                    <i data-lucide="inbox" class="w-16 h-16 mx-auto text-gray-400 mb-4"></i>
                    <h3 class="text-lg font-medium text-gray-900 mb-2">No feedback yet</h3>
                    <p class="text-gray-500">Customer feedback will appear here.</p>
                </div>
            <% } else { %>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <% for (CustomerFeedback feedback : feedbackList) { %>
                        <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
                            <!-- Customer Info -->
                            <div class="mb-4">
                                <h4 class="font-semibold text-gray-900"><%= feedback.getCustomerName() %></h4>
                                <p class="text-sm text-gray-500">ID: <%= feedback.getCustomerId() %></p>
                            </div>
                            
                            <!-- Rating -->
                            <div class="mb-4">
                                <div class="text-yellow-400 text-lg">
                                    <%= feedback.getStarRating() %>
                                </div>
                                <span class="text-xs px-2 py-1 rounded-full <%= feedback.getRating() >= 4 ? "bg-green-100 text-green-800" : feedback.getRating() == 3 ? "bg-yellow-100 text-yellow-800" : "bg-red-100 text-red-800" %>">
                                    <%= feedback.getRatingLevel() %>
                                </span>
                            </div>
                            
                            <!-- Order Info -->
                            <div class="mb-4 p-3 bg-white rounded-lg">
                                <p class="text-sm text-gray-600">Order #<%= feedback.getOrderId() %></p>
                                <p class="text-sm text-gray-800 font-medium"><%= feedback.getPizzaOrdered() %></p>
                            </div>
                            
                            <!-- Comment -->
                            <div class="mb-4 bg-white p-3 rounded-lg border border-gray-200">
                                <p class="text-xs text-gray-500 mb-1 font-semibold">Comment:</p>
                                <% 
                                    String comment = feedback.getComment();
                                    if (comment != null && !comment.trim().isEmpty() && !comment.equals("...")) {
                                %>
                                    <p class="text-gray-700 text-sm italic">"<%= comment %>"</p>
                                <% } else { %>
                                    <p class="text-gray-400 text-sm italic">No comment</p>
                                <% } %>
                            </div>
                            
                            <!-- Date -->
                            <div class="flex items-center justify-between pt-4 border-t">
                                <span class="text-xs text-gray-500"><%= feedback.getFeedbackDate() %></span>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
