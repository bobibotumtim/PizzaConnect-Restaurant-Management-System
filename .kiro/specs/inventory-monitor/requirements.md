# Requirements Document - Inventory Monitor

## Introduction

Tính năng Inventory Monitor cho phép Manager xem tình trạng tồn kho của các nguyên liệu theo thời gian thực với hệ thống cảnh báo 4 mức. Đây là tính năng chỉ đọc (read-only), tập trung vào việc giám sát và cảnh báo, khác với tính năng Manage Inventory dùng để chỉnh sửa dữ liệu.

## Glossary

- **Inventory Monitor System**: Hệ thống giám sát tồn kho hiển thị trạng thái nguyên liệu với các mức cảnh báo
- **Warning Level**: Mức độ cảnh báo dựa trên số lượng tồn kho (OK, LOW, CRITICAL, INACTIVE)
- **InventoryMonitor View**: Database view tính toán và cung cấp dữ liệu cảnh báo
- **Manager**: Người dùng có vai trò quản lý, có quyền xem inventory monitor
- **Active Item**: Nguyên liệu đang được sử dụng (Status = 'Active')
- **Stock Threshold**: Ngưỡng số lượng để xác định mức cảnh báo

## Requirements

### Requirement 1: Hiển thị Dashboard với 4 Mức Cảnh báo

**User Story:** Là một Manager, tôi muốn xem dashboard hiển thị tất cả nguyên liệu với mã màu theo 4 mức cảnh báo, để tôi có thể nhanh chóng nhận biết nguyên liệu nào cần chú ý.

#### Acceptance Criteria

1. WHEN Manager truy cập trang Inventory Monitor, THE Inventory Monitor System SHALL hiển thị danh sách tất cả nguyên liệu Active với mức cảnh báo tương ứng
2. THE Inventory Monitor System SHALL hiển thị 4 mức cảnh báo với màu sắc:
   - OK (Xanh lá): Quantity > 50
   - LOW (Vàng): 11 ≤ Quantity ≤ 50
   - CRITICAL (Đỏ): 1 ≤ Quantity ≤ 10
   - INACTIVE (Xám): Status = 'Inactive'
3. THE Inventory Monitor System SHALL hiển thị thông tin cho mỗi nguyên liệu: ItemName, Quantity, Unit, WarningLevel, LastUpdated
4. THE Inventory Monitor System SHALL sắp xếp nguyên liệu theo mức độ ưu tiên (CRITICAL trước, sau đó LOW, OK, INACTIVE)
5. THE Inventory Monitor System SHALL lấy dữ liệu từ InventoryMonitor view trong database

### Requirement 2: Lọc theo Mức Cảnh báo

**User Story:** Là một Manager, tôi muốn lọc nguyên liệu theo mức cảnh báo cụ thể, để tôi có thể tập trung vào các nguyên liệu cần xử lý ngay.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL cung cấp bộ lọc với 5 tùy chọn: All, OK, LOW, CRITICAL, INACTIVE
2. WHEN Manager chọn một mức cảnh báo, THE Inventory Monitor System SHALL hiển thị chỉ các nguyên liệu thuộc mức đó
3. THE Inventory Monitor System SHALL hiển thị số lượng nguyên liệu cho mỗi mức cảnh báo
4. WHEN Manager chọn "All", THE Inventory Monitor System SHALL hiển thị tất cả nguyên liệu
5. THE Inventory Monitor System SHALL giữ trạng thái bộ lọc được chọn khi trang được refresh

### Requirement 3: Tìm kiếm Nguyên liệu

**User Story:** Là một Manager, tôi muốn tìm kiếm nguyên liệu theo tên, để tôi có thể nhanh chóng kiểm tra trạng thái của một nguyên liệu cụ thể.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL cung cấp ô tìm kiếm cho phép nhập tên nguyên liệu
2. WHEN Manager nhập từ khóa tìm kiếm, THE Inventory Monitor System SHALL hiển thị các nguyên liệu có tên chứa từ khóa đó (không phân biệt hoa thường)
3. THE Inventory Monitor System SHALL cập nhật kết quả tìm kiếm trong thời gian thực khi Manager gõ
4. THE Inventory Monitor System SHALL hiển thị thông báo khi không tìm thấy kết quả phù hợp
5. THE Inventory Monitor System SHALL cho phép kết hợp tìm kiếm với bộ lọc mức cảnh báo

### Requirement 4: Hiển thị Thống kê Tổng quan

**User Story:** Là một Manager, tôi muốn xem thống kê tổng quan về số lượng nguyên liệu ở mỗi mức cảnh báo, để tôi có thể đánh giá tình hình tồn kho tổng thể.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL hiển thị 4 thẻ thống kê (cards) cho mỗi mức cảnh báo
2. THE Inventory Monitor System SHALL hiển thị số lượng nguyên liệu ở mỗi mức trên thẻ tương ứng
3. THE Inventory Monitor System SHALL sử dụng màu sắc tương ứng với mỗi mức cảnh báo cho các thẻ
4. WHEN Manager click vào một thẻ thống kê, THE Inventory Monitor System SHALL lọc danh sách theo mức cảnh báo đó
5. THE Inventory Monitor System SHALL làm nổi bật thẻ CRITICAL nếu có nguyên liệu ở mức này

### Requirement 5: Kiểm soát Truy cập và Bảo mật

**User Story:** Là một Manager, tôi muốn chỉ người dùng có quyền Manager mới có thể truy cập Inventory Monitor, để đảm bảo thông tin tồn kho được bảo mật.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL yêu cầu người dùng đăng nhập với vai trò Manager
2. WHEN người dùng không có vai trò Manager cố gắng truy cập, THE Inventory Monitor System SHALL chuyển hướng đến trang lỗi hoặc trang chủ
3. THE Inventory Monitor System SHALL chỉ cho phép xem dữ liệu, không cho phép chỉnh sửa hoặc xóa
4. THE Inventory Monitor System SHALL ghi log mỗi lần Manager truy cập trang
5. THE Inventory Monitor System SHALL tự động đăng xuất sau 30 phút không hoạt động

### Requirement 6: Giao diện Responsive và Thân thiện

**User Story:** Là một Manager, tôi muốn giao diện Inventory Monitor hoạt động tốt trên cả desktop và mobile, để tôi có thể kiểm tra tồn kho mọi lúc mọi nơi.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL hiển thị đúng trên các kích thước màn hình: desktop (≥1024px), tablet (768-1023px), mobile (<768px)
2. THE Inventory Monitor System SHALL sử dụng sidebar có thể thu gọn trên màn hình nhỏ
3. THE Inventory Monitor System SHALL hiển thị dữ liệu dạng bảng trên desktop và dạng card trên mobile
4. THE Inventory Monitor System SHALL đảm bảo các nút và liên kết đủ lớn để dễ click trên thiết bị cảm ứng (tối thiểu 44x44px)
5. THE Inventory Monitor System SHALL tải trang trong thời gian dưới 2 giây với kết nối internet trung bình

### Requirement 7: Cập nhật Dữ liệu Thời gian Thực

**User Story:** Là một Manager, tôi muốn dữ liệu inventory được cập nhật tự động, để tôi luôn thấy thông tin mới nhất mà không cần refresh trang thủ công.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL hiển thị thời gian cập nhật cuối cùng (LastUpdated) cho mỗi nguyên liệu
2. THE Inventory Monitor System SHALL cung cấp nút "Refresh" để Manager có thể cập nhật dữ liệu thủ công
3. WHEN Manager click nút Refresh, THE Inventory Monitor System SHALL tải lại dữ liệu từ database và cập nhật giao diện
4. THE Inventory Monitor System SHALL hiển thị loading indicator trong khi đang tải dữ liệu
5. THE Inventory Monitor System SHALL hiển thị thông báo lỗi nếu không thể tải dữ liệu từ server

### Requirement 8: Xuất Báo cáo

**User Story:** Là một Manager, tôi muốn xuất danh sách inventory monitor ra file, để tôi có thể lưu trữ hoặc chia sẻ với người khác.

#### Acceptance Criteria

1. THE Inventory Monitor System SHALL cung cấp nút "Export" để xuất dữ liệu
2. THE Inventory Monitor System SHALL hỗ trợ xuất ra định dạng CSV
3. WHEN Manager click Export, THE Inventory Monitor System SHALL tạo file chứa tất cả nguyên liệu đang hiển thị (sau khi lọc/tìm kiếm)
4. THE Inventory Monitor System SHALL bao gồm các cột: ItemName, Quantity, Unit, WarningLevel, LastUpdated trong file xuất
5. THE Inventory Monitor System SHALL đặt tên file theo định dạng: inventory_monitor_YYYYMMDD_HHMMSS.csv
