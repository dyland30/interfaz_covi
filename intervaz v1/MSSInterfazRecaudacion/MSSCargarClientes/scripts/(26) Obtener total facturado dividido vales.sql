USE [GPTST]
GO
 
/****** Object:  UserDefinedFunction [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS]    Script Date: 09/25/2012 12:45:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_VALES]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_VALES]
GO


CREATE FUNCTION [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_VALES]
(
	@codestacion varchar(MAX),
	@nroDoc		varchar(30),
	@fecInicio DATETIME, 
	@fecFin DATETIME
)
RETURNS numeric(19,7)
AS
BEGIN

-- =============================================  
-- Author:  Daniel Castillo  
-- Create date: 10/09/2012  
-- Description: obtiene el total facturado dividido  
-- entre el numero de consumos  
-- =============================================  
 DECLARE @monto numeric(19,7)  
 DECLARE @cant numeric(19,7)  
 DECLARE @cant1 numeric(19,7)  
   
 DECLARE @mdividido numeric(19,7)  
   
 DECLARE @codEstaciones TABLE(codEstacion varchar(5))  
   
 INSERT INTO @codEstaciones  
 SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)  
   
   
 --cantidad de datos  
   
 SELECT @cant = COUNT(*)  
 FROM GL20000 as g  
   
 INNER JOIN COV_ADIC_CONS as ad  
 on g.JRNENTRY = ad.jrnentry   
 
 INNER JOIN t_tributarios_venta as tv
 on tv.LOC_Correlativo =RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1)
 and tv.LOC_NroDeSerie = LEFT(REPLACE(ad.numeroFactura,RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1),''),LEN(REPLACE(ad.numeroFactura,RIGHT(ad.numeroFactura,charindex('-',REVERSE(ad.numeroFactura))-1),''))-1) 
 and LOC_CodigoDocumento ='01' 
 
 INNER JOIN SOP30200 AS s  
 on tv.LOC_Numero_Documento = s.SOPNUMBE  
  
 WHERE g.REFRENCE LIKE '%VAL:%'  
 AND CRDTAMNT =0  
 AND ad.estacion IN (select codEstacion from @codEstaciones)  
 AND TRXDATE BETWEEN @fecInicio AND @fecFin  
 AND RTRIM(ad.numeroFactura) = RTRIM(@nroDoc)  
   
 -- sin contabilizar  
   
 SELECT @cant1 = COUNT(*)  
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
 AND ad.estacion IN (select codEstacion from @codEstaciones)  
 AND TRXDATE BETWEEN @fecInicio AND @fecFin  
 AND RTRIM(ad.numeroFactura) = RTRIM(@nroDoc)  
   
 IF @cant1 IS NULL  
 BEGIN  
  SET @cant1 =0  
 END  
   
 IF @cant IS NULL  
 BEGIN  
  set @cant =1.00  
 END  
 SET @cant = @cant+@cant1  
   
 ---------------------------------  
DECLARE @loc_serie AS VARCHAR(15)
DECLARE @loc_correlativo AS VARCHAR(21)
DECLARE @numeroDocumento AS VARCHAR(21)
set @loc_correlativo = RIGHT(@nroDoc,charindex('-',REVERSE(@nroDoc))-1)
set @loc_serie= LEFT(REPLACE(@nroDoc,@loc_correlativo,''),LEN(REPLACE(@nroDoc,@loc_correlativo,''))-1)

select @numeroDocumento=LOC_Numero_Documento from t_tributarios_venta
		where LOC_CodigoDocumento ='01'
		and  LOC_NroDeSerie =@loc_serie
		and LOC_Correlativo =@loc_correlativo
 
 SELECT @monto=tax.TAXDTSLS  
 FROM SOP30200 as s INNER JOIN SOP10105 as tax  
 on s.SOPNUMBE = tax.SOPNUMBE 
  
 WHERE tax.LNITMSEQ=0  
 AND s.SOPNUMBE = RTRIM(@numeroDocumento)  
   
 SET @mdividido = @monto/@cant      
 RETURN @mdividido  
END