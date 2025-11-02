package chatbot.models;

import java.util.Map;
import java.util.HashMap;

/**
 * Represents a detected user intent
 */
public class Intent {
    
    // Intent types
    public static final String MENU_INQUIRY = "menu_inquiry";
    public static final String ORDER_STATUS = "order_status";
    public static final String LOYALTY_POINTS = "loyalty_points";
    public static final String DISCOUNT_INQUIRY = "discount_inquiry";
    public static final String RECOMMENDATION = "recommendation";
    public static final String GENERAL_SUPPORT = "general_support";
    public static final String GREETING = "greeting";
    public static final String UNKNOWN = "unknown";
    
    private String name;
    private double confidence;
    private Map<String, Object> entities;
    
    public Intent() {
        this.entities = new HashMap<>();
        this.confidence = 0.0;
    }
    
    public Intent(String name) {
        this();
        this.name = name;
    }
    
    public Intent(String name, double confidence) {
        this();
        this.name = name;
        this.confidence = confidence;
    }
    
    // Getters and Setters
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public double getConfidence() {
        return confidence;
    }
    
    public void setConfidence(double confidence) {
        this.confidence = confidence;
    }
    
    public Map<String, Object> getEntities() {
        return entities;
    }
    
    public void setEntities(Map<String, Object> entities) {
        this.entities = entities;
    }
    
    public void addEntity(String key, Object value) {
        this.entities.put(key, value);
    }
    
    public Object getEntity(String key) {
        return this.entities.get(key);
    }
    
    /**
     * Check if intent is recognized with sufficient confidence
     */
    public boolean isRecognized() {
        return !UNKNOWN.equals(name) && confidence > 0.5;
    }
    
    /**
     * Check if this is a specific intent type
     */
    public boolean is(String intentType) {
        return intentType != null && intentType.equals(name);
    }
    
    @Override
    public String toString() {
        return String.format("Intent{name='%s', confidence=%.2f, entities=%s}", 
                name, confidence, entities);
    }
}
