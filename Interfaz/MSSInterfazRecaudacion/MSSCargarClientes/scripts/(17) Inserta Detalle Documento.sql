USE [REPCOVI]
GO

/****** Object:  StoredProcedure [dbo].[insertarDetalleDocumento]    Script Date: 10/25/2012 14:19:15 ******/
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


