USE [GPTST]
GO
IF NOT EXISTS (SELECT * FROM t_documento_tributario WHERE LOC_CodigoDocumento='DET' )
INSERT INTO t_documento_tributario
           ([LOC_TipoRegistroContable]
           ,[LOC_CodigoDocumento]
           ,[LOC_Descripcion]
           ,[LOC_NombreCorto]
           ,[LOC_TipoDocumento]
           ,[LOC_Tasa_Compra]
           ,[LOC_Tasa_Venta])
     VALUES
           (3
           ,'DET'
           ,'DETRACCIÓN'
           ,'-DET'
           ,1
           ,''
           ,'')
GO
