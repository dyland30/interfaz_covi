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
----------------------------------------------------------
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
---------------------------------------------------------------------
GO

/****** Object:  StoredProcedure [dbo].[obtenerCabecerasFacturas]    Script Date: 09/28/2012 11:03:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[obtenerCabecerasFacturas]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[obtenerCabecerasFacturas]
GO

CREATE PROC [dbo].[obtenerCabecerasFacturas]
	@codEstacion varchar(5),
	@serieCaseta varchar(10),
	@fecha datetime,
	@turno varchar(5)	
AS
BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	obtener las cabeceras de los documentos
-- de venta
-- =============================================
	SELECT DISTINCT tipdoc+nrodoc+seriedoc as dist,
	   [tipdoc]
      ,[nrodoc]
      ,[seriedoc]
      ,[seriecaseta]
      ,[nomcliente]
      ,[idcliente]
      ,[codestacion]
      ,[formapago]
      ,[fecdoc]
      ,[fecproceso]
      ,[tipodocsunat]
      ,[estado]
      ,[codlote]
      ,[turno]
      ,[nrodocasociado]
      
  FROM [DETALLEVENTAS]
  WHERE codestacion=@codEstacion AND
		seriecaseta= @serieCaseta AND
		convert(varchar,fecproceso,103)=convert(varchar,@fecha,103) AND
		turno=@turno AND upper(estado)='N'

END
GO

----------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'obtenerRepCliente') AND type in (N'P', N'PC'))
DROP PROC obtenerRepCliente
GO

CREATE PROC obtenerRepCliente

	@idCliente varchar(20)
AS
BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	obtiene el cliente por codigo
-- =============================================

	SELECT * FROM REPCLIENTE
	WHERE idcliente = @idCliente;
	
END

----------------------------------------------------------------------------

GO

/****** Object:  StoredProcedure [dbo].[obtenerDetalleDocumentos]    Script Date: 09/28/2012 11:10:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[obtenerDetalleDocumentos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[obtenerDetalleDocumentos]
GO

CREATE PROC [dbo].[obtenerDetalleDocumentos]
	@tipdoc varchar(15),
	@serieDoc varchar(15),
	@nroDoc varchar(25)	
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 13/08/2012
-- Description:	procedimiento que permite obtener los
-- detalles de documento por cabecera
-- =============================================
	SELECT [tipdoc]
      ,[nrodoc]
      ,[seriedoc]
      ,[seriecaseta]
      ,[seriedetraccion]
      ,[nrodetraccion]
      ,[nomcliente]
      ,[idcliente]
      ,[sentido]
      ,[placa]
      ,[codestacion]
      ,[formapago]
      ,[fecdoc]
      ,[fecproceso]
      ,[codarticulo]
      ,[cantidad]
      ,[preuni]
      ,[total]
      ,[igv]
      ,[totaldetraccion]
      ,[nrodocasociado]
      ,[fechavencimientovale]
      ,[nrotag]
      ,[turno]
      ,[tipodocsunat]
      ,[destinooperacion]
      ,[nroasientocont]
      ,[estado]
      ,[observacion]
      ,[codlote]
  FROM [DETALLEVENTAS]
  WHERE tipdoc=@tipdoc AND
		seriedoc= @serieDoc AND
		nrodoc=@nroDoc	
END


GO

--------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'almacenarHistorico') AND type in (N'P', N'PC'))
DROP PROC almacenarHistorico
GO

CREATE PROC almacenarHistorico
AS

BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 14/08/2012
-- Description:	Inserta en la tabla de detalles historicos
-- los detalles que se encuentren en estado procesado (P)
-- o con error (E)
-- =============================================
	BEGIN TRANSACTION
	BEGIN TRY
	
		INSERT INTO DETALLEVENTAS_OLD
		SELECT * FROM DETALLEVENTAS
		WHERE estado='P' or estado ='E';
		
		DELETE FROM DETALLEVENTAS
		WHERE estado='P' or estado ='E';
		
		COMMIT
	
	END TRY
	
	BEGIN CATCH
		ROLLBACK
		PRINT 'SE HA PRODUCIDO UN ERROR'
	
	END CATCH

END

-----------------------------------------------------------------------------------------
GO

/****** Object:  StoredProcedure [dbo].[modificarDetalleDocumento]    Script Date: 09/28/2012 11:24:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[modificarDetalleDocumento]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[modificarDetalleDocumento]
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

-------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[insertarDetalleDocumento]    Script Date: 09/28/2012 11:10:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[insertarDetalleDocumento]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[insertarDetalleDocumento]
GO

CREATE PROC [dbo].[insertarDetalleDocumento]
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Inserta un detalle en la tabla 
-- DETALLEVENTAS
-- =============================================
 @tipdoc varchar(15)
,@nrodoc varchar(25)
,@seriedoc varchar(15)
,@seriecaseta varchar(4)
,@seriedetraccion varchar(3)
,@nrodetraccion varchar(20)
,@nomcliente varchar(100)
,@idcliente varchar(20)
,@sentido varchar(2)
,@placa varchar(8)
,@codestacion char(4)
,@formapago char(1)
,@fecdoc datetime
,@fecproceso datetime
,@codarticulo varchar(30)
,@cantidad numeric(19,5)
,@preuni numeric(19,5)
,@total numeric(19,5)
,@igv numeric(19,5)
,@totaldetraccion numeric(19,5)
,@nrodocasociado varchar(25)
,@fechavencimientovale datetime
,@nrotag varchar(30)
,@turno varchar(5)
,@tipodocsunat varchar(4)
,@destinooperacion varchar(4)
,@nroasientocont int
,@estado char(1)
,@observacion text
,@codlote varchar(20)


AS
BEGIN

INSERT INTO DETALLEVENTAS
           ([tipdoc]
           ,[nrodoc]
           ,[seriedoc]
           ,[seriecaseta]
           ,[seriedetraccion]
           ,[nrodetraccion]
           ,[nomcliente]
           ,[idcliente]
           ,[sentido]
           ,[placa]
           ,[codestacion]
           ,[formapago]
           ,[fecdoc]
           ,[fecproceso]
           ,[codarticulo]
           ,[cantidad]
           ,[preuni]
           ,[total]
           ,[igv]
           ,[totaldetraccion]
           ,[nrodocasociado]
           ,[fechavencimientovale]
           ,[nrotag]
           ,[turno]
           ,[tipodocsunat]
           ,[destinooperacion]
           ,[nroasientocont]
           ,[estado]
           ,[observacion]
           ,[codlote])
     VALUES
           ( @tipdoc 
			,@nrodoc 
			,@seriedoc 
			,@seriecaseta
			,@seriedetraccion
			,@nrodetraccion 
			,@nomcliente
			,@idcliente 
			,@sentido 
			,@placa 
			,@codestacion 
			,@formapago 
			,@fecdoc
			,@fecproceso 
			,@codarticulo 
			,@cantidad 
			,@preuni 
			,@total
			,@igv 
			,@totaldetraccion
			,@nrodocasociado 
			,@fechavencimientovale 
			,@nrotag 
			,@turno 
			,@tipodocsunat 
			,@destinooperacion 
			,@nroasientocont 
			,@estado 
			,@observacion 
			,@codlote )
END
GO
---------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[INSERTAR_RESUMEN]    Script Date: 09/28/2012 11:29:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSERTAR_RESUMEN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[INSERTAR_RESUMEN]
GO


CREATE PROC [dbo].[INSERTAR_RESUMEN]
		   @codEstacion varchar(5),
           @serieCaseta varchar(5),
           @turno char(2),
           @procesados int,
           @errores int,
           @lote varchar(20)
AS

BEGIN
INSERT INTO [REPRESUMEN]
           ([codEstacion]
           ,[serieCaseta]
           ,[turno]
           ,[procesados]
           ,[errores]
           ,[lote])
     VALUES
           (@codEstacion
           ,@serieCaseta
           ,@turno
           ,@procesados
           ,@errores
           ,@lote)
END
----------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[LIMPIAR_RESUMEN]    Script Date: 09/28/2012 11:32:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LIMPIAR_RESUMEN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LIMPIAR_RESUMEN]
GO

CREATE PROC [dbo].[LIMPIAR_RESUMEN]
AS
BEGIN
	DELETE FROM REPRESUMEN;

END

GO
-------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[OBTENER_RESUMEN]    Script Date: 09/28/2012 11:33:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OBTENER_RESUMEN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[OBTENER_RESUMEN]
GO

CREATE PROC [dbo].[OBTENER_RESUMEN]
AS
BEGIN
SELECT [codEstacion]
      ,[serieCaseta]
      ,[turno]
      ,[procesados]
      ,[errores]
      ,[lote]
FROM [REPRESUMEN]
WHERE procesados>0 or errores>0
END
GO
---------------------------------------------------------------------------------------

