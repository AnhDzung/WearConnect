package Model;

import java.math.BigDecimal;

public class AIChatReply {
    private int conversationID;
    private int userMessageID;
    private int assistantMessageID;
    private String assistantMessage;
    private String intent;
    private BigDecimal confidence;
    private boolean handedOff;
    private String handoffReason;
    private String responseSource;
    private boolean redirectToAdvisor;
    private String redirectReason;

    public int getConversationID() {
        return conversationID;
    }

    public void setConversationID(int conversationID) {
        this.conversationID = conversationID;
    }

    public int getUserMessageID() {
        return userMessageID;
    }

    public void setUserMessageID(int userMessageID) {
        this.userMessageID = userMessageID;
    }

    public int getAssistantMessageID() {
        return assistantMessageID;
    }

    public void setAssistantMessageID(int assistantMessageID) {
        this.assistantMessageID = assistantMessageID;
    }

    public String getAssistantMessage() {
        return assistantMessage;
    }

    public void setAssistantMessage(String assistantMessage) {
        this.assistantMessage = assistantMessage;
    }

    public String getIntent() {
        return intent;
    }

    public void setIntent(String intent) {
        this.intent = intent;
    }

    public BigDecimal getConfidence() {
        return confidence;
    }

    public void setConfidence(BigDecimal confidence) {
        this.confidence = confidence;
    }

    public boolean isHandedOff() {
        return handedOff;
    }

    public void setHandedOff(boolean handedOff) {
        this.handedOff = handedOff;
    }

    public String getHandoffReason() {
        return handoffReason;
    }

    public void setHandoffReason(String handoffReason) {
        this.handoffReason = handoffReason;
    }

    public String getResponseSource() {
        return responseSource;
    }

    public void setResponseSource(String responseSource) {
        this.responseSource = responseSource;
    }

    public boolean isRedirectToAdvisor() {
        return redirectToAdvisor;
    }

    public void setRedirectToAdvisor(boolean redirectToAdvisor) {
        this.redirectToAdvisor = redirectToAdvisor;
    }

    public String getRedirectReason() {
        return redirectReason;
    }

    public void setRedirectReason(String redirectReason) {
        this.redirectReason = redirectReason;
    }
}
