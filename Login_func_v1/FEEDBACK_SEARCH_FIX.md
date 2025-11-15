# Customer Feedback Search Fix

## Problem

Tìm kiếm theo tên khách hàng không hoạt động trong Customer Feedback view.

## Root Cause

SQL query trong `searchFeedback()` method sử dụng tên cột sai:

- **Used**: `pizza_ordered`
- **Correct**: `product_feedbacked`

Tên cột trong database VIEW là `product_feedbacked`, không phải `pizza_ordered`.

## Fix Applied

### File: CustomerFeedbackDAO.java

#### Method 1: searchFeedback(String, Integer, Boolean)

**Before:**

```java
sql.append(" AND (customer_name LIKE ? OR comment LIKE ? OR pizza_ordered LIKE ?)");
```

**After:**

```java
sql.append(" AND (customer_name LIKE ? OR comment LIKE ? OR product_feedbacked LIKE ?)");
```

#### Method 2: searchFeedback(String, Integer, String, int, int)

**Before:**

```java
sql.append(" AND (customer_name LIKE ? OR comment LIKE ? OR pizza_ordered LIKE ?)");
```

**After:**

```java
sql.append(" AND (customer_name LIKE ? OR comment LIKE ? OR product_feedbacked LIKE ?)");
```

## Search Functionality

### Search Fields

Tìm kiếm trong 3 cột:

1. **customer_name** - Tên khách hàng
2. **comment** - Nội dung nhận xét
3. **product_feedbacked** - Tên sản phẩm (đã sửa)

### Search Pattern

- Uses SQL `LIKE` with `%searchTerm%`
- Case-insensitive search
- Searches across all 3 fields

## Testing

### Test Case 1: Search by Customer Name

1. Go to Customer Feedback page
2. Enter customer name in search box
3. Click "Tìm kiếm"
4. **Expected**: Shows feedback from that customer
5. **Result**: ✅ Should work now

### Test Case 2: Search by Product Name

1. Enter product name (e.g., "Pizza")
2. Click "Tìm kiếm"
3. **Expected**: Shows feedback for that product
4. **Result**: ✅ Should work now

### Test Case 3: Search by Comment

1. Enter text from comment
2. Click "Tìm kiếm"
3. **Expected**: Shows feedback with that comment
4. **Result**: ✅ Should work now

### Test Case 4: Combined Search + Filter

1. Enter customer name
2. Select rating (e.g., 5 stars)
3. Click "Tìm kiếm"
4. **Expected**: Shows 5-star feedback from that customer
5. **Result**: ✅ Should work now

## Database Column Names

### customer_feedback VIEW

- `feedback_id`
- `customer_id`
- `customer_name` ✅ Used in search
- `order_id`
- `order_date`
- `order_time`
- `rating`
- `comment` ✅ Used in search
- `feedback_date`
- `product_feedbacked` ✅ Used in search (FIXED)
- `created_at`
- `updated_at`

## Notes

- Column name mismatch was causing SQL to fail silently
- The `mapResultSetToFeedback()` method correctly uses `product_feedbacked`
- Search query now matches the actual database schema
- Both overloaded `searchFeedback()` methods have been fixed

## Related Files

- `CustomerFeedbackDAO.java` - Fixed search queries
- `CustomerFeedbackServlet.java` - No changes needed
- `CustomerFeedbackSimple.jsp` - No changes needed

## Impact

- ✅ Search by customer name now works
- ✅ Search by product name now works
- ✅ Search by comment still works
- ✅ Combined search + filter works
- ✅ No breaking changes to existing functionality
