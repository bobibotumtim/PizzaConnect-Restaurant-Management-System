<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Inventory Form</title>
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
  </head>
  <body class="p-4">
    <div class="container">
      <h3>${inventory != null ? 'Edit Inventory' : 'Add Inventory'}</h3>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
      </c:if>

      <form action="manageinventory" method="post">
        <input type="hidden" name="id" value="${inventory.inventoryID}" />

        <!-- Hidden fields to preserve navigation parameters -->
        <input
          type="hidden"
          name="returnSearchName"
          value="${returnSearchName}"
        />
        <input
          type="hidden"
          name="returnStatusFilter"
          value="${returnStatusFilter}"
        />
        <input type="hidden" name="returnPage" value="${returnPage}" />

        <div class="mb-3">
          <label class="form-label">Item Name</label>
          <input
            name="itemName"
            class="form-control"
            value="${inventory.itemName}"
            required
          />
        </div>
        <div class="mb-3">
          <label class="form-label">Quantity</label>
          <input
            name="quantity"
            type="number"
            step="0.01"
            class="form-control"
            value="${inventory.quantity}"
            required
          />
        </div>
        <div class="mb-3">
          <label class="form-label">Unit</label>
          <input
            name="unit"
            class="form-control"
            value="${inventory.unit}"
            required
          />
        </div>

        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-primary">💾 Save</button>
          <c:url var="cancelUrl" value="manageinventory">
            <c:if test="${not empty returnSearchName}">
              <c:param name="searchName" value="${returnSearchName}" />
            </c:if>
            <c:if
              test="${returnStatusFilter != 'all' && not empty returnStatusFilter}"
            >
              <c:param name="statusFilter" value="${returnStatusFilter}" />
            </c:if>
            <c:if test="${not empty returnPage}">
              <c:param name="page" value="${returnPage}" />
            </c:if>
          </c:url>
          <a href="${cancelUrl}" class="btn btn-secondary">❌ Cancel</a>
        </div>
      </form>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
