package chatbot;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Configuration class for chatbot settings
 * Reads environment variables and .env file
 */
public class ChatbotConfig {
    
    private static final Map<String, String> config = new HashMap<>();
    private static boolean initialized = false;
    
    // Configuration keys
    public static final String GEMINI_API_KEY = "GEMINI_API_KEY";
    public static final String CHATBOT_ENABLED = "CHATBOT_ENABLED";
    public static final String CHATBOT_MAX_HISTORY = "CHATBOT_MAX_HISTORY";
    public static final String CHATBOT_SESSION_TIMEOUT = "CHATBOT_SESSION_TIMEOUT";
    public static final String CHATBOT_RESPONSE_CACHE_HOURS = "CHATBOT_RESPONSE_CACHE_HOURS";
    
    // Default values
    private static final String DEFAULT_MAX_HISTORY = "50";
    private static final String DEFAULT_SESSION_TIMEOUT = "1800";
    private static final String DEFAULT_CACHE_HOURS = "24";
    private static final String DEFAULT_ENABLED = "true";
    
    /**
     * Initialize configuration by loading from environment variables and .env file
     */
    public static synchronized void initialize() {
        if (initialized) {
            return;
        }
        
        // First, try to load from .env file
        loadFromEnvFile();
        
        // Then override with system environment variables if present
        loadFromSystemEnv();
        
        // Set defaults for missing values
        setDefaults();
        
        initialized = true;
    }
    
    /**
     * Load configuration from .env file
     */
    private static void loadFromEnvFile() {
        String envFilePath = ".env";
        try (BufferedReader reader = new BufferedReader(new FileReader(envFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // Skip comments and empty lines
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                
                // Parse key=value
                int equalsIndex = line.indexOf('=');
                if (equalsIndex > 0) {
                    String key = line.substring(0, equalsIndex).trim();
                    String value = line.substring(equalsIndex + 1).trim();
                    config.put(key, value);
                }
            }
        } catch (IOException e) {
            // .env file not found or not readable - this is okay, we'll use system env
            System.out.println("No .env file found, using system environment variables");
        }
    }
    
    /**
     * Load configuration from system environment variables
     */
    private static void loadFromSystemEnv() {
        // Override with system environment variables if they exist
        String apiKey = System.getenv(GEMINI_API_KEY);
        if (apiKey != null && !apiKey.isEmpty()) {
            config.put(GEMINI_API_KEY, apiKey);
        }
        
        String enabled = System.getenv(CHATBOT_ENABLED);
        if (enabled != null && !enabled.isEmpty()) {
            config.put(CHATBOT_ENABLED, enabled);
        }
        
        String maxHistory = System.getenv(CHATBOT_MAX_HISTORY);
        if (maxHistory != null && !maxHistory.isEmpty()) {
            config.put(CHATBOT_MAX_HISTORY, maxHistory);
        }
        
        String sessionTimeout = System.getenv(CHATBOT_SESSION_TIMEOUT);
        if (sessionTimeout != null && !sessionTimeout.isEmpty()) {
            config.put(CHATBOT_SESSION_TIMEOUT, sessionTimeout);
        }
        
        String cacheHours = System.getenv(CHATBOT_RESPONSE_CACHE_HOURS);
        if (cacheHours != null && !cacheHours.isEmpty()) {
            config.put(CHATBOT_RESPONSE_CACHE_HOURS, cacheHours);
        }
    }
    
    /**
     * Set default values for missing configuration
     */
    private static void setDefaults() {
        config.putIfAbsent(CHATBOT_ENABLED, DEFAULT_ENABLED);
        config.putIfAbsent(CHATBOT_MAX_HISTORY, DEFAULT_MAX_HISTORY);
        config.putIfAbsent(CHATBOT_SESSION_TIMEOUT, DEFAULT_SESSION_TIMEOUT);
        config.putIfAbsent(CHATBOT_RESPONSE_CACHE_HOURS, DEFAULT_CACHE_HOURS);
    }
    
    /**
     * Get configuration value by key
     */
    public static String get(String key) {
        if (!initialized) {
            initialize();
        }
        return config.get(key);
    }
    
    /**
     * Get configuration value with default
     */
    public static String get(String key, String defaultValue) {
        String value = get(key);
        return value != null ? value : defaultValue;
    }
    
    /**
     * Get integer configuration value
     */
    public static int getInt(String key, int defaultValue) {
        String value = get(key);
        if (value == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * Get boolean configuration value
     */
    public static boolean getBoolean(String key, boolean defaultValue) {
        String value = get(key);
        if (value == null) {
            return defaultValue;
        }
        return Boolean.parseBoolean(value);
    }
    
    /**
     * Check if chatbot is enabled
     */
    public static boolean isChatbotEnabled() {
        return getBoolean(CHATBOT_ENABLED, true);
    }
    
    /**
     * Get Gemini API key
     */
    public static String getGeminiApiKey() {
        return get(GEMINI_API_KEY);
    }
    
    /**
     * Get max conversation history size
     */
    public static int getMaxHistory() {
        return getInt(CHATBOT_MAX_HISTORY, 50);
    }
    
    /**
     * Get session timeout in seconds
     */
    public static int getSessionTimeout() {
        return getInt(CHATBOT_SESSION_TIMEOUT, 1800);
    }
    
    /**
     * Get response cache duration in hours
     */
    public static int getCacheHours() {
        return getInt(CHATBOT_RESPONSE_CACHE_HOURS, 24);
    }
}
