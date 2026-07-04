-- 1.0.0_SeedReferenceData.sql
-- Seeds initial reference data. Idempotent — checks before inserting.

SET QUOTED_IDENTIFIER ON;
GO

PRINT 'Running: 1.0.0_SeedReferenceData';

-- Seed demo user
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE [email] = N'demo@localhost')
BEGIN
    INSERT INTO [dbo].[users] ([username], [email], [phone_number])
    VALUES (N'demo', N'demo@localhost', N'000-000-0000');

    PRINT '  -> Demo user seeded';
END
ELSE
BEGIN
    PRINT '  -> Demo user already exists, skipping';
END
GO
