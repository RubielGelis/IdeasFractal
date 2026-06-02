IF OBJECT_ID('dbo.spza_InterfaceXmlRespuesta_IdeasFractral', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spza_InterfaceXmlRespuesta_IdeasFractral;
GO

CREATE PROCEDURE dbo.[spza_InterfaceXmlRespuesta_IdeasFractral]
		@Op VARCHAR(50) = NULL
	,	@XML VARCHAR(MAX) = NULL
	,	@Codigo VARCHAR(25)  = NULL
	,	@MensajeError VARCHAR(MAX) = NULL
 
AS
BEGIN
	SET NOCOUNT ON
	--SET CONCAT_NULL_YIELDS_NULL OFF;
	/*** DECLARACION DE VARIABLES A NIVEL GENERAL ***/
	DECLARE @NodoXML XML
	DECLARE @RegistroActual BIGINT
	DECLARE @TotalRegistros BIGINT
	DECLARE @TextoRaiserror VARCHAR(MAX)
	DECLARE @Error INT
	DECLARE @XmlA XML
	DECLARE @XmlR VARCHAR(MAX)=''
	DECLARE @Reservas TABLE (
		Id	INT IDENTITY,
		InternalLocator VARCHAR(25),
		LocProvider VARCHAR(25),
		MessageIntegration VARCHAR(50),
		StatusIntegration VARCHAR(50),
		ProductType VARCHAR(50)
		)
/*** SE CONVIERTE EL @XML RECIBIDO A UN TIPO DE DATOS XML VERDADERO ***/
	BEGIN TRY
		SET @NodoXML = @XML
	END TRY
	BEGIN CATCH
		RAISERROR('Error en la captura del XML para el procesamiento de las Proveedores de Booking.' , 16 , 1)
		RETURN 1
	END CATCH
	SET @TextoRaiserror=''
	BEGIN TRY
		INSERT INTO @Reservas (InternalLocator,LocProvider,MessageIntegration,StatusIntegration,ProductType)
		SELECT	InternalLocator,
				LocProvider,
				MessageIntegration,
				StatusIntegration,
				ProductType
		FROM (
			SELECT InternalLocator=REPLACE(REPLACE(R.Reservas.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				LocProvider=REPLACE(REPLACE(R.Reservas.value('(locSource)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				MessageIntegration='Todo Error',
				StatusIntegration='Error',
				ProductType='Flight'
			FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight') As R(Reservas)

			UNION ALL

			SELECT InternalLocator=REPLACE(REPLACE(R.Reservas.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				LocProvider=REPLACE(REPLACE(R.Reservas.value('(locSource)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				MessageIntegration='Todo Error',
				StatusIntegration='Error',
				ProductType='Hotel'
			FROM @NodoXML.nodes('//Books/Book/bookInfoHotels/bookInfoHotel') As R(Reservas)

			UNION ALL

			SELECT InternalLocator=REPLACE(REPLACE(R.Reservas.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				LocProvider=REPLACE(REPLACE(R.Reservas.value('(locSource)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				MessageIntegration='Todo Error',
				StatusIntegration='Error',
				ProductType='Car'
			FROM @NodoXML.nodes('//Books/Book/bookCars/bookCar') As R(Reservas)

			UNION ALL

			SELECT InternalLocator=REPLACE(REPLACE(R.Reservas.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				LocProvider=REPLACE(REPLACE(R.Reservas.value('(locSource)[1]','VARCHAR(12)'),CHAR(9),''),CHAR(10),''),
				MessageIntegration='Todo Error',
				StatusIntegration='Error',
				ProductType='Insurance'
			FROM @NodoXML.nodes('//Books/Book/Insurances/Insurance') As R(Reservas)

		) AS RESERVA
		IF EXISTS(SELECT id FROM @Reservas)
		BEGIN
			IF ISNULL(@MensajeError,'')=''
			BEGIN
				UPDATE R
				SET MessageIntegration='Todo OK',
					StatusIntegration='OK'
				FROM @Reservas R
				INNER JOIN dbo.ReservasGDS G ON G.cd_codigo=R.InternalLocator
				INNER JOIN dbo.ReservaGDS_Detalles D ON D.cd_consecutivo=R.LocProvider
				WHERE R.ProductType='Flight'

				UPDATE R
				SET MessageIntegration='Todo OK',
					StatusIntegration='OK'
				FROM @Reservas R
				INNER JOIN dbo.ReservasGDS G ON G.cd_codigo=R.InternalLocator
				INNER JOIN dbo.ReservaGDS_Servicios D ON D.cd_consecutivo=R.LocProvider
				WHERE R.ProductType IN('Hotel','Car','Insurance')
			END

			SET @XmlA=(
					SELECT 'locField'=@Codigo--ISNULL(RTRIM(LTRIM(InternalLocator)),'')
						,	'codeIntegrationBackofficeField'=ISNULL(RTRIM(LTRIM(InternalLocator)),'')
						,	'statusIntegracionField'= CASE WHEN ISNULL(@MensajeError,'')='' THEN 'OK' ELSE 'Error' END
						,	'messageIntegrationField'= CASE WHEN ISNULL(@MensajeError,'')='' THEN 'Mensaje de exito' ELSE ISNULL(@MensajeError,'') END
						,	'locsField'=convert (xml, 
												(SELECT		'productType'		= ISNULL(RTRIM(LTRIM(loc.ProductType)),'')
														,	'locProvider'	        = ISNULL(RTRIM(LTRIM(loc.LocProvider)),'')
														,	'statusIntegracion'          = ISNULL(RTRIM(LTRIM(loc.StatusIntegration)),'')
														,	'messageIntegration'    = CASE WHEN ISNULL(@MensajeError,'')='' THEN ISNULL(RTRIM(LTRIM(loc.MessageIntegration)),'') ELSE ISNULL(@MensajeError,'') END
												FROM @Reservas loc
												FOR XML AUTO, ELEMENTS--, ROOT(' ')
											))
			FROM @Reservas AS SaleInfoRS
			WHERE SaleInfoRS.id=1
			FOR XML AUTO, ELEMENTS--, ROOT(' ')
			)
			SELECT @XmlA=CONVERT(XML,REPLACE(REPLACE(CONVERT(VARCHAR(MAX),@XmlA),'&lt;','<'),'&gt;','>')) 
			SELECT @XmlR=CONVERT(VARCHAR(MAX),@XmlA)
			SELECT @XmlR
		END
		
	END TRY
	BEGIN CATCH
	
		
		SET @TextoRaiserror = ISNULL ( ERROR_MESSAGE() , '')
	
		SET @TextoRaiserror =	CHAR(13) + CHAR(10) +
								--'Operacion: ' +  @Operacion + CHAR(13) + CHAR(10) + 
								--'Registro: ' +  CONVERT(VARCHAR(10), IsNull(@RegistroActual, 0)) + --' - Cliente: ' + Isnull(@IdCliente,'') + CHAR(13) + CHAR(10) + 
								'Ha ocurrido un error. Información para soporte tecnico:'			+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							    'Numero: ' + isnull(CAST(ERROR_NUMBER()   AS VARCHAR(10)),'') 		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
								'Mensaje: ' + @TextoRaiserror 					   		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							 	'Severidad: ' + isnull(CAST(ERROR_SEVERITY() AS VARCHAR(10)),'') 	+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							 	'Estado: ' + isnull(CAST(ERROR_STATE()    AS VARCHAR(10)),'') 		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
								'Procedimiento: ' + isnull(ERROR_PROCEDURE(),'')					+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
								'Linea: ' + isnull(CAST(ERROR_LINE() 	   AS VARCHAR(10)),'');
	
	RAISERROR ( @TextoRaiserror , 16, 1)
	
	END CATCH

	RETURN
END
GO
