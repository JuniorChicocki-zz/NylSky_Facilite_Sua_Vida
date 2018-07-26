USE master
GO
--DROP PROCEDURE SP_LIST_FILES
GO
CREATE PROCEDURE SP_LIST_FILES(@V_DIR VARCHAR(100), @V_FILES VARCHAR(50))
AS
BEGIN
 
    CREATE TABLE #TMP_FILES
    (
        ID INT IDENTITY(1,1),
        FILE_NAME VARCHAR(500)
    );
	DECLARE @DIR VARCHAR(100);
	SET @DIR = @V_DIR;

    SET @V_DIR = 'DIR ' + @V_DIR + @V_FILES + '/B';
 
    INSERT #TMP_FILES EXEC XP_CMDSHELL @V_DIR;
	
	SELECT @DIR + FILE_NAME
    FROM #TMP_FILES
    WHERE FILE_NAME IS NOT NULL;

END;
GO
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO