package chatbot.models;

import java.util.Date;

/**
 * Model representing a single chat message
 */
public class ChatMessage {
    
    private int conversationId;
    private String sessionId;
    private Integer userId;
    private String messageText;
    private boolean isUserMessage;
    private String intent;
    private String language;
    private Date createdAt;
    
    public ChatMessage() {
        this.createdAt = new Date();
    }
    
    public ChatMessage(String sessionId, String messageText, boolean isUserMessage) {
        this();
        this.sessionId = sessionId;
        this.messageText = messageText;
        this.isUserMessage = isUserMessage;
    }
    
    // Getters and Setters
    
    public int getConversationId() {
        return conversationId;
    }
    
    public void setConversationId(int conversationId) {
        this.conversationId = conversationId;
    }
    
    public String getSessionId() {
        return sessionId;
    }
    
    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }
    
    public Integer getUserId() {
        return userId;
    }
    
    public void setUserId(Integer userId) {
        this.userId = userId;
    }
    
    public String getMessageText() {
        return messageText;
    }
    
    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }
    
    public boolean isUserMessage() {
        return isUserMessage;
    }
    
    public void setUserMessage(boolean userMessage) {
        isUserMessage = userMessage;
    }
    
    public String getIntent() {
        return intent;
    }
    
    public void setIntent(String intent) {
        this.intent = intent;
    }
    
    public String getLanguage() {
        return language;
    }
    
    public void setLanguage(String language) {
        this.language = language;
    }
    
    public Date getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return String.format("ChatMessage{sessionId='%s', isUser=%b, text='%s', intent='%s'}", 
                sessionId, isUserMessage, messageText, intent);
    }
}
