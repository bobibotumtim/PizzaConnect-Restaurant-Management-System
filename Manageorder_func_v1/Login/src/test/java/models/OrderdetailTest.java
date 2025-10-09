package models;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Orderdetail Model Tests")
public class OrderdetailTest {
    
    private Orderdetail orderdetail;
    
    @BeforeEach
    void setUp() {
        orderdetail = new Orderdetail(
            1, // orderDetailId
            2, // orderId
            3, // productId
            2, // quantity
            15.99, // unitPrice
            31.98, // totalPrice
            "Extra cheese" // specialInstructions
        );
    }
    
    @Test
    @DisplayName("Should create orderdetail with all parameters")
    void testOrderdetailCreationWithAllParameters() {
        // Given & When (in setUp)
        // Then
        assertEquals(1, orderdetail.getOrderDetailId());
        assertEquals(2, orderdetail.getOrderId());
        assertEquals(3, orderdetail.getProductId());
        assertEquals(2, orderdetail.getQuantity());
        assertEquals(15.99, orderdetail.getUnitPrice());
        assertEquals(31.98, orderdetail.getTotalPrice());
        assertEquals("Extra cheese", orderdetail.getSpecialInstructions());
    }
    
    @Test
    @DisplayName("Should create orderdetail with minimal parameters")
    void testOrderdetailCreationWithMinimalParameters() {
        // Given
        Orderdetail minimalOrderdetail = new Orderdetail(
            2, // orderId
            3, // productId
            1, // quantity
            12.99 // unitPrice
        );
        
        // When & Then
        assertEquals(2, minimalOrderdetail.getOrderId());
        assertEquals(3, minimalOrderdetail.getProductId());
        assertEquals(1, minimalOrderdetail.getQuantity());
        assertEquals(12.99, minimalOrderdetail.getUnitPrice());
        assertEquals(12.99, minimalOrderdetail.getTotalPrice()); // Should auto-calculate
    }
    
    @Test
    @DisplayName("Should auto-calculate total price when setting quantity")
    void testAutoCalculateTotalPriceOnQuantityChange() {
        // Given
        Orderdetail testOrderdetail = new Orderdetail(1, 2, 3, 1, 10.00, 10.00, "");
        
        // When
        testOrderdetail.setQuantity(3);
        
        // Then
        assertEquals(30.00, testOrderdetail.getTotalPrice(), 0.01, 
            "Total price should be auto-calculated as quantity * unitPrice");
    }
    
    @Test
    @DisplayName("Should auto-calculate total price when setting unit price")
    void testAutoCalculateTotalPriceOnUnitPriceChange() {
        // Given
        Orderdetail testOrderdetail = new Orderdetail(1, 2, 3, 2, 10.00, 20.00, "");
        
        // When
        testOrderdetail.setUnitPrice(15.00);
        
        // Then
        assertEquals(30.00, testOrderdetail.getTotalPrice(), 0.01, 
            "Total price should be auto-calculated as quantity * unitPrice");
    }
    
    @Test
    @DisplayName("Should set and get all properties correctly")
    void testSettersAndGetters() {
        // Given
        Orderdetail testOrderdetail = new Orderdetail();
        
        // When
        testOrderdetail.setOrderDetailId(10);
        testOrderdetail.setOrderId(20);
        testOrderdetail.setProductId(30);
        testOrderdetail.setQuantity(4);
        testOrderdetail.setUnitPrice(25.50);
        testOrderdetail.setTotalPrice(102.00);
        testOrderdetail.setSpecialInstructions("No onions");
        
        // Then
        assertEquals(10, testOrderdetail.getOrderDetailId());
        assertEquals(20, testOrderdetail.getOrderId());
        assertEquals(30, testOrderdetail.getProductId());
        assertEquals(4, testOrderdetail.getQuantity());
        assertEquals(25.50, testOrderdetail.getUnitPrice());
        assertEquals(102.00, testOrderdetail.getTotalPrice());
        assertEquals("No onions", testOrderdetail.getSpecialInstructions());
    }
    
    @Test
    @DisplayName("Should return proper toString representation")
    void testToString() {
        // When
        String toString = orderdetail.toString();
        
        // Then
        assertNotNull(toString, "toString should not be null");
        assertTrue(toString.contains("Orderdetail{"), "toString should contain class name");
        assertTrue(toString.contains("orderDetailId=1"), "toString should contain orderDetailId");
        assertTrue(toString.contains("orderId=2"), "toString should contain orderId");
        assertTrue(toString.contains("productId=3"), "toString should contain productId");
        assertTrue(toString.contains("quantity=2"), "toString should contain quantity");
        assertTrue(toString.contains("unitPrice=15.99"), "toString should contain unitPrice");
        assertTrue(toString.contains("totalPrice=31.98"), "toString should contain totalPrice");
        assertTrue(toString.contains("specialInstructions='Extra cheese'"), 
            "toString should contain specialInstructions");
    }
    
    @Test
    @DisplayName("Should handle null special instructions")
    void testNullSpecialInstructions() {
        // Given
        Orderdetail testOrderdetail = new Orderdetail();
        
        // When
        testOrderdetail.setSpecialInstructions(null);
        
        // Then
        assertNull(testOrderdetail.getSpecialInstructions());
    }
    
    @Test
    @DisplayName("Should handle zero quantity")
    void testZeroQuantity() {
        // Given
        Orderdetail testOrderdetail = new Orderdetail(1, 2, 3, 0, 10.00, 0.00, "");
        
        // When
        testOrderdetail.setQuantity(0);
        
        // Then
        assertEquals(0, testOrderdetail.getQuantity());
        assertEquals(0.00, testOrderdetail.getTotalPrice(), 0.01);
    }
    
    @Test
    @DisplayName("Should handle negative values gracefully")
    void testNegativeValues() {
        // Given
        Orderdetail testOrderdetail = new Orderdetail();
        
        // When
        testOrderdetail.setQuantity(-1);
        testOrderdetail.setUnitPrice(-10.00);
        
        // Then
        assertEquals(-1, testOrderdetail.getQuantity());
        assertEquals(-10.00, testOrderdetail.getUnitPrice());
        assertEquals(10.00, testOrderdetail.getTotalPrice(), 0.01); // Should auto-calculate
    }
}

