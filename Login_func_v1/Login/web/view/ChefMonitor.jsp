<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chef Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f9f9fb;
            padding: 30px;
            font-family: 'Segoe UI', sans-serif;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .btn-done {
            background-color: #8fa8c8;
            color: black;
            font-weight: 600;
            border: none;
            padding: 10px 18px;
            border-radius: 6px;
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            margin-top: 25px;
            margin-bottom: 15px;
            padding: 12px 20px;
            border-radius: 8px;
            color: white;
            text-transform: uppercase;
            letter-spacing: 1px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .section-count {
            background: rgba(255,255,255,0.3);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: bold;
        }
        
        .section-waiting {
            background: linear-gradient(135deg, #4a7aff 0%, #3461e0 100%);
        }
        
        .section-preparing {
            background: linear-gradient(135deg, #f2b134 0%, #d99a1f 100%);
        }
        
        .section-ready {
            background: linear-gradient(135deg, #63f063 0%, #4ad84a 100%);
        }

        .dish-container {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }

        .dish-card {
            position: relative;
            width: 200px;
            min-height: 120px;
            border-radius: 10px;
            color: black;
            padding: 10px 12px;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            gap: 4px;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .dish-card:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 10px rgba(0,0,0,0.25);
        }

        .waiting { background-color: #4a7aff; color: white; }
        .ongoing { background-color: #f2b134; }

        .order-id { 
            font-weight: bold; 
            font-size: 14px; 
            margin-bottom: 2px;
        }
        .name { 
            font-size: 16px; 
            font-weight: 600; 
            line-height: 1.2;
            padding-right: 35px;
        }
        .quantity {
            position: absolute;
            top: 10px;
            right: 12px;
            font-size: 22px;
            font-weight: bold;
            background: rgba(255,255,255,0.3);
            padding: 2px 8px;
            border-radius: 5px;
        }
        .topping { 
            font-size: 11px; 
            line-height: 1.3;
            margin-top: 2px;
        }

        .selected {
            outline: 4px solid #333;
        }

        .button-row {
            text-align: center;
            margin: 20px 0;
        }

        .btn-action {
            border: none;
            padding: 10px 30px;
            font-size: 16px;
            font-weight: 600;
            margin: 0 10px;
            border-radius: 6px;
        }

        .btn-start { background-color: #b0c4ff; }
        .btn-ready { background-color: #63f063; }
        .btn-cancel { background-color: #ff6b6b; color: white; }
    </style>
</head>

<body>
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>
    
    <div class="content-wrapper">
        
        <!-- Alert Messages -->
        <c:if test="${not empty error}">
            <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg" style="margin: 20px;">
                <div style="display: flex; align-items: center;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    <span><strong>Error:</strong> ${error}</span>
                </div>
            </div>
            <script>
                // Reload page after 5 seconds to clear error and resume normal operation
                setTimeout(() => {
                    const url = new URL(window.location.href);
                    const category = url.searchParams.get('category');
                    if (category && category !== 'All') {
                        window.location.href = 'ChefMonitor?category=' + category;
                    } else {
                        window.location.href = 'ChefMonitor';
                    }
                }, 5000);
            </script>
        </c:if>
        <div class="top-bar">
            <div></div>
            <div>
                <button onclick="location.reload()" class="btn btn-primary">Refresh</button>
            </div>
        </div>
        
        <!-- Category Filter -->
        <div class="mb-4 p-3" style="background-color: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
            <div class="d-flex flex-wrap gap-2">
                <button type="button" class="btn ${selectedCategory == 'All' ? 'btn-primary' : 'btn-outline-primary'}" 
                        onclick="filterByCategory('All')" style="min-width: 100px;">
                    All
                </button>
                <c:forEach var="cat" items="${categories}">
                    <button type="button" class="btn ${selectedCategory == cat ? 'btn-primary' : 'btn-outline-primary'}" 
                            onclick="filterByCategory('${cat}')" style="min-width: 100px;">
                        ${cat}
                    </button>
                </c:forEach>
            </div>
        </div>

    <!-- ==================== Waiting Section ==================== -->
    <div>
        <div class="section-title section-waiting">
            <span>Waiting Dishes</span>
            <span class="section-count">${waitingList.size()} dishes</span>
        </div>
        <div id="waiting" class="dish-container">
            <c:forEach var="dish" items="${waitingList}">
                <div class="dish-card waiting" onclick="selectDish(this)" data-id="${dish.orderDetailID}">
                    <div class="order-id">#${dish.orderID}</div>
                    <div class="name">${dish.productName} 
                        <c:if test="${not empty dish.sizeName}">
                            <span style="font-size: 12px;">(${dish.sizeName})</span>
                        </c:if>
                    </div>
                    <div class="quantity">x${dish.quantity}</div>
                    <c:if test="${not empty dish.toppings}">
                        <div class="topping" style="font-weight: 600; color: #FFD700;">
                            + <c:forEach var="topping" items="${dish.toppings}" varStatus="status">${topping.toppingName}<c:if test="${!status.last}">, </c:if></c:forEach>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>

        <div class="button-row">
            <form id="startForm" action="ChefMonitor" method="post">
                <input type="hidden" name="action" value="start">
                <input type="hidden" id="selectedIdStart" name="orderDetailId">
                <input type="hidden" name="category" value="${selectedCategory}">
                <button type="submit" class="btn-action btn-start">▼ Start cooking ▼</button>
            </form>
        </div>

        <!-- ==================== Preparing Section ==================== -->
        <div class="section-title section-preparing">
            <span>Preparing Dishes</span>
            <span class="section-count">${preparingList.size()} dishes</span>
        </div>
        <div id="ongoing" class="dish-container">
            <c:forEach var="dish" items="${preparingList}">
                <div class="dish-card ongoing" onclick="selectDish(this)" data-id="${dish.orderDetailID}">
                    <div class="order-id">#${dish.orderID}</div>
                    <div class="name">${dish.productName}
                        <c:if test="${not empty dish.sizeName}">
                            <span style="font-size: 12px;">(${dish.sizeName})</span>
                        </c:if>
                    </div>
                    <div class="quantity">x${dish.quantity}</div>
                    <c:if test="${not empty dish.toppings}">
                        <div class="topping" style="font-weight: 600; color: #8B4513;">
                            + <c:forEach var="topping" items="${dish.toppings}" varStatus="status">${topping.toppingName}<c:if test="${!status.last}">, </c:if></c:forEach>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>

        <div class="button-row">
            <form id="readyForm" action="ChefMonitor" method="post" style="display:inline;">
                <input type="hidden" name="action" value="ready">
                <input type="hidden" id="selectedIdReady" name="orderDetailId">
                <input type="hidden" name="category" value="${selectedCategory}">
                <button type="submit" class="btn-action btn-ready">Ready to serve</button>
            </form>
            <form id="cancelFormPreparing" action="ChefMonitor" method="post" style="display:inline;">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" id="selectedIdCancelPreparing" name="orderDetailId">
                <input type="hidden" name="category" value="${selectedCategory}">
                <button type="submit" class="btn-action btn-cancel" onclick="return confirm('You want to cancel?')">✕ Cancel</button>
            </form>
        </div>

        <!-- ==================== Ready Section ==================== -->
        <div class="section-title section-ready">
            <span>Ready Dishes (Waiter will serve)</span>
            <span class="section-count">${readyList.size()} dishes</span>
        </div>
        <div id="ready" class="dish-container">
            <c:forEach var="dish" items="${readyList}">
                <div class="dish-card" style="background-color: #90EE90;" data-id="${dish.orderDetailID}">
                    <div class="order-id">#${dish.orderID}</div>
                    <div class="name">${dish.productName}
                        <c:if test="${not empty dish.sizeName}">
                            <span style="font-size: 12px;">(${dish.sizeName})</span>
                        </c:if>
                    </div>
                    <div class="quantity">x${dish.quantity}</div>
                    <c:if test="${not empty dish.toppings}">
                        <div class="topping" style="font-weight: 600; color: #228B22;">
                            + <c:forEach var="topping" items="${dish.toppings}" varStatus="status">${topping.toppingName}<c:if test="${!status.last}">, </c:if></c:forEach>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </div>
    </div>

    <script>
        let selectedDish = null;

        function selectDish(el) {
            document.querySelectorAll('.dish-card').forEach(d => d.classList.remove('selected'));
            el.classList.add('selected');
            selectedDish = el;

            const id = el.getAttribute('data-id');
            document.getElementById('selectedIdStart').value = id;
            document.getElementById('selectedIdReady').value = id;
            document.getElementById('selectedIdCancelPreparing').value = id;
        }
        
        function filterByCategory(category) {
            const url = new URL(window.location.href);
            if (category === 'All') {
                url.searchParams.delete('category');
            } else {
                url.searchParams.set('category', category);
            }
            window.location.href = url.toString();
        }
        
        // Auto-refresh every 10 seconds - KHÔNG refresh khi có error
        <c:if test="${empty error}">
            setTimeout(function() {
                location.reload();
            }, 10000);
        </c:if>
    </script>

</body>
</html>
