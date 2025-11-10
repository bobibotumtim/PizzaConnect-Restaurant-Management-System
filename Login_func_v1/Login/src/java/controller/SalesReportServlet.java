package controller;

import dao.SalesReportDAO;
import models.SalesReportData;
import models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@WebServlet(urlPatterns = {"/sales-reports", "/salesreports"})
public class SalesReportServlet extends HttpServlet {
    
    private final SalesReportDAO salesReportDAO = new SalesReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication - Allow Admin (role=1) and Manager (role=2 with jobRole=Manager)
        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
            return;
        }
        
        // Check if user is Admin or Manager
        boolean isAuthorized = false;
        if (currentUser.getRole() == 1) {
            // Admin has access
            isAuthorized = true;
        } else if (currentUser.getRole() == 2) {
            // Check if Employee is Manager
            models.Employee employee = (models.Employee) request.getSession().getAttribute("employee");
            if (employee != null && "Manager".equalsIgnoreCase(employee.getJobRole())) {
                isAuthorized = true;
            }
        }
        
        if (!isAuthorized) {
            response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
            return;
        }
        
        // Get parameters
        String reportType = request.getParameter("reportType");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String branch = request.getParameter("branch");
        String action = request.getParameter("action");
        
        // Set defaults if parameters are null
        if (reportType == null) reportType = "daily";
        if (branch == null) branch = "all";
        
        // Set default date range based on report type
        LocalDate today = LocalDate.now();
        if (dateFrom == null || dateTo == null) {
            switch (reportType) {
                case "daily":
                    dateFrom = today.minusDays(6).toString(); // Last 7 days
                    dateTo = today.toString();
                    break;
                case "weekly":
                    dateFrom = today.minusWeeks(4).toString(); // Last 4 weeks
                    dateTo = today.toString();
                    break;
                case "monthly":
                    dateFrom = today.minusMonths(3).toString(); // Last 3 months
                    dateTo = today.toString();
                    break;
                case "quarterly":
                    dateFrom = today.minusMonths(12).toString(); // Last year
                    dateTo = today.toString();
                    break;
                case "yearly":
                    dateFrom = today.minusYears(2).toString(); // Last 2 years
                    dateTo = today.toString();
                    break;
                default: // custom
                    if (dateFrom == null) dateFrom = today.minusDays(30).toString();
                    if (dateTo == null) dateTo = today.toString();
                    break;
            }
        }
        
        try {
            // Validate date range
            if (!isValidDateRange(dateFrom, dateTo)) {
                request.setAttribute("error", "Invalid date range. Please check your dates.");
                setDefaultAttributes(request, reportType, dateFrom, dateTo, branch);
                request.getRequestDispatcher("view/GenerateSalesReports.jsp").forward(request, response);
                return;
            }
            
            // Get sales report data from database - only when explicitly requested
            SalesReportData reportData = null;
            if ("generate".equals(action)) {
                try {
                    reportData = salesReportDAO.getSalesReportData(dateFrom, dateTo, branch);
                    if (reportData != null) {
                        request.setAttribute("message", "Báo cáo đã được tạo thành công!");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("error", "Lỗi khi lấy dữ liệu từ database: " + e.getMessage());
                    // Set empty report data to avoid null pointer exceptions
                    reportData = new SalesReportData();
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportType", reportType);
            request.setAttribute("dateFrom", dateFrom);
            request.setAttribute("dateTo", dateTo);
            request.setAttribute("branch", branch);
            
            // Format dates for display
            if (dateFrom != null && dateTo != null && !"".equals(dateFrom) && !"".equals(dateTo)) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                LocalDate fromDate = LocalDate.parse(dateFrom);
                LocalDate toDate = LocalDate.parse(dateTo);
                request.setAttribute("dateFromFormatted", fromDate.format(formatter));
                request.setAttribute("dateToFormatted", toDate.format(formatter));
                
                // Calculate date range in days
                long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(fromDate, toDate) + 1;
                request.setAttribute("daysBetween", daysBetween);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error generating report: " + e.getMessage());
            setDefaultAttributes(request, reportType, dateFrom, dateTo, branch);
        }
        
        // Forward to JSP
        request.getRequestDispatcher("view/GenerateSalesReports.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("generate".equals(action)) {
            // Handle report generation - redirect to GET with parameters
            String reportType = request.getParameter("reportType");
            String dateFrom = request.getParameter("dateFrom");
            String dateTo = request.getParameter("dateTo");
            String branch = request.getParameter("branch");
            
            StringBuilder redirectUrl = new StringBuilder("sales-reports?action=generate");
            if (reportType != null) redirectUrl.append("&reportType=").append(reportType);
            if (dateFrom != null) redirectUrl.append("&dateFrom=").append(dateFrom);
            if (dateTo != null) redirectUrl.append("&dateTo=").append(dateTo);
            if (branch != null) redirectUrl.append("&branch=").append(branch);
            
            response.sendRedirect(redirectUrl.toString());
            
        } else if ("export".equals(action)) {
            // Handle export functionality
            handleExport(request, response);
        } else {
            // Default to GET behavior
            doGet(request, response);
        }
    }
    
    /**
     * Handle export functionality with real data
     */
    private void handleExport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String format = request.getParameter("format");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String branch = request.getParameter("branch");
        
        // Set defaults if parameters are null
        if (format == null) format = "csv";
        if (dateFrom == null) dateFrom = "2025-11-03";
        if (dateTo == null) dateTo = "2025-11-03";
        if (branch == null) branch = "all";
        
        // Debug logging
        System.out.println("Export request - Format: " + format + ", DateFrom: " + dateFrom + ", DateTo: " + dateTo + ", Branch: " + branch);
        
        try {
            // Get real data from database
            SalesReportData reportData = salesReportDAO.getSalesReportData(dateFrom, dateTo, branch);
            System.out.println("Retrieved report data: " + reportData);
            
            if ("pdf".equals(format)) {
                exportToPDF(response, reportData, dateFrom, dateTo, branch);
            } else if ("excel".equals(format)) {
                exportToExcel(response, reportData, dateFrom, dateTo, branch);
            } else if ("csv".equals(format)) {
                exportToCSV(response, reportData, dateFrom, dateTo, branch);
            } else {
                // Default to showing data on page
                request.setAttribute("message", "Export format not supported yet. Showing data on page.");
                doGet(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error exporting report: " + e.getMessage());
            doGet(request, response);
        }
    }
    
    /**
     * Export to PDF (HTML format for printing)
     */
    private void exportToPDF(HttpServletResponse response, SalesReportData reportData, 
                           String dateFrom, String dateTo, String branch) throws IOException {
        try {
            StringBuilder html = new StringBuilder();
            
            html.append("<!DOCTYPE html>");
            html.append("<html lang='vi'>");
            html.append("<head>");
            html.append("<meta charset='UTF-8'>");
            html.append("<title>Báo Cáo Bán Hàng - PizzaConnect</title>");
            html.append("<style>");
            html.append("body { font-family: Arial, sans-serif; margin: 20px; }");
            html.append("h1 { color: #f97316; text-align: center; }");
            html.append("h2 { color: #333; border-bottom: 2px solid #f97316; padding-bottom: 10px; }");
            html.append("table { width: 100%; border-collapse: collapse; margin: 20px 0; }");
            html.append("th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }");
            html.append("th { background-color: #f97316; color: white; }");
            html.append("tr:nth-child(even) { background-color: #f9f9f9; }");
            html.append(".summary { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0; }");
            html.append(".currency { text-align: right; font-weight: bold; color: #10b981; }");
            html.append("@media print { body { margin: 0; } }");
            html.append("</style>");
            html.append("</head>");
            html.append("<body>");
            
            // Header
            html.append("<h1>BÁO CÁO BÁN HÀNG</h1>");
            html.append("<h2>PIZZA CONNECT RESTAURANT</h2>");
            html.append("<div class='summary'>");
            html.append("<p><strong>Khoảng thời gian:</strong> ").append(dateFrom).append(" đến ").append(dateTo).append("</p>");
            html.append("<p><strong>Chi nhánh:</strong> ").append(getBranchName(branch)).append("</p>");
            html.append("<p><strong>Ngày tạo báo cáo:</strong> ").append(new java.util.Date()).append("</p>");
            html.append("</div>");
            
            // Summary Statistics
            html.append("<h2>TỔNG QUAN</h2>");
            html.append("<table>");
            html.append("<tr><th>Chỉ Số</th><th>Giá Trị</th></tr>");
            
            if (reportData != null) {
                html.append("<tr><td>Tổng Doanh Thu</td><td class='currency'>")
                    .append(String.format("%,.0f ₫", reportData.getTotalRevenue())).append("</td></tr>");
                html.append("<tr><td>Tổng Đơn Hàng</td><td>").append(reportData.getTotalOrders()).append("</td></tr>");
                html.append("<tr><td>Tổng Khách Hàng</td><td>").append(reportData.getTotalCustomers()).append("</td></tr>");
                html.append("<tr><td>Giá Trị Trung Bình</td><td class='currency'>")
                    .append(String.format("%,.0f ₫", reportData.getAvgOrderValue())).append("</td></tr>");
                html.append("<tr><td>Tỷ Lệ Tăng Trưởng</td><td>")
                    .append(String.format("%.1f%%", reportData.getGrowthRate())).append("</td></tr>");
            } else {
                html.append("<tr><td colspan='2'>Không có dữ liệu trong khoảng thời gian này</td></tr>");
            }
            html.append("</table>");
            
            // Top Products
            html.append("<h2>TOP 5 SẢN PHẨM BÁN CHẠY</h2>");
            html.append("<table>");
            html.append("<tr><th>Hạng</th><th>Tên Sản Phẩm</th><th>Số Lượng</th><th>Doanh Thu</th></tr>");
            
            if (reportData != null && reportData.getTopProducts() != null) {
                int rank = 1;
                for (models.TopProduct product : reportData.getTopProducts()) {
                    html.append("<tr>");
                    html.append("<td>").append(rank++).append("</td>");
                    html.append("<td>").append(product.getProductName()).append("</td>");
                    html.append("<td>").append(product.getQuantity()).append("</td>");
                    html.append("<td class='currency'>").append(String.format("%,.0f ₫", product.getRevenue())).append("</td>");
                    html.append("</tr>");
                }
            } else {
                html.append("<tr><td colspan='4'>Không có dữ liệu sản phẩm</td></tr>");
            }
            html.append("</table>");
            
            // Daily Revenue
            html.append("<h2>DOANH THU THEO NGÀY</h2>");
            html.append("<table>");
            html.append("<tr><th>Ngày</th><th>Doanh Thu</th><th>Số Đơn Hàng</th></tr>");
            
            if (reportData != null && reportData.getDailyRevenue() != null) {
                for (models.DailyRevenue daily : reportData.getDailyRevenue()) {
                    html.append("<tr>");
                    html.append("<td>").append(daily.getDate()).append("</td>");
                    html.append("<td class='currency'>").append(String.format("%,.0f ₫", daily.getRevenue())).append("</td>");
                    html.append("<td>").append(daily.getOrders()).append("</td>");
                    html.append("</tr>");
                }
            } else {
                html.append("<tr><td colspan='3'>Không có dữ liệu doanh thu</td></tr>");
            }
            html.append("</table>");
            
            // Footer
            html.append("<div style='margin-top: 50px; text-align: center; font-size: 12px; color: #666;'>");
            html.append("<p>© 2024 PizzaConnect Restaurant Management System</p>");
            html.append("<p>Báo cáo được tạo tự động bởi hệ thống</p>");
            html.append("</div>");
            
            html.append("</body>");
            html.append("</html>");
            
            // Set response headers for HTML download (can be printed to PDF by browser)
            response.setContentType("text/html; charset=UTF-8");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"SalesReport_" + dateFrom + "_" + dateTo + ".html\"");
            
            // Write HTML content
            response.getWriter().write(html.toString());
            response.getWriter().flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Error generating PDF: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Export to Excel (Simple CSV format)
     */
    private void exportToExcel(HttpServletResponse response, SalesReportData reportData,
                             String dateFrom, String dateTo, String branch) throws IOException {
        try {
            StringBuilder csv = new StringBuilder();
            
            // Header
            csv.append("SALES REPORT - PIZZA CONNECT\n");
            csv.append("Period:,").append(dateFrom).append(" to ").append(dateTo).append("\n");
            csv.append("Branch:,").append(getBranchName(branch)).append("\n");
            csv.append("\n");
            
            // Summary Statistics
            csv.append("SUMMARY STATISTICS\n");
            csv.append("Metric,Value\n");
            csv.append("Total Revenue,").append(reportData.getTotalRevenue()).append("\n");
            csv.append("Total Orders,").append(reportData.getTotalOrders()).append("\n");
            csv.append("Total Customers,").append(reportData.getTotalCustomers()).append("\n");
            csv.append("Average Order Value,").append(reportData.getAvgOrderValue()).append("\n");
            csv.append("Growth Rate (%),").append(reportData.getGrowthRate()).append("\n");
            csv.append("\n");
            
            // Top Products
            csv.append("TOP PRODUCTS\n");
            csv.append("Rank,Product Name,Quantity,Revenue\n");
            if (reportData.getTopProducts() != null) {
                int rank = 1;
                for (models.TopProduct product : reportData.getTopProducts()) {
                    csv.append(rank++).append(",")
                       .append("\"").append(product.getProductName()).append("\",")
                       .append(product.getQuantity()).append(",")
                       .append(product.getRevenue()).append("\n");
                }
            }
            csv.append("\n");
            
            // Daily Revenue
            csv.append("DAILY REVENUE\n");
            csv.append("Date,Revenue,Orders\n");
            if (reportData != null && reportData.getDailyRevenue() != null) {
                for (models.DailyRevenue daily : reportData.getDailyRevenue()) {
                    csv.append("\"").append(daily.getDate()).append("\",")
                       .append(daily.getRevenue()).append(",")
                       .append(daily.getOrders()).append("\n");
                }
            }
            
            // Set response headers for Excel-compatible CSV download
            response.setContentType("application/vnd.ms-excel; charset=UTF-8");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"SalesReport_" + dateFrom + "_" + dateTo + ".csv\"");
            
            // Write CSV data
            response.getWriter().write(csv.toString());
            response.getWriter().flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Error generating Excel: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Export to CSV with real data
     */
    private void exportToCSV(HttpServletResponse response, SalesReportData reportData,
                           String dateFrom, String dateTo, String branch) throws IOException {
        try {
            StringBuilder csv = new StringBuilder();
            
            // Header
            csv.append("SALES REPORT - PIZZA CONNECT\n");
            csv.append("Period:,").append(dateFrom).append(" to ").append(dateTo).append("\n");
            csv.append("Branch:,").append(getBranchName(branch)).append("\n");
            csv.append("\n");
            
            // Summary Statistics
            csv.append("SUMMARY STATISTICS\n");
            csv.append("Metric,Value\n");
            csv.append("Total Revenue,").append(reportData.getTotalRevenue()).append("\n");
            csv.append("Total Orders,").append(reportData.getTotalOrders()).append("\n");
            csv.append("Total Customers,").append(reportData.getTotalCustomers()).append("\n");
            csv.append("Average Order Value,").append(reportData.getAvgOrderValue()).append("\n");
            csv.append("Growth Rate (%),").append(reportData.getGrowthRate()).append("\n");
            csv.append("\n");
            
            // Top Products
            csv.append("TOP PRODUCTS\n");
            csv.append("Rank,Product Name,Quantity,Revenue\n");
            if (reportData.getTopProducts() != null) {
                int rank = 1;
                for (models.TopProduct product : reportData.getTopProducts()) {
                    csv.append(rank++).append(",")
                       .append("\"").append(product.getProductName()).append("\",")
                       .append(product.getQuantity()).append(",")
                       .append(product.getRevenue()).append("\n");
                }
            }
            csv.append("\n");
            
            // Daily Revenue
            csv.append("DAILY REVENUE\n");
            csv.append("Date,Revenue,Orders\n");
            if (reportData.getDailyRevenue() != null) {
                for (models.DailyRevenue daily : reportData.getDailyRevenue()) {
                    csv.append("\"").append(daily.getDate()).append("\",")
                       .append(daily.getRevenue()).append(",")
                       .append(daily.getOrders()).append("\n");
                }
            }
            
            // Set response headers for CSV download
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"SalesReport_" + dateFrom + "_" + dateTo + ".csv\"");
            
            // Write CSV data
            response.getWriter().write(csv.toString());
            response.getWriter().flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Error generating CSV: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Validate date range
     */
    private boolean isValidDateRange(String dateFrom, String dateTo) {
        try {
            LocalDate fromDate = LocalDate.parse(dateFrom);
            LocalDate toDate = LocalDate.parse(dateTo);
            
            // Check if from date is not after to date
            if (fromDate.isAfter(toDate)) {
                return false;
            }
            
            // Check if date range is not more than 1 year
            long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(fromDate, toDate);
            if (daysBetween > 365) {
                return false;
            }
            
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Set default attributes for JSP
     */
    private void setDefaultAttributes(HttpServletRequest request, String reportType, 
                                    String dateFrom, String dateTo, String branch) {
        request.setAttribute("reportType", reportType);
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("branch", branch);
        
        // Set empty report data to avoid null pointer exceptions
        SalesReportData emptyData = new SalesReportData();
        request.setAttribute("reportData", emptyData);
    }
    
    /**
     * Create sample report data for testing export
     */
    private SalesReportData createSampleReportData() {
        SalesReportData data = new SalesReportData();
        data.setTotalRevenue(45250000);
        data.setTotalOrders(324);
        data.setTotalCustomers(278);
        data.setAvgOrderValue(139660);
        data.setGrowthRate(12.5);
        
        // Create sample top products
        java.util.List<models.TopProduct> topProducts = new java.util.ArrayList<>();
        topProducts.add(new models.TopProduct("Pizza Hải Sản Deluxe", 89, 8900000));
        topProducts.add(new models.TopProduct("Pizza Pepperoni", 76, 6840000));
        topProducts.add(new models.TopProduct("Pizza Phô Mai Siêu Dày", 65, 7150000));
        topProducts.add(new models.TopProduct("Pizza Gà BBQ", 54, 5940000));
        topProducts.add(new models.TopProduct("Pizza Bò Beefsteak", 48, 6240000));
        data.setTopProducts(topProducts);
        
        // Create sample daily revenue
        java.util.List<models.DailyRevenue> dailyRevenue = new java.util.ArrayList<>();
        dailyRevenue.add(new models.DailyRevenue("01/11", 12500000, 89));
        dailyRevenue.add(new models.DailyRevenue("02/11", 10800000, 76));
        dailyRevenue.add(new models.DailyRevenue("03/11", 11200000, 82));
        dailyRevenue.add(new models.DailyRevenue("04/11", 10750000, 77));
        data.setDailyRevenue(dailyRevenue);
        
        return data;
    }
    
    /**
     * Get branch name for display
     */
    private String getBranchName(String branch) {
        switch (branch) {
            case "all": return "All Branches";
            case "hcm1": return "Pizza Store Q1 - HCM";
            case "hcm2": return "Pizza Store Q3 - HCM";
            case "hn1": return "Pizza Store Hoan Kiem - HN";
            case "dn1": return "Pizza Store Hai Chau - DN";
            default: return "Unknown";
        }
    }
}