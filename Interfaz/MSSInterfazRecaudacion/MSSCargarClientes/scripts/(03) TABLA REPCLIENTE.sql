USE [REPCOVI]
GO

/****** Object:  Table [dbo].[REPCLIENTE]    Script Date: 04/04/2013 14:38:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[REPCLIENTE]') AND type in (N'U'))
DROP TABLE [dbo].[REPCLIENTE]
GO

USE [REPCOVI]
GO

/****** Object:  Table [dbo].[REPCLIENTE]    Script Date: 04/04/2013 14:38:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
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

GO

SET ANSI_PADDING OFF
GO


