package models;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;

import java.util.Date;

@DisplayName("Order Model Tests")
public class OrderTest {
    
    private Order order;
    private Date testDate;
    
    @BeforeEach
    void setUp() {
        testDate = new Date();
        order = new Order(
            1, // orderId
            2, // staffId
            "T01", // tableNumber
            testDate, // orderDate
            0, // status (Pending)
            45.99, // totalMoney
            "Unpaid", // paymentStatus
            "John Doe", // customerName
            "0901234567", // customerPhone
            "Extra cheese" // notes
        );
    }
    
    @Test
    @DisplayName("Should create order with all parameters")
    void testOrderCreationWithAllParameters() {
        // Given & When (in setUp)
        // Then
        assertEquals(1, order.getOrderId());
        assertEquals(2, order.getStaffId());
        assertEquals("T01", order.getTableNumber());
        assertEquals(testDate, order.getOrderDate());
        assertEquals(0, order.getStatus());
        assertEquals(45.99, order.getTotalMoney());
        assertEquals("Unpaid", order.getPaymentStatus());
        assertEquals("John Doe", order.getCustomerName());
        assertEquals("0901234567", order.getCustomerPhone());
        assertEquals("Extra cheese", order.getNotes());
    }
    
    @Test
    @DisplayName("Should create order with minimal parameters")
    void testOrderCreationWithMinimalParameters() {
        // Given
        Order minimalOrder = new Order(
            2, 3, "T02", testDate, 1, 25.50, "Paid"
        );
        
        // When & Then
        assertEquals(2, minimalOrder.getOrderId());
        assertEquals(3, minimalOrder.getStaffId());
        assertEquals("T02", minimalOrder.getTableNumber());
        assertEquals(1, minimalOrder.getStatus());
        assertEquals(25.50, minimalOrder.getTotalMoney());
        assertEquals("Paid", minimalOrder.getPaymentStatus());
    }
    
    @Test
    @DisplayName("Should return correct status text")
    void testGetStatusText() {
        // Test all status values
        assertEquals("Pending", order.getStatusText());
        
        order.setStatus(1);
        assertEquals("Processing", order.getStatusText());
        
        order.setStatus(2);
        assertEquals("Completed", order.getStatusText());
        
        order.setStatus(3);
        assertEquals("Cancelled", order.getStatusText());
        
        order.setStatus(999);
        assertEquals("Unknown", order.getStatusText());
    }
    
    @Test
    @DisplayName("Should set and get all properties correctly")
    void testSettersAndGetters() {
        // Given
        Order testOrder = new Order();
        
        // When
        testOrder.setOrderId(10);
        testOrder.setStaffId(5);
        testOrder.setTableNumber("T10");
        testOrder.setOrderDate(testDate);
        testOrder.setStatus(2);
        testOrder.setTotalMoney(99.99);
        testOrder.setPaymentStatus("Paid");
        testOrder.setCustomerName("Jane Smith");
        testOrder.setCustomerPhone("0909876543");
        testOrder.setNotes("No onions");
        
        // Then
        assertEquals(10, testOrder.getOrderId());
        assertEquals(5, testOrder.getStaffId());
        assertEquals("T10", testOrder.getTableNumber());
        assertEquals(testDate, testOrder.getOrderDate());
        assertEquals(2, testOrder.getStatus());
        assertEquals(99.99, testOrder.getTotalMoney());
        assertEquals("Paid", testOrder.getPaymentStatus());
        assertEquals("Jane Smith", testOrder.getCustomerName());
        assertEquals("0909876543", testOrder.getCustomerPhone());
        assertEquals("No onions", testOrder.getNotes());
    }
    
    @Test
    @DisplayName("Should return proper toString representation")
    void testToString() {
        // When
        String toString = order.toString();
        
        // Then
        assertNotNull(toString, "toString should not be null");
        assertTrue(toString.contains("Order{"), "toString should contain class name");
        assertTrue(toString.contains("orderId=1"), "toString should contain orderId");
        assertTrue(toString.contains("staffId=2"), "toString should contain staffId");
        assertTrue(toString.contains("tableNumber='T01'"), "toString should contain tableNumber");
        assertTrue(toString.contains("totalMoney=45.99"), "toString should contain totalMoney");
    }
    
    @Test
    @DisplayName("Should handle null values gracefully")
    void testNullValues() {
        // Given
        Order nullOrder = new Order();
        
        // When
        nullOrder.setTableNumber(null);
        nullOrder.setCustomerName(null);
        nullOrder.setCustomerPhone(null);
        nullOrder.setNotes(null);
        
        // Then
        assertNull(nullOrder.getTableNumber());
        assertNull(nullOrder.getCustomerName());
        assertNull(nullOrder.getCustomerPhone());
        assertNull(nullOrder.getNotes());
    }
}

