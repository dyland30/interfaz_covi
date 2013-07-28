
USE [GPCOV]
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
 
INSERT INTO [GPCOV].[dbo].[EXT00102]
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

