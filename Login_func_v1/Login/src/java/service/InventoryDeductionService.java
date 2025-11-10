package service;

import dao.*;
import models.*;
import java.util.*;

/**
 * Service để xử lý trừ nguyên liệu khi chef hoàn thành món
 */
public class InventoryDeductionService {
    
    private InventoryDAO inventoryDAO;
    private ProductIngredientDAO productIngredientDAO;
    private OrderDetailToppingDAO orderDetailToppingDAO;
    
    public InventoryDeductionService() {
        this.inventoryDAO = new InventoryDAO();
        this.productIngredientDAO = new ProductIngredientDAO();
        this.orderDetailToppingDAO = new OrderDetailToppingDAO();
    }
    
    /**
     * Trừ nguyên liệu cho một OrderDetail khi chef hoàn thành món
     * @param orderDetail OrderDetail đã hoàn thành
     * @return true nếu trừ thành công, false nếu thất bại
     */
    public boolean deductIngredientsForOrderDetail(OrderDetail orderDetail) {
        try {
            // 1. Trừ nguyên liệu cho sản phẩm chính
            boolean productDeducted = deductProductIngredients(
                orderDetail.getProductSizeID(), 
                orderDetail.getQuantity()
            );
            
            if (!productDeducted) {
                System.err.println("❌ Không thể trừ nguyên liệu cho sản phẩm: " + orderDetail.getProductName());
                return false;
            }
            
            // 2. Trừ nguyên liệu cho toppings (nếu có)
            List<OrderDetailTopping> toppings = orderDetailToppingDAO.getToppingsByOrderDetailID(
                orderDetail.getOrderDetailID()
            );
            
            if (toppings != null && !toppings.isEmpty()) {
                for (OrderDetailTopping topping : toppings) {
                    boolean toppingDeducted = deductProductIngredients(
                        topping.getToppingID(),
                        orderDetail.getQuantity()
                    );
                    
                    if (!toppingDeducted) {
                        System.err.println("⚠️ Không thể trừ nguyên liệu cho topping: " + topping.getToppingName());
                    }
                }
            }
            
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi trừ nguyên liệu: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Trừ nguyên liệu cho một ProductSize
     * @param productSizeId ID của ProductSize
     * @param quantity Số lượng món
     * @return true nếu trừ thành công, false nếu thất bại
     */
    private boolean deductProductIngredients(int productSizeId, int quantity) {
        // Lấy danh sách nguyên liệu cần trừ
        Map<Integer, Double> ingredientsToDeduct = productIngredientDAO.getIngredientsToDeduct(
            productSizeId, 
            quantity
        );
        
        if (ingredientsToDeduct.isEmpty()) {
            return true; // Không có nguyên liệu thì coi như thành công
        }
        
        // Kiểm tra xem có đủ nguyên liệu không
        for (Map.Entry<Integer, Double> entry : ingredientsToDeduct.entrySet()) {
            int inventoryId = entry.getKey();
            double quantityNeeded = entry.getValue();
            
            if (!inventoryDAO.hasEnoughInventory(inventoryId, quantityNeeded)) {
                String itemName = inventoryDAO.getItemNameById(inventoryId);
                System.err.println("❌ Không đủ nguyên liệu: " + itemName + " (cần: " + quantityNeeded + ")");
                return false;
            }
        }
        
        // Trừ nguyên liệu
        for (Map.Entry<Integer, Double> entry : ingredientsToDeduct.entrySet()) {
            int inventoryId = entry.getKey();
            double quantityNeeded = entry.getValue();
            
            boolean deducted = inventoryDAO.deductInventory(inventoryId, quantityNeeded);
            if (!deducted) {
                String itemName = inventoryDAO.getItemNameById(inventoryId);
                System.err.println("❌ Không thể trừ nguyên liệu: " + itemName);
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Kiểm tra xem có đủ nguyên liệu để làm món không
     * @param orderDetail OrderDetail cần kiểm tra
     * @return true nếu đủ nguyên liệu, false nếu không đủ
     */
    public boolean checkIngredientsAvailability(OrderDetail orderDetail) {
        try {
            // 1. Kiểm tra nguyên liệu cho sản phẩm chính
            Map<Integer, Double> productIngredients = productIngredientDAO.getIngredientsToDeduct(
                orderDetail.getProductSizeID(), 
                orderDetail.getQuantity()
            );
            
            for (Map.Entry<Integer, Double> entry : productIngredients.entrySet()) {
                if (!inventoryDAO.hasEnoughInventory(entry.getKey(), entry.getValue())) {
                    return false;
                }
            }
            
            // 2. Kiểm tra nguyên liệu cho toppings
            List<OrderDetailTopping> toppings = orderDetailToppingDAO.getToppingsByOrderDetailID(
                orderDetail.getOrderDetailID()
            );
            
            if (toppings != null && !toppings.isEmpty()) {
                for (OrderDetailTopping topping : toppings) {
                    Map<Integer, Double> toppingIngredients = productIngredientDAO.getIngredientsToDeduct(
                        topping.getToppingID(), 
                        orderDetail.getQuantity()
                    );
                    
                    for (Map.Entry<Integer, Double> entry : toppingIngredients.entrySet()) {
                        if (!inventoryDAO.hasEnoughInventory(entry.getKey(), entry.getValue())) {
                            return false;
                        }
                    }
                }
            }
            
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi kiểm tra nguyên liệu: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
