package util;

public class Config {
    // Gemini API Configuration
    // IMPORTANT: Replace with your actual API key
    // Get your key from: https://makersuite.google.com/app/apikey
    public static final String GEMINI_API_KEY = "AIzaSyBSHNvhaqiKnTS5nvoxAhNipdXBxiU52y8";
    
    // Enable/Disable Gemini AI
    // Set to false temporarily if hitting rate limits
    public static final boolean ENABLE_GEMINI = true; // Disabled due to rate limit
    
    // Restaurant Information
    public static final String RESTAURANT_NAME = "PizzaConnect";
    public static final String RESTAURANT_ADDRESS = "123 Pizza Street, District 1, Ho Chi Minh City";
    public static final String RESTAURANT_PHONE = "0909-000-001";
    public static final String RESTAURANT_EMAIL = "support@pizzaconnect.com";
    public static final String OPENING_HOURS = "10:00 AM - 10:00 PM (Daily)";
}
