USE [GPCOV]
GO 

/****** Object:  StoredProcedure [dbo].[ReporteConsumosValesObtenerClientes]    Script Date: 09/24/2012 12:19:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosValesObtenerClientes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosValesObtenerClientes]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosValesObtenerClientes]
	-- Add the parameters for the stored procedure here  
 @fecInicio datetime,  
 @fecFin datetime,  
 @codestacion varchar(max)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 --SET NOCOUNT ON;  
 ---- crear tabla de documentos del cliente  
 DECLARE @codEstaciones TABLE(codEstacion varchar(5))  
   
 INSERT INTO @codEstaciones  
 SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)  
   
   
 SELECT   
 DISTINCT RTRIM(s.CUSTNMBR) as CUSTNMBR ,RTRIM(s.CUSTNAME) as CUSTNAME  
 FROM GL20000 as g  
   
 INNER JOIN COV_ADIC_CONS as ad  
 on g.JRNENTRY = ad.jrnentry 
 
 INNER JOIN t_tributarios_venta as tv
 on tv.LOC_Correlativo =RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1)
 and tv.LOC_NroDeSerie = LEFT(REPLACE(ad.numeroFactura,RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1),''),LEN(REPLACE(ad.numeroFactura,RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1),''))-1) 
 and LOC_CodigoDocumento ='01' 
   
 INNER JOIN SOP30200 AS s  
 on tv.LOC_Correlativo = s.SOPNUMBE  
    
 WHERE g.REFRENCE LIKE '%VAL:%'  
 AND CRDTAMNT =0   
 AND TRXDATE BETWEEN @fecInicio AND @fecFin  
 AND ad.estacion IN (select codEstacion from @codEstaciones)  
   
 UNION  
   
 SELECT   
 DISTINCT RTRIM(s.CUSTNMBR) as CUSTNMBR ,RTRIM(s.CUSTNAME) as CUSTNAME  
 FROM GL10001 as g INNER JOIN GL10000 as h  
 on g.JRNENTRY = h.JRNENTRY  
   
 INNER JOIN COV_ADIC_CONS as ad  
 on g.JRNENTRY = ad.jrnentry
 
 INNER JOIN t_tributarios_venta as tv
 on tv.LOC_Correlativo =RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1)
 and tv.LOC_NroDeSerie = LEFT(REPLACE(ad.numeroFactura,RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1),''),LEN(REPLACE(ad.numeroFactura,RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1),''))-1) 
 and LOC_CodigoDocumento ='01' 
 INNER JOIN SOP30200 AS s  
 on tv.LOC_Numero_Documento = s.SOPNUMBE  
 WHERE h.REFRENCE LIKE '%VAL:%'  
 AND CRDTAMNT =0   
 AND TRXDATE BETWEEN @fecInicio AND @fecFin  
 AND ad.estacion IN (select codEstacion from @codEstaciones)  

END

GO
GRANT EXEC ON ReporteConsumosObtenerClientes TO DYNGRP
GO
