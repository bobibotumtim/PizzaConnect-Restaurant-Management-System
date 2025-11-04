package models;

public class ProductIngredient {
    private int productSizeId;
    private int inventoryId;
    private double quantityNeeded;
    private String unit;
    private String itemName; // từ Inventory (hiển thị thôi)

    public ProductIngredient() {}

    public ProductIngredient(int productSizeId, int inventoryId, double quantityNeeded, String unit) {
        this.productSizeId = productSizeId;
        this.inventoryId = inventoryId;
        this.quantityNeeded = quantityNeeded;
        this.unit = unit;
    }

    // Getters & Setters
    public int getProductSizeId() { return productSizeId; }
    public void setProductSizeId(int productSizeId) { this.productSizeId = productSizeId; }

    public int getInventoryId() { return inventoryId; }
    public void setInventoryId(int inventoryId) { this.inventoryId = inventoryId; }

    public double getQuantityNeeded() { return quantityNeeded; }
    public void setQuantityNeeded(double quantityNeeded) { this.quantityNeeded = quantityNeeded; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    @Override
    public String toString() {
        return "ProductIngredient{" +
                "productSizeId=" + productSizeId +
                ", inventoryId=" + inventoryId +
                ", quantityNeeded=" + quantityNeeded +
                ", unit='" + unit + '\'' +
                ", itemName='" + itemName + '\'' +
                '}';
    }
}
