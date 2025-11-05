<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.DBContext" %>
<%@ page import="models.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    // Check authentication - only admin and employees can access
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
        response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
        return;
    }
    
    // Get filter parameters
    String searchTerm = request.getParameter("searchTerm");
    String ratingFilter = request.getParameter("ratingFilter");
    String responseFilter = request.getParameter("responseFilter");
    
    // Get data directly from database
    List<Map<String, Object>> feedbackList = new ArrayList<>();
    Map<String, Object> stats = new HashMap<>();
    String errorMessage = null;
    
    try {
        DBContext dbContext = new DBContext();
        Connection conn = dbContext.getConnection();
        
        if (conn != null) {
            // Get statistics (always show all stats)
            String statsSQL = "SELECT " +
                            "COUNT(*) as total_feedback, " +
                            "AVG(CAST(rating AS FLOAT)) as avg_rating, " +
                            "COUNT(CASE WHEN rating >= 4 THEN 1 END) as positive_feedback, " +
                            "COUNT(CASE WHEN has_response = 0 THEN 1 END) as pending_response " +
                            "FROM customer_feedback";
            PreparedStatement statsPs = conn.prepareStatement(statsSQL);
            ResultSet statsRs = statsPs.executeQuery();
            
            if (statsRs.next()) {
                stats.put("totalFeedback", statsRs.getInt("total_feedback"));
                stats.put("averageRating", statsRs.getDouble("avg_rating"));
                stats.put("positiveFeedback", statsRs.getInt("positive_feedback"));
                stats.put("pendingResponse", statsRs.getInt("pending_response"));
            }
            statsRs.close();
            statsPs.close();
            
            // Build filtered query
            StringBuilder dataSQL = new StringBuilder("SELECT * FROM customer_feedback WHERE 1=1");
            List<Object> parameters = new ArrayList<>();
            
            // Add search filter
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                dataSQL.append(" AND (customer_name LIKE ? OR comment LIKE ?)");
                parameters.add("%" + searchTerm.trim() + "%");
                parameters.add("%" + searchTerm.trim() + "%");
            }
            
            // Add rating filter
            if (ratingFilter != null && !ratingFilter.trim().isEmpty()) {
                dataSQL.append(" AND rating = ?");
                parameters.add(Integer.parseInt(ratingFilter));
            }
            
            // Add response filter
            if (responseFilter != null && !responseFilter.trim().isEmpty()) {
                if ("responded".equals(responseFilter)) {
                    dataSQL.append(" AND has_response = 1");
                } else if ("pending".equals(responseFilter)) {
                    dataSQL.append(" AND has_response = 0");
                }
            }
            
            dataSQL.append(" ORDER BY feedback_date DESC, created_at DESC");
            
            PreparedStatement dataPs = conn.prepareStatement(dataSQL.toString());
            
            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                dataPs.setObject(i + 1, parameters.get(i));
            }
            
            ResultSet dataRs = dataPs.executeQuery();
            
            while (dataRs.next()) {
                Map<String, Object> feedback = new HashMap<>();
                feedback.put("feedbackId", dataRs.getInt("feedback_id"));
                feedback.put("customerId", dataRs.getString("customer_id"));
                feedback.put("customerName", dataRs.getString("customer_name"));
                feedback.put("orderId", dataRs.getInt("order_id"));
                feedback.put("orderDate", dataRs.getDate("order_date"));
                feedback.put("orderTime", dataRs.getTime("order_time"));
                feedback.put("rating", dataRs.getInt("rating"));
                feedback.put("comment", dataRs.getString("comment"));
                feedback.put("feedbackDate", dataRs.getDate("feedback_date"));
                feedback.put("pizzaOrdered", dataRs.getString("pizza_ordered"));
                feedback.put("response", dataRs.getString("response"));
                feedback.put("hasResponse", dataRs.getBoolean("has_response"));
                
                // Add utility methods as map entries
                int rating = dataRs.getInt("rating");
                String starRating = "";
                for (int i = 1; i <= 5; i++) {
                    starRating += (i <= rating) ? "★" : "☆";
                }
                feedback.put("starRating", starRating);
                
                String ratingLevel = "";
                switch (rating) {
                    case 5: ratingLevel = "Xuất sắc"; break;
                    case 4: ratingLevel = "Tốt"; break;
                    case 3: ratingLevel = "Trung bình"; break;
                    case 2: ratingLevel = "Kém"; break;
                    case 1: ratingLevel = "Rất kém"; break;
                    default: ratingLevel = "Chưa đánh giá"; break;
                }
                feedback.put("ratingLevel", ratingLevel);
                feedback.put("needsUrgentAttention", rating <= 2 && !dataRs.getBoolean("has_response"));
                
                feedbackList.add(feedback);
            }
            dataRs.close();
            dataPs.close();
            conn.close();
            
        } else {
            errorMessage = "Không thể kết nối database";
        }
        
    } catch (Exception e) {
        errorMessage = "Lỗi database: " + e.getMessage();
        e.printStackTrace();
    }
    
    // Set data for JSP
    request.setAttribute("feedbackList", feedbackList);
    request.setAttribute("feedbackStats", stats);
    if (errorMessage != null) {
        request.setAttribute("errorMessage", errorMessage);
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Phản Hồi Khách Hàng - PizzaConnect</title>
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
        .nav-btn:hover {
            transform: translateY(-2px);
        }
        .gradient-bg {
            background: linear-gradient(135deg, #fed7aa 0%, #ffffff 50%, #fee2e2 100%);
        }
        .card-gradient-blue {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
        }
        .card-gradient-green {
            background: linear-gradient(135deg, #10b981, #059669);
        }
        .card-gradient-purple {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }
        .card-gradient-orange {
            background: linear-gradient(135deg, #f59e0b, #d97706);
        }
        .feedback-card {
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .feedback-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
        .feedback-card.urgent {
            border-left: 4px solid #ef4444;
        }
        .star-rating {
            color: #fbbf24;
        }
    </style>
</head>
<body class="gradient-bg min-h-screen">
    <!-- Include Sidebar Navigation -->
    <jsp:include page="partials/Sidebar.jsp">
        <jsp:param name="activePage" value="feedback"/>
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content ml-20 p-6">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex items-center justify-between">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">
                        <i data-lucide="message-circle" class="inline-block w-8 h-8 mr-3 text-orange-500"></i>
                        Quản Lý Phản Hồi Khách Hàng
                    </h1>
                    <p class="text-gray-600">Theo dõi và phản hồi ý kiến khách hàng về dịch vụ</p>
                </div>
                <div class="text-right">
                    <p class="text-sm text-gray-500">Xin chào, <strong>${sessionScope.user.name}</strong></p>
                    <p class="text-xs text-gray-400">
                        <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                </div>
            </div>
        </div>

        <!-- Error/Success Messages -->
        <% if (errorMessage != null) { %>
            <div class="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                    <span><%= errorMessage %></span>
                </div>
            </div>
        <% } %>

        <!-- Statistics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="card-gradient-blue text-white rounded-xl p-6 shadow-lg">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-blue-100 text-sm font-medium">Tổng Phản Hồi</p>
                        <p class="text-3xl font-bold"><%= stats.get("totalFeedback") != null ? stats.get("totalFeedback") : 0 %></p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="message-square" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>

            <div class="card-gradient-green text-white rounded-xl p-6 shadow-lg">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-green-100 text-sm font-medium">Đánh Giá TB</p>
                        <p class="text-3xl font-bold">
                            <%= stats.get("averageRating") != null ? String.format("%.1f", (Double)stats.get("averageRating")) : "0.0" %>
                        </p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="star" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>

            <div class="card-gradient-purple text-white rounded-xl p-6 shadow-lg">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-purple-100 text-sm font-medium">Tích Cực</p>
                        <p class="text-3xl font-bold"><%= stats.get("positiveFeedback") != null ? stats.get("positiveFeedback") : 0 %></p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="thumbs-up" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>

            <div class="card-gradient-orange text-white rounded-xl p-6 shadow-lg">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-orange-100 text-sm font-medium">Chờ Phản Hồi</p>
                        <p class="text-3xl font-bold"><%= stats.get("pendingResponse") != null ? stats.get("pendingResponse") : 0 %></p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="clock" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filter -->
        <div class="bg-white rounded-xl shadow-lg p-6 mb-8">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900">
                    <i data-lucide="search" class="w-5 h-5 mr-2 inline-block"></i>
                    Tìm Kiếm & Lọc
                </h3>
                <div class="flex items-center space-x-2 text-sm text-gray-500">
                    <i data-lucide="info" class="w-4 h-4"></i>
                    <span>Nhấn "Lọc" để áp dụng bộ lọc</span>
                </div>
            </div>
            
            <form method="GET" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tìm kiếm</label>
                    <input type="text" name="searchTerm" 
                           placeholder="Tên khách hàng, nội dung..."
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                           value="<%= searchTerm != null ? searchTerm : "" %>">
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Đánh giá</label>
                    <select name="ratingFilter" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                        <option value="">Tất cả</option>
                        <option value="5" <%= "5".equals(ratingFilter) ? "selected" : "" %>>5 sao</option>
                        <option value="4" <%= "4".equals(ratingFilter) ? "selected" : "" %>>4 sao</option>
                        <option value="3" <%= "3".equals(ratingFilter) ? "selected" : "" %>>3 sao</option>
                        <option value="2" <%= "2".equals(ratingFilter) ? "selected" : "" %>>2 sao</option>
                        <option value="1" <%= "1".equals(ratingFilter) ? "selected" : "" %>>1 sao</option>
                    </select>
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Trạng thái</label>
                    <select name="responseFilter" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                        <option value="">Tất cả</option>
                        <option value="responded" <%= "responded".equals(responseFilter) ? "selected" : "" %>>Đã phản hồi</option>
                        <option value="pending" <%= "pending".equals(responseFilter) ? "selected" : "" %>>Chờ phản hồi</option>
                    </select>
                </div>
                
                <div class="flex items-end space-x-2">
                    <button type="submit" class="flex-1 bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg transition-colors">
                        <i data-lucide="search" class="w-4 h-4 mr-2 inline-block"></i>
                        Lọc
                    </button>
                    <a href="<%= request.getRequestURI() %>" class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors">
                        <i data-lucide="x" class="w-4 h-4"></i>
                    </a>
                </div>
            </form>
        </div>

        <!-- Feedback List -->
        <div class="bg-white rounded-xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
                <div>
                    <h3 class="text-lg font-semibold text-gray-900">
                        <i data-lucide="list" class="w-5 h-5 mr-2 inline-block"></i>
                        Danh Sách Phản Hồi
                    </h3>
                    <% 
                    // Show active filters
                    List<String> activeFilters = new ArrayList<>();
                    if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                        activeFilters.add("Tìm kiếm: \"" + searchTerm + "\"");
                    }
                    if (ratingFilter != null && !ratingFilter.trim().isEmpty()) {
                        activeFilters.add("Đánh giá: " + ratingFilter + " sao");
                    }
                    if (responseFilter != null && !responseFilter.trim().isEmpty()) {
                        String statusText = "responded".equals(responseFilter) ? "Đã phản hồi" : "Chờ phản hồi";
                        activeFilters.add("Trạng thái: " + statusText);
                    }
                    
                    if (!activeFilters.isEmpty()) {
                    %>
                        <div class="flex flex-wrap gap-2 mt-2">
                            <% for (String filter : activeFilters) { %>
                                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                                    <i data-lucide="filter" class="w-3 h-3 mr-1"></i>
                                    <%= filter %>
                                </span>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                <span class="text-sm text-gray-500">
                    Hiển thị: <%= feedbackList.size() %> phản hồi
                    <% if (!activeFilters.isEmpty()) { %>
                        / <%= stats.get("totalFeedback") %> tổng
                    <% } %>
                </span>
            </div>

            <% if (feedbackList.isEmpty()) { %>
                <div class="text-center py-12">
                    <i data-lucide="inbox" class="w-16 h-16 mx-auto text-gray-300 mb-4"></i>
                    <h3 class="text-lg font-medium text-gray-900 mb-2">Chưa có phản hồi nào</h3>
                    <p class="text-gray-500">Khi khách hàng gửi phản hồi, chúng sẽ hiển thị ở đây.</p>
                    <% if (errorMessage == null) { %>
                        <p class="text-sm text-blue-600 mt-2">
                            <a href="debug-feedback.jsp" class="underline">Debug database</a> để kiểm tra dữ liệu
                        </p>
                    <% } %>
                </div>
            <% } else { %>
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <% for (Map<String, Object> feedback : feedbackList) { %>
                        <div class="feedback-card <%= (Boolean)feedback.get("needsUrgentAttention") ? "urgent" : "" %> bg-gray-50 rounded-lg p-6 border border-gray-200">
                            
                            <!-- Header -->
                            <div class="flex items-start justify-between mb-4">
                                <div class="flex-1">
                                    <h4 class="font-semibold text-gray-900"><%= feedback.get("customerName") %></h4>
                                    <p class="text-sm text-gray-500">ID: <%= feedback.get("customerId") %></p>
                                </div>
                                <div class="text-right">
                                    <div class="star-rating text-lg mb-1">
                                        <%= feedback.get("starRating") %>
                                    </div>
                                    <% 
                                        int rating = (Integer)feedback.get("rating");
                                        String badgeClass = "";
                                        if (rating >= 4) {
                                            badgeClass = "bg-green-100 text-green-800";
                                        } else if (rating == 3) {
                                            badgeClass = "bg-yellow-100 text-yellow-800";
                                        } else {
                                            badgeClass = "bg-red-100 text-red-800";
                                        }
                                    %>
                                    <span class="rating-badge text-xs px-2 py-1 rounded-full <%= badgeClass %>">
                                        <%= feedback.get("ratingLevel") %>
                                    </span>
                                </div>
                            </div>
                            
                            <!-- Order Info -->
                            <div class="mb-4 p-3 bg-white rounded-lg">
                                <div class="flex items-center text-sm text-gray-600 mb-2">
                                    <i data-lucide="shopping-bag" class="w-4 h-4 mr-2"></i>
                                    Đơn hàng #<%= feedback.get("orderId") %> - 
                                    <%= feedback.get("orderDate") %>
                                </div>
                                <p class="text-sm text-gray-800 font-medium"><%= feedback.get("pizzaOrdered") %></p>
                            </div>
                            
                            <!-- Comment -->
                            <div class="mb-4">
                                <p class="text-gray-700 text-sm">
                                    "<%= feedback.get("comment") %>"
                                </p>
                            </div>
                            
                            <!-- Footer -->
                            <div class="flex items-center justify-between pt-4 border-t border-gray-200">
                                <div class="text-xs text-gray-500">
                                    <%= feedback.get("feedbackDate") %>
                                </div>
                                <div class="flex items-center">
                                    <% if ((Boolean)feedback.get("hasResponse")) { %>
                                        <span class="status-badge text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full">
                                            <i data-lucide="check-circle" class="w-3 h-3 mr-1 inline-block"></i>
                                            Đã phản hồi
                                        </span>
                                    <% } else { %>
                                        <span class="status-badge text-xs px-2 py-1 bg-orange-100 text-orange-800 rounded-full">
                                            <i data-lucide="clock" class="w-3 h-3 mr-1 inline-block"></i>
                                            Chờ phản hồi
                                        </span>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Initialize Lucide Icons -->
    <script>
        lucide.createIcons();
        
        // Auto-submit form when filter changes (optional)
        document.addEventListener('DOMContentLoaded', function() {
            const ratingFilter = document.querySelector('select[name="ratingFilter"]');
            const responseFilter = document.querySelector('select[name="responseFilter"]');
            
            // Optional: Auto-submit when dropdown changes
            // Uncomment if you want instant filtering
            /*
            ratingFilter.addEventListener('change', function() {
                this.form.submit();
            });
            
            responseFilter.addEventListener('change', function() {
                this.form.submit();
            });
            */
            
            // Highlight urgent feedback
            const urgentCards = document.querySelectorAll('.feedback-card.urgent');
            urgentCards.forEach(card => {
                card.style.animation = 'pulse 2s infinite';
            });
        });
        
        // Add pulse animation for urgent feedback
        const style = document.createElement('style');
        style.textContent = `
            @keyframes pulse {
                0%, 100% { opacity: 1; }
                50% { opacity: 0.8; }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>