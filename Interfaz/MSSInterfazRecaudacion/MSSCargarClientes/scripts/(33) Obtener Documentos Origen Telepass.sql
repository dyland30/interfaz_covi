USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[ReporteConsumosTelepassObtenerDocumentos]    Script Date: 09/24/2012 14:11:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosTelepassObtenerDocumentos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosTelepassObtenerDocumentos]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosTelepassObtenerDocumentos]
	-- Add the parameters for the stored procedure here
	@fecInicio datetime,
	@fecFin datetime,
	@codestacion varchar(max),
	@idCliente varchar(max)
AS
BEGIN 
	-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Obtiene los documentos
-- de origen de telepass
-- =============================================
	SET NOCOUNT ON;
	-- crear tabla de documentos del cliente
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	DECLARE @Clientes TABLE(codCliente varchar(30))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	INSERT INTO @Clientes
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@idCliente)
		
	SELECT 
	DISTINCT RTRIM(s.SOPNUMBE) as CLAVE, RTRIM(s.SOPNUMBE) as SOPNUMBE 
	FROM GL20000 as g
	
	INNER JOIN COV_ADIC_CONS as ad
	on g.JRNENTRY = ad.jrnentry	
	INNER JOIN SOP30200 AS s
	on ad.numeroFactura = s.SOPNUMBE
		
	WHERE g.REFRENCE LIKE '%TEL:%'
	AND CRDTAMNT =0	
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM(LTRIM(S.CUSTNMBR))IN (select codCliente from @Clientes)
	AND ad.estacion IN (select codEstacion from @codEstaciones)

	UNION
	
	SELECT 
	DISTINCT RTRIM(s.SOPNUMBE) as CLAVE, RTRIM(s.SOPNUMBE) as SOPNUMBE 
	FROM GL10001 as g INNER JOIN GL10000 as h
	on g.JRNENTRY = h.JRNENTRY
	
	INNER JOIN COV_ADIC_CONS as ad
	on g.JRNENTRY = ad.jrnentry	
	INNER JOIN SOP30200 AS s
	on ad.numeroFactura = s.SOPNUMBE
		
	WHERE h.REFRENCE LIKE '%TEL:%'
	AND CRDTAMNT =0	
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM(LTRIM(S.CUSTNMBR))IN (select codCliente from @Clientes)
	AND ad.estacion IN (select codEstacion from @codEstaciones)

	
END

GO
GRANT EXEC ON ReporteConsumosTelepassObtenerDocumentos TO DYNGRP
GO
