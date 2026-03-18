package Controller;

import Model.AIChatReply;
import Model.AIConversation;
import Model.AIMessage;
import Service.AIChatService;
import java.util.List;

public class AIChatController {

    public static AIChatReply sendUserMessage(int userID, String userRole, Integer conversationID, String userMessage) {
        return AIChatService.handleUserMessage(userID, userRole, conversationID, userMessage);
    }

    public static List<AIMessage> getConversationHistory(int userID, int conversationID, int limit) {
        return AIChatService.getConversationHistory(userID, conversationID, limit);
    }

    public static List<AIConversation> getRecentConversations(int userID, int limit) {
        return AIChatService.getRecentConversations(userID, limit);
    }

    public static Integer createNewConversation(int userID) {
        return AIChatService.createNewConversation(userID);
    }

    public static boolean clearUserHistory(int userID) {
        return AIChatService.clearUserHistory(userID);
    }

    public static boolean deleteConversation(int userID, int conversationID) {
        return AIChatService.deleteConversation(userID, conversationID);
    }

    public static boolean conversationExistsForUser(int userID, int conversationID) {
        return AIChatService.conversationExistsForUser(userID, conversationID);
    }

    public static boolean submitAssistantFeedback(int userID, int assistantMessageID, int rating, boolean isHelpful, String note) {
        return AIChatService.submitAssistantFeedback(userID, assistantMessageID, rating, isHelpful, note);
    }
}
