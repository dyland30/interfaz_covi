USE [GPCOV]
GO
/****** Object:  StoredProcedure [dbo].[ReporteRecaudacionPeaje_trabajo]    Script Date: 10/11/2012 17:15:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteRecaudacionPeaje_trabajo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteRecaudacionPeaje_trabajo]
GO



CREATE PROC [dbo].[ReporteRecaudacionPeaje_trabajo]
@Estacion varchar(max),
@Turno varchar(max),
@FechaInicio datetime, 
@FechaFin datetime
AS
BEGIN
	-- CREAR TABLA TEMPORAL
	DECLARE @tabla_temp as TABLE(
		estacion varchar(5),
		turno varchar(3),
		fecha datetime,
		monto numeric(19,2),
		diff varchar(10)
	);
	--tabla de turnos
	DECLARE @tabla_turnos as TABLE(turno varchar(3));
	--POBLAR TURNO
	INSERT INTO @tabla_turnos
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Turno)
	-- tabla de estaciones
	DECLARE @tabla_estaciones as TABLE(
		codEstacion varchar(5)
	);	
	INSERT INTO @tabla_estaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Estacion)
	
	-- insertar tickets sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'TK' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = LTRIM(RTRIM(def.USRDEF04))
	WHERE CUSTNMBR <> 'DETRACCION' AND f.DOCID not like '%SOBR%'
	AND  f.DOCID not like '%DISC%'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	-- insertar sobrantes sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'SOB' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND f.DOCID like '%SOBR%'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	-- insertar discrepancias sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'DIS' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND  f.DOCID like '%DISC%'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	
	-- insertar detraccion sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as MONTO,
	'DET' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	where CUSTNMBR = 'DETRACCION'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	
	-- en lugar de consumos de vales y telepass insertar el monto facturado
	--telepass
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTEL' as DIFF
	FROM  SOP10200 AS d INNER JOIN SOP10100 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TEL%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  
	
	
	--tags
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTAG' as DIFF
	FROM  SOP10200 AS d INNER JOIN SOP10100 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TAG%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  

	--telepass internet
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTINT' as DIFF
	FROM  SOP10200 AS d INNER JOIN SOP10100 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TELEPASS.INTERNET%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  


	
	-- insertar consumos de vales sin contabilizar
	--INSERT INTO @tabla_temp
	--SELECT convert(varchar(5),T.ESTACION) AS ESTACION,convert(varchar(3),T.TURNO) AS TURNO,
	-- T.TRXDATE AS FECHA,convert(numeric(19,2),SUM(t.MONTO)) AS MONTO,
	-- 'VAL' as diff
	--FROM
	--(SELECT 
	--	(SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) AS ESTACION,
	--	(SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=1) AS TURNO,
	--	h.TRXDATE,DEBITAMT as MONTO
	--	FROM GL10001 as g inner join GL10000 AS h
	--	ON g.JRNENTRY = h.JRNENTRY 
	--	WHERE h.REFRENCE LIKE '%VAL:%'
	--	AND CRDTAMNT =0
	--	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) IS NOT NULL
	--	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=1) IS NOT NULL
	--) AS t
	--GROUP BY T.TURNO,T.TRXDATE, T.ESTACION
	
	-- INSERTAR CONSUMOS DE TELEPASS
	--INSERT INTO @tabla_temp
	--SELECT convert(varchar(5),T.ESTACION) AS ESTACION,convert(varchar(3),T.TURNO) AS TURNO,
	-- T.TRXDATE AS FECHA,convert(numeric(19,2),SUM(t.MONTO)) AS MONTO,
	-- 'TEL' as diff
	--FROM
	--(SELECT 
	--	(SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) AS ESTACION,
	--	(SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=1) AS TURNO,
	--	TRXDATE,DEBITAMT as MONTO
	--	FROM  GL10001 as g inner join GL10000 AS h
	--	ON g.JRNENTRY = h.JRNENTRY
	--	WHERE h.REFRENCE LIKE '%TEL:%'
	--	AND CRDTAMNT =0
	--	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) IS NOT NULL
	--	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	--	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=1) IS NOT NULL
	--) AS t
	--GROUP BY T.TURNO,T.TRXDATE, T.ESTACION
	
	select estacion,turno,CONVERT(VARCHAR,t.fecha,103) as fecha,
	sum(CASE WHEN diff ='TK' THEN monto ELSE 0 END) AS RecaudacionTickets,
	sum(CASE WHEN diff ='DET' THEN monto ELSE 0 END) AS Detracciones,
	sum(CASE WHEN diff ='FTEL' THEN monto ELSE 0 END) AS Telepass,
	sum(CASE WHEN diff ='FTAG' THEN monto ELSE 0 END) AS TAG,
	sum(CASE WHEN diff ='FTINT' THEN monto ELSE 0 END) AS TelepassInternet,
	--sum(CASE WHEN diff ='VAL' THEN monto ELSE 0 END) AS Vales,
	--sum(CASE WHEN diff ='TEL' THEN monto ELSE 0 END) AS Telepass,
	sum(CASE WHEN diff ='DIS' THEN monto ELSE 0 END) AS Discrepancia,
	sum(CASE WHEN diff ='SOB' THEN monto ELSE 0 END) AS Sobrante
	
	from @tabla_temp as t
	where fecha between @FechaInicio and @FechaFin and estacion in (select CodEstacion from  @tabla_estaciones)
	and turno in (select turno from @tabla_turnos)
	group by turno,fecha,estacion
	order by t.fecha desc, turno asc
END

GO


