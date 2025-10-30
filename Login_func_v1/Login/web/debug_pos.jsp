<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.*, models.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>POS Debug Page</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { border: 1px solid #ccc; padding: 15px; margin: 10px 0; }
        .success { color: green; }
        .error { color: red; }
        .info { color: blue; }
        button { padding: 10px 20px; margin: 5px; }
    </style>
</head>
<body>
    <h1>🔧 POS System Debug Page</h1>
    
    <div class="test-section">
        <h2>1. Database Connection Test</h2>
        <%
        try {
            OrderDAO orderDAO = new OrderDAO();
            Connection conn = orderDAO.getConnection();
            if (conn != null && !conn.isClosed()) {
                out.println("<p class='success'>✅ Database connection successful!</p>");
                out.println("<p class='info'>Database: " + conn.getCatalog() + "</p>");
            } else {
                out.println("<p class='error'>❌ Database connection failed!</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>❌ Database connection error: " + e.getMessage() + "</p>");
        }
        %>
    </div>
    
    <div class="test-section">
        <h2>2. Table Existence Test</h2>
        <%
        try {
            OrderDAO orderDAO = new OrderDAO();
            Connection conn = orderDAO.getConnection();
            
            // Test Order table
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM [Order]");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p class='success'>✅ Order table exists (" + count + " records)</p>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p class='error'>❌ Order table missing: " + e.getMessage() + "</p>");
            }
            
            // Test Customer table
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Customer");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p class='success'>✅ Customer table exists (" + count + " records)</p>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p class='error'>❌ Customer table missing: " + e.getMessage() + "</p>");
            }
            
            // Test Product table
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Product");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p class='success'>✅ Product table exists (" + count + " records)</p>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p class='error'>❌ Product table missing: " + e.getMessage() + "</p>");
            }
            
            // Test OrderDetail table
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM OrderDetail");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p class='success'>✅ OrderDetail table exists (" + count + " records)</p>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p class='error'>❌ OrderDetail table missing: " + e.getMessage() + "</p>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>❌ Table test error: " + e.getMessage() + "</p>");
        }
        %>
    </div>
    
    <div class="test-section">
        <h2>3. Test Order Creation</h2>
        <button onclick="testOrderCreation()">Test Create Order</button>
        <div id="orderTestResult"></div>
    </div>
    
    <div class="test-section">
        <h2>4. Quick Actions</h2>
        <p><strong>If you see errors above, try these steps:</strong></p>
        <ol>
            <li>Make sure SQL Server is running</li>
            <li>Check database name in DBContext.java (currently: pizza_demo_DB2)</li>
            <li>Run POS_Database_Setup_Complete.sql in SQL Server Management Studio</li>
            <li>Refresh this page</li>
        </ol>
        
        <p><a href="pos.jsp">🍕 Go to POS System</a></p>
        <p><a href="ManageOrders">📋 Go to Order Management</a></p>
    </div>

    <script>
    function testOrderCreation() {
        const resultDiv = document.getElementById('orderTestResult');
        resultDiv.innerHTML = '<p class="info">🔄 Testing order creation...</p>';
        
        const testData = {
            customerName: "Test Customer",
            total: 150000,
            discount: 0,
            subtotal: 150000,
            items: [
                {id: 1, name: "Test Pizza", price: 150000, quantity: 1}
            ]
        };
        
        fetch('POS', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(testData)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                resultDiv.innerHTML = '<p class="success">✅ Order creation test successful! Order ID: ' + data.orderId + '</p>';
            } else {
                resultDiv.innerHTML = '<p class="error">❌ Order creation test failed: ' + data.message + '</p>';
            }
        })
        .catch(error => {
            resultDiv.innerHTML = '<p class="error">❌ Network error: ' + error.message + '</p>';
        });
    }
    </script>
</body>
</html>