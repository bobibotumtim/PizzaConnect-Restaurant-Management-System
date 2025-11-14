# 🔧 Browser Cache Issue - Fix Instructions

## ✅ Server đang trả về content ĐÚNG!

Đã verify qua PowerShell:

```
URL: http://localhost:8080/Login/view/SimpleFeedbackForm.jsp?orderId=2
Server Response: "Đơn hàng #2" ✅
Hidden Input: <input name="orderId" value="2"> ✅
```

## ⚠️ Vấn đề: Browser đang cache trang cũ!

Browser của bạn đang hiển thị cached version với lỗi "Order ID không được để trống".

## 🔧 Giải pháp (thử theo thứ tự):

### 1. Hard Refresh (Khuyến nghị)

- **Windows/Linux:** `Ctrl + Shift + R` hoặc `Ctrl + F5`
- **Mac:** `Cmd + Shift + R`

### 2. Clear Browser Cache

1. Mở Developer Tools: `F12`
2. Right-click vào nút Refresh
3. Chọn "Empty Cache and Hard Reload"

### 3. Incognito/Private Mode

- **Chrome:** `Ctrl + Shift + N`
- **Firefox:** `Ctrl + Shift + P`
- **Edge:** `Ctrl + Shift + N`

Sau đó truy cập: `http://localhost:8080/Login/view/SimpleFeedbackForm.jsp?orderId=2`

### 4. Clear Specific Site Data

1. Mở Developer Tools (`F12`)
2. Tab "Application" (Chrome) hoặc "Storage" (Firefox)
3. Right-click "localhost:8080" → "Clear"
4. Refresh trang

### 5. Disable Cache trong Developer Tools

1. Mở Developer Tools (`F12`)
2. Tab "Network"
3. Check "Disable cache"
4. Giữ Developer Tools mở và refresh trang

### 6. Add Cache-Busting Parameter

Thử URL này:

```
http://localhost:8080/Login/view/SimpleFeedbackForm.jsp?orderId=2&t=123456
```

## 🧪 Verify Server Response

Để chắc chắn server đang trả về đúng, chạy command này trong PowerShell:

```powershell
$response = Invoke-WebRequest -Uri "http://localhost:8080/Login/view/SimpleFeedbackForm.jsp?orderId=2" -Method GET
$response.Content | Select-String -Pattern "Đơn hàng #"
```

Kết quả phải là: `<p class="subtitle" id="pageSubtitle">Đơn hàng #2</p>`

## ✅ Expected Result

Sau khi clear cache, bạn sẽ thấy:

- ⭐ Đánh giá trải nghiệm
- **Đơn hàng #2** (không còn lỗi)
- 5 stars để chọn rating
- Comment box
- Button "Gửi đánh giá"

## 🎯 Nếu vẫn không được

Thử restart browser hoàn toàn:

1. Close tất cả browser windows
2. Mở lại browser
3. Truy cập URL trong incognito mode

## 📝 Technical Details

- Server Status: 200 OK ✅
- Content-Length: 7972 bytes ✅
- Content-Type: text/html;charset=UTF-8 ✅
- Response contains: "Đơn hàng #2" ✅
- Hidden input value: "2" ✅

**Kết luận:** Server hoạt động hoàn hảo. Chỉ cần clear browser cache!
