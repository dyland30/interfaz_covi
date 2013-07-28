USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[covi_insertarAsientosContables]    Script Date: 09/25/2012 12:18:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[covi_insertarAsientosContables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[covi_insertarAsientosContables]
GO

USE [GPTST]
GO

/****** Object:  StoredProcedure [dbo].[covi_insertarAsientosContables]    Script Date: 09/25/2012 12:18:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
		declare @ErrorMessage as varchar(max) 
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
   @I_vSQNCLINE=16384.00000,  
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
	IF LEN(@p42) <> 0 
    BEGIN 
        SET @ErrorMessage = dbo.fnvGeteConnectErrorMessage(@p42) 
        RAISERROR (@ErrorMessage, 18, 1)
    END  
  
   exec taGLTransactionLineInsert   
   @I_vBACHNUMB=@nroLote,  
   @I_vJRNENTRY=@numeroDiario,  
   @I_vSQNCLINE=32768.00000,  
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
     
     IF LEN(@p42) <> 0 
    BEGIN 
        SET @ErrorMessage = dbo.fnvGeteConnectErrorMessage(@p42) 
        RAISERROR (@ErrorMessage, 18, 1)
    END  
   --exec insertarCabeceraGL @nroLote,  
   --@numeroDiario,  
   --@SOURCDOC,  
   --@REFRENCE,  
   --@TRXDATE,  
   --@RVRSNGDT,  
   --@CURNCYID  
     
     
      SET DATEFORMAT YMD  
   DECLARE @STRTRXDATE AS VARCHAR(30)  
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
    
    IF LEN(@p36) <> 0 
    BEGIN 
        SET @ErrorMessage = dbo.fnvGeteConnectErrorMessage(@p36) 
        RAISERROR (@ErrorMessage, 18, 1)
    END  
    
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



