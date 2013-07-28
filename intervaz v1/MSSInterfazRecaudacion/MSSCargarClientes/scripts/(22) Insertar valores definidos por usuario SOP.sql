USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[InsertarValoresDefinidosUsuarioSOP]    Script Date: 09/28/2012 11:49:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarValoresDefinidosUsuarioSOP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertarValoresDefinidosUsuarioSOP]
GO

USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[InsertarValoresDefinidosUsuarioSOP]    Script Date: 09/28/2012 11:49:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[InsertarValoresDefinidosUsuarioSOP]
	-- Add the parameters for the stored procedure here
	@SopType smallint,
	@nroDoc varchar(21),
	@fec1 datetime, 
	@def1 varchar(21),
	@def2 varchar(21),
	@def3 varchar(21),
	@def4 varchar(21),
	@def5 varchar(21)
	
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	Permite ingresar valores definidos 
-- por el usuario en las facturas 
-- =============================================
	
	SET NOCOUNT ON;
	DECLARE @CONT INT
	-- buscar en la tabla para ver si 
	SELECT @CONT=COUNT(*) FROM SOP10106
	WHERE SOPNUMBE = @nroDoc
	
	IF @CONT>0 
	BEGIN
		--ACTUALIZAR
		UPDATE SOP10106
		SET 
			[USRDAT02]=@fec1
           ,[USERDEF1]= @def1
           ,[USERDEF2] =@def2
           ,[USRDEF03] =@def3
           ,[USRDEF04] =@def4
           ,[USRDEF05] =@def5
        WHERE [SOPNUMBE]= @nroDoc
		
	END
	ELSE 
	BEGIN
		--INSERTAR
		INSERT INTO SOP10106
           ([SOPTYPE]
           ,[SOPNUMBE]
           ,[USERDEF1]
           ,[USERDEF2]
           ,[USRDEF03]
           ,[USRDEF04]
           ,[USRDEF05]
           ,[USRDAT02]
           ,[CMMTTEXT])
     VALUES
           (@SopType
           ,@nroDoc
           ,@def1
           ,@def2
           ,@def3
           ,@def4
           ,@def5
           ,@fec1
           ,'');
	END
	

END

GO
GRANT EXEC ON InsertarValoresDefinidosUsuarioSOP TO DYNGRP
GO




