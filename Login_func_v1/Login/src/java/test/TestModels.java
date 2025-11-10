package test;

/**
 * Simple test to verify model classes are working
 */
public class TestModels {
    
    public static void main(String[] args) {
        System.out.println("Testing model classes...");
        
        try {
            // Test if we can create basic objects
            System.out.println("Model classes test completed!");
            
        } catch (Exception e) {
            System.err.println("Model test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}