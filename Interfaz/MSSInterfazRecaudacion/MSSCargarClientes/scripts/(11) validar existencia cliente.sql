USE [GPTST]
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'validarExistenciaCliente') AND type in (N'P', N'PC'))
DROP PROC validarExistenciaCliente
GO

CREATE PROC validarExistenciaCliente
	@idCliente varchar(25)
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	Permite validar si el cliente ya existe
-- en la tabla RM00101
-- =============================================
	select COUNT(*) as cantidadClientes from RM00101
	where CUSTNMBR = @idCliente
END

GO
GRANT EXEC ON validarExistenciaCliente TO DYNGRP
GO

