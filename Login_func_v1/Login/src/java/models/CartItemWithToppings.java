package models;

import java.util.ArrayList;
import java.util.List;

/**
 * Helper class to store cart item with toppings during order processing
 */
public class CartItemWithToppings {
    private OrderDetail orderDetail;
    private List<OrderDetailTopping> toppings;
    
    public CartItemWithToppings() {
        this.toppings = new ArrayList<>();
    }
    
    public CartItemWithToppings(OrderDetail orderDetail) {
        this.orderDetail = orderDetail;
        this.toppings = new ArrayList<>();
    }
    
    public OrderDetail getOrderDetail() {
        return orderDetail;
    }
    
    public void setOrderDetail(OrderDetail orderDetail) {
        this.orderDetail = orderDetail;
    }
    
    public List<OrderDetailTopping> getToppings() {
        return toppings;
    }
    
    public void setToppings(List<OrderDetailTopping> toppings) {
        this.toppings = toppings;
    }
    
    public void addTopping(OrderDetailTopping topping) {
        this.toppings.add(topping);
    }
}
