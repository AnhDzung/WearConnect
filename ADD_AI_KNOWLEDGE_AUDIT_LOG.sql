-- =============================================
-- AI Knowledge Audit Log
-- Date: 2026-02-25
-- =============================================

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIKnowledgeAuditLogs'
)
BEGIN
    CREATE TABLE AIKnowledgeAuditLogs (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        DocID INT NULL,
        Action VARCHAR(20) NOT NULL, -- CREATE, UPDATE, DEACTIVATE
        OperatorID INT NOT NULL,
        OperatorRole VARCHAR(20) NULL,
        Summary NVARCHAR(500) NOT NULL,
        BeforeSnapshot NVARCHAR(MAX) NULL,
        AfterSnapshot NVARCHAR(MAX) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        IpAddress VARCHAR(64) NULL,
        UserAgent NVARCHAR(500) NULL,
        FOREIGN KEY (DocID) REFERENCES AIKnowledgeDocs(DocID),
        FOREIGN KEY (OperatorID) REFERENCES Accounts(AccountID)
    );

    CREATE INDEX IX_AIKnowledgeAuditLogs_DocID_CreatedAt ON AIKnowledgeAuditLogs(DocID, CreatedAt DESC);
    CREATE INDEX IX_AIKnowledgeAuditLogs_OperatorID_CreatedAt ON AIKnowledgeAuditLogs(OperatorID, CreatedAt DESC);
END
GO
