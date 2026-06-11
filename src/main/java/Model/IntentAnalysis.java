package Model;

import java.math.BigDecimal;

public class IntentAnalysis {
    public final String intent;
    public final BigDecimal confidence;

    public IntentAnalysis(String intent, BigDecimal confidence) {
        this.intent = intent;
        this.confidence = confidence;
    }
}