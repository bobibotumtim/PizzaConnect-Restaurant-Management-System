package controller;

import dao.ProductDAO;
import dao.ProductSizeDAO;
import models.Product;
import models.ProductSize;
import util.GeminiAPI;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.NumberFormat;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ChatBotServlet", urlPatterns = {"/chatbot"})
public class ChatBotServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private ProductSizeDAO sizeDAO = new ProductSizeDAO();
    private NumberFormat currencyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("view/ChatBot.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String userMessage = request.getParameter("message");
            System.out.println("Received message: " + userMessage);

            String botResponse = generateResponse(userMessage);
            System.out.println("Generated response: " + botResponse);

            // Simple JSON response without library
            String jsonResponse = "{\"response\":\"" + escapeJson(botResponse) + "\"}";
            System.out.println("JSON response: " + jsonResponse);

            PrintWriter out = response.getWriter();
            out.print(jsonResponse);
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            String errorJson = "{\"response\":\"Sorry, an error occurred: " + e.getMessage() + "\"}";
            PrintWriter out = response.getWriter();
            out.print(errorJson);
            out.flush();
        }
    }

    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        // Replace HTML breaks with newlines first
        text = text.replace("<br><br>", "\n\n").replace("<br>", "\n");
        // Remove HTML tags for now (simple approach)
        text = text.replaceAll("<strong>", "**").replaceAll("</strong>", "**");
        // Escape JSON special characters
        return text.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private String generateResponse(String message) {
        if (message == null || message.trim().isEmpty()) {
            return "I didn't catch that. Could you please repeat?";
        }

        String lowerMessage = message.toLowerCase().trim();

        // Menu queries
        if (lowerMessage.contains("menu") || lowerMessage.contains("show") && lowerMessage.contains("product")) {
            return getMenuResponse();
        }

        // Pizza queries
        if (lowerMessage.contains("pizza")) {
            return getPizzaResponse();
        }

        // Drink queries
        if (lowerMessage.contains("drink") || lowerMessage.contains("beverage")) {
            return getDrinkResponse();
        }

        // Price queries
        if (lowerMessage.contains("price") || lowerMessage.contains("cost") || lowerMessage.contains("how much")) {
            return getPriceResponse();
        }

        // Best seller queries
        if (lowerMessage.contains("best") || lowerMessage.contains("popular") || lowerMessage.contains("recommend")) {
            return getBestSellerResponse();
        }

        // Promotion queries
        if (lowerMessage.contains("promotion") || lowerMessage.contains("discount") || lowerMessage.contains("offer") || lowerMessage.contains("deal")) {
            return getPromotionResponse();
        }

        // Opening hours
        if (lowerMessage.contains("hour") || lowerMessage.contains("open") || lowerMessage.contains("close") || lowerMessage.contains("time")) {
            return "We're open daily from 10:00 AM to 10:00 PM. 🕐<br><br>You can visit us anytime during these hours or order online!";
        }

        // Location
        if (lowerMessage.contains("location") || lowerMessage.contains("address") || lowerMessage.contains("where")) {
            return "We're located at 123 Pizza Street, District 1, Ho Chi Minh City. 📍<br><br>You can also order online for delivery!";
        }

        // Order status
        if (lowerMessage.contains("order") && (lowerMessage.contains("status") || lowerMessage.contains("track"))) {
            return "To check your order status, please go to your profile page and view your order history. 📦<br><br>You can also contact our staff for assistance!";
        }

        // Contact
        if (lowerMessage.contains("contact") || lowerMessage.contains("phone") || lowerMessage.contains("call")) {
            return "You can reach us at:<br>📞 Phone: 0909-000-001<br>📧 Email: support@pizzaconnect.com<br><br>We're here to help!";
        }

        // Delivery
        if (lowerMessage.contains("deliver") || lowerMessage.contains("shipping")) {
            return "Yes, we offer delivery service! 🚚<br><br>Delivery is free for orders above 200,000₫. Standard delivery takes 30-45 minutes.";
        }

        // Payment
        if (lowerMessage.contains("payment") || lowerMessage.contains("pay")) {
            return "We accept multiple payment methods:<br>💵 Cash<br>💳 Credit/Debit Cards<br>📱 Mobile Payment (Momo, ZaloPay)<br><br>Choose what's convenient for you!";
        }

        // Greeting (check for standalone greetings, not words containing these)
        if (lowerMessage.matches(".*\\b(hello|hi|hey)\\b.*")) {
            return "Hello! 👋 Welcome to PizzaConnect! How can I help you today?";
        }

        // Thank you
        if (lowerMessage.contains("thank")) {
            return "You're welcome! 😊 Is there anything else I can help you with?";
        }

        // Fallback to Gemini AI for other questions
        return getGeminiResponse(message);
    }

    private String getMenuResponse() {
        try {
            List<Product> products = productDAO.getAllBaseProducts();
            if (products.isEmpty()) {
                return "Our menu is currently being updated. Please check back soon!";
            }

            StringBuilder response = new StringBuilder("Here's our menu: 📋<br><br>");

            Map<String, List<Product>> byCategory = new HashMap<>();
            for (Product p : products) {
                if (p.isAvailable()) {
                    byCategory.computeIfAbsent(p.getCategoryName(), k -> new ArrayList<>()).add(p);
                }
            }

            for (Map.Entry<String, List<Product>> entry : byCategory.entrySet()) {
                response.append("<strong>").append(entry.getKey()).append(":</strong><br>");
                for (Product p : entry.getValue()) {
                    List<ProductSize> sizes = sizeDAO.getSizesByProductId(p.getProductId());
                    if (!sizes.isEmpty()) {
                        double minPrice = sizes.get(0).getPrice();
                        for (ProductSize size : sizes) {
                            if (size.getPrice() < minPrice) {
                                minPrice = size.getPrice();
                            }
                        }
                        response.append("• ").append(p.getProductName())
                                .append(" - From ").append(currencyFormat.format(minPrice)).append("₫<br>");
                    }
                }
                response.append("<br>");
            }

            response.append("Would you like to know more about any specific item?");
            return response.toString();

        } catch (Exception e) {
            return "I'm having trouble accessing the menu right now. Please try again!";
        }
    }

    private String getPizzaResponse() {
        try {
            List<Product> products = productDAO.getAllBaseProducts();
            if (products.isEmpty()) {
                return "We don't have pizza available right now, but check back soon!";
            }

            StringBuilder response = new StringBuilder("Our delicious pizzas: 🍕<br><br>");
            for (Product p : products) {
                if (p.isAvailable() && p.getCategoryName().equalsIgnoreCase("Pizza")) {
                    List<ProductSize> sizes = sizeDAO.getSizesByProductId(p.getProductId());
                    response.append("<strong>").append(p.getProductName()).append("</strong><br>");
                    response.append(p.getDescription() != null ? p.getDescription() + "<br>" : "");
                    response.append("Sizes: ");
                    for (ProductSize size : sizes) {
                        response.append(size.getSizeCode()).append(" (")
                                .append(currencyFormat.format(size.getPrice())).append("₫) ");
                    }
                    response.append("<br><br>");
                }
            }

            response.append("All pizzas are made fresh with premium ingredients! 🧀");
            return response.toString();

        } catch (Exception e) {
            return "I'm having trouble getting pizza information. Please try again!";
        }
    }

    private String getDrinkResponse() {
        try {
            List<Product> products = productDAO.getAllBaseProducts();
            if (products.isEmpty()) {
                return "We're updating our drink menu. Please check back soon!";
            }

            StringBuilder response = new StringBuilder("Our refreshing drinks: 🥤<br><br>");
            for (Product p : products) {
                if (p.isAvailable() && p.getCategoryName().equalsIgnoreCase("Drink")) {
                    List<ProductSize> sizes = sizeDAO.getSizesByProductId(p.getProductId());
                    double price = sizes.isEmpty() ? 0 : sizes.get(0).getPrice();
                    response.append("• ").append(p.getProductName())
                            .append(" - ").append(currencyFormat.format(price)).append("₫<br>");
                }
            }

            response.append("<br>Perfect to pair with your pizza! 🍕");
            return response.toString();

        } catch (Exception e) {
            return "I'm having trouble getting drink information. Please try again!";
        }
    }

    private String getPriceResponse() {
        return "Our prices vary by product and size:<br><br>"
                + "🍕 <strong>Pizzas:</strong> 120,000₫ - 200,000₫<br>"
                + "🥤 <strong>Drinks:</strong> 25,000₫ - 30,000₫<br>"
                + "🧀 <strong>Toppings:</strong> 15,000₫ - 20,000₫<br><br>"
                + "Would you like to see the full menu with detailed prices?";
    }

    private String getBestSellerResponse() {
        return "Our best sellers are: ⭐<br><br>"
                + "🍕 <strong>Hawaiian Pizza</strong> - A classic favorite with ham and pineapple!<br>"
                + "Available in S (120,000₫), M (160,000₫), L (200,000₫)<br><br>"
                + "🥤 <strong>Iced Milk Coffee</strong> - Perfect refreshment! (25,000₫)<br><br>"
                + "These are loved by our customers! Would you like to order?";
    }

    private String getPromotionResponse() {
        return "Current promotions: 🎁<br><br>"
                + "🔥 <strong>First Order Special:</strong> Get 20% off your first order!<br>"
                + "🍕 <strong>Combo Deal:</strong> Buy any Large pizza + 2 drinks and save 30,000₫<br>"
                + "🎉 <strong>Loyalty Program:</strong> Earn points with every purchase!<br><br>"
                + "Don't miss out on these amazing deals!";
    }

    private String getGeminiResponse(String userMessage) {
        System.out.println("=== getGeminiResponse called ===");
        System.out.println("User message: " + userMessage);
        
        try {
            // Check if Gemini is enabled
            System.out.println("Checking if Gemini is enabled...");
            System.out.println("ENABLE_GEMINI = " + util.Config.ENABLE_GEMINI);
            
            if (!util.Config.ENABLE_GEMINI) {
                System.out.println("Gemini is DISABLED, returning default response");
                return getDefaultResponse();
            }

            System.out.println("Gemini is ENABLED, proceeding...");

            // Build context about restaurant
            String context = "PizzaConnect is a pizza restaurant. "
                    + "We serve pizzas (S: 120,000₫, M: 160,000₫, L: 200,000₫), "
                    + "drinks (25,000-30,000₫), and toppings (15,000-20,000₫). "
                    + "Open daily 10AM-10PM. Located at 123 Pizza Street, District 1, HCMC. "
                    + "We offer delivery (free over 200,000₫). "
                    + "Accept cash, cards, and mobile payment.";

            // Call Gemini API
            System.out.println("Calling GeminiAPI.generateResponse...");
            String geminiResponse = GeminiAPI.generateResponse(userMessage, context);

            if (geminiResponse != null && !geminiResponse.trim().isEmpty()) {
                System.out.println("Gemini returned valid response");
                return geminiResponse;
            } else {
                System.out.println("Gemini returned null/empty, using default response");
                return getDefaultResponse();
            }

        } catch (Exception e) {
            System.err.println("Exception in getGeminiResponse: " + e.getMessage());
            e.printStackTrace();
            return getDefaultResponse();
        }
    }

    private String getDefaultResponse() {
        return "I'm here to help! You can ask me about:\n"
                + "• Our menu and prices 📋\n"
                + "• Product recommendations ⭐\n"
                + "• Promotions and deals 🎁\n"
                + "• Opening hours and location 🕐\n"
                + "• Delivery and payment options 🚚\n\n"
                + "What would you like to know?";
    }
}
