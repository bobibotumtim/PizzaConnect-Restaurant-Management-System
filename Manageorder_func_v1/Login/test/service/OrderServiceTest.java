package service;

import org.junit.Test;
import static org.junit.Assert.*;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import models.Order;
import dao.OrderDAO;
import org.junit.Before;

public class OrderServiceTest {

    private OrderService orderService;
    private FakeOrderDAO fakeOrderDAO;

    //==================================================================
    // LỚP GIẢ LẬP FAKEORDERDAO NẰM BÊN TRONG FILE TEST
    // Nó kế thừa OrderDAO để có cùng kiểu dữ liệu,
    // nhưng ghi đè (override) tất cả các phương thức để làm việc với HashMap,
    // không hề kết nối tới CSDL thật.
    //==================================================================
    static class FakeOrderDAO extends OrderDAO {
        Map<Integer, Order> database = new HashMap<>();

        // Constructor này ghi đè constructor của DBContext để không làm gì cả,
        // ngăn chặn việc kết nối CSDL.
        public FakeOrderDAO() {
            super(); 
        }

        @Override
        public Order getOrderById(int orderId) {
            return database.get(orderId);
        }

        @Override
        public List<Order> getAllOrders() {
            return new ArrayList<>(database.values());
        }

        @Override
        public boolean updateOrderStatus(int orderId, int status) {
            if (database.containsKey(orderId)) {
                database.get(orderId).setStatus(status);
                return true;
            }
            return false;
        }

        @Override
        public boolean updatePaymentStatus(int orderId, String paymentStatus) {
            if (database.containsKey(orderId)) {
                database.get(orderId).setPaymentStatus(paymentStatus);
                return true;
            }
            return false;
        }

        @Override
        public boolean deleteOrder(int orderId) {
            return database.remove(orderId) != null;
        }
    }
    //==================================================================
    // KẾT THÚC LỚP GIẢ LẬP
    //==================================================================


    @Before
    public void setUp() {
        // Trước mỗi test, tạo mới một DAO giả và một Service mới
        // để các test không ảnh hưởng lẫn nhau.
        fakeOrderDAO = new FakeOrderDAO();
        orderService = new OrderService(fakeOrderDAO); // Giả định OrderService có constructor này
    }

    @Test
    public void test1_processOrder_WhenOrderIsPending_ShouldUpdateStatusToProcessing() {
        // Arrange
        fakeOrderDAO.database.put(1, new Order(1, 1, "T03", new Date(), 0, 28.99, "Unpaid")); // Status 0 = Pending
        
        // Act
        boolean result = orderService.processOrder(1);

        // Assert
        assertTrue("Hàm phải trả về true khi xử lý thành công", result);
        assertEquals("Trạng thái đơn hàng phải là Processing (1)", 1, fakeOrderDAO.database.get(1).getStatus());
    }

    @Test
    public void test2_cancelOrder_WhenOrderIsAlreadyPaid_ShouldFail() {
        // Arrange
        fakeOrderDAO.database.put(2, new Order(2, 1, "T02", new Date(), 1, 32.98, "Paid"));
        
        // Act
        boolean result = orderService.cancelOrder(2);

        // Assert
        assertFalse("Không thể hủy đơn hàng đã thanh toán", result);
        assertEquals("Trạng thái đơn hàng không được thay đổi", 1, fakeOrderDAO.database.get(2).getStatus());
    }
    
    @Test
    public void test3_getOrdersByStatus_WhenFilteringForPending_ShouldReturnOnlyPendingOrders() {
        // Arrange
        fakeOrderDAO.database.put(1, new Order(1, 1, "T01", new Date(), 0, 10.0, "Unpaid")); // Pending
        fakeOrderDAO.database.put(2, new Order(2, 1, "T02", new Date(), 1, 20.0, "Paid"));   // Processing
        fakeOrderDAO.database.put(3, new Order(3, 1, "T03", new Date(), 0, 30.0, "Unpaid")); // Pending

        // Act
        List<Order> pendingOrders = orderService.getOrdersByStatus(0); // 0 = Pending

        // Assert
        assertEquals("Phải có đúng 2 đơn hàng Pending được tìm thấy", 2, pendingOrders.size());
        for (Order order : pendingOrders) {
            assertEquals(0, order.getStatus());
        }
    }
    
    @Test
    public void test4_deleteOrder_WhenOrderIsProcessing_ShouldFail() {
        // Arrange
        fakeOrderDAO.database.put(4, new Order(4, 1, "9", new Date(), 1, 25.97, "Paid")); // status 1 = Processing
        
        // Act
        boolean result = orderService.deleteOrder(4);

        // Assert
        assertFalse("Không được phép xóa đơn hàng đang xử lý", result);
        assertNotNull("Đơn hàng vẫn phải tồn tại trong CSDL giả", fakeOrderDAO.database.get(4));
    }
    
    @Test
    public void test5_markOrderAsPaid_ForNonExistentOrder_ShouldFail() {
        // Act
        boolean result = orderService.markOrderAsPaid(999); // ID không tồn tại

        // Assert
        assertFalse("Phải trả về false cho ID đơn hàng không tồn tại", result);
    }
}