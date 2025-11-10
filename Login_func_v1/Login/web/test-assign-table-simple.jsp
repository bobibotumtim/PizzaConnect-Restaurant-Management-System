<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.TableDAO" %>
<%@ page import="models.Table" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Assign Table</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
            background: #f5f5f5;
        }
        .table-card {
            background: white;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .status-available { border-left: 5px solid #10b981; }
        .status-occupied { border-left: 5px solid #f59e0b; }
        .status-unavailable { border-left: 5px solid #ef4444; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mb-4">🧪 Test Assign Table Page</h1>
        
        <%
            try {
                TableDAO tableDAO = new TableDAO();
                List<Table> tables = tableDAO.getActiveTablesWithStatus();
                
                out.println("<div class='alert alert-info'>");
                out.println("<strong>📊 Statistics:</strong><br>");
                out.println("Total tables loaded: <strong>" + (tables != null ? tables.size() : "null") + "</strong>");
                out.println("</div>");
                
                if (tables != null && !tables.isEmpty()) {
                    int available = 0, occupied = 0, unavailable = 0;
                    
                    for (Table t : tables) {
                        String status = t.getStatus();
                        if ("available".equals(status)) available++;
                        else if ("occupied".equals(status)) occupied++;
                        else unavailable++;
                    }
                    
                    out.println("<div class='row mb-4'>");
                    out.println("<div class='col-md-4'>");
                    out.println("<div class='card text-center'>");
                    out.println("<div class='card-body'>");
                    out.println("<h3 class='text-success'>" + available + "</h3>");
                    out.println("<p>Bàn Trống</p>");
                    out.println("</div></div></div>");
                    
                    out.println("<div class='col-md-4'>");
                    out.println("<div class='card text-center'>");
                    out.println("<div class='card-body'>");
                    out.println("<h3 class='text-warning'>" + occupied + "</h3>");
                    out.println("<p>Đang Phục Vụ</p>");
                    out.println("</div></div></div>");
                    
                    out.println("<div class='col-md-4'>");
                    out.println("<div class='card text-center'>");
                    out.println("<div class='card-body'>");
                    out.println("<h3 class='text-danger'>" + unavailable + "</h3>");
                    out.println("<p>Không KD</p>");
                    out.println("</div></div></div>");
                    out.println("</div>");
                    
                    out.println("<h3>📋 Danh Sách Bàn:</h3>");
                    
                    for (Table t : tables) {
                        String statusClass = "status-" + t.getStatus();
                        out.println("<div class='table-card " + statusClass + "'>");
                        out.println("<div class='row align-items-center'>");
                        out.println("<div class='col-md-3'>");
                        out.println("<h4>🪑 " + t.getTableNumber() + "</h4>");
                        out.println("</div>");
                        out.println("<div class='col-md-3'>");
                        out.println("<span class='badge bg-secondary'>Sức chứa: " + t.getCapacity() + " người</span>");
                        out.println("</div>");
                        out.println("<div class='col-md-3'>");
                        
                        String badgeClass = "";
                        String statusText = "";
                        if ("available".equals(t.getStatus())) {
                            badgeClass = "bg-success";
                            statusText = "Trống";
                        } else if ("occupied".equals(t.getStatus())) {
                            badgeClass = "bg-warning";
                            statusText = "Đang Dùng";
                        } else {
                            badgeClass = "bg-danger";
                            statusText = "Không KD";
                        }
                        
                        out.println("<span class='badge " + badgeClass + "'>" + statusText + "</span>");
                        out.println("</div>");
                        out.println("<div class='col-md-3'>");
                        out.println("<small class='text-muted'>ID: " + t.getTableID() + "</small>");
                        out.println("</div>");
                        out.println("</div>");
                        out.println("</div>");
                    }
                } else {
                    out.println("<div class='alert alert-danger'>");
                    out.println("<h4>❌ Không tìm thấy bàn nào!</h4>");
                    out.println("<p><strong>Nguyên nhân có thể:</strong></p>");
                    out.println("<ol>");
                    out.println("<li>Database chưa được khởi tạo</li>");
                    out.println("<li>Script SQL chưa được chạy</li>");
                    out.println("<li>Lỗi kết nối database</li>");
                    out.println("<li>Bảng [Table] chưa có dữ liệu</li>");
                    out.println("</ol>");
                    out.println("<p><strong>Giải pháp:</strong></p>");
                    out.println("<ol>");
                    out.println("<li>Mở SQL Server Management Studio</li>");
                    out.println("<li>Chạy file <code>ScriptForHieuV5.sql</code></li>");
                    out.println("<li>Hoặc chạy file <code>insert_test_tables.sql</code></li>");
                    out.println("<li>Refresh lại trang này</li>");
                    out.println("</ol>");
                    out.println("</div>");
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>");
                out.println("<h4>💥 Lỗi khi tải dữ liệu:</h4>");
                out.println("<pre>" + e.getMessage() + "</pre>");
                out.println("<p><strong>Stack trace:</strong></p>");
                out.println("<pre>");
                e.printStackTrace(new java.io.PrintWriter(out));
                out.println("</pre>");
                out.println("</div>");
            }
        %>
        
        <hr>
        <div class="mt-4">
            <a href="assign-table" class="btn btn-primary">🔗 Đi đến trang Assign Table chính thức</a>
            <a href="test-tables.jsp" class="btn btn-secondary">🔍 Test TableDAO</a>
            <button onclick="location.reload()" class="btn btn-info">🔄 Refresh</button>
        </div>
    </div>
</body>
</html>
