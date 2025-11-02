package chatbot.models;

/**
 * Represents a quick reply button option
 */
public class QuickReply {
    
    private String text;
    private String action;
    
    public QuickReply() {
    }
    
    public QuickReply(String text, String action) {
        this.text = text;
        this.action = action;
    }
    
    // Getters and Setters
    
    public String getText() {
        return text;
    }
    
    public void setText(String text) {
        this.text = text;
    }
    
    public String getAction() {
        return action;
    }
    
    public void setAction(String action) {
        this.action = action;
    }
    
    @Override
    public String toString() {
        return String.format("QuickReply{text='%s', action='%s'}", text, action);
    }
}
