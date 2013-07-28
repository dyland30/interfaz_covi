USE [GPCOV]
GO

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
