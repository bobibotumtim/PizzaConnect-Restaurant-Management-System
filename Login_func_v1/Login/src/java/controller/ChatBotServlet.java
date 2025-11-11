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

        // ALL questions go to Gemini AI with full restaurant context
        return getGeminiResponseWithContext(message);
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

    private String getGeminiResponseWithContext(String userMessage) {
        System.out.println("=== getGeminiResponseWithContext called ===");
        System.out.println("User message: " + userMessage);
        
        try {
            // Check if Gemini is enabled
            if (!util.Config.ENABLE_GEMINI) {
                System.out.println("Gemini is DISABLED, returning default response");
                return getDefaultResponse();
            }

            System.out.println("Gemini is ENABLED, building context from database...");

            // Build rich context from database
            String context = buildRestaurantContext();

            // Call Gemini API
            System.out.println("Calling GeminiAPI with full context...");
            String geminiResponse = GeminiAPI.generateResponse(userMessage, context);

            if (geminiResponse != null && !geminiResponse.trim().isEmpty()) {
                System.out.println("Gemini returned valid response");
                return geminiResponse;
            } else {
                System.out.println("Gemini returned null/empty, using default response");
                return getDefaultResponse();
            }

        } catch (Exception e) {
            System.err.println("Exception in getGeminiResponseWithContext: " + e.getMessage());
            e.printStackTrace();
            return getDefaultResponse();
        }
    }
    
    private String buildRestaurantContext() {
        StringBuilder context = new StringBuilder();
        
        // Basic info
        context.append("You are a helpful assistant for PizzaConnect restaurant.\n\n");
        context.append("RESTAURANT INFO:\n");
        context.append("- Name: PizzaConnect\n");
        context.append("- Location: 123 Pizza Street, District 1, Ho Chi Minh City\n");
        context.append("- Phone: 0909-000-001\n");
        context.append("- Email: support@pizzaconnect.com\n");
        context.append("- Hours: 10:00 AM - 10:00 PM (Daily)\n");
        context.append("- Delivery: Free for orders above 200,000₫\n");
        context.append("- Payment: Cash, Credit/Debit Cards, Mobile Payment (Momo, ZaloPay)\n\n");
        
        // Get menu from database
        try {
            List<Product> products = productDAO.getAllBaseProducts();
            if (!products.isEmpty()) {
                context.append("CURRENT MENU:\n");
                
                Map<String, List<Product>> byCategory = new HashMap<>();
                for (Product p : products) {
                    if (p.isAvailable()) {
                        byCategory.computeIfAbsent(p.getCategoryName(), k -> new ArrayList<>()).add(p);
                    }
                }
                
                for (Map.Entry<String, List<Product>> entry : byCategory.entrySet()) {
                    context.append("\n").append(entry.getKey()).append(":\n");
                    for (Product p : entry.getValue()) {
                        List<ProductSize> sizes = sizeDAO.getSizesByProductId(p.getProductId());
                        context.append("- ").append(p.getProductName());
                        if (p.getDescription() != null) {
                            context.append(" (").append(p.getDescription()).append(")");
                        }
                        context.append(" - Sizes: ");
                        for (ProductSize size : sizes) {
                            context.append(size.getSizeCode()).append(" (")
                                   .append(currencyFormat.format(size.getPrice())).append("₫) ");
                        }
                        context.append("\n");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error building menu context: " + e.getMessage());
        }
        
        context.append("\nPROMOTIONS:\n");
        context.append("- First Order Special: 20% off\n");
        context.append("- Combo Deal: Large pizza + 2 drinks save 30,000₫\n");
        context.append("- Loyalty Program: Earn points with every purchase\n\n");
        
        context.append("INSTRUCTIONS:\n");
        context.append("- Answer in a friendly, helpful way\n");
        context.append("- Keep responses concise (2-4 sentences)\n");
        context.append("- Use the menu information above to answer questions\n");
        context.append("- Suggest products when appropriate\n");
        context.append("- Be helpful and encouraging\n");
        
        return context.toString();
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
