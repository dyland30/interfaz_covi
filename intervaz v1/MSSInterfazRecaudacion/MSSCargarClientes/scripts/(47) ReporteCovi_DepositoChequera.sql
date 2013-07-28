USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[ReporteCovi_DepositoChequera]    Script Date: 11/05/2012 09:38:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteCovi_DepositoChequera]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteCovi_DepositoChequera]
GO

CREATE PROCEDURE [dbo].[ReporteCovi_DepositoChequera]
	-- Add the parameters for the stored procedure here
	@fecini datetime,
	@fecfin datetime,
	@chequeras varchar(max)
	
AS
BEGIN
	-- =============================================
	-- Author:		Daniel Castillo
	-- Create date: 12/10/2012
	-- Description: reporte de deposito en chequeras 
	-- de fideicomiso
	-- =============================================
	SET NOCOUNT ON;
	
	DECLARE @tabla_chequeras as TABLE(
		codChequera varchar(30)
	);	
	INSERT INTO @tabla_chequeras
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@chequeras)
	
	declare @tabla_depositos as table(codEstacion varchar(5),fechaProc datetime,fecha datetime, monto numeric(19,5))
	
	-- ventana de entrada de transacciones bancarias
	insert into @tabla_depositos	
	select ad.IdEstacion as codEstacion, ad.FecProceso as fechaProc,t.TRXDATE as fecha, SUM(TRXAMNT) as monto 
	from CM20200 as t
	inner join COV_ADIC_TRANS_BANK as ad
	on RTRIM(t.CMTrxNum)=RTRIM(ad.CMTrxNum) 
	and t.CMTrxType = ad.CMTrxType
	and RTRIM(t.CHEKBKID) = RTRIM(AD.CHEKBKID)	 
	where t.CMTrxType = 5 and CURNCYID = 'PEN'
	and RTRIM(t.CHEKBKID) in (select codChequera from @tabla_chequeras)
	and ad.FecProceso between convert(datetime, CONVERT(varchar,@fecini,103),103) and convert(datetime, CONVERT(varchar,@fecfin,103),103)
	group by ad.IdEstacion,ad.FecProceso,t.TRXDATE
	
	-- ventana de entrada de transferencias bancarias
	insert into @tabla_depositos
	select ad.IdEstacion as codEstacion, ad.FecProceso as fechaProc, TRXDATE as fecha, sum(TRXAMNT) as monto 
	from CM20200 as t
	inner join COV_ADIC_TRANS_BANK as ad
	on RTRIM(t.CMTrxNum)=RTRIM(ad.CMTrxNum) 
	and t.CMTrxType = ad.CMTrxType
	and RTRIM(t.CHEKBKID) = RTRIM(AD.CHEKBKID)
	where t.CMTrxType=7 and CURNCYID = 'PEN'
	and rtrim(t.CHEKBKID) in (select codChequera from @tabla_chequeras)
	and ad.FecProceso between convert(datetime, CONVERT(varchar,@fecini,103),103) and convert(datetime, CONVERT(varchar,@fecfin,103),103)
	group by ad.IdEstacion,ad.FecProceso,t.TRXDATE  
	
	select convert(varchar,fechaProc,103) as fechaProc, convert(varchar,fecha,103) as fecha,RTRIM(sit.LOCNDSCR) as estacion, SUM(monto) as monto_deposito
	from @tabla_depositos as d
	inner join IV40700 as sit
	on RTRIM(d.codEstacion) = RTRIM(sit.LOCNCODE)
	group by fechaProc, fecha, sit.LOCNDSCR
	order by fecha
		
END

GO
GRANT EXEC ON ReporteCovi_DepositoChequera TO DYNGRP
GO