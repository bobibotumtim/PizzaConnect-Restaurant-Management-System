<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Edit User</title>
        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f7f7f7;
            }
            .edit-form-container {
                max-width: 500px;
                margin: 50px auto;
                padding: 30px;
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 6px 12px rgba(0,0,0,0.1);
            }
            .edit-form-container h2 {
                text-align: center;
                margin-bottom: 25px;
            }
            form.profile_form {
                display: grid;
                grid-template-columns: 23% auto 10%;
                gap: 12px 10px;
            }
            label {
                text-align: right;
                align-self: center;
                font-weight: bold;
            }
            input[type="text"], input[type="password"] {
                width: 100%;
                padding: 8px 10px;
                font-size: 14px;
                box-sizing: border-box;
            }
            button {
                text-align: center;
                font-size: 13px;
                height: auto;
            }
            .password_group {
                display: flex;
                flex-direction: column;
                gap: 10px;
                grid-column: 2 / 3;
            }
            .hidden {
                display: none !important;
            }
            #updateBtn {
                grid-column: 1 / -1;
                text-align: center;
                margin-top: 15px;
            }
            #updateBtn input {
                width: 50%;
            }
            button {
                padding: 5px 12px;
                font-size: 13px;
                height: 36px;
                border-radius: 4px;
                border: 1px solid #007bff;
                background-color: #007bff;
                color: white;
                cursor: pointer;
                transition: all 0.2s;
            }
            button:hover {
                background-color: #0056b3;
                border-color: #0056b3;
            }
        </style>
        <script>
            function enableEdit(field) {
                if (field === 'password') {
                    // Ẩn fake password và nút sửa
                    document.getElementById('fakePassword').classList.add('hidden');
                    document.getElementById('passwordEditBtn').style.visibility = "hidden";
                    document.getElementById('password_group').classList.remove('hidden');
                } else {
                    const input = document.getElementById(field);
                    if (input) {
                        input.removeAttribute('readonly');
                        focusAtEnd(input);
                    }
                    // hide EditBtn
                    const btn = document.getElementById(field + 'EditBtn');
                    if (btn)
                        btn.style.visibility = "hidden";
                }

                // show updateBtn
                document.getElementById('updateBtn').classList.remove('hidden');
            }
            function focusAtEnd(input) {
                input.focus();
                input.setSelectionRange(input.value.length, input.value.length);
            }
        </script>
    </head>
    <body>
        <div class="edit-form-container">
            <h2>Thông tin tài khoản</h2>
            <!-- Thông báo thành công / lỗi -->
            <% if (request.getAttribute("message") != null) { %>
                <div class="alert alert-success"><%= request.getAttribute("message") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
            <% } %>
            <form action="${pageContext.request.contextPath}/profile" method="post" class="profile_form">
                <!-- Username -->
                <label>Username:</label>
                <input type="text" name="username" value="${user.username}" readonly/>
                <span></span>

                <!-- Email -->
                <label>Email:</label>
                <input type="text" id="email" name="email" value="${user.email}" readonly/>
                <button type="button" id="emailEditBtn" onclick="enableEdit('email')">Sửa</button>

                <!-- Password -->
                <label>Mật khẩu:</label> 
                <div> 
                    <input type="password" value="************" readonly id="fakePassword"/> 
                    <div id="password_group" class="password_group hidden"> 
                        <input type="password" name="oldPassword" placeholder="Mật khẩu cũ"/> 
                        <input type="password" name="newPassword" placeholder="Mật khẩu mới"/> 
                        <input type="password" name="confirmPassword" placeholder="Xác nhận mật khẩu mới"/> 
                    </div> 
                </div> 
                <button type="button" id="passwordEditBtn" onclick="enableEdit('password')">Sửa</button>

                <!-- Phone -->
                <label>Số điện thoại</label>
                <input type="text" id="phone" name="phone" value="${user.phone}" readonly/>
                <button type="button" id="phoneEditBtn" onclick="enableEdit('phone')">Sửa</button>

                <!-- Submit -->
                <div id="updateBtn" class="hidden">
                    <input type="submit" class="btn btn-success" value="Cập nhật"/>
                </div>
            </form>
        </div>
    </body>
</html>