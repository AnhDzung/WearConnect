-- =============================================
-- AI Customer Support Foundation Schema
-- Date: 2026-02-24
-- =============================================

-- 1) Conversations
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIConversations'
)
BEGIN
    CREATE TABLE AIConversations (
        ConversationID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        Channel VARCHAR(30) NOT NULL DEFAULT 'WEB',
        Status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- OPEN, HANDED_OFF, CLOSED
        StartedAt DATETIME NOT NULL DEFAULT GETDATE(),
        LastMessageAt DATETIME NOT NULL DEFAULT GETDATE(),
        ClosedAt DATETIME NULL,
        FOREIGN KEY (UserID) REFERENCES Accounts(AccountID)
    );

    CREATE INDEX IX_AIConversations_UserID_Status ON AIConversations(UserID, Status);
END
GO

-- 2) Messages
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIMessages'
)
BEGIN
    CREATE TABLE AIMessages (
        MessageID INT IDENTITY(1,1) PRIMARY KEY,
        ConversationID INT NOT NULL,
        Role VARCHAR(20) NOT NULL, -- USER, ASSISTANT, SYSTEM
        Content NVARCHAR(MAX) NOT NULL,
        Intent VARCHAR(50) NULL,
        Confidence DECIMAL(5,4) NULL,
        ResponseSource VARCHAR(20) NULL, -- RULE, RAG, HUMAN
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (ConversationID) REFERENCES AIConversations(ConversationID)
    );

    CREATE INDEX IX_AIMessages_ConversationID_CreatedAt ON AIMessages(ConversationID, CreatedAt);
END
GO

-- 3) Knowledge Docs
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIKnowledgeDocs'
)
BEGIN
    CREATE TABLE AIKnowledgeDocs (
        DocID INT IDENTITY(1,1) PRIMARY KEY,
        Title NVARCHAR(300) NOT NULL,
        Category VARCHAR(50) NULL,
        Content NVARCHAR(MAX) NOT NULL,
        Tags NVARCHAR(300) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedBy INT NULL,
        FOREIGN KEY (UpdatedBy) REFERENCES Accounts(AccountID)
    );

    CREATE INDEX IX_AIKnowledgeDocs_Category_Active ON AIKnowledgeDocs(Category, IsActive);
END
GO

-- 4) Handoff Tickets
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIHandoffTickets'
)
BEGIN
    CREATE TABLE AIHandoffTickets (
        TicketID INT IDENTITY(1,1) PRIMARY KEY,
        ConversationID INT NOT NULL,
        UserID INT NOT NULL,
        Reason VARCHAR(100) NOT NULL,
        Priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH, URGENT
        Status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- OPEN, IN_PROGRESS, RESOLVED, CLOSED
        AssignedTo INT NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        ResolvedAt DATETIME NULL,
        FOREIGN KEY (ConversationID) REFERENCES AIConversations(ConversationID),
        FOREIGN KEY (UserID) REFERENCES Accounts(AccountID),
        FOREIGN KEY (AssignedTo) REFERENCES Accounts(AccountID)
    );

    CREATE INDEX IX_AIHandoffTickets_Status_Priority ON AIHandoffTickets(Status, Priority);
END
GO

-- 5) Message Feedback
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIMessageFeedback'
)
BEGIN
    CREATE TABLE AIMessageFeedback (
        FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
        MessageID INT NOT NULL,
        UserID INT NOT NULL,
        Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
        Note NVARCHAR(1000) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (MessageID) REFERENCES AIMessages(MessageID),
        FOREIGN KEY (UserID) REFERENCES Accounts(AccountID)
    );

    CREATE INDEX IX_AIMessageFeedback_MessageID ON AIMessageFeedback(MessageID);
END
GO
