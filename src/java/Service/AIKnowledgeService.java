package Service;

import DAO.AIKnowledgeDAO;
import Model.AIKnowledgeAuditLog;
import Model.AIKnowledgeDoc;
import com.google.gson.Gson;
import java.text.Normalizer;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class AIKnowledgeService {

    private static final int DEFAULT_TOP_K = 3;
    private static final int MAX_DOC_LENGTH = 500;
    private static final int MAX_TITLE_LENGTH = 300;
    private static final int MAX_CATEGORY_LENGTH = 50;
    private static final int MAX_TAGS_LENGTH = 300;
    private static final int MAX_CONTENT_LENGTH = 10000;
    private static final String DEFAULT_CATEGORY = "GENERAL";
    private static final int RETRIEVAL_CANDIDATE_LIMIT = 300;
    private static final int RETRIEVAL_MIN_TOKEN_LENGTH = 2;
    private static final Gson GSON = new Gson();
    private static final Set<String> STOP_WORDS = new HashSet<>(Arrays.asList(
            "la", "là", "va", "và", "cho", "toi", "tôi", "ban", "bạn", "minh", "mình",
            "nhu", "như", "duoc", "được", "co", "có", "khong", "không", "cua", "của",
            "ve", "về", "trong", "ngoai", "ngoài", "voi", "với", "giup", "giúp", "can", "cần"
    ));

    private static final Map<String, Set<String>> INTENT_CATEGORY_MAP = new HashMap<>();

    static {
        INTENT_CATEGORY_MAP.put("PAYMENT_SUPPORT", new HashSet<>(Arrays.asList("payment", "deposit", "bank", "thanh toán", "cọc")));
        INTENT_CATEGORY_MAP.put("RETURN_REFUND", new HashSet<>(Arrays.asList("return_refund", "refund", "trả hàng", "hoàn tiền")));
        INTENT_CATEGORY_MAP.put("SIZE_ADVICE", new HashSet<>(Arrays.asList("size_advice", "size", "kích cỡ")));
        INTENT_CATEGORY_MAP.put("BOOKING_SUPPORT", new HashSet<>(Arrays.asList(
            "booking_support", "booking_process", "booking", "quy trình", "đặt thuê", "thuê đồ"
        )));
        INTENT_CATEGORY_MAP.put("LISTING_SUPPORT", new HashSet<>(Arrays.asList(
            "listing_support", "listing", "đăng tải", "đăng sản phẩm", "quản lý trang phục", "thêm trang phục"
        )));
        INTENT_CATEGORY_MAP.put("ORDER_SUPPORT", new HashSet<>(Arrays.asList(
            "order_support", "order", "đơn hàng", "tracking", "trạng thái đơn"
        )));
    }

    public static String buildKnowledgeContext(String userQuery) {
        return buildKnowledgeContext(userQuery, null);
    }

    public static String buildKnowledgeContext(String userQuery, String intent) {
        List<AIKnowledgeDoc> docs = retrieveTopKnowledgeDocs(userQuery, intent, DEFAULT_TOP_K);
        return buildKnowledgeContextFromDocs(docs);
    }

    public static List<AIKnowledgeDoc> getTopDocsForChat(String userQuery, String intent, int topK) {
        int safeTopK = topK <= 0 ? DEFAULT_TOP_K : Math.min(topK, 8);
        return retrieveTopKnowledgeDocs(userQuery, intent, safeTopK);
    }

    public static String buildKnowledgeContextFromDocs(List<AIKnowledgeDoc> docs) {
        if (docs.isEmpty()) {
            return "";
        }

        StringBuilder context = new StringBuilder();
        context.append("Nguồn tri thức nội bộ liên quan:\n");

        int index = 1;
        for (AIKnowledgeDoc doc : docs) {
            context.append(index)
                    .append(") ")
                    .append(nonNull(doc.getTitle(), "Untitled"));

            if (doc.getCategory() != null && !doc.getCategory().isBlank()) {
                context.append(" [").append(doc.getCategory()).append("]");
            }

            context.append("\n");

            String trimmedContent = truncate(doc.getContent(), MAX_DOC_LENGTH);
            context.append(trimmedContent).append("\n\n");
            index++;
        }

        return context.toString().trim();
    }

    private static List<AIKnowledgeDoc> retrieveTopKnowledgeDocs(String userQuery, String intent, int topK) {
        List<AIKnowledgeDoc> candidates = AIKnowledgeDAO.getActiveDocs(RETRIEVAL_CANDIDATE_LIMIT);
        if (candidates.isEmpty()) {
            return Collections.emptyList();
        }

        List<String> tokens = tokenize(userQuery);
        String normalizedQuery = normalizeText(userQuery);

        List<ScoredDoc> scoredDocs = new ArrayList<>();
        for (AIKnowledgeDoc doc : candidates) {
            double score = scoreDoc(doc, normalizedQuery, tokens, intent);
            if (score > 0) {
                scoredDocs.add(new ScoredDoc(doc, score));
            }
        }

        if (scoredDocs.isEmpty()) {
            int safeTopK = Math.max(1, topK);
            return candidates.subList(0, Math.min(safeTopK, candidates.size()));
        }

        scoredDocs.sort(Comparator.comparingDouble(ScoredDoc::getScore).reversed());

        List<AIKnowledgeDoc> result = new ArrayList<>();
        int safeTopK = Math.max(1, topK);
        for (ScoredDoc scoredDoc : scoredDocs) {
            result.add(scoredDoc.getDoc());
            if (result.size() >= safeTopK) {
                break;
            }
        }
        return result;
    }

    private static double scoreDoc(AIKnowledgeDoc doc, String normalizedQuery, List<String> tokens, String intent) {
        String title = normalizeText(doc.getTitle());
        String category = normalizeText(doc.getCategory());
        String tags = normalizeText(doc.getTags());
        String content = normalizeText(doc.getContent());

        double score = 0.0;

        if (!normalizedQuery.isBlank()) {
            if (title.contains(normalizedQuery)) {
                score += 4.0;
            }
            if (tags.contains(normalizedQuery)) {
                score += 3.0;
            }
            if (content.contains(normalizedQuery)) {
                score += 1.0;
            }
        }

        for (String token : tokens) {
            if (title.contains(token)) {
                score += 2.2;
            }
            if (tags.contains(token)) {
                score += 1.8;
            }
            if (category.contains(token)) {
                score += 1.2;
            }
            if (content.contains(token)) {
                score += 0.4;
            }
        }

        score += intentCategoryBoost(intent, category);
        score += recencyBoost(doc.getUpdatedAt());
        return score;
    }

    private static double intentCategoryBoost(String intent, String normalizedCategory) {
        if (intent == null || intent.isBlank() || normalizedCategory == null || normalizedCategory.isBlank()) {
            return 0.0;
        }

        Set<String> mappedCategories = INTENT_CATEGORY_MAP.get(intent);
        if (mappedCategories == null || mappedCategories.isEmpty()) {
            return 0.0;
        }

        for (String keyword : mappedCategories) {
            if (normalizedCategory.contains(normalizeText(keyword))) {
                return 3.0;
            }
        }
        return 0.0;
    }

    private static double recencyBoost(LocalDateTime updatedAt) {
        if (updatedAt == null) {
            return 0.0;
        }
        long days = ChronoUnit.DAYS.between(updatedAt, LocalDateTime.now());
        if (days <= 3) {
            return 0.8;
        }
        if (days <= 14) {
            return 0.4;
        }
        return 0.0;
    }

    private static List<String> tokenize(String text) {
        String normalized = normalizeText(text);
        if (normalized.isBlank()) {
            return Collections.emptyList();
        }

        String[] parts = normalized.split("\\s+");
        List<String> tokens = new ArrayList<>();
        for (String token : parts) {
            if (token.length() < RETRIEVAL_MIN_TOKEN_LENGTH) {
                continue;
            }
            if (STOP_WORDS.contains(token)) {
                continue;
            }
            tokens.add(token);
            if (tokens.size() >= 10) {
                break;
            }
        }
        return tokens;
    }

    private static String normalizeText(String text) {
        if (text == null) {
            return "";
        }

        String lowered = text.toLowerCase(Locale.ROOT).trim();
        String removedAccents = Normalizer.normalize(lowered, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        return removedAccents.replaceAll("[^\\p{Alnum}\\s]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    public static List<AIKnowledgeDoc> getDocsForAdmin(String keyword, boolean includeInactive, int limit) {
        return AIKnowledgeDAO.getDocs(keyword, includeInactive, limit);
    }

    public static AIKnowledgeDoc getDocById(int docID) {
        return AIKnowledgeDAO.getDocById(docID);
    }

    public static List<AIKnowledgeAuditLog> getAuditLogs(Integer docID, Integer operatorID, String action, int limit) {
        return AIKnowledgeDAO.getAuditLogs(docID, operatorID, action, limit);
    }

    public static int createDoc(String title, String category, String content, String tags, int updatedBy,
                                String operatorRole, String ipAddress, String userAgent) {
        AIKnowledgeDoc normalized = normalizeDocInput(title, category, content, tags);
        if (normalized == null || updatedBy <= 0) {
            return -1;
        }

        int createdDocID = AIKnowledgeDAO.createDoc(
                normalized.getTitle(),
                normalized.getCategory(),
                normalized.getContent(),
                normalized.getTags(),
                updatedBy
        );

        if (createdDocID <= 0) {
            return -1;
        }

        AIKnowledgeDoc afterDoc = AIKnowledgeDAO.getDocById(createdDocID);
        AIKnowledgeDAO.insertAuditLog(
                createdDocID,
                "CREATE",
                updatedBy,
                normalizeNullable(operatorRole),
                "Created knowledge doc: " + normalized.getTitle(),
                null,
                toSnapshot(afterDoc),
                normalizeNullable(ipAddress),
                normalizeNullable(userAgent)
        );

        return createdDocID;
    }

    public static boolean updateDoc(int docID, String title, String category, String content, String tags,
                                    boolean isActive, int updatedBy, String operatorRole, String ipAddress,
                                    String userAgent) {
        AIKnowledgeDoc normalized = normalizeDocInput(title, category, content, tags);
        if (docID <= 0 || normalized == null || updatedBy <= 0) {
            return false;
        }

        AIKnowledgeDoc beforeDoc = AIKnowledgeDAO.getDocById(docID);
        if (beforeDoc == null) {
            return false;
        }

        boolean updated = AIKnowledgeDAO.updateDoc(
                docID,
                normalized.getTitle(),
                normalized.getCategory(),
                normalized.getContent(),
                normalized.getTags(),
                isActive,
                updatedBy
        );

        if (!updated) {
            return false;
        }

        AIKnowledgeDoc afterDoc = AIKnowledgeDAO.getDocById(docID);
        AIKnowledgeDAO.insertAuditLog(
                docID,
                "UPDATE",
                updatedBy,
                normalizeNullable(operatorRole),
                "Updated knowledge doc: " + normalized.getTitle(),
                toSnapshot(beforeDoc),
                toSnapshot(afterDoc),
                normalizeNullable(ipAddress),
                normalizeNullable(userAgent)
        );

        return true;
    }

    public static boolean deactivateDoc(int docID, int updatedBy, String operatorRole, String ipAddress,
                                        String userAgent) {
        if (docID <= 0 || updatedBy <= 0) {
            return false;
        }

        AIKnowledgeDoc beforeDoc = AIKnowledgeDAO.getDocById(docID);
        if (beforeDoc == null) {
            return false;
        }

        boolean deactivated = AIKnowledgeDAO.deactivateDoc(docID, updatedBy);
        if (!deactivated) {
            return false;
        }

        AIKnowledgeDoc afterDoc = AIKnowledgeDAO.getDocById(docID);
        AIKnowledgeDAO.insertAuditLog(
                docID,
                "DEACTIVATE",
                updatedBy,
                normalizeNullable(operatorRole),
                "Deactivated knowledge doc: " + beforeDoc.getTitle(),
                toSnapshot(beforeDoc),
                toSnapshot(afterDoc),
                normalizeNullable(ipAddress),
                normalizeNullable(userAgent)
        );

        return true;
    }

    private static String truncate(String text, int maxLength) {
        if (text == null || text.isBlank()) {
            return "Không có nội dung.";
        }

        String normalized = text.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= maxLength) {
            return normalized;
        }

        return normalized.substring(0, maxLength).trim() + "...";
    }

    private static String nonNull(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value;
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private static String normalizeNullable(String value) {
        if (isBlank(value)) {
            return null;
        }
        return value.trim();
    }

    private static AIKnowledgeDoc normalizeDocInput(String title, String category, String content, String tags) {
        String normalizedTitle = normalizeNullable(title);
        String normalizedCategory = normalizeNullable(category);
        String normalizedContent = normalizeNullable(content);
        String normalizedTags = normalizeNullable(tags);

        if (isBlank(normalizedCategory)) {
            normalizedCategory = DEFAULT_CATEGORY;
        }

        if (isBlank(normalizedTitle) || isBlank(normalizedContent)) {
            return null;
        }

        if (normalizedTitle.length() > MAX_TITLE_LENGTH || normalizedContent.length() > MAX_CONTENT_LENGTH) {
            return null;
        }

        if (normalizedCategory != null && normalizedCategory.length() > MAX_CATEGORY_LENGTH) {
            normalizedCategory = normalizedCategory.substring(0, MAX_CATEGORY_LENGTH).trim();
        }

        if (normalizedTags != null && normalizedTags.length() > MAX_TAGS_LENGTH) {
            normalizedTags = normalizedTags.substring(0, MAX_TAGS_LENGTH).trim();
        }

        AIKnowledgeDoc doc = new AIKnowledgeDoc();
        doc.setTitle(normalizedTitle);
        doc.setCategory(normalizedCategory);
        doc.setContent(normalizedContent);
        doc.setTags(normalizedTags);
        return doc;
    }

    private static String toSnapshot(AIKnowledgeDoc doc) {
        if (doc == null) {
            return null;
        }
        return GSON.toJson(doc);
    }

    private static class ScoredDoc {
        private final AIKnowledgeDoc doc;
        private final double score;

        private ScoredDoc(AIKnowledgeDoc doc, double score) {
            this.doc = doc;
            this.score = score;
        }

        private AIKnowledgeDoc getDoc() {
            return doc;
        }

        private double getScore() {
            return score;
        }
    }
}
