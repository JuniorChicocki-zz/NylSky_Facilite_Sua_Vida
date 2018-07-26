DROP PROCEDURE sp_restaurar;
GO
CREATE PROCEDURE sp_restaurar(@posicao VARCHAR(6))
AS BEGIN
	CREATE TABLE #TMP_FILES(ID INT IDENTITY(1,1), FILE_NAME VARCHAR(500));
	INSERT #TMP_FILES EXEC XP_CMDSHELL 'DIR C:\CS\Backup\*.bak/B';
	
	DECLARE @SQL nvarchar(max)
	SET @SQL =
			'IF  NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N''ces_adm@pos'')
				BEGIN
					CREATE DATABASE ces_adm@pos
				END;

			IF  NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N''ces_est@pos'')
				BEGIN
					CREATE DATABASE ces_est@pos
				END;

			IF  NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N''ces_exp@pos'')
				BEGIN
					CREATE DATABASE ces_exp@pos
				END;

			IF  NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N''ces_mobile@pos'')
				BEGIN
					CREATE DATABASE ces_mobile@pos
				END;

			DECLARE @ADM VARCHAR(50)
			DECLARE @EST VARCHAR(50)
			DECLARE @EXP VARCHAR(50)
			DECLARE @MOB VARCHAR(50)

			SELECT @ADM = ''C:\CS\BACKUP\'' + FILE_NAME FROM #TMP_FILES WHERE ID = 1;
			SELECT @EST = ''C:\CS\BACKUP\'' + FILE_NAME FROM #TMP_FILES WHERE ID = 2;
			SELECT @EXP = ''C:\CS\BACKUP\'' + FILE_NAME FROM #TMP_FILES WHERE ID = 3;
			SELECT @MOB = ''C:\CS\BACKUP\'' + FILE_NAME FROM #TMP_FILES WHERE ID = 4;

			RESTORE DATABASE ces_adm@pos FROM DISK = @ADM WITH REPLACE 
					,MOVE ''ces_adm_dat'' TO N''C:\CS\DADOS\ces_adm@pos.mdf'', 
					 MOVE ''ces_adm_log'' TO ''C:\CS\DADOS\ces_adm@pos.ldf''
					;

			RESTORE DATABASE ces_est@pos FROM DISK = @EST WITH REPLACE
					,MOVE ''ces_est''		TO ''C:\CS\DADOS\ces_est@pos.mdf'', 
					 MOVE ''ces_est_log'' TO ''C:\CS\DADOS\ces_est@pos.ldf''
					;

			RESTORE DATABASE ces_exp@pos FROM DISK = @EXP WITH REPLACE
					,MOVE ''EXPRESS_dat'' TO ''C:\CS\DADOS\ces_exp@pos.mdf'', 
					 MOVE ''EXPRESS_log'' TO ''C:\CS\DADOS\ces_exp@pos.ldf''
					;

			RESTORE DATABASE ces_mobile@pos FROM DISK = @MOB WITH REPLACE
					,MOVE ''ces_mobile_monitor''	 TO ''C:\CS\DADOS\ces_mobile@pos.mdf'', 
					 MOVE ''ces_mobile_monitor_log'' TO ''C:\CS\DADOS\ces_mobile@pos.ldf''
					; '
	SET @SQL = REPLACE(@SQL,'@pos', @posicao );
		
	EXEC sp_executesql @SQL	;
	
	DROP TABLE #TMP_FILES 

	SELECT 'Restauração concluida! Banco: ces_adm' + @posicao 
END;
