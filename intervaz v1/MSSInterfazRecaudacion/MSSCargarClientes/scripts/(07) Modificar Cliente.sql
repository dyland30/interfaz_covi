USE [REPCOVI]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'modificarClienteRep') AND type in (N'P', N'PC'))
DROP PROC modificarClienteRep
GO

CREATE PROC modificarClienteRep
--parametros para la búsqueda
@idCliente varchar(20),
@estado char(1),
@observacion varchar(1000)
AS
BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	modificar estado de cliente
-- =============================================

UPDATE REPCLIENTE
SET estado= @estado,observacion = @observacion
WHERE idcliente = @idCliente;

END
