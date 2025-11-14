<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.CustomerFeedback" %>
<%@ page import="dao.CustomerFeedbackDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Get orderId from URL parameter first
    String orderIdParam = request.getParameter("orderId");
    Integer orderIdAttr = (Integer) request.getAttribute("orderId");
    
    String orderIdStr = null;
    int orderId = 0;
    
    if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
        orderIdStr = orderIdParam;
        try {
            orderId = Integer.parseInt(orderIdParam);
        } catch (NumberFormatException e) {
            // Invalid order ID
        }
    } else if (orderIdAttr != null) {
        orderIdStr = orderIdAttr.toString();
        orderId = orderIdAttr;
    }
    
    // Check if feedback exists for this order
    boolean hasFeedback = false;
    CustomerFeedback existingFeedback = null;
    
    if (orderId > 0) {
        CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();
        hasFeedback = feedbackDAO.hasFeedbackForOrder(orderId);
        if (hasFeedback) {
            existingFeedback = feedbackDAO.getFeedbackByOrderId(orderId);
        }
    }
    
    boolean isViewMode = hasFeedback && existingFeedback != null;
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>
      <%= isViewMode ? "Xem đánh giá" : "Đánh giá đơn hàng" %> - Pizza
      Restaurant
    </title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
      }

      .container {
        background: white;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        max-width: 600px;
        width: 100%;
        padding: 40px;
        animation: fadeIn 0.5s ease-out;
      }

      @keyframes fadeIn {
        from {
          opacity: 0;
          transform: scale(0.95);
        }
        to {
          opacity: 1;
          transform: scale(1);
        }
      }

      h1 {
        color: #333;
        font-size: 28px;
        margin-bottom: 10px;
        text-align: center;
      }

      .subtitle {
        color: #666;
        font-size: 16px;
        margin-bottom: 30px;
        text-align: center;
      }

      .form-group {
        margin-bottom: 30px;
      }

      .form-label {
        display: block;
        color: #333;
        font-size: 16px;
        font-weight: 600;
        margin-bottom: 15px;
      }

      .required {
        color: #e74c3c;
      }

      /* Star Rating */
      .star-rating {
        display: flex;
        justify-content: center;
        gap: 10px;
        margin-bottom: 10px;
      }

      .star {
        font-size: 50px;
        color: #ddd;
        cursor: pointer;
        transition: all 0.2s ease;
        user-select: none;
      }

      .star:hover,
      .star.hover {
        color: #ffd700;
        transform: scale(1.2);
      }

      .star.selected {
        color: #ffd700;
      }

      .rating-text {
        text-align: center;
        color: #666;
        font-size: 18px;
        font-weight: 600;
        min-height: 30px;
        margin-top: 10px;
      }

      .rating-error {
        color: #e74c3c;
        font-size: 14px;
        text-align: center;
        margin-top: 10px;
        display: none;
      }

      /* Comment Section */
      .comment-wrapper {
        position: relative;
      }

      textarea {
        width: 100%;
        min-height: 120px;
        padding: 15px;
        border: 2px solid #e0e0e0;
        border-radius: 12px;
        font-size: 16px;
        font-family: inherit;
        resize: vertical;
        transition: border-color 0.3s ease;
      }

      textarea:focus {
        outline: none;
        border-color: #667eea;
      }

      .char-counter {
        text-align: right;
        color: #999;
        font-size: 14px;
        margin-top: 5px;
      }

      .char-counter.warning {
        color: #e74c3c;
      }

      /* Low Rating Prompt */
      .low-rating-prompt {
        background: #fff3cd;
        border: 2px solid #ffc107;
        border-radius: 12px;
        padding: 15px;
        margin-bottom: 20px;
        display: none;
        animation: slideDown 0.3s ease-out;
      }

      @keyframes slideDown {
        from {
          opacity: 0;
          transform: translateY(-10px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .low-rating-prompt p {
        color: #856404;
        font-size: 14px;
        margin: 0;
      }

      /* Buttons */
      .form-actions {
        display: flex;
        gap: 15px;
        margin-top: 30px;
      }

      .btn {
        flex: 1;
        padding: 15px;
        font-size: 16px;
        font-weight: 600;
        border: none;
        border-radius: 50px;
        cursor: pointer;
        transition: all 0.3s ease;
        min-height: 50px;
      }

      .btn-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
      }

      .btn-primary:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
      }

      .btn-primary:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }

      .btn-secondary {
        background: white;
        color: #667eea;
        border: 2px solid #667eea;
      }

      .btn-secondary:hover {
        background: #f8f9fa;
        transform: translateY(-2px);
      }

      /* Loading State */
      .loading {
        display: none;
        text-align: center;
        padding: 20px;
      }

      .loading.active {
        display: block;
      }

      .spinner {
        border: 4px solid #f3f3f3;
        border-top: 4px solid #667eea;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 0 auto;
      }

      @keyframes spin {
        0% {
          transform: rotate(0deg);
        }
        100% {
          transform: rotate(360deg);
        }
      }

      /* Success/Error Messages */
      .message {
        padding: 15px;
        border-radius: 12px;
        margin-bottom: 20px;
        display: none;
        animation: slideDown 0.3s ease-out;
      }

      .message.success {
        background: #d4edda;
        border: 2px solid #28a745;
        color: #155724;
      }

      .message.error {
        background: #f8d7da;
        border: 2px solid #dc3545;
        color: #721c24;
      }

      .message.active {
        display: block;
      }

      /* Mobile Responsive */
      @media (max-width: 768px) {
        .container {
          padding: 30px 20px;
        }

        h1 {
          font-size: 24px;
        }

        .star {
          font-size: 44px;
        }

        .form-actions {
          flex-direction: column;
        }

        .btn {
          width: 100%;
        }
      }
    </style>
  </head>
  <body>
    <div class="container">
      <% if (isViewMode && existingFeedback != null) { %>
        <!-- View Mode: Display Existing Feedback -->
        <h1>✅ Đánh giá của bạn</h1>
        <p class="subtitle">Đơn hàng #<%= orderIdStr %></p>

        <div class="form-group">
          <label class="form-label">Đánh giá của bạn:</label>
          <div class="star-rating">
            <% for (int i = 1; i <= 5; i++) { %>
              <span class="star <%= i <= existingFeedback.getRating() ? "selected" : "" %>">★</span>
            <% } %>
          </div>
          <div class="rating-text" style="display: block;">
            <%= existingFeedback.getRating() == 5 ? "😍 Rất hài lòng" :
                existingFeedback.getRating() == 4 ? "😊 Hài lòng" :
                existingFeedback.getRating() == 3 ? "😐 Bình thường" :
                existingFeedback.getRating() == 2 ? "😕 Không hài lòng" :
                "😞 Rất không hài lòng" %>
          </div>
        </div>

        <div class="message success active">
          <strong>Cảm ơn bạn đã đánh giá!</strong><br>
          Feedback của bạn đã được ghi nhận vào ngày <%= existingFeedback.getFeedbackDate() != null ? 
            new java.text.SimpleDateFormat("dd/MM/yyyy").format(existingFeedback.getFeedbackDate()) : "N/A" %>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/order-history'">
            ← Quay lại lịch sử đơn hàng
          </button>
        </div>

      <% } else { 
        // Check if orderId is still null or empty
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
      %>
        <!-- Error: No Order ID -->
        <h1>❌ Lỗi</h1>
        <div class="message error active">
          <strong>Order ID không được để trống</strong><br>
          Vui lòng quay lại trang Order History và thử lại.
        </div>
        <div class="form-actions">
          <button type="button" class="btn btn-primary" onclick="window.location.href='${pageContext.request.contextPath}/order-history'">
            ← Quay lại Order History
          </button>
        </div>
      <% } else { %>
        <!-- Submit Mode: Show Feedback Form -->
        <h1>⭐ Đánh giá trải nghiệm</h1>
        <p class="subtitle">Đơn hàng #<%= orderIdStr %></p>

        <!-- Success/Error Messages -->
        <div id="message" class="message"></div>

        <!-- Feedback Form -->
        <form id="feedbackForm">
        <input type="hidden" name="orderId" value="<%= orderIdStr %>" />
        <input type="hidden" name="productId" value="1" />
        <input type="hidden" id="ratingInput" name="rating" value="" />

        <!-- Star Rating -->
        <div class="form-group">
          <label class="form-label">
            Bạn đánh giá thế nào về trải nghiệm của mình?
            <span class="required">*</span>
          </label>

          <div class="star-rating" id="starRating">
            <span class="star" data-rating="1">★</span>
            <span class="star" data-rating="2">★</span>
            <span class="star" data-rating="3">★</span>
            <span class="star" data-rating="4">★</span>
            <span class="star" data-rating="5">★</span>
          </div>

          <div class="rating-text" id="ratingText"></div>
          <div class="rating-error" id="ratingError">
            Vui lòng chọn đánh giá
          </div>
        </div>

        <!-- Low Rating Prompt -->
        <div class="low-rating-prompt" id="lowRatingPrompt">
          <p>
            💬 Chúng tôi rất tiếc vì trải nghiệm của bạn chưa tốt. Vui lòng chia
            sẻ chi tiết để chúng tôi cải thiện!
          </p>
        </div>

        <!-- Comment -->
        <div class="form-group">
          <label class="form-label" for="comment">
            Nhận xét của bạn (tùy chọn)
          </label>

          <div class="comment-wrapper">
            <textarea
              id="comment"
              name="comment"
              placeholder="Chia sẻ trải nghiệm của bạn với chúng tôi..."
              maxlength="500"
            ></textarea>
            <div class="char-counter">
              <span id="charCount">0</span>/500 ký tự
            </div>
          </div>
        </div>

        <!-- Form Actions -->
        <div class="form-actions">
          <button
            type="button"
            class="btn btn-secondary"
            onclick="window.history.back()"
          >
            ← Quay lại
          </button>
          <button type="submit" class="btn btn-primary" id="submitBtn">
            Gửi đánh giá
          </button>
        </div>
      </form>

        <!-- Loading State -->
        <div class="loading" id="loading">
          <div class="spinner"></div>
          <p style="margin-top: 15px; color: #666">Đang gửi đánh giá...</p>
        </div>
      <% } // end else (has orderId)
      } // end else (submit mode) %>
    </div>

    <% if (!isViewMode && orderIdStr != null && !orderIdStr.trim().isEmpty()) { %>
    <script>
      // Star Rating Logic
      const stars = document.querySelectorAll(".star");
      const ratingInput = document.getElementById("ratingInput");
      const ratingText = document.getElementById("ratingText");
      const ratingError = document.getElementById("ratingError");
      const lowRatingPrompt = document.getElementById("lowRatingPrompt");
      let selectedRating = 0;

      const ratingLabels = {
        1: "😞 Rất không hài lòng",
        2: "😕 Không hài lòng",
        3: "😐 Bình thường",
        4: "😊 Hài lòng",
        5: "😍 Rất hài lòng",
      };

      stars.forEach((star) => {
        // Hover effect
        star.addEventListener("mouseenter", function () {
          const rating = parseInt(this.dataset.rating);
          highlightStars(rating);
        });

        // Click to select
        star.addEventListener("click", function () {
          selectedRating = parseInt(this.dataset.rating);
          ratingInput.value = selectedRating;
          selectStars(selectedRating);
          ratingText.textContent = ratingLabels[selectedRating];
          ratingError.style.display = "none";

          // Show prompt for low ratings
          if (selectedRating <= 3) {
            lowRatingPrompt.style.display = "block";
          } else {
            lowRatingPrompt.style.display = "none";
          }
        });
      });

      // Reset on mouse leave
      document
        .getElementById("starRating")
        .addEventListener("mouseleave", function () {
          if (selectedRating > 0) {
            highlightStars(selectedRating);
          } else {
            clearStars();
          }
        });

      function highlightStars(rating) {
        stars.forEach((star, index) => {
          if (index < rating) {
            star.classList.add("hover");
          } else {
            star.classList.remove("hover");
          }
        });
      }

      function selectStars(rating) {
        stars.forEach((star, index) => {
          if (index < rating) {
            star.classList.add("selected");
          } else {
            star.classList.remove("selected");
          }
        });
      }

      function clearStars() {
        stars.forEach((star) => {
          star.classList.remove("hover", "selected");
        });
      }

      // Character Counter
      const commentTextarea = document.getElementById("comment");
      const charCount = document.getElementById("charCount");
      const charCounter = document.querySelector(".char-counter");

      commentTextarea.addEventListener("input", function () {
        const length = this.value.length;
        charCount.textContent = length;

        if (length > 450) {
          charCounter.classList.add("warning");
        } else {
          charCounter.classList.remove("warning");
        }
      });

      // Form Submission
      const form = document.getElementById("feedbackForm");
      const submitBtn = document.getElementById("submitBtn");
      const loading = document.getElementById("loading");
      const messageDiv = document.getElementById("message");

      form.addEventListener("submit", async function (e) {
        e.preventDefault();

        // Validate rating
        if (!selectedRating || selectedRating < 1) {
          ratingError.style.display = "block";
          return;
        }

        // Show loading
        form.style.display = "none";
        loading.classList.add("active");

        try {
          // Submit via AJAX
          const formData = new FormData(form);
          const response = await fetch(
            "${pageContext.request.contextPath}/submit-feedback",
            {
              method: "POST",
              body: formData,
            }
          );

          const result = await response.json();

          // Hide loading
          loading.classList.remove("active");

          if (result.success) {
            // Show success message
            messageDiv.textContent = result.message;
            messageDiv.className = "message success active";

            // Redirect after 2 seconds
            const orderIdValue = document.querySelector('input[name="orderId"]').value;
            setTimeout(() => {
              window.location.href =
                "${pageContext.request.contextPath}/feedback-confirmation?orderId=" + orderIdValue + "&rating=" +
                selectedRating;
            }, 2000);
          } else {
            // Show error message
            messageDiv.textContent = result.message;
            messageDiv.className = "message error active";
            form.style.display = "block";
          }
        } catch (error) {
          console.error("Error:", error);
          loading.classList.remove("active");
          messageDiv.textContent = "Có lỗi xảy ra. Vui lòng thử lại.";
          messageDiv.className = "message error active";
          form.style.display = "block";
        }
      });
    </script>
    <% } %>
  </body>
</html>
