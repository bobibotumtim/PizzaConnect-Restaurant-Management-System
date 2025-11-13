# Implementation Plan - Customer Feedback After Payment

- [x] 1. Enhance CustomerFeedbackDAO with post-payment support

  - Add method `hasFeedbackForOrder(int orderId)` to check if feedback exists for an order
  - Add method `getFeedbackByOrderId(int orderId)` to retrieve existing feedback
  - Add method `insertPostPaymentFeedback(CustomerFeedback feedback)` with source tracking
  - Add method `canUpdateFeedback(int feedbackId, Timestamp submittedAt)` to check if feedback can be edited (within 24 hours)
  - _Requirements: 3.1, 3.2, 7.1, 7.4_

- [x] 2. Create Order/Bill helper methods for feedback context

  - Add method in OrderDAO or BillServlet to get order details by ID
  - Add method to get order items summary (pizza names) for display
  - Add method to get customer information from order
  - Handle both logged-in and guest customers
  - _Requirements: 3.4, 3.5, 6.2_

- [x] 3. Create FeedbackPromptServlet

  - Create new servlet class `FeedbackPromptServlet` with URL pattern `/feedback-prompt`
  - Implement `doGet()` to retrieve order details from request parameter
  - Check if feedback already exists for the order using `hasFeedbackForOrder()`
  - If feedback exists, redirect to home with message
  - If no feedback, forward to FeedbackPrompt.jsp with order context
  - Set order details as request attributes (orderId, items, total, date)
  - _Requirements: 1.1, 1.2, 7.1, 7.2_

- [x] 4. Create PostPaymentFeedbackServlet

  - Create new servlet class `PostPaymentFeedbackServlet` with URL pattern `/submit-feedback`
  - Implement `doPost()` to handle feedback submission
  - Validate required fields (orderId, rating)
  - Validate rating is between 1-5
  - Validate comment length (max 500 characters)
  - Create CustomerFeedback object with order context
  - Handle guest customers by generating guest ID: "GUEST\_" + orderId
  - Call `insertPostPaymentFeedback()` to save to database
  - Return JSON response or forward to confirmation page
  - _Requirements: 4.1, 4.2, 4.3, 6.1, 6.3_

- [x] 5. Enhance BillServlet to redirect to feedback prompt

  - Modify BillServlet's payment success flow
  - After successful payment, check if feedback prompt should be shown
  - Add method `shouldShowFeedbackPrompt(int orderId)` to check if feedback already exists
  - Redirect to `/feedback-prompt?orderId=X` instead of directly to home
  - Pass order context as request attributes or session
  - _Requirements: 1.1, 1.5_

- [x] 6. Create FeedbackPrompt.jsp

  - Create JSP page at `/view/FeedbackPrompt.jsp`
  - Display payment success message with checkmark icon
  - Show order summary (order ID, items, total amount)
  - Add prominent "Rate Your Experience" button linking to feedback form
  - Add "Skip for Now" link to home page
  - Add "Continue to Home" button
  - Implement auto-redirect to home after 10 seconds using JavaScript
  - Use responsive CSS for mobile compatibility
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 9.1, 9.3_

- [x] 7. Create FeedbackForm.jsp or modal component

  - Create feedback form interface (can be modal or separate page)
  - Implement 5-star rating component with hover and click effects
  - Add visual feedback for selected rating
  - Create textarea for comments with maxlength=500
  - Add real-time character counter showing remaining characters
  - Display prompt for detailed feedback when rating ≤ 3 stars
  - Add form validation before submission
  - Implement AJAX submission to PostPaymentFeedbackServlet
  - Show loading state during submission
  - Handle success and error responses
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 9.2, 9.4_

- [x] 8. Create FeedbackConfirmation.jsp

  - Create confirmation page at `/view/FeedbackConfirmation.jsp`
  - Display thank you message with success icon
  - Show different message for low ratings (1-2 stars) indicating priority review
  - Add "View Order History" button
  - Add "Return to Home" button
  - Implement auto-redirect to home after 5 seconds
  - Use responsive design
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 9. Implement duplicate feedback prevention

  - In FeedbackPromptServlet, check `hasFeedbackForOrder()` before showing form
  - If feedback exists, display message "You've already provided feedback for this order"
  - Provide link to view existing feedback
  - In PostPaymentFeedbackServlet, double-check before insertion
  - Allow feedback update within 24 hours using `canUpdateFeedback()`
  - Update existing feedback instead of creating duplicate
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 10. Add feedback source tracking

  - Add `source` column to `customer_feedback` table if not exists
  - Update `insertPostPaymentFeedback()` to set source = 'POST_PAYMENT'
  - Modify existing feedback insertion to set source = 'MANUAL' by default
  - Update manager dashboard to filter by source
  - _Requirements: 8.2, 10.5_

- [ ] 11. Integrate with manager feedback dashboard

  - Verify post-payment feedback appears in existing CustomerFeedbackServlet
  - Ensure feedback statistics include post-payment feedback
  - Test that managers can respond to post-payment feedback
  - Add source indicator in feedback list (e.g., badge showing "Post-Payment")
  - _Requirements: 8.1, 8.3, 8.4, 8.5_

- [ ] 12. Implement mobile-responsive CSS

  - Create or update CSS for feedback components
  - Ensure star rating buttons are minimum 44x44 pixels for touch
  - Test layout on mobile devices (320px - 768px width)
  - Ensure no horizontal scrolling required
  - Use minimum 16px font size for body text
  - Test on various devices and browsers
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 13. Add input validation and security

  - Sanitize all user input (rating, comments) in PostPaymentFeedbackServlet
  - Use prepared statements in DAO to prevent SQL injection
  - Escape output in JSP pages to prevent XSS
  - Verify order ID exists and belongs to customer (if logged in)
  - Implement rate limiting to prevent spam (optional)
  - _Requirements: 4.1, 4.2, 4.5_

- [ ] 14. Add error handling and user feedback

  - Handle missing rating error with clear message
  - Handle comment too long error with character count
  - Handle invalid order ID with redirect to home
  - Handle database save failure with retry option
  - Display appropriate error messages in UI
  - Log errors for debugging
  - _Requirements: 4.4, 4.5_

- [x] 15. Update web.xml with new servlet mappings

  - Add servlet definition for FeedbackPromptServlet
  - Add servlet mapping for `/feedback-prompt`
  - Add servlet definition for PostPaymentFeedbackServlet
  - Add servlet mapping for `/submit-feedback`
  - Ensure servlets are accessible without authentication for guest customers
  - _Requirements: 1.1, 4.3, 6.1_

- [ ] 16. Create database migration script (if needed)

  - Create SQL script to add `source` column to `customer_feedback` table
  - Add default value 'MANUAL' for existing records
  - Add index on `order_id` column for faster lookups
  - Test migration script on development database
  - _Requirements: 8.2, 10.5_

- [ ] 17. Test end-to-end feedback flow

  - Test complete flow: Payment → Prompt → Form → Submission → Confirmation
  - Test with logged-in customer
  - Test with guest customer
  - Test duplicate prevention
  - Test feedback update within 24 hours
  - Test error scenarios (invalid data, database errors)
  - Verify feedback appears in manager dashboard
  - _Requirements: All requirements_

- [ ] 18. Test mobile responsiveness

  - Test on mobile devices (iPhone, Android)
  - Test on tablets (iPad, Android tablets)
  - Test on desktop browsers (Chrome, Firefox, Safari, Edge)
  - Verify touch interactions work correctly
  - Verify auto-redirect works on all devices
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ]\* 19. Add feedback submission metrics tracking

  - Add logging for feedback submission events
  - Track time between payment and feedback submission
  - Calculate feedback submission rate
  - Add metrics to manager dashboard or analytics
  - _Requirements: 10.1, 10.2, 10.3, 10.4_

- [ ]\* 20. Create user documentation
  - Document the feedback flow for customers
  - Create guide for managers on reviewing post-payment feedback
  - Document configuration options (auto-redirect timing, etc.)
  - _Requirements: 5.2_
