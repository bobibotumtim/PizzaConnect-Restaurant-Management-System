# Dashboard Access Control Fix

## Problem

Manager có thể truy cập vào Admin Dashboard và Waiter Dashboard, gây nhầm lẫn và lỗi bảo mật.

## Issues Fixed

### 1. UserProfile.jsp - Dashboard Button

**Problem:** Nút "Dashboard" luôn link đến `waiter-dashboard` cho tất cả users

**Solution:** Dynamic dashboard link dựa trên role

```jsp
<c:choose>
    <c:when test="${user.role == 1}">
        <a href="dashboard">Admin Dashboard</a>
    </c:when>
    <c:when test="${user.role == 2 and employee.jobRole == 'Manager'}">
        <a href="manager-dashboard">Manager Dashboard</a>
    </c:when>
    <c:when test="${user.role == 2}">
        <a href="waiter-dashboard">Waiter Dashboard</a>
    </c:when>
    <c:otherwise>
        <a href="home">Home</a>
    </c:otherwise>
</c:choose>
```

### 2. WaiterDashboardServlet - Block Manager Access

**Problem:** Manager có thể truy cập Waiter Dashboard

**Solution:** Thêm check và redirect Manager

```java
// Chặn Manager - redirect về Manager Dashboard
if (employee != null && "Manager".equalsIgnoreCase(employee.getJobRole())) {
    response.sendRedirect("manager-dashboard");
    return;
}
```

### 3. DashboardController - Admin Only Access

**Problem:** Không có authentication check, ai cũng có thể truy cập Admin Dashboard

**Solution:** Thêm authentication và chặn non-Admin users

```java
// Check authentication - Only Admin allowed
HttpSession session = req.getSession(false);
if (session == null || session.getAttribute("user") == null) {
    resp.sendRedirect("Login");
    return;
}

User currentUser = (User) session.getAttribute("user");
Employee employee = (Employee) session.getAttribute("employee");

// Only Admin (role 1) can access Admin Dashboard
if (currentUser.getRole() != 1) {
    // Redirect Manager to Manager Dashboard
    if (currentUser.getRole() == 2 && employee != null && "Manager".equalsIgnoreCase(employee.getJobRole())) {
        resp.sendRedirect("manager-dashboard");
        return;
    }
    // Redirect other employees to their dashboard
    else if (currentUser.getRole() == 2) {
        resp.sendRedirect("waiter-dashboard");
        return;
    }
    // Redirect customers to home
    else {
        resp.sendRedirect("home");
        return;
    }
}
```

## Access Control Matrix

| User Role                               | Can Access                                  | Redirected From     |
| --------------------------------------- | ------------------------------------------- | ------------------- |
| **Admin (Role 1)**                      | ✅ Admin Dashboard (`/dashboard`)           | -                   |
|                                         | ❌ Manager Dashboard                        | → Admin Dashboard   |
|                                         | ❌ Waiter Dashboard                         | → Admin Dashboard   |
| **Manager (Role 2 + JobRole=Manager)**  | ✅ Manager Dashboard (`/manager-dashboard`) | -                   |
|                                         | ❌ Admin Dashboard                          | → Manager Dashboard |
|                                         | ❌ Waiter Dashboard                         | → Manager Dashboard |
| **Employee (Role 2 + JobRole≠Manager)** | ✅ Waiter Dashboard (`/waiter-dashboard`)   | -                   |
|                                         | ❌ Admin Dashboard                          | → Waiter Dashboard  |
|                                         | ❌ Manager Dashboard                        | → Waiter Dashboard  |
| **Chef (Role 2 + isChef=true)**         | ✅ Chef Monitor (`/chef-monitor`)           | -                   |
|                                         | ❌ All Dashboards                           | → Chef Monitor      |
| **Customer (Role 3)**                   | ✅ Home (`/home`)                           | -                   |
|                                         | ❌ All Dashboards                           | → Home              |

## Files Modified

### 1. UserProfile.jsp

- **Location**: `Login_func_v1/Login/web/view/UserProfile.jsp`
- **Changes**:
  - Dynamic dashboard button based on user role
  - Correct role display in navbar
  - Manager shows "Manager" instead of "Waiter"

### 2. WaiterDashboardServlet.java

- **Location**: `Login_func_v1/Login/src/java/controller/WaiterDashboardServlet.java`
- **Changes**:
  - Added Manager check
  - Redirect Manager to `manager-dashboard`
  - Prevents Manager from accessing Waiter Dashboard

### 3. DashboardController.java

- **Location**: `Login_func_v1/Login/src/java/controller/DashboardController.java`
- **Changes**:
  - Added authentication check
  - Only Admin (role 1) can access
  - Redirect non-Admin users to appropriate dashboard

## Security Benefits

1. **Role Separation**: Each role has its own dashboard
2. **No Cross-Access**: Manager cannot access Admin or Waiter dashboards
3. **Automatic Redirect**: Users are redirected to correct dashboard
4. **URL Protection**: Even with direct URL access, users are redirected
5. **Clear Boundaries**: Each role has clear access boundaries

## Testing

### Test Case 1: Manager Login

1. Login as Manager
2. Go to Profile page
3. Click "Dashboard" button
4. **Expected**: Redirected to Manager Dashboard
5. **Before**: Redirected to Waiter Dashboard ❌
6. **After**: Redirected to Manager Dashboard ✅

### Test Case 2: Manager Direct URL Access

1. Login as Manager
2. Type `/Login/dashboard` in browser
3. **Expected**: Redirected to Manager Dashboard
4. **Before**: Can access Admin Dashboard ❌
5. **After**: Redirected to Manager Dashboard ✅

### Test Case 3: Manager Waiter Dashboard Access

1. Login as Manager
2. Type `/Login/waiter-dashboard` in browser
3. **Expected**: Redirected to Manager Dashboard
4. **Before**: Can access Waiter Dashboard ❌
5. **After**: Redirected to Manager Dashboard ✅

### Test Case 4: Admin Access

1. Login as Admin
2. Access `/Login/dashboard`
3. **Expected**: Can access Admin Dashboard
4. **Result**: ✅ Works correctly

### Test Case 5: Waiter Access

1. Login as Waiter
2. Access `/Login/waiter-dashboard`
3. **Expected**: Can access Waiter Dashboard
4. **Result**: ✅ Works correctly

## URL Mappings

- `/dashboard` → Admin Dashboard (Admin only)
- `/manager-dashboard` → Manager Dashboard (Manager only)
- `/waiter-dashboard` → Waiter Dashboard (Waiter/Employee only)
- `/chef-monitor` → Chef Monitor (Chef only)
- `/home` → Home (Customer)

## Notes

- Authentication checks are at servlet level
- Redirects happen before page load
- No error messages shown (seamless redirect)
- Session-based authentication
- Role and JobRole both checked for Manager

## Rollback (If Needed)

If issues occur, revert these changes:

### UserProfile.jsp

```jsp
<!-- Old code -->
<a href="waiter-dashboard" class="...">Dashboard</a>
```

### WaiterDashboardServlet.java

```java
// Remove Manager check
// if (employee != null && "Manager".equalsIgnoreCase(employee.getJobRole())) {
//     response.sendRedirect("manager-dashboard");
//     return;
// }
```

### DashboardController.java

```java
// Remove authentication block at the beginning of doGet()
```
