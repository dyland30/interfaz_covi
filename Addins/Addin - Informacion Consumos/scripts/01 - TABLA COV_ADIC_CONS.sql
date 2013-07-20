USE [GPTST]
GO

/****** Object:  Table [dbo].[COV_ADIC_CONS]    Script Date: 10/26/2012 12:17:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COV_ADIC_CONS]') AND type in (N'U'))
DROP TABLE [dbo].[COV_ADIC_CONS]
GO

CREATE TABLE [dbo].[COV_ADIC_CONS](
	[jrnentry] [int] NOT NULL,
	[turno] [char](2) NULL,
	[estacion] [varchar](4) NULL,
	[categoria] [char](2) NULL,
	[numeroVale] [varchar](40) NULL,
	[placa] [varchar](10) NULL,
	[numeroFactura] [varchar](40) NULL,
 CONSTRAINT [PK_COV_ADIC_CONS] PRIMARY KEY CLUSTERED 
(
	[jrnentry] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

