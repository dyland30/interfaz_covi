USE [GPTST] 
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ObtenerEstacionesPeaje') AND type in (N'P', N'PC'))
DROP PROC ObtenerEstacionesPeaje
GO
CREATE PROC [dbo].[ObtenerEstacionesPeaje]
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Obtiene las estaciones de peaje
-- =============================================
	SELECT RTRIM(LTRIM(LOCNCODE)) AS LOCNCODE,RTRIM(LTRIM(LOCNDSCR)) AS LOCNDSCR FROM IV40700
	WHERE ADDRESS2='ESTPEA'
END


GO
GRANT EXEC ON ObtenerEstacionesPeaje TO DYNGRP
GO
