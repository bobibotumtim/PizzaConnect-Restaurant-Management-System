<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.*, java.util.*, java.text.*" %>
<%
    Order order = (Order) request.getAttribute("order");
    Payment payment = (Payment) request.getAttribute("payment");
    Double subtotal = (Double) request.getAttribute("subtotal");
    Double tax = (Double) request.getAttribute("tax");
    String currentDate = (String) request.getAttribute("currentDate");
    Boolean embedded = (Boolean) request.getAttribute("embedded");
    
    if (embedded == null) embedded = false;
    
    NumberFormat numberFormat = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>Bill - Order #<%= order != null ? order.getOrderID() : "" %></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Courier New', monospace;
            font-size: 12px;
            line-height: 1.2;
            background: white;
            padding: 5px;
        }
        .bill-container {
            width: 280px;
            margin: 0 auto;
            padding: 8px;
            border: 1px solid #000;
        }
        .header {
            text-align: center;
            margin-bottom: 8px;
            padding-bottom: 8px;
            border-bottom: 1px dashed #000;
        }
        .header h1 {
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 3px;
            text-transform: uppercase;
        }
        .header p {
            margin: 1px 0;
            font-size: 10px;
        }
        .divider {
            border-bottom: 1px dashed #000;
            margin: 5px 0;
        }
        .info-line {
            display: flex;
            justify-content: space-between;
            margin: 2px 0;
        }
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin: 5px 0;
        }
        .items-table td {
            padding: 2px 0;
            vertical-align: top;
        }
        .item-name {
            width: 60%;
            text-align: left;
        }
        .item-qty {
            width: 10%;
            text-align: center;
        }
        .item-price {
            width: 30%;
            text-align: right;
        }
        .amount-section {
            margin: 5px 0;
        }
        .amount-line {
            display: flex;
            justify-content: space-between;
            margin: 2px 0;
        }
        .total-line {
            font-weight: bold;
            font-size: 13px;
        }
        .qr-section {
            text-align: center;
            margin: 8px 0;
            padding: 5px;
            border: 1px dashed #000;
        }
        .qr-code img {
            width: 250px;
            height: 280px;
            max-width: 100%;
        }
        .payment-instruction {
            text-align: center;
            margin: 5px 0;
            font-size: 10px;
        }
        .footer {
            text-align: center;
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px dashed #000;
            font-size: 10px;
        }
        .text-center { text-align: center; }
        .text-right { text-align: right; }
        .text-bold { font-weight: bold; }
        
        /* Print styles */
        @media print {
            body {
                padding: 0;
                margin: 0;
                width: 280px;
            }
            .bill-container {
                border: none;
                box-shadow: none;
                width: 100%;
                margin: 0;
                padding: 0;
            }
            .no-print {
                display: none !important;
            }
            /* Ensure QR code prints properly */
            .qr-code img {
                width: 250px !important;
                height: 280px !important;
            }
        }

        /* Styles for embedded mode */
        .embedded-bill {
            transform: scale(0.8);
            transform-origin: top center;
        }
    </style>
</head>
<body class="<%= embedded ? "embedded-bill" : "" %>">
    <% if (order == null) { %>
        <div class="text-center py-8 text-red-600">
            <p>Order not found or invalid order ID</p>
        </div>
    <% } else { %>
        <div class="bill-container">
            <!-- Header -->
            <div class="header">
                <h1>HÓA ĐƠN THANH TOÁN</h1>
                <p class="text-bold">Pizza Store</p>
                <p>KM29 - ĐL Thăng Long</p>
                <p>ĐT: 012345678-0987654321</p>
            </div>

            <!-- Order Info -->
            <div class="info-line">
                <span><%= currentDate %></span>
            </div>
            <div class="info-line">
                <span>Khách hàng: <%= order.getCustomerName() != null ? order.getCustomerName() : "Khách vãng lai" %></span>
            </div>
            <% if (order.getTableID() > 0) { %>
            <div class="info-line">
                <span>Bàn số: <%= order.getTableID() %></span>
            </div>
            <% } %>
            <div class="info-line">
                <span>Hóa đơn số: <%= order.getOrderID() %></span>
            </div>

            <div class="divider"></div>

            <!-- Order Items -->
            <table class="items-table">
                <tbody>
                    <% for (OrderDetail item : order.getDetails()) { %>
                    <tr>
                        <td class="item-name">
                            <%= item.getProductName() %>
                            <% if (item.getSizeName() != null && !item.getSizeName().isEmpty()) { %>
                                (<%= item.getSizeName() %>)
                            <% } %>
                        </td>
                        <td class="item-qty"><%= item.getQuantity() %></td>
                        <td class="item-price"><%= numberFormat.format(item.getTotalPrice()) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <div class="divider"></div>

            <!-- Amount Calculation -->
            <div class="amount-section">
                <div class="amount-line text-bold">
                    <span>Tạm tính:</span>
                    <span><%= numberFormat.format(subtotal) %></span>
                </div>
                <div class="amount-line">
                    <span>Thuế (10%):</span>
                    <span><%= numberFormat.format(tax) %></span>
                </div>
                <div class="amount-line total-line">
                    <span>Tổng cộng:</span>
                    <span><%= numberFormat.format(order.getTotalPrice()) %></span>
                </div>
            </div>

            <div class="divider"></div>
            
            <!-- QR Code Payment Section -->
            <div class="qr-section">
                <div class="text-bold" style="margin-bottom: 5px;">
                    Thanh toán bằng QR Banking
                </div>
                <div class="payment-instruction">
                    Số dư ứng dụng ngân hàng để quét mã QR
                </div>
                
                <div class="qr-code">
                    <img src="<%= payment.getQrCodeURL() != null ? payment.getQrCodeURL() : generateQRCodeURL(order.getTotalPrice(), order.getOrderID()) %>" 
                         alt="QR Code">
                </div>
                
                <div class="text-bold" style="margin: 5px 0;">
                    Số tiền: <%= numberFormat.format(order.getTotalPrice()) %> VND
                </div>
                
                <div class="payment-instruction">
                    - Thanh toán hóa đơn số <%= order.getOrderID() %>
                </div>
                <div class="payment-instruction">
                    Phần mềm chờ thu ngân xác nhận
                </div>
            </div>

            <!-- Footer -->
            <div class="footer">
                <p>Cảm ơn quý khách!</p>
                <p>Hẹn gặp lại!</p>
            </div>
        </div>
    <% } %>
</body>
</html>

<%!
    private String generateQRCodeURL(double amount, int orderId) {
        String baseUrl = "https://img.vietqr.io/image/vietinbank-113366668888-compact2.jpg";
        String amountStr = String.format("%.0f", amount);
        String addInfo = "Thanh toan order " + orderId;
        
        return baseUrl + "?amount=" + amountStr + 
               "&addInfo=" + addInfo + 
               "&accountName=Pizza Store";
    }
%>