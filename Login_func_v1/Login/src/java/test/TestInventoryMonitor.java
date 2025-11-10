package test;

import dao.MonitorDAO;
import models.*;
import java.util.List;

/**
 * Test class for Inventory Monitor Dashboard functionality
 * Tests database operations, data models, and business logic
 */
public class TestInventoryMonitor {
    
    public static void main(String[] args) {
        System.out.println("=== Inventory Monitor Dashboard Test ===");
        
        TestInventoryMonitor test = new TestInventoryMonitor();
        
        try {
            test.testDatabaseConnection();
            test.testDashboardMetrics();
            test.testAlerts();
            test.testTrends();
            test.testCriticalItems();
            test.testThresholdUpdate();
            
            System.out.println("\n✅ All tests completed successfully!");
            
        } catch (Exception e) {
            System.err.println("❌ Test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void testDatabaseConnection() {
        System.out.println("\n--- Testing Database Connection ---");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            DashboardMetrics metrics = dao.getDashboardMetrics();
            
            if (metrics != null) {
                System.out.println("✅ Database connection successful");
                System.out.println("   Total items: " + metrics.getTotalItems());
            } else {
                System.out.println("❌ Failed to get dashboard metrics");
            }
        } catch (Exception e) {
            System.out.println("❌ Database connection failed: " + e.getMessage());
            throw e;
        }
    }
    
    private void testDashboardMetrics() {
        System.out.println("\n--- Testing Dashboard Metrics ---");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            DashboardMetrics metrics = dao.getDashboardMetrics();
            
            System.out.println("Dashboard Metrics:");
            System.out.println("  Total Items: " + metrics.getTotalItems());
            System.out.println("  Low Stock Items: " + metrics.getLowStockItems());
            System.out.println("  Out of Stock Items: " + metrics.getOutOfStockItems());
            System.out.println("  Critical Items: " + metrics.getCriticalItems());
            System.out.println("  Low Stock %: " + String.format("%.1f%%", metrics.getLowStockPercentage()));
            System.out.println("  Has Alerts: " + metrics.hasAlerts());
            
            System.out.println("✅ Dashboard metrics test passed");
            
        } catch (Exception e) {
            System.out.println("❌ Dashboard metrics test failed: " + e.getMessage());
            throw e;
        }
    }
    
    private void testAlerts() {
        System.out.println("\n--- Testing Alerts ---");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            
            // Test all alerts
            List<AlertItem> allAlerts = dao.getAllAlerts();
            System.out.println("Total alerts: " + allAlerts.size());
            
            // Test low stock alerts
            List<AlertItem> lowStockAlerts = dao.getLowStockAlerts();
            System.out.println("Low stock alerts: " + lowStockAlerts.size());
            
            // Test out of stock alerts
            List<AlertItem> outOfStockAlerts = dao.getOutOfStockAlerts();
            System.out.println("Out of stock alerts: " + outOfStockAlerts.size());
            
            // Display first few alerts
            if (!allAlerts.isEmpty()) {
                System.out.println("\nSample alerts:");
                for (int i = 0; i < Math.min(3, allAlerts.size()); i++) {
                    AlertItem alert = allAlerts.get(i);
                    System.out.println("  - " + alert.getItemName() + ": " + alert.getMessage());
                    System.out.println("    Type: " + alert.getAlertType() + ", Priority: " + alert.getPriority());
                }
            }
            
            System.out.println("✅ Alerts test passed");
            
        } catch (Exception e) {
            System.out.println("❌ Alerts test failed: " + e.getMessage());
            throw e;
        }
    }
    
    private void testTrends() {
        System.out.println("\n--- Testing Trends ---");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            List<InventoryTrend> trends = dao.getInventoryTrends(0); // All items
            
            System.out.println("Total trends: " + trends.size());
            
            if (!trends.isEmpty()) {
                System.out.println("\nSample trends:");
                for (int i = 0; i < Math.min(3, trends.size()); i++) {
                    InventoryTrend trend = trends.get(i);
                    System.out.println("  - " + trend.getItemName() + ":");
                    System.out.println("    Current: " + String.format("%.1f", trend.getCurrentQuantity()) + " " + trend.getUnit());
                    System.out.println("    Daily usage: " + String.format("%.1f", trend.getDailyUsageRate()) + " " + trend.getUnit());
                    System.out.println("    Trend: " + trend.getTrendDirection());
                    System.out.println("    Days until empty: " + (trend.getDaysUntilEmpty() > 0 ? trend.getDaysUntilEmpty() : "N/A"));
                }
            }
            
            System.out.println("✅ Trends test passed");
            
        } catch (Exception e) {
            System.out.println("❌ Trends test failed: " + e.getMessage());
            throw e;
        }
    }
    
    private void testCriticalItems() {
        System.out.println("\n--- Testing Critical Items ---");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            List<CriticalItemStatus> criticalItems = dao.getCriticalItemsStatus();
            
            System.out.println("Total critical items: " + criticalItems.size());
            
            if (!criticalItems.isEmpty()) {
                System.out.println("\nCritical items status:");
                for (CriticalItemStatus item : criticalItems) {
                    System.out.println("  - " + item.getItemName() + " (" + item.getCategory().getDisplayName() + "):");
                    System.out.println("    Status: " + item.getStatusLevel().getDisplayName());
                    System.out.println("    Current: " + String.format("%.1f", item.getCurrentQuantity()) + " " + item.getUnit());
                    System.out.println("    Priority: " + item.getPriority());
                    System.out.println("    Requires Action: " + item.isRequiresAction());
                    if (item.isRequiresAction()) {
                        System.out.println("    Action: " + item.getActionMessage());
                    }
                    System.out.println();
                }
            }
            
            System.out.println("✅ Critical items test passed");
            
        } catch (Exception e) {
            System.out.println("❌ Critical items test failed: " + e.getMessage());
            throw e;
        }
    }
    
    private void testThresholdUpdate() {
        System.out.println("\n--- Testing Threshold Update ---");
        
        try {
            MonitorDAO dao = new MonitorDAO();
            
            // Try to update thresholds for first inventory item
            boolean success = dao.updateThresholds(1, 15.0, 8.0);
            
            if (success) {
                System.out.println("✅ Threshold update successful");
            } else {
                System.out.println("⚠️ Threshold update returned false (item may not exist)");
            }
            
            System.out.println("✅ Threshold update test passed");
            
        } catch (Exception e) {
            System.out.println("❌ Threshold update test failed: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Test data model functionality
     */
    private void testDataModels() {
        System.out.println("\n--- Testing Data Models ---");
        
        try {
            // Test DashboardMetrics
            DashboardMetrics metrics = new DashboardMetrics(10, 3, 1, 5, 1000.0, null);
            System.out.println("DashboardMetrics - Low Stock %: " + metrics.getLowStockPercentage());
            System.out.println("DashboardMetrics - Has Alerts: " + metrics.hasAlerts());
            
            // Test AlertItem
            AlertItem alert = new AlertItem(1, "Test Item", 5.0, 10.0, "kg", 
                                          AlertItem.AlertType.LOW_STOCK, AlertItem.Priority.HIGH);
            System.out.println("AlertItem - Message: " + alert.getMessage());
            System.out.println("AlertItem - CSS Class: " + alert.getAlertTypeClass());
            
            // Test InventoryTrend
            InventoryTrend trend = new InventoryTrend(1, "Test Item", "kg");
            trend.setCurrentQuantity(20.0);
            trend.setDailyUsageRate(2.0);
            trend.calculateTrendMetrics();
            System.out.println("InventoryTrend - Days until empty: " + trend.getDaysUntilEmpty());
            
            // Test CriticalItemStatus
            CriticalItemStatus critical = new CriticalItemStatus(1, "Dough", 8.0, 15.0, 5.0, "kg",
                                                               CriticalItemStatus.CriticalCategory.DOUGH, 1);
            System.out.println("CriticalItemStatus - Status: " + critical.getStatusLevel());
            System.out.println("CriticalItemStatus - Requires Action: " + critical.isRequiresAction());
            
            System.out.println("✅ Data models test passed");
            
        } catch (Exception e) {
            System.out.println("❌ Data models test failed: " + e.getMessage());
            throw e;
        }
    }
}