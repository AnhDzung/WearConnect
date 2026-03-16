package DAO;

import Model.AIConversation;
import Model.AIMessage;
import config.DatabaseConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AIChatDAO {

    public static Integer createConversation(int userID, String channel) {
        String sql = "INSERT INTO AIConversations(UserID, Channel, Status, StartedAt, LastMessageAt) VALUES (?, ?, 'OPEN', GETDATE(), GETDATE())";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userID);
            ps.setString(2, channel == null ? "WEB" : channel);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static AIConversation getConversationByIdAndUser(int conversationID, int userID) {
        String sql = "SELECT ConversationID, UserID, Channel, Status, StartedAt, LastMessageAt, ClosedAt FROM AIConversations WHERE ConversationID = ? AND UserID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationID);
            ps.setInt(2, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapConversation(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static AIConversation getLatestOpenConversationByUser(int userID) {
        String sql = "SELECT TOP 1 ConversationID, UserID, Channel, Status, StartedAt, LastMessageAt, ClosedAt FROM AIConversations WHERE UserID = ? AND Status = 'OPEN' ORDER BY LastMessageAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapConversation(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<AIConversation> getRecentConversationsByUser(int userID, int limit) {
        List<AIConversation> conversations = new ArrayList<>();
        int safeLimit = limit <= 0 ? 20 : limit;
        String sql = "SELECT TOP " + safeLimit + " ConversationID, UserID, Channel, Status, StartedAt, LastMessageAt, ClosedAt "
                + "FROM AIConversations WHERE UserID = ? ORDER BY LastMessageAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                conversations.add(mapConversation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conversations;
    }

    public static int addMessage(int conversationID, String role, String content, String intent, BigDecimal confidence, String responseSource) {
        String sql = "INSERT INTO AIMessages(ConversationID, Role, Content, Intent, Confidence, ResponseSource, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, conversationID);
            ps.setString(2, role);
            ps.setString(3, content);
            ps.setString(4, intent);
            if (confidence == null) {
                ps.setNull(5, java.sql.Types.DECIMAL);
            } else {
                ps.setBigDecimal(5, confidence);
            }
            ps.setString(6, responseSource);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    touchConversation(conversationID);
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static List<AIMessage> getRecentMessages(int conversationID, int limit) {
        List<AIMessage> list = new ArrayList<>();
        int safeLimit = limit <= 0 ? 20 : limit;
        String sql = "SELECT TOP " + safeLimit + " MessageID, ConversationID, Role, Content, Intent, Confidence, ResponseSource, CreatedAt FROM AIMessages WHERE ConversationID = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(0, mapMessage(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static int createHandoffTicket(int conversationID, int userID, String reason, String priority) {
        String sql = "INSERT INTO AIHandoffTickets(ConversationID, UserID, Reason, Priority, Status, CreatedAt) VALUES (?, ?, ?, ?, 'OPEN', GETDATE())";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, conversationID);
            ps.setInt(2, userID);
            ps.setString(3, reason);
            ps.setString(4, priority == null ? "NORMAL" : priority);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    updateConversationStatus(conversationID, "HANDED_OFF");
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static int addMessageFeedback(int messageID, int userID, int rating, String note) {
        String sql = "INSERT INTO AIMessageFeedback(MessageID, UserID, Rating, Note, CreatedAt) VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, messageID);
            ps.setInt(2, userID);
            ps.setInt(3, rating);
            if (note == null || note.trim().isEmpty()) {
                ps.setNull(4, java.sql.Types.NVARCHAR);
            } else {
                ps.setString(4, note.trim());
            }

            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static int addRetrievalLog(int conversationID, int userMessageID, int assistantMessageID,
                                      String intent, String queryText, String retrievedDocIDs,
                                      String retrievedDocTitles, String responseSource) {
        String sql = "INSERT INTO AIRetrievalLogs(ConversationID, UserMessageID, AssistantMessageID, Intent, QueryText, RetrievedDocIDs, RetrievedDocTitles, ResponseSource, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, conversationID);
            ps.setInt(2, userMessageID);
            ps.setInt(3, assistantMessageID);
            ps.setString(4, intent);
            ps.setString(5, queryText);
            ps.setString(6, retrievedDocIDs);
            ps.setString(7, retrievedDocTitles);
            ps.setString(8, responseSource);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static boolean updateRetrievalFeedbackByAssistantMessage(int assistantMessageID, boolean isHelpful, String feedbackNote) {
        String sql = "UPDATE AIRetrievalLogs SET IsHelpful = ?, FeedbackNote = ?, FeedbackAt = GETDATE() WHERE AssistantMessageID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isHelpful);
            if (feedbackNote == null || feedbackNote.trim().isEmpty()) {
                ps.setNull(2, java.sql.Types.NVARCHAR);
            } else {
                ps.setString(2, feedbackNote.trim());
            }
            ps.setInt(3, assistantMessageID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean touchConversation(int conversationID) {
        String sql = "UPDATE AIConversations SET LastMessageAt = GETDATE() WHERE ConversationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updateConversationStatus(int conversationID, String status) {
        String sql = "UPDATE AIConversations SET Status = ?, ClosedAt = CASE WHEN ? = 'CLOSED' THEN GETDATE() ELSE ClosedAt END WHERE ConversationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setInt(3, conversationID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean clearUserHistory(int userID) {
        String deleteFeedbackSql = "DELETE FROM AIMessageFeedback WHERE MessageID IN ("
                + "SELECT MessageID FROM AIMessages WHERE ConversationID IN ("
                + "SELECT ConversationID FROM AIConversations WHERE UserID = ?))";
        String deleteRetrievalSql = "DELETE FROM AIRetrievalLogs WHERE ConversationID IN ("
                + "SELECT ConversationID FROM AIConversations WHERE UserID = ?)";
        String deleteHandoffSql = "DELETE FROM AIHandoffTickets WHERE ConversationID IN ("
                + "SELECT ConversationID FROM AIConversations WHERE UserID = ?)";
        String deleteMessagesSql = "DELETE FROM AIMessages WHERE ConversationID IN ("
                + "SELECT ConversationID FROM AIConversations WHERE UserID = ?)";
        String deleteConversationsSql = "DELETE FROM AIConversations WHERE UserID = ?";

        try (Connection conn = DatabaseConnection.getConnection()) {
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(deleteFeedbackSql)) {
                    ps.setInt(1, userID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteRetrievalSql)) {
                    ps.setInt(1, userID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteHandoffSql)) {
                    ps.setInt(1, userID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteMessagesSql)) {
                    ps.setInt(1, userID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteConversationsSql)) {
                    ps.setInt(1, userID);
                    ps.executeUpdate();
                }

                conn.commit();
                conn.setAutoCommit(previousAutoCommit);
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                conn.setAutoCommit(previousAutoCommit);
                throw ex;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean deleteConversationForUser(int userID, int conversationID) {
        String deleteFeedbackSql = "DELETE FROM AIMessageFeedback WHERE MessageID IN ("
                + "SELECT MessageID FROM AIMessages WHERE ConversationID = ?)";
        String deleteRetrievalSql = "DELETE FROM AIRetrievalLogs WHERE ConversationID = ?";
        String deleteHandoffSql = "DELETE FROM AIHandoffTickets WHERE ConversationID = ?";
        String deleteMessagesSql = "DELETE FROM AIMessages WHERE ConversationID = ?";
        String deleteConversationSql = "DELETE FROM AIConversations WHERE ConversationID = ? AND UserID = ?";

        try (Connection conn = DatabaseConnection.getConnection()) {
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(deleteFeedbackSql)) {
                    ps.setInt(1, conversationID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteRetrievalSql)) {
                    ps.setInt(1, conversationID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteHandoffSql)) {
                    ps.setInt(1, conversationID);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteMessagesSql)) {
                    ps.setInt(1, conversationID);
                    ps.executeUpdate();
                }

                int deletedConversations;
                try (PreparedStatement ps = conn.prepareStatement(deleteConversationSql)) {
                    ps.setInt(1, conversationID);
                    ps.setInt(2, userID);
                    deletedConversations = ps.executeUpdate();
                }

                conn.commit();
                conn.setAutoCommit(previousAutoCommit);
                return deletedConversations > 0;
            } catch (SQLException ex) {
                conn.rollback();
                conn.setAutoCommit(previousAutoCommit);
                throw ex;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private static AIConversation mapConversation(ResultSet rs) throws SQLException {
        AIConversation conversation = new AIConversation();
        conversation.setConversationID(rs.getInt("ConversationID"));
        conversation.setUserID(rs.getInt("UserID"));
        conversation.setChannel(rs.getString("Channel"));
        conversation.setStatus(rs.getString("Status"));

        Timestamp startedAt = rs.getTimestamp("StartedAt");
        if (startedAt != null) {
            conversation.setStartedAt(startedAt.toLocalDateTime());
        }

        Timestamp lastMessageAt = rs.getTimestamp("LastMessageAt");
        if (lastMessageAt != null) {
            conversation.setLastMessageAt(lastMessageAt.toLocalDateTime());
        }

        Timestamp closedAt = rs.getTimestamp("ClosedAt");
        if (closedAt != null) {
            conversation.setClosedAt(closedAt.toLocalDateTime());
        }

        return conversation;
    }

    private static AIMessage mapMessage(ResultSet rs) throws SQLException {
        AIMessage message = new AIMessage();
        message.setMessageID(rs.getInt("MessageID"));
        message.setConversationID(rs.getInt("ConversationID"));
        message.setRole(rs.getString("Role"));
        message.setContent(rs.getString("Content"));
        message.setIntent(rs.getString("Intent"));
        message.setConfidence(rs.getBigDecimal("Confidence"));
        message.setResponseSource(rs.getString("ResponseSource"));

        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) {
            message.setCreatedAt(createdAt.toLocalDateTime());
        }

        return message;
    }
}
