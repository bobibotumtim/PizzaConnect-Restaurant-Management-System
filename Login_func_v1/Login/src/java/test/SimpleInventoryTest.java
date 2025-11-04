package test;

import dao.InventoryDAO;
import models.Inventory;
import java.util.List;

/**
 * Simple test class to verify inventory functionality without servlet dependencies
 */
public class SimpleInventoryTest {
    
    public static void main(String[] args) {
        System.out.println("=== Simple Inventory Test ===\n");
        
        InventoryDAO dao = new InventoryDAO();
        
        try {
            // Test 1: Get total count
            int totalCount = dao.getTotalInventoryCount();
            System.out.println("1. Total inventory items: " + totalCount);
            
            // Test 2: Get items by page
            List<Inventory> items = dao.getInventoriesByPage(1, 5);
            System.out.println("2. First 5 items:");
            for (Inventory item : items) {
                System.out.println("   - " + item.getItemName() + " (" + item.getQuantity() + " " + item.getUnit() + ") - Status: " + item.getStatus());
            }
            
            // Test 3: Search functionality
            List<Inventory> searchResults = dao.getInventoriesByPage(1, 10, "flour", "all");
            System.out.println("3. Search results for 'flour': " + searchResults.size() + " items");
            
            // Test 4: Status filtering
            List<Inventory> activeItems = dao.getInventoriesByPage(1, 10, null, "active");
            System.out.println("4. Active items: " + activeItems.size() + " items");
            
            // Test 5: Get specific item
            if (!items.isEmpty()) {
                Inventory firstItem = dao.getById(items.get(0).getInventoryID());
                if (firstItem != null) {
                    System.out.println("5. Retrieved item by ID: " + firstItem.getItemName());
                }
            }
            
            System.out.println("\n✅ All tests completed successfully!");
            
        } catch (Exception e) {
            System.out.println("❌ Test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}