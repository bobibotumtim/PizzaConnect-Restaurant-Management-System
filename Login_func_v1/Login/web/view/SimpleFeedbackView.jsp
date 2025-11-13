<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá đơn hàng</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .container { background: white; border-radius: 20px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3); max-width: 600px; width: 100%; padding: 40px; }
        h1 { color: #333; font-size: 28px; margin-bottom: 10px; text-align: center; }
        .subtitle { color: #666; font-size: 16px; margin-bottom: 30px; text-align: center; }
        .star-rating { display: flex; justify-content: center; gap: 10px; margin: 20px 0; }
        .star { font-size: 50px; color: #ddd; cursor: pointer; transition: all 0.2s ease; user-select: none; }
        .star:hover, .star.selected { color: #ffd700; transform: scale(1.2); }
        .rating-text { text-align: center; color: #666; font-size: 18px; font-weight: 600; min-height: 30px; margin: 10px 0; }
        textarea { width: 100%; min-height: 120px; padding: 15px; border: 2px solid #e0e0e0; border-radius: 12px; font-size: 16px; font-family: inherit; resize: vertical; margin: 20px 0; }
        textarea:focus { outline: none; border-color: #667eea; }
        .btn { width: 100%; padding: 15px; font-size: 16px; font-weight: 600; border: none; border-radius: 50px; cursor: pointer; transition: all 0.3s ease; margin-top: 10px; }
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6); }
        .btn-secondary { background: white; color: #667eea; border: 2px solid #667eea; }
        .message { padding: 15px; border-radius: 12px; margin: 20px 0; }
        .message.success { background: #d4edda; border: 2px solid #28a745; color: #155724; }
        .message.error { background: #f8d7da; border: 2px solid #dc3545; color: #721c24; }
    </style>
</head>
<body>
    <div class="container">
        <c:choose>
            <c:when test="${!validOrderId}">
                <h1>⚠️ Lỗi</h1>
                <div class="message error">Order ID không được để trống</div>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='/Login/order-history'">← Quay lại</button>
            </c:when>
            <c:otherwise>
                <h1 id="pageTitle">⭐ Đánh giá trải nghiệm</h1>
                <p class="subtitle" id="pageSubtitle">Đơn hàng #${orderId}</p>
                
                <div id="successMessage" class="message success" style="display: none;">
                    <strong>Cảm ơn bạn đã đánh giá!</strong><br>Đánh giá của bạn đã được gửi thành công.
                </div>
                
                <div id="errorMessage" class="message error" style="display: none;"></div>
                
                <form id="feedbackForm" method="POST" action="/Login/submit-feedback">
                    <input type="hidden" name="orderId" value="${orderId}">
                    <input type="hidden" name="productId" value="1">
                    <input type="hidden" id="ratingInput" name="rating" value="">
                    
                    <div class="star-rating" id="starRating">
                        <span class="star" data-rating="1">★</span>
                        <span class="star" data-rating="2">★</span>
                        <span class="star" data-rating="3">★</span>
                        <span class="star" data-rating="4">★</span>
                        <span class="star" data-rating="5">★</span>
                    </div>
                    
                    <div class="rating-text" id="ratingText"></div>
                    
                    <textarea name="comment" placeholder="Chia sẻ trải nghiệm của bạn... (tùy chọn)" maxlength="500"></textarea>
                    
                    <button type="submit" class="btn btn-primary" id="submitBtn">Gửi đánh giá</button>
                    <button type="button" class="btn btn-secondary" onclick="window.location.href='/Login/order-history'">← Quay lại</button>
                </form>
                
                <script>
                    const stars = document.querySelectorAll('.star');
                    const ratingInput = document.getElementById('ratingInput');
                    const ratingText = document.getElementById('ratingText');
                    let selectedRating = 0;
                    const ratingLabels = { 1: '😞 Rất không hài lòng', 2: '😕 Không hài lòng', 3: '😐 Bình thường', 4: '😊 Hài lòng', 5: '😍 Rất hài lòng' };
                    stars.forEach(star => { star.addEventListener('click', function() { selectedRating = parseInt(this.dataset.rating); ratingInput.value = selectedRating; ratingText.textContent = ratingLabels[selectedRating]; stars.forEach((s, index) => { if (index < selectedRating) { s.classList.add('selected'); } else { s.classList.remove('selected'); } }); }); });
                    document.getElementById('feedbackForm').addEventListener('submit', async function(e) { e.preventDefault(); if (!selectedRating || selectedRating < 1) { alert('Vui lòng chọn đánh giá!'); return false; } const submitBtn = document.getElementById('submitBtn'); submitBtn.disabled = true; submitBtn.textContent = 'Đang gửi...'; try { const formData = new FormData(this); const response = await fetch('/Login/submit-feedback', { method: 'POST', body: formData }); const result = await response.json(); if (result.success) { document.getElementById('feedbackForm').style.display = 'none'; document.getElementById('pageTitle').textContent = '✅ Cảm ơn bạn!'; document.getElementById('pageSubtitle').style.display = 'none'; document.getElementById('successMessage').style.display = 'block'; setTimeout(() => { window.location.href = '/Login/order-history'; }, 3000); } else { const errorMsg = document.getElementById('errorMessage'); errorMsg.textContent = result.message || 'Có lỗi xảy ra'; errorMsg.style.display = 'block'; submitBtn.disabled = false; submitBtn.textContent = 'Gửi đánh giá'; } } catch (error) { const errorMsg = document.getElementById('errorMessage'); errorMsg.textContent = 'Có lỗi xảy ra. Vui lòng thử lại.'; errorMsg.style.display = 'block'; submitBtn.disabled = false; submitBtn.textContent = 'Gửi đánh giá'; } });
                </script>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
