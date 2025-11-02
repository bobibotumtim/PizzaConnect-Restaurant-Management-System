# Implementation Plan

- [x] 1. Set up project infrastructure and dependencies





  - Add Google Gemini API dependency to project (if using Maven/Gradle, add HTTP client library)
  - Create environment configuration for GEMINI_API_KEY
  - Set up logging configuration for chatbot components
  - Create package structure: `chatbot` (service, dao, models)
  - _Requirements: All requirements depend on proper setup_

- [x] 2. Create database schema and models



  - [x] 2.1 Create ChatConversation table in database


    - Write SQL script to create ChatConversation table with indexes
    - Add foreign key constraint to User table
    - Test table creation on development database
    - _Requirements: 8.1, 8.2, 12.1, 12.2_
  


  - [ ] 2.2 Create Java model classes
    - Create ChatMessage.java model with all fields and getters/setters
    - Create ChatContext.java model to hold conversation context
    - Create ChatResponse.java model for API responses





    - Create Intent.java model for intent classification
    - Create QuickReply.java model for quick reply buttons
    - _Requirements: 8.1, 8.2, 8.3_

- [x] 3. Implement Data Access Layer (DAO)


  - [ ] 3.1 Create ChatDAO.java
    - Implement saveMessage() method to persist chat messages
    - Implement getConversationHistory() method with limit parameter
    - Implement clearConversation() method
    - Implement getActiveSessionsCount() for analytics
    - _Requirements: 8.1, 8.2, 12.1_
  
  - [ ] 3.2 Enhance existing DAOs with chatbot-specific methods
    - Add getProductsByCategory() and searchProducts() to ProductDAO
    - Add getCustomerRecentOrders() and getOrderDetails() to OrderDAO
    - Add getActiveDiscounts() and validateDiscountCode() to DiscountDAO (create if not exists)
    - _Requirements: 2.1, 2.2, 3.1, 6.1_

- [ ] 4. Implement Gemini API integration
  - [ ] 4.1 Create GeminiService.java
    - Implement HTTP client for Gemini API calls
    - Create generateResponse() method with prompt and language parameters
    - Implement error handling and timeout (10 seconds)
    - Add retry logic for transient failures
    - _Requirements: 7.5, 10.3, 11.3_
  
  - [ ] 4.2 Create prompt templates
    - Design system prompt for restaurant assistant persona
    - Create context-building method that includes customer info, products, orders
    - Implement language-specific prompt formatting (Vietnamese/English)
    - Add safety filters to prevent inappropriate responses
    - _Requirements: 2.4, 5.2, 7.1, 7.2, 7.3_
  
  - [ ] 4.3 Implement response caching
    - Create cache for common queries (menu, hours, location)
    - Set cache expiration (24 hours for common responses)
    - Implement cache invalidation when product data changes
    - _Requirements: 11.1, 11.2_

- [ ] 5. Implement Intent Recognition Service
  - [ ] 5.1 Create IntentService.java
    - Implement keyword-based intent detection for fast path
    - Create intent classification using Gemini API for ambiguous cases
    - Implement entity extraction (product names, order IDs, discount codes)
    - Return Intent object with confidence score
    - _Requirements: 2.1, 3.1, 4.1, 5.1, 6.1_
  
  - [ ] 5.2 Define intent patterns and keywords
    - Create keyword mappings for each intent category
    - Define regex patterns for entity extraction (order IDs, prices)
    - Implement multilingual keyword support (Vietnamese + English)
    - _Requirements: 7.2, 7.3, 10.2_

- [ ] 6. Implement Core Chat Service
  - [ ] 6.1 Create ChatService.java
    - Implement processMessage() method as main entry point
    - Build conversation context from session and user data
    - Integrate IntentService for intent detection
    - Call appropriate handler based on detected intent
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [ ] 6.2 Implement intent handlers
    - Create handleMenuInquiry() to fetch and format product information
    - Create handleOrderStatus() to retrieve and display order details
    - Create handleLoyaltyPoints() to show points balance and redemption options
    - Create handleDiscountInquiry() to list and validate discount codes
    - Create handleRecommendation() to generate personalized suggestions
    - Create handleGeneralSupport() for fallback responses
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 4.1, 4.2, 5.1, 5.2, 6.1, 6.2, 6.3_
  
  - [ ] 6.3 Implement conversation context management
    - Load last 10 messages from database for context
    - Build context object with user info, products, orders, points
    - Pass context to Gemini API for coherent responses
    - Handle pronoun resolution ("that pizza", "the one you mentioned")
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 7. Implement ChatbotServlet controller
  - [ ] 7.1 Create ChatbotServlet.java
    - Set up servlet mapping for /chatbot endpoint
    - Implement doPost() method to handle actions (sendMessage, getHistory, clearHistory)
    - Extract session information and user context from HttpSession
    - Call ChatService to process messages
    - Return JSON responses with proper error handling
    - _Requirements: 9.1, 9.2, 9.3, 11.1_
  
  - [ ] 7.2 Implement authentication and authorization
    - Check user session for protected features (orders, points)
    - Return appropriate error for unauthenticated requests
    - Provide login link in response when authentication required
    - _Requirements: 9.1, 9.2, 9.3_
  
  - [ ] 7.3 Implement response formatting
    - Format ChatResponse as JSON with message, intent, data, quickReplies
    - Add quick reply buttons based on intent and context
    - Include error messages in standardized format
    - _Requirements: 10.1, 10.2, 10.4_

- [ ] 8. Create frontend chat widget UI
  - [ ] 8.1 Create ChatWidget.jsp component
    - Design floating chat button with icon
    - Create chat window with header, message area, input field
    - Add minimize, maximize, close controls
    - Style with Tailwind CSS for consistency
    - Make responsive for mobile devices
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [ ] 8.2 Implement chatbot.js client logic
    - Create ChatbotClient class with initialization
    - Implement toggleChat() to open/close window
    - Implement sendMessage() with AJAX/Fetch to backend
    - Implement renderMessage() to display messages in chat window
    - Add typing indicator during message processing
    - _Requirements: 1.1, 1.2, 1.3, 11.1_
  
  - [ ] 8.3 Implement conversation persistence
    - Save conversation to localStorage on each message
    - Load conversation from localStorage on page load
    - Restore conversation when navigating between pages
    - Clear localStorage on explicit user action
    - _Requirements: 1.4, 8.5_
  
  - [ ] 8.4 Implement quick reply buttons
    - Render quick reply buttons from server response
    - Handle button clicks to send predefined actions
    - Style buttons distinctly from regular messages
    - _Requirements: 10.4_

- [ ] 9. Integrate chat widget into existing pages
  - [ ] 9.1 Add ChatWidget.jsp to customer pages
    - Include ChatWidget.jsp in Home.jsp
    - Include ChatWidget.jsp in product listing pages
    - Include ChatWidget.jsp in order pages
    - Include ChatWidget.jsp in customer profile pages
    - _Requirements: 1.1, 1.4_
  
  - [ ] 9.2 Add chatbot.js script to pages
    - Include chatbot.js in page footer
    - Initialize ChatbotClient on page load
    - Ensure no conflicts with existing JavaScript
    - _Requirements: 1.1, 1.4_

- [ ] 10. Implement multilingual support
  - [ ] 10.1 Add language detection
    - Detect browser language preference on initialization
    - Detect language from user message content
    - Store language preference in session
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ] 10.2 Create language-specific responses
    - Create Vietnamese greeting and system messages
    - Create English greeting and system messages
    - Pass language parameter to Gemini API
    - Format responses in detected language
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

- [ ] 11. Implement error handling and fallbacks
  - [ ] 11.1 Add Gemini API error handling
    - Implement try-catch for API calls
    - Add fallback to rule-based responses when API unavailable
    - Display user-friendly error messages
    - Log errors for monitoring
    - _Requirements: 10.1, 10.3_
  
  - [ ] 11.2 Add database error handling
    - Implement try-catch for all DAO operations
    - Return appropriate error responses
    - Log database errors with context
    - _Requirements: 10.3_
  
  - [ ] 11.3 Implement unrecognized intent handling
    - Display clarifying questions when intent unclear
    - Show quick reply buttons with common actions
    - Log unrecognized messages for analysis
    - _Requirements: 10.2, 10.4, 12.3_

- [ ] 12. Implement analytics and monitoring
  - [ ] 12.1 Add session tracking
    - Log session start time and customer ID
    - Log session end time and duration
    - Track message count per session
    - _Requirements: 12.1, 12.2_
  
  - [ ] 12.2 Add intent tracking
    - Log detected intents with confidence scores
    - Track intent distribution
    - Log unrecognized intents for improvement
    - _Requirements: 12.3_
  
  - [ ] 12.3 Create analytics dashboard
    - Create servlet to display chatbot metrics
    - Show daily active users, average session duration
    - Display top intents and unrecognized queries
    - Add charts for visualization
    - _Requirements: 12.5_

- [ ] 13. Testing and quality assurance
  - [ ] 13.1 Write unit tests for services
    - Test IntentService intent detection with various inputs
    - Test ChatService message processing logic
    - Test GeminiService API integration with mocks
    - Test DAO methods for data persistence
    - _Requirements: All requirements_
  
  - [ ] 13.2 Perform integration testing
    - Test end-to-end conversation flows (greeting, menu inquiry, order status)
    - Test authentication flow (guest vs logged-in user)
    - Test multilingual support (Vietnamese and English)
    - Test error recovery scenarios
    - _Requirements: All requirements_
  
  - [ ] 13.3 Manual testing
    - Test floating button on all customer pages
    - Test chat window open/close/minimize
    - Test conversation persistence across navigation
    - Test message rendering and formatting
    - Test typing indicator
    - Test quick reply buttons
    - Test product information accuracy
    - Test order status updates
    - Test loyalty points display
    - Test discount code validation
    - Test language detection
    - Test error messages
    - Test performance (< 2 second response time)
    - Test mobile responsive design
    - _Requirements: All requirements_

- [ ] 14. Performance optimization
  - [ ] 14.1 Implement caching
    - Cache product catalog with 5-minute expiration
    - Cache active discounts with 1-hour expiration
    - Cache common AI responses with 24-hour expiration
    - _Requirements: 11.2, 11.4_
  
  - [ ] 14.2 Optimize database queries
    - Add indexes to ChatConversation table (SessionID, UserID, CreatedAt)
    - Limit conversation history queries to last 50 messages
    - Optimize product and order queries with proper joins
    - _Requirements: 11.2, 11.5_
  
  - [ ] 14.3 Implement lazy loading
    - Lazy load chat widget (don't load until first interaction)
    - Compress message payload
    - Debounce typing indicator
    - _Requirements: 11.1, 11.2_

- [ ] 15. Security hardening
  - [ ] 15.1 Implement input sanitization
    - Sanitize all user input before storing in database
    - Escape HTML in chat messages to prevent XSS
    - Validate session IDs and user IDs
    - _Requirements: 9.4_
  
  - [ ] 15.2 Secure API key management
    - Store GEMINI_API_KEY in environment variable
    - Never expose API key to client-side code
    - Add API key to .gitignore
    - _Requirements: 9.4_
  
  - [ ] 15.3 Implement rate limiting
    - Add rate limiting per user (max 30 messages per minute)
    - Add rate limiting for Gemini API calls
    - Return appropriate error when rate limit exceeded
    - _Requirements: 11.4_

- [ ] 16. Documentation and deployment
  - [ ] 16.1 Write deployment documentation
    - Document environment variables required
    - Document database migration steps
    - Document Gemini API setup and key generation
    - Create deployment checklist
    - _Requirements: All requirements_
  
  - [ ] 16.2 Create user documentation
    - Write user guide for chatbot features
    - Create FAQ for common issues
    - Document supported languages and capabilities
    - _Requirements: All requirements_
  
  - [ ] 16.3 Set up monitoring
    - Configure logging for production
    - Set up alerts for error rate > 5%
    - Monitor Gemini API usage and costs
    - Track response times
    - _Requirements: 12.1, 12.2, 12.3, 12.4_
