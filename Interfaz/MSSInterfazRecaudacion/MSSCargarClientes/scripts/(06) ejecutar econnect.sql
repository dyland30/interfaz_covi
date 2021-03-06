USE [REPCOVI]
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ejecutarEconnect') AND type in (N'P', N'PC'))
DROP PROC ejecutarEconnect
GO

CREATE PROC ejecutarEconnect
@filtro varchar(500)
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	Permite ejecutar un la interfaz de econnect
-- =============================================
	DECLARE @ruta varchar(1000)
	SET @ruta = 'D:/prueba_econnect/MSSCargarClientes.exe ' +  @filtro	
	DECLARE @tablaTemp TABLE(
		output text 	
	);
	
	insert into @tablaTemp exec xp_cmdshell @ruta;
	select * from @tablaTemp;
	
END
