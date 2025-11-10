<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Waiter Monitor - Serve Dishes</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .monitor-container {
            max-width: 1400px;
            margin: 0 auto;
        }
        .header-section {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .status-section {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .dish-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 4px solid #28a745;
            transition: all 0.3s;
        }
        .dish-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        .dish-card.ready {
            border-left-color: #ffc107;
            animation: pulse 2s infinite;
        }
        .dish-card.served {
            border-left-color: #28a745;
            opacity: 0.8;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
        .btn-served {
            background: #28a745;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 5px;
            transition: all 0.3s;
        }
        .btn-served:hover {
            background: #218838;
            transform: scale(1.05);
        }
        .badge-ready {
            background: #ffc107;
            color: #000;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.9em;
        }
        .badge-served {
            background: #28a745;
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.9em;
        }
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #6c757d;
        }
        .notification-bell {
            position: relative;
            display: inline-block;
        }
        .notification-count {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #dc3545;
            color: white;
            border-radius: 50%;
            padding: 2px 6px;
            font-size: 0.75em;
        }
    </style>
</head>
<body>
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>
    
    <div class="content-wrapper">
        <div class="monitor-container">
            <!-- Header -->
            <div class="header-section">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="fas fa-bell"></i> Waiter Monitor - Serve Dishes</h2>
                        <p class="text-muted mb-0">Track ready dishes and serve customers</p>
                    </div>
                </div>
            </div>

        <!-- Error Message -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Ready Section -->
        <div class="status-section">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4>
                    <span class="notification-bell">
                        <i class="fas fa-bell text-warning"></i>
                        <c:if test="${not empty readyList}">
                            <span class="notification-count">${readyList.size()}</span>
                        </c:if>
                    </span>
                    READY TO SERVE
                </h4>
                <span class="badge bg-warning text-dark">${readyList.size()} dishes</span>
            </div>

            <c:choose>
                <c:when test="${empty readyList}">
                    <div class="empty-state">
                        <i class="fas fa-check-circle fa-3x mb-3"></i>
                        <p>No dishes ready to serve</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${readyList}">
                        <div class="dish-card ready">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <h5 class="mb-1">
                                        <i class="fas fa-utensils text-warning"></i>
                                        ${item.productName} (${item.sizeCode})
                                    </h5>
                                    <p class="mb-1">
                                        <strong>Order #${item.orderID}</strong>
                                        <span class="badge badge-ready ms-2">Ready</span>
                                    </p>
                                    <p class="mb-0 text-muted">
                                        <i class="fas fa-info-circle"></i>
                                        Quantity: ${item.quantity} | 
                                        <c:if test="${not empty item.specialInstructions}">
                                            Note: ${item.specialInstructions}
                                        </c:if>
                                    </p>
                                </div>
                                <div class="col-md-3 text-center">
                                    <small class="text-muted">
                                        <i class="fas fa-clock"></i>
                                        Completed: ${item.endTime}
                                    </small>
                                </div>
                                <div class="col-md-3 text-end">
                                    <form method="post" action="WaiterMonitor" style="display: inline;">
                                        <input type="hidden" name="action" value="served">
                                        <input type="hidden" name="orderDetailId" value="${item.orderDetailID}">
                                        <input type="hidden" name="orderId" value="${item.orderID}">
                                        <button type="submit" class="btn-served">
                                            <i class="fas fa-check"></i> Served
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Served Section -->
        <div class="status-section">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4>
                    <i class="fas fa-check-circle text-success"></i>
                    SERVED
                </h4>
                <span class="badge bg-success">${servedList.size()} dishes</span>
            </div>

            <c:choose>
                <c:when test="${empty servedList}">
                    <div class="empty-state">
                        <i class="fas fa-inbox fa-3x mb-3"></i>
                        <p>No dishes served yet</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${servedList}">
                        <div class="dish-card served">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <h5 class="mb-1">
                                        <i class="fas fa-utensils text-success"></i>
                                        ${item.productName} (${item.sizeCode})
                                    </h5>
                                    <p class="mb-1">
                                        <strong>Order #${item.orderID}</strong>
                                        <span class="badge badge-served ms-2">Served</span>
                                    </p>
                                    <p class="mb-0 text-muted">
                                        <i class="fas fa-info-circle"></i>
                                        Quantity: ${item.quantity}
                                    </p>
                                </div>
                                <div class="col-md-6 text-end">
                                    <small class="text-muted">
                                        <i class="fas fa-clock"></i>
                                        Served at: ${item.endTime}
                                    </small>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-refresh every 10 seconds
        setTimeout(function() {
            location.reload();
        }, 10000);

        // Play notification sound when there are ready items
        <c:if test="${not empty readyList}">
            // You can add audio notification here
            console.log('${readyList.size()} dishes ready to serve!');
        </c:if>
    </script>
</body>
</html>
