<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, models.ProductIngredient" %>
<%
    String productId = request.getParameter("productId");
%>

<div class="p-4">
    <h2 class="text-lg font-bold mb-3 text-gray-700">Manage Ingredients for Product #<%= productId %></h2>

    <!-- Thông báo -->
    <%
        String msg = (String) session.getAttribute("message");
        String err = (String) session.getAttribute("error");
        if (msg != null) { %>
    <p class="text-green-600 mb-2"><%= msg %></p>
    <% session.removeAttribute("message"); %>
    <% } else if (err != null) { %>
    <p class="text-red-600 mb-2"><%= err %></p>
    <% session.removeAttribute("error"); %>
    <% } %>

    <!-- Form Update tất cả nguyên liệu -->
    <form action="<%= request.getContextPath() %>/manageingredients" method="post" class="mb-4">
        <input type="hidden" name="productId" value="<%= productId %>">

        <table class="min-w-full text-sm border border-gray-300 rounded">
            <thead class="bg-gray-200">
                <tr>
                    <th class="p-2 text-left">Ingredient</th>
                    <th class="p-2 text-left">Quantity</th>
                    <th class="p-2 text-left">Unit</th>
                    <th class="p-2 text-left">Action</th>
                </tr>
            </thead>
            <tbody class="bg-white">
                <%
                    List<ProductIngredient> list = (List<ProductIngredient>) request.getAttribute("ingredients");
                    if (list != null && !list.isEmpty()) {
                        for (ProductIngredient pi : list) {
                %>
                <tr class="border-b hover:bg-gray-50">
                    <td class="p-2"><%= pi.getItemName() %></td>
                    <td class="p-2">
                        <input type="number" step="0.01" name="quantity[]" value="<%= pi.getQuantityNeeded() %>"
                               class="border rounded p-1 w-24 text-black" required>
                        <input type="hidden" name="inventoryId[]" value="<%= pi.getInventoryId() %>">
                    </td>
                    <td class="p-2">
                        <input type="text" name="unit[]" value="<%= pi.getUnit() %>" class="border rounded p-1 w-20 text-black" readonly>
                    </td>
                    <td class="p-2">
                        <!-- Form Delete riêng -->
                        <form action="<%= request.getContextPath() %>/manageingredients" method="post" style="display:inline;">
                            <input type="hidden" name="productId" value="<%= productId %>">
                            <input type="hidden" name="inventoryId" value="<%= pi.getInventoryId() %>">
                            <button type="submit" name="action" value="delete" class="bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded">✕</button>
                        </form>
                    </td>
                </tr>
                <% } } else { %>
                <tr>
                    <td colspan="4" class="p-2 text-gray-500 text-center">No ingredients found.</td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <div class="mt-4">
            <button name="action" value="update" type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded">
                Update All Quantities
            </button>
        </div>
    </form>


    <!-- Form Thêm nguyên liệu mới -->
    <hr class="my-3">
    <form action="<%= request.getContextPath() %>/manageingredients" method="post" class="flex gap-2 items-center">
        <input type="hidden" name="action" value="add">
        <input type="hidden" name="productId" value="<%= productId %>">

        <select name="inventoryId" required class="border p-2 rounded text-black min-w-[150px]">
            <option value="">-- Select Ingredient --</option>
            <%
                List<Map<String, Object>> inventories = (List<Map<String, Object>>) session.getAttribute("ingredientList");
                if (inventories != null) {
                    for (Map<String, Object> inv : inventories) {
                        int id = (int) inv.get("inventoryID");
                        String name = (String) inv.get("inventoryName");
                        String unit = (String) inv.get("unit");
            %>
            <option value="<%= id %>" data-unit="<%= unit %>"><%= name %></option>
            <% } } %>
        </select>

        <input type="number" step="0.01" name="quantity" placeholder="Quantity"
               class="border p-2 rounded w-24 text-black" required>
        <input type="text" name="unit" placeholder="Unit"
               class="border p-2 rounded w-24 text-black" readonly>
        <button type="submit" class="bg-green-500 hover:bg-green-600 text-white px-3 py-2 rounded">
            Add Ingredient
        </button>
    </form>
</div>

<script>
    // Tự động điền unit khi chọn ingredient mới
    const select = document.querySelector('select[name="inventoryId"]');
    const unitInput = document.querySelector('input[name="unit"]');
    select.addEventListener('change', () => {
        const option = select.selectedOptions[0];
        unitInput.value = option.getAttribute('data-unit') || '';
    });
</script>
