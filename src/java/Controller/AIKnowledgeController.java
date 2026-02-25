package Controller;

import Model.AIKnowledgeDoc;
import Model.AIKnowledgeAuditLog;
import Service.AIKnowledgeService;
import java.util.List;

public class AIKnowledgeController {

    public static List<AIKnowledgeDoc> getDocsForAdmin(String keyword, boolean includeInactive, int limit) {
        return AIKnowledgeService.getDocsForAdmin(keyword, includeInactive, limit);
    }

    public static AIKnowledgeDoc getDocById(int docID) {
        return AIKnowledgeService.getDocById(docID);
    }

    public static List<AIKnowledgeAuditLog> getAuditLogs(Integer docID, Integer operatorID, String action, int limit) {
        return AIKnowledgeService.getAuditLogs(docID, operatorID, action, limit);
    }

    public static int createDoc(String title, String category, String content, String tags, int updatedBy,
                                String operatorRole, String ipAddress, String userAgent) {
        return AIKnowledgeService.createDoc(title, category, content, tags, updatedBy, operatorRole, ipAddress, userAgent);
    }

    public static boolean updateDoc(int docID, String title, String category, String content, String tags,
                                    boolean isActive, int updatedBy, String operatorRole, String ipAddress,
                                    String userAgent) {
        return AIKnowledgeService.updateDoc(docID, title, category, content, tags, isActive, updatedBy, operatorRole, ipAddress, userAgent);
    }

    public static boolean deactivateDoc(int docID, int updatedBy, String operatorRole, String ipAddress,
                                        String userAgent) {
        return AIKnowledgeService.deactivateDoc(docID, updatedBy, operatorRole, ipAddress, userAgent);
    }
}
