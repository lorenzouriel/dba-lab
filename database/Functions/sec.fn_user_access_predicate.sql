-- RLS predicate: a row is visible/writable when its owner matches the caller's session user_id.
-- The app must run: EXEC sp_set_session_context @key = N'user_id', @value = <id>, @read_only = 1;
-- db_owner members (migrations, datagen, DBAs) bypass the filter. Unset context => no rows (fail closed).
CREATE FUNCTION [sec].[fn_user_access_predicate] (@user_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS [access_granted]
    WHERE IS_MEMBER(N'db_owner') = 1
       OR @user_id = CAST(SESSION_CONTEXT(N'user_id') AS INT);
GO
