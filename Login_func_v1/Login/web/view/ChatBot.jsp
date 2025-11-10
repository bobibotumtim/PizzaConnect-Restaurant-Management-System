<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Assistant - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body class="bg-gray-50">
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>
    
    <div style="margin-left: 80px; margin-top: 60px; padding: 20px; min-height: calc(100vh - 60px);">
        <div style="max-width: 1024px; margin: 0 auto; padding: 0 24px;">
            
            <!-- Header -->
            <div class="bg-white rounded-xl shadow-md p-6 mb-6">
                <div class="flex items-center gap-4">
                    <div class="w-16 h-16 bg-gradient-to-br from-orange-400 to-orange-600 rounded-full flex items-center justify-center text-3xl">
                        🤖
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Pizza Assistant</h1>
                        <p class="text-gray-600">Ask me anything about our menu, orders, or services!</p>
                    </div>
                </div>
            </div>
            
            <!-- Chat Container -->
            <div class="bg-white rounded-xl shadow-md overflow-hidden" style="min-height: 600px;">
                <!-- Chat Messages -->
                <div id="chatMessages" class="overflow-y-auto p-6 space-y-4" style="height: 500px; background: white;">
                    <!-- Welcome Message -->
                    <div class="flex gap-3">
                        <div class="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center text-white flex-shrink-0">
                            🤖
                        </div>
                        <div class="bg-gray-100 rounded-lg p-4 max-w-[80%]">
                            <p class="text-gray-800">Hello! 👋 I'm your Pizza Assistant. I can help you with:</p>
                            <ul class="mt-2 space-y-1 text-sm text-gray-700">
                                <li>• Menu information and prices</li>
                                <li>• Product recommendations</li>
                                <li>• Order status</li>
                                <li>• Store information</li>
                            </ul>
                            <p class="mt-2 text-gray-800">How can I help you today?</p>
                        </div>
                    </div>
                </div>
                
                <!-- Chat Input -->
                <div class="border-t border-gray-200 p-4">
                    <div class="flex gap-2">
                        <input 
                            type="text" 
                            id="userInput" 
                            placeholder="Type your message here..."
                            class="flex-1 border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-orange-500"
                            onkeypress="if(event.key === 'Enter') sendMessage()"
                        >
                        <button 
                            onclick="sendMessage()"
                            class="bg-orange-500 text-white px-6 py-3 rounded-lg hover:bg-orange-600 transition-all font-semibold flex items-center gap-2"
                        >
                            <span>Send</span>
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/></svg>
                        </button>
                    </div>
                    
                    <!-- Quick Actions -->
                    <div class="mt-3 flex flex-wrap gap-2">
                        <button onclick="quickMessage('Show me the menu')" class="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded-full hover:bg-gray-200">
                            📋 Show menu
                        </button>
                        <button onclick="quickMessage('What are your best sellers?')" class="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded-full hover:bg-gray-200">
                            ⭐ Best sellers
                        </button>
                        <button onclick="quickMessage('Do you have any promotions?')" class="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded-full hover:bg-gray-200">
                            🎁 Promotions
                        </button>
                        <button onclick="quickMessage('What are your opening hours?')" class="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded-full hover:bg-gray-200">
                            🕐 Opening hours
                        </button>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
    
    <script>
        console.log('=== ChatBot.jsp Script Started ===');
        
        // Wait for DOM to be ready
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM Content Loaded');
            const chatMessages = document.getElementById('chatMessages');
            const userInput = document.getElementById('userInput');
            console.log('Chat elements:', chatMessages, userInput);
            
            if (!chatMessages) {
                console.error('chatMessages element not found!');
            }
            if (!userInput) {
                console.error('userInput element not found!');
            }
        });
        
        const chatMessages = document.getElementById('chatMessages');
        const userInput = document.getElementById('userInput');
        
        function addMessage(message, isUser = false) {
            const messageDiv = document.createElement('div');
            messageDiv.className = 'flex gap-3 ' + (isUser ? 'justify-end' : '');
            
            if (isUser) {
                messageDiv.innerHTML = 
                    '<div class="bg-orange-500 text-white rounded-lg p-4 max-w-[80%]">' +
                        '<p>' + escapeHtml(message) + '</p>' +
                    '</div>' +
                    '<div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white flex-shrink-0">' +
                        '👤' +
                    '</div>';
            } else {
                // Format bot message with line breaks and bold text
                const formattedMessage = message
                    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                    .replace(/\n/g, '<br>');
                
                messageDiv.innerHTML = 
                    '<div class="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center text-white flex-shrink-0">' +
                        '🤖' +
                    '</div>' +
                    '<div class="bg-gray-100 rounded-lg p-4 max-w-[80%]">' +
                        '<div class="text-gray-800">' + formattedMessage + '</div>' +
                    '</div>';
            }
            
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        
        function addTypingIndicator() {
            const typingDiv = document.createElement('div');
            typingDiv.id = 'typingIndicator';
            typingDiv.className = 'flex gap-3';
            typingDiv.innerHTML = 
                '<div class="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center text-white flex-shrink-0">' +
                    '🤖' +
                '</div>' +
                '<div class="bg-gray-100 rounded-lg p-4">' +
                    '<div class="flex gap-1">' +
                        '<div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>' +
                        '<div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>' +
                        '<div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>' +
                    '</div>' +
                '</div>';
            chatMessages.appendChild(typingDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        
        function removeTypingIndicator() {
            const typingIndicator = document.getElementById('typingIndicator');
            if (typingIndicator) {
                typingIndicator.remove();
            }
        }
        
        async function sendMessage() {
            const message = userInput.value.trim();
            if (!message) return;
            
            // Add user message
            addMessage(message, true);
            userInput.value = '';
            
            // Show typing indicator
            addTypingIndicator();
            
            try {
                // Send to servlet
                const response = await fetch('<%= request.getContextPath() %>/chatbot', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'message=' + encodeURIComponent(message)
                });
                
                console.log('Response status:', response.status);
                
                const text = await response.text();
                console.log('Raw response:', text.substring(0, 200));
                
                const data = JSON.parse(text);
                console.log('Bot response:', data);
                
                // Remove typing indicator
                removeTypingIndicator();
                
                // Add bot response
                if (data.response) {
                    addMessage(data.response);
                } else {
                    addMessage('Sorry, I received an empty response.');
                }
                
            } catch (error) {
                removeTypingIndicator();
                addMessage('Sorry, I encountered an error. Please try again.');
                console.error('Error:', error);
            }
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        function quickMessage(message) {
            userInput.value = message;
            sendMessage();
        }
        
        // Initialize Lucide icons
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
    </script>
</body>
</html>
