USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[obtenerCabecerasFacturas]    Script Date: 10/25/2012 14:21:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[obtenerCabecerasFacturas]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[obtenerCabecerasFacturas]
GO


CREATE PROC [dbo].[obtenerCabecerasFacturas]
	@codEstacion varchar(5),
	@fecha datetime,
	@turno varchar(5)	
AS
BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	obtener las cabeceras de los documentos
-- de venta
-- =============================================
	SELECT DISTINCT tipdoc+nrodoc+seriedoc as dist,
	   [tipdoc]
      ,[nrodoc]
      ,[seriedoc]
      ,[seriecaseta]
      ,[nomcliente]
      ,[idcliente]
      ,[codestacion]
      ,[fecdoc]
      ,[fecproceso]
      ,[tipodocsunat]
      ,[estado]
      ,[codlote]
      ,[turno]
      ,[nrodocasociado]
	  ,[destinooperacion]
      
  FROM [DETALLEVENTAS]
  WHERE codestacion=@codEstacion AND
		convert(varchar,fecproceso,103)=convert(varchar,@fecha,103) AND
		turno=@turno AND upper(estado)='N'

END

GO


