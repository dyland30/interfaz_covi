USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[InsertarAC_Financiero_SOP_RM]    Script Date: 10/12/2012 18:06:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarAC_Financiero_SOP_RM]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertarAC_Financiero_SOP_RM]
GO

CREATE PROC [dbo].[InsertarAC_Financiero_SOP_RM]
@jentry int,
@DISTTYPE SMALLINT
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
	 
	DECLARE @cant_guiones AS INTEGER 
	DECLARE @loc_serie AS VARCHAR(15)
	DECLARE @loc_correlativo AS VARCHAR(21)
	DECLARE @loc_codigoDocumento AS VARCHAR(3)
	DECLARE @numeroDocumento AS VARCHAR(21)
	SET @loc_codigoDocumento = '01'
	SET @cant_guiones=LEN(@NRODOC) - LEN(REPLACE(@NRODOC,'-',''))
	IF @cant_guiones > 0
	BEGIN
		set @loc_correlativo = RIGHT(@NRODOC,charindex('-',REVERSE(@NRODOC))-1)
		set @loc_serie= LEFT(REPLACE(@NRODOC,@loc_correlativo,''),LEN(REPLACE(@NRODOC,@loc_correlativo,''))-1)
		
		select @numeroDocumento=LOC_Numero_Documento from t_tributarios_venta
		where LOC_CodigoDocumento =@loc_codigoDocumento
		and  LOC_NroDeSerie =@loc_serie
		and LOC_Correlativo =@loc_correlativo
	END

	-- buscar documento en RM
	SELECT @CANT=COUNT(*) FROM RM10101
	WHERE RTRIM(LTRIM(DOCNUMBR)) = @numeroDocumento;
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
		--SET @DISTTYPE  = 2;
		
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
		WHERE DOCNUMBR=@numeroDocumento
		ORDER BY SEQNUMBR DESC
		
		--AUMENTAR SEQNUMBER EN 1
		SET @SEQNUMBR=@SEQNUMBR+16384;
		
		
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
           ,@numeroDocumento
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
		SET @SEQNUMBR=@SEQNUMBR+16384;
           
        
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
           ,@numeroDocumento
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
	   WHERE RTRIM(LTRIM(SOPNUMBE)) = @numeroDocumento
       ORDER BY SEQNUMBR DESC    
           
       -- INSERTAR DEBITO EN SOP
       --AUMENTAR SEQNUMBER EN 1
		SET @SEQNUMBR=@SEQNUMBR+16384;

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
           ,@numeroDocumento
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
		SET @SEQNUMBR=@SEQNUMBR+16384;
		
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
           ,@numeroDocumento
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