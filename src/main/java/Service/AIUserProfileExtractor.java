package Service;

import Model.UserProfile;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AIUserProfileExtractor {

    public static UserProfile extract(String normalizedMessage) {
        Integer heightCm = extractHeightCm(normalizedMessage);
        Integer weightKg = extractWeightKg(normalizedMessage);
        Long budgetVnd = extractBudgetVnd(normalizedMessage);
        return new UserProfile(heightCm, weightKg, budgetVnd);
    }

    private static Integer extractHeightCm(String normalizedMessage) {
        Matcher metricMatcher = Pattern.compile("\\b(1|2)\\s*(?:m|met)\\s*(\\d{1,2})?\\b").matcher(normalizedMessage);
        if (metricMatcher.find()) {
            int meter = Integer.parseInt(metricMatcher.group(1));
            String centimeterPart = metricMatcher.group(2);
            if (centimeterPart == null || centimeterPart.isBlank()) {
                return meter * 100;
            }
            int centimeter = Integer.parseInt(centimeterPart);
            if (centimeterPart.length() == 1) {
                centimeter = centimeter * 10;
            }
            return meter * 100 + centimeter;
        }
        Matcher cmMatcher = Pattern.compile("\\b(1\\d{2}|2\\d{2})\\s*cm\\b").matcher(normalizedMessage);
        if (cmMatcher.find()) {
            return Integer.parseInt(cmMatcher.group(1));
        }
        return null;
    }

    private static Integer extractWeightKg(String normalizedMessage) {
        Matcher weightMatcher = Pattern.compile("\\b(3\\d|[4-9]\\d|1\\d{2})\\s*(?:kg|kilogram|ky|can)\\b").matcher(normalizedMessage);
        if (weightMatcher.find()) {
            return Integer.parseInt(weightMatcher.group(1));
        }
        return null;
    }

    private static Long extractBudgetVnd(String normalizedMessage) {
        Matcher compactRangeMatcher = Pattern.compile("\\b(\\d{1,2})\\s*tr\\s*(\\d{1,2})?\\s*(?:-|den|toi)\\s*(\\d{1,2})\\s*tr\\s*(\\d{1,2})?\\b").matcher(normalizedMessage);
        if (compactRangeMatcher.find()) {
            long minValue = toCompactMillionValue(compactRangeMatcher.group(1), compactRangeMatcher.group(2));
            long maxValue = toCompactMillionValue(compactRangeMatcher.group(3), compactRangeMatcher.group(4));
            return Math.max(minValue, maxValue);
        }
        Matcher compactMillionMatcher = Pattern.compile("\\b(\\d{1,2})\\s*tr\\s*(\\d{1,2})\\b").matcher(normalizedMessage);
        if (compactMillionMatcher.find()) {
            return toCompactMillionValue(compactMillionMatcher.group(1), compactMillionMatcher.group(2));
        }
        Matcher millionAndThousandMatcher = Pattern.compile("\\b(\\d{1,2})\\s*trieu\\s*(\\d{1,3})\\s*nghin\\b").matcher(normalizedMessage);
        if (millionAndThousandMatcher.find()) {
            long million = Long.parseLong(millionAndThousandMatcher.group(1));
            long thousand = Long.parseLong(millionAndThousandMatcher.group(2));
            return million * 1_000_000L + thousand * 1_000L;
        }
        Matcher millionMatcher = Pattern.compile("\\b(\\d+(?:[\\.,]\\d+)?)\\s*trieu\\b").matcher(normalizedMessage);
        if (millionMatcher.find()) {
            double million = Double.parseDouble(millionMatcher.group(1).replace(',', '.'));
            return Math.round(million * 1_000_000L);
        }
        Matcher thousandMatcher = Pattern.compile("\\b(\\d{2,4})\\s*nghin\\b").matcher(normalizedMessage);
        if (thousandMatcher.find()) {
            long thousand = Long.parseLong(thousandMatcher.group(1));
            return thousand * 1_000L;
        }
        Matcher shorthandThousandMatcher = Pattern.compile("\\b(\\d{2,4})\\s*k\\b").matcher(normalizedMessage);
        if (shorthandThousandMatcher.find()) {
            long thousand = Long.parseLong(shorthandThousandMatcher.group(1));
            return thousand * 1_000L;
        }
        Matcher shorthandMillionMatcher = Pattern.compile("\\b(\\d+(?:[\\.,]\\d+)?)\\s*tr\\b").matcher(normalizedMessage);
        if (shorthandMillionMatcher.find()) {
            double million = Double.parseDouble(shorthandMillionMatcher.group(1).replace(',', '.'));
            return Math.round(million * 1_000_000L);
        }
        return null;
    }

    private static long toCompactMillionValue(String millionPart, String decimalPart) {
        long million = Long.parseLong(millionPart);
        if (decimalPart == null || decimalPart.isBlank()) {
            return million * 1_000_000L;
        }
        String digits = decimalPart.trim();
        return digits.length() == 1 ? million * 1_000_000L + Long.parseLong(digits) * 100_000L : million * 1_000_000L + Long.parseLong(digits.substring(0, 2)) * 10_000L;
    }
}