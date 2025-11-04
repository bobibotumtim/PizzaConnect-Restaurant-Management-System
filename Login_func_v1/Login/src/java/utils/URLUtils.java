package utils;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

/**
 * Utility class for handling URL parameter construction and encoding
 * specifically for inventory management functionality
 */
public class URLUtils {
    
    /**
     * Builds a URL with preserved search and filter parameters for inventory management
     * @param baseUrl The base URL (e.g., "manageinventory")
     * @param searchName The search parameter value
     * @param statusFilter The status filter parameter value
     * @param page The page parameter value
     * @return Complete URL with parameters
     */
    public static String buildInventoryUrl(String baseUrl, String searchName, String statusFilter, String page) {
        return buildInventoryUrl(baseUrl, searchName, statusFilter, page, null);
    }
    
    /**
     * Builds a URL with preserved search, filter and pagination parameters for inventory management
     * @param baseUrl The base URL (e.g., "manageinventory")
     * @param searchName The search parameter value
     * @param statusFilter The status filter parameter value
     * @param page The page parameter value
     * @param pageSize The page size parameter value
     * @return Complete URL with parameters
     */
    public static String buildInventoryUrl(String baseUrl, String searchName, String statusFilter, String page, String pageSize) {
        StringBuilder url = new StringBuilder(baseUrl);
        boolean hasParams = false;
        
        try {
            if (searchName != null && !searchName.trim().isEmpty()) {
                url.append(hasParams ? "&" : "?").append("searchName=").append(URLEncoder.encode(searchName.trim(), "UTF-8"));
                hasParams = true;
            }
            
            if (statusFilter != null && !statusFilter.equals("all")) {
                url.append(hasParams ? "&" : "?").append("statusFilter=").append(statusFilter);
                hasParams = true;
            }
            
            if (page != null && !page.equals("1")) {
                url.append(hasParams ? "&" : "?").append("page=").append(page);
                hasParams = true;
            }
            
            if (pageSize != null && !pageSize.equals("10")) {
                url.append(hasParams ? "&" : "?").append("pageSize=").append(pageSize);
            }
        } catch (UnsupportedEncodingException e) {
            // UTF-8 should always be supported, but fallback to original values
            if (searchName != null && !searchName.trim().isEmpty()) {
                url.append(hasParams ? "&" : "?").append("searchName=").append(searchName.trim());
                hasParams = true;
            }
            
            if (statusFilter != null && !statusFilter.equals("all")) {
                url.append(hasParams ? "&" : "?").append("statusFilter=").append(statusFilter);
                hasParams = true;
            }
            
            if (page != null && !page.equals("1")) {
                url.append(hasParams ? "&" : "?").append("page=").append(page);
                hasParams = true;
            }
            
            if (pageSize != null && !pageSize.equals("10")) {
                url.append(hasParams ? "&" : "?").append("pageSize=").append(pageSize);
            }
        }
        
        return url.toString();
    }
    
    /**
     * Normalizes search parameter - trims whitespace and converts empty to null
     * @param searchParam The search parameter from request
     * @return Normalized search parameter or null if empty
     */
    public static String normalizeSearchParam(String searchParam) {
        if (searchParam != null) {
            searchParam = searchParam.trim();
            if (searchParam.isEmpty()) {
                return null;
            }
        }
        return searchParam;
    }
    
    /**
     * Normalizes status filter parameter - defaults to "all" if null or empty
     * @param statusFilter The status filter parameter from request
     * @return Normalized status filter parameter
     */
    public static String normalizeStatusFilter(String statusFilter) {
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            return "all";
        }
        return statusFilter.trim();
    }
    
    /**
     * Parses page parameter with validation and default value
     * @param pageParam The page parameter from request
     * @param totalPages The total number of pages available
     * @return Valid page number (1-based)
     */
    public static int parsePageParam(String pageParam, int totalPages) {
        int page = 1;
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
                if (page > totalPages && totalPages > 0) page = totalPages;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        return page;
    }
}