<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chef Dashboard</title>

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
            font-size: 22px;
            font-weight: 600;
            margin-top: 25px;
            margin-bottom: 15px;
            text-decoration: underline;
        }

        .dish-container {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }

        .dish-card {
            position: relative;
            width: 150px;
            height: 100px;
            border-radius: 10px;
            color: black;
            padding: 8px 10px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
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

        .order-id { font-weight: bold; font-size: 14px; }
        .name { font-size: 18px; font-weight: 600; }
        .quantity {
            position: absolute;
            top: 8px;
            right: 10px;
            font-size: 20px;
            font-weight: bold;
        }
        .topping { font-size: 13px; }

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
        .btn-cancel { background-color: #ff6666; color: white; }
    </style>
</head>

<body>

    <div class="top-bar">
        <h2 class="fw-bold">Chef Dashboard</h2>
        <form action="ChefServlet" method="get">
            <button type="submit" name="action" value="doneList" class="btn-done">Done dishes</button>
        </form>
    </div>

    <!-- ==================== Waiting Section ==================== -->
    <div>
        <div class="section-title">Waiting dishes</div>
        <div id="waiting" class="dish-container">
            <c:forEach var="dish" items="${pendingList}">
                <div class="dish-card waiting" onclick="selectDish(this)" data-id="${dish.orderDetailId}">
                    <div class="order-id">#${dish.orderId}</div>
                    <div class="name">${dish.productName}</div>
                    <div class="quantity">${dish.quantity}</div>
                    <div class="topping">${dish.specialInstructions}</div>
                </div>
            </c:forEach>
        </div>

        <div class="button-row">
            <form id="startForm" action="ChefServlet" method="post">
                <input type="hidden" name="action" value="startCooking">
                <input type="hidden" id="selectedIdStart" name="orderDetailId">
                <button type="submit" class="btn-action btn-start">▼ Start cooking ▼</button>
            </form>
        </div>

        <!-- ==================== Ongoing Section ==================== -->
        <div class="section-title">Ongoing dishes</div>
        <div id="ongoing" class="dish-container">
            <c:forEach var="dish" items="${cookingList}">
                <div class="dish-card ongoing" onclick="selectDish(this)" data-id="${dish.orderDetailId}">
                    <div class="order-id">#${dish.orderId}</div>
                    <div class="name">${dish.productName}</div>
                    <div class="quantity">${dish.quantity}</div>
                    <div class="topping">${dish.specialInstructions}</div>
                </div>
            </c:forEach>
        </div>

        <div class="button-row">
            <form id="doneForm" action="ChefServlet" method="post" style="display:inline;">
                <input type="hidden" name="action" value="doneDish">
                <input type="hidden" id="selectedIdDone" name="orderDetailId">
                <button type="submit" class="btn-action btn-ready">Ready to serve</button>
            </form>

            <form id="cancelForm" action="ChefServlet" method="post" style="display:inline;">
                <input type="hidden" name="action" value="cancelDish">
                <input type="hidden" id="selectedIdCancel" name="orderDetailId">
                <button type="submit" class="btn-action btn-cancel">Cancel dishes</button>
            </form>
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
            document.getElementById('selectedIdDone').value = id;
            document.getElementById('selectedIdCancel').value = id;
        }
    </script>

</body>
</html>
