<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
  <head>
    <title>Test OrderID Parameter</title>
  </head>
  <body>
    <h1>Test OrderID Parameter</h1>

    <% String orderIdParam = request.getParameter("orderId"); out.println("
    <p><strong>orderIdParam:</strong> " + orderIdParam + "</p>
    "); if (orderIdParam != null && !orderIdParam.trim().isEmpty()) { try { int
    orderId = Integer.parseInt(orderIdParam); out.println("
    <p style="color: green">
      <strong>✅ Valid OrderID:</strong> " + orderId + "
    </p>
    "); } catch (NumberFormatException e) { out.println("
    <p style="color: red">
      <strong>❌ Invalid OrderID:</strong> " + e.getMessage() + "
    </p>
    "); } } else { out.println("
    <p style="color: orange"><strong>⚠️ OrderID is null or empty</strong></p>
    "); } %>

    <hr />
    <h2>Test Links:</h2>
    <ul>
      <li><a href="?orderId=2">Test with orderId=2</a></li>
      <li><a href="?orderId=5">Test with orderId=5</a></li>
      <li><a href="?orderId=abc">Test with invalid orderId</a></li>
      <li><a href="?">Test without orderId</a></li>
    </ul>

    <hr />
    <h2>Go to Feedback Form:</h2>
    <a
      href="${pageContext.request.contextPath}/view/SimpleFeedbackForm.jsp?orderId=2"
    >
      SimpleFeedbackForm with orderId=2
    </a>
  </body>
</html>
