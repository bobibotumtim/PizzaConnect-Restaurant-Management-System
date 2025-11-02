# AI Chatbot Assistant Setup Guide

## Overview

This guide explains how to set up and configure the AI Chatbot Assistant for the PizzaConnect Restaurant Management System.

## Prerequisites

- Java 11 or higher (for HttpClient support)
- Google Gemini API key
- Existing PizzaConnect application setup

## Setup Steps

### 1. Get Google Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

### 2. Configure Environment Variables

#### Option A: Using .env file (Recommended for Development)

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file and add your Gemini API key:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   CHATBOT_ENABLED=true
   CHATBOT_MAX_HISTORY=50
   CHATBOT_SESSION_TIMEOUT=1800
   CHATBOT_RESPONSE_CACHE_HOURS=24
   ```

3. **Important**: Never commit the `.env` file to version control. It's already in `.gitignore`.

#### Option B: Using System Environment Variables (Recommended for Production)

Set environment variables in your system or application server:

**Windows:**
```cmd
setx GEMINI_API_KEY "your_actual_api_key_here"
```

**Linux/Mac:**
```bash
export GEMINI_API_KEY="your_actual_api_key_here"
```

**Tomcat (catalina.sh or setenv.sh):**
```bash
export GEMINI_API_KEY="your_actual_api_key_here"
export CHATBOT_ENABLED="true"
```

### 3. Project Structure

The chatbot components are organized as follows:

```
Login_func_v1/Login/src/java/
└── chatbot/
    ├── ChatbotConfig.java          # Configuration management
    ├── ChatbotLogger.java          # Logging utility
    ├── models/                     # Data models
    │   ├── ChatContext.java
    │   ├── ChatMessage.java
    │   ├── ChatResponse.java
    │   ├── Intent.java
    │   └── QuickReply.java
    ├── service/                    # Business logic (to be implemented)
    └── dao/                        # Data access (to be implemented)
```

### 4. Dependencies

The following libraries are required and should already be in your project:

- **HTTP Client**: Java 11+ built-in `java.net.http.HttpClient`
- **JSON Processing**: `json-20231013.jar` (already in lib/)
- **Logging**: Log4j2 (already in lib/)

No additional JAR files need to be downloaded for basic functionality.

### 5. Database Setup

The chatbot requires a new database table. Run the following SQL script (will be created in task 2):

```sql
-- This will be provided in the next task
-- CREATE TABLE ChatConversation (...)
```

### 6. Logging Configuration

Logs are configured in `src/conf/log4j2-chatbot.xml` and will be written to:

- `logs/chatbot.log` - General chatbot logs
- `logs/chatbot-error.log` - Error logs only
- `logs/chatbot-analytics.log` - Analytics and metrics

Make sure the `logs/` directory exists or will be created automatically.

### 7. Verify Setup

To verify the configuration is working:

1. Start your application server
2. Check the logs for any configuration errors
3. The chatbot will initialize on first use

### 8. Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `GEMINI_API_KEY` | (required) | Your Google Gemini API key |
| `CHATBOT_ENABLED` | `true` | Enable/disable chatbot functionality |
| `CHATBOT_MAX_HISTORY` | `50` | Maximum conversation history to keep |
| `CHATBOT_SESSION_TIMEOUT` | `1800` | Session timeout in seconds (30 min) |
| `CHATBOT_RESPONSE_CACHE_HOURS` | `24` | Cache duration for common responses |

## Troubleshooting

### API Key Not Found

**Error**: "GEMINI_API_KEY not configured"

**Solution**: 
- Verify the API key is set in `.env` file or system environment
- Restart your application server after setting environment variables
- Check that `.env` file is in the correct location (project root)

### Logging Not Working

**Error**: Logs not appearing in `logs/` directory

**Solution**:
- Ensure Log4j2 configuration is loaded
- Check file permissions for the `logs/` directory
- Verify Log4j2 JARs are in the classpath

### HTTP Client Issues

**Error**: `java.net.http` classes not found

**Solution**:
- Verify you're using Java 11 or higher
- Check your project's Java version in NetBeans project properties

## Security Best Practices

1. **Never commit API keys** to version control
2. **Use environment variables** in production
3. **Rotate API keys** periodically
4. **Monitor API usage** to detect unauthorized access
5. **Implement rate limiting** to prevent abuse

## Next Steps

After completing this setup:

1. Proceed to Task 2: Create database schema and models
2. Implement the service layer (Task 4-6)
3. Create the frontend UI (Task 8)
4. Test the complete integration

## Support

For issues or questions:
- Check the design document: `.kiro/specs/ai-chatbot-assistant/design.md`
- Review requirements: `.kiro/specs/ai-chatbot-assistant/requirements.md`
- Check implementation tasks: `.kiro/specs/ai-chatbot-assistant/tasks.md`
