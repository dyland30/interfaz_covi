USE [REPCOVI]
GO

/****** Object:  Table [dbo].[DETALLEVENTAS]    Script Date: 04/04/2013 14:37:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETALLEVENTAS]') AND type in (N'U'))
DROP TABLE [dbo].[DETALLEVENTAS]
GO

USE [REPCOVI]
GO

/****** Object:  Table [dbo].[DETALLEVENTAS]    Script Date: 04/04/2013 14:37:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
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
	[regnum] [varchar](25) NULL,
 CONSTRAINT [PK_REPDETALLEVENTAS] PRIMARY KEY CLUSTERED 
(
	[tipdoc] ASC,
	[nrodoc] ASC,
	[seriedoc] ASC,
	[codarticulo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

