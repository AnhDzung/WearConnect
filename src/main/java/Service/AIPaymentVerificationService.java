package Service;

import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
import Model.PaymentVerificationCandidate;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import config.AIProviderConfig;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

public class AIPaymentVerificationService {

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    private static final DecimalFormat MONEY_FORMAT = new DecimalFormat("#,##0.00");
    private static final String NOTIF_TITLE_APPROVED = "Thanh toán được AI xác thực";
    private static final String NOTIF_TITLE_REJECTED = "Thanh toán bị AI từ chối";

    private AIPaymentVerificationService() {
    }

    public static ProcessingSummary processTimedOutSubmissions(int timeoutHours, int maxPerRun) {
        ProcessingSummary summary = new ProcessingSummary();

        if (!AIProviderConfig.isEnabled()) {
            summary.skipped = -1;
            return summary;
        }

        List<PaymentVerificationCandidate> candidates = RentalOrderDAO.getPaymentSubmittedCandidatesForAIVerification(timeoutHours, maxPerRun);
        if (candidates == null || candidates.isEmpty()) {
            return summary;
        }

        for (PaymentVerificationCandidate candidate : candidates) {
            if (candidate == null || candidate.getRentalOrderID() <= 0) {
                continue;
            }

            summary.processed++;
            try {
                AIDecision decision = evaluateCandidate(candidate);
                if (decision == null || decision.decision == null) {
                    summary.skipped++;
                    continue;
                }

                if ("VERIFY".equals(decision.decision)) {
                    if (approveOrder(candidate, decision.reason)) {
                        summary.verified++;
                    } else {
                        summary.skipped++;
                    }
                } else if ("REJECT".equals(decision.decision)) {
                    if (rejectOrder(candidate, decision.reason)) {
                        summary.rejected++;
                    } else {
                        summary.skipped++;
                    }
                } else {
                    summary.skipped++;
                }
            } catch (Exception ex) {
                System.err.println("[AIPaymentVerificationService] Failed to process order "
                        + candidate.getOrderCode() + ": " + ex.getMessage());
                summary.skipped++;
            }
        }

        return summary;
    }

    private static AIDecision evaluateCandidate(PaymentVerificationCandidate candidate) {
        String expectedTransferContent = safeText(candidate.getExpectedTransferContent());
        String providedTransferContent = safeText(candidate.getProvidedTransferContent());
        OcrSnapshot ocrSnapshot = extractFromProofImage(candidate);

        String effectiveTransferContent = providedTransferContent;
        if ((effectiveTransferContent.equals("N/A") || effectiveTransferContent.isBlank())
                && ocrSnapshot.transferContent != null && !ocrSnapshot.transferContent.isBlank()) {
            effectiveTransferContent = ocrSnapshot.transferContent;
        }

        if (!effectiveTransferContent.isBlank() && !"N/A".equalsIgnoreCase(effectiveTransferContent)) {
            if (!isTransferContentMatchingOrder(candidate.getRentalOrderID(), effectiveTransferContent)) {
                return new AIDecision("REJECT",
                        "Nội dung chuyển khoản không khớp RentalOrderID. expected="
                                + expectedTransferContent + ", provided=" + effectiveTransferContent);
            }
        }

        if (ocrSnapshot.amount > 0 && !isAmountMatching(candidate.getExpectedAmount(), ocrSnapshot.amount)) {
            return new AIDecision("REJECT",
                    "Số tiền OCR không khớp hệ thống. expected="
                            + MONEY_FORMAT.format(candidate.getExpectedAmount())
                            + ", ocr=" + MONEY_FORMAT.format(ocrSnapshot.amount));
        }

        if (ocrSnapshot.transferTime != null && candidate.getSubmittedAt() != null
                && ocrSnapshot.transferTime.isAfter(candidate.getSubmittedAt().plusMinutes(10))) {
            return new AIDecision("REJECT",
                    "Thời gian chuyển khoản trong ảnh xảy ra sau thời điểm gửi minh chứng.");
        }

        String systemPrompt = "Bạn là AI kiểm duyệt thanh toán cho WearConnect. "
                + "Bạn chỉ trả về JSON hợp lệ duy nhất với format: "
                + "{\"decision\":\"VERIFY|REJECT\",\"reason\":\"...\"}. "
                + "Quy tắc: VERIFY khi thông tin chuyển khoản hợp lệ và đủ căn cứ. "
                + "REJECT khi thông tin thiếu hoặc không hợp lệ.";

        String transferTimeText = candidate.getTransferTime() != null
                ? candidate.getTransferTime().format(DATE_TIME_FORMATTER)
                : "N/A";

        String submittedAtText = candidate.getSubmittedAt() != null
                ? candidate.getSubmittedAt().format(DATE_TIME_FORMATTER)
                : "N/A";

        String userPrompt = "Đánh giá giao dịch sau và quyết định VERIFY hoặc REJECT.\n"
                + "- Mã đơn hàng: " + candidate.getOrderCode() + "\n"
                + "- OrderID: " + candidate.getRentalOrderID() + "\n"
                + "- Thời gian chuyển khoản: " + transferTimeText + "\n"
                + "- Thời gian gửi thanh toán: " + submittedAtText + "\n"
                + "- Số tiền hệ thống kỳ vọng: " + MONEY_FORMAT.format(candidate.getExpectedAmount()) + "\n"
                + "- Số tiền đã ghi nhận: " + MONEY_FORMAT.format(candidate.getPaidAmount()) + "\n"
                + "- Số tiền OCR từ ảnh: " + (ocrSnapshot.amount > 0 ? MONEY_FORMAT.format(ocrSnapshot.amount) : "N/A") + "\n"
                + "- Thời gian OCR từ ảnh: "
                + (ocrSnapshot.transferTime != null ? ocrSnapshot.transferTime.format(DATE_TIME_FORMATTER) : "N/A") + "\n"
                + "- Nội dung chuyển khoản kỳ vọng: " + expectedTransferContent + "\n"
                + "- Nội dung chuyển khoản nhận được: " + effectiveTransferContent + "\n"
                + "- Nội dung OCR từ ảnh: " + safeText(ocrSnapshot.transferContent) + "\n"
                + "- Có ảnh minh chứng: " + (candidate.isHasProofImage() ? "Có" : "Không") + "\n"
                + "Chỉ trả JSON, không thêm giải thích ngoài JSON.";

        String rawReply = LLMClientService.generateReply(systemPrompt, Collections.emptyList(), userPrompt);
        if (rawReply == null || rawReply.isBlank()) {
            return null;
        }

        String jsonText = extractJsonObject(rawReply);
        if (jsonText == null) {
            return null;
        }

        JsonObject json = JsonParser.parseString(jsonText).getAsJsonObject();
        String decision = json.has("decision") ? json.get("decision").getAsString().trim().toUpperCase() : "";
        String reason = json.has("reason") ? json.get("reason").getAsString().trim() : "";

        if (!"VERIFY".equals(decision) && !"REJECT".equals(decision)) {
            return null;
        }

        return new AIDecision(decision, reason);
    }

    private static String extractJsonObject(String content) {
        int start = content.indexOf('{');
        int end = content.lastIndexOf('}');
        if (start < 0 || end <= start) {
            return null;
        }
        return content.substring(start, end + 1);
    }

    private static boolean approveOrder(PaymentVerificationCandidate candidate, String reason) {
        String notes = "AI_AUTO_VERIFY | "
                + "orderCode=" + candidate.getOrderCode()
                + " | transferTime=" + formatDateTime(candidate.getTransferTime())
                + " | amount=" + MONEY_FORMAT.format(candidate.getPaidAmount())
                + " | expectedContent=" + safeText(candidate.getExpectedTransferContent())
                + " | providedContent=" + safeText(candidate.getProvidedTransferContent())
                + " | reason=" + safeReason(reason);

        boolean statusUpdated = RentalOrderDAO.updateRentalOrderStatusWithNotes(candidate.getRentalOrderID(), "PAYMENT_VERIFIED", notes);
        if (!statusUpdated) {
            return false;
        }

        if (candidate.getPaymentID() > 0) {
            PaymentDAO.updatePaymentStatus(candidate.getPaymentID(), "COMPLETED");
        }

        RentalOrderDAO.markPaymentProcessed(candidate.getRentalOrderID());

        if (candidate.getRenterUserID() > 0) {
            NotificationService.createNotification(
                    candidate.getRenterUserID(),
                    NOTIF_TITLE_APPROVED,
                    "Đơn hàng " + candidate.getOrderCode() + " đã được hệ thống AI xác thực tự động.",
                    candidate.getRentalOrderID()
            );
        }

        if (candidate.getManagerID() > 0) {
            NotificationService.createNotification(
                    candidate.getManagerID(),
                    NOTIF_TITLE_APPROVED,
                    "Đơn hàng " + candidate.getOrderCode() + " đã được AI xác thực và sẵn sàng cho bước tiếp theo.",
                    candidate.getRentalOrderID()
            );
        }

        return true;
    }

    private static boolean rejectOrder(PaymentVerificationCandidate candidate, String reason) {
        String notes = "AI_AUTO_REJECT | "
                + "orderCode=" + candidate.getOrderCode()
                + " | transferTime=" + formatDateTime(candidate.getTransferTime())
                + " | amount=" + MONEY_FORMAT.format(candidate.getPaidAmount())
                + " | expectedContent=" + safeText(candidate.getExpectedTransferContent())
                + " | providedContent=" + safeText(candidate.getProvidedTransferContent())
                + " | reason=" + safeReason(reason);

        RentalOrderDAO.updatePaymentProofPath(candidate.getRentalOrderID(), null);
        boolean statusUpdated = RentalOrderDAO.updateRentalOrderStatusWithNotes(candidate.getRentalOrderID(), "PENDING_PAYMENT", notes);
        if (!statusUpdated) {
            return false;
        }

        if (candidate.getPaymentID() > 0) {
            PaymentDAO.updatePaymentStatus(candidate.getPaymentID(), "FAILED");
        }

        if (candidate.getRenterUserID() > 0) {
            NotificationService.createNotification(
                    candidate.getRenterUserID(),
                    NOTIF_TITLE_REJECTED,
                    "Đơn hàng " + candidate.getOrderCode()
                            + " chưa đạt điều kiện xác thực tự động. Vui lòng kiểm tra lại chứng từ thanh toán.",
                    candidate.getRentalOrderID()
            );
        }

        return true;
    }

    private static String formatDateTime(LocalDateTime time) {
        return time == null ? "N/A" : time.format(DATE_TIME_FORMATTER);
    }

    private static String safeReason(String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return "N/A";
        }
        String trimmed = reason.trim();
        return trimmed.length() > 500 ? trimmed.substring(0, 500) : trimmed;
    }

    private static String safeText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "N/A";
        }
        String trimmed = value.trim();
        return trimmed.length() > 200 ? trimmed.substring(0, 200) : trimmed;
    }

    private static boolean isTransferContentMatchingOrder(int rentalOrderId, String providedContent) {
        if (rentalOrderId <= 0 || providedContent == null || providedContent.trim().isEmpty()) {
            return false;
        }

        String digits = providedContent.replaceAll("\\D", "");
        if (digits.isEmpty()) {
            return false;
        }

        try {
            int providedOrderId = Integer.parseInt(digits);
            return providedOrderId == rentalOrderId;
        } catch (NumberFormatException ex) {
            return false;
        }
    }

    private static boolean isAmountMatching(double expected, double observed) {
        if (expected <= 0 || observed <= 0) {
            return false;
        }
        double diff = Math.abs(expected - observed);
        return diff <= Math.max(1000.0, expected * 0.01);
    }

    private static OcrSnapshot extractFromProofImage(PaymentVerificationCandidate candidate) {
        OcrSnapshot snapshot = new OcrSnapshot();
        if (candidate == null || !candidate.isHasProofImage()) {
            return snapshot;
        }

        String path = candidate.getProofImagePath();
        if (path == null || path.trim().isEmpty()) {
            return snapshot;
        }

        byte[] imageBytes = RentalOrderDAO.getAnyProofImageDataByPath(path);
        if (imageBytes == null || imageBytes.length == 0) {
            return snapshot;
        }

        String systemPrompt = "Bạn là bộ OCR cho ảnh chuyển khoản ngân hàng. "
                + "Trả về JSON duy nhất theo mẫu: "
                + "{\"amount\":number_or_0,\"transferTime\":\"dd/MM/yyyy HH:mm:ss|N/A\",\"transferContent\":\"...|N/A\"}.";

        String userPrompt = "Đọc ảnh minh chứng chuyển khoản và trích xuất: số tiền, thời gian chuyển khoản, nội dung chuyển khoản. "
                + "Nếu không thấy trường nào thì trả về N/A hoặc 0 tương ứng.";

        String raw = LLMClientService.generateReplyWithImage(systemPrompt, userPrompt, imageBytes, "image/png");
        if (raw == null || raw.isBlank()) {
            return snapshot;
        }

        String jsonText = extractJsonObject(raw);
        if (jsonText == null) {
            return snapshot;
        }

        try {
            JsonObject json = JsonParser.parseString(jsonText).getAsJsonObject();

            if (json.has("amount") && !json.get("amount").isJsonNull()) {
                try {
                    snapshot.amount = json.get("amount").getAsDouble();
                } catch (Exception ignored) {
                    snapshot.amount = parseAmountFromText(json.get("amount").getAsString());
                }
            }

            if (json.has("transferContent") && !json.get("transferContent").isJsonNull()) {
                snapshot.transferContent = safeText(json.get("transferContent").getAsString());
            }

            if (json.has("transferTime") && !json.get("transferTime").isJsonNull()) {
                snapshot.transferTime = parseDateTimeFlexible(json.get("transferTime").getAsString());
            }
        } catch (Exception ignored) {
            return snapshot;
        }

        return snapshot;
    }

    private static double parseAmountFromText(String amountText) {
        if (amountText == null || amountText.trim().isEmpty()) {
            return 0;
        }
        String numeric = amountText.replaceAll("[^0-9.]", "");
        if (numeric.isEmpty()) {
            return 0;
        }
        try {
            return Double.parseDouble(numeric);
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private static LocalDateTime parseDateTimeFlexible(String value) {
        if (value == null || value.trim().isEmpty() || "N/A".equalsIgnoreCase(value.trim())) {
            return null;
        }

        String v = value.trim();
        DateTimeFormatter[] formatters = new DateTimeFormatter[] {
                DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"),
                DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")
        };

        for (DateTimeFormatter formatter : formatters) {
            try {
                LocalDateTime dt = LocalDateTime.parse(v, formatter);
                return dt.truncatedTo(ChronoUnit.SECONDS);
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private static class OcrSnapshot {
        private double amount;
        private LocalDateTime transferTime;
        private String transferContent;
    }

    private static class AIDecision {
        private final String decision;
        private final String reason;

        private AIDecision(String decision, String reason) {
            this.decision = decision;
            this.reason = reason;
        }
    }

    public static class ProcessingSummary {
        private int processed;
        private int verified;
        private int rejected;
        private int skipped;

        public int getProcessed() {
            return processed;
        }

        public int getVerified() {
            return verified;
        }

        public int getRejected() {
            return rejected;
        }

        public int getSkipped() {
            return skipped;
        }
    }
}
