package models;

import java.sql.Timestamp;
import java.util.List;

public class Order {

    private int orderID;
    private int customerID;
    private int employeeID;
    private int tableID;
    private Timestamp orderDate;
    private int status;
    private String paymentStatus;
    private double totalPrice;
    private String note;
    private List<OrderDetail> details;

//    public Order(int orderID, int customerID, int employeeID, int tableID,
//            Timestamp orderDate, int status, String paymentStatus,
//            double totalPrice, String note) {
//        this.orderID = orderID;
//        this.customerID = customerID;
//        this.employeeID = employeeID;
//        this.tableID = tableID;
//        this.orderDate = orderDate;
//        this.status = status;
//        this.paymentStatus = paymentStatus;
//        this.totalPrice = totalPrice;
//        this.note = note;
//    }
    
    public Order(int orderID, int customerID, int employeeID, int tableID,
             Timestamp orderDate, int status, String paymentStatus,
             double totalPrice, String note) {
    this.orderID = orderID;
    this.customerID = customerID;
    this.employeeID = employeeID;
    this.tableID = tableID;
    this.orderDate = orderDate;
    this.status = status;
    this.paymentStatus = paymentStatus;
    this.totalPrice = totalPrice;
    this.note = note;
    this.details = null; // không cần danh sách chi tiết ở đây
}

    

    public Order() {
    }

    public int getOrderID() {
        return orderID;
    }

    public int getCustomerID() {
        return customerID;
    }

    public int getEmployeeID() {
        return employeeID;
    }

    public int getTableID() {
        return tableID;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public int getStatus() {
        return status;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public String getNote() {
        return note;
    }

    public List<OrderDetail> getDetails() {
        return details;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public void setEmployeeID(int employeeID) {
        this.employeeID = employeeID;
    }

    public void setTableID(int tableID) {
        this.tableID = tableID;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public void setDetails(List<OrderDetail> details) {
        this.details = details;
    }

    // Helper methods for display
    public String getStatusText() {
        switch (status) {
            case 0: return "Pending";
            case 1: return "Processing";
            case 2: return "Completed";
            case 3: return "Cancelled";
            default: return "Unknown";
        }
    }
    
    public String getCustomerName() {
        // Use the database lookup method
        return getCustomerNameFromDB();
    }
    
    public String getCustomerNameFromDB() {
        // Lấy tên khách hàng từ database thật
        try {
            dao.DBContext db = new dao.DBContext();
            java.sql.Connection conn = db.getConnection();
            if (conn != null) {
                String sql = "SELECT CustomerName FROM Customer WHERE CustomerID = ?";
                try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, this.customerID);
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return rs.getString("CustomerName");
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error getting customer name: " + e.getMessage());
        }
        
        // Fallback nếu không lấy được từ database
        switch (customerID) {
            case 1: return "Nguyễn Văn A";
            case 2: return "Trần Thị B";
            case 3: return "Lê Văn C";
            default: return "Customer #" + customerID;
        }
    }
    
    public String getCustomerPhone() {
        // This would typically be fetched from CustomerDAO
        // For now, return null
        return null;
    }
    
    public String getTableNumber() {
        // This would typically be fetched from TableDAO
        // For now, return table ID as string
        return String.valueOf(tableID);
    }
    
    public double getTotalMoney() {
        return totalPrice;
    }

    @Override
    public String toString() {
        return "Order{" + "orderID=" + orderID + ", customerID=" + customerID + ", employeeID=" + employeeID + ", tableID=" + tableID + ", orderDate=" + orderDate + ", status=" + status + ", paymentStatus=" + paymentStatus + ", totalPrice=" + totalPrice + ", note=" + note + ", details=" + details + '}';
    }

}
