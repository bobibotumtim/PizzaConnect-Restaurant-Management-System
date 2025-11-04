package test;

import dao.InventoryDAO;
import models.Inventory;
import utils.URLUtils;
import java.util.List;

/**
 * Test class to verify inventory search and filtering enhancements
 */
public class TestInventoryEnhancements {
    
    public static void main(String[] args) {
        System.out.println("=== Testing Inventory Search and Filter Enhancements ===\n");
        
        testURLUtils();
        testInventoryDAO();
        
        System.out.println("=== All tests completed ===");
    }
    
    /**
     * Test URLUtils functionality
     */
    private static void testURLUtils() {
        System.out.println("1. Testing URLUtils...");
        
        // Test URL building with all parameters
        String url1 = URLUtils.buildInventoryUrl("manageinventory", "pizza", "active", "2");
        System.out.println("   URL with all params: " + url1);
        
        // Test URL building with some parameters
        String url2 = URLUtils.buildInventoryUrl("manageinventory", "bread", null, null);
        System.out.println("   URL with search only: " + url2);
        
        // Test URL building with no parameters
        String url3 = URLUtils.buildInventoryUrl("manageinventory", null, "all", "1");
        System.out.println("   URL with no params: " + url3);
        
        // Test parameter normalization
        String normalized1 = URLUtils.normalizeSearchParam("  pizza  ");
        String normalized2 = URLUtils.normalizeSearchParam("");
        String normalized3 = URLUtils.normalizeSearchParam(null);
        System.out.println("   Normalized search params: '" + normalized1 + "', '" + normalized2 + "', '" + normalized3 + "'");
        
        // Test status filter normalization
        String status1 = URLUtils.normalizeStatusFilter("active");
        String status2 = URLUtils.normalizeStatusFilter("");
        String status3 = URLUtils.normalizeStatusFilter(null);
        System.out.println("   Normalized status filters: '" + status1 + "', '" + status2 + "', '" + status3 + "'");
        
        // Test page parsing
        int page1 = URLUtils.parsePageParam("3", 5);
        int page2 = URLUtils.parsePageParam("0", 5);
        int page3 = URLUtils.parsePageParam("10", 5);
        int page4 = URLUtils.parsePageParam("invalid", 5);
        System.out.println("   Parsed pages: " + page1 + ", " + page2 + ", " + page3 + ", " + page4);
        
        System.out.println("   ✓ URLUtils tests completed\n");
    }
    
    /**
     * Test InventoryDAO search and filter functionality
     */
    private static void testInventoryDAO() {
        System.out.println("2. Testing InventoryDAO search and filter...");
        
        InventoryDAO dao = new InventoryDAO();
        
        try {
            // Test total count without filters
            int totalCount = dao.getTotalInventoryCount();
            System.out.println("   Total inventory count: " + totalCount);
            
            // Test total count with search filter
            int searchCount = dao.getTotalInventoryCount("pizza", null);
            System.out.println("   Count with 'pizza' search: " + searchCount);
            
            // Test total count with status filter
            int activeCount = dao.getTotalInventoryCount(null, "active");
            System.out.println("   Count with 'active' status: " + activeCount);
            
            // Test total count with both filters
            int bothCount = dao.getTotalInventoryCount("pizza", "active");
            System.out.println("   Count with both filters: " + bothCount);
            
            // Test paginated results without filters
            List<Inventory> allItems = dao.getInventoriesByPage(1, 5);
            System.out.println("   First 5 items (no filter): " + allItems.size() + " items");
            
            // Test paginated results with search
            List<Inventory> searchItems = dao.getInventoriesByPage(1, 5, "pizza", null);
            System.out.println("   First 5 items with 'pizza' search: " + searchItems.size() + " items");
            
            // Test paginated results with status filter
            List<Inventory> activeItems = dao.getInventoriesByPage(1, 5, null, "active");
            System.out.println("   First 5 active items: " + activeItems.size() + " items");
            
            // Test paginated results with both filters
            List<Inventory> filteredItems = dao.getInventoriesByPage(1, 5, "pizza", "active");
            System.out.println("   First 5 items with both filters: " + filteredItems.size() + " items");
            
            // Test name existence check
            boolean nameExists1 = dao.isNameExists("Pizza Dough", null);
            boolean nameExists2 = dao.isNameExists("NonExistentItem12345", null);
            System.out.println("   Name exists checks: 'Pizza Dough'=" + nameExists1 + ", 'NonExistentItem12345'=" + nameExists2);
            
            System.out.println("   ✓ InventoryDAO tests completed\n");
            
        } catch (Exception e) {
            System.out.println("   ✗ InventoryDAO test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}