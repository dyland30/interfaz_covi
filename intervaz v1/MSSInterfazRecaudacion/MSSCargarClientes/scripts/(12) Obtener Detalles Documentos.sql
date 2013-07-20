USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[obtenerDetalleDocumentos]    Script Date: 10/25/2012 14:23:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[obtenerDetalleDocumentos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[obtenerDetalleDocumentos]
GO

CREATE PROC [dbo].[obtenerDetalleDocumentos]
	@tipdoc varchar(15),
	@serieDoc varchar(15),
	@nroDoc varchar(25)	
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	procedimiento que permite obtener los
-- detalles de documento por cabecera
-- =============================================
	SELECT [tipdoc]
      ,[nrodoc]
      ,[seriedoc]
      ,[seriecaseta]
      ,[seriedetraccion]
      ,[nrodetraccion]
      ,[nomcliente]
      ,[idcliente]
      ,[sentido]
      ,[placa]
      ,[codestacion]
      ,[fecdoc]
      ,[fecproceso]
      ,[codarticulo]
      ,[cantidad]
      ,[preuni]
      ,[total]
      ,[igv]
      ,[totaldetraccion]
      ,[nrodocasociado]
      ,[fechavencimientovale]
      ,[nrotag]
      ,[turno]
      ,[tipodocsunat]
      ,[destinooperacion]
      ,[nroasientocont]
      ,[estado]
      ,[observacion]
      ,[codlote]
  FROM [DETALLEVENTAS]
  WHERE tipdoc=@tipdoc AND
		seriedoc= @serieDoc AND
		nrodoc=@nroDoc	
END



GO


