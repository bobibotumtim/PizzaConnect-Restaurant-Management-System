<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.util.*,java.util.List,java.util.Map" %>
<%@ page import="models.User,models.Product,dao.ProductDAO" %>
<!DOCTYPE html>
<style>
    /* (Toàn bộ CSS của bạn giữ nguyên, tôi ẩn đi cho gọn) */
    .modal { display: none; position: fixed; z-index: 999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); transition: opacity 0.3s ease; }
    .modal-content { background-color: #fff; margin: 5% auto; padding: 25px 30px; border-radius: 12px; width: 600px; max-height: 90vh; overflow-y: auto; box-shadow: 0 5px 15px rgba(0,0,0,0.2); }
    .close { float: right; font-size: 28px; font-weight: bold; color: #aaa; cursor: pointer; }
    .close:hover, .close:focus { color: #333; text-decoration: none; }
    button { padding: 6px 12px; border: none; background-color: #0078d4; color: white; border-radius: 4px; cursor: pointer; }
    button:hover { background-color: #005fa3; }
    .modal-content h2 { margin-top: 0; margin-bottom: 20px; font-size: 24px; font-weight: 600; color: #333; border-bottom: 1px solid #eee; padding-bottom: 15px; }
    .form-group { margin-bottom: 15px; }
    .modal-content label { display: block; margin-bottom: 6px; font-weight: 600; color: #555; font-size: 14px; }
    .modal-content input[type="text"], .modal-content input[type="number"], .modal-content textarea, .modal-content select { width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box; font-size: 15px; transition: border-color 0.2s, box-shadow 0.2s; }
    .modal-content input:focus, .modal-content textarea:focus, .modal-content select:focus { border-color: #0078d4; outline: none; box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.15); }
    .modal-content textarea { resize: vertical; min-height: 80px; }
    .modal-content button[type="submit"] { width: 100%; padding: 12px; font-size: 16px; font-weight: 600; margin-top: 10px; background-color: #10B981; }
    .modal-content button[type="submit"]:hover { background-color: #059669; }
</style>

<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Products - PizzaConnect</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest"></script>
        <style>
            .nav-btn { width: 3rem; height: 3rem; border-radius: 0.75rem; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
            .nav-btn:hover { transform: translateY(-2px); }
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
            Map<Integer, Double> availabilityMap = (Map<Integer, Double>) request.getAttribute("availabilityMap");
            List<Map<String, Object>> ingredientList = (List<Map<String, Object>>) session.getAttribute("ingredientList");
        %>

        <%-- Sidebar Navigation --%>
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
                    <a href="${pageContext.request.contextPath}/sales-reports"
                       class="nav-btn text-gray-400 hover:bg-gray-700" title="Sales Reports">
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
        
        <%-- Alert Message Box (Nếu có) --%>
        <%
            String message = (String) session.getAttribute("message");
            String messageType = (String) session.getAttribute("messageType");
            if (message != null) {
                String bgColor = "bg-green-500"; // mặc định xanh lá
                if ("error".equals(messageType)) {
                    bgColor = "bg-red-500"; // nếu lỗi thì đỏ
                }
        %>
        <div id="alertBox" class="fixed top-5 right-5 <%= bgColor %> text-white px-4 py-3 rounded-lg shadow-lg transition-opacity duration-500">
            <%= message %>
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
        <%
                session.removeAttribute("message");
                session.removeAttribute("messageType");
            }
        %>

        <%-- Main Content --%>
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
                    
                    <form action="${pageContext.request.contextPath}/manageproduct" method="GET" class="flex-1 flex flex-wrap gap-4 items-center justify-end">
                        
                        <input type="text" name="searchName" value="${searchName}" placeholder="Search by name..."
                               class="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-400"
                               style="min-width: 200px;">
                        
                        <select name="statusFilter" 
                                class="px-3 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-orange-400">
                            <%-- 
                                Dùng JSTL để kiểm tra và 'selected' giá trị đã lọc trước đó.
                                'empty statusFilter' sẽ chọn 'All Status' làm mặc định khi tải trang lần đầu.
                            --%>
                            <option value="all" ${statusFilter == 'all' || empty statusFilter ? 'selected' : ''}>All Status</option>
                            <option value="available" ${statusFilter == 'available' ? 'selected' : ''}>Available</option>
                            <option value="unavailable" ${statusFilter == 'unavailable' ? 'selected' : ''}>Unavailable</option>
                        </select>
                        
                        <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-1">
                            <i data-lucide="search" class="w-4 h-4"></i> Filter
                        </button>
                    </form>
                </div>

                <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div class="bg-gray-800 text-white text-lg font-semibold px-6 py-3">Product Management</div>

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
                                        double availableQty = 0;
                                        if (availabilityMap != null && availabilityMap.containsKey(p.getProductId())) {
                                            availableQty = availabilityMap.get(p.getProductId());
                                        }

                                        String statusClass, statusText;
                                        if (availableQty > 0) {
                                            statusClass = "bg-green-500";
                                            statusText = "Available";
                                        } else {
                                            statusClass = "bg-red-500";
                                            statusText = "Unavailable";
                                        }
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
                                        
                                        <%-- ✅ XOÁ NÚT INGREDIENTS THỪA --%>
                                        <%-- <a href="#" class="bg-yellow-500 ...">Ingredients</a> --%>

                                        <a href="${pageContext.request.contextPath}/DeleteProduct?productId=<%= p.getProductId() %>"
                                           onclick="return confirm('Are you sure you want to delete this product?');"
                                           class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs">Delete</a>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <%-- Pagination --%>
                    <%-- ✅ PHÂN TRANG ĐÃ CẬP NHẬT (Dùng c:url) --%>
                    <div class="flex justify-center items-center mt-6 space-x-2">
                        
                        <%-- Nút Previous --%>
                        <c:if test="${currentPage > 1}">
                            <%-- Tạo URL với đầy đủ tham số --%>
                            <c:url var="prevUrl" value="/manageproduct">
                                <c:param name="page" value="${currentPage - 1}" />
                                <c:param name="searchName" value="${searchName}" />     <%-- Thêm tham số --%>
                                <c:param name="statusFilter" value="${statusFilter}" /> <%-- Thêm tham số --%>
                            </c:url>
                            <a href="${prevUrl}"
                               class="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded">Previous</a>
                        </c:if>

                        <%-- Các nút số trang --%>
                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <c:url var="pageUrl" value="/manageproduct">
                                <c:param name="page" value="${i}" />
                                <c:param name="searchName" value="${searchName}" />     <%-- Thêm tham số --%>
                                <c:param name="statusFilter" value="${statusFilter}" /> <%-- Thêm tham số --%>
                            </c:url>
                            <a href="${pageUrl}"
                               class="px-3 py-1 rounded
                               ${i == currentPage ? 'bg-orange-500 text-white' : 'bg-gray-200 hover:bg-gray-300'}">
                                ${i}
                            </a>
                        </c:forEach>

                        <%-- Nút Next --%>
                        <c:if test="${currentPage < totalPages}">
                            <c:url var="nextUrl" value="/manageproduct">
                                <c:param name="page" value="${currentPage + 1}" />
                                <c:param name="searchName" value="${searchName}" />     <%-- Thêm tham số --%>
                                <c:param name="statusFilter" value="${statusFilter}" /> <%-- Thêm tham số --%>
                            </c:url>
                            <a href="${nextUrl}"
                               class="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded">Next</a>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <%-- ✅ XOÁ POP-UP INGREDIENT THỪA --%>
        <%-- <div id="ingredientModal" class="modal"> ... </div> --%>

        <div id="editFullModal" class="modal">
            <div class="modal-content">
                <span class="close">&times;</span>
                <div id="editFullContent">Loading...</div>
            </div>
        </div>

        <%-- Nạp AddProductModal (Giữ nguyên) --%>
        <jsp:include page="AddProductModal.jsp" />


        <%-- ✅ SCRIPT ĐÃ ĐƯỢC DỌN DẸP --%>
        <script>
            document.addEventListener("DOMContentLoaded", () => {
                lucide.createIcons();

                // --- 1. LẤY CÁC VỎ BỌC MODAL ---
                const addModal = document.getElementById("addModal");
                const editModal = document.getElementById("editFullModal");
                // const ingredientModal = ... (ĐÃ XOÁ)

                // --- 2. LOGIC MỞ MODAL ---

                // Mở Add Modal
                document.querySelector('a[href$="AddProduct.jsp"]')?.addEventListener("click", e => {
                    e.preventDefault();
                    addModal.style.display = "block";
                });

                // Mở Edit Modal (Fetch nội dung)
                document.querySelectorAll(".editBtn").forEach(btn => {
                    btn.addEventListener("click", ev => {
                        ev.preventDefault();
                        const productId = btn.dataset.id;
                        const editContent = document.getElementById("editFullContent");

                        editContent.innerHTML = "Loading...";
                        editModal.style.display = "block";

                        fetch("<%= request.getContextPath() %>/EditProductFullServlet?productId=" + productId)
                            .then(res => res.ok ? res.text() : Promise.reject(res.status))
                            .then(html => {
                                editContent.innerHTML = html;
                            })
                            .catch(err => {
                                editContent.innerHTML = "Error loading form: " + err;
                                console.error(err);
                            });
                    });
                });
                
                // window.openIngredients = ... (ĐÃ XOÁ)

                // --- 3. LOGIC ĐÓNG MODAL (Dùng chung) ---
                document.querySelectorAll(".close").forEach(btn => {
                    btn.addEventListener("click", () => {
                        btn.closest(".modal").style.display = "none";
                    });
                });

                window.addEventListener("click", e => {
                    // (Đã xoá 'ingredientModal' khỏi danh sách này)
                    if ([addModal, editModal].includes(e.target)) {
                        e.target.style.display = "none";
                    }
                });

                // --- 4. LOGIC XÓA HÀNG (Dùng chung) ---
                document.addEventListener("click", e => {
                    if (e.target.classList.contains("removeIng") || e.target.classList.contains("removeBtn")) {
                        e.target.closest(".ingredient-row, tr")?.remove();
                    }
                });


                // --- 5. LOGIC CHO ADD MODAL (Giữ nguyên - Đây là code CẦN THIẾT) ---

                // (A) Xử lý nút "+ Add Ingredient" (id: addIngredientBtn)
                addModal.addEventListener('click', (e) => {
                    if (e.target.id === 'addIngredientBtn') {
                        e.preventDefault();
                        
                        const template = addModal.querySelector("#ingredientTemplate")?.cloneNode(true);
                        const list = addModal.querySelector("#ingredientList");

                        if (template && list) {
                            template.classList.remove("hidden"); 
                            template.removeAttribute("id");      
                            
                            template.querySelector("select")?.setAttribute("required", "required");
                            template.querySelector("input[name='ingredientQty[]']")?.setAttribute("required", "required");
                            
                            list.appendChild(template);
                        } else {
                            console.error("Lỗi Add Modal: Không tìm thấy #ingredientTemplate hoặc #ingredientList");
                        }
                    }
                });

                // (B) Tự động điền Unit cho Add Modal (class: ingredientSelect)
                addModal.addEventListener('change', (e) => {
                    if (e.target.classList.contains('ingredientSelect')) {
                        const select = e.target;
                        const row = select.closest('.ingredient-row'); 
                        const unitInput = row?.querySelector('.unitField');
                        
                        if (unitInput) {
                            const option = select.selectedOptions[0];
                            unitInput.value = option.getAttribute('data-unit') || '';
                        }
                    }
                });


                // --- 6. LOGIC CHO EDIT MODAL (Giữ nguyên - Đây là code CẦN THIẾT) ---

                // (A) Tự động điền Unit cho Edit Modal (id: editNewIngredientSelect)
                editModal.addEventListener('change', (e) => {
                    if (e.target.id === 'editNewIngredientSelect') {
                        const select = e.target;
                        const unitInput = editModal.querySelector('#editNewUnit');
                        if (unitInput) {
                            const option = select.selectedOptions[0];
                            unitInput.value = option.getAttribute('data-unit') || '';
                        }
                    }
                });

                // (B) Thêm hàng mới cho Edit Modal (id: editAddIngredientBtn)
                editModal.addEventListener('click', (e) => {
                    if (e.target.id === 'editAddIngredientBtn') {
                        e.preventDefault();
                        console.log("--- DEBUG: Nút 'Edit Add' đã nhấn ---");

                        const tableBody = editModal.querySelector('#ingredientTable tbody');
                        const select = editModal.querySelector('#editNewIngredientSelect');
                        const unitInput = editModal.querySelector('#editNewUnit');
                        const qtyInput = editModal.querySelector('#editNewQuantity');

                        if (!tableBody || !select || !unitInput || !qtyInput) {
                            console.error("Lỗi Edit Modal: Không tìm thấy element (editNewIngredientSelect, editNewQuantity...)");
                            return;
                        }

                        const selectedOption = select.options[select.selectedIndex];
                        const ingId = selectedOption ? selectedOption.value.trim() : "";
                        const ingName = selectedOption ? selectedOption.text.trim() : "";
                        const unit = unitInput.value.trim();
                        const qty = qtyInput.value.trim();

                        console.log("Values:", { ingId, ingName, unit, qty });

                        if (!ingId || ingId === "" || ingName.includes("--") || !unit || !qty || parseFloat(qty) <= 0) {
                            if(!ingId || ingId === "" || ingName.includes("--") ) {
                                alert("Vui lòng chọn nguyên liệu hợp lệ.");                                
                            } else if (!unit || !qty || parseFloat(qty) <= 0) {
                                alert("Vui lòng nhập số lượng lớn hơn 0.");
                            }
                            console.warn("Validation failed");
                            return;
                        }

                        const exists = Array.from(tableBody.querySelectorAll('input[name="inventoryId[]"]'))
                            .some(input => input.value === ingId);
                        if (exists) {
                            alert("Nguyên liệu đã được thêm.");
                            return;
                        }

                        console.log("Validation OK. Đang thêm hàng (DOM METHOD)...");

                        // (Code tạo hàng bằng DOM)
                        const tr = document.createElement("tr");
                        const tdName = document.createElement("td");
                        tdName.textContent = ingName;
                        tr.appendChild(tdName);

                        const tdQty = document.createElement("td");
                        const inputQty = document.createElement("input");
                        inputQty.type = "number";
                        inputQty.step = "0.01";
                        inputQty.name = "quantity[]";
                        inputQty.value = qty;
                        inputQty.className = "border p-1 w-24";
                        tdQty.appendChild(inputQty);
                        const inputHiddenId = document.createElement("input");
                        inputHiddenId.type = "hidden";
                        inputHiddenId.name = "inventoryId[]";
                        inputHiddenId.value = ingId;
                        tdQty.appendChild(inputHiddenId);
                        tr.appendChild(tdQty);

                        const tdUnit = document.createElement("td");
                        const inputUnit = document.createElement("input");
                        inputUnit.type = "text";
                        inputUnit.name = "unit[]";
                        inputUnit.value = unit;
                        inputUnit.className = "border p-1 w-20";
                        inputUnit.readOnly = true;
                        tdUnit.appendChild(inputUnit);
                        tr.appendChild(tdUnit);

                                
                        const tdAction = document.createElement("td");
                        const removeBtn = document.createElement("button");
                        removeBtn.type = "button";
                        removeBtn.className = "removeBtn bg-red-500 text-white px-2 py-1 rounded";
                        removeBtn.innerHTML = "✕";
                        tdAction.appendChild(removeBtn);
                        tr.appendChild(tdAction);

                        tableBody.appendChild(tr);
                        
                        // Reset
                        select.selectedIndex = 0;
                        qtyInput.value = "";
                        unitInput.value = "";
                    }
                });

            });
        </script>

    </body>
</html>