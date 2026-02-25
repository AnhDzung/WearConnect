-- =============================================
-- AI Retrieval Feedback Loop Schema
-- Date: 2026-02-25
-- =============================================

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIRetrievalLogs'
)
BEGIN
    CREATE TABLE AIRetrievalLogs (
        RetrievalLogID INT IDENTITY(1,1) PRIMARY KEY,
        ConversationID INT NOT NULL,
        UserMessageID INT NOT NULL,
        AssistantMessageID INT NOT NULL,
        Intent VARCHAR(50) NULL,
        QueryText NVARCHAR(2000) NOT NULL,
        RetrievedDocIDs NVARCHAR(1000) NULL,
        RetrievedDocTitles NVARCHAR(2000) NULL,
        ResponseSource VARCHAR(20) NULL, -- LLM, RULE, HUMAN
        IsHelpful BIT NULL,
        FeedbackNote NVARCHAR(1000) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FeedbackAt DATETIME NULL,
        FOREIGN KEY (ConversationID) REFERENCES AIConversations(ConversationID),
        FOREIGN KEY (UserMessageID) REFERENCES AIMessages(MessageID),
        FOREIGN KEY (AssistantMessageID) REFERENCES AIMessages(MessageID)
    );

    CREATE INDEX IX_AIRetrievalLogs_AssistantMessageID ON AIRetrievalLogs(AssistantMessageID);
    CREATE INDEX IX_AIRetrievalLogs_ConversationID_CreatedAt ON AIRetrievalLogs(ConversationID, CreatedAt DESC);
END
GO

-- AIMessageFeedback already exists in ADD_AI_CHAT_SUPPORT.sql
-- This script only adds retrieval-level measurement to close optimization loop.
