USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[INSERTAR_RESUMEN]    Script Date: 09/28/2012 11:29:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSERTAR_RESUMEN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[INSERTAR_RESUMEN]
GO


CREATE PROC [dbo].[INSERTAR_RESUMEN]
		   @codEstacion varchar(5),
           @serieCaseta varchar(5),
           @turno char(2),
           @procesados int,
           @errores int,
           @lote varchar(20)
AS

BEGIN
INSERT INTO [REPRESUMEN]
           ([codEstacion]
           ,[serieCaseta]
           ,[turno]
           ,[procesados]
           ,[errores]
           ,[lote])
     VALUES
           (@codEstacion
           ,@serieCaseta
           ,@turno
           ,@procesados
           ,@errores
           ,@lote)
END
