<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${inventory != null ? "Edit Inventory" : "Add New Inventory"}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-5">
    <div class="card shadow-sm mx-auto" style="max-width: 600px;">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">${inventory != null ? "Edit Inventory" : "Add New Inventory"}</h4>
        </div>
        <div class="card-body">
            <!-- ✅ Hiển thị lỗi validate -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    ${error}
                </div>
            </c:if>
            <!-- ✅ Kết thúc hiển thị lỗi -->
            
            <form action="manageinventory" method="post">
                <c:if test="${inventory != null}">
                    <input type="hidden" name="id" value="${inventory.inventoryID}">
                </c:if>

                <div class="mb-3">
                    <label class="form-label">Item Name</label>
                    <input type="text" class="form-control" name="itemName" required
                           value="${inventory != null ? inventory.itemName : ''}">
                </div>

                <div class="mb-3">
                    <label class="form-label">Quantity</label>
                    <input type="number" step="0.01" class="form-control" name="quantity" required
                           value="${inventory != null ? inventory.quantity : ''}">
                </div>

                <div class="mb-3">
                    <label class="form-label">Unit</label>
                    <input type="text" class="form-control" name="unit"
                           value="${inventory != null ? inventory.unit : ''}">
                </div>

                <div class="d-flex justify-content-between">
                    <a href="manageinventory" class="btn btn-secondary">Back</a>
                    <button type="submit" class="btn btn-primary">
                        ${inventory != null ? "Update" : "Add"}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
