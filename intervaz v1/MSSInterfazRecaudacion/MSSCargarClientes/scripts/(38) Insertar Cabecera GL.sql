USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[insertarCabeceraGL]    Script Date: 09/17/2012 09:35:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[insertarCabeceraGL]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[insertarCabeceraGL]
GO

USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[insertarCabeceraGL]    Script Date: 09/17/2012 09:35:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON 
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


