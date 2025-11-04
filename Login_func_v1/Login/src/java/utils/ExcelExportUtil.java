package utils;

import models.SalesReportData;
import models.TopProduct;
import models.DailyRevenue;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.NumberFormat;
import java.util.Locale;

public class ExcelExportUtil {
    
    private static final NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    
    public static byte[] exportSalesReport(SalesReportData reportData, String dateFrom, String dateTo, String branch) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            
            // Create styles
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle titleStyle = createTitleStyle(workbook);
            CellStyle currencyStyle = createCurrencyStyle(workbook);
            CellStyle numberStyle = createNumberStyle(workbook);
            
            // Create Summary Sheet
            Sheet summarySheet = workbook.createSheet("Tổng Quan");
            createSummarySheet(summarySheet, reportData, dateFrom, dateTo, branch, titleStyle, headerStyle, currencyStyle, numberStyle);
            
            // Create Top Products Sheet
            Sheet productsSheet = workbook.createSheet("Sản Phẩm Bán Chạy");
            createTopProductsSheet(productsSheet, reportData, titleStyle, headerStyle, currencyStyle, numberStyle);
            
            // Create Daily Revenue Sheet
            Sheet dailySheet = workbook.createSheet("Doanh Thu Theo Ngày");
            createDailyRevenueSheet(dailySheet, reportData, titleStyle, headerStyle, currencyStyle, numberStyle);
            
            // Write to byte array
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            workbook.write(outputStream);
            return outputStream.toByteArray();
        }
    }
    
    private static void createSummarySheet(Sheet sheet, SalesReportData reportData, String dateFrom, String dateTo, 
                                         String branch, CellStyle titleStyle, CellStyle headerStyle, 
                                         CellStyle currencyStyle, CellStyle numberStyle) {
        int rowNum = 0;
        
        // Title
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("BÁO CÁO BÁN HÀNG - PIZZA CONNECT");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));
        
        rowNum++; // Empty row
        
        // Report Info
        Row infoRow1 = sheet.createRow(rowNum++);
        infoRow1.createCell(0).setCellValue("Khoảng thời gian:");
        infoRow1.createCell(1).setCellValue(dateFrom + " đến " + dateTo);
        
        Row infoRow2 = sheet.createRow(rowNum++);
        infoRow2.createCell(0).setCellValue("Chi nhánh:");
        infoRow2.createCell(1).setCellValue(getBranchName(branch));
        
        rowNum++; // Empty row
        
        // Summary Statistics
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("Chỉ Số");
        headerRow.createCell(1).setCellValue("Giá Trị");
        headerRow.getCell(0).setCellStyle(headerStyle);
        headerRow.getCell(1).setCellStyle(headerStyle);
        
        // Total Revenue
        Row revenueRow = sheet.createRow(rowNum++);
        revenueRow.createCell(0).setCellValue("Tổng Doanh Thu");
        Cell revenueCell = revenueRow.createCell(1);
        revenueCell.setCellValue(reportData.getTotalRevenue());
        revenueCell.setCellStyle(currencyStyle);
        
        // Total Orders
        Row ordersRow = sheet.createRow(rowNum++);
        ordersRow.createCell(0).setCellValue("Tổng Đơn Hàng");
        Cell ordersCell = ordersRow.createCell(1);
        ordersCell.setCellValue(reportData.getTotalOrders());
        ordersCell.setCellStyle(numberStyle);
        
        // Total Customers
        Row customersRow = sheet.createRow(rowNum++);
        customersRow.createCell(0).setCellValue("Tổng Khách Hàng");
        Cell customersCell = customersRow.createCell(1);
        customersCell.setCellValue(reportData.getTotalCustomers());
        customersCell.setCellStyle(numberStyle);
        
        // Average Order Value
        Row avgRow = sheet.createRow(rowNum++);
        avgRow.createCell(0).setCellValue("Giá Trị Đơn Hàng Trung Bình");
        Cell avgCell = avgRow.createCell(1);
        avgCell.setCellValue(reportData.getAvgOrderValue());
        avgCell.setCellStyle(currencyStyle);
        
        // Growth Rate
        Row growthRow = sheet.createRow(rowNum++);
        growthRow.createCell(0).setCellValue("Tỷ Lệ Tăng Trưởng (%)");
        Cell growthCell = growthRow.createCell(1);
        growthCell.setCellValue(reportData.getGrowthRate());
        growthCell.setCellStyle(numberStyle);
        
        // Auto-size columns
        for (int i = 0; i < 4; i++) {
            sheet.autoSizeColumn(i);
        }
    }
    
    private static void createTopProductsSheet(Sheet sheet, SalesReportData reportData, 
                                             CellStyle titleStyle, CellStyle headerStyle, 
                                             CellStyle currencyStyle, CellStyle numberStyle) {
        int rowNum = 0;
        
        // Title
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("TOP 5 SẢN PHẨM BÁN CHẠY");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));
        
        rowNum++; // Empty row
        
        // Headers
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("Hạng");
        headerRow.createCell(1).setCellValue("Tên Sản Phẩm");
        headerRow.createCell(2).setCellValue("Số Lượng Bán");
        headerRow.createCell(3).setCellValue("Doanh Thu");
        
        for (int i = 0; i < 4; i++) {
            headerRow.getCell(i).setCellStyle(headerStyle);
        }
        
        // Data rows
        if (reportData.getTopProducts() != null) {
            int rank = 1;
            for (TopProduct product : reportData.getTopProducts()) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(rank++);
                dataRow.createCell(1).setCellValue(product.getProductName());
                
                Cell quantityCell = dataRow.createCell(2);
                quantityCell.setCellValue(product.getQuantity());
                quantityCell.setCellStyle(numberStyle);
                
                Cell revenueCell = dataRow.createCell(3);
                revenueCell.setCellValue(product.getRevenue());
                revenueCell.setCellStyle(currencyStyle);
            }
        }
        
        // Auto-size columns
        for (int i = 0; i < 4; i++) {
            sheet.autoSizeColumn(i);
        }
    }
    
    private static void createDailyRevenueSheet(Sheet sheet, SalesReportData reportData, 
                                              CellStyle titleStyle, CellStyle headerStyle, 
                                              CellStyle currencyStyle, CellStyle numberStyle) {
        int rowNum = 0;
        
        // Title
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("DOANH THU THEO NGÀY");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 2));
        
        rowNum++; // Empty row
        
        // Headers
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("Ngày");
        headerRow.createCell(1).setCellValue("Doanh Thu");
        headerRow.createCell(2).setCellValue("Số Đơn Hàng");
        
        for (int i = 0; i < 3; i++) {
            headerRow.getCell(i).setCellStyle(headerStyle);
        }
        
        // Data rows
        if (reportData.getDailyRevenue() != null) {
            for (DailyRevenue daily : reportData.getDailyRevenue()) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(daily.getDate());
                
                Cell revenueCell = dataRow.createCell(1);
                revenueCell.setCellValue(daily.getRevenue());
                revenueCell.setCellStyle(currencyStyle);
                
                Cell ordersCell = dataRow.createCell(2);
                ordersCell.setCellValue(daily.getOrders());
                ordersCell.setCellStyle(numberStyle);
            }
        }
        
        // Auto-size columns
        for (int i = 0; i < 3; i++) {
            sheet.autoSizeColumn(i);
        }
    }
    
    private static CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.LIGHT_ORANGE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }
    
    private static CellStyle createTitleStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 16);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }
    
    private static CellStyle createCurrencyStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setDataFormat(workbook.createDataFormat().getFormat("#,##0\" ₫\""));
        return style;
    }
    
    private static CellStyle createNumberStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setDataFormat(workbook.createDataFormat().getFormat("#,##0"));
        return style;
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