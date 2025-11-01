package models;

import java.util.List;

public class Product {
    private int productId;
    private String productName;
    private String description;
    private String categoryName;     // ✅ chỉ lấy tên category
    private String imageUrl;
    private boolean isAvailable;
    private List<ProductSize> sizes; // ✅ chứa danh sách các size (ProductSize)

    public Product() {}

    public Product(int productId, String productName, String description,
                   String categoryName, String imageUrl, boolean isAvailable,
                   List<ProductSize> sizes) {
        this.productId = productId;
        this.productName = productName;
        this.description = description;
        this.categoryName = categoryName;
        this.imageUrl = imageUrl;
        this.isAvailable = isAvailable;
        this.sizes = sizes;
    }

    public Product(String productName, String description, String categoryName,
                   String imageUrl, boolean isAvailable) {
        this.productName = productName;
        this.description = description;
        this.categoryName = categoryName;
        this.imageUrl = imageUrl;
        this.isAvailable = isAvailable;
    }

    // Getters & Setters
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }

    public List<ProductSize> getSizes() { return sizes; }
    public void setSizes(List<ProductSize> sizes) { this.sizes = sizes; }

    @Override
    public String toString() {
        return "Product{" +
                "productId=" + productId +
                ", productName='" + productName + '\'' +
                ", description='" + description + '\'' +
                ", categoryName='" + categoryName + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                ", isAvailable=" + isAvailable +
                ", sizes=" + (sizes != null ? sizes.size() : 0) +
                '}';
    }
}
