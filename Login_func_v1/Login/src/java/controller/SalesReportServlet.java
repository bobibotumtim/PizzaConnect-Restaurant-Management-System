package controller;

import dao.SalesReportDAO;
import models.SalesReportData;
import models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

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
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String branch = request.getParameter("branch");
        String action = request.getParameter("action");
        
        // Set defaults if parameters are null
        if (branch == null) branch = "all";
        
        // Set default date range (this week: Monday to Sunday)
        // Also handle invalid values like "--"
        LocalDate today = LocalDate.now();
        if (dateFrom == null || dateTo == null || dateFrom.isEmpty() || dateTo.isEmpty() 
            || "--".equals(dateFrom) || "--".equals(dateTo) || "null".equals(dateFrom) || "null".equals(dateTo)
            || "undefined".equals(dateFrom) || "undefined".equals(dateTo)) {
            // Calculate Monday of current week
            java.time.DayOfWeek dayOfWeek = today.getDayOfWeek();
            int daysToMonday = dayOfWeek.getValue() - 1; // Monday = 1, so subtract 1
            LocalDate monday = today.minusDays(daysToMonday);
            
            // Calculate Sunday of current week
            LocalDate sunday = monday.plusDays(6);
            
            dateFrom = monday.toString();
            dateTo = sunday.toString();
            System.out.println("Using default date range: " + dateFrom + " to " + dateTo);
        }
        
        try {
            // Handle export action
            if ("export".equals(action)) {
                handleExport(request, response);
                return;
            }
            
            // Validate date range
            if (!isValidDateRange(dateFrom, dateTo)) {
                request.setAttribute("error", "Invalid date range. Please check your dates.");
                request.setAttribute("dateFrom", dateFrom);
                request.setAttribute("dateTo", dateTo);
                request.setAttribute("branch", branch);
                request.getRequestDispatcher("view/GenerateSalesReports.jsp").forward(request, response);
                return;
            }
            
            // Get sales report data from database - only when explicitly requested
            SalesReportData reportData = null;
            if ("generate".equals(action)) {
                try {
                    System.out.println("Loading report data for dateFrom: " + dateFrom + ", dateTo: " + dateTo + ", branch: " + branch);
                    reportData = salesReportDAO.getSalesReportData(dateFrom, dateTo, branch);
                    if (reportData != null) {
                        System.out.println("Report data loaded successfully - Total Revenue: " + reportData.getTotalRevenue() + 
                                         ", Total Orders: " + reportData.getTotalOrders());
                        request.setAttribute("message", "Báo cáo đã được tạo thành công!");
                    } else {
                        System.out.println("Report data is null");
                        reportData = new SalesReportData(); // Create empty report data
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    System.err.println("Error loading report data: " + e.getMessage());
                    request.setAttribute("error", "Lỗi khi lấy dữ liệu từ database: " + e.getMessage());
                    // Set empty report data to avoid null pointer exceptions
                    reportData = new SalesReportData();
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("reportData", reportData);
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
            request.setAttribute("dateFrom", dateFrom);
            request.setAttribute("dateTo", dateTo);
            request.setAttribute("branch", branch);
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
            String dateFrom = request.getParameter("dateFrom");
            String dateTo = request.getParameter("dateTo");
            String branch = request.getParameter("branch");
            
            System.out.println("POST request received - dateFrom: " + dateFrom + ", dateTo: " + dateTo + ", branch: " + branch);
            
            StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/sales-reports?action=generate");
            if (dateFrom != null && !dateFrom.isEmpty()) {
                redirectUrl.append("&dateFrom=").append(java.net.URLEncoder.encode(dateFrom, "UTF-8"));
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                redirectUrl.append("&dateTo=").append(java.net.URLEncoder.encode(dateTo, "UTF-8"));
            }
            if (branch != null) {
                redirectUrl.append("&branch=").append(branch);
            }
            
            System.out.println("Redirecting to: " + redirectUrl.toString());
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
        
        // Single branch system
        String branch = "main";
        
        // Set defaults if parameters are null
        if (format == null) format = "pdf";
        
        // Validate that date parameters are provided - DO NOT set defaults
        if (dateFrom == null || dateFrom.isEmpty() || dateTo == null || dateTo.isEmpty()) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<html><body><script>alert('Please select a date range before exporting!'); window.close();</script></body></html>");
            return;
        }
        
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
            } else {
                // Default to PDF
                exportToPDF(response, reportData, dateFrom, dateTo, branch);
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
            html.append("<html lang='en'>");
            html.append("<head>");
            html.append("<meta charset='UTF-8'>");
            html.append("<title>Sales Report - PizzaConnect</title>");
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
            html.append("<h1>SALES REPORT</h1>");
            html.append("<h2>PIZZA CONNECT RESTAURANT</h2>");
            html.append("<div class='summary'>");
            html.append("<p><strong>Period:</strong> ").append(dateFrom).append(" to ").append(dateTo).append("</p>");
            html.append("<p><strong>Report generated:</strong> ").append(new java.text.SimpleDateFormat("EEE MMM dd HH:mm:ss zzz yyyy", java.util.Locale.ENGLISH).format(new java.util.Date())).append("</p>");
            html.append("</div>");
            
            // Summary Statistics
            html.append("<h2>SUMMARY</h2>");
            html.append("<table>");
            html.append("<tr><th>Metric</th><th>Value</th></tr>");
            
            if (reportData != null) {
                html.append("<tr><td>Total Revenue</td><td class='currency'>")
                    .append(String.format("%,.0f ₫", reportData.getTotalRevenue())).append("</td></tr>");
                html.append("<tr><td>Total Orders</td><td>").append(reportData.getTotalOrders()).append("</td></tr>");
                html.append("<tr><td>Total Customers</td><td>").append(reportData.getTotalCustomers()).append("</td></tr>");
                html.append("<tr><td>Average Order Value</td><td class='currency'>")
                    .append(String.format("%,.0f ₫", reportData.getAvgOrderValue())).append("</td></tr>");
                html.append("<tr><td>Growth Rate</td><td>")
                    .append(String.format("%.1f%%", reportData.getGrowthRate())).append("</td></tr>");
            } else {
                html.append("<tr><td colspan='2'>No data available for this period</td></tr>");
            }
            html.append("</table>");
            
            // Top Products
            html.append("<h2>TOP 5 BEST-SELLING PRODUCTS</h2>");
            html.append("<table>");
            html.append("<tr><th>Rank</th><th>Product Name</th><th>Quantity</th><th>Revenue</th></tr>");
            
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
                html.append("<tr><td colspan='4'>No product data available</td></tr>");
            }
            html.append("</table>");
            
            // Daily Revenue
            html.append("<h2>DAILY REVENUE</h2>");
            html.append("<table>");
            html.append("<tr><th>Date</th><th>Revenue</th><th>Number of Orders</th></tr>");
            
            if (reportData != null && reportData.getDailyRevenue() != null) {
                for (models.DailyRevenue daily : reportData.getDailyRevenue()) {
                    html.append("<tr>");
                    html.append("<td>").append(daily.getDate()).append("</td>");
                    html.append("<td class='currency'>").append(String.format("%,.0f ₫", daily.getRevenue())).append("</td>");
                    html.append("<td>").append(daily.getOrders()).append("</td>");
                    html.append("</tr>");
                }
            } else {
                html.append("<tr><td colspan='3'>No revenue data available</td></tr>");
            }
            html.append("</table>");
            
            // Footer
            html.append("<div style='margin-top: 50px; text-align: center; font-size: 12px; color: #666;'>");
            html.append("<p>© 2025 PizzaConnect Restaurant Management System</p>");
            html.append("<p>Report automatically generated by the system</p>");
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
            case "all": return "Tất Cả Chi Nhánh";
            case "main": return "Chi Nhánh Chính - PizzaConnect";
            case "hcm1": return "Pizza Store Q1 - HCM";
            case "hcm2": return "Pizza Store Q3 - HCM";
            case "hn1": return "Pizza Store Hoan Kiem - HN";
            case "dn1": return "Pizza Store Hai Chau - DN";
            default: return "Chi Nhánh Chính";
        }
    }
}