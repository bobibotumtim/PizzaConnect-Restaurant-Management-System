<%@ page import="models.User" %>
<%
    // Only show for customers (Role = 3)
    HttpSession widgetSession = request.getSession(false);
    User widgetUser = (widgetSession != null) ? (User) widgetSession.getAttribute("user") : null;
    boolean isCustomer = (widgetUser != null && widgetUser.getRole() == 3);
    
    if (isCustomer) {
%>
<style>
    .chatbot-widget {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 9999;
    }
    
    .chatbot-button {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
        color: white;
        border: none;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(249, 115, 22, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        transition: all 0.3s ease;
        animation: pulse 2s infinite;
    }
    
    .chatbot-button:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 20px rgba(249, 115, 22, 0.6);
    }
    
    .chatbot-button:active {
        transform: scale(0.95);
    }
    
    @keyframes pulse {
        0%, 100% {
            box-shadow: 0 4px 12px rgba(249, 115, 22, 0.4);
        }
        50% {
            box-shadow: 0 4px 20px rgba(249, 115, 22, 0.8);
        }
    }
    
    .chatbot-tooltip {
        position: absolute;
        right: 70px;
        bottom: 15px;
        background: white;
        color: #1f2937;
        padding: 8px 16px;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        white-space: nowrap;
        font-size: 14px;
        font-weight: 500;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.3s ease;
    }
    
    .chatbot-widget:hover .chatbot-tooltip {
        opacity: 1;
    }
    
    .chatbot-tooltip::after {
        content: '';
        position: absolute;
        right: -6px;
        top: 50%;
        transform: translateY(-50%);
        width: 0;
        height: 0;
        border-left: 6px solid white;
        border-top: 6px solid transparent;
        border-bottom: 6px solid transparent;
    }
</style>

<div class="chatbot-widget">
    <div class="chatbot-tooltip">Need help? Chat with us!</div>
    <button class="chatbot-button" onclick="window.location.href='<%= request.getContextPath() %>/chatbot'" title="AI Assistant">
        🤖
    </button>
</div>
<%
    }
%>
