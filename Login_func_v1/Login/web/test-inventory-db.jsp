<%@ page import="java.sql.*" %> <%@ page import="dao.DBContext" %> <%@ page
contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
  <head>
    <title>Test Inventory Database</title>
    <style>
      body {
        font-family: Arial;
        margin: 20px;
      }
      .success {
        color: green;
        font-weight: bold;
      }
      .error {
        color: red;
        font-weight: bold;
      }
      table {
        border-collapse: collapse;
        margin: 20px 0;
        width: 100%;
      }
      th,
      td {
        border: 1px solid #ddd;
        padding: 8px;
      }
      th {
        background-color: #f97316;
        color: white;
      }
      tr:nth-child(even) {
        background-color: #f9f9f9;
      }
    </style>
  </head>
  <body>
    <h1>Inventory Database Test</h1>

    <% Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
    try { DBContext dbContext = new DBContext(); conn =
    dbContext.getConnection(); if (conn != null && !conn.isClosed()) { %>
    <p class="success">Database connected successfully!</p>
    <p>Database: <%= conn.getMetaData().getDatabaseProductName() %></p>
    <% } else { %>
    <p class="error">Database connection failed!</p>
    <% } // Check table exists DatabaseMetaData metaData = conn.getMetaData();
    ResultSet tables = metaData.getTables(null, null, "Inventory", null); if
    (tables.next()) { %>
    <p class="success">Inventory table exists</p>
    <% } else { %>
    <p class="error">Inventory table does NOT exist!</p>
    <% } tables.close(); // Count records String countSql = "SELECT COUNT(*) as
    total FROM Inventory"; ps = conn.prepareStatement(countSql); rs =
    ps.executeQuery(); int totalCount = 0; if (rs.next()) { totalCount =
    rs.getInt("total"); %>
    <h2>Total Records: <%= totalCount %></h2>
    <% if (totalCount == 0) { %>
    <p class="error">No data in Inventory table! You need to add some items.</p>
    <% } } rs.close(); ps.close(); // Show records if (totalCount > 0) { %>
    <h2>Inventory Records (First 10)</h2>
    <table>
      <tr>
        <th>ID</th>
        <th>Item Name</th>
        <th>Quantity</th>
        <th>Unit</th>
        <th>Status</th>
        <th>Last Updated</th>
      </tr>
      <% String selectSql = "SELECT TOP 10 InventoryID, ItemName, Quantity,
      Unit, Status, LastUpdated FROM Inventory ORDER BY InventoryID"; ps =
      conn.prepareStatement(selectSql); rs = ps.executeQuery(); while
      (rs.next()) { %>
      <tr>
        <td><%= rs.getInt("InventoryID") %></td>
        <td><%= rs.getString("ItemName") %></td>
        <td><%= rs.getDouble("Quantity") %></td>
        <td><%= rs.getString("Unit") %></td>
        <td><%= rs.getString("Status") %></td>
        <td><%= rs.getTimestamp("LastUpdated") %></td>
      </tr>
      <% } %>
    </table>
    <% } } catch (Exception e) { %>
    <p class="error">Error: <%= e.getMessage() %></p>
    <pre><%= e.getClass().getName() %></pre>
    <% e.printStackTrace(); } finally { if (rs != null) try { rs.close(); }
    catch (Exception e) {} if (ps != null) try { ps.close(); } catch (Exception
    e) {} if (conn != null) try { conn.close(); } catch (Exception e) {} } %>

    <hr />
    <p><a href="manageinventory">Back to Manage Inventory</a></p>
  </body>
</html>
