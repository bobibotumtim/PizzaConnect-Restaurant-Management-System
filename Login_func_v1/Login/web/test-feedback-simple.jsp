<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
  <head>
    <title>Test Feedback - Simple</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 50px auto;
        padding: 20px;
      }
      h1 {
        color: #333;
      }
      .test-link {
        display: block;
        padding: 15px;
        margin: 10px 0;
        background: #667eea;
        color: white;
        text-decoration: none;
        border-radius: 8px;
        text-align: center;
      }
      .test-link:hover {
        background: #5568d3;
      }
      .info {
        background: #f0f0f0;
        padding: 15px;
        border-radius: 8px;
        margin: 20px 0;
      }
    </style>
  </head>
  <body>
    <h1>🧪 Test Feedback System</h1>

    <div class="info">
      <h3>Hướng dẫn:</h3>
      <p>Click vào các link bên dưới để test từng trang feedback.</p>
      <p>
        <strong>Lưu ý:</strong> Thay orderId=4 bằng OrderID thật từ database của
        bạn.
      </p>
    </div>

    <h2>Test Pages:</h2>

    <a
      href="<%= request.getContextPath() %>/feedback-prompt?orderId=4"
      class="test-link"
    >
      1. Test Feedback Prompt (orderId=4)
    </a>

    <a
      href="<%= request.getContextPath() %>/feedback-form?orderId=4"
      class="test-link"
    >
      2. Test Feedback Form (orderId=4)
    </a>

    <a
      href="<%= request.getContextPath() %>/feedback-confirmation?orderId=4&rating=5"
      class="test-link"
    >
      3. Test Confirmation Page (orderId=4, rating=5)
    </a>

    <hr />

    <h2>Kiểm tra Orders:</h2>
    <div class="info">
      <p>Chạy query này trong SQL Server để lấy Order IDs:</p>
      <pre>
SELECT TOP 5 OrderID, CustomerID, TotalPrice, PaymentStatus 
FROM [Order] 
ORDER BY OrderDate DESC;</pre
      >
    </div>

    <h2>Test với Order IDs khác:</h2>
    <form method="get" action="<%= request.getContextPath() %>/feedback-prompt">
      <label>Nhập Order ID:</label>
      <input type="number" name="orderId" value="4" required />
      <button type="submit">Test Feedback Prompt</button>
    </form>
  </body>
</html>
