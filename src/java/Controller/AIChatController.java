package Controller;

import Model.AIChatReply;
import Model.AIMessage;
import Service.AIChatService;
import java.util.List;

public class AIChatController {

    public static AIChatReply sendUserMessage(int userID, Integer conversationID, String userMessage) {
        return AIChatService.handleUserMessage(userID, conversationID, userMessage);
    }

    public static List<AIMessage> getConversationHistory(int userID, int conversationID, int limit) {
        return AIChatService.getConversationHistory(userID, conversationID, limit);
    }

    public static boolean submitAssistantFeedback(int userID, int assistantMessageID, int rating, boolean isHelpful, String note) {
        return AIChatService.submitAssistantFeedback(userID, assistantMessageID, rating, isHelpful, note);
    }
}
