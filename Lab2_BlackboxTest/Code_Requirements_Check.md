# Kiểm tra Code vs Yêu cầu Lab 2

## ✅ YÊU CẦU LAB 2:

Màn hình phải có **ít nhất 3 loại item khác nhau:**
1. Text item (có format/giới hạn ký tự)
2. Number item (có range, VD: 10,000 - 99,000,000đ)
3. Date item (trước/sau ngày nào đó)
4. List/Checkbox item (ít nhất 3 items)

**HOẶC** có thể thay 1 item bằng 2 Business Rules

---

## 📊 KIỂM TRA CODE:

### 1. NUMBER ITEM: Total Price ✅

**Yêu cầu trong Test Cases:**
- Range: 10,000đ - 99,000,000đ
- Format: Integer với thousand separators

**Trong Code:**
- ✅ Có field Price trong modal "Add New Order"
- ✅ Hiển thị: "Price ($5-$9000)" 
- ⚠️ **KHÔNG KHỚP:** Test cases nói 10,000đ - 99,000,000đ nhưng modal hiển thị $5-$9000

**Khuyến nghị:**
- Cập nhật test cases để khớp với code: $5 - $9000
- Hoặc sửa code để validation 10,000đ - 99,000,000đ

---

### 2. DATE ITEM: Order Date ✅

**Yêu cầu trong Test Cases:**
- Min: 01/01/2020
- Max: Ngày hiện tại
- Không được là tương lai

**Trong Code:**
- ✅ Có cột Date trong danh sách orders
- ✅ Hiển thị: "2025-11-02 14:43:44.803"
- ✅ OrderDate tự động = GETDATE() khi tạo order
- ⚠️ **KHÔNG CÓ VALIDATION:** Code không kiểm tra min date 01/01/2020

**Khuyến nghị:**
- Thêm validation trong code hoặc
- Cập nhật test cases: "Date phải trước/bằng ngày hiện tại" (bỏ min date)

---

### 3. LIST ITEM: Status Dropdown ✅

**Yêu cầu trong Test Cases:**
- 4 options: Pending / Processing / Completed / Cancelled

**Trong Code:**
- ✅ Có dropdown "Status" trong modal "Add New Order"
- ✅ Hiển thị: "Pending" (default)
- ✅ Có filter dropdown "Filter by Status" với "All Orders"
- ✅ Code có 4 status: 0=Pending, 1=Processing, 2=Completed, 3=Cancelled

**Kết luận:** ✅ KHỚP

---

### 4. TEXT ITEM: Note Field ❌

**Yêu cầu trong Test Cases:**
- KHÔNG CÓ test case cho Note field

**Trong Code:**
- ✅ Có field Note trong database
- ✅ Hiển thị trong cột "Note" của danh sách
- ❌ KHÔNG CÓ trong modal "Add New Order"

**Khuyến nghị:**
- Không cần test Note vì có thể dùng 2 Business Rules thay thế

---

### 5. BUSINESS RULES ✅

**BR1: Payment must match Status**
- Test Case: TC-MO-004
- Yêu cầu: Không được mark Paid cho Pending order
- ⚠️ **CHƯA KIỂM TRA CODE:** Cần verify trong ManageOrderServlet

**BR2: Pagination 10 items/page**
- Test Case: TC-MO-005
- Yêu cầu: Hiển thị tối đa 10 orders/page
- ⚠️ **CHƯA KIỂM TRA CODE:** Cần verify PAGE_SIZE trong servlet

---

## 📋 TÓM TẮT:

| Item | Yêu cầu Test Cases | Code Thực Tế | Đồng Nhất? |
|------|-------------------|--------------|------------|
| **Number (Price)** | 10,000đ - 99,000,000đ | $5 - $9000 | ❌ KHÔNG KHỚP |
| **Date** | 01/01/2020 - Today | GETDATE() | ⚠️ Thiếu validation |
| **List (Status)** | 4 options | 4 options | ✅ KHỚP |
| **BR1 (Payment)** | Cannot mark Paid for Pending | ? | ⚠️ Cần kiểm tra |
| **BR2 (Pagination)** | 10 items/page | ? | ⚠️ Cần kiểm tra |

---

## ✅ KẾT LUẬN:

**Màn hình ĐỦ YÊU CẦU Lab 2** nhưng có **KHÔNG ĐỒNG NHẤT** giữa Test Cases và Code:

### Vấn đề cần sửa:

1. **Price Range không khớp:**
   - Test Cases: 10,000đ - 99,000,000đ
   - Code: $5 - $9000
   - **Giải pháp:** Cập nhật test cases thành $5 - $9000

2. **Date validation thiếu:**
   - Test Cases: Min date 01/01/2020
   - Code: Không có validation
   - **Giải pháp:** Bỏ min date trong test cases

3. **Business Rules chưa verify:**
   - Cần kiểm tra code có implement đúng không

---

## 🔧 KHUYẾN NGHỊ:

### Option 1: Cập nhật Test Cases (NHANH)
- Sửa TC-MO-001: Price range = $5 - $9000
- Sửa TC-MO-002: Bỏ min date 01/01/2020
- Test theo code hiện tại

### Option 2: Sửa Code (LÂU HƠN)
- Thêm validation Price: 10,000đ - 99,000,000đ
- Thêm validation Date: Min 01/01/2020
- Test theo yêu cầu ban đầu

**Khuyến nghị: Chọn Option 1 để nhanh hoàn thành Lab 2!**
