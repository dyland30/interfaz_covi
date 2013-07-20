/****** Object:  StoredProcedure [dbo].[PROC_COV_ADIC_CONS_BUSCAR_POR_ID]    Script Date: 10/26/2012 15:16:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROC_COV_ADIC_CONS_BUSCAR_POR_ID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PROC_COV_ADIC_CONS_BUSCAR_POR_ID]
GO

CREATE PROC [dbo].[PROC_COV_ADIC_CONS_BUSCAR_POR_ID]
@JRNENTRY INT
AS
BEGIN
SELECT [jrnentry]
      ,[turno]
      ,[estacion]
      ,[categoria]
      ,[numeroVale]
      ,[placa]
      ,[numeroFactura]
  FROM [COV_ADIC_CONS]
  WHERE jrnentry = @JRNENTRY

END



