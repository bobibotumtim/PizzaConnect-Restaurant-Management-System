# Design Document

## Overview

This design document outlines the architecture and implementation approach for the AI Chatbot Assistant feature in the PizzaConnect Restaurant Management System. The chatbot combines customer support and order assistance capabilities using Google Gemini API for natural language processing. The system follows the existing MVC architecture and integrates seamlessly with current database tables (User, Customer, Product, Order, Discount).

The chatbot will be implemented as a floating widget accessible on all customer-facing pages, with backend services handling conversation management, intent recognition, and integration with existing business logic.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer (JSP)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Home.jsp    │  │ Product.jsp  │  │  Other Pages │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                        │
│                   │  ChatWidget.jsp │                        │
│                   │  (Floating UI)  │                        │
│                   └────────┬────────┘                        │
└────────────────────────────┼──────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   chatbot.js    │
                    │  (Client Logic) │
                    └────────┬────────┘
                             │ AJAX/Fetch
┌────────────────────────────┼──────────────────────────────────┐
│                   Controller Layer                            │
│                   ┌────────▼────────┐                         │
│                   │ ChatbotServlet  │                         │
│                   └────────┬────────┘                         │
│                            │                                  │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                     Service Layer                             │
│  ┌──────────────────┬──────▼──────┬──────────────────┐       │
│  │                  │             │                   │       │
│  │  ChatService     │  IntentService  │  GeminiService│       │
│  │  (Conversation)  │  (Recognition)  │  (AI API)     │       │
│  └────────┬─────────┴──────┬──────┴──────┬───────────┘       │
│           │                │             │                    │
└───────────┼────────────────┼─────────────┼────────────────────┘
            │                │             │
┌───────────┼────────────────┼─────────────┼────────────────────┐
│           │      DAO Layer │             │                    │
│  ┌────────▼────────┐  ┌───▼──────┐  ┌───▼──────┐            │
│  │  ChatDAO        │  │ProductDAO│  │OrderDAO  │            │
│  │  (Messages)     │  │          │  │          │            │
│  └────────┬────────┘  └───┬──────┘  └───┬──────┘            │
│           │               │             │                    │
│  ┌────────▼───────────────▼─────────────▼──────┐            │
│  │         Existing DAOs (UserDAO, etc.)       │            │
│  └────────┬────────────────────────────────────┘            │
└───────────┼──────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────┐
│                     Database Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │   User   │  │ Customer │  │  Product │  │  Order   │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐      │
│  │ Discount │  │Inventory │  │  ChatConversation    │      │
│  └──────────┘  └──────────┘  │  (New Table)         │      │
│                               └──────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────┐
│                  External Services                            │
│                 ┌──────────────────┐                          │
│                 │  Google Gemini   │                          │
│                 │      API         │                          │
│                 └──────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

- **Client Layer**: Floating chat widget UI, message display, user input handling
- **Controller Layer**: HTTP request routing, session management, response formatting
- **Service Layer**: Business logic, AI integration, intent processing
- **DAO Layer**: Database operations, data persistence
- **External Services**: Google Gemini API for NLP

## Components and Interfaces

### 1. Frontend Components

#### ChatWidget.jsp (Floating UI Component)

**Purpose**: Provides the visual chat interface as a floating widget

**Key Elements**:
```html
<div id="chatbot-container" class="chatbot-minimized">
    <button id="chatbot-toggle" class="chatbot-button">
        <i class="chat-icon"></i>
    </button>
    
    <div id="chatbot-window" class="chatbot-window hidden">
        <div class="chatbot-header">
            <span>PizzaConnect Assistant</span>
            <div class="chatbot-controls">
                <button id="minimize-btn">−</button>
                <button id="close-btn">×</button>
            </div>
        </div>
        
        <div id="chatbot-messages" class="chatbot-messages">
            <!-- Messages rendered here -->
        </div>
        
        <div class="chatbot-input-area">
            <input type="text" id="chatbot-input" placeholder="Type your message...">
            <button id="send-btn">Send</button>
        </div>
    </div>
</div>
```

**Styling**: Tailwind CSS classes for consistency with existing UI

#### chatbot.js (Client-Side Logic)

**Purpose**: Handles user interactions, AJAX communication, message rendering

**Key Functions**:
```javascript
class ChatbotClient {
    constructor() {
        this.sessionId = this.generateSessionId();
        this.isOpen = false;
        this.messageHistory = [];
    }
    
    // Initialize chatbot and attach event listeners
    init() { }
    
    // Toggle chat window open/close
    toggleChat() { }
    
    // Send message to backend
    async sendMessage(message) { }
    
    // Render message in chat window
    renderMessage(message, isUser) { }
    
    // Display typing indicator
    showTypingIndicator() { }
    
    // Handle quick reply buttons
    handleQuickReply(action) { }
    
    // Persist conversation to localStorage
    saveConversation() { }
    
    // Restore conversation from localStorage
    loadConversation() { }
}
```

### 2. Backend Components

#### ChatbotServlet.java

**Purpose**: Main controller for handling chatbot requests

**Endpoints**:
```java
@WebServlet(name = "ChatbotServlet", urlPatterns = {"/chatbot"})
public class ChatbotServlet extends HttpServlet {
    
    private ChatService chatService;
    private IntentService intentService;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "sendMessage":
                handleSendMessage(request, response);
                break;
            case "getHistory":
                handleGetHistory(request, response);
                break;
            case "clearHistory":
                handleClearHistory(request, response);
                break;
            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
    
    private void handleSendMessage(HttpServletRequest request, HttpServletResponse response) {
        // 1. Extract message and session info
        // 2. Get user context (if logged in)
        // 3. Call ChatService to process message
        // 4. Return JSON response
    }
}
```

**Response Format**:
```json
{
    "success": true,
    "message": "AI response text",
    "intent": "menu_inquiry",
    "data": {
        "products": [...],
        "suggestions": [...]
    },
    "quickReplies": [
        {"text": "Show menu", "action": "show_menu"},
        {"text": "Check orders", "action": "check_orders"}
    ]
}
```

#### ChatService.java

**Purpose**: Core business logic for conversation management

**Key Methods**:
```java
public class ChatService {
    
    private GeminiService geminiService;
    private IntentService intentService;
    private ChatDAO chatDAO;
    
    // Process incoming message and generate response
    public ChatResponse processMessage(String message, ChatContext context) {
        // 1. Save user message to database
        // 2. Detect intent
        // 3. Fetch relevant data based on intent
        // 4. Build context for Gemini API
        // 5. Call Gemini API
        // 6. Post-process response
        // 7. Save assistant message
        // 8. Return ChatResponse
    }
    
    // Get conversation history
    public List<ChatMessage> getConversationHistory(String sessionId, int limit) { }
    
    // Clear conversation
    public void clearConversation(String sessionId) { }
    
    // Build context for AI prompt
    private String buildPromptContext(ChatContext context, String intent) { }
}
```

#### IntentService.java

**Purpose**: Recognize user intent from messages

**Intent Categories**:
- `menu_inquiry` - Questions about products, prices
- `order_status` - Check order status
- `loyalty_points` - Check/redeem points
- `discount_inquiry` - Ask about discounts
- `recommendation` - Request product suggestions
- `general_support` - General questions
- `greeting` - Hello, hi, etc.
- `unknown` - Cannot determine intent

**Key Methods**:
```java
public class IntentService {
    
    // Detect intent using keyword matching + Gemini
    public Intent detectIntent(String message, ChatContext context) {
        // 1. Check for keyword patterns (fast path)
        // 2. If ambiguous, use Gemini for classification
        // 3. Return Intent object with confidence score
    }
    
    // Extract entities from message (product names, order IDs, etc.)
    public Map<String, Object> extractEntities(String message, Intent intent) { }
}
```

#### GeminiService.java

**Purpose**: Interface with Google Gemini API

**Key Methods**:
```java
public class GeminiService {
    
    private static final String GEMINI_API_KEY = System.getenv("GEMINI_API_KEY");
    private static final String GEMINI_ENDPOINT = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent";
    
    // Generate response from Gemini
    public String generateResponse(String prompt, String language) {
        // 1. Build request payload
        // 2. Call Gemini API via HTTP
        // 3. Parse response
        // 4. Handle errors/timeouts
        // 5. Return generated text
    }
    
    // Classify intent using Gemini
    public String classifyIntent(String message) { }
    
    // Generate product recommendations
    public List<String> generateRecommendations(List<Product> orderHistory, List<Product> availableProducts) { }
}
```

**Prompt Template Example**:
```java
private String buildPrompt(String userMessage, ChatContext context) {
    return String.format("""
        You are a helpful restaurant assistant for PizzaConnect.
        
        Context:
        - Customer: %s
        - Language: %s
        - Previous orders: %s
        - Loyalty points: %d
        
        Available products:
        %s
        
        Customer message: "%s"
        
        Respond naturally and helpfully. If suggesting products, mention names and prices.
        Keep responses concise (2-3 sentences).
        """,
        context.getCustomerName(),
        context.getLanguage(),
        context.getOrderHistory(),
        context.getLoyaltyPoints(),
        context.getProductCatalog(),
        userMessage
    );
}
```

### 3. Data Access Layer

#### ChatDAO.java

**Purpose**: Manage chat conversation persistence

**Key Methods**:
```java
public class ChatDAO extends DBContext {
    
    // Save a chat message
    public boolean saveMessage(ChatMessage message) { }
    
    // Get conversation history
    public List<ChatMessage> getConversationHistory(String sessionId, int limit) { }
    
    // Clear conversation
    public boolean clearConversation(String sessionId) { }
    
    // Get active sessions count (for analytics)
    public int getActiveSessionsCount() { }
}
```

#### Enhanced Existing DAOs

**ProductDAO.java** - Add methods:
```java
// Get products by category with availability
public List<Product> getProductsByCategory(String category, boolean availableOnly) { }

// Search products by keyword
public List<Product> searchProducts(String keyword) { }

// Get popular products
public List<Product> getPopularProducts(int limit) { }
```

**OrderDAO.java** - Add methods:
```java
// Get customer's recent orders with details
public List<Order> getCustomerRecentOrders(int customerId, int limit) { }

// Get order with full details (items, products)
public OrderWithDetails getOrderDetails(int orderId) { }
```

**DiscountDAO.java** - Add methods:
```java
// Get active discounts
public List<Discount> getActiveDiscounts() { }

// Validate discount code
public Discount validateDiscountCode(String code) { }

// Get point-based discounts
public List<Discount> getPointDiscounts() { }
```

## Data Models

### New Database Table: ChatConversation

```sql
CREATE TABLE ChatConversation (
    ConversationID INT IDENTITY(1,1) PRIMARY KEY,
    SessionID NVARCHAR(100) NOT NULL,
    UserID INT NULL,  -- NULL if not logged in
    MessageText NVARCHAR(MAX) NOT NULL,
    IsUserMessage BIT NOT NULL,  -- 1 = user, 0 = assistant
    Intent NVARCHAR(50) NULL,
    Language NVARCHAR(10) DEFAULT 'vi',
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

CREATE INDEX IX_ChatConversation_SessionID ON ChatConversation(SessionID);
CREATE INDEX IX_ChatConversation_UserID ON ChatConversation(UserID);
CREATE INDEX IX_ChatConversation_CreatedAt ON ChatConversation(CreatedAt);
```

### Java Models

#### ChatMessage.java
```java
public class ChatMessage {
    private int conversationId;
    private String sessionId;
    private Integer userId;
    private String messageText;
    private boolean isUserMessage;
    private String intent;
    private String language;
    private Date createdAt;
    
    // Getters and setters
}
```

#### ChatContext.java
```java
public class ChatContext {
    private String sessionId;
    private User user;
    private Customer customer;
    private String language;
    private List<ChatMessage> messageHistory;
    private List<Order> recentOrders;
    private List<Product> availableProducts;
    
    // Getters and setters
}
```

#### ChatResponse.java
```java
public class ChatResponse {
    private boolean success;
    private String message;
    private String intent;
    private Map<String, Object> data;
    private List<QuickReply> quickReplies;
    private String error;
    
    // Getters and setters
}
```

#### Intent.java
```java
public class Intent {
    private String name;
    private double confidence;
    private Map<String, Object> entities;
    
    // Getters and setters
}
```

## Error Handling

### Error Scenarios and Responses

1. **Gemini API Unavailable**
   - Fallback to rule-based responses for common queries
   - Display: "I'm having trouble connecting to my AI brain. Let me help you with basic information..."

2. **Database Connection Failure**
   - Log error with stack trace
   - Display: "I'm having trouble accessing information right now. Please try again in a moment."

3. **Authentication Required**
   - Display: "To check your orders and points, please [log in](link). I can still help you with menu questions!"

4. **Intent Not Recognized**
   - Display: "I'm not sure I understand. Can you rephrase that? Or try one of these:"
   - Show quick reply buttons: [View Menu] [Check Orders] [Contact Support]

5. **API Timeout**
   - Implement 10-second timeout
   - Display: "That's taking longer than expected. Let me try a simpler approach..."

6. **Invalid Discount Code**
   - Display: "I couldn't find that discount code. Here are our current active promotions: [list]"

### Error Logging

```java
public class ChatbotLogger {
    private static final Logger logger = Logger.getLogger(ChatbotLogger.class.getName());
    
    public static void logError(String context, Exception e, ChatContext chatContext) {
        logger.severe(String.format(
            "Chatbot Error - Context: %s, SessionID: %s, UserID: %s, Error: %s",
            context,
            chatContext.getSessionId(),
            chatContext.getUser() != null ? chatContext.getUser().getUserID() : "guest",
            e.getMessage()
        ));
    }
    
    public static void logUnrecognizedIntent(String message, ChatContext context) {
        // Log for future training/improvement
    }
}
```

## Testing Strategy

### Unit Testing

1. **IntentService Tests**
   - Test intent detection for each category
   - Test entity extraction
   - Test ambiguous message handling

2. **GeminiService Tests**
   - Mock Gemini API responses
   - Test prompt building
   - Test error handling and timeouts

3. **ChatService Tests**
   - Test conversation flow
   - Test context building
   - Test response generation

4. **DAO Tests**
   - Test message persistence
   - Test conversation retrieval
   - Test data integrity

### Integration Testing

1. **End-to-End Conversation Flow**
   - User sends greeting → receives welcome message
   - User asks about menu → receives product list
   - User checks order status → receives order details
   - User asks for recommendations → receives personalized suggestions

2. **Authentication Flow**
   - Guest user → limited functionality
   - Logged-in user → full access to orders and points

3. **Multilingual Support**
   - Send Vietnamese message → receive Vietnamese response
   - Send English message → receive English response
   - Switch languages mid-conversation

4. **Error Recovery**
   - Simulate API failure → verify fallback behavior
   - Simulate database error → verify error message
   - Simulate timeout → verify retry logic

### Manual Testing Checklist

- [ ] Floating button appears on all customer pages
- [ ] Chat window opens/closes/minimizes correctly
- [ ] Conversation persists across page navigation
- [ ] Messages display correctly with proper formatting
- [ ] Typing indicator shows during processing
- [ ] Quick reply buttons work correctly
- [ ] Product information displays accurately
- [ ] Order status updates correctly
- [ ] Loyalty points display correctly
- [ ] Discount codes validate properly
- [ ] Language detection works
- [ ] Error messages display appropriately
- [ ] Performance meets < 2 second response time
- [ ] Mobile responsive design works

## Implementation Notes

### Gemini API Integration

**API Key Management**:
- Store API key in environment variable: `GEMINI_API_KEY`
- Never commit API key to version control
- Use `.env` file for local development

**Rate Limiting**:
- Gemini free tier: 60 requests per minute
- Implement request queuing if needed
- Cache common responses to reduce API calls

**Cost Optimization**:
- Use `gemini-pro` model (free tier available)
- Limit conversation context to last 10 messages
- Implement response caching for common queries
- Use rule-based responses for simple intents

### Security Considerations

1. **Input Sanitization**
   - Sanitize all user input before storing
   - Prevent SQL injection in DAO layer
   - Escape HTML in chat messages

2. **Session Management**
   - Use secure session IDs
   - Implement session timeout (30 minutes)
   - Clear sensitive data on logout

3. **API Security**
   - Never expose API key to client
   - Validate all requests on server side
   - Implement rate limiting per user

4. **Data Privacy**
   - Don't send passwords to Gemini API
   - Don't send payment information to Gemini API
   - Implement data retention policy (delete old conversations after 90 days)

### Performance Optimization

1. **Caching Strategy**
   - Cache product catalog (refresh every 5 minutes)
   - Cache active discounts (refresh every hour)
   - Cache common AI responses (24 hours)

2. **Database Optimization**
   - Index SessionID and UserID in ChatConversation table
   - Limit conversation history queries to last 50 messages
   - Archive old conversations to separate table

3. **Frontend Optimization**
   - Lazy load chat widget (don't load until first interaction)
   - Debounce typing indicator
   - Compress message payload

### Deployment Considerations

1. **Environment Variables**
   ```
   GEMINI_API_KEY=your_api_key_here
   CHATBOT_ENABLED=true
   CHATBOT_MAX_HISTORY=50
   CHATBOT_SESSION_TIMEOUT=1800
   ```

2. **Database Migration**
   - Run ChatConversation table creation script
   - Add indexes for performance
   - Set up automated cleanup job for old conversations

3. **Monitoring**
   - Track API response times
   - Monitor Gemini API usage and costs
   - Alert on error rate > 5%
   - Track user satisfaction (if feedback implemented)

## Alternative Approaches Considered

### 1. Rule-Based Only (No AI)
- ❌ Rejected: Limited flexibility, poor natural language understanding
- ✅ Kept as fallback when Gemini unavailable

### 2. OpenAI GPT Instead of Gemini
- ❌ Rejected: Higher cost, no free tier
- ⚠️ Could reconsider if Gemini performance insufficient

### 3. WebSocket for Real-Time Communication
- ❌ Rejected: Adds complexity, HTTP polling sufficient for chatbot use case
- ⚠️ Could implement later for real-time order status updates

### 4. Separate Microservice Architecture
- ❌ Rejected: Over-engineering for current scale
- ⚠️ Could refactor later if chatbot needs to scale independently

### 5. Client-Side AI (TensorFlow.js)
- ❌ Rejected: Limited model capabilities, poor performance on mobile
- ✅ Server-side AI provides better control and performance
