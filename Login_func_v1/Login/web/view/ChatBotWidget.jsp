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
        z-index: 1000;
    }
    
    .chatbot-button {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
        color: white;
        border: 3px solid white;
        cursor: pointer;
        box-shadow: 0 8px 24px rgba(249, 115, 22, 0.35);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 32px;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
    }
    
    .chatbot-icon {
        width: 36px;
        height: 36px;
        fill: white;
    }
    
    .chatbot-button:hover {
        transform: translateY(-4px) scale(1.05);
        box-shadow: 0 12px 32px rgba(249, 115, 22, 0.5);
        border-color: rgba(255, 255, 255, 0.9);
    }
    

    
    .chatbot-button:active {
        transform: translateY(-2px) scale(1.02);
    }
    
    .chatbot-tooltip {
        position: absolute;
        right: 80px;
        bottom: 50%;
        transform: translateY(50%);
        background: white;
        color: #1f2937;
        padding: 10px 18px;
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
        white-space: nowrap;
        font-size: 14px;
        font-weight: 600;
        opacity: 0;
        pointer-events: none;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        border: 1px solid rgba(249, 115, 22, 0.1);
    }
    
    .chatbot-widget:hover .chatbot-tooltip {
        opacity: 1;
        right: 85px;
    }
    
    .chatbot-tooltip::after {
        content: '';
        position: absolute;
        right: -8px;
        top: 50%;
        transform: translateY(-50%);
        width: 0;
        height: 0;
        border-left: 8px solid white;
        border-top: 8px solid transparent;
        border-bottom: 8px solid transparent;
    }
    
    .chatbot-badge {
        position: absolute;
        top: -4px;
        right: -4px;
        width: 20px;
        height: 20px;
        background: #10b981;
        border: 3px solid white;
        border-radius: 50%;
        animation: pulse-badge 2s infinite;
    }
    
    @keyframes pulse-badge {
        0%, 100% {
            transform: scale(1);
            opacity: 1;
        }
        50% {
            transform: scale(1.1);
            opacity: 0.8;
        }
    }
</style>

<div class="chatbot-widget">
    <div class="chatbot-tooltip">Need help? Chat with us!</div>
    <button class="chatbot-button" onclick="window.location.href='<%= request.getContextPath() %>/chatbot'" title="AI Assistant">
        <svg class="chatbot-icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M17.753 14a2.25 2.25 0 0 1 2.25 2.25v.904A3.75 3.75 0 0 1 18.696 20c-1.565 1.344-3.806 2-6.696 2-2.89 0-5.128-.656-6.69-2a3.75 3.75 0 0 1-1.306-2.843v-.908A2.25 2.25 0 0 1 6.254 14h11.5ZM11.9 2.006L12 2a.75.75 0 0 1 .743.648l.007.102v.749h3.5a2.25 2.25 0 0 1 2.25 2.25v4.505a2.25 2.25 0 0 1-2.25 2.25h-8.5a2.25 2.25 0 0 1-2.25-2.25V5.75a2.25 2.25 0 0 1 2.25-2.25h3.5V2.75a.75.75 0 0 1 .65-.744ZM9.75 6.5a1.25 1.25 0 1 0 0 2.5 1.25 1.25 0 0 0 0-2.5Zm4.5 0a1.25 1.25 0 1 0 0 2.5 1.25 1.25 0 0 0 0-2.5Z"/>
        </svg>
        <span class="chatbot-badge"></span>
    </button>
</div>
<%
    }
%>
