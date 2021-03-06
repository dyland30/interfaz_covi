USE [REPCOVI]
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'almacenarHistorico') AND type in (N'P', N'PC'))
DROP PROC almacenarHistorico
GO

CREATE PROC almacenarHistorico
AS

BEGIN
-- =============================================
-- Author:		Daniel Castillo
-- Create date: 14/08/2012
-- Description:	Inserta en la tabla de detalles historicos
-- los detalles que se encuentren en estado procesado (P)
-- o con error (E)
-- =============================================
	BEGIN TRANSACTION
	BEGIN TRY
	
		INSERT INTO DETALLEVENTAS_OLD
		SELECT * FROM DETALLEVENTAS
		WHERE estado='P' or estado ='E';
		
		DELETE FROM DETALLEVENTAS
		WHERE estado='P' or estado ='E';
		
		COMMIT
	
	END TRY
	
	BEGIN CATCH
		ROLLBACK
		PRINT 'SE HA PRODUCIDO UN ERROR'
	
	END CATCH

END

