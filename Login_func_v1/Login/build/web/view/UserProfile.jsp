<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User, models.Customer" %>
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
            grid-template-columns: 25% auto 12%;
            gap: 12px 10px;
        }
        label {
            text-align: right;
            align-self: center;
            font-weight: bold;
        }
        input[type="text"], input[type="password"], select {
            width: 100%;
            padding: 8px 10px;
            font-size: 14px;
            box-sizing: border-box;
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
        .back-to-home {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #007bff;
        }
        .back-to-home:hover {
            color: #0056b3; 
            text-decoration: none;
        }
        .password_group {
            display: flex;
            flex-direction: column;
            gap: 10px;
            grid-column: 2 / 3;
        }
    </style>

    <script>
        function enableEdit(field) {
            if (field === 'password') {
                document.getElementById('fakePassword').classList.add('hidden');
                document.getElementById('passwordEditBtn').style.visibility = "hidden";
                document.getElementById('password_group').classList.remove('hidden');
            } else {
                const input = document.getElementById(field);
                if (input) {
                    input.removeAttribute('readonly');
                    input.focus();
                    input.setSelectionRange(input.value.length, input.value.length);
                }
                const btn = document.getElementById(field + 'EditBtn');
                if (btn)
                    btn.style.visibility = "hidden";
            }
            document.getElementById('updateBtn').classList.remove('hidden');
        }
    </script>
</head>

<body>
    <div class="edit-form-container">
        <h2>Update Profile</h2>

        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("message") %></div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="profile" method="post" class="profile_form">
            <!-- Username -->
            <label>Name</label>
            <input type="text" name="username" value="${user.name}" readonly/>
            <span></span>

            <!-- Email -->
            <label>Email</label>
            <input type="text" id="email" name="email" value="${user.email}" readonly/>
            <button type="button" id="emailEditBtn" onclick="enableEdit('email')">Edit</button>

            <!-- Password -->
            <label>Password</label> 
            <div> 
                <input type="password" value="************" readonly id="fakePassword"/> 
                <div id="password_group" class="password_group hidden"> 
                    <input type="password" name="oldPassword" placeholder="Old password"/> 
                    <input type="password" name="newPassword" placeholder="New password"/> 
                    <input type="password" name="confirmPassword" placeholder="Confirm new password"/> 
                </div> 
            </div> 
            <button type="button" id="passwordEditBtn" onclick="enableEdit('password')">Edit</button>

            <!-- Phone -->
            <label>Phone</label>
            <input type="text" id="phone" name="phone" value="${user.phone}" readonly/>
            <button type="button" id="phoneEditBtn" onclick="enableEdit('phone')">Edit</button>

            <!-- Gender -->
            <label>Gender</label>
            <select id="gender" name="gender" disabled>
                <option value="Male" ${user.gender == 'Male' ? 'selected' : ''}>Male</option>
                <option value="Female" ${user.gender == 'Female' ? 'selected' : ''}>Female</option>
                <option value="Other" ${user.gender == 'Other' ? 'selected' : ''}>Other</option>
            </select>
            <button type="button" id="genderEditBtn" onclick="document.getElementById('gender').disabled=false; this.style.visibility='hidden'; document.getElementById('updateBtn').classList.remove('hidden');">Edit</button>


            <!-- Submit -->
            <div id="updateBtn" class="hidden">
                <input type="submit" class="btn btn-success" value="Update"/>
            </div>
        </form>

        <a href="view/Home.jsp" class="back-to-home">Back to Home</a>
    </div>
</body>
</html>
