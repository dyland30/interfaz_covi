USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[modificarDetalleDocumento]    Script Date: 09/28/2012 11:24:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[modificarDetalleDocumento]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[modificarDetalleDocumento]
GO

USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[modificarDetalleDocumento]    Script Date: 09/28/2012 11:24:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[modificarDetalleDocumento]
--parametros para la búsqueda
@tipodoc varchar(15),
@nrodoc varchar(25),
@seriedoc varchar(15),
@codarticulo varchar(30),
@estado char(1),
@codLote varchar(20),
@observacion varchar(1000),
@nroAsientoCont int
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	modificar estado de detalle de venta
-- =============================================
UPDATE DETALLEVENTAS
SET estado= @estado, codlote = @codLote,
observacion = @observacion, nroasientocont =@nroAsientoCont
WHERE tipdoc = @tipodoc and nrodoc = @nrodoc
and seriedoc = @seriedoc and codarticulo = @codarticulo
END



GO


