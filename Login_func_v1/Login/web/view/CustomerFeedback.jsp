<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
            background: linear-gradient(135deg, #f97316, #ea580c);
        }
        .feedback-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        .feedback-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        .feedback-card:hover::before {
            left: 100%;
        }
        .feedback-card:hover {
            transform: translateY(-6px) scale(1.02);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15), 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }
        .feedback-card:active {
            transform: translateY(-2px) scale(1.01);
        }
        .feedback-card.urgent {
            border-left: 4px solid #ef4444;
            animation: pulse-urgent 2s infinite;
        }
        @keyframes pulse-urgent {
            0%, 100% { border-left-color: #ef4444; }
            50% { border-left-color: #fca5a5; }
        }
        .star-rating {
            color: #fbbf24;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
            transition: all 0.2s ease;
        }
        .star-rating:hover {
            transform: scale(1.1);
            filter: drop-shadow(0 2px 4px rgba(251, 191, 36, 0.3));
        }
        .rating-badge {
            transition: all 0.2s ease;
            backdrop-filter: blur(10px);
        }
        .rating-badge:hover {
            transform: scale(1.05);
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(4px);
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 1;
        }
        .modal-content {
            background: white;
            border-radius: 1rem;
            max-width: 600px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            transform: scale(0.9) translateY(20px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .modal.show .modal-content {
            transform: scale(1) translateY(0);
        }
        .modal-content::-webkit-scrollbar {
            width: 6px;
        }
        .modal-content::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 3px;
        }
        .modal-content::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }
        .modal-content::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
        /* Statistics Cards Enhancements */
        .stats-card {
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .stats-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
            transform: scale(0);
            transition: transform 0.6s ease;
        }
        .stats-card:hover::before {
            transform: scale(1);
        }
        .stats-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        
        /* Button Enhancements */
        .btn-primary {
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .btn-primary::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }
        .btn-primary:hover::before {
            width: 300px;
            height: 300px;
        }
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        /* Form Enhancements */
        .form-input {
            transition: all 0.3s ease;
            position: relative;
        }
        .form-input:focus {
            transform: translateY(-1px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        
        /* Loading Animations */
        @keyframes shimmer {
            0% { background-position: -200px 0; }
            100% { background-position: calc(200px + 100%) 0; }
        }
        .loading-shimmer {
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200px 100%;
            animation: shimmer 1.5s infinite;
        }
        
        /* Badge Animations */
        .status-badge {
            transition: all 0.2s ease;
            position: relative;
        }
        .status-badge:hover {
            transform: scale(1.05);
        }
        .status-badge.urgent {
            animation: pulse-badge 1.5s infinite;
        }
        @keyframes pulse-badge {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        /* Search Enhancements */
        .search-container {
            position: relative;
        }
        .search-container::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, #f97316, #ea580c);
            transform: translateX(-50%);
            transition: width 0.3s ease;
        }
        .search-container:focus-within::after {
            width: 100%;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .sidebar {
                width: 60px;
            }
            .main-content {
                margin-left: 60px;
            }
            .feedback-card:hover {
                transform: translateY(-3px) scale(1.01);
            }
            .modal-content {
                width: 95%;
                max-height: 95vh;
                margin: 2.5vh auto;
            }
            .stats-card {
                margin-bottom: 1rem;
            }
        }
        
        @media (max-width: 640px) {
            .main-content {
                margin-left: 0;
                padding: 1rem;
            }
            .feedback-card {
                margin-bottom: 1rem;
            }
            .modal-content {
                width: 98%;
                max-height: 98vh;
                margin: 1vh auto;
                border-radius: 0.5rem;
            }
        }
        
        /* Dark mode support (optional) */
        @media (prefers-color-scheme: dark) {
            .modal {
                background-color: rgba(0, 0, 0, 0.7);
            }
        }
        
        /* Print styles */
        @media print {
            .modal, .nav-btn, .search-container {
                display: none !important;
            }
            .feedback-card {
                break-inside: avoid;
                box-shadow: none;
                border: 1px solid #e5e7eb;
            }
        }
        
        /* Accessibility enhancements */
        .focus-visible:focus {
            outline: 2px solid #f97316;
            outline-offset: 2px;
        }
        
        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Authentication Check -->
    <c:if test="${empty sessionScope.user}">
        <c:redirect url="view/Home.jsp"/>
    </c:if>
    
    <!-- Role Check: Only Admin (1) and Employee (2) can access -->
    <c:if test="${sessionScope.user.role != 1 && sessionScope.user.role != 2}">
        <c:redirect url="view/Home.jsp"/>
    </c:if>

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
        <c:if test="${not empty errorMessage}">
            <div class="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                    <span>${errorMessage}</span>
                </div>
            </div>
        </c:if>
        
        <c:if test="${not empty message}">
            <div class="mb-6 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                    <span>${message}</span>
                </div>
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="x-circle" class="w-5 h-5 mr-2"></i>
                    <span>${error}</span>
                </div>
            </div>
        </c:if>

        <!-- Success/Error Messages -->
        <c:if test="${not empty param.message}">
            <div class="mb-6 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                    ${param.message}
                </div>
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                    ${error}
                </div>
            </div>
        </c:if>

        <!-- Statistics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <!-- Total Feedback -->
            <div class="stats-card bg-white rounded-xl shadow-lg p-6 card-gradient-blue text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-blue-100 text-sm font-medium">Tổng Phản Hồi</p>
                        <p class="text-3xl font-bold">${feedbackStats.totalFeedback}</p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="message-square" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>

            <!-- Average Rating -->
            <div class="stats-card bg-white rounded-xl shadow-lg p-6 card-gradient-green text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-green-100 text-sm font-medium">Đánh Giá TB</p>
                        <p class="text-3xl font-bold">${feedbackStats.formattedAverageRating}/5.0</p>
                        <p class="text-green-100 text-xs">${feedbackStats.overallRatingLevel}</p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="star" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>

            <!-- Positive Rate -->
            <div class="stats-card bg-white rounded-xl shadow-lg p-6 card-gradient-purple text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-purple-100 text-sm font-medium">Tỷ Lệ Tích Cực</p>
                        <p class="text-3xl font-bold">${feedbackStats.formattedPositiveRate}</p>
                        <p class="text-purple-100 text-xs">${feedbackStats.positiveFeedback}/${feedbackStats.totalFeedback} phản hồi</p>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="thumbs-up" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>

            <!-- Pending Response -->
            <div class="stats-card bg-white rounded-xl shadow-lg p-6 card-gradient-orange text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-orange-100 text-sm font-medium">Chờ Phản Hồi</p>
                        <p class="text-3xl font-bold">${feedbackStats.pendingResponse}</p>
                        <c:if test="${urgentCount > 0}">
                            <p class="text-orange-100 text-xs">⚠️ ${urgentCount} cần xử lý gấp</p>
                        </c:if>
                    </div>
                    <div class="bg-white bg-opacity-20 rounded-lg p-3">
                        <i data-lucide="clock" class="w-8 h-8"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filter Form -->
        <div class="bg-white rounded-xl shadow-lg p-6 mb-8">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i data-lucide="search" class="inline-block w-5 h-5 mr-2"></i>
                Tìm Kiếm & Lọc
            </h3>
            
            <form method="POST" action="customer-feedback" class="space-y-4">
                <input type="hidden" name="action" value="search">
                
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <!-- Search Term -->
                    <div class="search-container">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Tìm kiếm</label>
                        <input type="text" name="searchTerm" value="${searchTerm}" 
                               placeholder="Tên khách hàng, bình luận, pizza..."
                               class="form-input w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                    </div>
                    
                    <!-- Rating Filter -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Đánh giá</label>
                        <select name="ratingFilter" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                            <option value="all" ${ratingFilter == 'all' ? 'selected' : ''}>Tất cả</option>
                            <option value="5" ${ratingFilter == '5' ? 'selected' : ''}>⭐⭐⭐⭐⭐ (5 sao)</option>
                            <option value="4" ${ratingFilter == '4' ? 'selected' : ''}>⭐⭐⭐⭐ (4 sao)</option>
                            <option value="3" ${ratingFilter == '3' ? 'selected' : ''}>⭐⭐⭐ (3 sao)</option>
                            <option value="2" ${ratingFilter == '2' ? 'selected' : ''}>⭐⭐ (2 sao)</option>
                            <option value="1" ${ratingFilter == '1' ? 'selected' : ''}>⭐ (1 sao)</option>
                        </select>
                    </div>
                    
                    <!-- Response Status Filter -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Trạng thái</label>
                        <select name="responseFilter" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                            <option value="all" ${responseFilter == 'all' ? 'selected' : ''}>Tất cả</option>
                            <option value="pending" ${responseFilter == 'pending' ? 'selected' : ''}>Chờ phản hồi</option>
                            <option value="responded" ${responseFilter == 'responded' ? 'selected' : ''}>Đã phản hồi</option>
                        </select>
                    </div>
                    
                    <!-- Search Button -->
                    <div class="flex items-end">
                        <button type="submit" class="btn-primary w-full bg-orange-500 hover:bg-orange-600 text-white font-medium py-2 px-4 rounded-lg transition-colors">
                            <i data-lucide="search" class="w-4 h-4 mr-2 inline-block"></i>
                            Tìm kiếm
                        </button>
                    </div>
                </div>
                
                <c:if test="${searchPerformed}">
                    <div class="flex items-center justify-between pt-2 border-t">
                        <p class="text-sm text-gray-600">
                            Tìm thấy <strong>${feedbackList.size()}</strong> kết quả
                        </p>
                        <a href="customer-feedback" class="text-orange-500 hover:text-orange-600 text-sm font-medium">
                            <i data-lucide="x" class="w-4 h-4 mr-1 inline-block"></i>
                            Xóa bộ lọc
                        </a>
                    </div>
                </c:if>
            </form>
        </div>

        <!-- Feedback List -->
        <div class="bg-white rounded-xl shadow-lg">
            <div class="p-6 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">
                    <i data-lucide="list" class="inline-block w-5 h-5 mr-2"></i>
                    Danh Sách Phản Hồi
                    <span class="text-sm font-normal text-gray-500">(${feedbackList.size()} phản hồi)</span>
                </h3>
            </div>
            
            <div class="p-6">
                <c:choose>
                    <c:when test="${empty feedbackList}">
                        <div class="text-center py-12">
                            <i data-lucide="inbox" class="w-16 h-16 mx-auto text-gray-400 mb-4"></i>
                            <h3 class="text-lg font-medium text-gray-900 mb-2">Không có phản hồi nào</h3>
                            <p class="text-gray-500">
                                <c:choose>
                                    <c:when test="${searchPerformed}">
                                        Không tìm thấy phản hồi nào phù hợp với tiêu chí tìm kiếm.
                                    </c:when>
                                    <c:otherwise>
                                        Chưa có phản hồi nào từ khách hàng.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
                            <c:forEach var="feedback" items="${feedbackList}">
                                <div class="feedback-card ${feedback.needsUrgentAttention ? 'urgent' : ''} bg-gray-50 rounded-lg p-6 border border-gray-200" 
                                     onclick="showFeedbackDetail('${feedback.feedbackId}', '${feedback.customerName}', '${feedback.customerId}', '${feedback.orderId}', '${feedback.orderDate}', '${feedback.orderTime}', '${feedback.rating}', '${feedback.comment}', '${feedback.feedbackDate}', '${feedback.pizzaOrdered}', '${feedback.response}', '${feedback.hasResponse}')"
                                    
                                    <!-- Header -->
                                    <div class="flex items-start justify-between mb-4">
                                        <div class="flex-1">
                                            <h4 class="font-semibold text-gray-900">${feedback.customerName}</h4>
                                            <p class="text-sm text-gray-500">ID: ${feedback.customerId}</p>
                                        </div>
                                        <div class="text-right">
                                            <div class="star-rating text-lg mb-1">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <c:choose>
                                                        <c:when test="${i <= feedback.rating}">⭐</c:when>
                                                        <c:otherwise>☆</c:otherwise>
                                                    </c:choose>
                                                </c:forEach>
                                            </div>
                                            <span class="rating-badge text-xs px-2 py-1 rounded-full
                                                <c:choose>
                                                    <c:when test="${feedback.rating >= 4}">bg-green-100 text-green-800</c:when>
                                                    <c:when test="${feedback.rating == 3}">bg-yellow-100 text-yellow-800</c:when>
                                                    <c:otherwise>bg-red-100 text-red-800</c:otherwise>
                                                </c:choose>">
                                                ${feedback.ratingLevel}
                                            </span>
                                        </div>
                                    </div>
                                    
                                    <!-- Order Info -->
                                    <div class="mb-4 p-3 bg-white rounded-lg">
                                        <div class="flex items-center text-sm text-gray-600 mb-2">
                                            <i data-lucide="shopping-bag" class="w-4 h-4 mr-2"></i>
                                            Đơn hàng #${feedback.orderId} - 
                                            <fmt:formatDate value="${feedback.orderDate}" pattern="dd/MM/yyyy"/>
                                        </div>
                                        <p class="text-sm text-gray-800 font-medium truncate">${feedback.pizzaOrdered}</p>
                                    </div>
                                    
                                    <!-- Comment -->
                                    <div class="mb-4">
                                        <p class="text-gray-700 text-sm line-clamp-3">
                                            "${feedback.comment}"
                                        </p>
                                    </div>
                                    
                                    <!-- Footer -->
                                    <div class="flex items-center justify-between pt-4 border-t border-gray-200">
                                        <div class="text-xs text-gray-500">
                                            <fmt:formatDate value="${feedback.feedbackDate}" pattern="dd/MM/yyyy"/>
                                        </div>
                                        <div class="flex items-center">
                                            <c:choose>
                                                <c:when test="${feedback.hasResponse}">
                                                    <span class="status-badge text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full">
                                                        <i data-lucide="check" class="w-3 h-3 mr-1 inline-block"></i>
                                                        Đã phản hồi
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge ${feedback.needsUrgentAttention ? 'urgent' : ''} text-xs px-2 py-1 
                                                        <c:choose>
                                                            <c:when test="${feedback.needsUrgentAttention}">bg-red-100 text-red-800</c:when>
                                                            <c:otherwise>bg-orange-100 text-orange-800</c:otherwise>
                                                        </c:choose> rounded-full">
                                                        <i data-lucide="clock" class="w-3 h-3 mr-1 inline-block"></i>
                                                        <c:choose>
                                                            <c:when test="${feedback.needsUrgentAttention}">Cần xử lý gấp</c:when>
                                                            <c:otherwise>Chờ phản hồi</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Feedback Detail Modal -->
    <div id="feedbackModal" class="modal">
        <div class="modal-content">
            <div class="p-6">
                <!-- Modal Header -->
                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-xl font-semibold text-gray-900">Chi Tiết Phản Hồi</h3>
                    <button onclick="closeModal()" class="text-gray-400 hover:text-gray-600">
                        <i data-lucide="x" class="w-6 h-6"></i>
                    </button>
                </div>
                
                <!-- Modal Content will be populated by JavaScript -->
                <div id="modalContent">
                    <div class="text-center py-8">
                        <i data-lucide="loader" class="w-8 h-8 mx-auto text-gray-400 animate-spin mb-4"></i>
                        <p class="text-gray-500">Đang tải...</p>
                    </div>
                </div>
                
                <!-- Modal Template (hidden, will be cloned by JavaScript) -->
                <div id="modalTemplate" style="display: none;">
                    <!-- Customer Info -->
                    <div class="bg-gray-50 rounded-lg p-4 mb-6">
                        <div class="flex items-center justify-between mb-3">
                            <div>
                                <h4 class="font-semibold text-gray-900" id="modal-customerName"></h4>
                                <p class="text-sm text-gray-500">ID: <span id="modal-customerId"></span></p>
                            </div>
                            <div class="text-right">
                                <div class="star-rating text-xl mb-1" id="modal-starRating"></div>
                                <span class="text-sm px-3 py-1 rounded-full" id="modal-ratingBadge">
                                    <span id="modal-ratingLevel"></span>
                                </span>
                            </div>
                        </div>
                        
                        <!-- Order Info -->
                        <div class="bg-white rounded-lg p-3">
                            <div class="flex items-center text-sm text-gray-600 mb-2">
                                <i data-lucide="shopping-bag" class="w-4 h-4 mr-2"></i>
                                Đơn hàng #<span id="modal-orderId"></span> - 
                                <span id="modal-orderDate"></span> lúc <span id="modal-orderTime"></span>
                            </div>
                            <div class="text-sm text-gray-800">
                                <strong>Pizza đã order:</strong>
                                <p id="modal-pizzaOrdered" class="mt-1"></p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Feedback Content -->
                    <div class="mb-6">
                        <h5 class="font-medium text-gray-900 mb-3">
                            <i data-lucide="message-square" class="w-4 h-4 mr-2 inline-block"></i>
                            Nội dung phản hồi
                        </h5>
                        <div class="bg-blue-50 border-l-4 border-blue-400 p-4 rounded-r-lg">
                            <p class="text-gray-700" id="modal-comment"></p>
                        </div>
                        <div class="text-xs text-gray-500 mt-2">
                            Phản hồi vào ngày: <span id="modal-feedbackDate"></span>
                        </div>
                    </div>
                    
                    <!-- Current Response (if exists) -->
                    <div id="modal-currentResponse" class="mb-6" style="display: none;">
                        <h5 class="font-medium text-gray-900 mb-3">
                            <i data-lucide="reply" class="w-4 h-4 mr-2 inline-block"></i>
                            Phản hồi hiện tại
                        </h5>
                        <div class="bg-green-50 border-l-4 border-green-400 p-4 rounded-r-lg">
                            <p class="text-gray-700" id="modal-response"></p>
                        </div>
                    </div>
                    
                    <!-- Response Form -->
                    <div id="modal-responseForm">
                        <h5 class="font-medium text-gray-900 mb-3">
                            <i data-lucide="edit" class="w-4 h-4 mr-2 inline-block"></i>
                            <span id="modal-responseTitle">Gửi phản hồi</span>
                        </h5>
                        
                        <form method="POST" action="customer-feedback" id="responseForm">
                            <input type="hidden" name="action" value="respond">
                            <input type="hidden" name="id" id="modal-feedbackId">
                            
                            <div class="mb-4">
                                <textarea name="response" id="modal-responseText" rows="4" 
                                         placeholder="Nhập phản hồi của bạn cho khách hàng (10-1000 ký tự)..."
                                         class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 resize-none"
                                         required minlength="10" maxlength="1000"></textarea>
                                <div class="flex justify-between mt-1">
                                    <p class="text-xs text-gray-500">Tối thiểu 10 ký tự, tối đa 1000 ký tự</p>
                                    <p class="text-xs text-gray-500">
                                        <span id="charCount">0</span>/1000
                                    </p>
                                </div>
                            </div>
                            
                            <div class="flex justify-end space-x-3">
                                <button type="button" onclick="closeModal()" 
                                        class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                                    Hủy
                                </button>
                                <button type="submit" 
                                        class="px-4 py-2 bg-orange-500 hover:bg-orange-600 text-white rounded-lg transition-colors">
                                    <i data-lucide="send" class="w-4 h-4 mr-2 inline-block"></i>
                                    Gửi phản hồi
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Initialize Lucide Icons -->
    <script>
        lucide.createIcons();
        
        // Global variables
        let currentFeedbackData = null;
        
        // ===== MODAL MANAGEMENT FUNCTIONS =====
        
        /**
         * Show feedback detail modal with direct data
         */
        function showFeedbackDetail(feedbackId, customerName, customerId, orderId, orderDate, orderTime, rating, comment, feedbackDate, pizzaOrdered, response, hasResponse) {
            const modal = document.getElementById('feedbackModal');
            
            // Create data object
            const data = {
                feedbackId: feedbackId,
                customerName: customerName,
                customerId: customerId,
                orderId: orderId,
                orderDate: orderDate,
                orderTime: orderTime,
                rating: parseInt(rating),
                comment: comment,
                feedbackDate: feedbackDate,
                pizzaOrdered: pizzaOrdered,
                response: response,
                hasResponse: hasResponse === 'true'
            };
            
            // Show modal
            modal.classList.add('show');
            
            // Populate modal with data
            currentFeedbackData = data;
            populateModal(data);
        }
        
        /**
         * Close modal and reset state
         */
        function closeModal() {
            const modal = document.getElementById('feedbackModal');
            modal.classList.remove('show');
            currentFeedbackData = null;
            
            // Reset form if exists
            const form = document.getElementById('responseForm');
            if (form) {
                form.reset();
                updateCharCount();
            }
        }
        
        /**
         * Populate modal with feedback data
         */
        function populateModal(data) {
            const modalContent = document.getElementById('modalContent');
            const template = document.getElementById('modalTemplate');
            
            // Clone template content
            modalContent.innerHTML = template.innerHTML;
            
            // Populate customer info
            document.getElementById('modal-customerName').textContent = data.customerName;
            document.getElementById('modal-customerId').textContent = data.customerId;
            document.getElementById('modal-orderId').textContent = data.orderId;
            document.getElementById('modal-orderDate').textContent = formatDate(data.orderDate);
            document.getElementById('modal-orderTime').textContent = formatTime(data.orderTime);
            document.getElementById('modal-pizzaOrdered').textContent = data.pizzaOrdered;
            
            // Populate rating
            document.getElementById('modal-starRating').textContent = getStarRating(data.rating);
            document.getElementById('modal-ratingLevel').textContent = getRatingLevel(data.rating);
            
            // Set rating badge color
            const ratingBadge = document.getElementById('modal-ratingBadge');
            if (data.rating >= 4) {
                ratingBadge.className = 'text-sm px-3 py-1 rounded-full bg-green-100 text-green-800';
            } else if (data.rating === 3) {
                ratingBadge.className = 'text-sm px-3 py-1 rounded-full bg-yellow-100 text-yellow-800';
            } else {
                ratingBadge.className = 'text-sm px-3 py-1 rounded-full bg-red-100 text-red-800';
            }
            
            // Populate feedback content
            document.getElementById('modal-comment').textContent = data.comment;
            document.getElementById('modal-feedbackDate').textContent = formatDate(data.feedbackDate);
            document.getElementById('modal-feedbackId').value = data.feedbackId;
            
            // Handle current response
            const currentResponseDiv = document.getElementById('modal-currentResponse');
            const responseForm = document.getElementById('modal-responseForm');
            const responseTitle = document.getElementById('modal-responseTitle');
            const responseTextarea = document.getElementById('modal-responseText');
            
            if (data.hasResponse && data.response) {
                // Show current response
                currentResponseDiv.style.display = 'block';
                document.getElementById('modal-response').textContent = data.response;
                
                // Update form for editing response
                responseTitle.textContent = 'Cập nhật phản hồi';
                responseTextarea.value = data.response;
                responseTextarea.placeholder = 'Cập nhật phản hồi của bạn...';
            } else {
                // Hide current response section
                currentResponseDiv.style.display = 'none';
                
                // Set form for new response
                responseTitle.textContent = 'Gửi phản hồi';
                responseTextarea.value = '';
                responseTextarea.placeholder = 'Nhập phản hồi của bạn cho khách hàng (10-1000 ký tự)...';
            }
            
            // Initialize character counter
            updateCharCount();
            
            // Add event listener for character counter
            responseTextarea.addEventListener('input', updateCharCount);
            
            // Initialize response form
            initializeResponseForm();
            
            // Re-initialize Lucide icons
            lucide.createIcons();
        }
        
        /**
         * Format date for display
         */
        function formatDate(dateString) {
            if (!dateString) return '';
            const date = new Date(dateString);
            return date.toLocaleDateString('vi-VN', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            });
        }
        
        /**
         * Format time for display
         */
        function formatTime(timeString) {
            if (!timeString) return '';
            // timeString format: "HH:mm:ss" or "HH:mm:ss.SSS"
            const timeParts = timeString.split(':');
            if (timeParts.length >= 2) {
                return `${timeParts[0]}:${timeParts[1]}`;
            }
            return timeString;
        }
        
        /**
         * Get star rating display
         */
        function getStarRating(rating) {
            let stars = '';
            for (let i = 1; i <= 5; i++) {
                if (i <= rating) {
                    stars += '★';
                } else {
                    stars += '☆';
                }
            }
            return stars;
        }
        
        /**
         * Get rating level text
         */
        function getRatingLevel(rating) {
            switch (rating) {
                case 5: return 'Xuất sắc';
                case 4: return 'Tốt';
                case 3: return 'Trung bình';
                case 2: return 'Kém';
                case 1: return 'Rất kém';
                default: return 'Chưa đánh giá';
            }
        }
        
        // ===== EVENT LISTENERS =====
        
        // Close modal when clicking outside
        document.getElementById('feedbackModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });
        
        // Close modal with Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const modal = document.getElementById('feedbackModal');
                if (modal.classList.contains('show')) {
                    closeModal();
                }
            }
        });
        
        // ===== UTILITY FUNCTIONS =====
        
        /**
         * Update character counter for response textarea
         */
        function updateCharCount() {
            const textarea = document.getElementById('modal-responseText');
            const charCount = document.getElementById('charCount');
            
            if (textarea && charCount) {
                const currentLength = textarea.value.length;
                charCount.textContent = currentLength;
                
                // Update color based on length
                if (currentLength < 10) {
                    charCount.className = 'text-red-500';
                } else if (currentLength > 900) {
                    charCount.className = 'text-orange-500';
                } else {
                    charCount.className = 'text-gray-500';
                }
            }
        }
        
        // ===== RESPONSE SUBMISSION FUNCTIONS =====
        
        /**
         * Submit response with validation and loading state
         */
        function submitResponse(event) {
            event.preventDefault();
            
            const form = event.target;
            const textarea = document.getElementById('modal-responseText');
            const submitButton = form.querySelector('button[type="submit"]');
            const responseText = textarea.value.trim();
            
            // Validate response text
            if (!validateResponse(responseText)) {
                return false;
            }
            
            // Show loading state
            const originalButtonText = submitButton.innerHTML;
            submitButton.disabled = true;
            submitButton.innerHTML = `
                <i data-lucide="loader" class="w-4 h-4 mr-2 inline-block animate-spin"></i>
                Đang gửi...
            `;
            lucide.createIcons();
            
            // Create form data
            const formData = new FormData(form);
            
            // Submit form using fetch
            fetch('customer-feedback', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (response.redirected) {
                    // If redirected, it means success - reload the page
                    window.location.href = response.url;
                    return;
                }
                return response.text();
            })
            .then(data => {
                if (typeof data === 'string') {
                    // If we get HTML back, there was an error
                    showResponseError('Có lỗi xảy ra khi gửi phản hồi. Vui lòng thử lại.');
                }
            })
            .catch(error => {
                console.error('Error submitting response:', error);
                showResponseError('Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.');
            })
            .finally(() => {
                // Restore button state
                submitButton.disabled = false;
                submitButton.innerHTML = originalButtonText;
                lucide.createIcons();
            });
            
            return false;
        }
        
        /**
         * Validate response text
         */
        function validateResponse(responseText) {
            const textarea = document.getElementById('modal-responseText');
            
            // Clear previous error styling
            textarea.classList.remove('border-red-500', 'focus:ring-red-500', 'focus:border-red-500');
            
            // Remove existing error message
            const existingError = document.getElementById('response-error');
            if (existingError) {
                existingError.remove();
            }
            
            // Check if empty
            if (!responseText) {
                showValidationError(textarea, 'Vui lòng nhập nội dung phản hồi');
                return false;
            }
            
            // Check minimum length
            if (responseText.length < 10) {
                showValidationError(textarea, 'Phản hồi phải có ít nhất 10 ký tự');
                return false;
            }
            
            // Check maximum length
            if (responseText.length > 1000) {
                showValidationError(textarea, 'Phản hồi không được vượt quá 1000 ký tự');
                return false;
            }
            
            return true;
        }
        
        /**
         * Show validation error for textarea
         */
        function showValidationError(textarea, message) {
            // Add error styling
            textarea.classList.add('border-red-500', 'focus:ring-red-500', 'focus:border-red-500');
            
            // Create error message element
            const errorDiv = document.createElement('div');
            errorDiv.id = 'response-error';
            errorDiv.className = 'mt-2 text-sm text-red-600';
            errorDiv.innerHTML = `
                <i data-lucide="alert-circle" class="w-4 h-4 mr-1 inline-block"></i>
                ${message}
            `;
            
            // Insert error message after textarea
            textarea.parentNode.insertBefore(errorDiv, textarea.nextSibling);
            
            // Focus on textarea
            textarea.focus();
            
            // Re-initialize icons
            lucide.createIcons();
        }
        
        /**
         * Show response submission error
         */
        function showResponseError(message) {
            const modalContent = document.getElementById('modalContent');
            
            // Create error alert
            const errorAlert = document.createElement('div');
            errorAlert.className = 'mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg';
            errorAlert.innerHTML = `
                <div class="flex items-center">
                    <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                    ${message}
                </div>
            `;
            
            // Insert at top of modal content
            modalContent.insertBefore(errorAlert, modalContent.firstChild);
            
            // Re-initialize icons
            lucide.createIcons();
            
            // Auto-remove after 5 seconds
            setTimeout(() => {
                if (errorAlert.parentNode) {
                    errorAlert.remove();
                }
            }, 5000);
        }
        
        /**
         * Initialize response form event listeners
         */
        function initializeResponseForm() {
            // This will be called after modal is populated
            const form = document.getElementById('responseForm');
            if (form) {
                form.addEventListener('submit', submitResponse);
            }
        }
        
        // ===== INTERACTIVE FEATURES =====
        
        /**
         * Initialize all interactive features when page loads
         */
        function initializeInteractiveFeatures() {
            // Initialize search form enhancements
            initializeSearchForm();
            
            // Initialize feedback card interactions
            initializeFeedbackCards();
            
            // Initialize keyboard shortcuts
            initializeKeyboardShortcuts();
            
            // Initialize tooltips and help text
            initializeTooltips();
        }
        
        /**
         * Initialize search form with real-time validation and enhancements
         */
        function initializeSearchForm() {
            const searchForm = document.querySelector('form[action="customer-feedback"]');
            const searchInput = document.querySelector('input[name="searchTerm"]');
            const ratingSelect = document.querySelector('select[name="ratingFilter"]');
            const responseSelect = document.querySelector('select[name="responseFilter"]');
            
            if (searchForm) {
                // Add loading state to search button
                searchForm.addEventListener('submit', function(e) {
                    const submitButton = this.querySelector('button[type="submit"]');
                    if (submitButton) {
                        const originalText = submitButton.innerHTML;
                        submitButton.disabled = true;
                        submitButton.innerHTML = `
                            <i data-lucide="loader" class="w-4 h-4 mr-2 inline-block animate-spin"></i>
                            Đang tìm...
                        `;
                        lucide.createIcons();
                        
                        // Re-enable after a short delay (form will submit)
                        setTimeout(() => {
                            submitButton.disabled = false;
                            submitButton.innerHTML = originalText;
                            lucide.createIcons();
                        }, 1000);
                    }
                });
                
                // Auto-submit on filter change (optional enhancement)
                if (ratingSelect) {
                    ratingSelect.addEventListener('change', function() {
                        // Optional: Auto-submit when filter changes
                        // searchForm.submit();
                    });
                }
                
                if (responseSelect) {
                    responseSelect.addEventListener('change', function() {
                        // Optional: Auto-submit when filter changes
                        // searchForm.submit();
                    });
                }
            }
            
            // Add search input enhancements
            if (searchInput) {
                // Add clear button when there's text
                searchInput.addEventListener('input', function() {
                    toggleClearButton(this);
                });
                
                // Initialize clear button state
                toggleClearButton(searchInput);
            }
        }
        
        /**
         * Toggle clear button for search input
         */
        function toggleClearButton(input) {
            const container = input.parentNode;
            let clearButton = container.querySelector('.clear-search-btn');
            
            if (input.value.trim()) {
                if (!clearButton) {
                    clearButton = document.createElement('button');
                    clearButton.type = 'button';
                    clearButton.className = 'clear-search-btn absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600';
                    clearButton.innerHTML = '<i data-lucide="x" class="w-4 h-4"></i>';
                    clearButton.addEventListener('click', function() {
                        input.value = '';
                        input.focus();
                        toggleClearButton(input);
                    });
                    
                    // Make container relative if not already
                    if (getComputedStyle(container).position === 'static') {
                        container.style.position = 'relative';
                    }
                    
                    container.appendChild(clearButton);
                    lucide.createIcons();
                }
            } else if (clearButton) {
                clearButton.remove();
            }
        }
        
        /**
         * Initialize feedback card interactions
         */
        function initializeFeedbackCards() {
            const feedbackCards = document.querySelectorAll('.feedback-card');
            
            feedbackCards.forEach(card => {
                // Add keyboard accessibility
                card.setAttribute('tabindex', '0');
                card.setAttribute('role', 'button');
                card.setAttribute('aria-label', 'Xem chi tiết phản hồi');
                
                // Add keyboard support
                card.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault();
                        this.click();
                    }
                });
                
                // Add visual feedback on focus
                card.addEventListener('focus', function() {
                    this.classList.add('ring-2', 'ring-orange-500', 'ring-opacity-50');
                });
                
                card.addEventListener('blur', function() {
                    this.classList.remove('ring-2', 'ring-orange-500', 'ring-opacity-50');
                });
            });
        }
        
        /**
         * Initialize keyboard shortcuts
         */
        function initializeKeyboardShortcuts() {
            document.addEventListener('keydown', function(e) {
                // Ctrl/Cmd + K to focus search
                if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                    e.preventDefault();
                    const searchInput = document.querySelector('input[name="searchTerm"]');
                    if (searchInput) {
                        searchInput.focus();
                        searchInput.select();
                    }
                }
                
                // Ctrl/Cmd + F to focus search (alternative)
                if ((e.ctrlKey || e.metaKey) && e.key === 'f') {
                    const searchInput = document.querySelector('input[name="searchTerm"]');
                    if (searchInput && document.activeElement !== searchInput) {
                        e.preventDefault();
                        searchInput.focus();
                        searchInput.select();
                    }
                }
            });
        }
        
        /**
         * Initialize tooltips and help text
         */
        function initializeTooltips() {
            // Add tooltips to statistics cards
            const statsCards = document.querySelectorAll('[class*="card-gradient-"]');
            const tooltips = [
                'Tổng số phản hồi đã nhận từ khách hàng',
                'Điểm đánh giá trung bình từ tất cả phản hồi',
                'Tỷ lệ phần trăm phản hồi tích cực (4-5 sao)',
                'Số phản hồi chưa được staff trả lời'
            ];
            
            statsCards.forEach((card, index) => {
                if (tooltips[index]) {
                    card.setAttribute('title', tooltips[index]);
                }
            });
            
            // Add help text for search
            const searchInput = document.querySelector('input[name="searchTerm"]');
            if (searchInput) {
                searchInput.setAttribute('title', 'Tìm kiếm theo tên khách hàng, nội dung bình luận, hoặc tên pizza (Ctrl+K)');
            }
        }
        
        /**
         * Show loading overlay for page transitions
         */
        function showPageLoading() {
            const overlay = document.createElement('div');
            overlay.id = 'page-loading-overlay';
            overlay.className = 'fixed inset-0 bg-white bg-opacity-75 flex items-center justify-center z-50';
            overlay.innerHTML = `
                <div class="text-center">
                    <i data-lucide="loader" class="w-8 h-8 mx-auto text-orange-500 animate-spin mb-4"></i>
                    <p class="text-gray-600">Đang tải...</p>
                </div>
            `;
            
            document.body.appendChild(overlay);
            lucide.createIcons();
            
            // Auto-remove after 10 seconds (fallback)
            setTimeout(() => {
                const existingOverlay = document.getElementById('page-loading-overlay');
                if (existingOverlay) {
                    existingOverlay.remove();
                }
            }, 10000);
        }
        
        /**
         * Hide loading overlay
         */
        function hidePageLoading() {
            const overlay = document.getElementById('page-loading-overlay');
            if (overlay) {
                overlay.remove();
            }
        }
        
        /**
         * Smooth scroll to element
         */
        function smoothScrollTo(elementId) {
            const element = document.getElementById(elementId);
            if (element) {
                element.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        }
        
        /**
         * Show success message
         */
        function showSuccessMessage(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'fixed top-4 right-4 z-50 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg shadow-lg';
            alertDiv.innerHTML = `
                <div class="flex items-center">
                    <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                    ${message}
                    <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-green-500 hover:text-green-700">
                        <i data-lucide="x" class="w-4 h-4"></i>
                    </button>
                </div>
            `;
            
            document.body.appendChild(alertDiv);
            lucide.createIcons();
            
            // Auto-remove after 5 seconds
            setTimeout(() => {
                if (alertDiv.parentNode) {
                    alertDiv.remove();
                }
            }, 5000);
        }
        
        // ===== INITIALIZATION =====
        
        /**
         * Initialize everything when DOM is loaded
         */
        document.addEventListener('DOMContentLoaded', function() {
            initializeInteractiveFeatures();
        });
    </script>
</body>
</html>