package chatbot.dao;

import chatbot.models.ChatMessage;
import chatbot.ChatbotLogger;
import dao.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for ChatConversation table
 * Handles all database operations related to chat messages
 */
public class ChatDAO extends DBContext {
    
    /**
     * Save a chat message to the database
     * 
     * @param message ChatMessage object to save
     * @return true if save successful, false otherwise
     */
    public boolean saveMessage(ChatMessage message) {
        String sql = "INSERT INTO ChatConversation (SessionID, UserID, MessageText, IsUserMessage, Intent, Language) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            ps.setString(1, message.getSessionId());
            
            // UserID can be null for guest users
            if (message.getUserId() != null) {
                ps.setInt(2, message.getUserId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            
            ps.setString(3, message.getMessageText());
            ps.setBoolean(4, message.isUserMessage());
            
            // Intent can be null
            if (message.getIntent() != null) {
                ps.setString(5, message.getIntent());
            } else {
                ps.setNull(5, Types.NVARCHAR);
            }
            
            ps.setString(6, message.getLanguage() != null ? message.getLanguage() : "vi");
            
            int rowsAffected = ps.executeUpdate();
            
            // Get the generated ConversationID
            if (rowsAffected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    message.setConversationId(rs.getInt(1));
                }
                
                ChatbotLogger.debug("Message saved successfully: " + message.getConversationId());
                return true;
            }
            
            return false;
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error saving message to database", e);
            return false;
        } finally {
            closeResources(rs, ps, conn);
        }
    }
    
    /**
     * Get conversation history for a session
     * 
     * @param sessionId Session ID to retrieve messages for
     * @param limit Maximum number of messages to retrieve (most recent)
     * @return List of ChatMessage objects, ordered by CreatedAt DESC
     */
    public List<ChatMessage> getConversationHistory(String sessionId, int limit) {
        List<ChatMessage> messages = new ArrayList<>();
        
        String sql = "SELECT TOP (?) ConversationID, SessionID, UserID, MessageText, " +
                     "IsUserMessage, Intent, Language, CreatedAt " +
                     "FROM ChatConversation " +
                     "WHERE SessionID = ? " +
                     "ORDER BY CreatedAt DESC";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setString(2, sessionId);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                ChatMessage message = new ChatMessage();
                message.setConversationId(rs.getInt("ConversationID"));
                message.setSessionId(rs.getString("SessionID"));
                
                int userId = rs.getInt("UserID");
                if (!rs.wasNull()) {
                    message.setUserId(userId);
                }
                
                message.setMessageText(rs.getString("MessageText"));
                message.setUserMessage(rs.getBoolean("IsUserMessage"));
                message.setIntent(rs.getString("Intent"));
                message.setLanguage(rs.getString("Language"));
                message.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                messages.add(message);
            }
            
            ChatbotLogger.debug("Retrieved " + messages.size() + " messages for session: " + sessionId);
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error retrieving conversation history", e);
        } finally {
            closeResources(rs, ps, conn);
        }
        
        // Reverse the list to get chronological order (oldest first)
        List<ChatMessage> chronological = new ArrayList<>();
        for (int i = messages.size() - 1; i >= 0; i--) {
            chronological.add(messages.get(i));
        }
        
        return chronological;
    }
    
    /**
     * Clear all messages for a session
     * 
     * @param sessionId Session ID to clear
     * @return true if clear successful, false otherwise
     */
    public boolean clearConversation(String sessionId) {
        String sql = "DELETE FROM ChatConversation WHERE SessionID = ?";
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            
            int rowsDeleted = ps.executeUpdate();
            
            ChatbotLogger.info("Cleared " + rowsDeleted + " messages for session: " + sessionId);
            return true;
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error clearing conversation", e);
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    /**
     * Get count of active sessions (sessions with messages in last 30 minutes)
     * Used for analytics
     * 
     * @return Number of active sessions
     */
    public int getActiveSessionsCount() {
        String sql = "SELECT COUNT(DISTINCT SessionID) AS ActiveSessions " +
                     "FROM ChatConversation " +
                     "WHERE CreatedAt >= DATEADD(MINUTE, -30, GETDATE())";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("ActiveSessions");
            }
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error getting active sessions count", e);
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return 0;
    }
    
    /**
     * Get total message count for a session
     * 
     * @param sessionId Session ID
     * @return Total number of messages in the session
     */
    public int getMessageCount(String sessionId) {
        String sql = "SELECT COUNT(*) AS MessageCount " +
                     "FROM ChatConversation " +
                     "WHERE SessionID = ?";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("MessageCount");
            }
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error getting message count", e);
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return 0;
    }
    
    /**
     * Get session start time
     * 
     * @param sessionId Session ID
     * @return Timestamp of first message, or null if session not found
     */
    public Timestamp getSessionStartTime(String sessionId) {
        String sql = "SELECT MIN(CreatedAt) AS StartTime " +
                     "FROM ChatConversation " +
                     "WHERE SessionID = ?";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getTimestamp("StartTime");
            }
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error getting session start time", e);
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return null;
    }
    
    /**
     * Get all sessions for a user
     * 
     * @param userId User ID
     * @param limit Maximum number of sessions to retrieve
     * @return List of session IDs
     */
    public List<String> getUserSessions(int userId, int limit) {
        List<String> sessions = new ArrayList<>();
        
        String sql = "SELECT DISTINCT TOP (?) SessionID " +
                     "FROM ChatConversation " +
                     "WHERE UserID = ? " +
                     "ORDER BY MAX(CreatedAt) DESC";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                sessions.add(rs.getString("SessionID"));
            }
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error getting user sessions", e);
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return sessions;
    }
    
    /**
     * Get intent statistics for analytics
     * 
     * @param limit Number of top intents to retrieve
     * @return List of intent names with their counts
     */
    public List<IntentStat> getTopIntents(int limit) {
        List<IntentStat> stats = new ArrayList<>();
        
        String sql = "SELECT TOP (?) Intent, COUNT(*) AS Count " +
                     "FROM ChatConversation " +
                     "WHERE Intent IS NOT NULL " +
                     "AND CreatedAt >= DATEADD(DAY, -7, GETDATE()) " +
                     "GROUP BY Intent " +
                     "ORDER BY Count DESC";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                IntentStat stat = new IntentStat();
                stat.intent = rs.getString("Intent");
                stat.count = rs.getInt("Count");
                stats.add(stat);
            }
            
        } catch (SQLException e) {
            ChatbotLogger.error("Error getting intent statistics", e);
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return stats;
    }
    
    /**
     * Helper class for intent statistics
     */
    public static class IntentStat {
        public String intent;
        public int count;
    }
    
    /**
     * Close database resources
     */
    private void closeResources(ResultSet rs, PreparedStatement ps, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                ChatbotLogger.warn("Error closing ResultSet", e);
            }
        }
        
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                ChatbotLogger.warn("Error closing PreparedStatement", e);
            }
        }
        
        if (conn != null) {
            DBContext.closeConnection(conn);
        }
    }
}
