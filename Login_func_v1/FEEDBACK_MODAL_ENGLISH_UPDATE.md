# Feedback Modal - English Translation Update

## Overview

Đã chuyển tất cả text trong feedback modal popup từ tiếng Việt sang tiếng Anh để đồng bộ với hệ thống.

## Changes Made

### 1. Modal Header

**Before (Vietnamese):**

- Title: "⭐ Đánh giá trải nghiệm"
- Subtitle: "Đơn hàng #"

**After (English):**

- Title: "⭐ Rate Your Experience"
- Subtitle: "Order #"

### 2. Rating Label

**Before:** "Chọn số sao đánh giá"
**After:** "Select your rating"

### 3. Rating Text Labels

| Stars       | Before (Vietnamese) | After (English) |
| ----------- | ------------------- | --------------- |
| 1⭐         | Rất kém             | Very Poor       |
| 2⭐⭐       | Kém                 | Poor            |
| 3⭐⭐⭐     | Trung bình          | Average         |
| 4⭐⭐⭐⭐   | Tốt                 | Good            |
| 5⭐⭐⭐⭐⭐ | Xuất sắc            | Excellent       |

### 4. Textarea Placeholder

**Before:** "Chia sẻ trải nghiệm của bạn về món ăn, dịch vụ... (tùy chọn)"
**After:** "Share your experience about the food, service... (optional)"

### 5. Submit Button

**Before:** "Gửi đánh giá"
**After:** "Submit Rating"

**Loading state:**

- Before: "Đang gửi..."
- After: "Submitting..."

### 6. Validation Messages

#### No rating selected

**Before:** "Vui lòng chọn số sao đánh giá!"
**After:** "Please select a rating!"

#### Order ID not found

**Before:** "Lỗi: Không tìm thấy Order ID. Vui lòng thử lại."
**After:** "Error: Order ID not found. Please try again."

#### Order ID not included

**Before:** "Lỗi: Order ID không được gửi kèm. Vui lòng thử lại."
**After:** "Error: Order ID not included. Please try again."

### 7. Response Messages

#### Success

**Before:** "✓ Cảm ơn bạn đã đánh giá! Trang sẽ tự động tải lại..."
**After:** "✓ Thank you for your feedback! Page will reload..."

#### Error

**Before:** "Lỗi: [message]"
**After:** "Error: [message]"

#### Connection Error

**Before:** "Lỗi kết nối: [message]"
**After:** "Connection error: [message]"

## File Updated

- `Login_func_v1/Login/web/view/OrderHistory.jsp`
  - Modal HTML (lines ~543-577)
  - JavaScript resetFeedbackForm() function
  - JavaScript ratingTexts object
  - JavaScript validation messages
  - JavaScript response messages

## Code Examples

### Modal Header (HTML)

```html
<div class="modal-header">
  <span class="close" onclick="closeFeedbackModal()">&times;</span>
  <h2 style="margin: 0; font-size: 24px;">⭐ Rate Your Experience</h2>
  <p style="margin: 5px 0 0 0; opacity: 0.9; font-size: 14px;">
    Order #<span id="modalOrderId"></span>
  </p>
</div>
```

### Rating Labels (JavaScript)

```javascript
const ratingTexts = {
  1: "⭐ Very Poor",
  2: "⭐⭐ Poor",
  3: "⭐⭐⭐ Average",
  4: "⭐⭐⭐⭐ Good",
  5: "⭐⭐⭐⭐⭐ Excellent",
};
```

### Validation (JavaScript)

```javascript
if (!selectedRating) {
  showMessage("Please select a rating!", "error");
  return;
}
```

### Success Message (JavaScript)

```javascript
if (result.success) {
  showMessage("✓ Thank you for your feedback! Page will reload...", "success");
  setTimeout(() => {
    window.location.reload();
  }, 2000);
}
```

## Benefits

1. **Consistency**: Đồng bộ với các phần khác của hệ thống (đều dùng tiếng Anh)
2. **Professional**: Giao diện chuyên nghiệp hơn
3. **International**: Dễ mở rộng cho khách hàng quốc tế
4. **Maintainability**: Dễ bảo trì khi toàn bộ hệ thống dùng một ngôn ngữ

## Testing

### Test Steps

1. Login as Customer
2. Go to Order History
3. Find a completed & paid order
4. Click "Provide Feedback" button
5. Verify all text is in English:
   - ✅ Modal title: "Rate Your Experience"
   - ✅ Rating label: "Select your rating"
   - ✅ Click stars: Shows English rating text
   - ✅ Placeholder: English text
   - ✅ Button: "Submit Rating"
6. Submit without rating: Shows English error
7. Submit with rating: Shows English success message

## Notes

- Giữ nguyên icons và emojis (⭐, ✓)
- Giữ nguyên styling và layout
- Chỉ thay đổi text content
- Không ảnh hưởng đến functionality
