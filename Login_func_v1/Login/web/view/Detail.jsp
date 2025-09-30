<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="models.Customer, models.User" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Info</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" rel="stylesheet">
    <link href="css/login.css" rel="stylesheet" type="text/css"/>
</head>
<body>
    <div class="container mt-5" style="max-width: 400px;">
<%
    Customer c = (Customer) request.getAttribute("customer");
    User u = (User) request.getAttribute("user");
%>
        <h1 class="h3 mb-3 font-weight-normal text-center">Customer Information</h1>

        <div class="form-group">
            <label>Username</label>
            <input type="text" class="form-control" value="<%= u.getUsername() %>" readonly>
        </div>

        <div class="form-group">
            <label>Họ và tên</label>
            <input type="text" class="form-control" value="<%= c.getName() %>" readonly>
        </div>

        <div class="form-group">
            <label>Số điện thoại</label>
            <input type="text" class="form-control" value="<%= c.getPhone() %>" readonly>
        </div>

        <div class="form-group">
            <label>Email</label>
            <input type="text" class="form-control" value="<%= c.getEmail() %>" readonly>
        </div>

        <div class="form-group">
            <label>Điểm tích luỹ</label>
            <input type="text" class="form-control" value="<%= c.getLoyaltyPoint() %>" readonly>
        </div>
        
            <div class="form-group text-center">
                <a href="profile" class="btn btn-primary btn-block mt-3">
                    <i class="fas fa-edit"></i> Edit
                </a>
            </div>
    </div>
</body>
</html>

