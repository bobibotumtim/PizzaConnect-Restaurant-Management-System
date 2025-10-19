<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, models.ProductIngredient" %>

<table class="min-w-full text-sm">
    <thead>
        <tr class="bg-gray-200">
            <th class="p-2 text-left">Ingredient</th>
            <th class="p-2 text-left">Quantity</th>
            <th class="p-2 text-left">Unit</th>
        </tr>
    </thead>
    <tbody>
        <% 
            List<ProductIngredient> list = (List<ProductIngredient>) request.getAttribute("ingredients");
            if (list != null) {
                for (ProductIngredient pi : list) { 
        %>
        <tr class="border-b">
            <td class="p-2"><%= pi.getItemName() %></td>
            <td class="p-2"><%= pi.getQuantityNeeded() %></td>
            <td class="p-2"><%= pi.getUnit() %></td>
        </tr>
        <% }} %>
    </tbody>
</table>
