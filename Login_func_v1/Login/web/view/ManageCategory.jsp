<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Categories - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .modal {display: none; position: fixed; z-index: 999; left:0; top:0; width:100%; height:100%; background-color: rgba(0,0,0,0.5);}
        .modal-content {background-color: #fff; margin:5% auto; padding:25px 30px; border-radius:12px; width:600px; max-height:90vh; overflow-y:auto;}
        .close {float:right; font-size:28px; font-weight:bold; color:#aaa; cursor:pointer;}
        button {padding:6px 12px; border:none; background-color:#0078d4; color:white; border-radius:4px; cursor:pointer;}
        .modal-content h2 {margin-top:0; margin-bottom:20px; font-size:24px; font-weight:600; color:#333; border-bottom:1px solid #eee; padding-bottom:15px;}
        .form-group {margin-bottom:15px;}
        .modal-content input[type="text"], .modal-content textarea {
            width:100%; padding:10px 12px; border:1px solid #ccc; border-radius:6px; box-sizing:border-box; font-size:15px;
        }
        .modal-content textarea {resize: vertical; min-height:100px;}
        .modal-content button[type="submit"] {width:100%; padding:12px; font-size:16px; font-weight:600; margin-top:10px; background-color:#10B981;}
    </style>
</head>
<body class="bg-gray-50">

<!-- Include Sidebar -->
<%@ include file="Sidebar.jsp" %>
<%@ include file="NavBar.jsp" %>

<!-- Alert Messages -->
<c:if test="${not empty sessionScope.message}">
    <div id="alertBox" class="fixed top-20 right-5 ${sessionScope.messageType == 'error' ? 'bg-red-500' : 'bg-green-500'} text-white px-6 py-4 rounded-lg shadow-xl transition-opacity duration-500" style="z-index: 9999;">
        <div class="flex items-center gap-2">
            <span class="text-lg font-semibold">${sessionScope.message}</span>
        </div>
    </div>
    <script>
        setTimeout(() => {
            const box = document.getElementById("alertBox");
            if (box) {
                box.style.opacity = "0";
                setTimeout(() => box.remove(), 500);
            }
        }, 3000);
    </script>
    <c:remove var="message" scope="session" />
    <c:remove var="messageType" scope="session" />
</c:if>

<!-- Main Content -->
<div class="content-wrapper">
<div class="flex-1 flex flex-col overflow-hidden">
    <div class="bg-white border-b px-6 py-4 flex justify-between items-center">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">Manage Categories</h1>
            <p class="text-sm text-gray-500">PizzaConnect Restaurant Management System</p>
        </div>
        <div class="text-gray-600">
            Welcome, <strong>Admin</strong>
        </div>
    </div>

    <div class="flex-1 p-6 overflow-auto">
        <div class="bg-gray-50 p-4 rounded-xl mb-6 flex flex-wrap gap-4 items-center">
            <div class="flex gap-2">
                <button id="openAddModal" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg">Add Category</button>
            </div>

            <form action="managecategory" method="GET" class="flex-1 flex flex-wrap gap-4 items-center justify-end">
                <input type="text" name="searchName" value="${param.searchName}" placeholder="Search by name..."
                       class="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-400"
                       style="min-width: 200px;">
                <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-1">
                    <i data-lucide="search" class="w-4 h-4"></i> Filter
                </button>
            </form>
        </div>

        <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="bg-gray-800 text-white text-lg font-semibold px-6 py-3">Category Management</div>
            <table class="min-w-full border-t">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-2 text-left">Category ID</th>
                        <th class="px-4 py-2 text-left">Name</th>
                        <th class="px-4 py-2 text-left">Description</th>
                        <th class="px-4 py-2 text-left">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y">
                    <c:forEach var="c" items="${categories}">
                        <tr class="hover:bg-gray-50">
                            <td class="px-4 py-2 font-semibold">#${c.categoryId}</td>
                            <td class="px-4 py-2 font-medium">${c.categoryName}</td>
                            <td class="px-4 py-2 text-gray-600">${c.description}</td>
                            <td class="px-4 py-2">
                                <div class="flex gap-2">
                                    <button class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1 rounded text-xs editBtn"
                                            data-id="${c.categoryId}"
                                            data-name="${c.categoryName}"
                                            data-desc="${c.description}">Edit</button>
                                    <a href="managecategory?action=delete&id=${c.categoryId}"
                                       class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs"
                                       onclick="return confirm('Delete this category?')">Delete</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty categories}">
                        <tr><td colspan="4" class="text-center py-4 text-gray-500">No categories found</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</div>

<!-- Add Modal -->
<div id="addModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <h2>Add New Category</h2>
        <form action="managecategory" method="POST">
            <input type="hidden" name="categoryId" value="">
            <div class="form-group">
                <label>Category Name</label>
                <input type="text" name="categoryName" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" placeholder="Describe the category..."></textarea>
            </div>
            <button type="submit">Save Category</button>
        </form>
    </div>
</div>

<!-- Edit Modal -->
<div id="editModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <h2>Edit Category</h2>
        <form action="managecategory" method="POST">
            <input type="hidden" name="categoryId" id="edit_id">
            <div class="form-group">
                <label>Category Name</label>
                <input type="text" name="categoryName" id="edit_name" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" id="edit_desc"></textarea>
            </div>
            <button type="submit">Update Category</button>
        </form>
    </div>
</div>

<script>
    lucide.createIcons();

    // Modal logic
    const addModal = document.getElementById('addModal');
    const editModal = document.getElementById('editModal');
    const openAdd = document.getElementById('openAddModal');
    const closes = document.querySelectorAll('.close');

    openAdd.onclick = () => addModal.style.display = 'block';
    closes.forEach(c => c.onclick = () => { addModal.style.display = 'none'; editModal.style.display = 'none'; });

    window.onclick = e => {
        if (e.target === addModal) addModal.style.display = 'none';
        if (e.target === editModal) editModal.style.display = 'none';
    };

    // Edit button logic
    document.querySelectorAll('.editBtn').forEach(btn => {
        btn.onclick = () => {
            document.getElementById('edit_id').value = btn.dataset.id;
            document.getElementById('edit_name').value = btn.dataset.name;
            document.getElementById('edit_desc').value = btn.dataset.desc;
            editModal.style.display = 'block';
        };
    });
</script>

<!-- Alert -->
<c:if test="${param.message != null}">
    <div id="alertBoxParam"
         class="fixed top-20 right-5 bg-green-500 text-white px-6 py-4 rounded-lg shadow-xl" style="z-index: 9999;">
        <c:choose>
            <c:when test="${param.message == 'added'}">Category added successfully!</c:when>
            <c:when test="${param.message == 'updated'}">Category updated successfully!</c:when>
            <c:when test="${param.message == 'deleted'}">Category deleted successfully!</c:when>
        </c:choose>
    </div>
    <script>
        setTimeout(() => {
            const box = document.getElementById('alertBoxParam');
            if (box) {
                box.style.opacity = '0';
                box.style.transition = 'opacity 0.5s';
                setTimeout(() => box.remove(), 500);
            }
        }, 3000);
    </script>
</c:if>

<script>
    // Initialize Lucide icons
    lucide.createIcons();
</script>

</body>
</html>
