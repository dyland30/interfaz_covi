USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[REPORTE_COVI_INFORME_ERRORES]    Script Date: 10/26/2012 10:52:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[REPORTE_COVI_INFORME_ERRORES]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[REPORTE_COVI_INFORME_ERRORES]
GO

CREATE PROC [dbo].[REPORTE_COVI_INFORME_ERRORES]
@Estacion varchar(max),
@fechaProceso datetime
AS
BEGIN

	DECLARE @tabla_estaciones as TABLE(
		codEstacion varchar(5)
	);	
	INSERT INTO @tabla_estaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Estacion)

SELECT [id]
      ,[regnum]
      ,[tipdoc]
      ,[nrodoc]
      ,[seriedoc]
      ,[seriecaseta]
      ,[seriedetraccion]
      ,[nrodetraccion]
      ,[nomcliente]
      ,[idcliente]
      ,[placa]
      ,[codestacion]
      ,convert(varchar,[fecdoc],103) fecdoc
      ,convert(varchar,[fecproceso],103) fecproceso
      ,[codarticulo]
      ,[cantidad]
      ,[preuni]
      ,[total]
      ,[igv]
      ,[totaldetraccion]
      ,[nrodocasociado]
      ,convert(varchar,[fechavencimientovale],103) fechavencimientovale
      ,[nrotag]
      ,[turno]
      ,[tipodocsunat]
      ,[destinooperacion]
      ,[nroasientocont]
      ,[observacion]
      ,[codlote]
  FROM DETALLEVENTAS_OLD
  WHERE lower(estado)='e'
  AND codestacion IN (select codestacion from @tabla_estaciones)
  AND convert(varchar,[fecproceso],103) = convert(varchar,@fechaProceso,103)

END
GO


