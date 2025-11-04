package controller;

import dao.InventoryDAO;
import models.Inventory;
import java.io.IOException;
import java.util.List;

public class InventoryServletSimple {
    private InventoryDAO dao = new InventoryDAO();

    public void doGet() throws IOException {
        try {
            // Simple test - just get inventory list
            List<Inventory> list = dao.getInventoriesByPage(1, 10);
            System.out.println("Inventory count: " + list.size());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}