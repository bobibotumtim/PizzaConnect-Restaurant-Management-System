# Test Inventory Monitor Access

## Test Cases

### Test 1: Direct URL Access

**URL**: `http://localhost:8080/Login/inventorymonitor`
**Expected**: ✅ Trang inventory monitor hiển thị bình thường
**Status**: PASS

### Test 2: Direct URL Access (với dấu gạch ngang)

**URL**: `http://localhost:8080/Login/inventory-monitor`
**Expected**: ✅ Trang inventory monitor hiển thị bình thường
**Status**: PASS

### Test 3: Click từ Manager Dashboard Sidebar

**Action**: Click vào "Inventory Monitor" trong sidebar
**URL**: `/inventorymonitor`
**Expected**: ✅ Chuyển đến trang inventory monitor
**Status**: PASS (sau khi sửa RoleFilter)

### Test 4: Click từ Manager Dashboard Card

**Action**: Click vào card "Inventory Monitor"
**URL**: `/inventory-monitor`
**Expected**: ✅ Chuyển đến trang inventory monitor
**Status**: PASS (sau khi sửa RoleFilter)

## RoleFilter Logic

### Admin-only pages (Role 1)

- `/admin`
- `/adduser`
- `/edituser`
- `/manageproduct`
- `/discount`
- `/dashboard`
- `/inventory` (NHƯNG KHÔNG bao gồm `/inventorymonitor` và `/inventory-monitor`)

### Manager-accessible pages (Role 2 với jobRole="Manager")

- `/inventorymonitor` ✅
- `/inventory-monitor` ✅
- `/sales-reports`
- `/manager-dashboard`
- `/manager-users`
- `/customer-feedback`

### Waiter-only pages (Role 2)

- `/pos`
- `/manage-orders`
- `/waiter-monitor`
- `/waiter-dashboard`

## Verification Steps

1. Login as Manager (role 2, jobRole="Manager")
2. Verify Manager Dashboard loads
3. Click "Inventory Monitor" in sidebar → Should work ✅
4. Go back to dashboard
5. Click "Inventory Monitor" card → Should work ✅
6. Verify both URLs work directly in browser

## Notes

- RoleFilter đã được cập nhật để exclude cả `/inventorymonitor` và `/inventory-monitor`
- Servlet mapping hỗ trợ cả 2 URL patterns
- Manager Dashboard có 2 links đến inventory monitor (sidebar và card)
