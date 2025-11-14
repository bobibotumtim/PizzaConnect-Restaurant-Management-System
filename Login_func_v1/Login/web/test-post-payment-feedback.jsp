<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ page
import="dao.CustomerFeedbackDAO" %> <%@ page import="models.CustomerFeedback" %>
<%@ page import="java.sql.Timestamp" %>
<!DOCTYPE html>
<html>
  <head>
    <title>Test Post-Payment Feedback Methods</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        padding: 20px;
        background-color: #f5f5f5;
      }
      .container {
        max-width: 800px;
        margin: 0 auto;
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      h1 {
        color: #333;
        border-bottom: 2px solid #4caf50;
        padding-bottom: 10px;
      }
      .test-section {
        margin: 20px 0;
        padding: 15px;
        background: #f9f9f9;
        border-left: 4px solid #4caf50;
      }
      .success {
        color: #4caf50;
        font-weight: bold;
      }
      .error {
        color: #f44336;
        font-weight: bold;
      }
      .info {
        color: #2196f3;
      }
      pre {
        background: #263238;
        color: #aed581;
        padding: 10px;
        border-radius: 4px;
        overflow-x: auto;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>🧪 Test Post-Payment Feedback Methods</h1>

      <% CustomerFeedbackDAO dao = new CustomerFeedbackDAO(); // Test 1:
      hasFeedbackForOrder out.println("
      <div class="test-section">
        "); out.println("
        <h3>Test 1: hasFeedbackForOrder()</h3>
        "); try { int testOrderId = 4; // Order ID từ dữ liệu mẫu boolean
        hasFeedback = dao.hasFeedbackForOrder(testOrderId); out.println("
        <p class="info">Testing with OrderID: " + testOrderId + "</p>
        "); out.println("
        <p class="success">
          ✅ Result: " + (hasFeedback ? "Feedback exists" : "No feedback found")
          + "
        </p>
        "); } catch (Exception e) { out.println("
        <p class="error">❌ Error: " + e.getMessage() + "</p>
        "); } out.println("
      </div>
      "); // Test 2: getFeedbackByOrderId out.println("
      <div class="test-section">
        "); out.println("
        <h3>Test 2: getFeedbackByOrderId()</h3>
        "); try { int testOrderId = 4; CustomerFeedback feedback =
        dao.getFeedbackByOrderId(testOrderId); out.println("
        <p class="info">Testing with OrderID: " + testOrderId + "</p>
        "); if (feedback != null) { out.println("
        <p class="success">✅ Feedback found:</p>
        "); out.println("
        <pre>
");
                    out.println("FeedbackID: " + feedback.getFeedbackId());
                    out.println("CustomerID: " + feedback.getCustomerId());
                    out.println("OrderID: " + feedback.getOrderId());
                    out.println("Rating: " + feedback.getRating() + " stars");
                    out.println("FeedbackDate: " + feedback.getFeedbackDate());
                    out.println("</pre
        >
        "); } else { out.println("
        <p class="info">No feedback found for this order</p>
        "); } } catch (Exception e) { out.println("
        <p class="error">❌ Error: " + e.getMessage() + "</p>
        "); } out.println("
      </div>
      "); // Test 3: insertPostPaymentFeedback out.println("
      <div class="test-section">
        "); out.println("
        <h3>Test 3: insertPostPaymentFeedback()</h3>
        "); out.println("
        <p class="info">
          ⚠️ This test is commented out to prevent duplicate data
        </p>
        "); out.println("
        <p>
          To test insertion, uncomment the code and provide valid test data:
        </p>
        "); out.println("
        <pre>
");
            out.println("// Example usage:");
            out.println("// boolean result = dao.insertPostPaymentFeedback(\"1\", 999, 1, 5);");
            out.println("// if (result) {");
            out.println("//     out.println(\"✅ Feedback inserted successfully\");");
            out.println("// }");
            out.println("</pre
        >
        "); out.println("
      </div>
      "); // Test 4: canUpdateFeedback out.println("
      <div class="test-section">
        "); out.println("
        <h3>Test 4: canUpdateFeedback()</h3>
        "); try { int testFeedbackId = 1; // Test với timestamp hiện tại (trong
        vòng 24 giờ) Timestamp recentTime = new
        Timestamp(System.currentTimeMillis() - (2 * 60 * 60 * 1000)); // 2 giờ
        trước boolean canUpdate1 = dao.canUpdateFeedback(testFeedbackId,
        recentTime); out.println("
        <p class="info">Test with timestamp 2 hours ago:</p>
        "); out.println("
        <p class="success">
          ✅ Can update: " + canUpdate1 + " (Expected: true)
        </p>
        "); // Test với timestamp cũ (ngoài 24 giờ) Timestamp oldTime = new
        Timestamp(System.currentTimeMillis() - (25 * 60 * 60 * 1000)); // 25 giờ
        trước boolean canUpdate2 = dao.canUpdateFeedback(testFeedbackId,
        oldTime); out.println("
        <p class="info">Test with timestamp 25 hours ago:</p>
        "); out.println("
        <p class="success">
          ✅ Can update: " + canUpdate2 + " (Expected: false)
        </p>
        "); } catch (Exception e) { out.println("
        <p class="error">❌ Error: " + e.getMessage() + "</p>
        "); } out.println("
      </div>
      "); %>

      <hr />
      <p>
        <a href="<%= request.getContextPath() %>/manager-dashboard"
          >← Back to Manager Dashboard</a
        >
      </p>
    </div>
  </body>
</html>
