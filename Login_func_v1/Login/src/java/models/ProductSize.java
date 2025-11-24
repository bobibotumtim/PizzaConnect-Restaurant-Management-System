package models;

public class ProductSize {
    private int productSizeId;
    private int productId; // chỉ cần ID thay vì Product object
    private String sizeCode;
    private double price;
    private double availableQuantity; // Available quantity from inventory

    public ProductSize() {}

    public ProductSize(int productSizeId, int productId, String sizeCode, double price) {
        this.productSizeId = productSizeId;
        this.productId = productId;
        this.sizeCode = sizeCode;
        this.price = price;
    }

    public ProductSize(int productId, String sizeCode, double price) {
        this.productId = productId;
        this.sizeCode = sizeCode;
        this.price = price;
    }

    // Getters & Setters
    public int getProductSizeId() { return productSizeId; }
    public void setProductSizeId(int productSizeId) { this.productSizeId = productSizeId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getSizeCode() { return sizeCode; }
    public void setSizeCode(String sizeCode) { this.sizeCode = sizeCode; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public double getAvailableQuantity() { return availableQuantity; }
    public void setAvailableQuantity(double availableQuantity) { this.availableQuantity = availableQuantity; }

    @Override
    public String toString() {
        return "ProductSize{" +
                "productSizeId=" + productSizeId +
                ", productId=" + productId +
                ", sizeCode='" + sizeCode + '\'' +
                ", price=" + price +
                ", availableQuantity=" + availableQuantity +
                '}';
    }
}
