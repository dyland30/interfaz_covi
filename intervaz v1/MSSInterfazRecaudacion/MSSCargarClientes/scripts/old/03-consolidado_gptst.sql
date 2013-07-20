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

--------------------------------------------------------------------------------------


/****** Object:  StoredProcedure [dbo].[InterfazCovi_InsertaClienteLOC]    Script Date: 09/28/2012 11:39:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InterfazCovi_InsertaClienteLOC]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InterfazCovi_InsertaClienteLOC]
GO


CREATE PROC [dbo].[InterfazCovi_InsertaClienteLOC]
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	permite insertar los datos adicionales (localizacion)
-- del cliente
-- =============================================
			@CUSTNAME char(65)
           ,@CUSTNMBR char(15)
           ,@LOC_Nombre1 char(31)
           ,@LOC_Nombre2 char(31)
           ,@LOC_Apellido_Paterno char(31)
           ,@LOC_Apellido_Materno char(31)
           ,@LOC_Numero_Documento char(31)
           ,@F_Tipo_Persona_DDL smallint
           ,@F_Tipo_Documento_ID char(11)
           ,@F_Tipo_Documento_Desc char(51)
           ,@LOC_Razon_Social char(101)
           ,@USERID char(15)
           ,@SLPRSNID char(15)
           ,@PYMTRMID char(21)
           ,@F_TipoDoc_Emitir char(21)
           ,@F_TipoPedido char(67)
	
AS
BEGIN
	INSERT INTO [t_cliente]
           ([CUSTNAME]
           ,[CUSTNMBR]
           ,[LOC_Nombre1]
           ,[LOC_Nombre2]
           ,[LOC_Apellido_Paterno]
           ,[LOC_Apellido_Materno]
           ,[LOC_Numero_Documento]
           ,[F_Tipo_Persona_DDL]
           ,[F_Tipo_Documento_ID]
           ,[F_Tipo_Documento_Desc]
           ,[LOC_Razon_Social]
           ,[USERID]
           ,[CREATDDT]
           ,[MODIFDT]
           ,[SLPRSNID]
           ,[PYMTRMID]
           ,[F_TipoDoc_Emitir]
           ,[F_TipoPedido])
     VALUES
       (
          	@CUSTNAME 
           ,@CUSTNMBR 
           ,@LOC_Nombre1 
           ,@LOC_Nombre2 
           ,@LOC_Apellido_Paterno 
           ,@LOC_Apellido_Materno 
           ,@LOC_Numero_Documento 
           ,@F_Tipo_Persona_DDL 
           ,@F_Tipo_Documento_ID 
           ,@F_Tipo_Documento_Desc 
           ,@LOC_Razon_Social 
           ,@USERID 
           ,convert(datetime,Convert(varchar, GETDATE(),103),103)
           ,convert(datetime,Convert(varchar, GETDATE(),103),103)
           ,@SLPRSNID 
           ,@PYMTRMID
           ,@F_TipoDoc_Emitir 
           ,@F_TipoPedido
         )
END


GO
GRANT EXEC ON InterfazCovi_InsertaClienteLOC TO DYNGRP
GO

----------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[InsertarDistribucionClienteSOP]    Script Date: 09/28/2012 11:44:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarDistribucionClienteSOP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertarDistribucionClienteSOP]
GO



CREATE PROCEDURE [dbo].[InsertarDistribucionClienteSOP] 
	-- Add the parameters for the stored procedure here
	@idCliente varchar(15),
	@sopNumber varchar(21)
AS
BEGIN
	
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Inserta los asientos contables
-- de la cuenta del cliente en transacciones de venta
-- =============================================
		
	SET NOCOUNT ON;
	DECLARE @actindx int;
	DECLARE @SopType smallint;
	DECLARE @SeqNumbr int;
	DECLARE @DistType smallint;
	DECLARE @CurrnIdx smallint;
	DECLARE @Posted tinyint;
	DECLARE @TrxSorce varchar(13);
	DECLARE @ContractExchangeRate numeric(19,5);
	DECLARE @DistRef varchar(31);
	DECLARE @monto numeric(19,5);
	BEGIN TRANSACTION
	BEGIN TRY
		--Obtener la cuenta del cliente
		SELECT @actindx = RMARACC 
		FROM RM00101
		WHERE CUSTNMBR= @idCliente;
		
		-- OBTENER MONTO DE DOCUMENTO
		SELECT @monto= DOCAMNT from SOP10100
		WHERE SOPNUMBE=@sopNumber;
		
		-- estableciendo el tipo de distribución
		SET @DistType= 2;
		
		-- OBTENER DATOS DEL ASIENTO PARA GUARDAR
		SELECT TOP 1
	   @SopType=[SOPTYPE]
      ,@SeqNumbr=[SEQNUMBR]
      ,@DistRef=[DistRef]
      ,@CurrnIdx=[CURRNIDX]
      ,@TrxSorce=[TRXSORCE]
      ,@Posted=[POSTED]
      ,@ContractExchangeRate=[Contract_Exchange_Rate]
	FROM SOP10102
	WHERE SOPNUMBE= @sopNumber
	ORDER BY SEQNUMBR DESC;
	-- establecemos el siguiente numero de secuencia
	-- segun dynamics 
	SET @SeqNumbr= @SeqNumbr+16384;
	
		-- INSERTAR DEBITO
		INSERT INTO SOP10102
           ([SOPTYPE]
           ,[SOPNUMBE]
           ,[SEQNUMBR]
           ,[DISTTYPE]
           ,[DistRef]
           ,[ACTINDX]
           ,[DEBITAMT]
           ,[ORDBTAMT]
           ,[CRDTAMNT]
           ,[ORCRDAMT]
           ,[CURRNIDX]
           ,[TRXSORCE]
           ,[POSTED]
           ,[Contract_Exchange_Rate])
     VALUES
           (@SopType
           ,@sopNumber
           ,@SeqNumbr
           ,@DistType
           ,@DistRef
           ,@actindx
           ,@monto
           ,@monto
           ,CONVERT(numeric(19,5),0)
           ,CONVERT(numeric(19,5),0)
           ,@CurrnIdx
           ,@TrxSorce
           ,@Posted
           ,@ContractExchangeRate)

SET @SeqNumbr= @SeqNumbr+16384;
-- INSERTAR CREDITO
		INSERT INTO SOP10102
           ([SOPTYPE]
           ,[SOPNUMBE]
           ,[SEQNUMBR]
           ,[DISTTYPE]
           ,[DistRef]
           ,[ACTINDX]
           ,[DEBITAMT]
           ,[ORDBTAMT]
           ,[CRDTAMNT]
           ,[ORCRDAMT]
           ,[CURRNIDX]
           ,[TRXSORCE]
           ,[POSTED]
           ,[Contract_Exchange_Rate])
     VALUES
           (@SopType
           ,@sopNumber
           ,@SeqNumbr
           ,@DistType
           ,@DistRef
           ,@actindx
           ,CONVERT(numeric(19,5),0)
           ,CONVERT(numeric(19,5),0)
           ,@monto
           ,@monto
           ,@CurrnIdx
           ,@TrxSorce
           ,@Posted
           ,@ContractExchangeRate)
		
		  COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		PRINT ERROR_MESSAGE();
	END CATCH

END
GO
GRANT EXEC ON InsertarDistribucionClienteSOP TO DYNGRP
GO
-----------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[InsertarAC_Financiero_SOP_RM]    Script Date: 09/28/2012 11:46:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarAC_Financiero_SOP_RM]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertarAC_Financiero_SOP_RM]
GO



CREATE PROC [dbo].[InsertarAC_Financiero_SOP_RM]
@jentry int
AS
	DECLARE @NRODOC AS VARCHAR(21)
	DECLARE @CANT AS INT
	DECLARE @MONTOASIENTO NUMERIC(19,5)
	--TABLA VARIABLE PARA ALMACENAR LOS ASIENTOS DE GL
	DECLARE @CUENTADEBITO AS INT
	DECLARE @CUENTACREDITO AS INT
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 28/08/2012
-- Description:	Permite insertar los asientos contables
-- generados en GL a SOP y RM
-- =============================================
		
	--INICIAR TRANSACCION
	BEGIN TRANSACTION
	
	BEGIN TRY
		SELECT @NRODOC=RTRIM(LTRIM(SUBSTRING(REFRENCE,CHARINDEX(':',REFRENCE)+1,(LEN(REFRENCE)-CHARINDEX(':',REFRENCE))))) from GL10000
	WHERE JRNENTRY=@jentry;
	
	-- buscar documento en RM
	SELECT @CANT=COUNT(*) FROM RM10101
	WHERE RTRIM(LTRIM(DOCNUMBR)) = @NRODOC;
	DECLARE @MENSAJE VARCHAR(100)
	SET @MENSAJE = 'No existe el documento asociado Nro: ' +@NRODOC+' o no ha sido contabilizado'
	
	IF @CANT = 0 
	BEGIN
		RAISERROR(@MENSAJE,16,1)
	END
	ELSE
	BEGIN
		--OBTENER FECHA DEL ASIENTO
		DECLARE @FECHA_ASIENTO DATETIME
		
		DECLARE @DISTREF VARCHAR(31)
		------------------------------------------
		SELECT @FECHA_ASIENTO=TRXDATE FROM GL10000
	    WHERE JRNENTRY=@jentry;
	    
		--OBTENER DISTRIBUCION CONTABLE DE FINANCIERO GENERAL
		SELECT TOP 1  @MONTOASIENTO=(CASE WHEN CRDTAMNT>0 THEN CRDTAMNT ELSE DEBITAMT END) FROM GL10001
		WHERE JRNENTRY=@jentry
		ORDER BY SQNCLINE DESC;
		
		--OBTENER CUENTA DEBITO
		--obtener distref
		SELECT @CUENTADEBITO=ACTINDX,@DISTREF=DSCRIPTN FROM GL10001
		WHERE JRNENTRY=@jentry AND DEBITAMT>0;
		
		   --OBTENER CUENTA CREDITO
		SELECT @CUENTACREDITO=ACTINDX FROM GL10001
		WHERE JRNENTRY=@jentry AND CRDTAMNT>0;
		
		--obtener ultima fila de la tabla RM10101 (Facturas Contabilizadas)
		DECLARE @TRXSORCE VARCHAR(13)
		DECLARE @POSTED TINYINT
		DECLARE @PSTGSTUS SMALLINT
		DECLARE @CHANGED TINYINT
		DECLARE @DCSTATUS SMALLINT
		DECLARE @DISTTYPE SMALLINT
		DECLARE @RMDTYPAL SMALLINT
		DECLARE @SEQNUMBR INT
		DECLARE @CUSTNMBR VARCHAR(15)
		DECLARE @PROJCTID VARCHAR(15)
		DECLARE @USERID VARCHAR(15)
		DECLARE @CATEGUSD SMALLINT
		DECLARE @CURNCYID VARCHAR(15)
		DECLARE @CURRNIDX SMALLINT	
		DECLARE @Contract_Exchange_Rate NUMERIC(19,5)		
		DECLARE @SOPTYPE SMALLINT
		
		--ESTABLECER TIPO DE DISTRIBUCION
		SET @DISTTYPE  = 2;
		
		SELECT TOP 1 
			@TRXSORCE =TRXSORCE,
			@POSTED =POSTED,
			@PSTGSTUS =PSTGSTUS,
			@CHANGED =CHANGED,
			@DCSTATUS =DCSTATUS,
			@RMDTYPAL =RMDTYPAL,
			@SEQNUMBR =SEQNUMBR,
			@CUSTNMBR =CUSTNMBR,
			@PROJCTID =PROJCTID,
			@USERID =USERID,
			@CATEGUSD =CATEGUSD,
			@CURNCYID =CURNCYID,
			@CURRNIDX =CURRNIDX
		FROM RM10101
		WHERE DOCNUMBR=@NRODOC
		ORDER BY SEQNUMBR DESC
		
		--AUMENTAR SEQNUMBER EN 1
		SET @SEQNUMBR=@SEQNUMBR+1;
		
		
		-- insertar debito RM
		INSERT INTO RM10101
           ([TRXSORCE]
           ,[POSTED]
           ,[POSTEDDT]
           ,[PSTGSTUS]
           ,[CHANGED]
           ,[DOCNUMBR]
           ,[DCSTATUS]
           ,[DISTTYPE]
           ,[RMDTYPAL]
           ,[SEQNUMBR]
           ,[CUSTNMBR]
           ,[DSTINDX]
           ,[DEBITAMT]
           ,[CRDTAMNT]
           ,[PROJCTID]
           ,[USERID]
           ,[CATEGUSD]
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[ORCRDAMT]
           ,[ORDBTAMT]
           ,[DistRef])
     VALUES
           (@TRXSORCE
           ,@POSTED
           ,@FECHA_ASIENTO
           ,@PSTGSTUS
           ,@CHANGED
           ,@NRODOC
           ,@DCSTATUS
           ,@DISTTYPE
           ,@RMDTYPAL
           ,@SEQNUMBR
           ,@CUSTNMBR
           ,@CUENTADEBITO
           ,@MONTOASIENTO
           ,CONVERT( numeric(19,5),0)
           ,@PROJCTID
           ,@USERID
           ,@CATEGUSD
           ,@CURNCYID
           ,@CURRNIDX
           ,CONVERT(numeric(19,5),0)
           ,@MONTOASIENTO
           ,@DISTREF)
           
        --AUMENTAR SEQNUMBER EN 1
		SET @SEQNUMBR=@SEQNUMBR+1;
           
        
           -- insertar credito RM
		INSERT INTO RM10101
           ([TRXSORCE]
           ,[POSTED]
           ,[POSTEDDT]
           ,[PSTGSTUS]
           ,[CHANGED]
           ,[DOCNUMBR]
           ,[DCSTATUS]
           ,[DISTTYPE]
           ,[RMDTYPAL]
           ,[SEQNUMBR]
           ,[CUSTNMBR]
           ,[DSTINDX]
           ,[DEBITAMT]
           ,[CRDTAMNT]
           ,[PROJCTID]
           ,[USERID]
           ,[CATEGUSD]
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[ORCRDAMT]
           ,[ORDBTAMT]
           ,[DistRef])
     VALUES
           (@TRXSORCE
           ,@POSTED
           ,@FECHA_ASIENTO
           ,@PSTGSTUS
           ,@CHANGED
           ,@NRODOC
           ,@DCSTATUS
           ,@DISTTYPE
           ,@RMDTYPAL
           ,@SEQNUMBR
           ,@CUSTNMBR
           ,@CUENTACREDITO
           ,CONVERT( numeric(19,5),0)
           ,@MONTOASIENTO
           ,@PROJCTID
           ,@USERID
           ,@CATEGUSD
           ,@CURNCYID
           ,@CURRNIDX
           ,@MONTOASIENTO
           ,CONVERT(numeric(19,5),0)
           ,@DISTREF)
           
       -- INSERTAR EN SOP
            
       -- OBTENER ULTIMA FILA DE SOP
       SELECT TOP 1 
       @SOPTYPE = SOPTYPE,
       @SEQNUMBR = SEQNUMBR,
       @CURRNIDX = CURRNIDX,
       @TRXSORCE = TRXSORCE,
       @POSTED = POSTED,
       @Contract_Exchange_Rate= Contract_Exchange_Rate
       FROM SOP10102
	   WHERE RTRIM(LTRIM(SOPNUMBE)) = @NRODOC
       ORDER BY SEQNUMBR DESC    
           
       -- INSERTAR DEBITO EN SOP
       --AUMENTAR SEQNUMBER EN 1
		SET @SEQNUMBR=@SEQNUMBR+1;
		INSERT INTO SOP10102
           ([SOPTYPE]
           ,[SOPNUMBE]
           ,[SEQNUMBR]
           ,[DISTTYPE]
           ,[DistRef]
           ,[ACTINDX]
           ,[DEBITAMT]
           ,[ORDBTAMT]
           ,[CRDTAMNT]
           ,[ORCRDAMT]
           ,[CURRNIDX]
           ,[TRXSORCE]
           ,[POSTED]
           ,[Contract_Exchange_Rate])
     VALUES
           (@SOPTYPE
           ,@NRODOC
           ,@SEQNUMBR
           ,@DISTTYPE
           ,@DISTREF
           ,@CUENTADEBITO
           ,@MONTOASIENTO
           ,@MONTOASIENTO
           ,CONVERT(numeric(19,5),0)
           ,CONVERT(numeric(19,5),0)
           ,@CURRNIDX
           ,@TRXSORCE
           ,@POSTED
           ,@Contract_Exchange_Rate)
       
       -- INSERTAR CREDITO EN SOP
	--AUMENTAR SEQNUMBER EN 1
		SET @SEQNUMBR=@SEQNUMBR+1;
		INSERT INTO SOP10102
           ([SOPTYPE]
           ,[SOPNUMBE]
           ,[SEQNUMBR]
           ,[DISTTYPE]
           ,[DistRef]
           ,[ACTINDX]
           ,[DEBITAMT]
           ,[ORDBTAMT]
           ,[CRDTAMNT]
           ,[ORCRDAMT]
           ,[CURRNIDX]
           ,[TRXSORCE]
           ,[POSTED]
           ,[Contract_Exchange_Rate])
     VALUES
           (@SOPTYPE
           ,@NRODOC
           ,@SEQNUMBR
           ,@DISTTYPE
           ,@DISTREF
           ,@CUENTACREDITO
           ,CONVERT(numeric(19,5),0)
           ,CONVERT(numeric(19,5),0)
           ,@MONTOASIENTO
           ,@MONTOASIENTO
           ,@CURRNIDX
           ,@TRXSORCE
           ,@POSTED
           ,@Contract_Exchange_Rate)
	END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @err_mess varchar(500)
		SET @err_mess =ERROR_MESSAGE() 
		RAISERROR(@err_mess,16,1)
	END CATCH
END



GO
GRANT EXEC ON InsertarAC_Financiero_SOP_RM TO DYNGRP
GO

----------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[InsertarAdicionalesConsumos]    Script Date: 09/28/2012 11:51:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarAdicionalesConsumos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertarAdicionalesConsumos]
GO

CREATE PROCEDURE [dbo].[InsertarAdicionalesConsumos]
	-- Add the parameters for the stored procedure here
	@id_ventana varchar(15),
	@jrentry	varchar(30),
	@nroCampo	smallint,
	@valor		varchar(255)
AS
BEGIN
	-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	Permite agregar valores adicionales
-- en los extender de short string
-- =============================================
	
	INSERT INTO EXT00101
           ([PT_Window_ID]
           ,[PT_UD_Key]
           ,[PT_UD_Number]
           ,[STRGA255])
     VALUES
           (@id_ventana
           ,@jrentry
           ,@nroCampo
           ,@valor)

END


GO
GRANT EXEC ON InsertarAdicionalesConsumos TO DYNGRP
GO
-----------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[InsertarValoresDefinidosUsuarioSOP]    Script Date: 09/28/2012 11:49:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarValoresDefinidosUsuarioSOP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertarValoresDefinidosUsuarioSOP]
GO

CREATE PROCEDURE [dbo].[InsertarValoresDefinidosUsuarioSOP]
	-- Add the parameters for the stored procedure here
	@SopType smallint,
	@nroDoc varchar(21),
	@fec1 datetime, 
	@def1 varchar(21),
	@def2 varchar(21),
	@def3 varchar(21),
	@def4 varchar(21),
	@def5 varchar(21)
	
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	Permite ingresar valores definidos 
-- por el usuario en las facturas 
-- =============================================
	
	SET NOCOUNT ON;
	DECLARE @CONT INT
	-- buscar en la tabla para ver si 
	SELECT @CONT=COUNT(*) FROM SOP10106
	WHERE SOPNUMBE = @nroDoc
	
	IF @CONT>0 
	BEGIN
		--ACTUALIZAR
		UPDATE SOP10106
		SET 
			[USRDAT02]=@fec1
           ,[USERDEF1]= @def1
           ,[USERDEF2] =@def2
           ,[USRDEF03] =@def3
           ,[USRDEF04] =@def4
           ,[USRDEF05] =@def5
        WHERE [SOPNUMBE]= @nroDoc
		
	END
	ELSE 
	BEGIN
		--INSERTAR
		INSERT INTO SOP10106
           ([SOPTYPE]
           ,[SOPNUMBE]
           ,[USERDEF1]
           ,[USERDEF2]
           ,[USRDEF03]
           ,[USRDEF04]
           ,[USRDEF05]
           ,[USRDAT02]
           ,[CMMTTEXT])
     VALUES
           (@SopType
           ,@nroDoc
           ,@def1
           ,@def2
           ,@def3
           ,@def4
           ,@def5
           ,@fec1
           ,'');
	END
	

END

GO
GRANT EXEC ON InsertarValoresDefinidosUsuarioSOP TO DYNGRP
GO

-------------------------------------------------------------------------------------------
USE [GPTST]
GO 

/****** Object:  UserDefinedFunction [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS]    Script Date: 09/24/2012 17:58:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS]
GO

CREATE FUNCTION [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS]
(
	@codestacion varchar(MAX),
	@nroDoc		varchar(30),
	@fecInicio DATETIME, 
	@fecFin DATETIME
)
RETURNS numeric(19,7)
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 10/09/2012
-- Description:	obtiene el total facturado dividido
-- entre el numero de consumos
-- =============================================
	DECLARE @monto numeric(19,7)
	DECLARE @cant numeric(19,7)
	DECLARE @mdividido numeric(19,7)
	
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	
	--cantidad de datos
	
	SELECT @cant = COUNT(*)
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%TEL:%'
	AND CRDTAMNT =0
	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) IN (select codEstacion from @codEstaciones)
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM(s.SOPNUMBE) = RTRIM(@nroDoc)
	
	IF @cant IS NULL
	BEGIN
		set @cant =1.00
	END
	
	---------------------------------
	SELECT @monto=DOCAMNT
	FROM SOP30200
	WHERE SOPNUMBE = RTRIM(@nroDoc)
	
	SET @mdividido = @monto/@cant				
	RETURN @mdividido
END

GO
---------------------------------------------------------------------------------------------
 
/****** Object:  UserDefinedFunction [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS]    Script Date: 09/25/2012 12:45:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_VALES]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_VALES]
GO


CREATE FUNCTION [dbo].[UFN_TOTAL_FACTURADO_DIVIDIDO_VALES]
(
	@codestacion varchar(MAX),
	@nroDoc		varchar(30),
	@fecInicio DATETIME, 
	@fecFin DATETIME
)
RETURNS numeric(19,7)
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 10/09/2012
-- Description:	obtiene el total facturado dividido
-- entre el numero de consumos
-- =============================================
	DECLARE @monto numeric(19,7)
	DECLARE @cant numeric(19,7)
	DECLARE @mdividido numeric(19,7)
	
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	
	--cantidad de datos
	
	SELECT @cant = COUNT(*)
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%VAL:%'
	AND CRDTAMNT =0
	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) IN (select codEstacion from @codEstaciones)
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM(s.SOPNUMBE) = RTRIM(@nroDoc)
	
	IF @cant IS NULL
	BEGIN
		set @cant =1.00
	END
	
	---------------------------------
	SELECT @monto=DOCAMNT
	FROM SOP30200
	WHERE SOPNUMBE = RTRIM(@nroDoc)
	
	SET @mdividido = @monto/@cant				
	RETURN @mdividido
	
END

GO
--------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[ReporteConsumosValesxClienteDocumento]    Script Date: 09/25/2012 12:51:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosValesxClienteDocumento]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosValesxClienteDocumento]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosValesxClienteDocumento]
	-- Add the parameters for the stored procedure here
	@nroDoc varchar(max),
	@idCliente varchar(max),
	@codestacion varchar(max),
	@fecInicio datetime,
	@fecFin datetime
AS
BEGIN
	
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 20/08/2012
-- Description:	Reporte de consumos de
-- vales por cliente, documento, estacion y rango de fechas
-- =============================================
	SET NOCOUNT ON;
	
	
	DECLARE @docs TABLE(nroDoc varchar(30))
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	DECLARE @Clientes TABLE(codCliente varchar(30))
	
	INSERT INTO @docs 
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@nroDoc)
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	INSERT INTO @Clientes
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@idCliente)
	
	
	SELECT 
	RTRIM(ltrim(substring(g.REFRENCE,charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE))))  DOCNUMBR,
	RTRIM(DSCRIPTN) as VALE,
	CONVERT(varchar,TRXDATE,103) AS FECHA,
	convert(numeric(19,2),DEBITAMT) as MONTO,
	RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=1))  TURNO,
	RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2))  ESTACION,
	RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=3)) CATEGORIA,
	RTRIM(s.CUSTNMBR) as CUSTNMBR ,
	RTRIM(s.CUSTNAME) as CUSTNAME,
	convert(numeric(19,2),s.DOCAMNT) as DOCAMNT,
	dbo.UFN_TOTAL_FACTURADO_DIVIDIDO_VALES(@codestacion,s.SOPNUMBE,@fecInicio,@fecFin) as DOCAMNTDIV	 
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%VAL:%'
	AND CRDTAMNT =0
	AND rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) in (select nroDoc from @docs)
	AND (SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) in(select codEstacion from @codEstaciones)
	AND s.CUSTNMBR in (select codCliente from @Clientes)
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
END
GO
GRANT EXEC ON ReporteConsumosValesxClienteDocumento TO DYNGRP
GO
-------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[ReporteConsumosValesObtenerClientes]    Script Date: 09/24/2012 12:19:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosValesObtenerClientes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosValesObtenerClientes]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosValesObtenerClientes]
	-- Add the parameters for the stored procedure here
	@fecInicio datetime,
	@fecFin datetime,
	@codestacion varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	---- crear tabla de documentos del cliente
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	
	SELECT 
	DISTINCT RTRIM(s.CUSTNMBR) as CUSTNMBR ,RTRIM(s.CUSTNAME) as CUSTNAME
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%VAL:%'
	AND CRDTAMNT =0	
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2)) IN (select codEstacion from @codEstaciones)
	
END

GO
GRANT EXEC ON ReporteConsumosObtenerClientes TO DYNGRP
GO
--------------------------------------------------------------------

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

---------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[ReporteConsumosValesObtenerDocumentos]    Script Date: 09/24/2012 12:34:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosValesObtenerDocumentos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosValesObtenerDocumentos]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosValesObtenerDocumentos]
	-- Add the parameters for the stored procedure here
	@fecInicio datetime,
	@fecFin datetime,
	@codestacion varchar(max),
	@idCliente varchar(max)
AS
BEGIN

-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Permite obtener los documentos de origen de vales
-- que se encuentren en un rango de fechos, pertenezcan a una estacion y cliente
-- =============================================
	SET NOCOUNT ON;
	-- crear tabla de documentos del cliente
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	DECLARE @Clientes TABLE(codCliente varchar(30))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	INSERT INTO @Clientes
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@idCliente)
	
	
	SELECT 
	DISTINCT RTRIM(s.SOPNUMBE) as CLAVE, RTRIM(s.SOPNUMBE) as SOPNUMBE 
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%VAL:%'
	AND CRDTAMNT =0	
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM(LTRIM(S.CUSTNMBR))IN (select codCliente from @Clientes)
	AND RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2)) IN (select codEstacion from @codEstaciones)

	
END
GO
GRANT EXEC ON ReporteConsumosValesObtenerDocumentos TO DYNGRP
GO

-------------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[ReporteConsumosTelepassxClienteDocumento]    Script Date: 09/24/2012 16:51:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosTelepassxClienteDocumento]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosTelepassxClienteDocumento]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosTelepassxClienteDocumento]
	-- Add the parameters for the stored procedure here
	@fecInicio datetime,
	@fecFin datetime,
    @codestacion varchar(max),
	@idCliente varchar(max),
	@nroDoc varchar(max)
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	REPORTE DE CONSUMOS DE TELEPASS POR
-- RANGO DE FECHAS, ESTACION, CLIENTE Y NRO DE DOCUMENTO
-- =============================================
	SET NOCOUNT ON;
	-- crear tabla de documentos del cliente
	DECLARE @docs TABLE(nroDoc varchar(30))
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	DECLARE @Clientes TABLE(codCliente varchar(30))
	
	INSERT INTO @docs 
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@nroDoc)
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	INSERT INTO @Clientes
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@idCliente)
	
	
		SELECT JRNENTRY,
		RTRIM(LTRIM(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) AS DOCNUMBR,
		RTRIM(RIGHT(DSCRIPTN,(Charindex(':',Reverse(DSCRIPTN))-1))) AS TAG,
		RTRIM(LTRIM(SUBSTRING(DSCRIPTN,CHARINDEX(':',DSCRIPTN)+1,CHARINDEX(' ',DSCRIPTN,CHARINDEX(' ',DSCRIPTN,CHARINDEX(':',DSCRIPTN) )+1)-(CHARINDEX(':',DSCRIPTN)+1)))) AS PLACA,
		CONVERT(varchar,TRXDATE,103) AS TRXDATE,
		CONVERT(NUMERIC(19,2),DEBITAMT) AS MONTO,
		RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
		RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=1)) AS TURNO,
		RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
		RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2)) AS ESTACION,
		RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
		RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=3)) CATEGORIA,
		s.CUSTNMBR,
		s.CUSTNAME,
		convert(numeric(19,2),s.DOCAMNT) as DOCAMNT,
	    dbo.UFN_TOTAL_FACTURADO_DIVIDIDO_TELEPASS(@codestacion,s.SOPNUMBE,@fecInicio,@fecFin) as DOCAMNTDIV		
		FROM GL20000 as g
		INNER JOIN SOP30200 AS s
		on rtrim(ltrim(substring(g.REFRENCE,charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
		WHERE g.REFRENCE LIKE '%TEL:%'
		AND CRDTAMNT =0
		AND rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) in (select nroDoc from @docs)
		AND (SELECT STRGA255 FROM EXT00101 WHERE 
		RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2) in (select codEstacion from @codEstaciones)
		AND TRXDATE BETWEEN @fecInicio AND @fecFin@fecFin

END

GO
GRANT EXEC ON ReporteConsumosTelepassxClienteDocumento TO DYNGRP
GO
----------------------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[ReporteConsumosObtenerClientesTelepass]    Script Date: 09/24/2012 14:08:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosObtenerClientesTelepass]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosObtenerClientesTelepass]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosObtenerClientesTelepass]
	-- Add the parameters for the stored procedure here
	@fecInicio datetime,
	@fecFin datetime,
	@codestacion varchar(max)
AS
BEGIN 
	-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Obtiene los clientes
-- que hayan realizado un consumo de telepass
-- en un rango de fechas determinadas y estacion
-- =============================================
	SET NOCOUNT ON;
	-- crear tabla de documentos del cliente
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	SELECT 
	DISTINCT RTRIM(s.CUSTNMBR) as CUSTNMBR ,RTRIM(s.CUSTNAME) as CUSTNAME
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%TEL:%'
	AND CRDTAMNT =0	
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2)) IN (select codEstacion from @codEstaciones)

END

GO
GRANT EXEC ON ReporteConsumosObtenerClientesTelepass TO DYNGRP
GO
-------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[ReporteConsumosTelepassObtenerDocumentos]    Script Date: 09/24/2012 14:11:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteConsumosTelepassObtenerDocumentos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteConsumosTelepassObtenerDocumentos]
GO

CREATE PROCEDURE [dbo].[ReporteConsumosTelepassObtenerDocumentos]
	-- Add the parameters for the stored procedure here
	@fecInicio datetime,
	@fecFin datetime,
	@codestacion varchar(max),
	@idCliente varchar(max)
AS
BEGIN 
	-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Obtiene los documentos
-- de origen de telepass
-- =============================================
	SET NOCOUNT ON;
	-- crear tabla de documentos del cliente
	DECLARE @codEstaciones TABLE(codEstacion varchar(5))
	DECLARE @Clientes TABLE(codCliente varchar(30))
	
	INSERT INTO @codEstaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@codestacion)
	
	INSERT INTO @Clientes
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@idCliente)
		
	SELECT 
	DISTINCT RTRIM(s.SOPNUMBE) as CLAVE, RTRIM(s.SOPNUMBE) as SOPNUMBE 
	FROM GL20000 as g
	INNER JOIN SOP30200 AS s
	on rtrim(ltrim(substring(g.REFRENCE,	charindex(':',g.REFRENCE)+1,LEN(g.REFRENCE)-charindex(':',g.REFRENCE)))) = s.SOPNUMBE
	WHERE g.REFRENCE LIKE '%TEL:%'
	AND CRDTAMNT =0	
	AND TRXDATE BETWEEN @fecInicio AND @fecFin
	AND RTRIM(LTRIM(S.CUSTNMBR))IN (select codCliente from @Clientes)
	AND RTRIM((SELECT STRGA255 FROM EXT00101 WHERE 
	RTRIM(PT_Window_ID) = 'V_CONSUMO_GL' AND rtrim(PT_UD_Key)= CAST(g.JRNENTRY AS VARCHAR) AND PT_UD_Number=2)) IN (select codEstacion from @codEstaciones)

	
	
END

GO
GRANT EXEC ON ReporteConsumosTelepassObtenerDocumentos TO DYNGRP
GO
----------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[ReporteRecaudacionPeaje]    Script Date: 09/27/2012 11:09:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteRecaudacionPeaje]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteRecaudacionPeaje]
GO

CREATE PROC [dbo].[ReporteRecaudacionPeaje]
@Estacion varchar(max),
@Turno varchar(max),
@FechaInicio datetime, 
@FechaFin datetime
AS
BEGIN
	-- CREAR TABLA TEMPORAL
	DECLARE @tabla_temp as TABLE(
		estacion varchar(30),
		turno varchar(30),
		fecha datetime,
		monto numeric(19,2),
		diff varchar(30)
	);
	--tabla de turnos
	DECLARE @tabla_turnos as TABLE(turno varchar(3));
	--POBLAR TURNO
	INSERT INTO @tabla_turnos
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Turno)
	-- tabla de estaciones
	DECLARE @tabla_estaciones as TABLE(
		codEstacion varchar(5)
	);	
	INSERT INTO @tabla_estaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Estacion)
	
	-- insertar tickets
	-- cambiar fecha de documento por fecha de proceso
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, def.USRDAT02 as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'TK' as diff
	from SOP30200 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND f.DOCID not like '%SOBR%'
	AND  f.DOCID not like '%DISC%' AND def.USRDAT02 BETWEEN @FechaInicio AND @FechaFin
	group by def.USRDEF03,def.USRDAT02,def.USRDEF04
	
	-- insertar sobrantes
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, def.USRDAT02 as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'SOB' as diff
	from SOP30200 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND f.DOCID like '%SOBR%'
	AND def.USRDAT02 BETWEEN @FechaInicio AND @FechaFin
	group by def.USRDEF03,def.USRDAT02,def.USRDEF04
	
	-- insertar discrepancias
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, def.USRDAT02 as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'DIS' as diff
	from SOP30200 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND  f.DOCID like '%DISC%'
	AND def.USRDAT02 BETWEEN @FechaInicio AND @FechaFin
	group by def.USRDEF03,def.USRDAT02,def.USRDEF04
	
	
	-- insertar detraccion
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, def.USRDAT02 as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as MONTO,
	'DET' as diff
	from SOP30200 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	where CUSTNMBR = 'DETRACCION'
	AND def.USRDAT02 BETWEEN @FechaInicio AND @FechaFin
	group by def.USRDEF03,def.USRDAT02,def.USRDEF04
	
	-- en lugar de consumos de vales y telepass insertar el monto facturado
	--telepass
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTEL' as DIFF
	FROM  SOP30300 AS d INNER JOIN SOP30200 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TEL%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  
	
	--tags
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTAG' as DIFF
	FROM  SOP30300 AS d INNER JOIN SOP30200 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TAG%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  
		
	select estacion,turno,CONVERT(VARCHAR,t.fecha,103) as fecha,
	sum(CASE WHEN diff ='TK' THEN monto ELSE 0 END) AS RecaudacionTickets,
	sum(CASE WHEN diff ='DET' THEN monto ELSE 0 END) AS Detracciones,
	sum(CASE WHEN diff ='FTEL' THEN monto ELSE 0 END) AS Telepass,
	sum(CASE WHEN diff ='FTAG' THEN monto ELSE 0 END) AS TAG,
	--sum(CASE WHEN diff ='VAL' THEN monto ELSE 0 END) AS Vales,
	--sum(CASE WHEN diff ='TEL' THEN monto ELSE 0 END) AS Telepass,
	sum(CASE WHEN diff ='DIS' THEN monto ELSE 0 END) AS Discrepancia,
	sum(CASE WHEN diff ='SOB' THEN monto ELSE 0 END) AS Sobrante
	
	from @tabla_temp as t
	where fecha between @FechaInicio and @FechaFin and estacion in (select CodEstacion from  @tabla_estaciones)
	and turno in (select turno from @tabla_turnos)
	group by turno,fecha,estacion
	order by t.fecha desc, turno asc
END

GO
GRANT EXEC ON ReporteRecaudacionPeaje TO DYNGRP
GO
---------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ObtenerEstacionesPeajeTodas') AND type in (N'P', N'PC'))
DROP PROC ObtenerEstacionesPeajeTodas
GO
CREATE PROC [dbo].[ObtenerEstacionesPeajeTodas]
AS
BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 29/08/2012
-- Description:	Obtiene las estaciones de peaje
-- =============================================
	SELECT '' AS LOCNCODE, '(Todos)' AS LOCNDSCR
	UNION
	SELECT RTRIM(LTRIM(LOCNCODE)) AS LOCNCODE,RTRIM(LTRIM(LOCNDSCR)) AS LOCNDSCR FROM IV40700
	WHERE ADDRESS2='ESTPEA'
END

GO 
GRANT EXEC ON ObtenerEstacionesPeajeTodas TO DYNGRP
GO

----------------------------------------------------------------------------------------------------------------------------


/****** Object:  StoredProcedure [dbo].[insertarCabeceraGL]    Script Date: 09/17/2012 09:35:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[insertarCabeceraGL]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[insertarCabeceraGL]
GO

CREATE proc [dbo].[insertarCabeceraGL]
@BACHNUMB char(15),
@JRNENTRY INT,
@SOURCDOC char(11),
@REFRENCE char(31),
@TRXDATE datetime,
@RVRSNGDT datetime,
@CURNCYID char(15)
as
begin

--DECLARE @SQNCLINE AS NUMERIC(19,5)
--SET @SQNCLINE = 0.00000
declare @BCHSOURC char(15)
set @BCHSOURC= 'GL_Normal'

declare @RCTRXSEQ numeric(19,5)
set  @RCTRXSEQ=0.00000

declare @RCRNGTRX tinyint
set @RCRNGTRX=0

declare @BALFRCLC tinyint
set @BALFRCLC=0

declare @PSTGSTUS tinyint
set @PSTGSTUS=1

declare @LASTUSER char(15)
set @LASTUSER=''

declare @LSTDTEDT datetime
set @LSTDTEDT = convert(datetime,convert(varchar,GETDATE(),103),103)


DECLARE @USWHPSTD char(15)
SET @USWHPSTD=''

DECLARE @TRXTYPE smallint
SET @TRXTYPE=0

DECLARE @SQNCLINE numeric(19,5)
SET @SQNCLINE = 0.00000

DECLARE @GLHDRMSG binary(4)
SET @GLHDRMSG=CONVERT(binary(4),'0x00000000')

DECLARE @GLHDRMS2 binary(4)
SET @GLHDRMS2 = CONVERT(binary(4),'0x00000000')

DECLARE @TRXSORCE char(13)
SET @TRXSORCE=''

DECLARE @RVTRXSRC char(13)
SET @RVTRXSRC=''

DECLARE @SERIES smallint
SET @SERIES=2

DECLARE @ORPSTDDT datetime
SET @ORPSTDDT= CONVERT(DATETIME,'01/01/1900',103)

DECLARE @ORTRXSRC char(13)
SET @ORTRXSRC =''

DECLARE @OrigDTASeries smallint
SET @OrigDTASeries =0

DECLARE @DTAControlNum char(21)
SET @DTAControlNum=''

DECLARE @DTATRXType smallint
SET @DTATRXType=0

DECLARE @DTA_Index numeric(19,5)
--obtener dta index
SELECT @DTA_Index=MAX(DTA_Index) FROM
GL10000

SET @DTA_Index= @DTA_Index+1
 
-- OBTENER CURRENCY IDX
DECLARE @CURRNIDX smallint

select @CURRNIDX= CURRNIDX from DYNAMICS..MC40200


DECLARE @RATETPID char(15)
SET @RATETPID=''

DECLARE @EXGTBLID char(15)
SET @EXGTBLID=''

DECLARE  @XCHGRATE numeric(19,7)
SET @XCHGRATE=0.0000000

DECLARE  @EXCHDATE datetime
SET @EXCHDATE=CONVERT(DATETIME,'01/01/1900',103)

DECLARE  @TIME1 datetime
SET @TIME1=CONVERT(DATETIME,'01/01/1900',103)

DECLARE @RTCLCMTD smallint
SET @RTCLCMTD=0

DECLARE @NOTEINDX numeric(19,5)

SELECT @NOTEINDX=MAX(NOTEINDX) FROM GL10000
SET @NOTEINDX=@NOTEINDX+3

DECLARE @GLHDRVAL binary(4)
SET @GLHDRVAL=convert(binary(4),'0x06000000')

DECLARE @PERIODID smallint
SELECT @PERIODID = MONTH(GETDATE())

DECLARE @OPENYEAR SMALLINT
SELECT @OPENYEAR= YEAR(GETDATE())

DECLARE @CLOSEDYR smallint 
SET @CLOSEDYR=0

DECLARE @HISTRX tinyint
SET @HISTRX=0

DECLARE @REVPRDID smallint
SET @REVPRDID=0

DECLARE @REVYEAR smallint
SET @REVYEAR=0

DECLARE @REVCLYR smallint
SET @REVCLYR=0

DECLARE @REVHIST tinyint
SET @REVHIST=0

DECLARE @ERRSTATE int
SET @ERRSTATE=0

DECLARE @ICTRX tinyint
SET @ICTRX=0

DECLARE @ORCOMID char(5)
SET @ORCOMID=''


DECLARE @ORIGINJE int
SET @ORIGINJE =0

DECLARE @ICDISTS tinyint
SET @ICDISTS=0

DECLARE @PRNTSTUS smallint
SET @PRNTSTUS=1

DECLARE @DENXRATE numeric(19,7)
SET @DENXRATE = CONVERT(numeric(19,7),0)

DECLARE @MCTRXSTT smallint
SET @MCTRXSTT=0

DECLARE @DOCDATE DATETIME
SET @DOCDATE = CONVERT(DATETIME,'01/01/1900',103)


DECLARE @Tax_Date DATETIME
SET @Tax_Date = CONVERT(DATETIME,'01/01/1900',103)

DECLARE @VOIDED tinyint
SET @VOIDED =0

DECLARE @Original_JE int
SET @Original_JE=0

DECLARE @Original_JE_Year smallint
SET @Original_JE_Year=0

DECLARE @Original_JE_Seq_Num numeric(19,5)
SET @Original_JE_Seq_Num = 0.00000

DECLARE @Correcting_Trx_Type smallint
SET  @Correcting_Trx_Type=0

DECLARE @Ledger_ID smallint
SET  @Ledger_ID=0

DECLARE @Adjustment_Transaction tinyint
SET @Adjustment_Transaction=0

DECLARE @DEX_ROW_TS datetime
SET @DEX_ROW_TS = GETDATE()

INSERT INTO [GL10000]
           ([BACHNUMB]
           ,[BCHSOURC]
           ,[JRNENTRY]
           ,[RCTRXSEQ]
           ,[SOURCDOC]
           ,[REFRENCE]
           ,[TRXDATE]
           ,[RVRSNGDT]
           ,[RCRNGTRX]
           ,[BALFRCLC]
           ,[PSTGSTUS]
           ,[LASTUSER]
           ,[LSTDTEDT]
           ,[USWHPSTD]
           ,[TRXTYPE]
           ,[SQNCLINE]
           ,[GLHDRMSG]
           ,[GLHDRMS2]
           ,[TRXSORCE]
           ,[RVTRXSRC]
           ,[SERIES]
           ,[ORPSTDDT]
           ,[ORTRXSRC]
           ,[OrigDTASeries]
           ,[DTAControlNum]
           ,[DTATRXType]
           ,[DTA_Index]
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[RATETPID]
           ,[EXGTBLID]
           ,[XCHGRATE]
           ,[EXCHDATE]
           ,[TIME1]
           ,[RTCLCMTD]
           ,[NOTEINDX]
           ,[GLHDRVAL]
           ,[PERIODID]
           ,[OPENYEAR]
           ,[CLOSEDYR]
           ,[HISTRX]
           ,[REVPRDID]
           ,[REVYEAR]
           ,[REVCLYR]
           ,[REVHIST]
           ,[ERRSTATE]
           ,[ICTRX]
           ,[ORCOMID]
           ,[ORIGINJE]
           ,[ICDISTS]
           ,[PRNTSTUS]
           ,[DENXRATE]
           ,[MCTRXSTT]
           ,[DOCDATE]
           ,[Tax_Date]
           ,[VOIDED]
           ,[Original_JE]
           ,[Original_JE_Year]
           ,[Original_JE_Seq_Num]
           ,[Correcting_Trx_Type]
           ,[Ledger_ID]
           ,[Adjustment_Transaction]
           ,[DEX_ROW_TS])
     VALUES
           (@BACHNUMB, 
           @BCHSOURC,
           @JRNENTRY,
           @RCTRXSEQ,
           @SOURCDOC,
           @REFRENCE,
           @TRXDATE, 
           @RVRSNGDT,
           @RCRNGTRX,
           @BALFRCLC,
           @PSTGSTUS,
           @LASTUSER,
           @LSTDTEDT,
           @USWHPSTD,
           @TRXTYPE, 
           @SQNCLINE,
           @GLHDRMSG,
           @GLHDRMS2,
           @TRXSORCE,
           @RVTRXSRC,
           @SERIES, 
           @ORPSTDDT, 
           @ORTRXSRC, 
           @OrigDTASeries, 
           @DTAControlNum, 
           @DTATRXType,
           @DTA_Index, 
           @CURNCYID, 
           @CURRNIDX, 
           @RATETPID, 
           @EXGTBLID, 
           @XCHGRATE, 
           @EXCHDATE, 
           @TIME1, 
           @RTCLCMTD, 
           @NOTEINDX, 
           @GLHDRVAL, 
           @PERIODID,
           @OPENYEAR,
           @CLOSEDYR,
           @HISTRX, 
           @REVPRDID,
           @REVYEAR, 
           @REVCLYR, 
           @REVHIST, 
           @ERRSTATE,
           @ICTRX, 
           @ORCOMID, 
           @ORIGINJE,
           @ICDISTS, 
           @PRNTSTUS,
           @DENXRATE,
           @MCTRXSTT,
           @DOCDATE, 
           @Tax_Date,
           @VOIDED, 
           @Original_JE, 
           @Original_JE_Year, 
           @Original_JE_Seq_Num, 
           @Correcting_Trx_Type, 
           @Ledger_ID, 
           @Adjustment_Transaction, 
           @DEX_ROW_TS)
END

GO 
GRANT EXEC ON insertarCabeceraGL TO DYNGRP
GO
--------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[covi_insertarAsientosContables]    Script Date: 09/25/2012 12:18:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[covi_insertarAsientosContables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[covi_insertarAsientosContables]
GO


CREATE proc [dbo].[covi_insertarAsientosContables]
@nroLote varchar(20),
@REFRENCE varchar(31),
@monto numeric(19,5),
@cuentaDebito varchar(30),
@cuentaCredito varchar(30),
@DSCRIPTN varchar(31),
@CURNCYID varchar(10),
@TRXDATE datetime,
@RVRSNGDT datetime,
@EXPNDATE datetime,
@EXCHDATE datetime,
@SOURCDOC varchar(10)
AS
BEGIN
	--procedimiento para generar asientos contables 
	BEGIN TRANSACTION
		BEGIN TRY			
		-- obtener numero de entrada de diario
			declare @numeroDiario char(13)
			set @numeroDiario=''
			declare @p3 int
			set @p3=0
			exec taGetNextJournalEntry @I_vInc_Dec=1,@O_vJournalEntryNumber=@numeroDiario output,@O_iErrorState=@p3 output

			--select @numeroDiario as num, @p3 as err
			-- Insertar asiento Cuenta debito
			declare @p41 int
			set @p41=0
			declare @p42 varchar(255)
			set @p42=''
			exec taGLTransactionLineInsert 
			@I_vBACHNUMB=@nroLote,
			@I_vJRNENTRY=@numeroDiario,
			@I_vSQNCLINE=1.00000,
			@I_vACTINDX=default,
			@I_vCRDTAMNT=0.00000,
			@I_vDEBITAMT=@monto,
			@I_vACTNUMST=@cuentaDebito,
			@I_vDSCRIPTN=@DSCRIPTN,
			@I_vORCTRNUM=default,
			@I_vORDOCNUM=default,
			@I_vORMSTRID=default,
			@I_vORMSTRNM=default,
			@I_vORTRXTYP=default,
			@I_vOrigSeqNum=default,
			@I_vORTRXDESC=default,
			@I_vTAXDTLID=default,
			@I_vTAXAMNT=default,
			@I_vTAXACTNUMST=default,
			@I_vDOCDATE=default,
			@I_vCURNCYID=@CURNCYID,
			@I_vXCHGRATE=default,
			@I_vRATETPID=default,
			@I_vEXPNDATE=default,
			@I_vEXCHDATE=default,
			@I_vEXGTBDSC=default,
			@I_vEXTBLSRC=default,
			@I_vRATEEXPR=default,
			@I_vDYSTINCR=default,
			@I_vRATEVARC=default,
			@I_vTRXDTDEF=default,
			@I_vRTCLCMTD=default,
			@I_vPRVDSLMT=default,
			@I_vDATELMTS=default,
			@I_vTIME1=default,
			@I_vRequesterTrx=default,
			@I_vUSRDEFND1=default,
			@I_vUSRDEFND2=default,
			@I_vUSRDEFND3=default,
			@I_vUSRDEFND4=default,
			@I_vUSRDEFND5=default,
			@O_iErrorState=@p41 output,
			@oErrString=@p42 output
			--select @p41, @p42
		-- Insertar asiento cuenta credito

			exec taGLTransactionLineInsert 
			@I_vBACHNUMB=@nroLote,
			@I_vJRNENTRY=@numeroDiario,
			@I_vSQNCLINE=2.00000,
			@I_vACTINDX=default,
			@I_vCRDTAMNT=@monto,
			@I_vDEBITAMT=0.00000,
			@I_vACTNUMST=@cuentaCredito,
			@I_vDSCRIPTN=@DSCRIPTN,
			@I_vORCTRNUM=default,
			@I_vORDOCNUM=default,
			@I_vORMSTRID=default,
			@I_vORMSTRNM=default,
			@I_vORTRXTYP=default,
			@I_vOrigSeqNum=default,
			@I_vORTRXDESC=default,
			@I_vTAXDTLID=default,
			@I_vTAXAMNT=default,
			@I_vTAXACTNUMST=default,
			@I_vDOCDATE=default,
			@I_vCURNCYID=@CURNCYID,
			@I_vXCHGRATE=default,
			@I_vRATETPID=default,
			@I_vEXPNDATE=default,
			@I_vEXCHDATE=default,
			@I_vEXGTBDSC=default,
			@I_vEXTBLSRC=default,
			@I_vRATEEXPR=default,
			@I_vDYSTINCR=default,
			@I_vRATEVARC=default,
			@I_vTRXDTDEF=default,
			@I_vRTCLCMTD=default,
			@I_vPRVDSLMT=default,
			@I_vDATELMTS=default,
			@I_vTIME1=default,
			@I_vRequesterTrx=default,
			@I_vUSRDEFND1=default,
			@I_vUSRDEFND2=default,
			@I_vUSRDEFND3=default,
			@I_vUSRDEFND4=default,
			@I_vUSRDEFND5=default,
			@O_iErrorState=@p41 output,
			@oErrString=@p42 output
			--select @p41, @p42
			
			--exec insertarCabeceraGL @nroLote,
			--@numeroDiario,
			--@SOURCDOC,
			--@REFRENCE,
			--@TRXDATE,
			--@RVRSNGDT,
			--@CURNCYID
			
			
		    SET DATEFORMAT YMD
			DECLARE @STRTRXDATE	AS VARCHAR(30)
			DECLARE @STRRVRSNGDT AS VARCHAR(30)
			DECLARE @STREXPNDATE AS VARCHAR(30)
			DECLARE @STREXCHDATE AS VARCHAR(30)
			
			SET @STRTRXDATE = CAST(DATEPART(YEAR,@TRXDATE) AS VARCHAR(4))+RIGHT('0'+CAST(DATEPART(MONTH,@TRXDATE) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DATEPART(DAY,@TRXDATE) AS VARCHAR(2)),2)
			SET @STRRVRSNGDT =CAST(DATEPART(YEAR,@RVRSNGDT) AS VARCHAR(4)) + RIGHT('0'+CAST(DATEPART(MONTH,@RVRSNGDT) AS VARCHAR(2)),2)  + RIGHT('0'+CAST(DATEPART(DAY,@RVRSNGDT) AS VARCHAR(2)),2)
			SET @STREXPNDATE =CAST(DATEPART(YEAR,@EXPNDATE) AS VARCHAR(4)) + RIGHT('0'+CAST(DATEPART(MONTH,@EXPNDATE) AS VARCHAR(2)),2)  + RIGHT('0'+CAST(DATEPART(DAY,@EXPNDATE) AS VARCHAR(2)),2)
			SET @STREXCHDATE =CAST(DATEPART(YEAR,@EXCHDATE) AS VARCHAR(4)) + RIGHT('0'+CAST(DATEPART(MONTH,@EXCHDATE) AS VARCHAR(2)),2)  + RIGHT('0'+CAST(DATEPART(DAY,@EXCHDATE) AS VARCHAR(2)),2)
			
			
		--insertar cabecera de asiento
			declare @p35 int
			set @p35=0
			declare @p36 varchar(255)
			set @p36=''
			exec taGLTransactionHeaderInsert 
			@I_vBACHNUMB=@nroLote,
			@I_vJRNENTRY=@numeroDiario,
			@I_vREFRENCE=@REFRENCE,
			@I_vTRXDATE=@STRTRXDATE,
			@I_vRVRSNGDT=@STRRVRSNGDT,
			@I_vTRXTYPE=0,
			@I_vSQNCLINE=default,
			@I_vSERIES=default,
			@I_vCURNCYID=@CURNCYID,
			@I_vXCHGRATE=default,
			@I_vRATETPID=default,
			@I_vEXPNDATE=@STREXPNDATE,
			@I_vEXCHDATE=@STREXCHDATE,
			@I_vEXGTBDSC=default,
			@I_vEXTBLSRC=default,
			@I_vRATEEXPR=default,
			@I_vDYSTINCR=default,
			@I_vRATEVARC=default,
			@I_vTRXDTDEF=0,
			@I_vRTCLCMTD=default,
			@I_vPRVDSLMT=default,
			@I_vDATELMTS=default,
			@I_vTIME1=@STREXCHDATE,
			@I_vRequesterTrx=default,
			@I_vSOURCDOC=@SOURCDOC,
			@I_vLedger_ID=default,
			@I_vUSERID=default,
			@I_vAdjustment_Transaction=default,
			@I_vNOTETEXT=default,
			@I_vUSRDEFND1=default,
			@I_vUSRDEFND2=default,
			@I_vUSRDEFND3=default,
			@I_vUSRDEFND4=default,
			@I_vUSRDEFND5=default,
			@O_iErrorState=@p35 output,
			@oErrString=@p36 output
		
			COMMIT
			
			DECLARE @nroEntradaDiario int
			set @nroEntradaDiario = CONVERT(INT,@numeroDiario)
			SELECT @nroEntradaDiario
			
		END TRY
		BEGIN CATCH
								
			ROLLBACK
			DECLARE @MENSAJE VARCHAR(8000)
			SELECT @MENSAJE = ERROR_MESSAGE()
			SET @MENSAJE= 'HA OCURRIDO UN ERROR EN SQL :'+ @MENSAJE + 'TRXDATE '+ CONVERT(VARCHAR,@TRXDATE,103) 
				+'RVRSNGDT '+ CONVERT(VARCHAR,@RVRSNGDT,103) 
			RAISERROR(@MENSAJE,16,1)
		END CATCH
		
END


GO
GRANT EXEC ON covi_insertarAsientosContables TO DYNGRP
GO

-----------------------------------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[OBTENER_RESUMEN]    Script Date: 09/19/2012 13:46:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSERTAR_EXTENDER_FECHA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[INSERTAR_EXTENDER_FECHA]
GO
CREATE PROC [dbo].[INSERTAR_EXTENDER_FECHA]
@PT_Window_ID char(15),
@PT_UD_Key char(201),
@PT_UD_Number smallint,
@DATE1 datetime
AS
BEGIN
 
INSERT INTO [GPTST].[dbo].[EXT00102]
           ([PT_Window_ID]
           ,[PT_UD_Key]
           ,[PT_UD_Number]
           ,[DATE1])
     VALUES
           (@PT_Window_ID
           ,@PT_UD_Key 
           ,@PT_UD_Number
           ,@DATE1)

END
GO
GRANT EXEC ON INSERTAR_EXTENDER_FECHA TO DYNGRP
GO
---------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[ReporteRecaudacionPeaje_trabajo]    Script Date: 09/27/2012 18:31:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteRecaudacionPeaje_trabajo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteRecaudacionPeaje_trabajo]
GO

CREATE PROC [dbo].[ReporteRecaudacionPeaje_trabajo]
@Estacion varchar(max),
@Turno varchar(max),
@FechaInicio datetime, 
@FechaFin datetime
AS
BEGIN
	-- CREAR TABLA TEMPORAL
	DECLARE @tabla_temp as TABLE(
		estacion varchar(5),
		turno varchar(3),
		fecha datetime,
		monto numeric(19,2),
		diff varchar(10)
	);
	--tabla de turnos
	DECLARE @tabla_turnos as TABLE(turno varchar(3));
	--POBLAR TURNO
	INSERT INTO @tabla_turnos
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Turno)
	-- tabla de estaciones
	DECLARE @tabla_estaciones as TABLE(
		codEstacion varchar(5)
	);	
	INSERT INTO @tabla_estaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Estacion)
	
	-- insertar tickets sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'TK' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = LTRIM(RTRIM(def.USRDEF04))
	WHERE CUSTNMBR <> 'DETRACCION' AND f.DOCID not like '%SOBR%'
	AND  f.DOCID not like '%DISC%'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	-- insertar sobrantes sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'SOB' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND f.DOCID like '%SOBR%'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	-- insertar discrepancias sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as monto,
	'DIS' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	WHERE CUSTNMBR <> 'DETRACCION' AND  f.DOCID like '%DISC%'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	
	-- insertar detraccion sin contabilizar
	INSERT INTO @tabla_temp	
	select LTRIM(RTRIM(def.USRDEF04)) AS ESTACION, LTRIM(RTRIM(def.USRDEF03)) AS TURNO, DOCDATE as FECHA,
	convert(numeric(19,2),SUM(DOCAMNT))  as MONTO,
	'DET' as diff
	from SOP10100 AS f
	INNER JOIN SOP10106 AS def
	on def.SOPNUMBE = f.SOPNUMBE AND RTRIM(f.LOCNCODE) = RTRIM(def.USRDEF04)
	where CUSTNMBR = 'DETRACCION'
	group by def.USRDEF03,DOCDATE,def.USRDEF04
	
	
	-- en lugar de consumos de vales y telepass insertar el monto facturado
	--telepass
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTEL' as DIFF
	FROM  SOP10200 AS d INNER JOIN SOP10100 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TEL%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  
	
	
	--tags
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FTAG' as DIFF
	FROM  SOP10200 AS d INNER JOIN SOP10100 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%TAG%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  

	
	
	select estacion,turno,CONVERT(VARCHAR,t.fecha,103) as fecha,
	sum(CASE WHEN diff ='TK' THEN monto ELSE 0 END) AS RecaudacionTickets,
	sum(CASE WHEN diff ='DET' THEN monto ELSE 0 END) AS Detracciones,
	sum(CASE WHEN diff ='FTEL' THEN monto ELSE 0 END) AS Telepass,
	sum(CASE WHEN diff ='FTAG' THEN monto ELSE 0 END) AS TAG,
	--sum(CASE WHEN diff ='VAL' THEN monto ELSE 0 END) AS Vales,
	--sum(CASE WHEN diff ='TEL' THEN monto ELSE 0 END) AS Telepass,
	sum(CASE WHEN diff ='DIS' THEN monto ELSE 0 END) AS Discrepancia,
	sum(CASE WHEN diff ='SOB' THEN monto ELSE 0 END) AS Sobrante
	
	from @tabla_temp as t
	where fecha between @FechaInicio and @FechaFin and estacion in (select CodEstacion from  @tabla_estaciones)
	and turno in (select turno from @tabla_turnos)
	group by turno,fecha,estacion
	order by t.fecha desc, turno asc
END
GO
GRANT EXEC ON ReporteRecaudacionPeaje_trabajo TO DYNGRP
GO

---------------------------------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[INSERTAR_EXTENDER_FECHA]    Script Date: 09/28/2012 12:39:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSERTAR_EXTENDER_FECHA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[INSERTAR_EXTENDER_FECHA]
GO

CREATE PROC [dbo].[INSERTAR_EXTENDER_FECHA]
@PT_Window_ID char(15),
@PT_UD_Key char(201),
@PT_UD_Number smallint,
@DATE1 datetime
AS
BEGIN

INSERT INTO [GPTST].[dbo].[EXT00102]
           ([PT_Window_ID]
           ,[PT_UD_Key]
           ,[PT_UD_Number]
           ,[DATE1])
     VALUES
           (@PT_Window_ID
           ,@PT_UD_Key 
           ,@PT_UD_Number
           ,@DATE1)

END

GO
GRANT EXEC ON INSERTAR_EXTENDER_FECHA TO DYNGRP
GO

------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [dbo].[ReporteRecaudacionPeaje]    Script Date: 09/28/2012 09:58:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReporteRecaudacionPeaje_Vales]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReporteRecaudacionPeaje_Vales]
GO

CREATE PROC [dbo].[ReporteRecaudacionPeaje_Vales]
@Estacion varchar(max),
@FechaInicio datetime, 
@FechaFin datetime
AS
BEGIN
	-- CREAR TABLA TEMPORAL
	DECLARE @tabla_temp as TABLE(
		estacion varchar(30),
		turno varchar(30),
		fecha datetime,
		monto numeric(19,2),
		diff varchar(30)
	);
	
	-- tabla de estaciones
	DECLARE @tabla_estaciones as TABLE(
		codEstacion varchar(5)
	);	
	INSERT INTO @tabla_estaciones
	SELECT value FROM dbo.FN_RPTPTO_SplitData(@Estacion)
	
	
	-- en lugar de consumos de vales y telepass insertar el monto facturado
	--VALES PREPAGO
	INSERT INTO @tabla_temp	
	SELECT 
	LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) AS ESTACION,
	'01' AS TURN0, h.DOCDATE as FECHA, 
	CONVERT(NUMERIC(19,2),SUM(d.XTNDPRCE)) as MONTO, 'FVAL' as DIFF
	FROM  SOP30300 AS d INNER JOIN SOP30200 AS h
	on d.SOPNUMBE = h.SOPNUMBE
	WHERE d.ITEMNMBR like '%VPREP%'AND h.DOCDATE BETWEEN @FechaInicio AND @FechaFin
	AND LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1))) in (select CodEstacion from  @tabla_estaciones)
	group by h.DOCDATE, LTRIM(RTRIM(RIGHT(RTRIM(d.ITEMNMBR), CHARINDEX('.',REVERSE(RTRIM(d.ITEMNMBR)))-1)))  
	
	
	select estacion,turno,CONVERT(VARCHAR,t.fecha,103) as fecha,
	sum(CASE WHEN diff ='FVAL' THEN monto ELSE 0 END) AS FacturacionVales	
	from @tabla_temp as t
	where fecha between @FechaInicio and @FechaFin and estacion in (select CodEstacion from  @tabla_estaciones)
	group by turno,fecha,estacion
	order by t.fecha desc, turno asc
END
GO
GRANT EXEC ON ReporteRecaudacionPeaje_Vales TO DYNGRP
GO

-----------------------------------------------------------------------------------------------------------

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
