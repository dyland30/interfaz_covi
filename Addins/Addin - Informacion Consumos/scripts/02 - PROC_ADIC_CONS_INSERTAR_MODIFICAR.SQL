
/****** Object:  StoredProcedure [dbo].[PROC_COV_ADIC_CONS_INSERTAR_MODIFICAR]    Script Date: 10/26/2012 14:34:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROC_COV_ADIC_CONS_INSERTAR_MODIFICAR]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PROC_COV_ADIC_CONS_INSERTAR_MODIFICAR]
GO

CREATE PROC [dbo].[PROC_COV_ADIC_CONS_INSERTAR_MODIFICAR]
			@jrnentry int
           ,@turno varchar(2)
           ,@estacion varchar(4)
           ,@categoria varchar(2)
           ,@numeroVale varchar(40)
           ,@placa varchar(10)
           ,@numeroFactura varchar(40)
AS           
BEGIN

	DECLARE @NRO AS INTEGER
	
	SELECT @NRO =COUNT(*)
	FROM COV_ADIC_CONS
	WHERE jrnentry= @jrnentry
	
	IF @NRO > 0 
	BEGIN
		UPDATE [COV_ADIC_CONS]
		SET 
		  [turno] = @turno
		  ,[estacion] = @estacion
		  ,[categoria] = @categoria
		  ,[numeroVale] = @numeroVale
		  ,[placa] = @placa
		  ,[numeroFactura] = @numeroFactura
		 WHERE [jrnentry] = @jrnentry

	END
	ELSE
	BEGIN
		INSERT INTO [COV_ADIC_CONS]
				   ([jrnentry]
				   ,[turno]
				   ,[estacion]
				   ,[categoria]
				   ,[numeroVale]
				   ,[placa]
				   ,[numeroFactura])
			 VALUES
				   (@jrnentry 
				   ,@turno 
				   ,@estacion 
				   ,@categoria 
				   ,@numeroVale 
				   ,@placa 
				   ,@numeroFactura)
	END
END
GO


