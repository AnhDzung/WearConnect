package config;

public class AIProviderConfig {

    private static final String DEFAULT_PROVIDER = "openai";
    private static final String DEFAULT_OPENAI_MODEL = "gpt-4o-mini";
    private static final String DEFAULT_GEMINI_MODEL = "gemini-1.5-flash";
    private static final int DEFAULT_TIMEOUT_SECONDS = 15;
    private static final double DEFAULT_TEMPERATURE = 0.3;
    private static final int DEFAULT_MAX_TOKENS = 450;

    public static String getProvider() {
        return getConfig("AI_PROVIDER", DEFAULT_PROVIDER).toLowerCase();
    }

    public static String getApiKey() {
        return getConfig("AI_API_KEY", "");
    }

    public static String getModel() {
        String provider = getProvider();
        if ("gemini".equals(provider)) {
            return getConfig("AI_MODEL", DEFAULT_GEMINI_MODEL);
        }
        return getConfig("AI_MODEL", DEFAULT_OPENAI_MODEL);
    }

    public static String getEndpoint() {
        String provider = getProvider();
        String customEndpoint = getConfig("AI_ENDPOINT", "");
        if (!customEndpoint.isBlank()) {
            return customEndpoint;
        }

        if ("gemini".equals(provider)) {
            return "https://generativelanguage.googleapis.com/v1beta/models/" + getModel() + ":generateContent";
        }
        return "https://api.openai.com/v1/chat/completions";
    }

    public static int getTimeoutSeconds() {
        return parseInt(getConfig("AI_TIMEOUT_SECONDS", String.valueOf(DEFAULT_TIMEOUT_SECONDS)), DEFAULT_TIMEOUT_SECONDS);
    }

    public static double getTemperature() {
        return parseDouble(getConfig("AI_TEMPERATURE", String.valueOf(DEFAULT_TEMPERATURE)), DEFAULT_TEMPERATURE);
    }

    public static int getMaxTokens() {
        return parseInt(getConfig("AI_MAX_TOKENS", String.valueOf(DEFAULT_MAX_TOKENS)), DEFAULT_MAX_TOKENS);
    }

    public static boolean isEnabled() {
        return !getApiKey().isBlank();
    }

    private static String getConfig(String key, String defaultValue) {
        String systemProperty = System.getProperty(key);
        if (systemProperty != null && !systemProperty.isBlank()) {
            return systemProperty.trim();
        }

        String env = System.getenv(key);
        if (env != null && !env.isBlank()) {
            return env.trim();
        }

        return defaultValue;
    }

    private static int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    private static double parseDouble(String value, double fallback) {
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }
}
