<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ page
import="dao.DBContext" %> <%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
  <head>
    <title>Test Customer Feedback Database</title>
    <style>
      body {
        font-family: Arial;
        padding: 20px;
      }
      .success {
        color: green;
      }
      .error {
        color: red;
      }
      pre {
        background: #f5f5f5;
        padding: 10px;
        border-radius: 4px;
      }
    </style>
  </head>
  <body>
    <h1>🔍 Test Customer Feedback Database</h1>

    <% try { DBContext dbContext = new DBContext(); Connection conn =
    dbContext.getConnection(); if (conn != null) { out.println("
    <p class="success">✅ Database connection successful!</p>
    "); // Check if customer_feedback table exists String checkTableSQL =
    "SELECT COUNT(*) as table_exists FROM INFORMATION_SCHEMA.TABLES WHERE
    TABLE_NAME = 'customer_feedback'"; PreparedStatement ps =
    conn.prepareStatement(checkTableSQL); ResultSet rs = ps.executeQuery(); if
    (rs.next() && rs.getInt("table_exists") > 0) { out.println("
    <p class="success">✅ Table 'customer_feedback' exists!</p>
    "); // Get row count String countSQL = "SELECT COUNT(*) as row_count FROM
    customer_feedback"; PreparedStatement ps2 = conn.prepareStatement(countSQL);
    ResultSet rs2 = ps2.executeQuery(); if (rs2.next()) { int rowCount =
    rs2.getInt("row_count"); out.println("
    <p class="success">✅ Table has " + rowCount + " rows</p>
    "); } rs2.close(); ps2.close(); } else { out.println("
    <p class="error">❌ Table 'customer_feedback' does NOT exist!</p>
    "); out.println("
    <p><strong>Solution:</strong> You need to run the SQL setup script:</p>
    "); out.println("
    <pre>customer_feedback_setup.sql</pre>
    "); out.println("
    <p>This script will create the table and insert sample data.</p>
    "); } rs.close(); ps.close(); conn.close(); } else { out.println("
    <p class="error">❌ Failed to connect to database!</p>
    "); } } catch (Exception e) { out.println("
    <p class="error">❌ Error: " + e.getMessage() + "</p>
    "); out.println("
    <pre>
");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre
    >
    "); } %>

    <hr />
    <p>
      <a href="<%= request.getContextPath() %>/manager-dashboard"
        >← Back to Manager Dashboard</a
      >
    </p>
  </body>
</html>
