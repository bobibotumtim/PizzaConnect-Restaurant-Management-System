<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Cảm ơn đánh giá - Pizza Restaurant</title>
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
        padding: 50px 40px;
        text-align: center;
        animation: zoomIn 0.5s ease-out;
      }

      @keyframes zoomIn {
        from {
          opacity: 0;
          transform: scale(0.8);
        }
        to {
          opacity: 1;
          transform: scale(1);
        }
      }

      .success-icon {
        width: 100px;
        height: 100px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 30px;
        animation: pulse 2s ease-in-out infinite;
      }

      @keyframes pulse {
        0%,
        100% {
          transform: scale(1);
          box-shadow: 0 0 0 0 rgba(102, 126, 234, 0.7);
        }
        50% {
          transform: scale(1.05);
          box-shadow: 0 0 0 20px rgba(102, 126, 234, 0);
        }
      }

      .success-icon::after {
        content: "✓";
        color: white;
        font-size: 60px;
        font-weight: bold;
      }

      h1 {
        color: #333;
        font-size: 32px;
        margin-bottom: 15px;
      }

      .subtitle {
        color: #666;
        font-size: 18px;
        line-height: 1.6;
        margin-bottom: 30px;
      }

      /* Rating Display */
      .rating-display {
        background: #f8f9fa;
        border-radius: 15px;
        padding: 25px;
        margin-bottom: 30px;
      }

      .rating-stars {
        font-size: 40px;
        color: #ffd700;
        margin-bottom: 10px;
        letter-spacing: 5px;
      }

      .rating-text {
        color: #666;
        font-size: 16px;
      }

      /* Low Rating Message */
      .low-rating-message {
        background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
        color: white;
        padding: 20px;
        border-radius: 15px;
        margin-bottom: 30px;
        display: none;
        animation: slideIn 0.5s ease-out;
      }

      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translateX(-20px);
        }
        to {
          opacity: 1;
          transform: translateX(0);
        }
      }

      .low-rating-message.show {
        display: block;
      }

      .low-rating-message h3 {
        font-size: 20px;
        margin-bottom: 10px;
      }

      .low-rating-message p {
        font-size: 15px;
        opacity: 0.95;
      }

      /* Thank You Message */
      .thank-you-box {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 25px;
        border-radius: 15px;
        margin-bottom: 30px;
      }

      .thank-you-box h2 {
        font-size: 24px;
        margin-bottom: 10px;
      }

      .thank-you-box p {
        font-size: 16px;
        opacity: 0.95;
        line-height: 1.6;
      }

      /* Action Buttons */
      .actions {
        display: flex;
        gap: 15px;
        margin-bottom: 30px;
      }

      .btn {
        flex: 1;
        padding: 15px 30px;
        font-size: 16px;
        font-weight: 600;
        text-decoration: none;
        border-radius: 50px;
        transition: all 0.3s ease;
        display: inline-block;
        min-height: 50px;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .btn-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
      }

      .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
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

      /* Auto Redirect */
      .auto-redirect {
        color: #999;
        font-size: 14px;
        margin-top: 20px;
      }

      .countdown {
        font-weight: 600;
        color: #667eea;
      }

      /* Decorative Elements */
      .confetti {
        position: fixed;
        width: 10px;
        height: 10px;
        background: #ffd700;
        position: absolute;
        animation: confetti-fall 3s linear;
      }

      @keyframes confetti-fall {
        to {
          transform: translateY(100vh) rotate(360deg);
          opacity: 0;
        }
      }

      /* Mobile Responsive */
      @media (max-width: 768px) {
        .container {
          padding: 40px 25px;
        }

        h1 {
          font-size: 26px;
        }

        .actions {
          flex-direction: column;
        }

        .btn {
          width: 100%;
        }

        .rating-stars {
          font-size: 35px;
        }
      }
    </style>
  </head>
  <body>
    <div class="container">
      <!-- Success Icon -->
      <div class="success-icon"></div>

      <!-- Main Heading -->
      <h1>🎉 Cảm ơn bạn!</h1>
      <p class="subtitle">
        Đánh giá của bạn đã được ghi nhận và sẽ giúp chúng tôi cải thiện dịch vụ
        tốt hơn.
      </p>

      <!-- Rating Display -->
      <div class="rating-display">
        <div class="rating-stars" id="ratingStars"></div>
        <p class="rating-text" id="ratingText"></p>
      </div>

      <!-- Low Rating Message (only show for 1-2 stars) -->
      <div class="low-rating-message" id="lowRatingMessage">
        <h3>⚠️ Chúng tôi rất tiếc!</h3>
        <p>
          Feedback của bạn đã được đánh dấu ưu tiên. Đội ngũ quản lý sẽ xem xét
          và liên hệ với bạn sớm nhất có thể.
        </p>
      </div>

      <!-- Thank You Box -->
      <div class="thank-you-box">
        <h2>💝 Cảm ơn bạn đã tin tưởng</h2>
        <p>
          Ý kiến của bạn rất quan trọng với chúng tôi. Chúng tôi cam kết không
          ngừng cải thiện để mang đến trải nghiệm tốt nhất!
        </p>
      </div>

      <!-- Action Buttons -->
      <div class="actions">
        <a
          href="${pageContext.request.contextPath}/order-history"
          class="btn btn-secondary"
        >
          📋 Xem lịch sử đơn hàng
        </a>
        <a
          href="${pageContext.request.contextPath}/home"
          class="btn btn-primary"
        >
          🏠 Về trang chủ
        </a>
      </div>

      <!-- Auto Redirect Message -->
      <p class="auto-redirect">
        Tự động chuyển về trang chủ sau
        <span class="countdown" id="countdown">5</span> giây
      </p>
    </div>

    <script>
      // Get rating from URL parameter
      const urlParams = new URLSearchParams(window.location.search);
      const rating = parseInt(urlParams.get("rating")) || 5;
      const orderId = urlParams.get("orderId");

      // Rating labels
      const ratingLabels = {
        1: "Rất không hài lòng",
        2: "Không hài lòng",
        3: "Bình thường",
        4: "Hài lòng",
        5: "Rất hài lòng",
      };

      // Display rating stars
      const ratingStars = document.getElementById("ratingStars");
      const ratingText = document.getElementById("ratingText");
      const lowRatingMessage = document.getElementById("lowRatingMessage");

      let starsHtml = "";
      for (let i = 1; i <= 5; i++) {
        starsHtml += i <= rating ? "★" : "☆";
      }
      ratingStars.innerHTML = starsHtml;
      ratingText.textContent = `${rating}/5 - ${ratingLabels[rating]}`;

      // Show low rating message for 1-2 stars
      if (rating <= 2) {
        lowRatingMessage.classList.add("show");
      }

      // Create confetti effect for high ratings (4-5 stars)
      if (rating >= 4) {
        createConfetti();
      }

      function createConfetti() {
        const colors = ["#ffd700", "#ff6b6b", "#4ecdc4", "#45b7d1", "#f7b731"];
        const confettiCount = 50;

        for (let i = 0; i < confettiCount; i++) {
          setTimeout(() => {
            const confetti = document.createElement("div");
            confetti.className = "confetti";
            confetti.style.left = Math.random() * 100 + "%";
            confetti.style.background =
              colors[Math.floor(Math.random() * colors.length)];
            confetti.style.animationDelay = Math.random() * 2 + "s";
            confetti.style.animationDuration = Math.random() * 2 + 2 + "s";
            document.body.appendChild(confetti);

            setTimeout(() => confetti.remove(), 5000);
          }, i * 30);
        }
      }

      // Auto redirect countdown
      let countdown = 5;
      const countdownElement = document.getElementById("countdown");

      const timer = setInterval(() => {
        countdown--;
        countdownElement.textContent = countdown;

        if (countdown <= 0) {
          clearInterval(timer);
          window.location.href = "${pageContext.request.contextPath}/home";
        }
      }, 1000);

      // Clear timer if user clicks any button
      document.querySelectorAll(".btn").forEach((btn) => {
        btn.addEventListener("click", () => {
          clearInterval(timer);
        });
      });

      // Log feedback submission for analytics (optional)
      console.log("Feedback submitted:", {
        orderId: orderId,
        rating: rating,
        timestamp: new Date().toISOString(),
      });
    </script>
  </body>
</html>
