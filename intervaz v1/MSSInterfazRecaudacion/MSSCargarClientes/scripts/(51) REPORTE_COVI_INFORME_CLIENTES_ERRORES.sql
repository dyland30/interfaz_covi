USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[REPORTE_COVI_INFORME_CLIENTE_ERRORES]    Script Date: 10/25/2012 11:34:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[REPORTE_COVI_INFORME_CLIENTE_ERRORES]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[REPORTE_COVI_INFORME_CLIENTE_ERRORES]
GO


CREATE PROC [dbo].[REPORTE_COVI_INFORME_CLIENTE_ERRORES]
AS
BEGIN
SELECT [idcliente]
      ,[nomcliente]
      ,[nombrecorto]
      ,[direccion]
      ,[tipopersona]
      ,[tipodocumento]
      ,[nombre1]
      ,[nombre2]
      ,[apepaterno]
      ,[apematerno]
      ,[idVendedor]
      ,[idcondicionpago]
      ,[prioridad]
      ,[estado]
      ,[observacion]
  FROM [REPCLIENTE]
  WHERE LOWER(estado) = 'e'

END
