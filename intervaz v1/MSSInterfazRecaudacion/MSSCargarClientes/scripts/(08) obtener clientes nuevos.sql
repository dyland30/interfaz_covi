USE [REPCOVI]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'obtenerClientesNuevos') AND type in (N'P', N'PC'))
DROP PROC obtenerClientesNuevos
GO

CREATE PROC obtenerClientesNuevos
AS

BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	procedimiento que permite obtener los clientes
-- con estado nuevo (N)
-- =============================================


SELECT [idcliente]
      ,[nomcliente]
      ,[nombrecorto]
      ,[direccion]
      ,[tipopersona]
      ,[tipodocumento]
      ,[nombre1]
      ,[nombre2]
      ,[apepaterno]
      ,[apematerno]
      ,[idclase]
      ,[idVendedor]
      ,[idcondicionpago]
      ,[prioridad]
      ,[condnivelprecio]
      ,[estado]
      ,[observacion]
  FROM [REPCLIENTE]
  WHERE estado ='N';
END
