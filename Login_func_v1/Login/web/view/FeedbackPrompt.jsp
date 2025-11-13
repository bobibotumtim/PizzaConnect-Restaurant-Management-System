<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> <%@ taglib prefix="fmt"
uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Thanh toán thành công - Pizza Restaurant</title>
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
        text-align: center;
        animation: slideUp 0.5s ease-out;
      }

      @keyframes slideUp {
        from {
          opacity: 0;
          transform: translateY(30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .success-icon {
        width: 80px;
        height: 80px;
        background: #4caf50;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        animation: scaleIn 0.5s ease-out 0.2s both;
      }

      @keyframes scaleIn {
        from {
          transform: scale(0);
        }
        to {
          transform: scale(1);
        }
      }

      .success-icon::after {
        content: "✓";
        color: white;
        font-size: 50px;
        font-weight: bold;
      }

      h1 {
        color: #333;
        font-size: 28px;
        margin-bottom: 10px;
      }

      .subtitle {
        color: #666;
        font-size: 16px;
        margin-bottom: 30px;
      }

      .order-summary {
        background: #f8f9fa;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 30px;
        text-align: left;
      }

      .order-summary h3 {
        color: #333;
        font-size: 18px;
        margin-bottom: 15px;
        text-align: center;
      }

      .order-detail {
        display: flex;
        justify-content: space-between;
        padding: 10px 0;
        border-bottom: 1px solid #e0e0e0;
      }

      .order-detail:last-child {
        border-bottom: none;
      }

      .order-detail .label {
        color: #666;
        font-weight: 500;
      }

      .order-detail .value {
        color: #333;
        font-weight: 600;
      }

      .items-list {
        color: #555;
        font-size: 14px;
        line-height: 1.6;
        margin-top: 5px;
      }

      .feedback-prompt {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 25px;
        border-radius: 12px;
        margin-bottom: 20px;
      }

      .feedback-prompt h2 {
        font-size: 22px;
        margin-bottom: 10px;
      }

      .feedback-prompt p {
        font-size: 16px;
        opacity: 0.95;
      }

      .btn {
        display: inline-block;
        padding: 15px 40px;
        font-size: 16px;
        font-weight: 600;
        text-decoration: none;
        border-radius: 50px;
        transition: all 0.3s ease;
        cursor: pointer;
        border: none;
        margin: 10px;
        min-width: 200px;
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

      .btn-home {
        background: #6c757d;
        color: white;
      }

      .btn-home:hover {
        background: #5a6268;
        transform: translateY(-2px);
      }

      .auto-redirect {
        color: #999;
        font-size: 14px;
        margin-top: 20px;
      }

      .countdown {
        font-weight: 600;
        color: #667eea;
      }

      /* Mobile responsive */
      @media (max-width: 768px) {
        .container {
          padding: 30px 20px;
        }

        h1 {
          font-size: 24px;
        }

        .btn {
          width: 100%;
          margin: 10px 0;
        }

        .order-detail {
          flex-direction: column;
          gap: 5px;
        }
      }

      /* Touch-friendly buttons for mobile */
      @media (max-width: 768px) {
        .btn {
          min-height: 44px;
          padding: 12px 30px;
        }
      }
    </style>
  </head>
  <body>
    <div class="container">
      <!-- Success Icon -->
      <div class="success-icon"></div>

      <!-- Success Message -->
      <h1>Thanh toán thành công!</h1>
      <p class="subtitle">Cảm ơn bạn đã đặt hàng tại Pizza Restaurant</p>

      <!-- Order Summary -->
      <div class="order-summary">
        <h3>📋 Thông tin đơn hàng</h3>

        <div class="order-detail">
          <span class="label">Mã đơn hàng:</span>
          <span class="value">#${orderId}</span>
        </div>

        <div class="order-detail">
          <span class="label">Ngày đặt:</span>
          <span class="value">
            <fmt:formatDate value="${orderDate}" pattern="dd/MM/yyyy HH:mm" />
          </span>
        </div>

        <div class="order-detail">
          <span class="label">Món đã đặt:</span>
          <span class="value items-list">${itemsSummary}</span>
        </div>

        <div class="order-detail">
          <span class="label">Tổng tiền:</span>
          <span class="value">
            <fmt:formatNumber
              value="${totalPrice}"
              type="currency"
              currencySymbol="₫"
            />
          </span>
        </div>
      </div>

      <!-- Feedback Prompt -->
      <div class="feedback-prompt">
        <h2>⭐ Đánh giá trải nghiệm của bạn</h2>
        <p>Ý kiến của bạn giúp chúng tôi phục vụ tốt hơn!</p>
      </div>

      <!-- Action Buttons -->
      <div class="actions">
        <a
          href="${pageContext.request.contextPath}/feedback-form?orderId=${orderId}"
          class="btn btn-primary"
        >
          ⭐ Đánh giá ngay
        </a>

        <a
          href="${pageContext.request.contextPath}/home"
          class="btn btn-secondary"
        >
          Bỏ qua
        </a>

        <a href="${pageContext.request.contextPath}/home" class="btn btn-home">
          🏠 Về trang chủ
        </a>
      </div>

      <!-- Auto Redirect Message -->
      <p class="auto-redirect">
        Tự động chuyển về trang chủ sau
        <span class="countdown" id="countdown">10</span> giây
      </p>
    </div>

    <script>
      // Auto redirect after 10 seconds
      let countdown = 10;
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
    </script>
  </body>
</html>
