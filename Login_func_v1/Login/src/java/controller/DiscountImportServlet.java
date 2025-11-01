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
    private static final String NOT_FOUND_PATH = "/view/NotFound.jsp";
    private static final Set<String> VALID_ACTIONS = Set.of("template", "error-report");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        // Validate authentication first
        if (!isAuthenticated(request)) {
            forwardToNotFound(request, response, "Unauthorized access");
            return;
        }

        // Validate URL parameters
        if (!validateGetParameters(request)) {
            forwardToNotFound(request, response, "Invalid URL parameters");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("template".equals(action)) {
                downloadTemplate(response);
            } else if ("error-report".equals(action)) {
                downloadErrorReport(request, response);
            } else {
                forwardToNotFound(request, response, "Invalid action parameter");
            }
        } catch (Exception e) {
            LOGGER.severe("Error processing GET request: " + e.getMessage());
            forwardToNotFound(request, response, "Error processing request");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        // Validate authentication first
        if (!isAuthenticated(request)) {
            forwardToNotFound(request, response, "Unauthorized access");
            return;
        }

        // Validate URL path and parameters
        if (!validatePostRequest(request)) {
            forwardToNotFound(request, response, "Invalid POST request");
            return;
        }

        String pathInfo = request.getPathInfo();
        LOGGER.info("Processing import request for path: " + pathInfo);

        try {
            if ("/import".equals(pathInfo) || "/".equals(pathInfo) || pathInfo == null) {
                handleImport(request, response);
            } else {
                forwardToNotFound(request, response, "Invalid path: " + pathInfo);
            }
        } catch (Exception e) {
            LOGGER.severe("Error processing POST request: " + e.getMessage());
            forwardToNotFound(request, response, "Server error");
        }
    }

    /**
     * Validate GET request parameters
     */
    private boolean validateGetParameters(HttpServletRequest request) {
        try {
            String action = request.getParameter("action");

            // Validate action parameter
            if (action == null || action.trim().isEmpty()) {
                LOGGER.warning("Action parameter is required");
                return false;
            }

            if (!VALID_ACTIONS.contains(action)) {
                LOGGER.warning("Invalid action parameter: " + action);
                return false;
            }

            // Validate no unexpected parameters
            return validateNoUnexpectedParameters(request, Arrays.asList("action"));

        } catch (Exception e) {
            LOGGER.severe("Error validating GET parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Validate POST request
     */
    private boolean validatePostRequest(HttpServletRequest request) {
        try {
            String pathInfo = request.getPathInfo();

            // Validate path info
            if (pathInfo != null && !pathInfo.equals("/import") && !pathInfo.equals("/")) {
                LOGGER.warning("Invalid path info: " + pathInfo);
                return false;
            }

            // Check for multipart request
            if (!isMultipartRequest(request)) {
                LOGGER.warning("Request is not multipart");
                return false;
            }

            return true;
        } catch (Exception e) {
            LOGGER.severe("Error validating POST request: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check if request is multipart
     */
    private boolean isMultipartRequest(HttpServletRequest request) {
        String contentType = request.getContentType();
        return contentType != null && contentType.toLowerCase().startsWith("multipart/");
    }

    /**
     * Check for unexpected parameters in request
     */
    private boolean validateNoUnexpectedParameters(HttpServletRequest request, List<String> expectedParams) {
        try {
            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (!expectedParams.contains(paramName)) {
                    // Check if it's a potential attack parameter
                    if (isPotentialAttackParameter(paramName, request.getParameter(paramName))) {
                        LOGGER.warning("Potential attack parameter detected: " + paramName);
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            LOGGER.severe("Error checking unexpected parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check for potential attack parameters
     */
    private boolean isPotentialAttackParameter(String paramName, String paramValue) {
        if (paramName == null || paramValue == null) {
            return false;
        }

        // Check for SQL injection patterns
        if (paramValue.matches(".*([';]+|(--)+).*")) {
            LOGGER.warning("SQL injection pattern detected in parameter: " + paramName);
            return true;
        }

        // Check for XSS patterns
        if (paramValue.matches(".*[<>].*")) {
            LOGGER.warning("XSS pattern detected in parameter: " + paramName);
            return true;
        }

        // Check for path traversal patterns
        if (paramValue.matches(".*(\\.\\./|\\.\\\\.*).*")) {
            LOGGER.warning("Path traversal pattern detected in parameter: " + paramName);
            return true;
        }

        // Check parameter name for suspicious patterns
        if (paramName.matches(".*(script|iframe|object|embed|form).*")) {
            LOGGER.warning("Suspicious parameter name detected: " + paramName);
            return true;
        }

        return false;
    }

    /**
     * Forward to not found page with logging
     */
    private void forwardToNotFound(HttpServletRequest request, HttpServletResponse response, String reason) {
        try {
            LOGGER.warning("Forwarding to not found page. Reason: " + reason);
            request.getRequestDispatcher(NOT_FOUND_PATH).forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error forwarding to not found page: " + e.getMessage());
            try {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            } catch (Exception ex) {
                LOGGER.severe("Error sending 404: " + ex.getMessage());
            }
        }
    }

    private boolean isAuthenticated(HttpServletRequest request) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                LOGGER.warning("No session found");
                return false;
            }

            User user = (User) session.getAttribute("user");
            if (user == null) {
                LOGGER.warning("No user in session");
                return false;
            }

            if (user.getRole() != 1) {
                LOGGER.warning("User is not admin. Role: " + user.getRole());
                return false;
            }

            return true;
        } catch (Exception e) {
            LOGGER.severe("Authentication error: " + e.getMessage());
            return false;
        }
    }

    private void handleImport(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        // Validate file part
        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            forwardToNotFound(request, response, "No file uploaded");
            return;
        }

        // Validate file size
        if (filePart.getSize() > 10 * 1024 * 1024) { // 10MB limit
            forwardToNotFound(request, response, "File size exceeds limit");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        LOGGER.info("Processing import for file: " + fileName);

        // Validate file name
        if (fileName == null || fileName.trim().isEmpty()) {
            forwardToNotFound(request, response, "Invalid file name");
            return;
        }

        // Validate file extension
        if (!isValidExcelFile(fileName)) {
            forwardToNotFound(request, response, "Invalid file type");
            return;
        }

        List<ImportResult> errorResults = new ArrayList<>();
        int successCount = 0;
        int totalProcessedRows = 0;

        try (InputStream inputStream = filePart.getInputStream()) {
            List<ImportResult> results = processExcelFile(inputStream, fileName);

            if (results.isEmpty()) {
                forwardToNotFound(request, response, "File is empty or contains no valid data");
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
            forwardToNotFound(request, response, "Error processing file");
        }
    }

    /**
     * Validate file extension
     */
    private boolean isValidExcelFile(String fileName) {
        if (fileName == null)
            return false;

        String lowerFileName = fileName.toLowerCase();
        return lowerFileName.endsWith(".xlsx") || lowerFileName.endsWith(".xls");
    }

    private void downloadErrorReport(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        // Validate session attributes
        @SuppressWarnings("unchecked")
        List<ImportResult> errorResults = (List<ImportResult>) session.getAttribute("importErrorResults");
        String originalFileName = (String) session.getAttribute("importFileName");
        LocalDateTime timestamp = (LocalDateTime) session.getAttribute("importTimestamp");
        Integer successCount = (Integer) session.getAttribute("importSuccessCount");
        Integer totalCount = (Integer) session.getAttribute("importTotalCount");

        if (errorResults == null || errorResults.isEmpty()) {
            forwardToNotFound(request, response, "No error data available");
            return;
        }

        if (originalFileName == null || timestamp == null || successCount == null || totalCount == null) {
            forwardToNotFound(request, response, "Invalid error report data");
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

        LocalDate tomorrow = LocalDate.now().plusDays(1);
        if (startDate.isBefore(tomorrow)) {
            throw new IllegalArgumentException("Start Date must be tomorrow or later");
        }

        // Validate end date (if provided)
        if (discount.getEndDate() != null && !discount.getEndDate().trim().isEmpty()) {
            LocalDate endDate;
            try {
                endDate = LocalDate.parse(discount.getEndDate().trim());
            } catch (DateTimeParseException e) {
                throw new IllegalArgumentException("Invalid End Date format. Use YYYY-MM-DD");
            }

            LocalDate dayAfterTomorrow = LocalDate.now().plusDays(2);
            if (endDate.isBefore(dayAfterTomorrow)) {
                throw new IllegalArgumentException("End Date must be at least 2 days from today");
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
            String[] headers = { "Description *", "DiscountType *", "Value *", "MaxDiscount", "MinOrderTotal *",
                    "StartDate *",
                    "EndDate" };

            CellStyle headerStyle = createHeaderStyle(workbook);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Create example row with tomorrow as default start date
            Row exampleRow = sheet.createRow(1);
            exampleRow.createCell(0).setCellValue("Summer Sale");
            exampleRow.createCell(1).setCellValue("Percentage");
            exampleRow.createCell(2).setCellValue(10);
            exampleRow.createCell(3).setCellValue(50000);
            exampleRow.createCell(4).setCellValue(100000);

            // Set start date to tomorrow
            LocalDate tomorrow = LocalDate.now().plusDays(1);
            exampleRow.createCell(5).setCellValue(tomorrow.toString());

            // Set end date to 1 month from tomorrow
            exampleRow.createCell(6).setCellValue(tomorrow.plusMonths(1).toString());

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