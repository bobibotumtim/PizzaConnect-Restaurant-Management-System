package models;

public class OrderDetail {
    private int orderDetailID;
    private int orderID;
    private int productSizeID;  // Thay đổi từ productID thành productSizeID
    private int quantity;
    private double totalPrice;
    private String specialInstructions;
    private int employeeID;     // Thêm employeeID cho chef assignment
    private String status;      // Thêm status cho từng món
    private java.sql.Timestamp startTime;  // Thêm startTime
    private java.sql.Timestamp endTime;    // Thêm endTime
    
    // Thông tin bổ sung để hiển thị (không lưu DB)
    private String productName;
    private String sizeName;
    private String sizeCode;
    private java.util.List<OrderDetailTopping> toppings; // Danh sách toppings

    public OrderDetail(int orderDetailID, int orderID, int productSizeID, int quantity, double totalPrice, String specialInstructions) {
        this.orderDetailID = orderDetailID;
        this.orderID = orderID;
        this.productSizeID = productSizeID;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        this.specialInstructions = specialInstructions;
    }
    
    // Constructor đầy đủ cho database mới
    public OrderDetail(int orderDetailID, int orderID, int productSizeID, int quantity, 
                      double totalPrice, String specialInstructions, int employeeID, 
                      String status, java.sql.Timestamp startTime, java.sql.Timestamp endTime) {
        this.orderDetailID = orderDetailID;
        this.orderID = orderID;
        this.productSizeID = productSizeID;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        this.specialInstructions = specialInstructions;
        this.employeeID = employeeID;
        this.status = status;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public OrderDetail() {
    }

    // Getters
    public int getOrderDetailID() { return orderDetailID; }
    public int getOrderID() { return orderID; }
    public int getProductSizeID() { return productSizeID; }  // Thay đổi
    public int getQuantity() { return quantity; }
    public double getTotalPrice() { return totalPrice; }
    public String getSpecialInstructions() { return specialInstructions; }
    public int getEmployeeID() { return employeeID; }
    public String getStatus() { return status; }
    public java.sql.Timestamp getStartTime() { return startTime; }
    public java.sql.Timestamp getEndTime() { return endTime; }
    public String getProductName() { return productName; }
    public String getSizeName() { return sizeName; }
    public String getSizeCode() { return sizeCode; }

    // Setters
    public void setOrderDetailID(int orderDetailID) { this.orderDetailID = orderDetailID; }
    public void setOrderID(int orderID) { this.orderID = orderID; }
    public void setProductSizeID(int productSizeID) { this.productSizeID = productSizeID; }  // Thay đổi
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }
    public void setEmployeeID(int employeeID) { this.employeeID = employeeID; }
    public void setStatus(String status) { this.status = status; }
    public void setStartTime(java.sql.Timestamp startTime) { this.startTime = startTime; }
    public void setEndTime(java.sql.Timestamp endTime) { this.endTime = endTime; }
    public void setProductName(String productName) { this.productName = productName; }
    public void setSizeName(String sizeName) { this.sizeName = sizeName; }
    public void setSizeCode(String sizeCode) { this.sizeCode = sizeCode; }
    
    // Backward compatibility - deprecated methods
    @Deprecated
    public int getProductID() { return productSizeID; }
    @Deprecated
    public void setProductID(int productID) { this.productSizeID = productID; }

    // Getter and Setter for toppings
    public java.util.List<OrderDetailTopping> getToppings() { return toppings; }
    public void setToppings(java.util.List<OrderDetailTopping> toppings) { this.toppings = toppings; }
    
    public String toString() {
        return "OrderDetail{" + 
               "orderDetailID=" + orderDetailID + 
               ", orderID=" + orderID + 
               ", productSizeID=" + productSizeID + 
               ", quantity=" + quantity + 
               ", totalPrice=" + totalPrice + 
               ", specialInstructions='" + specialInstructions + '\'' +
               ", employeeID=" + employeeID +
               ", status='" + status + '\'' +
               ", productName='" + productName + '\'' +
               ", sizeName='" + sizeName + '\'' +
               ", toppings=" + (toppings != null ? toppings.size() : 0) +
               '}';
    }
}
