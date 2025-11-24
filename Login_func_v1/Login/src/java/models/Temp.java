package models;

public class Temp {
    private int productSizeId;
    private int productId; // chỉ cần ID thay vì Product object
    private String sizeCode;
    private double price;
    private int quantity; // chỉ cần ID thay vì Product object

    public Temp(int productSizeId, int productId, String sizeCode, double price, int quantity) {
        this.productSizeId = productSizeId;
        this.productId = productId;
        this.sizeCode = sizeCode;
        this.price = price;
        this.quantity = quantity;
    }

    public Temp() {
    }

    public int getProductSizeId() {
        return productSizeId;
    }

    public void setProductSizeId(int productSizeId) {
        this.productSizeId = productSizeId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSizeCode() {
        return sizeCode;
    }

    public void setSizeCode(String sizeCode) {
        this.sizeCode = sizeCode;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    
}
