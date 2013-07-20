USE [REPCOVI]
GO

/****** Object:  Table [dbo].[DETALLEVENTAS]    Script Date: 09/28/2012 10:49:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETALLEVENTAS]') AND type in (N'U'))
DROP TABLE [dbo].[DETALLEVENTAS]
GO

CREATE TABLE [dbo].[DETALLEVENTAS](
	[tipdoc] [varchar](15) NOT NULL,
	[nrodoc] [varchar](25) NOT NULL,
	[seriedoc] [varchar](15) NOT NULL,
	[seriecaseta] [varchar](4) NULL,
	[seriedetraccion] [varchar](3) NULL,
	[nrodetraccion] [varchar](20) NULL,
	[nomcliente] [varchar](100) NULL,
	[idcliente] [varchar](20) NULL,
	[sentido] [varchar](2) NULL,
	[placa] [varchar](8) NULL,
	[codestacion] [char](4) NULL,
	[formapago] [char](1) NULL,
	[fecdoc] [datetime] NULL,
	[fecproceso] [datetime] NULL,
	[codarticulo] [varchar](30) NOT NULL,
	[cantidad] [numeric](19, 5) NULL,
	[preuni] [numeric](19, 5) NULL,
	[total] [numeric](19, 5) NULL,
	[igv] [numeric](19, 5) NULL,
	[totaldetraccion] [numeric](19, 5) NULL,
	[nrodocasociado] [varchar](25) NULL,
	[fechavencimientovale] [datetime] NULL,
	[nrotag] [varchar](30) NULL,
	[turno] [varchar](5) NULL,
	[tipodocsunat] [varchar](4) NULL,
	[destinooperacion] [varchar](4) NULL,
	[nroasientocont] [int] NULL,
	[estado] [char](1) NULL,
	[observacion] [text] NULL,
	[codlote] [varchar](20) NULL,
 CONSTRAINT [PK_REPDETALLEVENTAS] PRIMARY KEY CLUSTERED 
(
	[tipdoc] ASC,
	[nrodoc] ASC,
	[seriedoc] ASC,
	[codarticulo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


--------------------------------------------------------------------------------------------------------------
/****** Object:  Table [dbo].[DETALLEVENTAS_OLD]    Script Date: 09/28/2012 10:51:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETALLEVENTAS_OLD]') AND type in (N'U'))
DROP TABLE [dbo].[DETALLEVENTAS_OLD]
GO


CREATE TABLE [dbo].[DETALLEVENTAS_OLD](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[tipdoc] [varchar](15) NOT NULL,
	[nrodoc] [varchar](25) NOT NULL,
	[seriedoc] [varchar](15) NOT NULL,
	[seriecaseta] [char](4) NULL,
	[seriedetraccion] [varchar](3) NULL,
	[nrodetraccion] [varchar](20) NULL,
	[nomcliente] [varchar](100) NULL,
	[idcliente] [varchar](20) NULL,
	[sentido] [varchar](2) NULL,
	[placa] [varchar](8) NULL,
	[codestacion] [char](4) NULL,
	[formapago] [char](1) NULL,
	[fecdoc] [datetime] NULL,
	[fecproceso] [datetime] NULL,
	[codarticulo] [varchar](30) NOT NULL,
	[cantidad] [numeric](19, 5) NULL,
	[preuni] [numeric](19, 5) NULL,
	[total] [numeric](19, 5) NULL,
	[igv] [numeric](19, 5) NULL,
	[totaldetraccion] [numeric](19, 5) NULL,
	[nrodocasociado] [varchar](25) NULL,
	[fechavencimientovale] [datetime] NULL,
	[nrotag] [varchar](30) NULL,
	[turno] [varchar](5) NULL,
	[tipodocsunat] [varchar](4) NULL,
	[destinooperacion] [varchar](4) NULL,
	[nroasientocont] [int] NULL,
	[estado] [char](1) NULL,
	[observacion] [text] NULL,
	[codlote] [varchar](20) NULL,
 CONSTRAINT [PK_REPDETALLEVENTAS_OLD] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[tipdoc] ASC,
	[nrodoc] ASC,
	[seriedoc] ASC,
	[codarticulo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

---------------------------------------------------------------------------------------

USE [REPCOVI]
GO

/****** Object:  Table [dbo].[REPCLIENTE]    Script Date: 09/28/2012 10:52:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[REPCLIENTE]') AND type in (N'U'))
DROP TABLE [dbo].[REPCLIENTE]
GO

CREATE TABLE [dbo].[REPCLIENTE](
	[idcliente] [varchar](20) NOT NULL,
	[nomcliente] [varchar](65) NULL,
	[nombrecorto] [varchar](15) NULL,
	[direccion] [varchar](65) NULL,
	[tipopersona] [smallint] NULL,
	[tipodocumento] [char](1) NULL,
	[nombre1] [varchar](31) NULL,
	[nombre2] [varchar](31) NULL,
	[apepaterno] [varchar](31) NULL,
	[apematerno] [varchar](31) NULL,
	[idclase] [varchar](15) NULL,
	[idVendedor] [varchar](15) NULL,
	[idcondicionpago] [varchar](21) NULL,
	[prioridad] [int] NULL,
	[condnivelprecio] [varchar](11) NULL,
	[estado] [char](1) NULL,
	[observacion] [text] NULL,
 CONSTRAINT [PK_REPCLIENTE] PRIMARY KEY CLUSTERED 
(
	[idcliente] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_REPRESUMEN_procesados]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[REPRESUMEN] DROP CONSTRAINT [DF_REPRESUMEN_procesados]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_REPRESUMEN_errores]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[REPRESUMEN] DROP CONSTRAINT [DF_REPRESUMEN_errores]
END

GO

/****** Object:  Table [dbo].[REPRESUMEN]    Script Date: 09/28/2012 10:55:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[REPRESUMEN]') AND type in (N'U'))
DROP TABLE [dbo].[REPRESUMEN]
GO

CREATE TABLE [dbo].[REPRESUMEN](
	[codEstacion] [varchar](5) NOT NULL,
	[serieCaseta] [varchar](5) NOT NULL,
	[turno] [char](2) NOT NULL,
	[procesados] [int] NOT NULL,
	[errores] [int] NOT NULL,
	[lote] [varchar](20) NULL,
 CONSTRAINT [PK_REPRESUMEN] PRIMARY KEY CLUSTERED 
(
	[codEstacion] ASC,
	[serieCaseta] ASC,
	[turno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[REPRESUMEN] ADD  CONSTRAINT [DF_REPRESUMEN_procesados]  DEFAULT ((0)) FOR [procesados]
GO

ALTER TABLE [dbo].[REPRESUMEN] ADD  CONSTRAINT [DF_REPRESUMEN_errores]  DEFAULT ((0)) FOR [errores]
GO

---------------------------------------------------------------------------------------------------



