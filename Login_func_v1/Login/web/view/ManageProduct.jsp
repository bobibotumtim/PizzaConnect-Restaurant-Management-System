<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.util.List" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Products - PizzaConnect</title>
        <%-- Các script của bạn --%>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest"></script>

        <%-- CSS cho Modal --%>
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
                transition: opacity 0.3s ease;
            }
            .modal-content {
                background-color: #fff;
                margin: 5% auto;
                padding: 25px 30px;
                border-radius: 12px;
                width: 600px;
                max-width: 90%;
                max-height: 90vh;
                overflow-y: auto;
                box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            }
            .close {
                float: right;
                font-size: 28px;
                font-weight: bold;
                color: #aaa;
                cursor: pointer;
            }
            .close:hover, .close:focus {
                color: #333;
                text-decoration: none;
            }
            button, .button {
                padding: 6px 12px;
                border: none;
                background-color: #0078d4;
                color: white;
                border-radius: 4px;
                cursor: pointer;
                text-decoration: none;
                display: inline-block;
            }
            button:hover, .button:hover {
                background-color: #005fa3;
            }
            .modal-content h2 {
                margin-top: 0;
                margin-bottom: 20px;
                font-size: 24px;
                font-weight: 600;
                color: #333;
                border-bottom: 1px solid #eee;
                padding-bottom: 15px;
            }
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
            .modal-content input[type="text"], .modal-content input[type="number"], .modal-content textarea, .modal-content select {
                width: 100%;
                padding: 10px 12px;
                border: 1px solid #ccc;
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 15px;
                transition: border-color 0.2s, box-shadow 0.2s;
            }
            .modal-content input:focus, .modal-content textarea:focus, .modal-content select:focus {
                border-color: #0078d4;
                outline: none;
                box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.15);
            }
            .modal-content textarea {
                resize: vertical;
                min-height: 80px;
            }
            .modal-content button[type="submit"] {
                width: 100%;
                padding: 12px;
                font-size: 16px;
                font-weight: 600;
                margin-top: 10px;
                background-color: #10B981;
            }
            .modal-content button[type="submit"]:hover {
                background-color: #059669;
            }
        </style>
    </head>
    <body class="bg-gray-50">

        <%-- Lấy User --%>
        <%
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null || currentUser.getRole() != 1) {
                response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
                return;
            }
        %>

        <%-- Include Sidebar --%>
        <%@ include file="Sidebar.jsp" %>
        <%@ include file="NavBar.jsp" %>

        <%-- ✅ Alert Message Box (Lấy từ file cũ) --%>
        <c:if test="${not empty sessionScope.message}">
            <div id="alertBox" class="fixed top-5 right-5 ${sessionScope.messageType == 'error' ? 'bg-red-500' : 'bg-green-500'} text-white px-4 py-3 rounded-lg shadow-lg transition-opacity duration-500 z-[1001]">
                ${sessionScope.message}
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

        <%-- Main Content --%>
        <div class="content-wrapper">
            <div class="flex-1 flex flex-col overflow-hidden">
            <div class="bg-white border-b px-6 py-4 flex justify-between items-center">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">Manage Products</h1>
                    <p class="text-sm text-gray-500">PizzaConnect Restaurant Management System</p>
                </div>
                <div class="text-gray-600">
                    Welcome, <strong>${sessionScope.user.name}</strong>
                </div>
            </div>

            <div class="flex-1 p-6 overflow-auto">
                <%-- ✅ Filter Bar --%>
                <div class="bg-gray-50 p-4 rounded-xl mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex gap-2">
                        <button id="openAddModalBtn" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg">Add Product</button>
                        <a href="${pageContext.request.contextPath}/dashboard" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg button">Dashboard</a>
                    </div>

                    <form action="${pageContext.request.contextPath}/manageproduct" method="GET" class="flex-1 flex flex-wrap gap-4 items-center justify-end">
                        <input type="text" name="searchName" value="${searchName}" placeholder="Search by name..."
                               class="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-400"
                               style="min-width: 200px;">

                        <select name="statusFilter" 
                                class="px-3 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-orange-400">
                            <option value="all" ${statusFilter == 'all' || empty statusFilter ? 'selected' : ''}>All Status</option>
                            <option value="available" ${statusFilter == 'available' ? 'selected' : ''}>Available</option>
                            <option value="unavailable" ${statusFilter == 'unavailable' ? 'selected' : ''}>Unavailable</option>
                        </select>

                        <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-1">
                            <i data-lucide="search" class="w-4 h-4"></i> Filter
                        </button>
                    </form>
                </div>

                <%-- ✅ Bảng Product Đơn giản --%>
                <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div class="bg-gray-800 text-white text-lg font-semibold px-6 py-3">Product Management</div>

                    <table class="min-w-full border-t">
                        <thead class="bg-gray-100">
                            <tr>
                                <th class="px-4 py-2 text-left">Product ID</th>
                                <th class="px-4 py-2 text-left">Image</th>
                                <th class="px-4 py-2 text-left">Name</th>
                                <th class="px-4 py-2 text-left">Category</th>
                                <th class="px-4 py-2 text-left">Status</th>
                                <th class="px-4 py-2 text-left">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            <c:forEach var="p" items="${products}">
                                <tr class="hover:bg-gray-50">
                                    <td class="px-4 py-2 font-semibold">#${p.productId}</td>
                                    <td class="px-4 py-2">
                                        <c:if test="${not empty p.imageUrl}">
                                            <img src="${p.imageUrl}" class="w-14 h-14 rounded-lg object-cover border" alt="Product">
                                        </c:if>
                                        <c:if test="${empty p.imageUrl}">
                                            <span class="text-gray-400 italic">No image</span>
                                        </c:if>
                                    </td>
                                    <td class="px-4 py-2 font-medium">${p.productName}</td>
                                    <td class="px-4 py-2">${p.categoryName}</td>
                                    <td class="px-4 py-2">
                                        <%-- Lấy status từ Map mới (ProductID -> Boolean) --%>
                                        <c:set var="isAvailable" value="${productAvailabilityStatus[p.productId]}" />

                                        <c:choose>
                                            <c:when test="${isAvailable}">
                                                <span class="px-3 py-1 text-white rounded-full text-xs font-semibold bg-green-500">
                                                    Available
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-3 py-1 text-white rounded-full text-xs font-semibold bg-red-500">
                                                    Unavailable
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-2">
                                        <div class="flex flex-wrap gap-2">
                                            <button class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-xs viewSizesBtn"
                                                    data-id="${p.productId}"
                                                    data-name="${p.productName}">
                                                View Sizes
                                            </button>
                                            <button class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1 rounded text-xs editBtn"
                                                    data-id="${p.productId}"
                                                    data-name="${p.productName}"
                                                    data-desc="${p.description}"
                                                    data-category="${p.categoryName}"
                                                    data-image="${p.imageUrl}"
                                                    data-available="${p.available}">
                                                Edit
                                            </button>
                                            <a href="${pageContext.request.contextPath}/DeleteProduct?productId=${p.productId}"
                                               onclick="return confirm('Are you sure? This will delete the product and ALL its sizes.');"
                                               class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs button">Delete</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <%-- ✅ Phân trang (Lấy từ file cũ và cập nhật) --%>
                    <div class="flex justify-center items-center p-4 space-x-2">
                        <c:if test="${currentPage > 1}">
                            <c:url var="prevUrl" value="/manageproduct">
                                <c:param name="page" value="${currentPage - 1}" />
                                <c:param name="searchName" value="${searchName}" />
                                <c:param name="statusFilter" value="${statusFilter}" />
                            </c:url>
                            <a href="${prevUrl}" class="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded button">Previous</a>
                        </c:if>

                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <c:url var="pageUrl" value="/manageproduct">
                                <c:param name="page" value="${i}" />
                                <c:param name="searchName" value="${searchName}" />
                                <c:param name="statusFilter" value="${statusFilter}" />
                            </c:url>
                            <a href="${pageUrl}"
                               class="px-3 py-1 rounded button ${i == currentPage ? 'bg-orange-500 text-white' : 'bg-gray-200 hover:bg-gray-300'}">
                                ${i}
                            </a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <c:url var="nextUrl" value="/manageproduct">
                                <c:param name="page" value="${currentPage + 1}" />
                                <c:param name="searchName" value="${searchName}" />
                                <c:param name="statusFilter" value="${statusFilter}" />
                            </c:url>
                            <a href="${nextUrl}" class="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded button">Next</a>
                        </c:if>
                    </div>
                </div>
            </div>
            </div>
        </div>

        <%-- 1. Modal Thêm Product (ĐƠN GIẢN) --%>
        <%-- 1. Modal Thêm Product (ĐƠN GIẢN) --%>
        <div id="addProductModal" class="modal">
            <div class="modal-content">
                <span class="close">&times;</span>
                <h2>Add New Product</h2>
                <%-- ✅ THAY ĐỔI 1: Thêm enctype="multipart/form-data" --%>
                <form action="${pageContext.request.contextPath}/AddProductServlet" method="post" enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Product Name:</label>
                        <input type="text" name="productName" required>
                    </div>
                    <div class="form-group">
                        <label>Description:</label>
                        <textarea name="description" rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="addCategoryName">Category:</label>
                        <select name="categoryName" id="addCategoryName" required>
                            <option value="">-- Select a Category --</option>
                            <c:forEach var="cat" items="${categoryList}">
                                <option value="${cat.categoryName}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <%-- ✅ THAY ĐỔI 2: Thay input type="text" bằng type="file" --%>
                    <div class="form-group">
                        <label>Product Image (File):</label>
                        <input type="file" name="productImage" accept="image/*">
                    </div>
                    <button type="submit">Save Product</button>
                </form>
            </div>
        </div>

        <%-- 2. Modal Sửa Product (ĐƠN GIẢN) --%>
        <div id="editProductModal" class="modal">
            <div class="modal-content">
                <span class="close">&times;</span>
                <h2>Edit Product</h2>
                <%-- ✅ THAY ĐỔI 3: Thêm enctype="multipart/form-data" --%>
                <form action="${pageContext.request.contextPath}/EditProductServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="productId" id="editProductId">
                    <%-- Thêm input hidden để lưu URL ảnh cũ --%>
                    <input type="hidden" name="existingImageUrl" id="existingImageUrl"> 
                    <div class="form-group">
                        <label>Product Name:</label>
                        <input type="text" name="productName" id="editProductName" required>
                    </div>
                    <div class="form-group">
                        <label>Description:</label>
                        <textarea name="description" id="editDescription" rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="editCategoryName">Category:</label>
                        <select name="categoryName" id="editCategoryName" required>
                            <option value="">-- Select a Category --</option>
                            <c:forEach var="cat" items="${categoryList}">
                                <option value="${cat.categoryName}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <%-- ✅ THAY ĐỔI 4: Thay input type="text" bằng type="file" --%>
                    <div class="form-group">
                        <label>New Product Image (Optional):</label>
                        <input type="file" name="newProductImage" id="editNewProductImage" accept="image/*">
                        <p class="text-xs text-gray-500 mt-1">Leave blank to keep current image.</p>
                    </div>
                    <button type="submit">Update Product</button>
                </form>
            </div>
        </div>

        <%-- 3. Modal Xem Sizes (Vỏ rỗng) --%>
        <div id="viewSizesModal" class="modal">
            <div class="modal-content" style="width: 800px;">
                <%-- Nội dung (ProductSizesDetail.jsp) sẽ được load vào đây --%>
                Loading sizes...
            </div>
        </div>

        <%-- 4. Modal Thêm Size (Vỏ rỗng) --%>
        <div id="addSizeModal" class="modal">
            <div class="modal-content">
                <%-- Nội dung (AddProductSizeForm.jsp) sẽ được load vào đây --%>
                Loading form...
            </div>
        </div>

        <%-- 5. Modal Sửa Size (Vỏ rỗng) --%>
        <div id="editSizeModal" class="modal">
            <div class="modal-content">
                <%-- Nội dung (EditProductSizeForm.jsp) sẽ được load vào đây --%>
                Loading form...
            </div>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", () => {
                lucide.createIcons();

                // Lấy các vỏ modal
                const addProductModal = document.getElementById("addProductModal");
                const editProductModal = document.getElementById("editProductModal");
                const viewSizesModal = document.getElementById("viewSizesModal");
                const addSizeModal = document.getElementById("addSizeModal");
                const editSizeModal = document.getElementById("editSizeModal");

                // Lắng nghe click trên toàn bộ body
                document.body.addEventListener('click', function (e) {

                    // ✅ Dùng e.target.closest()
                    const viewBtn = e.target.closest('.viewSizesBtn');
                    const editBtn = e.target.closest('.editBtn');
                    const addSizeBtn = e.target.closest('.addSizeBtn');
                    const editSizeBtn = e.target.closest('.editSizeBtn');
                    const closeBtn = e.target.closest('.close');
                    const addIngBtn = e.target.closest('#addIngredientBtn_AddSize');
                    const editAddIngBtn = e.target.closest('#editAddIngredientBtn_EditSize');
                    const removeIngBtn = e.target.closest('.removeIng, .removeBtn');

                    // === 1. Mở Modal Add Product ===
                    if (e.target.id === 'openAddModalBtn') {
                        addProductModal.style.display = "block";
                    }

                    // === 2. Mở Modal Edit Product ===
                    if (editBtn) {
                        const data = editBtn.dataset; // Lấy data từ button
                        document.getElementById("editProductId").value = data.id;
                        document.getElementById("editProductName").value = data.name;
                        document.getElementById("editDescription").value = data.desc;
                        document.getElementById("editCategoryName").value = data.category;
                        
                        // ✅ Dòng này đã được thay thế để lưu URL cũ vào input hidden mới
                        const existingImageUrlInput = document.getElementById("existingImageUrl");
                        if (existingImageUrlInput) {
                            existingImageUrlInput.value = data.image;
                        }
                        
                        // Reset input file để không gửi file cũ
                        const editNewProductImageInput = document.getElementById("editNewProductImage");
                        if (editNewProductImageInput) {
                            editNewProductImageInput.value = ''; 
                        }

                        // Cuối cùng mới hiển thị modal
                        editProductModal.style.display = "block";
                    }

                    // === 3. Mở Modal View Sizes (Fetch) ===
                    if (viewBtn) {
                        const productId = viewBtn.dataset.id; // Lấy data từ button
                        const contentDiv = viewSizesModal.querySelector(".modal-content");
                        contentDiv.innerHTML = "Loading...";
                        viewSizesModal.style.display = "block";

                        // ✅ SỬA LỖI: Dùng scriptlet trực tiếp (Cách bạn đã xác nhận)
                        fetch("<%= request.getContextPath() %>/ViewProductSizesServlet?productId=" + productId)
                                .then(res => res.ok ? res.text() : Promise.reject(res.status))
                                .then(html => {
                                    contentDiv.innerHTML = html;
                                    lucide.createIcons();
                                })
                                .catch(err => contentDiv.innerHTML = "Error loading sizes: " + err);
                    }

                    // === 4. Mở Modal Add Size (Fetch) ===
                    if (addSizeBtn) {
                        const productId = addSizeBtn.dataset.productId;
                        const contentDiv = addSizeModal.querySelector(".modal-content");
                        contentDiv.innerHTML = "Loading form...";

                        viewSizesModal.style.display = "none";
                        addSizeModal.style.display = "block";

                        // ✅ SỬA LỖI: Áp dụng cách mới
                        fetch("<%= request.getContextPath() %>/LoadAddSizeFormServlet?productId=" + productId)
                                .then(res => res.ok ? res.text() : Promise.reject(res.status))
                                .then(html => contentDiv.innerHTML = html)
                                .catch(err => contentDiv.innerHTML = "Error loading form.");
                    }

                    // === 5. Mở Modal Edit Size (Fetch) ===
                    if (editSizeBtn) {
                        const sizeId = editSizeBtn.dataset.sizeId;
                        const contentDiv = editSizeModal.querySelector(".modal-content");
                        contentDiv.innerHTML = "Loading form...";

                        viewSizesModal.style.display = "none";
                        editSizeModal.style.display = "block";

                        // ✅ SỬA LỖI: Áp dụng cách mới
                        fetch("<%= request.getContextPath() %>/LoadEditSizeFormServlet?productSizeId=" + sizeId)
                                .then(res => res.ok ? res.text() : Promise.reject(res.status))
                                .then(html => contentDiv.innerHTML = html)
                                .catch(err => contentDiv.innerHTML = "Error loading form.");
                    }

                    // === 6. Đóng Modal ===
                    if (closeBtn) {
                        closeBtn.closest(".modal").style.display = "none";
                    }

                    // === 7. Xóa hàng nguyên liệu ===
                    if (removeIngBtn) {
                        removeIngBtn.closest(".ingredient-row, tr").remove();
                    }

                    // === 8. Thêm hàng (Modal Add Size) ===
                    if (addIngBtn) {
                        e.preventDefault();

                        const tableBody = document.getElementById('ingredientList_AddSize');
                        const select = document.getElementById('newIngredientSelect_AddSize');
                        const qtyInputEl = document.getElementById('newQuantity_AddSize');
                        const unitInputEl = document.getElementById('newUnit_AddSize');

                        if (!tableBody || !select || !qtyInputEl || !unitInputEl)
                            return;

                        const selectedOption = select.options[select.selectedIndex];
                        const ingId = selectedOption.value;
                        const ingName = selectedOption.text;
                        const qtyValue = qtyInputEl.value.trim();
                        const unit = selectedOption.getAttribute('data-unit') || '';

                        if (!ingId) {
                            alert("Please select an ingredient.");
                            return;
                        }

                        if (!qtyValue || parseFloat(qtyValue) <= 0) {
                            alert("Please enter a valid quantity.");
                            return;
                        }

                        console.log("Adding ingredient:", { ingName, qtyValue, ingId, unit });

                        // ✅ Tạo DOM element thủ công (giống EditProductSizeForm)
                        const tr = document.createElement('tr');
                        tr.classList.add('border-b');

                        // Tên nguyên liệu
                        const tdName = document.createElement('td');
                        tdName.className = 'px-2 py-1';
                        tdName.textContent = ingName;

                        // Số lượng + hidden inventoryId
                        const tdQty = document.createElement('td');
                        tdQty.className = 'px-2 py-1';

                        const qtyInput = document.createElement('input');
                        qtyInput.type = 'number';
                        qtyInput.step = '0.01';
                        qtyInput.name = 'ingredientQty[]';
                        qtyInput.value = qtyValue;
                        qtyInput.className = 'border p-1 w-24';

                        const hiddenInv = document.createElement('input');
                        hiddenInv.type = 'hidden';
                        hiddenInv.name = 'ingredientId[]';
                        hiddenInv.value = ingId;

                        tdQty.append(qtyInput, hiddenInv);

                        // Đơn vị
                        const tdUnit = document.createElement('td');
                        tdUnit.className = 'px-2 py-1';
                        const unitInput = document.createElement('input');
                        unitInput.type = 'text';
                        unitInput.name = 'ingredientUnit[]';
                        unitInput.value = unit;
                        unitInput.className = 'border p-1 w-20';
                        unitInput.readOnly = true;
                        tdUnit.appendChild(unitInput);

                        // Nút xoá
                        const tdAction = document.createElement('td');
                        tdAction.className = 'px-2 py-1 text-center';
                        const removeBtn = document.createElement('button');
                        removeBtn.type = 'button';
                        removeBtn.textContent = '✕';
                        removeBtn.className = 'removeBtn bg-red-500 text-white px-2 py-1 rounded inline-flex justify-center items-center';
                        removeBtn.addEventListener('click', () => tr.remove());
                        tdAction.appendChild(removeBtn);

                        // Gắn tất cả lại
                        tr.append(tdName, tdQty, tdUnit, tdAction);
                        tableBody.appendChild(tr);

                        // ✅ Reset form
                        select.selectedIndex = 0;
                        qtyInputEl.value = '';
                        unitInputEl.value = '';
                    }

                    // === 9. Thêm hàng (Modal Edit Size) ===
                    if (editAddIngBtn) {
    e.preventDefault();

    const tableBody = document.getElementById('ingredientTable_EditSize')?.querySelector('tbody');
    const select = document.getElementById('editNewIngredientSelect_EditSize');
    const qtyInputEl = document.getElementById('editNewQuantity_EditSize');
    const unitInputEl = document.getElementById('editNewUnit_EditSize');

    if (!tableBody || !select || !qtyInputEl || !unitInputEl)
        return;

    const selectedOption = select.options[select.selectedIndex];
    const ingId = selectedOption.value;
    const ingName = selectedOption.text;
    const qtyValue = qtyInputEl.value.trim();
    const unit = selectedOption.getAttribute('data-unit') || '';

    if (!ingId) {
        alert("Please select an ingredient.");
        return;
    }

    if (!qtyValue || parseFloat(qtyValue) <= 0) {
        alert("Please enter a valid quantity.");
        return;
    }

    console.log("Adding ingredient:", { ingName, qtyValue, ingId, unit });

    // ✅ Tạo DOM element thủ công (không dùng innerHTML)
    const tr = document.createElement('tr');
    tr.classList.add('border-b');

    // Tên nguyên liệu
    const tdName = document.createElement('td');
    tdName.className = 'px-2 py-1';
    tdName.textContent = ingName;

    // Số lượng + hidden inventoryId
    const tdQty = document.createElement('td');
    tdQty.className = 'px-2 py-1';

    const qtyInput = document.createElement('input');
    qtyInput.type = 'number';
    qtyInput.step = '0.01';
    qtyInput.name = 'quantity[]';
    qtyInput.value = qtyValue;
    qtyInput.className = 'border p-1 w-24';

    const hiddenInv = document.createElement('input');
    hiddenInv.type = 'hidden';
    hiddenInv.name = 'inventoryId[]';
    hiddenInv.value = ingId;

    tdQty.append(qtyInput, hiddenInv);

    // Đơn vị
    const tdUnit = document.createElement('td');
    tdUnit.className = 'px-2 py-1';
    const unitInput = document.createElement('input');
    unitInput.type = 'text';
    unitInput.name = 'unit[]';
    unitInput.value = unit;
    unitInput.className = 'border p-1 w-20';
    unitInput.readOnly = true;
    tdUnit.appendChild(unitInput);

    // Nút xoá
    const tdAction = document.createElement('td');
    tdAction.className = 'px-2 py-1 text-center';
    const removeBtn = document.createElement('button');
    removeBtn.type = 'button';
    removeBtn.textContent = '✕';
    removeBtn.className = 'removeBtn bg-red-500 text-white px-2 py-1 rounded inline-flex justify-center items-center';
    removeBtn.addEventListener('click', () => tr.remove());
    tdAction.appendChild(removeBtn);

    // Gắn tất cả lại
    tr.append(tdName, tdQty, tdUnit, tdAction);
    tableBody.appendChild(tr);

    // ✅ Reset form
    select.selectedIndex = 0;
    qtyInputEl.value = '';
    unitInputEl.value = '';
}



                }); // Hết listener CLICK

                // === 10. Lắng nghe thay đổi (CHANGE) ===
                document.body.addEventListener('change', function (e) {
                    if (e.target.classList.contains('ingredientSelect')) {
                        const select = e.target;
                        const row = select.closest('.ingredient-row');
                        const unitInput = row?.querySelector('.unitField');
                        if (unitInput) {
                            const option = select.selectedOptions[0];
                            unitInput.value = option.getAttribute('data-unit') || '';
                        }
                    }
                    if (e.target.id === 'editNewIngredientSelect_EditSize') {
                        const select = e.target;
                        const unitInput = document.getElementById('editNewUnit_EditSize');
                        if (unitInput) {
                            const option = select.selectedOptions[0];
                            unitInput.value = option.getAttribute('data-unit') || '';
                        }
                    }
                    if (e.target.id === 'newIngredientSelect_AddSize') {
                        const select = e.target;
                        const unitInput = document.getElementById('newUnit_AddSize');
                        if (unitInput) {
                            const option = select.selectedOptions[0];
                            unitInput.value = option.getAttribute('data-unit') || '';
                        }
                    }
                }); // Hết listener CHANGE

                // Đóng modal khi click bên ngoài
                window.addEventListener("click", e => {
                    if (e.target.classList.contains("modal")) {
                        e.target.style.display = "none";
                    }
                });

            }); // Hết DOMContentLoaded
        </script>

    </body>
</html>