<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.util.*,java.util.List,java.util.Map" %>
<%@ page import="models.User,models.Product,dao.ProductDAO" %>
<!DOCTYPE html>
<style>
    .modal {
        display: none;
        position: fixed;
        z-index: 999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.5);
        /* Thêm hiệu ứng mượt mà */
        transition: opacity 0.3s ease;
    }
    .modal-content {
        background-color: #fff;
        margin: 5% auto;
        padding: 25px 30px;
        border-radius: 12px;
        width: 600px;
        max-height: 90vh;        /* Giới hạn cao nhất 90% màn hình */
        overflow-y: auto;        /* Cho phép cuộn nội dung */
        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
    }

    .close {
        float: right;
        font-size: 28px; /* To hơn */
        font-weight: bold;
        color: #aaa;
        cursor: pointer;
    }
    .close:hover,
    .close:focus {
        color: #333;
        text-decoration: none;
    }

    /* Nút chung - Giữ nguyên */
    button {
        padding: 6px 12px;
        border: none;
        background-color: #0078d4;
        color: white;
        border-radius: 4px;
        cursor: pointer;
    }
    button:hover {
        background-color: #005fa3;
    }

    /* === ✨ CSS MỚI CHO FORM TRONG MODAL ✨ === */
    .modal-content h2 {
        margin-top: 0;
        margin-bottom: 20px;
        font-size: 24px;
        font-weight: 600;
        color: #333;
        border-bottom: 1px solid #eee;
        padding-bottom: 15px;
    }

    /* Bọc cho mỗi trường nhập */
    .form-group {
        margin-bottom: 15px;
    }

    .modal-content label {
        display: block;
        margin-bottom: 6px;
        font-weight: 600;
        color: #555;
        font-size: 14px;
    }

    /* Kiểu chung cho các trường nhập */
    .modal-content input[type="text"],
    .modal-content input[type="number"],
    .modal-content textarea,
    .modal-content select {
        width: 100%;
        padding: 10px 12px;
        border: 1px solid #ccc; /* Thêm viền */
        border-radius: 6px; /* Bo góc */
        box-sizing: border-box;
        font-size: 15px;
        transition: border-color 0.2s, box-shadow 0.2s;
    }

    /* Hiệu ứng khi focus (click vào) */
    .modal-content input:focus,
    .modal-content textarea:focus,
    .modal-content select:focus {
        border-color: #0078d4; /* Đổi màu viền */
        outline: none; /* Bỏ viền outline mặc định */
        box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.15); /* Thêm hiệu ứng glow */
    }

    .modal-content textarea {
        resize: vertical; /* Cho phép thay đổi chiều cao */
        min-height: 80px;
    }

    /* Nút "Save" trong modal */
    .modal-content button[type="submit"] {
        width: 100%;
        padding: 12px;
        font-size: 16px;
        font-weight: 600;
        margin-top: 10px;
        background-color: #10B981; /* Màu xanh lá cây */
    }
    .modal-content button[type="submit"]:hover {
        background-color: #059669;
    }
    /* === HẾT CSS MỚI === */
</style>

<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Products - PizzaConnect</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest"></script>
        <style>
            .nav-btn {
                width: 3rem;
                height: 3rem;
                border-radius: 0.75rem;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.2s;
            }
            .nav-btn:hover {
                transform: translateY(-2px);
            }
        </style>
    </head>
    <body class="flex h-screen bg-gray-50">

        <%
            String currentPath = request.getRequestURI();
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null || currentUser.getRole() != 1) { 
                response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
                return;
            }
            List<Product> products = (List<Product>) request.getAttribute("products");
            List<Map<String, Object>> ingredientList = (List<Map<String, Object>>) session.getAttribute("ingredientList");
        %>


        <div class="w-20 bg-gray-800 flex flex-col items-center py-6 justify-between">
            <div class="flex flex-col items-center space-y-6">
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-lg">
                    <i data-lucide="pizza" class="w-7 h-7 text-white"></i>
                </a>

                <div class="flex flex-col items-center space-y-4 mt-8">
                    <a href="${pageContext.request.contextPath}/dashboard"
                       class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                       title="Dashboard">
                        <i data-lucide="grid" class="w-6 h-6"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/manageproduct"
                       class="nav-btn <%= currentPath.contains("/ManageProduct.jsp") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                       title="Products">
                        <i data-lucide="box" class="w-6 h-6"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/manage-orders"
                       class="nav-btn text-gray-400 hover:bg-gray-700" title="Orders">
                        <i data-lucide="file-text" class="w-6 h-6"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/manage-customers"
                       class="nav-btn text-gray-400 hover:bg-gray-700" title="Customers">
                        <i data-lucide="users" class="w-6 h-6"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/reports"
                       class="nav-btn text-gray-400 hover:bg-gray-700" title="Reports">
                        <i data-lucide="bar-chart-2" class="w-6 h-6"></i>
                    </a>
                </div>
            </div>

            <div class="flex flex-col items-center space-y-4">
                <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center">
                    <i data-lucide="user" class="w-5 h-5 text-gray-200"></i>
                </div>
                <a href="${pageContext.request.contextPath}/logout"
                   class="nav-btn text-gray-400 hover:bg-red-500 hover:text-white" title="Logout">
                    <i data-lucide="log-out" class="w-6 h-6"></i>
                </a>
            </div>
        </div>
        <%
            String message = (String) session.getAttribute("message");
            if (message != null) {
        %>
        <div id="alertBox" class="fixed top-5 right-5 bg-green-500 text-white px-4 py-3 rounded-lg shadow-lg">
            <%= message %>
        </div>
        <script>
            // Tự động ẩn sau 3 giây
            setTimeout(() => {
                const box = document.getElementById("alertBox");
                if (box)
                    box.style.display = "none";
            }, 3000);
        </script>
        <%
                session.removeAttribute("message"); 
            }
        %>

        <div class="flex-1 flex flex-col overflow-hidden">
            <div class="bg-white border-b px-6 py-4 flex justify-between items-center">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">Manage Products</h1>
                    <p class="text-sm text-gray-500">PizzaConnect Restaurant Management System</p>
                </div>
                <div class="text-gray-600">
                    Welcome, <strong><%= currentUser != null ? currentUser.getName() : "Admin" %></strong>
                </div>
            </div>

            <div class="flex-1 p-6 overflow-auto">
                <div class="bg-gray-50 p-4 rounded-xl mb-6 flex flex-wrap gap-4 items-center">

                    <div class="flex gap-2">
                        <a href="${pageContext.request.contextPath}/view/AddProduct.jsp" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg">Add Product</a>
                        <a href="${pageContext.request.contextPath}/dashboard" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg">Dashboard</a>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div class="bg-gray-800 text-white text-lg font-semibold px-6 py-3">📦Product Management</div>

                    <table class="min-w-full border-t">
                        <thead class="bg-gray-100">
                            <tr>
                                <th class="px-4 py-2 text-left">Product ID</th>
                                <th class="px-4 py-2 text-left">Image</th>
                                <th class="px-4 py-2 text-left">Name</th>
                                <th class="px-4 py-2 text-left">Category</th>
                                <th class="px-4 py-2 text-left">Price</th>
                                <th class="px-4 py-2 text-left">Status</th>
                                <th class="px-4 py-2 text-left">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            <% for (Product p : products) { %>
                            <tr class="hover:bg-gray-50">
                                <td class="px-4 py-2 font-semibold">#<%= p.getProductId() %></td>
                                <td class="px-4 py-2">
                                    <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                                    <img src="<%= p.getImageUrl() %>" class="w-14 h-14 rounded-lg object-cover border" alt="Product">
                                    <% } else { %>
                                    <span class="text-gray-400 italic">No image</span>
                                    <% } %>
                                </td>
                                <td class="px-4 py-2 font-medium"><%= p.getProductName() %></td>
                                <td class="px-4 py-2"><%= p.getCategory() %></td>
                                <td class="px-4 py-2 font-semibold text-gray-700">$<%= String.format("%.2f", p.getPrice()) %></td>
                                <td class="px-4 py-2">
                                    <%
                                        String statusClass = p.isAvailable() ? "bg-green-500" : "bg-gray-400";
                                        String statusText = p.isAvailable() ? "Active" : "Inactive";
                                    %>
                                    <span class="px-3 py-1 text-white rounded-full text-xs font-semibold <%= statusClass %>">
                                        <%= statusText %>
                                    </span>
                                </td>
                                <td class="px-4 py-2">
                                    <div class="flex flex-wrap gap-2">
                                        <button class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1 rounded text-xs editBtn"
                                                data-id="<%= p.getProductId() %>"
                                                data-name="<%= p.getProductName() %>"
                                                data-desc="<%= p.getDescription() %>"
                                                data-price="<%= p.getPrice() %>"
                                                data-category="<%= p.getCategory() %>"
                                                data-image="<%= p.getImageUrl() %>"
                                                data-available="<%= p.isAvailable() %>">
                                            Edit
                                        </button>
                                        <a href="#" class="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-1 rounded text-xs"
                                           onclick="openIngredients(<%= p.getProductId() %>)">Ingredients</a>

                                        <a href="${pageContext.request.contextPath}/DeleteProduct?productId=<%= p.getProductId() %>"
                                           onclick="return confirm('Are you sure you want to delete this product?');"
                                           class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs">Delete</a>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%-- INGREDIENT POP-UP --%>
        <div id="ingredientModal" class="modal">
            <div class="modal-content">
                <span class="close">&times;</span>
                <h2>Product Ingredients</h2>
                <div id="ingredientContent">Loading...</div>
            </div>
        </div>

        <jsp:include page="AddProductModal.jsp" />
        <jsp:include page="EditProductModal.jsp" />

        <script>
            document.addEventListener("DOMContentLoaded", () => {
                lucide.createIcons();

                const addModal = document.getElementById("addModal");
                const addIngredientBtn = document.getElementById("addIngredientBtn");
                const ingredientList = document.getElementById("ingredientList");
                const ingredientTemplate = document.getElementById("ingredientTemplate");
                const editModal = document.getElementById("editModal");
                const ingredientModal = document.getElementById("ingredientModal");

                // === OPEN MODAL ADD PRODUCT ===
                document.querySelector('a[href$="AddProduct.jsp"]').addEventListener("click", e => {
                    e.preventDefault();
                    addModal.style.display = "block";
                });

                // === OPEN MODAL EDIT PRODUCT ===
                document.querySelectorAll(".editBtn").forEach(btn => {
                    btn.addEventListener("click", () => {
                        document.getElementById("editProductId").value = btn.dataset.id;
                        document.getElementById("editProductName").value = btn.dataset.name;
                        document.getElementById("editDescription").value = btn.dataset.desc;
                        document.getElementById("editPrice").value = btn.dataset.price;
                        document.getElementById("editCategory").value = btn.dataset.category;
                        document.getElementById("editImageUrl").value = btn.dataset.image;
                        document.getElementById("editAvailable").value = btn.dataset.available;

                        editModal.style.display = "block";
                    });
                });

                // === OPEN MODAL INGREDIENTS ===
                window.openIngredients = function (productId) {
                    ingredientModal.style.display = "block";
                    const content = document.getElementById("ingredientContent");
                    content.innerHTML = "Loading...";
                    fetch("<%= request.getContextPath() %>/manageingredients?productId=" + productId)
                            .then(res => res.ok ? res.text() : Promise.reject(res.status))
                            .then(html => content.innerHTML = html)
                            .catch(err => content.innerHTML = "Error loading ingredients: " + err);
                }

                // === CLOSE MODALS ===
                document.querySelectorAll(".close").forEach(btn =>
                    btn.addEventListener("click", () => btn.closest(".modal").style.display = "none")
                );

                window.addEventListener("click", e => {
                    if (e.target === addModal)
                        addModal.style.display = "none";
                    if (e.target === editModal)
                        editModal.style.display = "none";
                    if (e.target === ingredientModal)
                        ingredientModal.style.display = "none";
                });

                // === ADD/REMOVE INGREDIENTS ===
                addIngredientBtn.addEventListener("click", () => {
                    const clone = ingredientTemplate.cloneNode(true);
                    clone.id = "";
                    clone.classList.remove("hidden");
                    ingredientList.appendChild(clone);
                });

                document.addEventListener("click", e => {
                    if (e.target.classList.contains("removeIng")) {
                        e.target.closest(".ingredient-row").remove();
                    }
                });

                document.addEventListener("change", e => {

                    if (e.target.classList.contains("ingredientSelect")) {
                        const unit = e.target.selectedOptions[0].dataset.unit || "";
                        const unitField = e.target.closest(".ingredient-row").querySelector(".unitField");
                        if (unitField)
                            unitField.value = unit;
                    }

                    if (e.target.name === "inventoryId") {

                        const selectedOption = e.target.options[e.target.selectedIndex];
                        const unit = selectedOption.dataset.unit;

                        const form = e.target.closest("form");

                        const unitInput = form.querySelector('input[name="unit"]');

                        if (unitInput)
                            unitInput.value = unit || "";
                    }
                });
            });

        </script>



    </body>
</html>