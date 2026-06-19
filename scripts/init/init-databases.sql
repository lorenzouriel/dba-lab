-- Creates AppDB database
-- Idempotent — safe to run multiple times

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'AppDB')
BEGIN
    CREATE DATABASE [AppDB];
    PRINT 'Created AppDB';
END
ELSE
    PRINT 'AppDB already exists';
GO

