<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Inventory Management</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest"></script>
    </head>
    <body class="flex h-screen bg-gray-50">

        <%-- Sidebar --%>
        <jsp:include page="sidebar.jsp" />

        <%-- Main content --%>
        <div class="flex-1 flex flex-col overflow-hidden">

            <%-- Header --%>
            <div class="bg-white border-b px-6 py-4 flex justify-between items-center flex-shrink-0">
                <h1 class="text-2xl font-bold text-gray-800">Inventory Management</h1>
                <a href="inventory-form.jsp" class="bg-orange-500 text-white px-4 py-2 rounded-lg hover:bg-orange-600">
                    + Add Item
                </a>
            </div>

            <%-- Content --%>
            <div class="flex-1 p-6 overflow-auto bg-gray-50">
                <jsp:include page="/view/inventory-list.jsp" />
            </div>
        </div>

        <script>
            lucide.createIcons();
        </script>

    </body>
</html>
