<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chef Dashboard</title>

    <!-- Bootstrap 5 -->
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

        .btn-start {
            background-color: #b0c4ff;
        }

        .btn-ready {
            background-color: #63f063;
        }

        .btn-cancel {
            background-color: #ff6666;
            color: white;
        }
    </style>
</head>
<body>

    <div class="top-bar">
        <h2 class="fw-bold">Chef Dashboard</h2>
        <button class="btn-done">Done dishes</button>
    </div>

    <div>
        <div class="section-title">Waiting dishes</div>
        <div id="waiting" class="dish-container">
            <div class="dish-card waiting" onclick="selectDish(this)">
                <div class="order-id">#12</div>
                <div class="name">Pizza A</div>
                <div class="quantity">2</div>
                <div class="topping">+ Cheese</div>
            </div>

            <div class="dish-card waiting" onclick="selectDish(this)">
                <div class="order-id">#12</div>
                <div class="name">Pizza B</div>
                <div class="quantity">1</div>
            </div>

            <div class="dish-card waiting" onclick="selectDish(this)">
                <div class="order-id">#13</div>
                <div class="name">Pizza C</div>
                <div class="quantity">1</div>
            </div>

            <div class="dish-card waiting" onclick="selectDish(this)">
                <div class="order-id">#14</div>
                <div class="name">Spaghetti Carbonara</div>
                <div class="quantity">2</div>
            </div>
        </div>

        <div class="button-row">
            <button class="btn-action btn-start" onclick="startCooking()">▼ Start cooking ▼</button>
        </div>

        <div class="section-title">Ongoing dishes</div>
        <div id="ongoing" class="dish-container">
            <div class="dish-card ongoing" onclick="selectDish(this)">
                <div class="order-id">#9</div>
                <div class="name">Pizza A</div>
                <div class="quantity">1</div>
                <div class="topping">+ Tomato</div>
            </div>

            <div class="dish-card ongoing" onclick="selectDish(this)">
                <div class="order-id">#10</div>
                <div class="name">Caesar Salad</div>
                <div class="quantity">3</div>
            </div>

            <div class="dish-card ongoing" onclick="selectDish(this)">
                <div class="order-id">#11</div>
                <div class="name">Pizza B</div>
                <div class="quantity">1</div>
            </div>
        </div>

        <div class="button-row">
            <button class="btn-action btn-ready" onclick="readyToServe()">Ready to serve</button>
            <button class="btn-action btn-cancel" onclick="cancelDish()">Cancel dishes</button>
        </div>
    </div>

    <script>
        let selectedDish = null;

        function selectDish(el) {
            document.querySelectorAll('.dish-card').forEach(d => d.classList.remove('selected'));
            el.classList.add('selected');
            selectedDish = el;
        }

        function startCooking() {
            if (!selectedDish || !selectedDish.classList.contains('waiting')) {
                alert("Please select a waiting dish first!");
                return;
            }
            selectedDish.classList.remove('waiting');
            selectedDish.classList.add('ongoing');
            document.getElementById('ongoing').appendChild(selectedDish);
            selectedDish.classList.remove('selected');
            selectedDish = null;
        }

        function readyToServe() {
            if (!selectedDish || !selectedDish.classList.contains('ongoing')) {
                alert("Please select an ongoing dish to mark ready!");
                return;
            }
            selectedDish.remove();
            selectedDish = null;
            alert("Dish marked as ready to serve!");
        }

        function cancelDish() {
            if (!selectedDish) {
                alert("Select a dish to cancel!");
                return;
            }
            selectedDish.remove();
            selectedDish = null;
        }
    </script>

</body>
</html>
