USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[OBTENER_RESUMEN]    Script Date: 09/28/2012 11:33:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OBTENER_RESUMEN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[OBTENER_RESUMEN]
GO

USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[OBTENER_RESUMEN]    Script Date: 09/28/2012 11:33:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[OBTENER_RESUMEN]
AS
BEGIN
SELECT [codEstacion]
      ,[serieCaseta]
      ,[turno]
      ,[procesados]
      ,[errores]
      ,[lote]
FROM [REPRESUMEN]
WHERE procesados>0 or errores>0
END


GO


