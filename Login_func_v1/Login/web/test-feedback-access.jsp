<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
  <head>
    <title>Test Feedback Access</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 50px auto;
        padding: 20px;
      }
      .test-section {
        background: #f5f5f5;
        padding: 20px;
        margin: 20px 0;
        border-radius: 8px;
      }
      .success {
        color: green;
      }
      .error {
        color: red;
      }
      a.button {
        display: inline-block;
        padding: 10px 20px;
        background: #007bff;
        color: white;
        text-decoration: none;
        border-radius: 5px;
        margin: 5px;
      }
      a.button:hover {
        background: #0056b3;
      }
    </style>
  </head>
  <body>
    <h1>🧪 Test Feedback System Access</h1>

    <div class="test-section">
      <h2>1. Test Direct JSP Access</h2>
      <p>Kiểm tra xem các JSP page có thể truy cập được không:</p>
      <a
        href="<%= request.getContextPath() %>/view/FeedbackPrompt.jsp?orderId=1"
        class="button"
        target="_blank"
      >
        Test FeedbackPrompt.jsp
      </a>
      <a
        href="<%= request.getContextPath() %>/view/FeedbackForm.jsp?orderId=1"
        class="button"
        target="_blank"
      >
        Test FeedbackForm.jsp
      </a>
      <a
        href="<%= request.getContextPath() %>/view/FeedbackConfirmation.jsp"
        class="button"
        target="_blank"
      >
        Test FeedbackConfirmation.jsp
      </a>
    </div>

    <div class="test-section">
      <h2>2. Test Servlet Mapping</h2>
      <p>Kiểm tra xem các servlet có được map đúng không:</p>
      <a
        href="<%= request.getContextPath() %>/feedback-prompt?orderId=1"
        class="button"
        target="_blank"
      >
        Test /feedback-prompt
      </a>
      <a
        href="<%= request.getContextPath() %>/feedback-form?orderId=1"
        class="button"
        target="_blank"
      >
        Test /feedback-form
      </a>
    </div>

    <div class="test-section">
      <h2>3. Check DAO Methods</h2>
      <% try { // Test import DAO classes dao.CustomerFeedbackDAO feedbackDAO =
      new dao.CustomerFeedbackDAO(); dao.OrderDAO orderDAO = new dao.OrderDAO();
      out.println("
      <p class="success">✅ DAO classes loaded successfully!</p>
      "); // Test hasFeedbackForOrder method boolean hasFeedback =
      feedbackDAO.hasFeedbackForOrder(1); out.println("
      <p>hasFeedbackForOrder(1): " + hasFeedback + "</p>
      "); } catch (Exception e) { out.println("
      <p class="error">❌ Error loading DAO: " + e.getMessage() + "</p>
      "); out.println("
      <pre>
");
                e.printStackTrace(new java.io.PrintWriter(out));
                out.println("</pre
      >
      "); } %>
    </div>

    <div class="test-section">
      <h2>4. Server Info</h2>
      <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
      <p><strong>Server Info:</strong> <%= application.getServerInfo() %></p>
      <p>
        <strong>Servlet Version:</strong> <%= application.getMajorVersion()
        %>.<%= application.getMinorVersion() %>
      </p>
    </div>

    <div class="test-section">
      <h2>📝 Instructions</h2>
      <ol>
        <li>Click vào các button ở trên để test từng phần</li>
        <li>Nếu gặp lỗi 500, check Tomcat logs trong NetBeans</li>
        <li>Nếu gặp lỗi 404, servlet chưa được deploy đúng</li>
        <li>Nếu JSP page lỗi, có thể do thiếu data hoặc syntax error</li>
      </ol>
    </div>

    <hr />
    <p><a href="<%= request.getContextPath() %>/home">← Back to Home</a></p>
  </body>
</html>
