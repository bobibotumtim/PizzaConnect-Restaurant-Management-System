package utils;

import models.SalesReportData;
import models.TopProduct;
import models.DailyRevenue;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class PDFExportUtil {
    
    private static final NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    
    /**
     * Generate HTML content for PDF export
     * This can be converted to PDF using browser print or server-side PDF libraries
     */
    public static String generateHTMLReport(SalesReportData reportData, String dateFrom, String dateTo, String branch) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>");
        html.append("<html lang='vi'>");
        html.append("<head>");
        html.append("<meta charset='UTF-8'>");
        html.append("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        html.append("<title>Báo Cáo Bán Hàng - PizzaConnect</title>");
        html.append("<style>");
        html.append(getCSS());
        html.append("</style>");
        html.append("</head>");
        html.append("<body>");
        
        // Header
        html.append("<div class='header'>");
        html.append("<h1>BÁO CÁO BÁN HÀNG</h1>");
        html.append("<h2>PIZZA CONNECT RESTAURANT</h2>");
        html.append("<div class='report-info'>");
        html.append("<p><strong>Khoảng thời gian:</strong> ").append(dateFrom).append(" đến ").append(dateTo).append("</p>");
        html.append("<p><strong>Chi nhánh:</strong> ").append(getBranchName(branch)).append("</p>");
        html.append("<p><strong>Ngày tạo báo cáo:</strong> ").append(dateFormat.format(new Date())).append("</p>");
        html.append("</div>");
        html.append("</div>");
        
        // Summary Statistics
        html.append("<div class='section'>");
        html.append("<h3>TỔNG QUAN</h3>");
        html.append("<div class='stats-grid'>");
        
        html.append("<div class='stat-card'>");
        html.append("<div class='stat-label'>Tổng Doanh Thu</div>");
        html.append("<div class='stat-value revenue'>").append(currencyFormat.format(reportData.getTotalRevenue())).append("</div>");
        html.append("</div>");
        
        html.append("<div class='stat-card'>");
        html.append("<div class='stat-label'>Tổng Đơn Hàng</div>");
        html.append("<div class='stat-value orders'>").append(reportData.getTotalOrders()).append("</div>");
        html.append("</div>");
        
        html.append("<div class='stat-card'>");
        html.append("<div class='stat-label'>Tổng Khách Hàng</div>");
        html.append("<div class='stat-value customers'>").append(reportData.getTotalCustomers()).append("</div>");
        html.append("</div>");
        
        html.append("<div class='stat-card'>");
        html.append("<div class='stat-label'>Giá Trị Trung Bình</div>");
        html.append("<div class='stat-value avg'>").append(currencyFormat.format(reportData.getAvgOrderValue())).append("</div>");
        html.append("</div>");
        
        html.append("</div>"); // stats-grid
        
        html.append("<div class='growth-section'>");
        html.append("<p><strong>Tỷ lệ tăng trưởng:</strong> ");
        String growthClass = reportData.getGrowthRate() >= 0 ? "positive" : "negative";
        html.append("<span class='growth ").append(growthClass).append("'>");
        html.append(String.format("%+.1f%%", reportData.getGrowthRate()));
        html.append("</span></p>");
        html.append("</div>");
        
        html.append("</div>"); // section
        
        // Top Products
        html.append("<div class='section'>");
        html.append("<h3>TOP 5 SẢN PHẨM BÁN CHẠY</h3>");
        html.append("<table class='data-table'>");
        html.append("<thead>");
        html.append("<tr>");
        html.append("<th>Hạng</th>");
        html.append("<th>Tên Sản Phẩm</th>");
        html.append("<th>Số Lượng</th>");
        html.append("<th>Doanh Thu</th>");
        html.append("</tr>");
        html.append("</thead>");
        html.append("<tbody>");
        
        if (reportData.getTopProducts() != null) {
            int rank = 1;
            for (TopProduct product : reportData.getTopProducts()) {
                html.append("<tr>");
                html.append("<td class='rank'>").append(rank++).append("</td>");
                html.append("<td>").append(product.getProductName()).append("</td>");
                html.append("<td class='number'>").append(product.getQuantity()).append("</td>");
                html.append("<td class='currency'>").append(currencyFormat.format(product.getRevenue())).append("</td>");
                html.append("</tr>");
            }
        }
        
        html.append("</tbody>");
        html.append("</table>");
        html.append("</div>"); // section
        
        // Daily Revenue
        html.append("<div class='section'>");
        html.append("<h3>DOANH THU THEO NGÀY</h3>");
        html.append("<table class='data-table'>");
        html.append("<thead>");
        html.append("<tr>");
        html.append("<th>Ngày</th>");
        html.append("<th>Doanh Thu</th>");
        html.append("<th>Số Đơn Hàng</th>");
        html.append("</tr>");
        html.append("</thead>");
        html.append("<tbody>");
        
        if (reportData.getDailyRevenue() != null) {
            for (DailyRevenue daily : reportData.getDailyRevenue()) {
                html.append("<tr>");
                html.append("<td>").append(daily.getDate()).append("</td>");
                html.append("<td class='currency'>").append(currencyFormat.format(daily.getRevenue())).append("</td>");
                html.append("<td class='number'>").append(daily.getOrders()).append("</td>");
                html.append("</tr>");
            }
        }
        
        html.append("</tbody>");
        html.append("</table>");
        html.append("</div>"); // section
        
        // Footer
        html.append("<div class='footer'>");
        html.append("<p>© 2024 PizzaConnect Restaurant Management System</p>");
        html.append("<p>Báo cáo được tạo tự động bởi hệ thống</p>");
        html.append("</div>");
        
        html.append("</body>");
        html.append("</html>");
        
        return html.toString();
    }
    
    private static String getCSS() {
        return """
            @page { 
                size: A4; 
                margin: 2cm; 
            }
            
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                line-height: 1.6; 
                color: #333; 
                margin: 0; 
                padding: 0; 
            }
            
            .header { 
                text-align: center; 
                margin-bottom: 30px; 
                border-bottom: 3px solid #f97316; 
                padding-bottom: 20px; 
            }
            
            .header h1 { 
                color: #f97316; 
                font-size: 28px; 
                margin: 0 0 10px 0; 
                font-weight: bold; 
            }
            
            .header h2 { 
                color: #666; 
                font-size: 18px; 
                margin: 0 0 20px 0; 
                font-weight: normal; 
            }
            
            .report-info { 
                background: #f8f9fa; 
                padding: 15px; 
                border-radius: 8px; 
                margin-top: 20px; 
            }
            
            .report-info p { 
                margin: 5px 0; 
                font-size: 14px; 
            }
            
            .section { 
                margin-bottom: 40px; 
                page-break-inside: avoid; 
            }
            
            .section h3 { 
                color: #f97316; 
                font-size: 20px; 
                margin-bottom: 20px; 
                border-bottom: 2px solid #f97316; 
                padding-bottom: 10px; 
            }
            
            .stats-grid { 
                display: grid; 
                grid-template-columns: repeat(2, 1fr); 
                gap: 20px; 
                margin-bottom: 20px; 
            }
            
            .stat-card { 
                background: #fff; 
                border: 2px solid #e5e7eb; 
                border-radius: 8px; 
                padding: 20px; 
                text-align: center; 
            }
            
            .stat-label { 
                font-size: 14px; 
                color: #666; 
                margin-bottom: 10px; 
            }
            
            .stat-value { 
                font-size: 24px; 
                font-weight: bold; 
            }
            
            .stat-value.revenue { color: #3b82f6; }
            .stat-value.orders { color: #10b981; }
            .stat-value.customers { color: #8b5cf6; }
            .stat-value.avg { color: #f97316; }
            
            .growth-section { 
                text-align: center; 
                margin-top: 20px; 
                padding: 15px; 
                background: #f8f9fa; 
                border-radius: 8px; 
            }
            
            .growth { 
                font-size: 18px; 
                font-weight: bold; 
            }
            
            .growth.positive { color: #10b981; }
            .growth.negative { color: #ef4444; }
            
            .data-table { 
                width: 100%; 
                border-collapse: collapse; 
                margin-top: 20px; 
            }
            
            .data-table th, .data-table td { 
                border: 1px solid #e5e7eb; 
                padding: 12px; 
                text-align: left; 
            }
            
            .data-table th { 
                background: #f97316; 
                color: white; 
                font-weight: bold; 
                text-align: center; 
            }
            
            .data-table tr:nth-child(even) { 
                background: #f8f9fa; 
            }
            
            .data-table .rank { 
                text-align: center; 
                font-weight: bold; 
                color: #f97316; 
            }
            
            .data-table .number { 
                text-align: right; 
            }
            
            .data-table .currency { 
                text-align: right; 
                font-weight: bold; 
                color: #10b981; 
            }
            
            .footer { 
                margin-top: 50px; 
                text-align: center; 
                font-size: 12px; 
                color: #666; 
                border-top: 1px solid #e5e7eb; 
                padding-top: 20px; 
            }
            
            @media print {
                .section { 
                    page-break-inside: avoid; 
                }
                
                .stats-grid { 
                    page-break-inside: avoid; 
                }
            }
            """;
    }
    
    private static String getBranchName(String branch) {
        switch (branch) {
            case "all": return "Tất cả chi nhánh";
            case "hcm1": return "Pizza Store Q1 - HCM";
            case "hcm2": return "Pizza Store Q3 - HCM";
            case "hn1": return "Pizza Store Hoàn Kiếm - HN";
            case "dn1": return "Pizza Store Hải Châu - DN";
            default: return "Không xác định";
        }
    }
}