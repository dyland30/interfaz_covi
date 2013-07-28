USE [GPCOV]
GO

/****** Object:  StoredProcedure [dbo].[PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA]    Script Date: 10/25/2012 16:22:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA]
GO

CREATE PROC [dbo].[PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA]
			@LOC_Numero_Documento varchar(31)
		   ,@LOC_Correlativo varchar(31)
           ,@CUSTNMBR varchar(15)
           ,@TipoDocSunat char(3) --tipo de documento
           ,@DestinoOperacion char(3) --destino de operacion
           ,@LOCNCODE char(11) -- codigo de sitio
           ,@LOC_NroDeSerie varchar(15) -- nro de serie
           ,@DOCDATE datetime -- fecha de documento
           ,@CURNCYID char(15)-- id moneda
           ,@USERID char(15)
         
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @CUSTNAME varchar(65)
		DECLARE @LOC_Descripcion varchar(31)  --descripcion de documento
		DECLARE @DSCRIPTN varchar(21) --descripcion de destino de operacion

		-- obtener nombre de cliente
			SELECT @CUSTNAME=CUSTNAME 
			FROM RM00101
			WHERE RTRIM(CUSTNMBR)= RTRIM(@CUSTNMBR)

		-- obtener descripcion de tipo de documento
			SELECT @LOC_Descripcion=RTRIM(LOC_Descripcion) 
			FROM t_documento_tributario
			WHERE RTRIM(LOC_CodigoDocumento)=RTRIM(@TipoDocSunat)
			
		--obtener descripcion de destino de operacion
			SELECT @DSCRIPTN=RTRIM(DSCRIPTN) 
			FROM t_destino_operacion
			WHERE RTRIM(LOC_Codigo) = RTRIM(@DestinoOperacion)
		--crear numero correlativo

			--cantidad de digitos de la configuracion de localizacion
			DECLARE @CantDigitos SMALLINT
			SELECT @CantDigitos= LVCORREL FROM t_locconf
			
			-- obtener numero anterior
			DECLARE @NumAnt as varchar(31)
			--DECLARE @num as bigint
			DECLARE @cont as integer
			--SELECT @NumAnt= RTRIM(LOC_Correlativo) 
			--FROM t_tribu_correlativos
			--WHERE RTRIM(LOC_NroDeSerie) = RTRIM(@LOC_NroDeSerie)
			--AND RTRIM(LOC_CodigoDocumento) = RTRIM(@TipoDocSunat)
			
			-- VALIDAR CORRELATIVO
			select @cont= COUNT(*)
			from t_tributarios_venta
			where LOC_NroDeSerie = RTRIM(@LOC_NroDeSerie)
			and LOC_Correlativo = @LOC_Correlativo
			and LOC_CodigoDocumento = @TipoDocSunat
			
			DECLARE @STR_MENSAJE VARCHAR(100)
			SET @STR_MENSAJE = 'EL CORRELATIVO '+ @LOC_Correlativo + ' YA EXISTE PARA LA SERIE ' + @LOC_NroDeSerie
			IF @cont>0
			BEGIN
				RAISERROR(@STR_MENSAJE,16,1)
			END
			
			
			---- aumentar en 1 el numero anterior
			--SET @num = CAST(@NumAnt as bigint)+1
			
			----generar codigo
			--set @LOC_Correlativo= RIGHT((REPLICATE('0',@CantDigitos) + CAST(@num as varchar)),@CantDigitos)
				
			
			INSERT INTO t_tributarios_venta
				   ([LOC_Numero_Documento]
				   ,[CUSTNMBR]
				   ,[CUSTNAME]
				   ,[LOC_CodigoDocumento]
				   ,[LOC_Descripcion]
				   ,[LOC_Codigo]
				   ,[DSCRIPTN]
				   ,[LOCNCODE]
				   ,[LOC_NroDeSerie]
				   ,[LOC_Correlativo]
				   ,[LOC_Estado]
				   ,[loc_RefCorrelativo1]
				   ,[DOCDATE]
				   ,[CURNCYID]
				   ,[XCHGRATE]
				   ,[USERID]
				   ,[CREATDDT]
				   ,[MDFUSRID]
				   ,[MODIFDT]
				   ,[LOC_TipoDocRef]
				   ,[LOc_TipoDocRef_Des]
				   ,[LOC_Serie_NC_ND]
				   ,[LOC_Corr_NC_ND]
				   ,[DEX_ROW_TS])
			 VALUES
				   (@LOC_Numero_Documento
				   ,@CUSTNMBR
				   ,@CUSTNAME
				   ,@TipoDocSunat
				   ,@LOC_Descripcion
				   ,@DestinoOperacion
				   ,@DSCRIPTN
				   ,@LOCNCODE
				   ,@LOC_NroDeSerie
				   ,@LOC_Correlativo
				   ,0
				   ,''
				   ,@DOCDATE
				   ,@CURNCYID
				   ,convert(numeric(19,7),0)
				   ,@USERID
				   ,CONVERT(DATETIME,CONVERT(VARCHAR,GETDATE(),103),103)
				   ,''
				   ,CONVERT(datetime,'01/01/1900',103)
				   ,''
				   ,''
				   ,''
				   ,''
				   ,GETDATE())
		           
			 --actualizar valor de configuracion de localizacion
			 --aumentar valor del numero correlativo
			UPDATE t_tribu_correlativos
			SET LOC_Correlativo = @LOC_Correlativo
			WHERE RTRIM(LOC_NroDeSerie) = RTRIM(@LOC_NroDeSerie)
			AND RTRIM(LOC_CodigoDocumento) = RTRIM(@TipoDocSunat)
			
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			
			DECLARE @MENSAJE VARCHAR(MAX)
			SET @MENSAJE = ERROR_MESSAGE()
			
			RAISERROR(@MENSAJE,16,1)
		END CATCH

END

GO
GRANT EXEC ON PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA TO DYNGRP
GO


