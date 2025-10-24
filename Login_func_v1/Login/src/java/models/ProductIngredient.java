package models;

public class ProductIngredient {
    private int productId;
    private int inventoryId;
    private double quantityNeeded;
    private String unit;
    private String itemName; // join từ Inventory để hiển thị

    public ProductIngredient() {}

    public ProductIngredient(int productId, int inventoryId, double quantityNeeded, String unit) {
        this.productId = productId;
        this.inventoryId = inventoryId;
        this.quantityNeeded = quantityNeeded;
        this.unit = unit;
    }

    // Getters & Setters
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getInventoryId() { return inventoryId; }
    public void setInventoryId(int inventoryId) { this.inventoryId = inventoryId; }

    public double getQuantityNeeded() { return quantityNeeded; }
    public void setQuantityNeeded(double quantityNeeded) { this.quantityNeeded = quantityNeeded; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
}
