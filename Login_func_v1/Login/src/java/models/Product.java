package models;

/**
 * Product model for Pizza menu items
 * @author Admin
 */
public class Product {
    private int productId;
    private String productName;
    private String description;
    private double price;
    private String category;
    private String imageUrl;
    private boolean isAvailable;
    private int stockQuantity;

    public Product() {
    }

    public Product(int productId, String productName, String description, double price, String category, String imageUrl, boolean isAvailable, int stockQuantity) {
        this.productId = productId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.category = category;
        this.imageUrl = imageUrl;
        this.isAvailable = isAvailable;
        this.stockQuantity = stockQuantity;
    }

    // Getters
    public int getProductId() {
        return productId;
    }

    public String getProductName() {
        return productName;
    }

    public String getDescription() {
        return description;
    }

    public double getPrice() {
        return price;
    }

    public String getCategory() {
        return category;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    // Setters
    public void setProductId(int productId) {
        this.productId = productId;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public void setAvailable(boolean available) {
        isAvailable = available;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    @Override
    public String toString() {
        return "Product{" +
                "productId=" + productId +
                ", productName='" + productName + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", category='" + category + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                ", isAvailable=" + isAvailable +
                ", stockQuantity=" + stockQuantity + // Đã thêm stockQuantity
                '}';
    }
}