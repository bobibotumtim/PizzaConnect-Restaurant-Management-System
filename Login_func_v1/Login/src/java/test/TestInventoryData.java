package test;

import dao.MonitorDAO;
import java.util.List;

public class TestInventoryData {
    public static void main(String[] args) {
        System.out.println("=== Testing Real Inventory Data ===");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            List<MonitorDAO.InventoryDisplayItem> items = dao.getAllInventoryForDisplay();
            
            System.out.println("Total items: " + items.size());
            
            for (MonitorDAO.InventoryDisplayItem item : items) {
                System.out.println("- " + item.getVietnameseName() + " (" + item.itemName + ")");
                System.out.println("  Category: " + item.getVietnameseCategory());
                System.out.println("  Quantity: " + item.quantity + " " + item.unit);
                System.out.println("  Status: " + item.getStatusText());
            }
            
            System.out.println("Test completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}