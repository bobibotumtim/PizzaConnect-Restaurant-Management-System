# 🤖 Gemini AI Integration

## 📋 Overview

Chatbot đã được tích hợp với Google Gemini Pro API để trả lời các câu hỏi ngoài lề mà rule-based system không cover được.

## 🎯 How It Works

### Priority System:
1. **Rule-Based (Fast)** - Trả lời ngay cho câu hỏi về:
   - Menu và giá cả
   - Pizza, drinks, toppings
   - Khuyến mãi
   - Giờ mở cửa
   - Địa chỉ
   - Giao hàng
   - Thanh toán

2. **Gemini AI (Fallback)** - Xử lý câu hỏi khác:
   - Câu hỏi chung về nhà hàng
   - Tư vấn món ăn
   - Câu hỏi về dinh dưỡng
   - Câu hỏi ngoài lề

## 🔑 Setup API Key

### Step 1: Get Gemini API Key
1. Truy cập: https://makersuite.google.com/app/apikey
2. Đăng nhập với Google account
3. Click "Create API Key"
4. Copy API key

### Step 2: Configure
Mở file `Login/src/java/util/Config.java`:

```java
public static final String GEMINI_API_KEY = "YOUR_API_KEY_HERE";
```

Thay `YOUR_API_KEY_HERE` bằng API key của bạn.

### Step 3: Enable/Disable
```java
public static final boolean ENABLE_GEMINI = true;  // Enable
public static final boolean ENABLE_GEMINI = false; // Disable
```

## 📁 Files Created

1. **`util/GeminiAPI.java`** - API client để gọi Gemini
2. **`util/Config.java`** - Configuration file
3. **`GEMINI_INTEGRATION.md`** - Documentation

## 📊 Example Conversations

### Rule-Based (Fast):
```
User: "Show me the menu"
Bot: [Returns menu from database immediately]
```

### Gemini AI (Smart):
```
User: "What's the healthiest pizza option?"
Bot: "The Hawaiian Pizza with extra vegetables would be a good choice. 
      It has ham for protein and pineapple for vitamins. 
      Consider ordering a Small size to control portions!"
```

```
User: "Can I bring my dog?"
Bot: "While we love pets, for health and safety reasons, 
      only service animals are allowed inside. 
      However, we have outdoor seating where your furry friend is welcome!"
```

## ⚙️ Configuration Options

### In `Config.java`:

```java
// Enable/Disable Gemini
public static final boolean ENABLE_GEMINI = true;

// API Key
public static final String GEMINI_API_KEY = "your-key-here";

// Restaurant Info (used in Gemini context)
public static final String RESTAURANT_NAME = "PizzaConnect";
public static final String RESTAURANT_ADDRESS = "...";
public static final String OPENING_HOURS = "...";
```

## 🔒 Security

### Best Practices:
1. **Never commit API key** to Git
2. **Use environment variables** in production:
   ```java
   String apiKey = System.getenv("GEMINI_API_KEY");
   ```
3. **Add to .gitignore**:
   ```
   Config.java
   ```

### For Production:
Create `Config.java.template`:
```java
public static final String GEMINI_API_KEY = "REPLACE_WITH_YOUR_KEY";
```

## 💰 API Costs

Gemini Pro API pricing (as of 2024):
- **Free tier**: 60 requests/minute
- **Paid tier**: $0.00025 per 1K characters

For typical chatbot usage:
- ~100 characters per request
- ~1000 requests/month
- **Cost**: ~$0.025/month (very cheap!)

## 🧪 Testing

### Test Rule-Based:
```
"Show me the menu"
"What pizzas do you have?"
"Any promotions?"
```

### Test Gemini AI:
```
"What's the best pizza for kids?"
"Do you have vegetarian options?"
"Can I customize my pizza?"
"What's your most popular topping?"
```

## 🐛 Troubleshooting

### Gemini Not Responding:
1. **Check API key** - Verify it's correct in Config.java
2. **Check internet** - Server needs internet access
3. **Check logs** - Look for errors in Tomcat logs
4. **Check quota** - Verify you haven't exceeded free tier

### Fallback Behavior:
If Gemini fails, chatbot automatically falls back to default response.

## 📈 Performance

### Response Times:
- **Rule-based**: <50ms (instant)
- **Gemini API**: 500-2000ms (depends on network)

### Optimization:
- Rule-based responses are prioritized
- Gemini only called for unmatched queries
- Timeout: 10 seconds (configurable)

## 🔮 Future Enhancements

1. **Caching** - Cache common Gemini responses
2. **Context Memory** - Remember conversation history
3. **Multilingual** - Support Vietnamese responses
4. **Fine-tuning** - Train on restaurant-specific data
5. **Analytics** - Track which questions use Gemini

## 📝 Example Code

### Calling Gemini:
```java
String response = GeminiAPI.generateResponse(
    userMessage, 
    restaurantContext
);
```

### With Error Handling:
```java
try {
    if (Config.ENABLE_GEMINI) {
        String response = GeminiAPI.generateResponse(message, context);
        if (response != null) {
            return response;
        }
    }
    return getDefaultResponse();
} catch (Exception e) {
    log.error("Gemini error", e);
    return getDefaultResponse();
}
```

---

**Created**: 2025-01-09  
**Version**: 1.0  
**Author**: Pizza Store Development Team
