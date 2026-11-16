USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.StockHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StockHistory (
        Id BIGINT IDENTITY PRIMARY KEY,
        BookId INT NOT NULL,
        OrderId INT NULL,
        BeforeQuantity BIGINT NOT NULL,
        AfterQuantity BIGINT NOT NULL,
        Actor NVARCHAR(150) NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT(SYSDATETIME())
    );
    CREATE INDEX IX_StockHistory_Book ON dbo.StockHistory(BookId, Id DESC);
END;
IF OBJECT_ID('dbo.OrderHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderHistory (
        Id BIGINT IDENTITY PRIMARY KEY,
        OrderId INT NOT NULL,
        PreviousStatus INT NULL,
        NewStatus INT NOT NULL,
        Actor NVARCHAR(150) NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT(SYSDATETIME())
    );
    CREATE INDEX IX_OrderHistory_Order ON dbo.OrderHistory(OrderId, Id DESC);
END;
COMMIT;
GO
