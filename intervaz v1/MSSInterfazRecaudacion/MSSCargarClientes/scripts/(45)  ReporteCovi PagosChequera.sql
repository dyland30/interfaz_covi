
USE [GPCOV]
GO
/****** Object:  StoredProcedure [dbo].[ReporteCovi_PagosChequera]    Script Date: 10/12/2012 15:17:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteCovi_PagosChequera]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteCovi_PagosChequera]
GO


CREATE PROCEDURE [dbo].[ReporteCovi_PagosChequera]
	-- Add the parameters for the stored procedure here
	@fecini datetime,
	@fecfin datetime
AS
BEGIN
	-- =============================================
	-- Author:		Daniel Castillo
	-- Create date: 12/10/2012
	-- Description:	obtiene los pagos acumulados por dia
	-- en las chequeras virtuales de cada estacion
	-- =============================================
	SET NOCOUNT ON;
	select  convert(varchar,e.DATE1,103) as fechaProceso,
	sum(r.RCPTAMT) as monto,
	RTRIM(sit.LOCNDSCR) as estacion
	from CM20300 as r
	inner join SOP10103 as s
	on r.RCPTNMBR= s.DOCNUMBR
	inner join EXT00102 as e
	on RTRIM(e.PT_UD_Key) = rtrim(r.RCPTNMBR)+RTRIM(s.SOPNUMBE)
	inner join IV40700 as sit
	on case when charindex('_',r.CHEKBKID)>0 then  left(r.CHEKBKID,(charindex('_',r.CHEKBKID)-1)) else '' end = rtrim(sit.LOCNCODE)
	where e.DATE1 between convert(datetime,convert(varchar,@fecini,103),103) and convert(datetime,convert(varchar,@fecfin,103),103)
	AND r.CURNCYID = 'PEN'
	group by e.DATE1, sit.LOCNDSCR
	
	
END
GO
GRANT EXEC ON ReporteCovi_PagosChequera TO DYNGRP
GO
