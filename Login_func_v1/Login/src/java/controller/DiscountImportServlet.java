package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.Discount;
import models.User;
import dao.DiscountDAO;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.logging.Logger;

@WebServlet("/discount/import/*")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class DiscountImportServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(DiscountImportServlet.class.getName());
    private DiscountDAO discountDAO = new DiscountDAO();

    private static final List<String> VALID_DISCOUNT_TYPES = Arrays.asList("Percentage", "Fixed", "Loyalty");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_DATE;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String action = request.getParameter("action");
        if ("template".equals(action)) {
            downloadTemplate(response);
        } else if ("error-report".equals(action)) {
            downloadErrorReport(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        if (!isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/discount?error=Unauthorized");
            return;
        }

        String pathInfo = request.getPathInfo();
        LOGGER.info("Processing import request for path: " + pathInfo);

        try {
            if ("/import".equals(pathInfo) || "/".equals(pathInfo) || pathInfo == null) {
                handleImport(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/discount?error=Invalid+path");
            }
        } catch (Exception e) {
            LOGGER.severe("Error processing request: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/discount?error=Server+error");
        }
    }

    private boolean isAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null)
            return false;

        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == 1;
    }

    private void handleImport(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/discount?error=Please+select+a+file");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        LOGGER.info("Processing import for file: " + fileName);

        List<ImportResult> errorResults = new ArrayList<>();
        int successCount = 0;
        int totalProcessedRows = 0;

        try (InputStream inputStream = filePart.getInputStream()) {
            List<ImportResult> results = processExcelFile(inputStream, fileName);

            if (results.isEmpty()) {
                response.sendRedirect(
                        request.getContextPath() + "/discount?error=File+is+empty+or+contains+no+valid+data");
                return;
            }

            totalProcessedRows = results.size();
            LOGGER.info("Total rows to process: " + totalProcessedRows);

            // Process valid results
            for (ImportResult result : results) {
                if (result.isSuccess() && result.getDiscount() != null) {
                    if (discountDAO.addDiscount(result.getDiscount())) {
                        successCount++;
                        LOGGER.info("Successfully imported discount: " + result.getDiscount().getDescription());
                    } else {
                        LOGGER.warning("Database save failed for: " + result.getDiscount().getDescription());
                        result.setSuccess(false);
                        result.setMessage("Database save failed");
                        errorResults.add(result);
                    }
                } else {
                    LOGGER.warning("Validation failed for row " + result.getRowNumber() + ": " + result.getMessage());
                    errorResults.add(result);
                }
            }

            LOGGER.info("Import summary: " + successCount + " successful, " + errorResults.size() + " failed");

            // Store results in session
            HttpSession session = request.getSession();

            // Set success message with counts
            String successMessage = "Successfully imported " + successCount + " out of " + totalProcessedRows
                    + " discounts.";
            session.setAttribute("success", successMessage);

            // Store error results for error report
            if (!errorResults.isEmpty()) {
                session.setAttribute("importErrorResults", errorResults);
                session.setAttribute("importFileName", fileName);
                session.setAttribute("importTimestamp", LocalDateTime.now());
                session.setAttribute("importSuccessCount", successCount);
                session.setAttribute("importTotalCount", totalProcessedRows);
                LOGGER.info("Stored " + errorResults.size() + " error results in session");
            }

            // Redirect back to discount page
            response.sendRedirect(request.getContextPath() + "/discount");

        } catch (Exception e) {
            LOGGER.severe("Error processing import: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/discount?error=Error+processing+file");
        }
    }

    private void downloadErrorReport(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        @SuppressWarnings("unchecked")
        List<ImportResult> errorResults = (List<ImportResult>) session.getAttribute("importErrorResults");
        String originalFileName = (String) session.getAttribute("importFileName");
        LocalDateTime timestamp = (LocalDateTime) session.getAttribute("importTimestamp");
        Integer successCount = (Integer) session.getAttribute("importSuccessCount");
        Integer totalCount = (Integer) session.getAttribute("importTotalCount");

        if (errorResults == null || errorResults.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No error data available");
            return;
        }

        // Generate filename with timestamp
        String timestampStr = timestamp.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String reportFileName = "import_errors_" + timestampStr + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=" + reportFileName);

        createErrorReport(errorResults, response.getOutputStream(), successCount, totalCount);

        // Clear session data after download
        session.removeAttribute("importErrorResults");
        session.removeAttribute("importFileName");
        session.removeAttribute("importTimestamp");
        session.removeAttribute("importSuccessCount");
        session.removeAttribute("importTotalCount");
    }

    private void createErrorReport(List<ImportResult> errorResults, OutputStream outputStream,
            Integer successCount, Integer totalCount) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Import Errors");

            // Create styles
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle errorStyle = workbook.createCellStyle();
            Font errorFont = workbook.createFont();
            errorFont.setColor(IndexedColors.RED.getIndex());
            errorStyle.setFont(errorFont);

            CellStyle normalStyle = workbook.createCellStyle();
            CellStyle blankStyle = workbook.createCellStyle(); // Style for empty cells
            Font blankFont = workbook.createFont();
            blankFont.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
            blankStyle.setFont(blankFont);

            // Add summary row
            Row summaryRow = sheet.createRow(0);
            Cell summaryCell = summaryRow.createCell(0);
            summaryCell.setCellValue("Import Summary: " + successCount + "/" + totalCount + " successful");
            CellStyle summaryStyle = workbook.createCellStyle();
            Font summaryFont = workbook.createFont();
            summaryFont.setBold(true);
            summaryStyle.setFont(summaryFont);
            summaryCell.setCellStyle(summaryStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 8));

            // Create header row
            Row headerRow = sheet.createRow(1);
            String[] headers = { "Row Number", "Description", "Discount Type", "Value", "Max Discount",
                    "Min Order Total", "Start Date", "End Date", "Error Message" };

            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Create data rows
            int rowNum = 2;
            for (ImportResult result : errorResults) {
                Row row = sheet.createRow(rowNum++);

                // Row Number
                createCell(row, 0, result.getRowNumber(), normalStyle);

                // Discount data - use new method to display correct values
                createDiscountCellsForErrorReport(row, result.getDiscount(), normalStyle, blankStyle);

                // Error Message
                Cell errorCell = row.createCell(8);
                errorCell.setCellValue(result.getMessage());
                errorCell.setCellStyle(errorStyle);
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(outputStream);
        }
    }

    private void createDiscountCellsForErrorReport(Row row, Discount discount, CellStyle normalStyle,
            CellStyle blankStyle) {
        if (discount == null) {
            // Create empty cells if discount is null
            for (int i = 1; i <= 7; i++) {
                createCell(row, i, "", blankStyle);
            }
            return;
        }

        // Description - always display
        createCell(row, 1, discount.getDescription(), normalStyle);

        // Discount Type - always display
        createCell(row, 2, discount.getDiscountType(), normalStyle);

        // Value - only display if has actual value
        if (discount.getValue() != 0) {
            createCell(row, 3, discount.getValue(), normalStyle);
        } else {
            createCell(row, 3, "", blankStyle);
        }

        // Max Discount - only display if has value
        if (discount.getMaxDiscount() != null && discount.getMaxDiscount() != 0) {
            createCell(row, 4, discount.getMaxDiscount(), normalStyle);
        } else {
            createCell(row, 4, "", blankStyle);
        }

        // Min Order Total - only display if has actual value
        if (discount.getMinOrderTotal() != 0) {
            createCell(row, 5, discount.getMinOrderTotal(), normalStyle);
        } else {
            createCell(row, 5, "", blankStyle);
        }

        // Start Date - only display if has value
        if (discount.getStartDate() != null && !discount.getStartDate().isEmpty()) {
            createCell(row, 6, discount.getStartDate(), normalStyle);
        } else {
            createCell(row, 6, "", blankStyle);
        }

        // End Date - only display if has value
        if (discount.getEndDate() != null && !discount.getEndDate().isEmpty()) {
            createCell(row, 7, discount.getEndDate(), normalStyle);
        } else {
            createCell(row, 7, "", blankStyle);
        }
    }

    private void createCell(Row row, int column, Object value, CellStyle style) {
        Cell cell = row.createCell(column);

        if (value instanceof String) {
            cell.setCellValue((String) value);
        } else if (value instanceof Double) {
            cell.setCellValue((Double) value);
        } else if (value instanceof Integer) {
            cell.setCellValue((Integer) value);
        } else if (value == null) {
            cell.setCellValue("");
        } else {
            cell.setCellValue(value.toString());
        }

        if (style != null) {
            cell.setCellStyle(style);
        }
    }

    private List<ImportResult> processExcelFile(InputStream inputStream, String fileName) throws IOException {
        List<ImportResult> results = new ArrayList<>();
        LOGGER.info("Starting to process Excel file: " + fileName);

        try (Workbook workbook = getWorkbook(inputStream, fileName)) {
            Sheet sheet = workbook.getSheetAt(0);

            if (sheet == null || sheet.getPhysicalNumberOfRows() == 0) {
                throw new IOException("Excel file is empty or has no sheets");
            }

            // Get the first row to check if it's a header
            Row firstRow = sheet.getRow(0);
            boolean hasHeader = isHeaderRow(firstRow);

            int rowNumber = 0;
            int dataRowCount = 0;

            for (Row row : sheet) {
                rowNumber++;

                // Skip header row if it exists
                if (rowNumber == 1 && hasHeader) {
                    continue;
                }

                if (isEmptyRow(row)) {
                    LOGGER.info("Skipping empty row: " + rowNumber);
                    continue;
                }

                ImportResult result = processExcelRow(row, rowNumber);
                results.add(result);
                dataRowCount++;
            }

            LOGGER.info("Processing complete: " + dataRowCount + " data rows");

            if (dataRowCount == 0) {
                throw new IOException("No valid data found in the file");
            }

        } catch (Exception e) {
            LOGGER.severe("Error in processExcelFile: " + e.getMessage());
            throw new IOException("Invalid Excel file: " + e.getMessage(), e);
        }

        return results;
    }

    private boolean isHeaderRow(Row row) {
        if (row == null)
            return false;

        Cell firstCell = row.getCell(0);
        if (firstCell != null) {
            String value = getCellValueAsString(firstCell);
            return value != null &&
                    (value.toLowerCase().contains("description") ||
                            value.toLowerCase().contains("discount") ||
                            value.toLowerCase().contains("type"));
        }
        return false;
    }

    private Workbook getWorkbook(InputStream inputStream, String fileName) throws IOException {
        if (fileName.toLowerCase().endsWith(".xlsx")) {
            return new XSSFWorkbook(inputStream);
        } else if (fileName.toLowerCase().endsWith(".xls")) {
            return new HSSFWorkbook(inputStream);
        } else {
            throw new IllegalArgumentException("The specified file is not Excel file. Supported formats: .xlsx, .xls");
        }
    }

    private boolean isEmptyRow(Row row) {
        if (row == null)
            return true;

        for (int i = 0; i < 7; i++) {
            Cell cell = row.getCell(i);
            if (cell != null) {
                String value = getCellValueAsString(cell);
                if (value != null && !value.trim().isEmpty()) {
                    return false;
                }
            }
        }
        return true;
    }

    private ImportResult processExcelRow(Row row, int rowNumber) {
        ImportResult result = new ImportResult();
        result.setRowNumber(rowNumber);

        Discount discount = null;
        try {
            LOGGER.info("Processing row " + rowNumber);
            discount = parseDiscountFromRow(row);
            LOGGER.info("Parsed discount: " + discount.getDescription());

            validateDiscount(discount);

            discount.setActive(true);
            result.setDiscount(discount);
            result.setSuccess(true);
            result.setMessage("Valid");

        } catch (Exception e) {
            LOGGER.warning("Row " + rowNumber + " validation failed: " + e.getMessage());
            result.setSuccess(false);
            result.setMessage(e.getMessage());

            // Always try to parse discount to get data for error report
            if (discount == null) {
                try {
                    discount = parseDiscountFromRowForErrorReport(row);
                } catch (Exception ex) {
                    // If parsing completely fails, create empty discount
                    discount = new Discount();
                    discount.setDescription("Failed to parse");
                }
            }
            result.setDiscount(discount);
        }

        return result;
    }

    private Discount parseDiscountFromRowForErrorReport(Row row) {
        Discount discount = new Discount();

        try {
            // Parse each field individually, catch errors separately
            discount.setDescription(getCellValueAsStringSafe(row, 0));
            discount.setDiscountType(getCellValueAsStringSafe(row, 1));

            // Parse value - use safe method
            Double value = getNumericCellValueSafe(row, 2);
            if (value != null) {
                discount.setValue(value);
            } else {
                discount.setValue(0); // Mark as no value
            }

            // Parse max discount - use safe method
            discount.setMaxDiscount(getNumericCellValueSafe(row, 3));

            // Parse min order total - use safe method
            Double minOrder = getNumericCellValueSafe(row, 4);
            if (minOrder != null) {
                discount.setMinOrderTotal(minOrder);
            } else {
                discount.setMinOrderTotal(0); // Mark as no value
            }

            // Parse dates
            discount.setStartDate(getCellValueAsStringSafe(row, 5));
            discount.setEndDate(getCellValueAsStringSafe(row, 6));

        } catch (Exception e) {
            LOGGER.warning("Error parsing row for error report: " + e.getMessage());
        }

        return discount;
    }

    private String getCellValueAsStringSafe(Row row, int cellIndex) {
        try {
            Cell cell = row.getCell(cellIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
            if (cell == null) {
                return "";
            }
            String value = getCellValueAsString(cell);
            return value != null ? value : "";
        } catch (Exception e) {
            return "";
        }
    }

    private Discount parseDiscountFromRow(Row row) {
        Discount discount = new Discount();

        discount.setDescription(getRequiredCellValue(row, 0, "Description"));
        discount.setDiscountType(getValidDiscountType(row, 1));
        discount.setValue(getNumericCellValue(row, 2, "Value"));
        discount.setMaxDiscount(getOptionalNumericCellValue(row, 3));
        discount.setMinOrderTotal(getNumericCellValue(row, 4, "Min Order Total"));

        String startDateStr = getRequiredCellValue(row, 5, "Start Date");
        discount.setStartDate(parseDate(startDateStr, "Start Date"));

        String endDateStr = getOptionalCellValue(row, 6);
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            discount.setEndDate(parseDate(endDateStr, "End Date"));
        }

        return discount;
    }

    private String getRequiredCellValue(Row row, int cellIndex, String fieldName) {
        Cell cell = row.getCell(cellIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (cell == null) {
            throw new IllegalArgumentException(fieldName + " is required");
        }

        String value = getCellValueAsString(cell);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " is required");
        }
        return value.trim();
    }

    private String getOptionalCellValue(Row row, int cellIndex) {
        Cell cell = row.getCell(cellIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (cell == null) {
            return null;
        }

        String value = getCellValueAsString(cell);
        return (value != null && !value.trim().isEmpty()) ? value.trim() : null;
    }

    private String getValidDiscountType(Row row, int cellIndex) {
        String discountType = getRequiredCellValue(row, cellIndex, "Discount Type");
        String trimmedType = discountType.trim();

        if (!VALID_DISCOUNT_TYPES.contains(trimmedType)) {
            throw new IllegalArgumentException(
                    "Discount Type must be one of: " + String.join(", ", VALID_DISCOUNT_TYPES));
        }
        return trimmedType;
    }

    private double getNumericCellValue(Row row, int cellIndex, String fieldName) {
        Cell cell = row.getCell(cellIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (cell == null) {
            throw new IllegalArgumentException(fieldName + " is required");
        }

        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            } else {
                String stringValue = getCellValueAsString(cell);
                if (stringValue == null || stringValue.trim().isEmpty()) {
                    throw new IllegalArgumentException(fieldName + " is required");
                }
                return Double.parseDouble(stringValue.trim());
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(fieldName + " must be a valid number");
        }
    }

    private Double getNumericCellValueSafe(Row row, int cellIndex) {
        try {
            Cell cell = row.getCell(cellIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
            if (cell == null) {
                return null;
            }

            if (cell.getCellType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            } else if (cell.getCellType() == CellType.STRING) {
                String stringValue = cell.getStringCellValue().trim();
                if (stringValue.isEmpty()) {
                    return null;
                }
                try {
                    return Double.parseDouble(stringValue);
                } catch (NumberFormatException e) {
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    private Double getOptionalNumericCellValue(Row row, int cellIndex) {
        Cell cell = row.getCell(cellIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (cell == null) {
            return null;
        }

        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            } else {
                String stringValue = getCellValueAsString(cell);
                if (stringValue == null || stringValue.trim().isEmpty()) {
                    return null;
                }
                return Double.parseDouble(stringValue.trim());
            }
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null)
            return null;

        try {
            CellType cellType = cell.getCellType();
            if (cellType == CellType.FORMULA) {
                cellType = cell.getCachedFormulaResultType();
            }

            switch (cellType) {
                case STRING:
                    return cell.getStringCellValue().trim();
                case NUMERIC:
                    if (DateUtil.isCellDateFormatted(cell)) {
                        try {
                            return cell.getDateCellValue().toInstant()
                                    .atZone(java.time.ZoneId.systemDefault())
                                    .toLocalDate()
                                    .format(DATE_FORMATTER);
                        } catch (Exception e) {
                            return String.valueOf(cell.getNumericCellValue());
                        }
                    } else {
                        double numValue = cell.getNumericCellValue();
                        if (numValue == (long) numValue) {
                            return String.valueOf((long) numValue);
                        } else {
                            return String.valueOf(numValue);
                        }
                    }
                case BOOLEAN:
                    return String.valueOf(cell.getBooleanCellValue());
                case BLANK:
                    return "";
                default:
                    return null;
            }
        } catch (Exception e) {
            LOGGER.warning("Error reading cell value: " + e.getMessage());
            return null;
        }
    }

    private String parseDate(String dateStr, String fieldName) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " is required");
        }

        try {
            LocalDate date = LocalDate.parse(dateStr.trim());
            LocalDate today = LocalDate.now();

            if (date.isBefore(today)) {
                throw new IllegalArgumentException(fieldName + " cannot be in the past");
            }

            return date.format(DATE_FORMATTER);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid " + fieldName + " format. Use YYYY-MM-DD");
        }
    }

    private void validateDiscount(Discount discount) {
        if (discount == null) {
            throw new IllegalArgumentException("Discount object is null");
        }

        // Validate description
        if (discount.getDescription() == null || discount.getDescription().trim().isEmpty()) {
            throw new IllegalArgumentException("Description is required");
        }

        // Validate value
        if (discount.getValue() <= 0) {
            throw new IllegalArgumentException("Value must be greater than 0");
        }

        // Validate min order total
        if (discount.getMinOrderTotal() < 0) {
            throw new IllegalArgumentException("Min Order Total must be >= 0");
        }

        // Validate max discount (if provided)
        if (discount.getMaxDiscount() != null && discount.getMaxDiscount() < 1000) {
            throw new IllegalArgumentException("Max Discount must be at least 1000 if provided");
        }

        // Validate start date
        if (discount.getStartDate() == null || discount.getStartDate().trim().isEmpty()) {
            throw new IllegalArgumentException("Start Date is required");
        }

        LocalDate startDate;
        try {
            startDate = LocalDate.parse(discount.getStartDate().trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid Start Date format. Use YYYY-MM-DD");
        }

        LocalDate today = LocalDate.now();
        if (startDate.isBefore(today)) {
            throw new IllegalArgumentException("Start Date cannot be in the past");
        }

        // Validate end date (if provided)
        if (discount.getEndDate() != null && !discount.getEndDate().trim().isEmpty()) {
            LocalDate endDate;
            try {
                endDate = LocalDate.parse(discount.getEndDate().trim());
            } catch (DateTimeParseException e) {
                throw new IllegalArgumentException("Invalid End Date format. Use YYYY-MM-DD");
            }

            if (endDate.isBefore(startDate)) {
                throw new IllegalArgumentException("End Date cannot be before Start Date");
            }
        }

        // Validate discount type specific rules
        String discountType = discount.getDiscountType();
        double value = discount.getValue();

        if ("Percentage".equals(discountType)) {
            if (value < 1 || value > 100) {
                throw new IllegalArgumentException("Percentage value must be between 1-100");
            }
        } else if ("Fixed".equals(discountType)) {
            if (value < 1000) {
                throw new IllegalArgumentException("Fixed discount must be at least 1000");
            }
        } else if ("Loyalty".equals(discountType)) {
            if (discount.getMinOrderTotal() != 0) {
                throw new IllegalArgumentException("Loyalty discount must have Min Order Total = 0");
            }
        }
    }

    private void downloadTemplate(HttpServletResponse response) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=discount_template.xlsx");

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Discount Template");

            // Create header row
            Row headerRow = sheet.createRow(0);
            String[] headers = { "Description", "DiscountType", "Value", "MaxDiscount", "MinOrderTotal", "StartDate",
                    "EndDate" };

            CellStyle headerStyle = createHeaderStyle(workbook);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Create example row
            Row exampleRow = sheet.createRow(1);
            exampleRow.createCell(0).setCellValue("Summer Sale");
            exampleRow.createCell(1).setCellValue("Percentage");
            exampleRow.createCell(2).setCellValue(10);
            exampleRow.createCell(3).setCellValue(50000);
            exampleRow.createCell(4).setCellValue(100000);
            exampleRow.createCell(5).setCellValue(LocalDate.now().plusDays(1).toString());
            exampleRow.createCell(6).setCellValue(LocalDate.now().plusMonths(1).toString());

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(response.getOutputStream());
        }
    }

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        style.setFont(font);
        return style;
    }

    public static class ImportResult {
        private int rowNumber;
        private boolean success;
        private String message;
        private Discount discount;

        public int getRowNumber() {
            return rowNumber;
        }

        public void setRowNumber(int rowNumber) {
            this.rowNumber = rowNumber;
        }

        public boolean isSuccess() {
            return success;
        }

        public void setSuccess(boolean success) {
            this.success = success;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public Discount getDiscount() {
            return discount;
        }

        public void setDiscount(Discount discount) {
            this.discount = discount;
        }
    }
}