<%@ page contentType="text/html;charset=UTF-8" language="java" %> 
<% 
    Integer orderId = (Integer) request.getAttribute("orderId"); 
    if (orderId == null || orderId == 0) { 
        try { 
            String param = request.getParameter("orderId"); 
            if (param != null && !param.trim().isEmpty()) { 
                orderId = Integer.parseInt(param); 
            } else {
                orderId = 0;
            }
        } catch (Exception e) { 
            orderId = 0;
        } 
    } 
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đánh giá</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      body {
        font-family: "Segoe UI", sans-serif;
        background: linear-gradient(135deg, #667eea, #764ba2);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
      }
      .box {
        background: #fff;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        max-width: 600px;
        width: 100%;
        padding: 40px;
      }
      h1 {
        color: #333;
        font-size: 28px;
        margin-bottom: 10px;
        text-align: center;
      }
      .sub {
        color: #666;
        font-size: 16px;
        margin-bottom: 30px;
        text-align: center;
      }
      .stars {
        display: flex;
        justify-content: center;
        gap: 10px;
        margin: 20px 0;
      }
      .star {
        font-size: 50px;
        color: #ddd;
        cursor: pointer;
        transition: all 0.2s;
        user-select: none;
      }
      .star:hover,
      .star.sel {
        color: #ffd700;
        transform: scale(1.2);
      }
      .txt {
        text-align: center;
        color: #666;
        font-size: 18px;
        font-weight: 600;
        min-height: 30px;
        margin: 10px 0;
      }
      textarea {
        width: 100%;
        min-height: 120px;
        padding: 15px;
        border: 2px solid #e0e0e0;
        border-radius: 12px;
        font-size: 16px;
        resize: vertical;
        margin: 20px 0;
      }
      textarea:focus {
        outline: none;
        border-color: #667eea;
      }
      .btn {
        width: 100%;
        padding: 15px;
        font-size: 16px;
        font-weight: 600;
        border: none;
        border-radius: 50px;
        cursor: pointer;
        transition: all 0.3s;
        margin-top: 10px;
      }
      .btn1 {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: #fff;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
      }
      .btn1:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
      }
      .btn2 {
        background: #fff;
        color: #667eea;
        border: 2px solid #667eea;
      }
      .msg {
        padding: 15px;
        border-radius: 12px;
        margin: 20px 0;
        display: none;
      }
      .ok {
        background: #d4edda;
        border: 2px solid #28a745;
        color: #155724;
      }
      .err {
        background: #f8d7da;
        border: 2px solid #dc3545;
        color: #721c24;
      }
    </style>
  </head>
  <body>
    <div class="box">
      <% if (orderId == null || orderId == 0) { %>
        <h1 id="t1">❌ Lỗi</h1>
        <div id="err" class="msg err" style="display: block;">
          <strong>Order ID không được để trống</strong><br />
          Vui lòng quay lại trang Order History và thử lại.
        </div>
        <button
          type="button"
          class="btn btn2"
          onclick="location.href='/Login/order-history'"
          style="margin-top: 20px;"
        >
          ← Quay lại Order History
        </button>
      <% } else { %>
      <h1 id="t1">⭐ Đánh giá trải nghiệm</h1>
      <p class="sub" id="t2">Đơn hàng #<%= orderId %></p>
      <div id="ok" class="msg ok">
        <strong>Cảm ơn!</strong><br />Đánh giá đã được gửi.
      </div>
      <div id="err" class="msg err"></div>
      <form id="f" method="POST" action="/Login/submit-feedback">
        <input type="hidden" name="orderId" id="orderIdInput" value="<%= orderId != null && orderId > 0 ? orderId : "" %>" />
        <input type="hidden" name="productId" value="1" />
        <input type="hidden" id="r" name="rating" value="" />
        <div class="stars" id="s">
          <span class="star" data-rating="1">★</span>
          <span class="star" data-rating="2">★</span>
          <span class="star" data-rating="3">★</span>
          <span class="star" data-rating="4">★</span>
          <span class="star" data-rating="5">★</span>
        </div>
        <div class="txt" id="tx"></div>
        <textarea
          name="comment"
          placeholder="Chia sẻ trải nghiệm..."
          maxlength="500"
        ></textarea>
        <button type="submit" class="btn btn1" id="b">Gửi đánh giá</button>
        <button
          type="button"
          class="btn btn2"
          onclick="location.href='/Login/order-history'"
        >
          ← Quay lại
        </button>
      </form>
      <script>
        const st = document.querySelectorAll(".star"),
          ri = document.getElementById("r"),
          tx = document.getElementById("tx");
        let sr = 0;
        const lb = {
          1: "😞 Rất không hài lòng",
          2: "😕 Không hài lòng",
          3: "😐 Bình thường",
          4: "😊 Hài lòng",
          5: "😍 Rất hài lòng",
        };
        st.forEach((s) => {
          s.addEventListener("click", function () {
            sr = parseInt(this.dataset.rating);
            ri.value = sr;
            tx.textContent = lb[sr];
            st.forEach((x, i) => {
              i < sr ? x.classList.add("sel") : x.classList.remove("sel");
            });
          });
        });
        document
          .getElementById("f")
          .addEventListener("submit", async function (e) {
            e.preventDefault();
            if (!sr || sr < 1) {
              alert("Vui lòng chọn đánh giá!");
              return;
            }
            
            // Get orderId from hidden input
            const orderIdInput = this.querySelector('input[name="orderId"]');
            const orderId = orderIdInput ? orderIdInput.value : null;
            
            if (!orderId || orderId === "0" || orderId.trim() === "") {
              alert("Order ID không hợp lệ. Vui lòng quay lại trang Order History và thử lại.");
              return;
            }
            
            const b = document.getElementById("b");
            b.disabled = true;
            b.textContent = "Đang gửi...";
            try {
              // Create URLSearchParams instead of FormData to ensure proper encoding
              const params = new URLSearchParams();
              params.append("orderId", orderId);
              params.append("rating", sr.toString());
              params.append("productId", "1");
              
              const commentValue = this.querySelector('textarea[name="comment"]').value;
              if (commentValue) {
                params.append("comment", commentValue);
              }
              
              // Debug log
              console.log("Submitting feedback with orderId:", params.get("orderId"));
              console.log("Rating:", params.get("rating"));
              console.log("Comment:", params.get("comment"));
              
              const res = await fetch("/Login/submit-feedback", {
                method: "POST",
                headers: {
                  "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
                },
                body: params.toString(),
              }),
                r = await res.json();
              if (r.success) {
                document.getElementById("f").style.display = "none";
                document.getElementById("t1").textContent = "✅ Cảm ơn!";
                document.getElementById("t2").style.display = "none";
                document.getElementById("ok").style.display = "block";
                setTimeout(
                  () => (location.href = "/Login/order-history"),
                  3000
                );
              } else {
                document.getElementById("err").textContent = r.message || "Lỗi";
                document.getElementById("err").style.display = "block";
                b.disabled = false;
                b.textContent = "Gửi đánh giá";
              }
            } catch (e) {
              document.getElementById("err").textContent = "Lỗi. Thử lại.";
              document.getElementById("err").style.display = "block";
              b.disabled = false;
              b.textContent = "Gửi đánh giá";
            }
          });
      </script>
      <% } %>
    </div>
  </body>
</html>
