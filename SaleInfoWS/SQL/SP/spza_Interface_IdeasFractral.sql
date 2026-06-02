IF OBJECT_ID('dbo.spza_Interface_IdeasFractral', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spza_Interface_IdeasFractral;
GO
CREATE PROCEDURE dbo.[spza_Interface_IdeasFractral]
		@Op VARCHAR(50) = NULL
	,	@Codigo VARCHAR(25)  = NULL
	,	@XML VARCHAR(MAX) = NULL
	,	@PET VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @id_Interfaces INT
	DECLARE @cd_interfaces VARCHAR(50)
	DECLARE @cd_maestros VARCHAR(25)
	DECLARE @oper VARCHAR(25)
	DECLARE @Error INT= 0
	DECLARE @TextoRaiserror VARCHAR(MAX)
	DECLARE @NombreServicio VARCHAR(MAX)
	DECLARE @Respuesta		VARCHAR(8000)
	DECLARE @Resultado		VARCHAR(8000)
	DECLARE @ResultadoError	VARCHAR(MAX)
	DECLARE @XMLI VARCHAR(MAX)=''
	DECLARE @XMLR VARCHAR(MAX)=''
	DECLARE @XMLD XML
	DECLARE @Reservas TABLE(id INT IDENTITY,Reserva VARCHAR(MAX))
	DECLARE @Respuestas TABLE(id INT IDENTITY,Respuesta VARCHAR(MAX))
	DECLARE @Resultados TABLE(id INT IDENTITY,Resultado VARCHAR(MAX), Mensaje VARCHAR(MAX))
	SET NOCOUNT ON

	BEGIN TRY


		SET @cd_interfaces = 'IdeasFractral'
		SELECT @id_Interfaces = id FROM dbo.Interfaces WHERE cd_codigo = @cd_interfaces
		IF @Op = 'Reserva'
		BEGIN
			SET @oper = 'Insertar'
			SET @NombreServicio = 'Creacion de reserva'
			--IF (ISJSON(@XML)=1)
			--BEGIN
			--	SELECT @XMLI = CONVERT(VARCHAR(MAX),dbo.fnza_jsonaxml(@XML))
			--END
			--ELSE
			--BEGIN
			--	SELECT @XMLI = @XML
			--END
			--BEGIN TRY 
			--	SELECT @XMLI = CONVERT(VARCHAR(MAX),CONVERT(XML,@XML)) 
			--END TRY
			--BEGIN CATCH
			--	SELECT @XMLI = CONVERT(VARCHAR(MAX),dbo.fnza_jsonaxml(@XML)) 
			--END CATCH
			IF (CHARINDEX('{',ISNULL(@XML,''))>0)
			BEGIN
				SELECT @XMLI = CONVERT(VARCHAR(MAX),dbo.fnza_jsonaxml(@XML))
			END
			ELSE
			BEGIN
				SELECT @XMLI = @XML
			END
			
			INSERT INTO @Reservas
			EXEC dbo.spza_InterfaceLeeXMLReserva_IdeasFractral @Op = @Op, @XML = @XMLI
			--return 1 
			IF NOT EXISTS(SELECT id FROM @Reservas)
			BEGIN
				SET @TextoRaiserror= 'Error al generar el XML del inserción de la reserva'
				SET @Respuesta= 'Error al generar el XML del inserción de la reserva'
				SET @Error = 1

			END
			ELSE
			BEGIN
				SELECT @XMLR = Reserva FROM @Reservas WHERE id=1
				
				BEGIN TRY
					SET @XMLD=CONVERT(XML,@XMLR)
					DECLARE @CodigoReserva VARCHAR(12),@msg VARCHAR(MAX),@archivo VARCHAR(250)
					
					SELECT @CodigoReserva=ISNULL(R.Reservas.value('(cd_codigo)[1]','VARCHAR(12)'),'')
					FROM @XMLD.nodes('//reservas/reserva') AS R(Reservas)

					SET @archivo=@CodigoReserva

					SET @msg='Reserva xml procesado exitosamente'
					Insert Into dbo.ReservasGDS_log (cd_sucursal,cd_implante,ds_mensaje,ds_archivo,cd_reserva, ds_reserva,bl_error )
					Select null,null,@msg,@archivo,@CodigoReserva, @XMLI, 0 

					INSERT INTO @Resultados
					Exec dbo.spWSG_ReservasGDS @XML = @XMLR
				
					SELECT @Resultado = @Resultado + Resultado + CHAR(10) FROM @Resultados
					SET @ResultadoError=''
				END TRY
				BEGIN CATCH

					SET @Resultado = ISNULL ( ERROR_MESSAGE() , '')
					SET @Resultado =	'Error al procesar el servicio "' + @NombreServicio + '" ' + 'Error: ' +  @Resultado
					SET @ResultadoError=@Resultado
					SET @Error=1
				END CATCH

				INSERT INTO @Respuestas
				EXEC dbo.[spza_InterfaceXmlRespuesta_IdeasFractral] @Op = NULL,	@XML=@XMLI, @Codigo=@Codigo, @MensajeError=@ResultadoError
				SET @Respuesta=''
				SELECT @Respuesta = @Respuesta + Respuesta + CHAR(10) FROM @Respuestas
				SET @Resultado = @Resultado + @Respuesta
				SET @Error = 0
			END

			SET @XMLR = ISNULL(@XMLR,'')
			INSERT INTO dbo.EquivalenciasInterfaces_Log (Id_Interfaces,cd_maestro,cd_codigo,cd_codigoInte,cd_operacion,ds_xmlpeticion,ds_xmlrespuesta,ds_xmlorg,ds_Logpeticion)
			VALUES(@id_Interfaces,@Op,@Codigo,@Codigo,@oper,@XMLR,@Resultado,@XMLI,@PET)
			SELECT ltrim(rtrim(@Respuesta)) AS 'Respuesta';
			--SELECT CONVERT(XML,ltrim(rtrim(@Respuesta))) AS 'Respuesta';
			RETURN @Error
		END

		


	END TRY
	BEGIN CATCH

		SET @TextoRaiserror = ISNULL ( ERROR_MESSAGE() , '')
		SET @TextoRaiserror =	'Error al procesar el servicio "' + @NombreServicio + '".' + CHAR(13) + CHAR(10) +
								'Error: ' +  @TextoRaiserror
		SET @XMLR=ISNULL(@XMLR,'')	
		INSERT INTO dbo.EquivalenciasInterfaces_Log (Id_Interfaces,cd_maestro,cd_codigo,cd_codigoInte,cd_operacion,ds_xmlpeticion,ds_xmlrespuesta,ds_xmlorg,ds_Logpeticion)
		VALUES(@id_Interfaces,@Op,@Codigo,@Codigo,@oper,@XMLR,@TextoRaiserror,@XMLI,@PET)
		RAISERROR ( @TextoRaiserror , 16, 1)
	END CATCH
		

	RETURN 0
END
GO
