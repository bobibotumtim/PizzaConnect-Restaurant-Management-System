package util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class GeminiAPI {
    
    // Gemini API endpoint
    // Using gemini-2.0-flash (stable version, not experimental)
    // API key is passed via header (x-goog-api-key or X-goog-api-key)
    private static final String API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
    
    public static String generateResponse(String userMessage, String context) {
        System.out.println("=== GeminiAPI.generateResponse called ===");
        System.out.println("User message: " + userMessage);
        System.out.println("API URL: " + API_URL);
        
        try {
            URL url = new URL(API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("X-goog-api-key", Config.GEMINI_API_KEY); // API key in header (capital X)
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000); // 10 seconds
            conn.setReadTimeout(10000);
            
            // Build prompt with context
            String prompt = buildPrompt(userMessage, context);
            System.out.println("Prompt built, length: " + prompt.length());
            
            // Build JSON request
            String jsonRequest = "{"
                + "\"contents\":[{"
                + "\"parts\":[{\"text\":\"" + escapeJson(prompt) + "\"}]"
                + "}]"
                + "}";
            
            System.out.println("Sending request to Gemini...");
            
            // Send request
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonRequest.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            // Read response
            int responseCode = conn.getResponseCode();
            System.out.println("Response code: " + responseCode);
            
            if (responseCode == 200) {
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();
                
                System.out.println("Raw response: " + response.toString().substring(0, Math.min(200, response.length())));
                
                // Parse response
                String parsed = parseGeminiResponse(response.toString());
                System.out.println("Parsed response: " + (parsed != null ? parsed.substring(0, Math.min(100, parsed.length())) : "null"));
                return parsed;
            } else {
                // Read error response
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
                StringBuilder errorResponse = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    errorResponse.append(line);
                }
                br.close();
                
                System.err.println("Gemini API error: " + responseCode);
                System.err.println("Error response: " + errorResponse.toString());
                return null;
            }
            
        } catch (Exception e) {
            System.err.println("Error calling Gemini API: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    private static String buildPrompt(String userMessage, String context) {
        return "You are a helpful assistant for PizzaConnect restaurant. "
            + "Answer the customer's question in a friendly and concise way. "
            + "Keep responses short (2-3 sentences max). "
            + "\n\nContext about our restaurant:\n" + context
            + "\n\nCustomer question: " + userMessage
            + "\n\nYour response:";
    }
    
    private static String parseGeminiResponse(String jsonResponse) {
        try {
            // Simple JSON parsing (extract text from response)
            int textStart = jsonResponse.indexOf("\"text\":");
            if (textStart == -1) return null;
            
            textStart = jsonResponse.indexOf("\"", textStart + 7) + 1;
            int textEnd = jsonResponse.indexOf("\"", textStart);
            
            if (textEnd == -1) return null;
            
            String text = jsonResponse.substring(textStart, textEnd);
            // Unescape JSON
            text = text.replace("\\n", "\n")
                       .replace("\\\"", "\"")
                       .replace("\\\\", "\\");
            
            return text;
            
        } catch (Exception e) {
            System.err.println("Error parsing Gemini response: " + e.getMessage());
            return null;
        }
    }
    
    private static String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
