USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[ReporteRecaudacionPeaje]    Script Date: 09/28/2012 09:58:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteRecaudacionPeaje_Vales]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteRecaudacionPeaje_Vales]
GO

CREATE PROC [dbo].[ReporteRecaudacionPeaje_Vales]
@Estacion varchar(max),
@FechaInicio datetime, 
@FechaFin datetime
AS
BEGIN
	-- CREAR TABLA TEMPORAL
	DECLARE @tabla_temp as TABLE(
		estacion varchar(30),
		turno varchar(30),
		fecha datetime,
		monto numeric(19,2),
		diff varchar(30)
	);
	
	-- tabla de estaciones
	DECLARE @tabla_estaciones as TABLE(
		codEstacion varchar(5)
	);	
	INSERT INTO @tabla_estaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Estacion)
	
	
	-- en lugar de consumos de vales y telepass insertar el monto facturado
	--VALES PREPAGO
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FVAL' as DIFF
	FROM  SOP30300 AS d INNER JOIN SOP30200 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%VPREP%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  
	
	
	select estacion,turno,CONVERT(VARCHAR,t.fecha,103) as fecha,
	sum(CASE WHEN diff ='FVAL' THEN monto ELSE 0 END) AS FacturacionVales	
	from @tabla_temp as t
	where fecha between @FechaInicio and @FechaFin and estacion in (select CodEstacion from  @tabla_estaciones)
	group by turno,fecha,estacion
	order by t.fecha desc, turno asc
END
GO
GRANT EXEC ON ReporteRecaudacionPeaje_Vales TO DYNGRP
GO

