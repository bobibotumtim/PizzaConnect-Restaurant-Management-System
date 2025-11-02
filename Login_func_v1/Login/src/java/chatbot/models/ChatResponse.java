package chatbot.models;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Response object sent back to the client
 */
public class ChatResponse {
    
    private boolean success;
    private String message;
    private String intent;
    private Map<String, Object> data;
    private List<QuickReply> quickReplies;
    private String error;
    
    public ChatResponse() {
        this.data = new HashMap<>();
        this.quickReplies = new ArrayList<>();
        this.success = true;
    }
    
    public ChatResponse(boolean success, String message) {
        this();
        this.success = success;
        this.message = message;
    }
    
    // Static factory methods for common responses
    
    public static ChatResponse success(String message) {
        return new ChatResponse(true, message);
    }
    
    public static ChatResponse error(String errorMessage) {
        ChatResponse response = new ChatResponse(false, null);
        response.setError(errorMessage);
        return response;
    }
    
    // Getters and Setters
    
    public boolean isSuccess() {
        return success;
    }
    
    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public String getIntent() {
        return intent;
    }
    
    public void setIntent(String intent) {
        this.intent = intent;
    }
    
    public Map<String, Object> getData() {
        return data;
    }
    
    public void setData(Map<String, Object> data) {
        this.data = data;
    }
    
    public void addData(String key, Object value) {
        this.data.put(key, value);
    }
    
    public List<QuickReply> getQuickReplies() {
        return quickReplies;
    }
    
    public void setQuickReplies(List<QuickReply> quickReplies) {
        this.quickReplies = quickReplies;
    }
    
    public void addQuickReply(QuickReply quickReply) {
        this.quickReplies.add(quickReply);
    }
    
    public void addQuickReply(String text, String action) {
        this.quickReplies.add(new QuickReply(text, action));
    }
    
    public String getError() {
        return error;
    }
    
    public void setError(String error) {
        this.error = error;
        this.success = false;
    }
    
    @Override
    public String toString() {
        return String.format("ChatResponse{success=%b, message='%s', intent='%s', error='%s'}", 
                success, message, intent, error);
    }
}
