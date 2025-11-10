package controller;

import dao.MonitorDAO;
import models.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Servlet controller for Inventory Monitor Dashboard
 * Handles dashboard view and AJAX endpoints for real-time updates
 */
public class MonitorServlet {
    private MonitorDAO monitorDAO = new MonitorDAO();

    /**
     * Handle GET requests - simplified version for JSP forward
     */
    public void processRequest(Object req, Object resp) throws Exception {
        try {
            // Get dashboard data
            DashboardMetrics metrics = monitorDAO.getDashboardMetrics();
            List<AlertItem> alerts = monitorDAO.getAllAlerts();
            List<InventoryTrend> trends = monitorDAO.getInventoryTrends(0);
            List<CriticalItemStatus> criticalItems = monitorDAO.getCriticalItemsStatus();
            
            // In a real servlet, these would be set as request attributes
            // req.setAttribute("metrics", metrics);
            // req.setAttribute("alerts", alerts);
            // req.setAttribute("trends", trends);
            // req.setAttribute("criticalItems", criticalItems);
            
            System.out.println("Dashboard data loaded successfully:");
            System.out.println("- Total items: " + metrics.getTotalItems());
            System.out.println("- Alerts: " + alerts.size());
            System.out.println("- Trends: " + trends.size());
            System.out.println("- Critical items: " + criticalItems.size());
            
        } catch (Exception e) {
            System.err.println("Error in MonitorServlet: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
}