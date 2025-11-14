<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ page
import="dao.CustomerFeedbackDAO" %> <% String orderIdParam =
request.getParameter("orderId"); int orderId = 0; boolean validOrderId = false;
if (orderIdParam != null && !orderIdParam.trim().isEmpty()) { try { orderId =
Integer.parseInt(orderIdParam); validOrderId = true; } catch
(NumberFormatException e) { validOrderId = false; } } %>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đánh giá đơn hàng</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        max-width: 600px;
        margin: 50px auto;
        padding: 20px;
        background: #f5f5f5;
      }
      .container {
        background: white;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      }
      .error {
        background: #fee;
        border: 1px solid #fcc;
        color: #c00;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
      }
      .success {
        background: #efe;
        border: 1px solid #cfc;
        color: #0c0;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
      }
      .stars {
        font-size: 40px;
        margin: 20px 0;
      }
      .star {
        cursor: pointer;
        color: #ddd;
      }
      .star.selected {
        color: #ffd700;
      }
      textarea {
        width: 100%;
        min-height: 100px;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
        margin: 10px 0;
      }
      button {
        background: #667eea;
        color: white;
        border: none;
        padding: 12px 30px;
        border-radius: 5px;
        cursor: pointer;
        font-size: 16px;
      }
      button:hover {
        background: #5568d3;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <% if (!validOrderId) { %>
      <div class="error">
        <strong>Lỗi:</strong> Không tìm thấy thông tin đơn hàng.<br />
        OrderID parameter: <%= orderIdParam %>
      </div>
      <a href="${pageContext.request.contextPath}/order-history"
        >← Quay lại Order History</a
      >
      <% } else { CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();
      boolean hasFeedback = feedbackDAO.hasFeedbackForOrder(orderId); if
      (hasFeedback) { %>
      <div class="success">
        <strong>✓ Đã gửi feedback</strong><br />
        Bạn đã gửi feedback cho đơn hàng này rồi!
      </div>
      <a href="${pageContext.request.contextPath}/order-history"
        >← Quay lại Order History</a
      >
      <% } else { %>
      <h1>⭐ Đánh giá trải nghiệm</h1>
      <p>Đơn hàng #<%= orderId %></p>

      <div id="message" style="display: none"></div>

      <form id="feedbackForm">
        <input type="hidden" name="orderId" value="<%= orderId %>" />
        <input type="hidden" name="productId" value="1" />
        <input type="hidden" id="rating" name="rating" value="" />

        <div class="stars" id="stars">
          <span class="star" data-rating="1">★</span>
          <span class="star" data-rating="2">★</span>
          <span class="star" data-rating="3">★</span>
          <span class="star" data-rating="4">★</span>
          <span class="star" data-rating="5">★</span>
        </div>
        <div id="ratingText"></div>

        <textarea
          name="comment"
          placeholder="Nhận xét của bạn (tùy chọn)"
        ></textarea>

        <button type="submit">Gửi đánh giá</button>
      </form>

      <script>
        const stars = document.querySelectorAll(".star");
        const ratingInput = document.getElementById("rating");
        const ratingText = document.getElementById("ratingText");
        let selectedRating = 0;

        stars.forEach((star) => {
          star.addEventListener("click", function () {
            selectedRating = parseInt(this.dataset.rating);
            ratingInput.value = selectedRating;
            ratingText.textContent = selectedRating + " sao";

            stars.forEach((s, i) => {
              if (i < selectedRating) {
                s.classList.add("selected");
              } else {
                s.classList.remove("selected");
              }
            });
          });
        });

        document
          .getElementById("feedbackForm")
          .addEventListener("submit", async function (e) {
            e.preventDefault();

            if (!selectedRating) {
              alert("Vui lòng chọn đánh giá!");
              return;
            }

            const formData = new FormData(this);

            try {
              const response = await fetch(
                "${pageContext.request.contextPath}/submit-feedback",
                {
                  method: "POST",
                  body: formData,
                }
              );

              const result = await response.json();
              const messageDiv = document.getElementById("message");

              if (result.success) {
                messageDiv.className = "success";
                messageDiv.innerHTML =
                  "<strong>✓ Thành công!</strong><br>" + result.message;
                messageDiv.style.display = "block";

                setTimeout(() => {
                  window.location.href =
                    "${pageContext.request.contextPath}/order-history";
                }, 2000);
              } else {
                messageDiv.className = "error";
                messageDiv.innerHTML =
                  "<strong>Lỗi:</strong> " + result.message;
                messageDiv.style.display = "block";
              }
            } catch (error) {
              const messageDiv = document.getElementById("message");
              messageDiv.className = "error";
              messageDiv.innerHTML = "<strong>Lỗi:</strong> " + error.message;
              messageDiv.style.display = "block";
            }
          });
      </script>
      <% } %> <% } %>
    </div>
  </body>
</html>
