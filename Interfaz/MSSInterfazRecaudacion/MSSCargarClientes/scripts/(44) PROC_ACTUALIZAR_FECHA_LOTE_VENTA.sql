USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[PROC_ACTUALIZAR_FECHA_LOTE_VENTA]    Script Date: 09/28/2012 12:44:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROC_ACTUALIZAR_FECHA_LOTE_VENTA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PROC_ACTUALIZAR_FECHA_LOTE_VENTA]
GO

CREATE PROC [dbo].[PROC_ACTUALIZAR_FECHA_LOTE_VENTA]
	@nroLote varchar(15),
	@FECHA DATETIME,
	@origen varchar(20)
	
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	permite agregar la fecha de contabilizacion
-- en el lote generado por la interfaz
-- =============================================

UPDATE sy00500
SET GLPOSTDT = @FECHA
WHERE RTRIM(BCHSOURC) = RTRIM(@origen)
AND RTRIM(BACHNUMB)= RTRIM(@nroLote)

END

GO
GRANT EXEC ON PROC_ACTUALIZAR_FECHA_LOTE_VENTA TO DYNGRP
GO
