package chatbot;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import chatbot.models.ChatContext;

/**
 * Centralized logging utility for chatbot components
 */
public class ChatbotLogger {
    
    private static final Logger logger = LogManager.getLogger("chatbot");
    private static final Logger analyticsLogger = LogManager.getLogger("chatbot.analytics");
    
    /**
     * Log an info message
     */
    public static void info(String message) {
        logger.info(message);
    }
    
    /**
     * Log an info message with context
     */
    public static void info(String message, ChatContext context) {
        logger.info(formatWithContext(message, context));
    }
    
    /**
     * Log a warning message
     */
    public static void warn(String message) {
        logger.warn(message);
    }
    
    /**
     * Log a warning message with exception
     */
    public static void warn(String message, Throwable t) {
        logger.warn(message, t);
    }
    
    /**
     * Log an error message
     */
    public static void error(String message) {
        logger.error(message);
    }
    
    /**
     * Log an error with exception
     */
    public static void error(String message, Throwable t) {
        logger.error(message, t);
    }
    
    /**
     * Log an error with context
     */
    public static void error(String context, Exception e, ChatContext chatContext) {
        String sessionId = chatContext != null ? chatContext.getSessionId() : "unknown";
        Integer userId = chatContext != null && chatContext.getUser() != null 
                ? chatContext.getUser().getUserID() : null;
        
        String errorMessage = String.format(
            "Chatbot Error - Context: %s, SessionID: %s, UserID: %s, Error: %s",
            context,
            sessionId,
            userId != null ? userId.toString() : "guest",
            e.getMessage()
        );
        
        logger.error(errorMessage, e);
    }
    
    /**
     * Log unrecognized intent for analysis
     */
    public static void logUnrecognizedIntent(String message, ChatContext context) {
        String sessionId = context != null ? context.getSessionId() : "unknown";
        Integer userId = context != null && context.getUser() != null 
                ? context.getUser().getUserID() : null;
        
        String logMessage = String.format(
            "Unrecognized Intent - SessionID: %s, UserID: %s, Message: %s",
            sessionId,
            userId != null ? userId.toString() : "guest",
            message
        );
        
        logger.warn(logMessage);
    }
    
    /**
     * Log analytics event
     */
    public static void logAnalytics(String eventType, String sessionId, Integer userId, String data) {
        String analyticsMessage = String.format(
            "%s|%s|%s|%s",
            eventType,
            sessionId,
            userId != null ? userId.toString() : "guest",
            data
        );
        
        analyticsLogger.info(analyticsMessage);
    }
    
    /**
     * Log session start
     */
    public static void logSessionStart(String sessionId, Integer userId, String initialIntent) {
        logAnalytics("SESSION_START", sessionId, userId, 
                String.format("intent=%s", initialIntent != null ? initialIntent : "none"));
    }
    
    /**
     * Log session end
     */
    public static void logSessionEnd(String sessionId, Integer userId, long durationSeconds, int messageCount) {
        logAnalytics("SESSION_END", sessionId, userId, 
                String.format("duration=%d,messages=%d", durationSeconds, messageCount));
    }
    
    /**
     * Log intent detection
     */
    public static void logIntent(String sessionId, Integer userId, String intent, double confidence) {
        logAnalytics("INTENT_DETECTED", sessionId, userId, 
                String.format("intent=%s,confidence=%.2f", intent, confidence));
    }
    
    /**
     * Log API call
     */
    public static void logApiCall(String sessionId, String apiName, long responseTimeMs, boolean success) {
        logAnalytics("API_CALL", sessionId, null, 
                String.format("api=%s,time=%d,success=%b", apiName, responseTimeMs, success));
    }
    
    /**
     * Format message with context information
     */
    private static String formatWithContext(String message, ChatContext context) {
        if (context == null) {
            return message;
        }
        
        String sessionId = context.getSessionId();
        Integer userId = context.getUser() != null ? context.getUser().getUserID() : null;
        
        return String.format("[SessionID: %s, UserID: %s] %s", 
                sessionId, 
                userId != null ? userId.toString() : "guest", 
                message);
    }
    
    /**
     * Log debug message (only in development)
     */
    public static void debug(String message) {
        logger.debug(message);
    }
    
    /**
     * Log debug message with context
     */
    public static void debug(String message, ChatContext context) {
        logger.debug(formatWithContext(message, context));
    }
}
