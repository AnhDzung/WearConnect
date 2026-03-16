package DAO;

import Model.AIKnowledgeDoc;
import Model.AIKnowledgeAuditLog;
import config.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AIKnowledgeDAO {

    public static List<AIKnowledgeDoc> searchTopDocs(String query, int limit) {
        List<AIKnowledgeDoc> docs = new ArrayList<>();
        int safeLimit = limit <= 0 ? 3 : Math.min(limit, 8);
        String normalized = query == null ? "" : query.trim();
        String wildcard = "%" + normalized + "%";

        String sql = "SELECT TOP " + safeLimit + " DocID, Title, Category, Content, Tags, IsActive, UpdatedAt, "
                + "(CASE WHEN Title LIKE ? THEN 3 ELSE 0 END "
                + "+ CASE WHEN Category LIKE ? THEN 2 ELSE 0 END "
                + "+ CASE WHEN Tags LIKE ? THEN 2 ELSE 0 END "
                + "+ CASE WHEN Content LIKE ? THEN 1 ELSE 0 END) AS Score "
                + "FROM AIKnowledgeDocs "
                + "WHERE IsActive = 1 "
                + "AND (Title LIKE ? OR Category LIKE ? OR Tags LIKE ? OR Content LIKE ?) "
                + "ORDER BY Score DESC, UpdatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, wildcard);
            ps.setString(2, wildcard);
            ps.setString(3, wildcard);
            ps.setString(4, wildcard);
            ps.setString(5, wildcard);
            ps.setString(6, wildcard);
            ps.setString(7, wildcard);
            ps.setString(8, wildcard);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                docs.add(mapDoc(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return docs;
    }

    public static List<AIKnowledgeDoc> getActiveDocs(int limit) {
        List<AIKnowledgeDoc> docs = new ArrayList<>();
        int safeLimit = limit <= 0 ? 300 : Math.min(limit, 1000);

        String sql = "SELECT TOP " + safeLimit + " DocID, Title, Category, Content, Tags, IsActive, UpdatedAt, UpdatedBy "
                + "FROM AIKnowledgeDocs WHERE IsActive = 1 ORDER BY UpdatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                docs.add(mapDoc(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return docs;
    }

    public static List<AIKnowledgeDoc> getDocs(String keyword, boolean includeInactive, int limit) {
        List<AIKnowledgeDoc> docs = new ArrayList<>();
        int safeLimit = limit <= 0 ? 50 : Math.min(limit, 200);
        String normalized = keyword == null ? "" : keyword.trim();
        String wildcard = "%" + normalized + "%";

        String sql = "SELECT TOP " + safeLimit + " DocID, Title, Category, Content, Tags, IsActive, UpdatedAt, UpdatedBy "
                + "FROM AIKnowledgeDocs "
                + "WHERE (? = '' OR Title LIKE ? OR Category LIKE ? OR Tags LIKE ? OR Content LIKE ?) "
                + (includeInactive ? "" : "AND IsActive = 1 ")
                + "ORDER BY UpdatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalized);
            ps.setString(2, wildcard);
            ps.setString(3, wildcard);
            ps.setString(4, wildcard);
            ps.setString(5, wildcard);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                docs.add(mapDoc(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return docs;
    }

    public static AIKnowledgeDoc getDocById(int docID) {
        String sql = "SELECT DocID, Title, Category, Content, Tags, IsActive, UpdatedAt, UpdatedBy FROM AIKnowledgeDocs WHERE DocID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, docID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapDoc(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int createDoc(String title, String category, String content, String tags, int updatedBy) {
        String sql = "INSERT INTO AIKnowledgeDocs(Title, Category, Content, Tags, IsActive, UpdatedAt, UpdatedBy) VALUES (?, ?, ?, ?, 1, GETDATE(), ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title);
            ps.setString(2, category);
            ps.setString(3, content);
            ps.setString(4, tags);
            ps.setInt(5, updatedBy);
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

    public static boolean updateDoc(int docID, String title, String category, String content, String tags, boolean isActive, int updatedBy) {
        String sql = "UPDATE AIKnowledgeDocs SET Title = ?, Category = ?, Content = ?, Tags = ?, IsActive = ?, UpdatedAt = GETDATE(), UpdatedBy = ? WHERE DocID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, category);
            ps.setString(3, content);
            ps.setString(4, tags);
            ps.setBoolean(5, isActive);
            ps.setInt(6, updatedBy);
            ps.setInt(7, docID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean deactivateDoc(int docID, int updatedBy) {
        String sql = "UPDATE AIKnowledgeDocs SET IsActive = 0, UpdatedAt = GETDATE(), UpdatedBy = ? WHERE DocID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, docID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean insertAuditLog(Integer docID, String action, int operatorID, String operatorRole,
                                         String summary, String beforeSnapshot, String afterSnapshot,
                                         String ipAddress, String userAgent) {
        String sql = "INSERT INTO AIKnowledgeAuditLogs(DocID, Action, OperatorID, OperatorRole, Summary, BeforeSnapshot, AfterSnapshot, CreatedAt, IpAddress, UserAgent) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (docID == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, docID);
            }
            ps.setString(2, action);
            ps.setInt(3, operatorID);
            ps.setString(4, operatorRole);
            ps.setString(5, summary);
            ps.setString(6, beforeSnapshot);
            ps.setString(7, afterSnapshot);
            ps.setString(8, ipAddress);
            ps.setString(9, userAgent);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static List<AIKnowledgeAuditLog> getAuditLogs(Integer docID, Integer operatorID, String action, int limit) {
        List<AIKnowledgeAuditLog> logs = new ArrayList<>();
        int safeLimit = limit <= 0 ? 100 : Math.min(limit, 500);

        String sql = "SELECT TOP " + safeLimit + " AuditID, DocID, Action, OperatorID, OperatorRole, Summary, BeforeSnapshot, AfterSnapshot, CreatedAt, IpAddress, UserAgent "
                + "FROM AIKnowledgeAuditLogs "
                + "WHERE (? IS NULL OR DocID = ?) "
                + "AND (? IS NULL OR OperatorID = ?) "
                + "AND (? IS NULL OR Action = ?) "
                + "ORDER BY CreatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (docID == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, docID);
                ps.setInt(2, docID);
            }

            if (operatorID == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, operatorID);
                ps.setInt(4, operatorID);
            }

            if (action == null || action.trim().isEmpty()) {
                ps.setNull(5, java.sql.Types.VARCHAR);
                ps.setNull(6, java.sql.Types.VARCHAR);
            } else {
                String normalizedAction = action.trim().toUpperCase();
                ps.setString(5, normalizedAction);
                ps.setString(6, normalizedAction);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                logs.add(mapAuditLog(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }

    private static AIKnowledgeDoc mapDoc(ResultSet rs) throws SQLException {
        AIKnowledgeDoc doc = new AIKnowledgeDoc();
        doc.setDocID(rs.getInt("DocID"));
        doc.setTitle(rs.getString("Title"));
        doc.setCategory(rs.getString("Category"));
        doc.setContent(rs.getString("Content"));
        doc.setTags(rs.getString("Tags"));
        doc.setActive(rs.getBoolean("IsActive"));

        int updatedBy = rs.getInt("UpdatedBy");
        if (!rs.wasNull()) {
            doc.setUpdatedBy(updatedBy);
        }

        Timestamp updatedAt = rs.getTimestamp("UpdatedAt");
        if (updatedAt != null) {
            doc.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return doc;
    }

    private static AIKnowledgeAuditLog mapAuditLog(ResultSet rs) throws SQLException {
        AIKnowledgeAuditLog log = new AIKnowledgeAuditLog();
        log.setAuditID(rs.getInt("AuditID"));

        int mappedDocID = rs.getInt("DocID");
        if (!rs.wasNull()) {
            log.setDocID(mappedDocID);
        }

        log.setAction(rs.getString("Action"));
        log.setOperatorID(rs.getInt("OperatorID"));
        log.setOperatorRole(rs.getString("OperatorRole"));
        log.setSummary(rs.getString("Summary"));
        log.setBeforeSnapshot(rs.getString("BeforeSnapshot"));
        log.setAfterSnapshot(rs.getString("AfterSnapshot"));
        log.setIpAddress(rs.getString("IpAddress"));
        log.setUserAgent(rs.getString("UserAgent"));

        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) {
            log.setCreatedAt(createdAt.toLocalDateTime());
        }

        return log;
    }
}
