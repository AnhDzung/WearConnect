package Service;

import Model.IntentAnalysis;
import java.math.BigDecimal;

public class AIIntentAnalyzer {

    public static IntentAnalysis analyze(String normalizedMessage) {
        if (containsAny(normalizedMessage,
                "quy trinh dang tai", "dang tai quan ao", "dang san pham", "them trang phuc", "listing", "dang bai")) {
            return new IntentAnalysis("LISTING_SUPPORT", new BigDecimal("0.8800"));
        }

        if (containsAny(normalizedMessage,
            "ao dai", "thue ao dai", "ao dai truyen thong", "ao dai cach tan")) {
            return new IntentAnalysis("RENTAL_ADVICE", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "tu van", "goi y", "phoi do", "phong cach", "style", "chon do",
            "di du tiec", "du tiec", "tiec", "tiec sang trong", "sang trong", "thanh lich", "ca tinh", "vui nhon",
            "tiec sinh nhat", "tiec cong ty", "chup anh", "di chup anh", "quay phim", "concept",
            "trang phuc", "outfit", "set do", "bo de thue", "thue di")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.9000"));
        }

        if (containsAny(normalizedMessage,
                "tim san pham", "muon tim san pham", "tim ao", "tim dam", "tim vest", "tim ao khoac", "tim ao dai")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.8200"));
        }

        if (containsAny(normalizedMessage,
                "ngan sach", "budget", "trieu", "nghin", "khoang", "tam", "duoi", "tren")) {
            return new IntentAnalysis("CONSULT_ADVICE", new BigDecimal("0.7600"));
        }

        if (containsAny(normalizedMessage, "hoan tien", "refund", "tra hang", "return", "khieu nai")) {
            return new IntentAnalysis("RETURN_REFUND", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "quy trinh", "dat thue", "quy trinh thue", "quy trinh dat thue", "thu tuc thue", "thue do")) {
            return new IntentAnalysis("BOOKING_SUPPORT", new BigDecimal("0.8600"));
        }

        if (containsAny(normalizedMessage,
            "don hang", "order", "trang thai", "giao hang")) {
            return new IntentAnalysis("ORDER_SUPPORT", new BigDecimal("0.8200"));
        }

        if (containsAny(normalizedMessage, "size", "kich co", "vong", "cao", "nang")) {
            return new IntentAnalysis("SIZE_ADVICE", new BigDecimal("0.7800"));
        }

        if (containsAny(normalizedMessage, "thanh toan", "payment", "chuyen khoan", "coc")) {
            return new IntentAnalysis("PAYMENT_SUPPORT", new BigDecimal("0.8000"));
        }

        return new IntentAnalysis("GENERAL_FAQ", new BigDecimal("0.5500"));
    }

    private static boolean containsAny(String source, String... keywords) {
        for (String keyword : keywords) {
            if (source.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}