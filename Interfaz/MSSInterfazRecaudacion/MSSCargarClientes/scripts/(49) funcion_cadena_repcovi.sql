USE [REPCOVI]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_RPTPTO_SplitData]    Script Date: 10/24/2012 11:45:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_RPTPTO_SplitData]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FN_RPTPTO_SplitData]
GO

CREATE FUNCTION [dbo].[FN_RPTPTO_SplitData](@StrParam VARCHAR(MAX))
RETURNS @DATA TABLE(VALUE VARCHAR(50))
AS
	BEGIN

		
		DECLARE @Str VARCHAR(MAX)=''
		DECLARE @Part NVARCHAR(MAX)
		DECLARE @IND INT
		DECLARE @EIND INT 
		IF @StrParam IS NULL
			SET @StrParam = ''
		IF @StrParam <> ''
			SET @Str = ',' + @StrParam + ','
			
		SET @IND = CHARINDEX(',',@Str)
		set @EIND = 0
		
		WHILE(@IND != LEN(@STR))
		BEGIN
			SET  @EIND = ISNULL(((CHARINDEX(',', @Str, @IND + 1)) - @IND - 1), 0)			
			INSERT INTO @DATA(VALUE) VALUES(SUBSTRING(@Str, (@IND  + 1),  @EIND))			 
			SELECT @IND = ISNULL(CHARINDEX(',', @STR, @IND + 1), 0)
		END						
			
		RETURN 
		
	END

GO