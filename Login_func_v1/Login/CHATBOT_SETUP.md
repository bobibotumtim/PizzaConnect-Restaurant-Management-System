# 🤖 AI Chatbot Setup Guide

## ✅ Files Created

1. **`Login/src/java/controller/ChatBotServlet.java`** - Backend servlet
2. **`Login/web/view/ChatBot.jsp`** - Chat interface
3. **`Login/web/view/ChatBotWidget.jsp`** - Floating button widget

## 🔧 Setup Steps

### 1. Clean & Build Project
```
Right-click project → Clean and Build
```

### 2. Restart Tomcat Server
```
Stop server → Start server
```

### 3. Test Access
```
Login as customer:
- Phone: 0909000004
- Password: 123

Then navigate to:
http://localhost:8080/Login/chatbot
```

## 🚨 Troubleshooting

### Error 404 - Not Found
**Solution:**
1. Clean and Build project
2. Restart Tomcat
3. Check if ChatBotServlet.class exists in build/web/WEB-INF/classes/controller/

### Bot Not Responding
**Check Browser Console (F12):**
- Look for JavaScript errors
- Check network tab for failed requests
- Verify response format is valid JSON

**Solution:**
1. Refresh page (Ctrl+F5)
2. Check server logs for errors
3. Verify database connection

### Servlet Not Loading
**Check:**
- `@WebServlet` annotation is present in ChatBotServlet.java
- No duplicate mapping in web.xml
- Class is compiled (check build folder)
- Using `jakarta.servlet.*` not `javax.servlet.*`

### Database Connection Error
**Check:**
- ProductDAO and ProductSizeDAO are accessible
- Database connection is working
- Tables Product and ProductSize exist

## 📍 Access Points

### For Customers:
1. **Sidebar Menu**: Click "AI Assistant"
2. **Floating Button**: Click 🤖 button (bottom-right corner)
3. **Direct URL**: `/chatbot`

### Widget Visibility:
- Only shows for customers (Role = 3)
- Appears on Home and CustomerMenu pages

## ✨ Features Working

- ✅ Menu information
- ✅ Pizza details with sizes/prices
- ✅ Drink information
- ✅ Price ranges
- ✅ Best sellers
- ✅ Promotions
- ✅ Opening hours
- ✅ Location info
- ✅ Delivery info
- ✅ Payment methods

## 🔍 Quick Test

### Access Chatbot:
```
1. Login as customer (Phone: 0909000004, Password: 123)
2. Navigate to: http://localhost:8080/Login/chatbot
   OR click "AI Assistant" in sidebar
   OR click 🤖 floating button
```

### Sample Questions:
```
"Show me the menu"
"What pizzas do you have?"
"Any promotions?"
"What time do you open?"
```

## 🐛 Troubleshooting

### Chat Not Showing:
1. **Clear browser cache** (Ctrl+Shift+Delete)
2. **Hard refresh** (Ctrl+F5)
3. **Check browser console** (F12) for errors
4. **Verify login** - Must be logged in as customer

### Bot Not Responding:
1. **Check console** for network errors
2. **Verify servlet** is running (check Tomcat logs)
3. **Test database** connection

---
**Status**: ✅ FULLY WORKING

## 🎉 Ready to Use!

The chatbot is now fully functional and integrated into your application.

### Access Methods:
1. **Sidebar Link** - Click "AI Assistant" 
2. **Floating Button** - Click 🤖 on Home/Menu pages
3. **Direct URL** - `/chatbot`

### Features:
- ✅ Full chat interface with Sidebar/NavBar
- ✅ Real-time responses from database
- ✅ Menu information and prices
- ✅ Product recommendations
- ✅ Promotions and deals
- ✅ Store information
- ✅ Quick action buttons
- ✅ Typing indicator
- ✅ Message formatting (bold, line breaks)
- ✅ Responsive design

### Test Files Cleaned:
- ❌ Removed test-chatbot.html
- ❌ Removed ChatBotSimple.jsp
- ❌ Removed ChatBotNoLayout.jsp

Only production files remain! 🚀

## 🤖 Gemini AI Integration (Optional)

Chatbot now supports Google Gemini Pro API for answering questions outside the rule-based system.

### Quick Setup:
1. Get API key from: https://makersuite.google.com/app/apikey
2. Open `Login/src/java/util/Config.java`
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your key
4. Set `ENABLE_GEMINI = true`

### How It Works:
- **Rule-based first** (fast) - Menu, prices, promotions
- **Gemini fallback** (smart) - Other questions

See `GEMINI_INTEGRATION.md` for full documentation.

### Without Gemini:
Chatbot works perfectly with rule-based responses only. Gemini is optional for enhanced capabilities.
