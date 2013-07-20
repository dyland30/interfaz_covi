USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[COVI_OBTENER_CLASE_CLIENTE]    Script Date: 10/22/2012 12:17:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COVI_OBTENER_CLASE_CLIENTE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[COVI_OBTENER_CLASE_CLIENTE]
GO

CREATE PROC [dbo].[COVI_OBTENER_CLASE_CLIENTE]
	@IDCLASE VARCHAR(15)
AS
BEGIN
	-- =============================================
	-- Author:		Daniel Castillo
	-- Create date: 22/20/2012
	-- Description:	Obtiene la clase de cliente
	-- =============================================

	SELECT 
	CLASSID, 
	TAXSCHID PlanImpuestos, 
	SHIPMTHD MetodoEnvio, 
	PYMTRMID CondicionPago, 
	CURNCYID IdMoneda,
	RMCSHACC CuentaEfectivoID,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMCSHACC) AS CuentaEfectivo,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMARACC) AS CuentaxCobrar,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMSLSACC) AS CuentaVentas,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMCOSACC) AS CuentaCostoVenta,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMIVACC) AS CuentaInventario,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMTAKACC) AS CuentaCondicionesDtosTomados,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMAVACC) AS CuentaCondicionesDtosDisponibles,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMFCGACC) AS CuentaCargosFinancieros,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMWRACC) AS CuentaCancelaciones,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMOvrpymtWrtoffAcctIdx) AS CuentaCancelacionesSobrepago,
	(SELECT ACTNUMST FROM PlanCuentas where ACTINDX = R.RMSORACC) AS CuentaDevolucionesPedidosVenta,
	SALSTERR IdVendedor, 
	SLPRSNID IdTerritorio, 
	STMTCYCL CicloEstado
	FROM RM00201 as R
	WHERE RTRIM(CLASSID) = RTRIM(@IDCLASE)
END
GO
GRANT EXEC ON COVI_OBTENER_CLASE_CLIENTE TO DYNGRP
GO
