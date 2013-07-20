USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[ReporteCovi_ObtenerChequerasFD]    Script Date: 10/12/2012 15:46:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteCovi_ObtenerChequerasFD]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteCovi_ObtenerChequerasFD]
GO

CREATE PROCEDURE [dbo].[ReporteCovi_ObtenerChequerasFD]
	-- Add the parameters for the stored procedure here
AS
BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 12/10/2012
-- Description:	obtiene la lista de chequeras
-- de fideicomiso
-- =============================================

	SET NOCOUNT ON;
	SELECT CHEKBKID,DSCRIPTN FROM CM00100
	WHERE RTRIM(CMUSRDF2) ='FD'
END

GO
GRANT EXEC ON ReporteCovi_ObtenerChequerasFD TO DYNGRP
GO
