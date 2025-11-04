# Requirements Document

## Introduction

Tạo tính năng báo cáo bán hàng cho hệ thống quản lý nhà hàng pizza, cho phép tạo và xuất các báo cáo doanh thu theo nhiều tiêu chí khác nhau.

## Glossary

- **Sales_Report_System**: Hệ thống tạo báo cáo bán hàng
- **Report_Dashboard**: Giao diện hiển thị thống kê và báo cáo
- **Export_Function**: Chức năng xuất báo cáo ra file
- **Date_Filter**: Bộ lọc theo khoảng thời gian
- **Branch_Filter**: Bộ lọc theo chi nhánh

## Requirements

### Requirement 1

**User Story:** Là một quản lý, tôi muốn xem tổng quan doanh thu qua dashboard, để nắm bắt tình hình kinh doanh tổng thể.

#### Acceptance Criteria

1. THE Sales_Report_System SHALL hiển thị tổng doanh thu trong khoảng thời gian được chọn
2. THE Sales_Report_System SHALL hiển thị tổng số đơn hàng và khách hàng
3. THE Sales_Report_System SHALL hiển thị giá trị đơn hàng trung bình
4. THE Sales_Report_System SHALL hiển thị tỷ lệ tăng trưởng so với kỳ trước
5. THE Sales_Report_System SHALL hiển thị top 5 sản phẩm bán chạy nhất

### Requirement 2

**User Story:** Là một quản lý, tôi muốn lọc báo cáo theo thời gian và chi nhánh, để phân tích dữ liệu cụ thể.

#### Acceptance Criteria

1. WHEN chọn loại báo cáo, THE Sales_Report_System SHALL cập nhật khoảng thời gian tương ứng
2. WHEN chọn khoảng thời gian, THE Sales_Report_System SHALL hiển thị dữ liệu trong khoảng đó
3. WHEN chọn chi nhánh, THE Sales_Report_System SHALL lọc dữ liệu theo chi nhánh được chọn
4. THE Sales_Report_System SHALL hỗ trợ các loại báo cáo: ngày, tuần, tháng, quý, năm
5. THE Sales_Report_System SHALL cho phép chọn khoảng thời gian tùy chỉnh

### Requirement 3

**User Story:** Là một quản lý, tôi muốn xuất báo cáo ra file, để lưu trữ và chia sẻ với các bên liên quan.

#### Acceptance Criteria

1. WHEN click nút "Tạo Báo Cáo", THE Sales_Report_System SHALL tạo báo cáo theo cấu hình đã chọn
2. WHEN click nút "Xuất Dữ Liệu", THE Sales_Report_System SHALL xuất dữ liệu ra file Excel
3. THE Sales_Report_System SHALL hỗ trợ xuất định dạng PDF và Excel
4. THE Sales_Report_System SHALL bao gồm tất cả thông tin thống kê trong file xuất
5. THE Sales_Report_System SHALL đặt tên file theo định dạng có ý nghĩa

### Requirement 4

**User Story:** Là một quản lý, tôi muốn xem biểu đồ doanh thu theo thời gian, để theo dõi xu hướng kinh doanh.

#### Acceptance Criteria

1. THE Sales_Report_System SHALL hiển thị biểu đồ doanh thu theo ngày
2. THE Sales_Report_System SHALL hiển thị số lượng đơn hàng tương ứng với mỗi ngày
3. THE Sales_Report_System SHALL sử dụng màu sắc phù hợp với theme của ứng dụng
4. THE Sales_Report_System SHALL hiển thị tooltip khi hover vào biểu đồ
5. THE Sales_Report_System SHALL cập nhật biểu đồ khi thay đổi bộ lọc
