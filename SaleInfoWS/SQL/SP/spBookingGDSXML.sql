
CREATE PROCEDURE dbo.[spBookingGDSXML]
		@Op VARCHAR(50) = NULL
	,	@XML VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN

	SET NOCOUNT ON

	/*** DECLARACION DE VARIABLES A NIVEL GENERAL ***/
	DECLARE @NodoXML XML
	DECLARE @RegistroActual BIGINT
	DECLARE @TotalRegistros BIGINT
	DECLARE @TextoRaiserror VARCHAR(MAX)
	DECLARE @Error INT
	DECLARE @Operacion VARCHAR(50)

	DECLARE @RegistroActualItinerario BIGINT
	DECLARE @TotalRegistrosItinerario BIGINT

	DECLARE @RegistroActualVariables BIGINT
	DECLARE @TotalRegistrosVariables BIGINT

	DECLARE @RegistroActualPaxAdicional BIGINT --rgelis 2018/01/22 req.46714
	DECLARE @TotalRegistrosPaxAdicional BIGINT --rgelis 2018/01/22 req.46714
	DECLARE @TotalRegistrosPaxAdicionalServ BIGINT --rgelis 2018/01/22 req.46714

	DECLARE @RegistroActualVarAdicional BIGINT --rgelis 2018/10/25 req.62804
	DECLARE @TotalRegistrosVarAdicional BIGINT --rgelis 2018/10/25 req.62804
	DECLARE @TotalRegistrosVarAdicionalServ BIGINT --rgelis 2018/10/25 req.62804

	DECLARE @RegistroActualCargosImpuestos BIGINT --rgelis 2022/05/16 req.227439
	DECLARE @TotalRegistrosCargosImpuestos BIGINT --rgelis 2022/05/16 req.227439
	DECLARE @TotalRegistrosCargosImpuestosServ BIGINT --rgelis 2022/05/16 req.227439

	DECLARE @RegistroActualFormasPagos BIGINT --rgelis 2022/05/16 req.227439
	DECLARE @TotalRegistrosFormasPagos BIGINT --rgelis 2022/05/16 req.227439
	DECLARE @TotalRegistrosFormasPagosServ BIGINT --rgelis 2022/05/16 req.227439

	DECLARE @RegistroActualFee BIGINT 
	DECLARE @TotalRegistrosFee BIGINT 
	DECLARE @TotalRegistrosFeeServ BIGINT 
	
	/*** DECLARACION DE VARIABLES PARA EL LLAMADO DEL SP DEL MAESTRO ***/
	DECLARE 
		@OpBookingGDS				VARCHAR(15)
		,@ds_tipoitem				VARCHAR(15)
		,@cd_sucursal				CHAR(5) 
		,@cd_implante				CHAR(5) 
		,@bl_externo				BIT
		,@id_reserva				INT 
		,@iden_gds					INT
		,@cd_codigo					CHAR(12)
		,@ds_fecha					CHAR(8) 
		,@cd_tiqueteador			CHAR(6)
		,@cd_vendedor				CHAR(3)
		,@cd_cliente				VARCHAR(25)
		,@reserva					VARCHAR(MAX)
		,@cd_TipoTransaccion		CHAR(1) 
		,@ds_pax_number				INT
		,@ds_pax_firstnm			VARCHAR(30)
		,@ds_pax_lastnm				VARCHAR(30)
		,@ds_pax_prefix				CHAR(3)
		,@cd_pax_cedula				CHAR(15)
		,@ds_pax_telefono			CHAR(15)
		,@ds_tkt_number				CHAR(10)
		,@ds_tkt_prefix				CHAR(3)
		,@ds_aero_code				CHAR(3)
		,@ds_moneda					CHAR(3)
		,@am_tarifa					NUMERIC(18,2)
		,@am_iva					NUMERIC(18,2)
		,@am_tua					NUMERIC(18,2)
		,@am_vat					NUMERIC(18,2)
		,@ds_cc_code				CHAR(2)
		,@ds_cc_number				CHAR(16)
		--Fare Basis (M4)
		,@cd_farebasis				VARCHAR(25)
		--detalle itinerario
		,@cd_aero_siglas			CHAR(3)
		,@cd_aero_salida			CHAR(3)
		,@cd_aero_llegada			CHAR(3)
		,@orden						INT
		,@ds_fecha_salida			CHAR(8)
		,@ds_hora_salida			CHAR(5)
		,@ds_hora_llegada			CHAR(5)
		,@cd_clase					CHAR(2)
		--Informacion de ahorro
		,@am_highfare				MONEY
		,@am_lowfare				MONEY
		,@am_fare					MONEY
		,@ds_reasoncode				CHAR(2)
		--Informacion de nuevo cliente
		,@ds_cliname				VARCHAR (50)
		,@ds_clidir					VARCHAR (50)
		,@ds_clicity				VARCHAR (50)
		,@ds_cliid					CHAR (25)
		,@ds_clirazoncial			VARCHAR (250)
		,@ds_cliname2				VARCHAR (60)
		,@ds_clilastname			VARCHAR (60)
		,@ds_clilastname2			VARCHAR (60)
		,@ds_clitel					VARCHAR (25)
		,@cd_clipais				VARCHAR (25)
		,@cd_clitipodoc				VARCHAR (100)
		,@cd_clitipotercero			CHAR (1)
		,@cd_CentroCostoCliente		VARCHAR(50)
		--Inormacion adicional del tiquete
		,@am_comb					MONEY
		,@am_tao					MONEY
		,@am_ivatao					MONEY 
		,@am_cap					MONEY
		,@am_ivacap					MONEY
		,@ds_cc_code2				CHAR(2) 
		,@ds_cc_number2				VARCHAR(16) 
		,@am_fp1					MONEY
		,@am_fp2					MONEY
		--Informacion  de renta de Autos
		,@dt_entrega				CHAR(17)
		,@in_cars					TINYINT 
		,@cd_carcode				CHAR(2)
		,@cd_confirmation			VARCHAR(16)
		,@cd_citysalida				CHAR(3) 
		,@dt_retorno				CHAR(17)  
		,@cd_cartype				VARCHAR(20)
		,@cd_currency				CHAR(3)
		,@cd_bookingsource			VARCHAR(20) 
		,@cd_ratecode				VARCHAR(10) 
		,@am_tarifarenta			MONEY 
		--Informaciion de hotel
		,@dt_checkin				VARCHAR(8) 
		,@in_guests					INT 
		,@cd_city					VARCHAR(3) 
		,@cd_htlchain				VARCHAR(2)
		,@dt_checkout				VARCHAR(8) 
		,@ds_htlname				VARCHAR(32) 
		,@in_habs					INT 
		,@cd_bed					VARCHAR(3) 
		,@cd_htlcur					VARCHAR(3) 
		,@am_htltarifa				MONEY 
		,@cd_agcur					VARCHAR(3) 
		,@am_agtarifa				MONEY 
		,@ds_dir1					VARCHAR(50) 
		,@ds_tel					VARCHAR(12) 
		,@ds_fax					VARCHAR(12)
		--Informaciion de servicios de terceros
		,@cd_conceptofacturacion	VARCHAR(3) 
		,@cd_TipoServicio			VARCHAR(3) 
		,@cd_Proveedores			VARCHAR(25) 
		,@ds_Descrip				varCHAR(500)
		--Tkt revisado
		,@cd_tktrevisado			VARCHAR(14)
		--Itinerario y clases
		,@ds_itinerario				VARCHAR(64)
		,@ds_clases					VARCHAR(36)
		,@in_nacionalidad			TINYINT
		--Valores a credito y de contado
		,@am_TarifaContado			MONEY
		,@am_IvaContado				MONEY
		,@am_OtrosContado			MONEY
		,@am_TarifaCredito			MONEY
		,@am_IvaCredito				MONEY
		,@am_OtrosCredito			MONEY
		--Comision del tiquete
		,@am_Comision				MONEY
		,@ds_Observaciones			VARCHAR(8000)
		,@ds_ClienteEmail			VARCHAR(100)
		,@bl_ClienteActualizar		BIT
		,@bl_NotificacionMPD		BIT
		,@cd_NumeroPoliza			VARCHAR(50)
		,@cd_AnexoPoliza			VARCHAR(50)
		,@am_ValorPoliza			MONEY
		,@cd_FormaPagoTAO			VARCHAR(3)
		,@cd_TarjetaCreditoTAO		VARCHAR(2)
		,@cd_NumeroTarjetaTAO		VARCHAR(16)
		,@cd_VencimientoTarjetaTAO	VARCHAR(5)
		,@cd_NumeroPolizaTAO		VARCHAR(50)
		,@cd_AnexoPolizaTAO			VARCHAR(50)
		,@am_PorDesFormaPagoTA		NUMERIC(8,4) 
		,@ds_NumVuelo				VARCHAR(25) 
		,@ds_TipoVuelo				CHAR(1) 
		,@cd_Penalidad				CHAR(14)
		,@am_TasaCambio				MONEY  
		,@ds_cc_vence				CHAR(5) 
		,@ds_cc_vence2				CHAR(5) 
		,@ds_cc_autorizacion		VARCHAR(25)
		,@ds_cc_autorizacion2		VARCHAR(25)
		,@ds_cc_voucher				VARCHAR(10)
		,@ds_cc_voucher2			VARCHAR(10)
		,@ds_AutorizacionTarjetaTAO	VARCHAR(25)
		,@ds_VoucherTarjetaTAO		VARCHAR(10)
		,@am_fptao					MONEY 
		,@in_cc_cuotas				INT 
		,@in_cc_cuotas2				INT 
		,@in_cuotasTarjetaTAO		INT 
		,@in_NumTktConj				INT  
		,@cd_TipoTarifaTAO			VARCHAR(25) 
		,@cd_TipoTiquete			CHAR(3) 
		,@PCC						VARCHAR(5) 
		,@PCC_Emite					VARCHAR(5) 
		,@bl_ahorro					BIT 
		,@in_CantidadTarifaTAO		INT 
		,@in_CantidadSegmentoTAO	INT 
		,@cd_tourcode				VARCHAR(25) 
		,@ds_contrato				VARCHAR(25) 
		,@am_valor					MONEY 
		,@cd_tourcode2				VARCHAR(25) 
		,@cd_Ahorro					VARCHAR(25) 
		,@cd_auxiliar				VARCHAR(25) 
		--Variables
		,@Id_ReservaGDS_Servicios	INT
		,@ds_paxClasificacion		CHAR (7) --inicio rgelis 2018/01/22 req.46714 
		,@cd_voucherpax				VARCHAR(25)
		,@in_edad					INT
		,@cd_consecutivo			VARCHAR(25) --fin rgelis 2018/10/25 req.62804 
		--Variables Adicionales
		,@in_orden					INT
		,@ds_nombre					VARCHAR(20)
		,@ds_valor					VARCHAR(8000) --fin rgelis 2018/10/25 req.62804
		--Variables Nuevas para la cabecera del documento.
		,@cd_tipoventa				Varchar(16)
		,@cd_licitacion				Varchar(25)
		,@ds_evento					Varchar(250)
		,@ds_campolibre1			Varchar(500)
		,@ds_campolibre2			Varchar(500)
		,@cd_facturador				Varchar(3)
		,@cd_especialista			Varchar(25)
		,@cd_tipoformapagoproveedor	Varchar(25)
		,@cd_medioreservacion		Varchar(25)
		,@ds_indice					VARCHAR(5) --rgelis 2020/03/24 correcion por interfaz con juniper
		,@cd_tipoproveedor			VARCHAR(3)
		,@ds_tipoproveedor			VARCHAR(60)
		,@ds_descripcion			VARCHAR(500)
		--Cargos e Impuestos
		,@Id_ReservaGDS_Detalles	INT
		,@cd_codigocarg				VARCHAR(3)
		,@cd_tipo					VARCHAR(1) --inicio rgelis 2022/05/16 req.227439
		,@cd_codigopadre			VARCHAR(3)
		,@cd_tipopadre				VARCHAR(1)
		,@am_porcentaje				SMALLMONEY
		,@am_contado				MONEY 
		,@am_credito				MONEY --fin rgelis 2022/05/16 req.227439
		--Formas Pagos
		,@cd_codigofp				VARCHAR(50)
		,@ds_nombrefp				VARCHAR(50)
		,@cd_tipotarjeta			VARCHAR(2) 
		,@ds_numerotarjeta			VARCHAR(16)
		,@ds_vouchertarjeta			VARCHAR(25)
		,@ds_expiraciontarjeta		VARCHAR(5) 
		,@ds_autorizaciontarjeta	VARCHAR(25)
		,@in_coutas					INT 
		,@cd_banco					VARCHAR(3) 
		,@ds_cheque					VARCHAR(30)
		,@ds_plaza					VARCHAR(30)
		,@ds_referencia				VARCHAR(50)
		,@ds_Poliza					VARCHAR(20)
		,@ds_PolizaAnexo			VARCHAR(20)
		,@am_iva2					MONEY
		,@reservaxml				VARCHAR(MAX)

	/*** DECLARACION DE TABLA PARA LLENAR LOS DATOS GENERALES DEL MAESTRO ***/
	DECLARE @Booking TABLE (
		Id							INT IDENTITY
		,OpBookingGDS				VARCHAR(15)
		,ds_tipoitem				VARCHAR(15)
		,cd_sucursal				CHAR(5) 
		,cd_implante				CHAR(5) 
		,bl_externo					BIT
		,id_reserva					INT 
		,iden_gds					INT
		,cd_codigo					CHAR(12)
		,ds_fecha					CHAR(8) 
		,cd_tiqueteador				CHAR(6)
		,cd_vendedor				CHAR(3)
		,cd_cliente					VARCHAR(25)
		,reserva					VARCHAR(MAX)
		,cd_TipoTransaccion			CHAR(1) 
		,ds_pax_number				INT
		,ds_pax_firstnm				VARCHAR(30)
		,ds_pax_lastnm				VARCHAR(30)
		,ds_pax_prefix				CHAR(3)
		,cd_pax_cedula				CHAR(15)
		,ds_pax_telefono			CHAR(15)
		,ds_tkt_number				CHAR(10)
		,ds_tkt_prefix				CHAR(3)
		,ds_aero_code				CHAR(3)
		,ds_moneda					CHAR(3)
		,am_tarifa					NUMERIC(18,2)
		,am_iva						NUMERIC(18,2)
		,am_tua						NUMERIC(18,2)
		,am_vat						NUMERIC(18,2)
		,ds_cc_code					CHAR(2)
		,ds_cc_number				CHAR(16)
		--Fare Basis (M4)
		,cd_farebasis				VARCHAR(25)
		--detalle itinerario
		,cd_aero_siglas				CHAR(3)
		,cd_aero_salida				CHAR(3)
		,cd_aero_llegada			CHAR(3)
		,orden						INT
		,ds_fecha_salida			CHAR(8)
		,ds_hora_salida				CHAR(5)
		,ds_hora_llegada			CHAR(5)
		,cd_clase					CHAR(2)
		--Informacion de ahorro
		,am_highfare				MONEY
		,am_lowfare					MONEY
		,am_fare					MONEY
		,ds_reasoncode				CHAR(2)
		--Informacion de nuevo cliente
		,ds_cliname					VARCHAR (50)
		,ds_clidir					VARCHAR (50)
		,ds_clicity					VARCHAR (50)
		,ds_cliid					CHAR (25)
		,ds_clirazoncial			VARCHAR (250)
		,ds_cliname2				VARCHAR (60)
		,ds_clilastname				VARCHAR (60)
		,ds_clilastname2			VARCHAR (60)
		,ds_clitel					VARCHAR (25)
		,cd_clipais					VARCHAR (25)
		,cd_clitipodoc				VARCHAR (100)
		,cd_clitipotercero			CHAR (1)
		,cd_CentroCostoCliente		VARCHAR(50)
		--Inormacion adicional del tiquete
		,am_comb					MONEY
		,am_tao						MONEY
		,am_ivatao					MONEY 
		,am_cap						MONEY
		,am_ivacap					MONEY
		,ds_cc_code2				CHAR(2) 
		,ds_cc_number2				VARCHAR(16) 
		,am_fp1						MONEY
		,am_fp2						MONEY
		--Informacion  de renta de Autos
		,dt_entrega					CHAR(17)
		,in_cars					TINYINT 
		,cd_carcode					CHAR(2)
		,cd_confirmation			VARCHAR(16)
		,cd_citysalida				CHAR(3) 
		,dt_retorno					CHAR(17)  
		,cd_cartype					VARCHAR(20)
		,cd_currency				CHAR(3)
		,cd_bookingsource			VARCHAR(20) 
		,cd_ratecode				VARCHAR(10) 
		,am_tarifarenta				MONEY 
		--Informaciion de hotel
		,dt_checkin					CHAR(8) 
		,in_guests					INT 
		,cd_city					CHAR(3) 
		,cd_htlchain				CHAR(2)
		,dt_checkout				CHAR(8) 
		,ds_htlname					VARCHAR(32) 
		,in_habs					INT 
		,cd_bed						CHAR(3) 
		,cd_htlcur					CHAR(3) 
		,am_htltarifa				MONEY 
		,cd_agcur					CHAR(3) 
		,am_agtarifa				MONEY 
		,ds_dir1					VARCHAR(50) 
		,ds_tel						VARCHAR(12) 
		,ds_fax						VARCHAR(12)
		--Informaciion de servicios de terceros
		,cd_conceptofacturacion		CHAR(3) 
		,cd_TipoServicio			CHAR(3) 
		,cd_Proveedores				VARCHAR(25) 
		,ds_Descrip					varCHAR(500)
		--Tkt revisado
		,cd_tktrevisado				CHAR(14)
		--Itinerario y clases
		,ds_itinerario				VARCHAR(64)
		,ds_clases					VARCHAR(36)
		,in_nacionalidad			TINYINT
		--Valores a credito y de contado
		,am_TarifaContado			MONEY
		,am_IvaContado				MONEY
		,am_OtrosContado			MONEY
		,am_TarifaCredito			MONEY
		,am_IvaCredito				MONEY
		,am_OtrosCredito			MONEY
		--Comision del tiquete
		,am_Comision				MONEY
		,ds_Observaciones			VARCHAR(8000)
		,ds_ClienteEmail			VARCHAR(100)
		,bl_ClienteActualizar		BIT
		,bl_NotificacionMPD			BIT
		,cd_NumeroPoliza			VARCHAR(50)
		,cd_AnexoPoliza				VARCHAR(50)
		,am_ValorPoliza				MONEY
		,cd_FormaPagoTAO			CHAR(3)
		,cd_TarjetaCreditoTAO		CHAR(2)
		,cd_NumeroTarjetaTAO		CHAR(16)
		,cd_VencimientoTarjetaTAO	CHAR(5)
		,cd_NumeroPolizaTAO			VARCHAR(50)
		,cd_AnexoPolizaTAO			VARCHAR(50)
		,am_PorDesFormaPagoTA		NUMERIC(8,4) 
		,ds_NumVuelo				VARCHAR(25) 
		,ds_TipoVuelo				CHAR(1) 
		,cd_Penalidad				CHAR(14)
		,am_TasaCambio				MONEY  
		,ds_cc_vence				CHAR(5) 
		,ds_cc_vence2				CHAR(5) 
		,ds_cc_autorizacion			VARCHAR(25)
		,ds_cc_autorizacion2		VARCHAR(25)
		,ds_cc_voucher				VARCHAR(10)
		,ds_cc_voucher2				VARCHAR(10)
		,ds_AutorizacionTarjetaTAO	VARCHAR(25)
		,ds_VoucherTarjetaTAO		VARCHAR(10)
		,am_fptao					MONEY 
		,in_cc_cuotas				INT 
		,in_cc_cuotas2				INT 
		,in_cuotasTarjetaTAO		INT 
		,in_NumTktConj				INT  
		,cd_TipoTarifaTAO			VARCHAR(25) 
		,cd_TipoTiquete				CHAR(3) 
		,PCC						VARCHAR(5) 
		,PCC_Emite					VARCHAR(5) 
		,bl_ahorro					BIT 
		,in_CantidadTarifaTAO		INT 
		,in_CantidadSegmentoTAO		INT 
		,cd_tourcode				VARCHAR(25) 
		,ds_contrato				VARCHAR(25) 
		,am_valor					MONEY 
		,cd_tourcode2				VARCHAR(25) 
		,cd_Ahorro					VARCHAR(25) 
		,cd_consecutivo				VARCHAR(25)
		,cd_auxiliar				VARCHAR(16)
		--Variables Nuevas para la cabecera del documento.
		,cd_tipoventa				Varchar(16)
		,cd_licitacion				Varchar(25)
		,ds_evento					Varchar(250)
		,ds_campolibre1				Varchar(500)
		,ds_campolibre2				Varchar(500)
		,cd_facturador				Varchar(3)
		,cd_especialista			Varchar(25)
		,cd_tipoformapagoproveedor	Varchar(25)
		,cd_medioreservacion		Varchar(25)
		,ds_indice					VARCHAR(5) --rgelis 2020/03/24 correcion por interfaz con juniper
		,cd_tipoproveedor			VARCHAR(3)
		,ds_tipoproveedor			VARCHAR(60)
		,ds_descripcion				VARCHAR(500)
		,am_iva2					MONEY
		,reservaxml					VARCHAR(MAX)
	)	
	
	Declare @ReservaGDS_Itinerarios TABLE 
	(
		id             INT IDENTITY NOT NULL,
		cd_reserva	   VARCHAR(12) NOT NULL,
		ds_tkt_number  VARCHAR(10) NOT NULL,
		orden          TINYINT NULL,
		cd_origen      CHAR (3) NULL,
		cd_destino     CHAR (3) NULL,
		cd_clase       CHAR (1) NULL,
		fecha_salida   VARCHAR(8) NULL,
		hora_salida    VARCHAR (5) NULL,
		hora_llegada   VARCHAR (5) NULL,
		terminal       VARCHAR (50) NULL,
		cd_aero_siglas CHAR (2) NULL,
		cd_farebasis   VARCHAR (25) NULL,
		ds_NumVuelo    VARCHAR (25) NULL,
		ds_TipoVuelo   CHAR (1) NULL,
		am_valor       MONEY NULL,
		cd_consecutivo VARCHAR(25)
	)

	Declare @ReservaGDS_Pasajeros TABLE 
	(
		id					INT IDENTITY NOT NULL,
		in_orden			INT NOT NULL,
		cd_reserva			VARCHAR(12) NOT NULL,
		cd_consecutivo		VARCHAR(25) NOT NULL,
		ds_pax_firstnm      CHAR (30) NULL,
		ds_pax_lastnm		CHAR (30) NULL,
		ds_pax_prefix       CHAR (3) NULL,
		cd_pax_cedula		VARCHAR (15) NULL,
		ds_pax_telefono		VARCHAR (15) NULL
	)

	Declare @ReservaGDS_VariablesAdicionales TABLE 
	(
		id					INT IDENTITY NOT NULL,
		in_orden			INT NOT NULL,
		cd_reserva			VARCHAR(12) NOT NULL,
		cd_consecutivo		VARCHAR(25) NOT NULL,
		ds_nombre			VARCHAR(20) NOT NULL,
		ds_valor			VARCHAR(8000) NULL
	)

	Declare @ReservaGDS_CargosImpuestos TABLE 
	(
		id					INT IDENTITY NOT NULL,
		in_orden			INT NOT NULL,
		cd_reserva			VARCHAR(12) NOT NULL,
		cd_consecutivo		VARCHAR(25) NOT NULL,
		cd_codigo			VARCHAR(3)  NOT NULL,
		ds_nombre			VARCHAR(50) NOT NULL,
		cd_tipo				VARCHAR(1) NOT NULL, --'1 cargo, 2 descuento, 3 impuesto 4 retenciones'
		cd_codigopadre		VARCHAR(3) NULL,
		cd_tipopadre		VARCHAR(1) NULL,
		am_porcentaje		SMALLMONEY NULL,
		am_contado			MONEY NOT NULL,
		am_credito			MONEY NOT NULL,
		am_valor			MONEY NOT NULL
	)

	Declare @ReservaGDS_FormasPagos TABLE 
		(
		id						INT IDENTITY NOT NULL,
		in_orden				INT NOT NULL,
		cd_reserva				VARCHAR(12) NOT NULL,
		cd_consecutivo			VARCHAR(25) NOT NULL,
		cd_codigo				VARCHAR(50) NOT NULL,
		ds_nombre				VARCHAR(50) NOT NULL,
		cd_tipotarjeta			VARCHAR(2) NULL,
		ds_numerotarjeta		VARCHAR(16) NULL,
		ds_vouchertarjeta		VARCHAR(25) NULL,
		ds_expiraciontarjeta	VARCHAR(5) NULL,
		ds_autorizaciontarjeta	VARCHAR(25) NULL,
		in_coutas				INT NULL,
		cd_banco				VARCHAR(3) NULL,
		ds_cheque				VARCHAR(30) NULL,
		ds_plaza				VARCHAR(30) NULL,
		ds_referencia			VARCHAR(50) NULL,
		ds_Poliza				VARCHAR(20) NULL,
		ds_PolizaAnexo			VARCHAR(20) NULL,
		am_valor				MONEY NOT NULL
	)

	Declare @ReservaGDS_FEE TABLE 
	(
		id					INT IDENTITY NOT NULL,
		in_orden			INT NOT NULL,
		cd_reserva			VARCHAR(12) NOT NULL,
		cd_consecutivo		VARCHAR(25) NOT NULL,
		cd_conceptofac		VARCHAR(5) NOT NULL,
		cd_subcodigo		VARCHAR(5) NULL,
		am_valor			MONEY NOT NULL,
		ds_servicio			VARCHAR(8000) NULL 
	)


	/*** SE CONVIERTE EL @XML RECIBIDO A UN TIPO DE DATOS XML VERDADERO ***/
	BEGIN TRY
		SET @NodoXML = @XML
	END TRY
	BEGIN CATCH
		RAISERROR('Error en la captura del XML para el procesamiento de las Booking.' , 16 , 1)
		RETURN 1
	END CATCH
	SET @TextoRaiserror=''
	
	SELECT @TextoRaiserror = 
		 CASE WHEN (ISDATE(R.BookingGds.value('ds_fecha[1]','CHAR(8)'))=1 AND LEN(R.BookingGds.value('ds_fecha[1]','CHAR(8)'))=8) OR ISNULL(R.BookingGds.value('ds_fecha[1]','CHAR(8)'),'')='' THEN '' ELSE 'La Fecha de la reserva debe estar en Formato aaaammdd'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('ds_pax_number[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('ds_pax_number[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('ds_pax_number[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Número de pasajeros de la reserva debe ser númerico'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_tarifa[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_tarifa[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_tarifa[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tarifa del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END 
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_iva[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_iva[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_iva[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'IVA del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_tua[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_tua[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_tua[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tasas aeroportuarias del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_vat[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_vat[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_vat[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Otros valores del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_highfare[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_highfare[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_highfare[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tarifa más alta del tiquete debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_lowfare[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_lowfare[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_lowfare[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tarifa más baja del tiquete debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_fare[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_fare[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_fare[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tarifa cobrada debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_comb[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_comb[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_comb[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Cargo por combustible del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_tao[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_tao[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_tao[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor de la Tarifa Administrativa del tiquete debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_ivatao[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_ivatao[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_ivatao[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'IVA de la Tarifa Administrativa del tiquete debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_cap[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_cap[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_cap[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor de la tarifa del cargo de emisión del tiquete debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_ivacap[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_ivacap[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_ivacap[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor del IVA del cargo de emisión del tiquete debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_fp1[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_fp1[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_fp1[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor de la primera forma de pago debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_fp2[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_fp2[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_fp2[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor de la segundo de pago debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISDATE(R.BookingGds.value('dt_checkin[1]','CHAR(8)'))=1 AND CHARINDEX(',',R.BookingGds.value('dt_checkin[1]','CHAR(8)'))=0) OR ISNULL(R.BookingGds.value('dt_checkin[1]','CHAR(8)'),'')='' THEN '' ELSE 'Fecha de check in debe estar en Formato aaaammdd'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISDATE(R.BookingGds.value('dt_checkout[1]','CHAR(8)'))=1 AND CHARINDEX(',',R.BookingGds.value('dt_checkout[1]','CHAR(8)'))=0) OR ISNULL(R.BookingGds.value('dt_checkout[1]','CHAR(8)'),'')='' THEN '' ELSE 'Fecha de check out debe estar en Formato aaaammdd'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_guests[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_guests[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('in_guests[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Número de huéspedes debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_habs[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_habs[1]','INT'))=0) OR ISNULL(R.BookingGds.value('in_habs[1]','INT'),'')='' THEN '' ELSE 'Número de habitaciones debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_htltarifa[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_htltarifa[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_htltarifa[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tarifa de Hotel debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_agtarifa[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_agtarifa[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_agtarifa[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Otros valores del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_nacionalidad[1]','TINYINT'))=1 AND CHARINDEX(',',R.BookingGds.value('in_nacionalidad[1]','TINYINT'))=0) OR ISNULL(R.BookingGds.value('in_nacionalidad[1]','TINYINT'),'')='' THEN '' ELSE 'Nacionalidad del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_TarifaContado[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_TarifaContado[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_TarifaContado[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valores de la tarifa Contado del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_IvaContado[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_IvaContado[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_IvaContado[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'IVA de Contado del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_OtrosContado[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_OtrosContado[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_OtrosContado[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Otros valores Contado del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_TarifaCredito[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_TarifaCredito[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_TarifaCredito[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor de la Tarifa credito del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_IvaCredito[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_IvaCredito[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_IvaCredito[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Iva Crédito del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_OtrosCredito[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_OtrosCredito[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_OtrosCredito[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Otros valores crédito del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_Comision[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_Comision[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_Comision[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valor de la Comisión del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_ValorPoliza[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_ValorPoliza[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_ValorPoliza[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valores de la poliza del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_PorDesFormaPagoTA[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_PorDesFormaPagoTA[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_PorDesFormaPagoTA[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'POrcentaje de descuanto de forma de pago del ítem debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_TasaCambio[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_TasaCambio[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_TasaCambio[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Tasa de cambio debe ser Númerica sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('am_fptao[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('am_fptao[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('am_fptao[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Valores de la forma de pago de la tarifa administrativa del tiquete debe ser Númerica sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_cc_cuotas[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_cc_cuotas[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('in_cc_cuotas[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Número de cuotas de primera forma de pago debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_cc_cuotas2[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_cc_cuotas2[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('in_cc_cuotas2[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Número de cuotas de la segunda forma de pago debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_cuotasTarjetaTAO[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_cuotasTarjetaTAO[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('in_cuotasTarjetaTAO[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Numero de cuotas de forma de pago de tarifa administrativa debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_NumTktConj[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_NumTktConj[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('in_NumTktConj[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Número de tiquetes en conjuncion debe ser Númerico sin Comas(,) saparador decimal punto(.)'  +CHAR(13)+CHAR(10) END
		+CASE WHEN (ISNUMERIC(R.BookingGds.value('in_CantidadTarifaTAO[1]','VARCHAR(25)'))=1 AND CHARINDEX(',',R.BookingGds.value('in_CantidadTarifaTAO[1]','VARCHAR(25)'))=0) OR ISNULL(R.BookingGds.value('in_CantidadTarifaTAO[1]','VARCHAR(25)'),'')='' THEN '' ELSE 'Cantidad de Tarifas administrativas debe ser Númerico sin Comas(,) saparador decimal punto(.)' END
	FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	
	IF ISNULL(@TextoRaiserror,'')<>''
	BEGIN
		RAISERROR (@TextoRaiserror , 16, 1)
		RETURN 1
	END 
	
	SELECT @iden_gds=ISNULL(R.BookingGds.value('iden_gds[1]','int'),6)
	FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	SET @iden_gds = ISNULL(@iden_gds,6)
	--INSERT INTO @ReservaGDS_Itinerarios (cd_reserva,ds_tkt_number,orden,cd_origen,cd_destino,cd_clase,fecha_salida,hora_salida,hora_llegada,terminal,cd_aero_siglas,cd_farebasis,ds_NumVuelo,ds_TipoVuelo,am_valor,cd_consecutivo)
	--Select
	--	cd_reserva				= R.BookingGds.value('../../cd_codigo[1]','VARCHAR(6)')
	--	,ds_tkt_number			= R.BookingGds.value('../../ds_tkt_number[1]','VARCHAR(10)')
	--	,orden					= R.BookingGds.value('orden[1]','INT')
	--	,cd_aero_salida			= R.BookingGds.value('cd_aero_salida[1]','CHAR(3)')
	--	,cd_aero_llegada		= R.BookingGds.value('cd_aero_llegada[1]','CHAR(3)')
	--	,cd_clase				= R.BookingGds.value('cd_clase[1]','CHAR(2)')
	--	,ds_fecha_salida		= R.BookingGds.value('ds_fecha_salida[1]','CHAR(8)')
	--	,ds_hora_salida			= R.BookingGds.value('ds_hora_salida[1]','CHAR(5)')
	--	,ds_hora_llegada		= R.BookingGds.value('ds_hora_llegada[1]','CHAR(5)')
	--	,cd_aero_llegada		= R.BookingGds.value('cd_aero_llegada[1]','CHAR(3)')
	--	,cd_aero_siglas			= R.BookingGds.value('cd_aero_siglas[1]','CHAR(3)')
	--	,cd_farebasis			= R.BookingGds.value('cd_farebasis[1]','VARCHAR(25)')
	--	,ds_NumVuelo			= R.BookingGds.value('ds_NumVuelo[1]','VARCHAR(25)')
	--	,ds_TipoVuelo			= R.BookingGds.value('ds_TipoVuelo[1]','CHAR(1)')
	--	,am_valor				= R.BookingGds.value('am_valor[1]','VARCHAR(25)')
	--	,cd_consecutivo			= R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)')
	--FROM @NodoXML.nodes('//Booking/reserva/itinerarios/itinerario') As R(BookingGDS)

	INSERT INTO @ReservaGDS_Itinerarios (cd_reserva,ds_tkt_number,orden,cd_origen,cd_destino,cd_clase,fecha_salida,hora_salida,hora_llegada,terminal,cd_aero_siglas,cd_farebasis,ds_NumVuelo,ds_TipoVuelo,am_valor,cd_consecutivo)
	SELECT cd_reserva			= cd_codigo
		  ,ds_tkt_number		= ds_tkt_number
		  ,orden				= I.Itinerario.value('orden[1]','INT')
		  ,cd_aero_salida		= I.Itinerario.value('cd_aero_salida[1]','CHAR(3)')
		  ,cd_aero_llegada		= I.Itinerario.value('cd_aero_llegada[1]','CHAR(3)')
		  ,cd_clase				= I.Itinerario.value('cd_clase[1]','CHAR(2)')
		  ,ds_fecha_salida		= I.Itinerario.value('ds_fecha_salida[1]','CHAR(8)')
		  ,ds_hora_salida		= I.Itinerario.value('ds_hora_salida[1]','CHAR(5)')
		  ,ds_hora_llegada		= I.Itinerario.value('ds_hora_llegada[1]','CHAR(5)')
		  ,cd_aero_llegada		= I.Itinerario.value('cd_aero_llegada[1]','CHAR(3)')
		  ,cd_aero_siglas		= I.Itinerario.value('cd_aero_siglas[1]','CHAR(3)')
		  ,cd_farebasis			= I.Itinerario.value('cd_farebasis[1]','VARCHAR(25)')
		  ,ds_NumVuelo			= I.Itinerario.value('ds_NumVuelo[1]','VARCHAR(25)')
		  ,ds_TipoVuelo			= I.Itinerario.value('ds_TipoVuelo[1]','CHAR(1)')
		  ,am_valor				= I.Itinerario.value('am_valor[1]','VARCHAR(25)')
		  ,cd_consecutivo		= cd_consecutivo
	FROM(
		SELECT
			 cd_codigo		= R.BookingGds.value('cd_codigo[1]','VARCHAR(12)')
			,cd_consecutivo	= R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
			,ds_tkt_number	= R.BookingGds.value('ds_tkt_number[1]','VARCHAR(10)')
			,Iti			= R.BookingGds.query('./itinerarios/itinerario') 
		FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	) AS reserva
	CROSS APPLY reserva.Iti.nodes('itinerario') I(Itinerario)


	Delete From @ReservaGDS_Itinerarios Where ISNULL(cd_origen,'') = ''
	SET @TotalRegistrosItinerario = ISNULL ( (SELECT COUNT(1) FROM @ReservaGDS_Itinerarios) , 0 )
	SET @RegistroActualItinerario = 1

	/*** SE INSERTAR LOS REGISTROS DEL MAESTRO - PARA LUEGO LLAMAR AL SP ***/
	INSERT INTO @Booking(
	OpBookingGDS,ds_tipoitem,cd_sucursal,cd_implante,bl_externo,id_reserva,iden_gds,cd_codigo,ds_fecha,cd_tiqueteador,cd_vendedor,cd_cliente,reserva,cd_TipoTransaccion,ds_pax_number,ds_pax_firstnm,ds_pax_lastnm,ds_pax_prefix,cd_pax_cedula
	,ds_pax_telefono,ds_tkt_number,ds_tkt_prefix,ds_aero_code,ds_moneda,am_tarifa,am_iva,am_tua,am_vat,ds_cc_code,ds_cc_number,am_highfare,am_lowfare,am_fare,ds_reasoncode,ds_cliname,ds_clidir,ds_clicity,ds_cliid,ds_clirazoncial,ds_cliname2,ds_clilastname,ds_clilastname2,ds_clitel,cd_clipais,cd_clitipodoc,cd_clitipotercero,cd_CentroCostoCliente
	,am_comb,am_tao,am_ivatao,am_cap,am_ivacap,ds_cc_code2,ds_cc_number2,am_fp1,am_fp2,dt_entrega,in_cars,cd_carcode,cd_confirmation,cd_citysalida,dt_retorno,cd_cartype,cd_currency,cd_bookingsource,cd_ratecode,am_tarifarenta
	,dt_checkin,in_guests,cd_city,cd_htlchain,dt_checkout,ds_htlname,in_habs,cd_bed,cd_htlcur,am_htltarifa,cd_agcur,am_agtarifa,ds_dir1,ds_tel,ds_fax,cd_conceptofacturacion,cd_TipoServicio,cd_Proveedores,ds_Descrip,cd_tktrevisado
	,ds_itinerario,ds_clases,in_nacionalidad,am_TarifaContado,am_IvaContado,am_OtrosContado,am_TarifaCredito,am_IvaCredito,am_OtrosCredito,am_Comision,ds_Observaciones,ds_ClienteEmail,bl_ClienteActualizar,bl_NotificacionMPD,cd_NumeroPoliza
	,cd_AnexoPoliza,am_ValorPoliza,cd_FormaPagoTAO,cd_TarjetaCreditoTAO,cd_NumeroTarjetaTAO,cd_VencimientoTarjetaTAO,cd_NumeroPolizaTAO,cd_AnexoPolizaTAO,am_PorDesFormaPagoTA,cd_Penalidad,am_TasaCambio
	,ds_cc_vence,ds_cc_vence2,ds_cc_autorizacion,ds_cc_autorizacion2,ds_cc_voucher,ds_cc_voucher2,ds_AutorizacionTarjetaTAO,ds_VoucherTarjetaTAO,am_fptao,in_cc_cuotas,in_cc_cuotas2,in_cuotasTarjetaTAO,in_NumTktConj,cd_TipoTarifaTAO
	,cd_TipoTiquete,PCC,PCC_Emite,bl_ahorro,in_CantidadTarifaTAO,in_CantidadSegmentoTAO,cd_tourcode,ds_contrato,cd_tourcode2,cd_Ahorro
	,cd_consecutivo,cd_auxiliar
	,cd_tipoventa, cd_licitacion, ds_evento, ds_campolibre1, ds_campolibre2, cd_facturador,cd_especialista ,cd_tipoformapagoproveedor, cd_medioreservacion, ds_indice, cd_tipoproveedor, ds_tipoproveedor, ds_descripcion, am_iva2, reservaxml) --rgelis 2020/03/24 correcion por interfaz con juniper
	Select
		 OpBookingGDS			= R.BookingGds.value('OpBookingGDS[1]','VARCHAR(15)')
		,ds_tipoitem				= R.BookingGds.value('ds_tipoitem[1]','VARCHAR(15)')
		,cd_sucursal			= R.BookingGds.value('cd_sucursal[1]','CHAR(5)')
		,cd_implante			= R.BookingGds.value('cd_implante[1]','CHAR(5)')
		,bl_externo				= 0--R.BookingGds.value('bl_externo[1]','BIT')
		,id_reserva				= NULL
		,iden_gds				= @iden_gds -- (WEB SERVICE)
		,cd_codigo				= R.BookingGds.value('cd_codigo[1]','CHAR(12)')
		,ds_fecha				= R.BookingGds.value('ds_fecha[1]','CHAR(8)')
		,cd_tiqueteador			= R.BookingGds.value('cd_tiqueteador[1]','CHAR(6)')
		,cd_vendedor			= R.BookingGds.value('cd_vendedor[1]','CHAR(3)')
		,cd_cliente				= R.BookingGds.value('cd_cliente[1]','VARCHAR(25)')
		,reserva				= @XML --R.BookingGds.value('reserva[1]','VARCHAR(MAX)')
		,cd_TipoTransaccion		= ISNULL(R.BookingGds.value('cd_TipoTransaccion[1]','CHAR(1)'),'1')
		,ds_pax_number			= R.BookingGds.value('ds_pax_number[1]','INT')
		,ds_pax_firstnm			= R.BookingGds.value('ds_pax_firstnm[1]','VARCHAR(30)')
		,ds_pax_lastnm			= R.BookingGds.value('ds_pax_lastnm[1]','VARCHAR(30)')
		,ds_pax_prefix			= R.BookingGds.value('ds_pax_prefix[1]','CHAR(3)')
		,cd_pax_cedula			= R.BookingGds.value('cd_pax_cedula[1]','CHAR(15)')
		,ds_pax_telefono		= R.BookingGds.value('ds_pax_telefono[1]','CHAR(15)')
		,ds_tkt_number			= R.BookingGds.value('ds_tkt_number[1]','CHAR(10)')
		,ds_tkt_prefix			= R.BookingGds.value('ds_tkt_prefix[1]','CHAR(3)')
		,ds_aero_code			= R.BookingGds.value('ds_aero_code[1]','CHAR(3)')
		,ds_moneda				= R.BookingGds.value('ds_moneda[1]','CHAR(3)')
		,am_tarifa				= R.BookingGds.value('am_tarifa[1]','NUMERIC(18,2)')
		,am_iva					= R.BookingGds.value('am_iva[1]','NUMERIC(18,2)')
		,am_tua					= R.BookingGds.value('am_tua[1]','NUMERIC(18,2)')
		,am_vat					= R.BookingGds.value('am_vat[1]','NUMERIC(18,2)')
		,ds_cc_code				= R.BookingGds.value('ds_cc_code[1]','CHAR(2)')
		,ds_cc_number			= R.BookingGds.value('ds_cc_number[1]','CHAR(16)')
		,am_highfare			= R.BookingGds.value('am_highfare[1]','MONEY')
		,am_lowfare				= R.BookingGds.value('am_lowfare[1]','MONEY')
		,am_fare				= R.BookingGds.value('am_fare[1]','MONEY')
		,ds_reasoncode			= R.BookingGds.value('ds_reasoncode[1]','CHAR(2)')
		,ds_cliname				= R.BookingGds.value('ds_cliname[1]','VARCHAR(50)')
		,ds_clidir				= R.BookingGds.value('ds_clidir[1]','VARCHAR(50)')
		,ds_clicity				= R.BookingGds.value('ds_clicity[1]','VARCHAR(50)')
		,ds_cliid				= R.BookingGds.value('cd_cliente[1]','VARCHAR(25)')
		,ds_clirazoncial		= R.BookingGds.value('ds_clirazoncial[1]','VARCHAR(250)')
		,ds_cliname2			= R.BookingGds.value('ds_cliname2[1]','VARCHAR(60)')
		,ds_clilastname			= R.BookingGds.value('ds_clilastname[1]','VARCHAR(60)')
		,ds_clilastname2		= R.BookingGds.value('ds_clilastname2[1]','VARCHAR(60)')
		,ds_clitel				= R.BookingGds.value('ds_clitel[1]','VARCHAR(25)')
		,cd_clipais				= R.BookingGds.value('cd_clipais[1]','VARCHAR(25)')
		,cd_clitipodoc			= R.BookingGds.value('cd_clitipodoc[1]','VARCHAR(100)')
		,cd_clitipotercero		= R.BookingGds.value('cd_clitipotercero[1]','CHAR(1)')
		,cd_CentroCostoCliente	= R.BookingGds.value('cd_CentroCostoCliente[1]','VARCHAR(50)')
		,am_comb				= R.BookingGds.value('am_comb[1]','MONEY')
		,am_tao					= R.BookingGds.value('am_tao[1]','MONEY')
		,am_ivatao				= R.BookingGds.value('am_ivatao[1]','MONEY')
		,am_cap					= R.BookingGds.value('am_cap[1]','MONEY')
		,am_ivacap				= R.BookingGds.value('am_ivacap[1]','MONEY')
		,ds_cc_code2			= R.BookingGds.value('ds_cc_code2[1]','CHAR(2)')
		,ds_cc_number2			= R.BookingGds.value('ds_cc_number2[1]','VARCHAR(16)')
		,am_fp1					= R.BookingGds.value('am_fp1[1]','MONEY')
		,am_fp2					= R.BookingGds.value('am_fp2[1]','MONEY')
		,dt_entrega				= NULL --R.BookingGds.value('dt_entrega[1]','CHAR(17)')
		,in_cars				= NULL --R.BookingGds.value('in_cars[1]','TINYINT')
		,cd_carcode				= NULL --R.BookingGds.value('cd_carcode[1]','CHAR(2)')
		,cd_confirmation		= NULL --R.BookingGds.value('cd_confirmation[1]','VARCHAR(16)')
		,cd_citysalida			= NULL --R.BookingGds.value('cd_citysalida[1]','CHAR(3)')
		,dt_retorno				= NULL --R.BookingGds.value('dt_retorno[1]','CHAR(17)')
		,cd_cartype				= NULL --R.BookingGds.value('cd_cartype[1]','VARCHAR(20)')
		,cd_currency			= NULL --R.BookingGds.value('cd_currency[1]','CHAR(3)')
		,cd_bookingsource		= NULL --R.BookingGds.value('cd_bookingsource[1]','VARCHAR(20)')
		,cd_ratecode			= NULL --R.BookingGds.value('cd_ratecode[1]','VARCHAR(10)')
		,am_tarifarenta			= NULL --R.BookingGds.value('am_tarifarenta[1]','MONEY')
		,dt_checkin				= R.BookingGds.value('dt_checkin[1]','CHAR(8)')
		,in_guests				= R.BookingGds.value('in_guests[1]','INT')
		,cd_city				= R.BookingGds.value('cd_city[1]','CHAR(3)')
		,cd_htlchain			= R.BookingGds.value('cd_htlchain[1]','CHAR(2)')
		,dt_checkout			= R.BookingGds.value('dt_checkout[1]','CHAR(8)')
		,ds_htlname				= R.BookingGds.value('ds_htlname[1]','VARCHAR(32)')
		,in_habs				= R.BookingGds.value('in_habs[1]','INT')
		,cd_bed					= R.BookingGds.value('cd_bed[1]','CHAR(3)')
		,cd_htlcur				= R.BookingGds.value('cd_htlcur[1]','CHAR(3)')
		,am_htltarifa			= R.BookingGds.value('am_htltarifa[1]','MONEY')
		,cd_agcur				= R.BookingGds.value('cd_agcur[1]','CHAR(3)')
		,am_agtarifa			= R.BookingGds.value('am_agtarifa[1]','MONEY')
		,ds_dir1				= R.BookingGds.value('ds_dirhtl[1]','VARCHAR(50)')
		,ds_tel					= R.BookingGds.value('ds_tel[1]','VARCHAR(12)')
		,ds_fax					= R.BookingGds.value('ds_fax[1]','VARCHAR(12)')
		,cd_conceptofacturacion	= R.BookingGds.value('cd_conceptofacturacion[1]','CHAR(3)')
		,cd_TipoServicio		= R.BookingGds.value('cd_TipoServicio[1]','CHAR(3)')
		,cd_Proveedores			= R.BookingGds.value('cd_Proveedores[1]','VARCHAR(25)')
		,ds_Descrip				= R.BookingGds.value('ds_Descrip[1]','varCHAR(500)')
		,cd_tktrevisado			= R.BookingGds.value('cd_tktrevisado[1]','CHAR(14)')
		,ds_itinerario			= R.BookingGds.value('ds_itinerario[1]','VARCHAR(64)')
		,ds_clases				= R.BookingGds.value('ds_clases[1]','VARCHAR(36)')
		,in_nacionalidad		= R.BookingGds.value('in_nacionalidad[1]','TINYINT')
		,am_TarifaContado		= R.BookingGds.value('am_TarifaContado[1]','MONEY')
		,am_IvaContado			= R.BookingGds.value('am_IvaContado[1]','MONEY')
		,am_OtrosContado		= R.BookingGds.value('am_OtrosContado[1]','MONEY')
		,am_TarifaCredito		= R.BookingGds.value('am_TarifaCredito[1]','MONEY')
		,am_IvaCredito			= R.BookingGds.value('am_IvaCredito[1]','MONEY')
		,am_OtrosCredito		= R.BookingGds.value('am_OtrosCredito[1]','MONEY')
		,am_Comision			= R.BookingGds.value('am_Comision[1]','MONEY')
		,ds_Observaciones		= R.BookingGds.value('ds_Observaciones[1]','VARCHAR(8000)')
		,ds_ClienteEmail		= R.BookingGds.value('ds_ClienteEmail[1]','VARCHAR(100)')
		,bl_ClienteActualizar	= R.BookingGds.value('bl_ClienteActualizar[1]','BIT')
		,bl_NotificacionMPD		= 0 --NO aplica --R.BookingGds.value('bl_NotificacionMPD[1]','BIT')
		,cd_NumeroPoliza		= R.BookingGds.value('cd_NumeroPoliza[1]','VARCHAR(50)')
		,cd_AnexoPoliza			= R.BookingGds.value('cd_AnexoPoliza[1]','VARCHAR(50)')
		,am_ValorPoliza			= R.BookingGds.value('am_ValorPoliza[1]','MONEY')
		,cd_FormaPagoTAO		= R.BookingGds.value('cd_FormaPagoTAO[1]','CHAR(3)')
		,cd_TarjetaCreditoTAO	= R.BookingGds.value('cd_TarjetaCreditoTAO[1]','CHAR(2)')
		,cd_NumeroTarjetaTAO	= R.BookingGds.value('cd_NumeroTarjetaTAO[1]','CHAR(16)')
		,cd_VencimientoTarjetaTA= NULL--R.BookingGds.value('cd_VencimientoTarjetaTAO[1]','CHAR(5)')
		,cd_NumeroPolizaTAO		= R.BookingGds.value('cd_NumeroPolizaTAO[1]','VARCHAR(50)')
		,cd_AnexoPolizaTAO		= R.BookingGds.value('cd_AnexoPolizaTAO[1]','VARCHAR(50)')
		,am_PorDesFormaPagoTA	= R.BookingGds.value('am_PorDesFormaPagoTA[1]','NUMERIC(8,4)')
		,cd_Penalidad			= R.BookingGds.value('cd_Penalidad[1]','CHAR(14)')
		,am_TasaCambio			= R.BookingGds.value('am_TasaCambio[1]','MONEY')
		,ds_cc_vence			= NULL--R.BookingGds.value('ds_cc_vence[1]','CHAR(5)')
		,ds_cc_vence2			= NULL--R.BookingGds.value('ds_cc_vence2[1]','CHAR(5)')
		,ds_cc_autorizacion		= R.BookingGds.value('ds_cc_autorizacion[1]','VARCHAR(25)')
		,ds_cc_autorizacion2	= R.BookingGds.value('ds_cc_autorizacion2[1]','VARCHAR(25)')
		,ds_cc_voucher			= R.BookingGds.value('ds_cc_voucher[1]','VARCHAR(10)')
		,ds_cc_voucher2			= R.BookingGds.value('ds_cc_voucher2[1]','VARCHAR(10)')
		,ds_AutorizacionTarjetaT= R.BookingGds.value('ds_AutorizacionTarjetaTAO[1]','VARCHAR(25)')
		,ds_VoucherTarjetaTAO	= R.BookingGds.value('ds_VoucherTarjetaTAO[1]','VARCHAR(10)')
		,am_fptao				= R.BookingGds.value('am_fptao[1]','MONEY')
		,in_cc_cuotas			= R.BookingGds.value('in_cc_cuotas[1]','INT')
		,in_cc_cuotas2			= R.BookingGds.value('in_cc_cuotas2[1]','INT')
		,in_cuotasTarjetaTAO	= R.BookingGds.value('in_cuotasTarjetaTAO[1]','INT')
		,in_NumTktConj			= R.BookingGds.value('in_NumTktConj[1]','INT')
		,cd_TipoTarifaTAO		= NULL --R.BookingGds.value('cd_TipoTarifaTAO[1]','VARCHAR(25)')
		,cd_TipoTiquete			= R.BookingGds.value('cd_TipoTiquete[1]','CHAR(3)')
		,PCC					= NULL --R.BookingGds.value('PCC[1]','VARCHAR(5)')
		,PCC_Emite				= NULL --R.BookingGds.value('PCC_Emite[1]','VARCHAR(5)')
		,bl_ahorro				= R.BookingGds.value('bl_ahorro[1]','BIT')
		,in_CantidadTarifaTAO	= R.BookingGds.value('in_CantidadTarifaTAO[1]','INT')
		,in_CantidadSegmentoTAO	= 0--R.BookingGds.value('in_CantidadSegmentoTAO[1]','INT')
		,cd_tourcode			= R.BookingGds.value('cd_tourcode[1]','VARCHAR(25)')
		,ds_contrato			= R.BookingGds.value('ds_contrato[1]','VARCHAR(25)')
		,cd_tourcode2			= R.BookingGds.value('cd_tourcode2[1]','VARCHAR(25)')
		,cd_Ahorro				= R.BookingGds.value('cd_Ahorro[1]','VARCHAR(25)')
		,cd_consecutivo			= R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
		,cd_auxiliar			= R.BookingGds.value('cd_aux[1]','VARCHAR(16)')
		,cd_tipoventa				= R.BookingGds.value('cd_tipoventa[1]','VARCHAR(16)')			
		,cd_licitacion				= R.BookingGds.value('cd_licitacion[1]','VARCHAR(25)')			
		,ds_evento					= R.BookingGds.value('ds_evento[1]','VARCHAR(250)')				
		,ds_campolibre1				= R.BookingGds.value('ds_campolibre1[1]','VARCHAR(500)')		
		,ds_campolibre2				= R.BookingGds.value('ds_campolibre2[1]','VARCHAR(500)')		
		,cd_facturador				= R.BookingGds.value('cd_facturador[1]','VARCHAR(3)')			
		,cd_especialista			= R.BookingGds.value('cd_especialista[1]','VARCHAR(25)')		
		,cd_tipoformapagoproveedor	= R.BookingGds.value('cd_tipoformapagoproveedor[1]','VARCHAR(25)')
		,cd_medioreservacion 		= R.BookingGds.value('cd_medioreservacion[1]','VARCHAR(25)')
		,ds_indice					= R.BookingGds.value('ds_indice[1]','VARCHAR(5)')
		,cd_tipoproveedor			= R.BookingGds.value('cd_tipoproveedor[1]','VARCHAR(3)')
		,ds_tipoproveedor			= R.BookingGds.value('ds_tipoproveedor[1]','VARCHAR(60)') 
		,ds_descripcion				= R.BookingGds.value('ds_descripcion[1]','VARCHAR(500)')
		,am_iva2					= R.BookingGds.value('am_iva2[1]','MONEY')
		,reservaxml					= R.BookingGds.value('reservaxml[1]','VARCHAR(MAX)')
	FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	
	

	--Insert Into @ReservaGDS_Pasajeros (in_orden,cd_reserva, cd_consecutivo, ds_pax_firstnm, ds_pax_lastnm, ds_pax_prefix, cd_pax_cedula, ds_pax_telefono)
	--Select
	--	 in_orden				= ROW_NUMBER() OVER(PARTITION BY R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)') ORDER BY R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)') ASC)
	--	,cd_codigo				= R.BookingGds.value('../../cd_codigo[1]','CHAR(6)')
	--	,cd_consecutivo			= R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)')
	--	,ds_pax_firstnm			= R.BookingGds.value('ds_pax_firstnm[1]','VARCHAR(30)')
	--	,ds_pax_lastnm			= R.BookingGds.value('ds_pax_lastnm[1]','VARCHAR(30)')
	--	,ds_pax_prefix			= R.BookingGds.value('ds_pax_prefix[1]','CHAR(3)')
	--	,cd_pax_cedula			= R.BookingGds.value('cd_pax_cedula[1]','CHAR(15)')
	--	,ds_pax_telefono		= R.BookingGds.value('ds_pax_telefono[1]','CHAR(15)')
	--FROM @NodoXML.nodes('//Booking/reserva/pasajeros/pasajero') As R(BookingGDS)

	Insert Into @ReservaGDS_Pasajeros (in_orden,cd_reserva, cd_consecutivo, ds_pax_firstnm, ds_pax_lastnm, ds_pax_prefix, cd_pax_cedula, ds_pax_telefono)
	Select
		 in_orden				= ROW_NUMBER() OVER(PARTITION BY cd_consecutivo ORDER BY cd_consecutivo ASC)
		,cd_codigo				= cd_codigo
		,cd_consecutivo			= cd_consecutivo
		,ds_pax_firstnm			= p.Pasajero.value('ds_pax_firstnm[1]','VARCHAR(30)')
		,ds_pax_lastnm			= p.Pasajero.value('ds_pax_lastnm[1]','VARCHAR(30)')
		,ds_pax_prefix			= p.Pasajero.value('ds_pax_prefix[1]','CHAR(3)')
		,cd_pax_cedula			= p.Pasajero.value('cd_pax_cedula[1]','CHAR(15)')
		,ds_pax_telefono		= p.Pasajero.value('ds_pax_telefono[1]','CHAR(15)')
	FROM(
		SELECT
			 cd_codigo		= R.BookingGds.value('cd_codigo[1]','CHAR(12)')
			,cd_consecutivo	= R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
			,Pax			= R.BookingGds.query('./pasajeros/pasajero') 
		FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	) AS reserva
	CROSS APPLY reserva.Pax.nodes('pasajero') P(Pasajero)
	
	Update R SET
		r.ds_pax_firstnm	   = rtrim(rp.ds_pax_firstnm)	
		,r.ds_pax_lastnm	   = rp.ds_pax_lastnm	
		,r.ds_pax_prefix	   = rp.ds_pax_prefix	
		,r.cd_pax_cedula	   = rp.cd_pax_cedula	
		,r.ds_pax_telefono     = rp.ds_pax_telefono
	From @Booking R
	Inner Join @ReservaGDS_Pasajeros RP ON rp.cd_reserva = r.cd_codigo and rp.cd_consecutivo = r.cd_consecutivo --AND rp.in_orden=1
		

	--Insert Into @ReservaGDS_VariablesAdicionales (in_orden,cd_reserva, cd_consecutivo, ds_nombre, ds_valor)
	--Select
	--	 in_orden		= ROW_NUMBER() OVER(PARTITION BY R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)') ORDER BY R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)') ASC)
	--	,cd_codigo		= R.BookingGds.value('../../cd_codigo[1]','CHAR(6)')
	--	,cd_consecutivo	= R.BookingGds.value('../../cd_consecutivo[1]','VARCHAR(25)')
	--	,ds_nombre		= R.BookingGds.value('nombre[1]','VARCHAR(20)')
	--	,ds_valor		= R.BookingGds.value('valor[1]','VARCHAR(8000)')
	--FROM @NodoXML.nodes('//Booking/reserva/variables/variable') As R(BookingGDS) 
	----select * from @ReservaGDS_VariablesAdicionales

	Insert Into @ReservaGDS_VariablesAdicionales (in_orden,cd_reserva, cd_consecutivo, ds_nombre, ds_valor)
	SELECT in_orden			= ROW_NUMBER() OVER(PARTITION BY cd_consecutivo ORDER BY cd_consecutivo ASC)
		  ,cd_codigo		= cd_codigo
		  ,cd_consecutivo	= cd_consecutivo
		  ,ds_nombre		= V.Variable.value('nombre[1]','VARCHAR(20)')
		  ,ds_valor			= V.Variable.value('valor[1]','VARCHAR(8000)')
	FROM(
		Select
			 cd_codigo		= R.BookingGds.value('cd_codigo[1]','CHAR(12)')
			,cd_consecutivo	= R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
			,Variable		= R.BookingGds.query('./Variables/Variable')
		FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	) AS reserva
	CROSS APPLY reserva.Variable.nodes('Variable') V(Variable)
	
	Insert Into @ReservaGDS_CargosImpuestos (in_orden,cd_reserva,cd_consecutivo,cd_codigo,ds_nombre,cd_tipo,cd_codigopadre,cd_tipopadre,am_porcentaje,am_contado,am_credito,am_valor)
	SELECT in_orden			= C.CargosImpuestos.value('orden[1]','INT')
		  ,cd_reserva		= cd_reserva
		  ,cd_consecutivo	= cd_consecutivo
		  ,cd_codigo		= C.CargosImpuestos.value('cd_codigo[1]','VARCHAR(3)')
		  ,ds_nombre		= C.CargosImpuestos.value('ds_nombre[1]','VARCHAR(20)')
		  ,cd_tipo			= C.CargosImpuestos.value('cd_tipo[1]','VARCHAR(1)')
		  ,cd_codigopadre	= C.CargosImpuestos.value('cd_codigopadre[1]','VARCHAR(3)')
		  ,cd_tipopadre		= C.CargosImpuestos.value('cd_tipopadre[1]','VARCHAR(1)')
		  ,am_porcentaje	= C.CargosImpuestos.value('am_porcentaje[1]','MONEY')
		  ,am_contado		= C.CargosImpuestos.value('am_contado[1]','MONEY')
		  ,am_credito		= C.CargosImpuestos.value('am_credito[1]','MONEY')
		  ,am_valor			= C.CargosImpuestos.value('am_valor[1]','MONEY')
	FROM(
		Select
			 cd_reserva		 = R.BookingGds.value('cd_codigo[1]','CHAR(12)')
			,cd_consecutivo	 = R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
			,CargosImpuestos = R.BookingGds.query('./CargosImpuestos/CargoImpuesto')
		FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	) AS reserva
	CROSS APPLY reserva.CargosImpuestos.nodes('CargoImpuesto') C(CargosImpuestos)

	Insert Into @ReservaGDS_FormasPagos (in_orden,cd_reserva,cd_consecutivo,cd_codigo,ds_nombre,cd_tipotarjeta,ds_numerotarjeta,ds_vouchertarjeta,ds_expiraciontarjeta,ds_autorizaciontarjeta,in_coutas,cd_banco,ds_cheque,ds_plaza,ds_referencia,ds_Poliza,ds_PolizaAnexo,am_valor)
	SELECT in_orden					= F.FormasPagos.value('orden[1]','INT')
		  ,cd_reserva				= cd_reserva
		  ,cd_consecutivo			= cd_consecutivo
		  ,cd_codigo				= F.FormasPagos.value('cd_codigo[1]','VARCHAR(50)')
		  ,ds_nombre				= F.FormasPagos.value('cd_nombre[1]','VARCHAR(50)')
		  ,cd_tipotarjeta			= F.FormasPagos.value('cd_tipotarjeta[1]','VARCHAR(2)')
		  ,ds_numerotarjeta			= F.FormasPagos.value('ds_numerotarjeta[1]','VARCHAR(16)')
		  ,ds_vouchertarjeta		= F.FormasPagos.value('ds_vouchertarjeta[1]','VARCHAR(25)')
		  ,ds_expiraciontarjeta		= F.FormasPagos.value('ds_expiraciontarjeta[1]','VARCHAR(5)')
		  ,ds_autorizaciontarjeta	= F.FormasPagos.value('ds_autorizaciontarjeta[1]','VARCHAR(25)')
		  ,in_coutas				= F.FormasPagos.value('in_cuotas[1]','INT')
		  ,cd_banco					= F.FormasPagos.value('cd_banco[1]','VARCHAR(25)') 
		  ,ds_cheque				= F.FormasPagos.value('cd_cheque[1]','VARCHAR(25)') 
		  ,ds_plaza					= F.FormasPagos.value('ds_plaza[1]','VARCHAR(25)') 
		  ,ds_referencia			= F.FormasPagos.value('ds_referencia[1]','VARCHAR(25)') 
		  ,ds_Poliza				= F.FormasPagos.value('ds_poliza[1]','VARCHAR(25)') 
		  ,ds_PolizaAnexo			= F.FormasPagos.value('ds_polizaanexo[1]','VARCHAR(25)') 
		  ,am_valor					= F.FormasPagos.value('am_valor[1]','MONEY')
	FROM(
		Select
			 cd_reserva		 = R.BookingGds.value('cd_codigo[1]','CHAR(12)')
			,cd_consecutivo	 = R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
			,FormasPagos = R.BookingGds.query('./FormasPagos/FormaPago')
		FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	) AS reserva
	CROSS APPLY reserva.FormasPagos.nodes('FormaPago') F(FormasPagos)
	
	Insert Into @ReservaGDS_FEE (in_orden,cd_reserva, cd_consecutivo, cd_conceptofac, cd_subcodigo, am_valor, ds_servicio)
	Select
		 in_orden				= ROW_NUMBER() OVER(PARTITION BY cd_consecutivo ORDER BY cd_consecutivo ASC)
		,cd_codigo				= cd_codigo
		,cd_consecutivo			= cd_consecutivo
		,ds_pax_firstnm			= f.fee.value('cd_conceptofac[1]','VARCHAR(5)')
		,ds_pax_lastnm			= f.fee.value('cd_subcodigo[1]','VARCHAR(5)')
		,ds_pax_prefix			= f.fee.value('am_valor[1]','MONEY')
		,cd_pax_cedula			= f.fee.value('ds_servicio[1]','VARCHAR(8000)')
	FROM(
		SELECT
			 cd_codigo		= R.BookingGds.value('cd_codigo[1]','CHAR(12)')
			,cd_consecutivo	= R.BookingGds.value('cd_consecutivo[1]','VARCHAR(25)')
			,Pax			= R.BookingGds.query('./pasajeros/pasajero/fees/fee') 
		FROM @NodoXML.nodes('//Booking/reserva') As R(BookingGDS)
	) AS reserva
	CROSS APPLY reserva.Pax.nodes('fee') f(fee)
	
	UPDATE @Booking
	SET  am_TarifaContado	= CASE WHEN ISNULL(am_TarifaContado,0)=0	AND ISNULL(ds_cc_code,'')=''	THEN am_Tarifa	ELSE am_TarifaContado	END
		,am_IvaContado		= CASE WHEN ISNULL(am_IvaContado,0)=0		AND ISNULL(ds_cc_code,'')=''	THEN am_Iva		ELSE am_IvaContado		END
		,am_OtrosContado	= CASE WHEN ISNULL(am_OtrosContado,0)=0		AND ISNULL(ds_cc_code,'')=''	THEN am_vat		ELSE am_OtrosContado	END
		,am_TarifaCredito	= CASE WHEN ISNULL(am_TarifaCredito,0)=0	AND ISNULL(ds_cc_code,'')<>''	THEN am_Tarifa	ELSE am_TarifaCredito	END
		,am_IvaCredito		= CASE WHEN ISNULL(am_IvaCredito,0)=0		AND ISNULL(ds_cc_code,'')<>''	THEN am_Iva		ELSE am_IvaCredito		END
		,am_OtrosCredito	= CASE WHEN ISNULL(am_OtrosCredito,0)=0		AND ISNULL(ds_cc_code,'')<>''	THEN am_vat		ELSE am_OtrosCredito	END

	/*** SE INICIA EL LLAMADO AL SP DEL MAESTRO RECURSIVO PARA TODOS LOS REGISTROS GENERADOS ***/
	SET @TotalRegistros = ISNULL ( (SELECT COUNT(1) FROM @Booking) , 0 )
	SET @RegistroActual = 1
	SET @OpBookingGDS = ISNULL ( (SELECT TOP 1 OpBookingGDS FROM @Booking) , '-')
	SET @TotalRegistrosPaxAdicional = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_Pasajeros),0)
	/*** VALIDACIONES ***/
	IF @TotalRegistros = 0
	BEGIN
		RAISERROR ( 'No existen Booking para procesar.' , 16 , 1)
		RETURN 1
	END

	IF NOT @OpBookingGDS IN ('Crear','Actualizar','Consultar')
	BEGIN
		RAISERROR ( 'La operación ingresada no es válida: %s' , 16 , 1, @OpBookingGDS)
		RETURN 1
	END

	--reserva
	IF NOT EXISTS (SELECT * FROM @Booking where isnull(cd_codigo,'') <> '' )
	BEGIN
		Select Top 1 @TextoRaiserror = 'Debe ingresar un codigo de reserva'
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END
	/*Campos nuevos de cabecera*/
	--Tipo de venta
	IF NOT EXISTS (Select * from TipoVenta WHERE cd_codigo IN (SELECT cd_tipoventa FROM @Booking))
		AND EXISTS (Select * From @Booking Where cd_tipoventa<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El tipo de venta ' + cd_tipoventa + ' no existe en el sistema'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END
	
	--Licitaciones
	IF NOT EXISTS (Select * from Licitaciones 
					WHERE cd_codigo IN (SELECT cd_licitacion FROM @Booking) 
					and bl_inactiva=0)
		AND EXISTS (Select * From @Booking Where cd_licitacion<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'La licitación ' + cd_licitacion + ' no existe en el sistema o se encuentra deshabilitada'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Licitaciones por contrato.
	IF NOT EXISTS (Select * from Licitaciones WHERE cd_contrato IN (SELECT ds_contrato FROM @Booking))
		AND EXISTS (Select * From @Booking Where ds_contrato<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El numero de contrato ' + ds_contrato + ' no esta asociado a una licitación'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Eventos
	IF NOT EXISTS (Select * from Eventos 
					WHERE cd_codigo IN (SELECT ds_evento FROM @Booking) 
					and bl_inactivo=0)
		AND EXISTS (Select * From @Booking Where ds_evento<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El evento ' + ds_evento + ' no existe en el sistema o se encuentra deshabilitado'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Facturador
	IF NOT EXISTS (Select * from Tiqueteadores 
					WHERE cd_codigo IN (SELECT cd_facturador FROM @Booking) 
					and bl_inactivo=0)
		AND EXISTS (Select * From @Booking Where cd_facturador<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El facturador ' + cd_facturador + ' no existe en el sistema o se encuentra deshabilitado'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Especialista
	IF NOT EXISTS (Select * from Especialista 
					WHERE cd_codigo IN (SELECT cd_especialista FROM @Booking) 
					and bl_inactivo=0)
		AND EXISTS (Select * From @Booking Where cd_especialista<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El especialista ' + cd_especialista + ' no existe en el sistema o se encuentra deshabilitado'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Tipo forma pago proveedor
	IF NOT EXISTS (Select * from TipoFormaPagoProveedor 
					WHERE cd_codigo IN (SELECT cd_tipoformapagoproveedor FROM @Booking) 
					and bl_inactivo=0)
		AND EXISTS (Select * From @Booking Where cd_tipoformapagoproveedor<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El tipo de forma de pago de proveedor ' + cd_tipoformapagoproveedor + ' no existe en el sistema o se encuentra deshabilitada'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Medio de reservacion
	IF NOT EXISTS (Select * from MedioReservacion 
					WHERE cd_codigo IN (SELECT cd_medioreservacion FROM @Booking) 
					and bl_inactivo=0)
		AND EXISTS (Select * From @Booking Where cd_medioreservacion<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El medio de reservación ' + cd_medioreservacion + ' no existe en el sistema o se encuentra deshabilitado'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	/**/
	--Proveedores
	IF EXISTS (
						Select p.* 
						from @Booking r
						left join Proveedores p on r.cd_Proveedores = p.IDPROVE
						where p.IDPROVE is null)

						--WHERE IDPROVE IN (SELECT cd_Proveedores FROM @Booking))
		AND EXISTS (SElect * From @Booking Where cd_proveedores<>'')
	BEGIN
		--print 'proveedores validacion'
		Select Top 1 @TextoRaiserror = 'El proveedor ' + cd_Proveedores + ' no existe en el sistema'
		from @Booking r
		left join Proveedores p on r.cd_Proveedores = p.IDPROVE
		where p.IDPROVE is null
			--From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END

	--Tipo Servicio
	IF NOT EXISTS (Select * from dbo.TiposServicios WHERE cd_codigo IN (SELECT cd_TipoServicio FROM @Booking))
	AND EXISTS (SElect * From @Booking Where cd_TipoServicio<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'El Tipo Servicio ' + cd_TipoServicio + ' no existe en el sistema'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END
		
	--Moneda
	IF NOT EXISTS (Select * from Monedas_IATA WHERE cd_codigo IN (SELECT ds_moneda FROM @Booking))
		AND EXISTS (SELECT * From @Booking Where ds_moneda<>'')
	BEGIN
		Select Top 1 @TextoRaiserror = 'La Moneda ' + ds_moneda + ' no existe en el sistema'
		From @Booking
		RAISERROR (@TextoRaiserror , 16 , 1)
		RETURN 1
	END
		
	-- print '03'
	--Select * From @Booking
	--Select * from @ReservaGDS_Itinerarios
	--Select * from @ReservaGDS_VariablesAdicionales
	/*** LLAMADO RECURSIVO ***/
	BEGIN TRY
		IF @OpBookingGDS IN ('Crear','Actualizar','Eliminar')
		BEGIN
		
			BEGIN TRANSACTION

				WHILE ( @RegistroActual <= @TotalRegistros )
				BEGIN
					--Obtenemos toda la informacion del XML
					Select
						@OpBookingGDS  			  = OpBookingGDS
						,@ds_tipoitem				  = ds_tipoitem
						,@cd_sucursal				  = cd_sucursal			
						,@cd_implante				  = cd_implante			
						,@bl_externo				  = bl_externo			
						,@id_reserva				  = id_reserva			
						,@iden_gds					  = iden_gds				
						,@cd_codigo					  = cd_codigo				
						,@ds_fecha					  = ds_fecha				
						,@cd_tiqueteador			  = cd_tiqueteador		
						,@cd_vendedor				  = cd_vendedor			
						,@cd_cliente				  = cd_cliente			
						,@reserva					  = reserva				
						,@cd_TipoTransaccion		  = cd_TipoTransaccion	
						,@ds_pax_number				  = ds_pax_number			
						,@ds_pax_firstnm			  = ds_pax_firstnm		
						,@ds_pax_lastnm				  = ds_pax_lastnm			
						,@ds_pax_prefix				  = ds_pax_prefix			
						,@cd_pax_cedula				  = cd_pax_cedula			
						,@ds_pax_telefono			  = ds_pax_telefono		
						,@ds_tkt_number				  = ds_tkt_number			
						,@ds_tkt_prefix				  = ds_tkt_prefix			
						,@ds_aero_code				  = ds_aero_code			
						,@ds_moneda					  = ds_moneda				
						,@am_tarifa					  = am_tarifa				
						,@am_iva					  = am_iva				
						,@am_tua					  = am_tua				
						,@am_vat					  = am_vat				
						,@ds_cc_code				  = ds_cc_code			
						,@ds_cc_number				  = ds_cc_number			
						,@am_highfare				  = ISNULL(am_highfare,0)			
						,@am_lowfare				  = ISNULL(am_lowfare,0)
						,@am_fare					  = ISNULL(am_fare,0)				
						,@ds_reasoncode				  = ds_reasoncode			
						,@ds_cliname				  = ds_cliname			
						,@ds_clidir					  = ds_clidir				
						,@ds_clicity				  = ds_clicity			
						,@ds_cliid					  = ds_cliid				
						,@ds_clirazoncial			  = ds_clirazoncial		
						,@ds_cliname2				  = ds_cliname2			
						,@ds_clilastname			  = ds_clilastname		
						,@ds_clilastname2			  = ds_clilastname2		
						,@ds_clitel					  = ds_clitel				
						,@cd_clipais				  = cd_clipais			
						,@cd_clitipodoc				  = cd_clitipodoc			
						,@cd_clitipotercero			  = cd_clitipotercero		
						,@cd_CentroCostoCliente		  = cd_CentroCostoCliente	
						,@am_comb					  = am_comb				
						,@am_tao					  = am_tao				
						,@am_ivatao					  = am_ivatao				
						,@am_cap					  = am_cap				
						,@am_ivacap					  = am_ivacap				
						,@ds_cc_code2				  = ds_cc_code2			
						,@ds_cc_number2				  = ds_cc_number2			
						,@am_fp1					  = am_fp1				
						,@am_fp2					  = am_fp2				
						,@dt_entrega				  = dt_entrega			
						,@in_cars					  = in_cars				
						,@cd_carcode				  = cd_carcode			
						,@cd_confirmation			  = cd_confirmation		
						,@cd_citysalida				  = cd_citysalida			
						,@dt_retorno				  = dt_retorno			
						,@cd_cartype				  = cd_cartype			
						,@cd_currency				  = cd_currency			
						,@cd_bookingsource			  = cd_bookingsource		
						,@cd_ratecode				  = cd_ratecode			
						,@am_tarifarenta			  = am_tarifarenta		
						,@dt_checkin				  = dt_checkin			
						,@in_guests					  = in_guests				
						,@cd_city					  = cd_city				
						,@cd_htlchain				  = cd_htlchain			
						,@dt_checkout				  = dt_checkout			
						,@ds_htlname				  = ds_htlname			
						,@in_habs					  = in_habs				
						,@cd_bed					  = cd_bed				
						,@cd_htlcur					  = cd_htlcur				
						,@am_htltarifa				  = am_htltarifa			
						,@cd_agcur					  = cd_agcur				
						,@am_agtarifa				  = am_agtarifa			
						,@ds_dir1					  = ds_dir1				
						,@ds_tel					  = ds_tel				
						,@ds_fax					  = ds_fax				
						,@cd_conceptofacturacion	  = cd_conceptofacturacion
						,@cd_TipoServicio			  = cd_TipoServicio		
						,@cd_Proveedores			  = cd_Proveedores		
						,@ds_Descrip				  = ds_Descrip			
						,@cd_tktrevisado			  = cd_tktrevisado		
						,@ds_itinerario				  = ds_itinerario			
						,@ds_clases					  = ds_clases				
						,@in_nacionalidad			  = in_nacionalidad		
						,@am_TarifaContado			  = am_TarifaContado		
						,@am_IvaContado				  = am_IvaContado			
						,@am_OtrosContado			  = am_OtrosContado		
						,@am_TarifaCredito			  = am_TarifaCredito		
						,@am_IvaCredito				  = am_IvaCredito			
						,@am_OtrosCredito			  = am_OtrosCredito		
						,@am_Comision				  = am_Comision			
						,@ds_Observaciones			  = ds_Observaciones		
						,@ds_ClienteEmail			  = ds_ClienteEmail		
						,@bl_ClienteActualizar		  = bl_ClienteActualizar	
						,@bl_NotificacionMPD		  = bl_NotificacionMPD	
						,@cd_NumeroPoliza			  = cd_NumeroPoliza		
						,@cd_AnexoPoliza			  = cd_AnexoPoliza		
						,@am_ValorPoliza			  = am_ValorPoliza		
						,@cd_FormaPagoTAO			  = cd_FormaPagoTAO		
						,@cd_TarjetaCreditoTAO		  = cd_TarjetaCreditoTAO	
						,@cd_NumeroTarjetaTAO		  = cd_NumeroTarjetaTAO	
						,@cd_VencimientoTarjetaTAO	  = cd_VencimientoTarjetaTAO
						,@cd_NumeroPolizaTAO		  = cd_NumeroPolizaTAO	
						,@cd_AnexoPolizaTAO			  = cd_AnexoPolizaTAO		
						,@am_PorDesFormaPagoTA		  = am_PorDesFormaPagoTA	
						,@cd_Penalidad				  = cd_Penalidad			
						,@am_TasaCambio				  = am_TasaCambio			
						,@ds_cc_vence				  = ds_cc_vence			
						,@ds_cc_vence2				  = ds_cc_vence2			
						,@ds_cc_autorizacion		  = ds_cc_autorizacion	
						,@ds_cc_autorizacion2		  = ds_cc_autorizacion2	
						,@ds_cc_voucher				  = ds_cc_voucher			
						,@ds_cc_voucher2			  = ds_cc_voucher2		
						,@ds_AutorizacionTarjetaTAO	  = ds_AutorizacionTarjetaTAO
						,@ds_VoucherTarjetaTAO		  = ds_VoucherTarjetaTAO	
						,@am_fptao					  = am_fptao				
						,@in_cc_cuotas				  = in_cc_cuotas			
						,@in_cc_cuotas2				  = in_cc_cuotas2			
						,@in_cuotasTarjetaTAO		  = in_cuotasTarjetaTAO	
						,@in_NumTktConj				  = in_NumTktConj			
						,@cd_TipoTarifaTAO			  = cd_TipoTarifaTAO		
						,@cd_TipoTiquete			  = cd_TipoTiquete		
						,@PCC						  = PCC					
						,@PCC_Emite					  = PCC_Emite				
						,@bl_ahorro					  = ISNULL(bl_ahorro,0)
						,@in_CantidadTarifaTAO		  = in_CantidadTarifaTAO	
						,@in_CantidadSegmentoTAO	  = in_CantidadSegmentoTAO
						,@cd_tourcode				  = cd_tourcode			
						,@ds_contrato				  = ds_contrato			
						,@cd_tourcode2				  = cd_tourcode2			
						,@cd_Ahorro					  = cd_Ahorro				
						,@cd_auxiliar				  = cd_Auxiliar
						,@cd_consecutivo			  = cd_consecutivo --rgelis 2018/01/22 req.46714 
						--Jramirez 2018/11/23 R74520
						,@cd_tipoventa				  = cd_tipoventa				
						,@cd_licitacion				  = cd_licitacion				
						,@ds_evento					  = ds_evento					
						,@ds_campolibre1			  = ds_campolibre1			
						,@ds_campolibre2			  = ds_campolibre2			
						,@cd_facturador				  = cd_facturador				
						,@cd_especialista			  = cd_especialista			
						,@cd_tipoformapagoproveedor	  = cd_tipoformapagoproveedor	
						,@cd_medioreservacion		  = cd_medioreservacion		
						,@ds_indice					  = ds_indice --rgelis 2020/03/24 correcion por interfaz con juniper
						,@cd_tipoproveedor			  = cd_tipoproveedor 
						,@ds_tipoproveedor			  = ds_tipoproveedor 
						,@ds_descripcion			  = ds_descripcion
						,@am_iva2					  = am_iva2
						,@reservaxml				  = reservaxml
					FROM @Booking
					WHERE Id = @RegistroActual
					-- print '04'
					
					IF @OpBookingGDS = 'Crear'
					Begin
						SET @Error = 1
						EXECUTE @Error =[dbo].[spBookingGDS]
							@Op				  			  = 'Cab'
							,@cd_sucursal				  = @cd_sucursal			
							,@cd_implante				  = @cd_implante			
							,@bl_externo				  = @bl_externo			
							,@id_reserva				  = @id_reserva			
							,@iden_gds					  = @iden_gds				
							,@cd_codigo					  = @cd_codigo				
							,@ds_fecha					  = @ds_fecha				
							,@cd_tiqueteador			  = @cd_tiqueteador		
							,@cd_vendedor				  = @cd_vendedor			
							,@cd_cliente				  = @cd_cliente			
							,@reserva					  = @reserva				
							,@cd_TipoTransaccion		  = @cd_TipoTransaccion	
							,@ds_pax_number				  = @ds_pax_number			
							,@ds_pax_firstnm			  = @ds_pax_firstnm		
							,@ds_pax_lastnm				  = @ds_pax_lastnm			
							,@ds_pax_prefix				  = @ds_pax_prefix			
							,@cd_pax_cedula				  = @cd_pax_cedula			
							,@ds_pax_telefono			  = @ds_pax_telefono		
							,@ds_tkt_number				  = @ds_tkt_number			
							,@ds_tkt_prefix				  = @ds_tkt_prefix			
							,@ds_aero_code				  = @ds_aero_code			
							,@ds_moneda					  = @ds_moneda				
							,@am_tarifa					  = @am_tarifa				
							,@am_iva					  = @am_iva				
							,@am_tua					  = @am_tua				
							,@am_vat					  = @am_vat				
							,@ds_cc_code				  = @ds_cc_code			
							,@ds_cc_number				  = @ds_cc_number			
							,@am_highfare				  = @am_highfare			
							,@am_lowfare				  = @am_lowfare			
							,@am_fare					  = @am_fare				
							,@ds_reasoncode				  = @ds_reasoncode			
							,@ds_cliname				  = @ds_cliname			
							,@ds_clidir					  = @ds_clidir				
							,@ds_clicity				  = @ds_clicity			
							,@ds_cliid					  = @ds_cliid				
							,@ds_clirazoncial			  = @ds_clirazoncial		
							,@ds_cliname2				  = @ds_cliname2			
							,@ds_clilastname			  = @ds_clilastname		
							,@ds_clilastname2			  = @ds_clilastname2		
							,@ds_clitel					  = @ds_clitel				
							,@cd_clipais				  = @cd_clipais			
							,@cd_clitipodoc				  = @cd_clitipodoc			
							,@cd_clitipotercero			  = @cd_clitipotercero		
							,@cd_CentroCostoCliente		  = @cd_CentroCostoCliente	
							,@am_comb					  = @am_comb				
							,@am_tao					  = @am_tao				
							,@am_ivatao					  = @am_ivatao				
							,@am_cap					  = @am_cap				
							,@am_ivacap					  = @am_ivacap				
							,@ds_cc_code2				  = @ds_cc_code2			
							,@ds_cc_number2				  = @ds_cc_number2			
							,@am_fp1					  = @am_fp1				
							,@am_fp2					  = @am_fp2				
							,@dt_entrega				  = @dt_entrega			
							,@in_cars					  = @in_cars				
							,@cd_carcode				  = @cd_carcode			
							,@cd_confirmation			  = @cd_confirmation		
							,@cd_citysalida				  = @cd_citysalida			
							,@dt_retorno				  = @dt_retorno			
							,@cd_cartype				  = @cd_cartype			
							,@cd_currency				  = @cd_currency			
							,@cd_bookingsource			  = @cd_bookingsource		
							,@cd_ratecode				  = @cd_ratecode			
							,@am_tarifarenta			  = @am_tarifarenta		
							,@cd_tktrevisado			  = @cd_tktrevisado		
							,@ds_itinerario				  = @ds_itinerario			
							,@ds_clases					  = @ds_clases				
							,@in_nacionalidad			  = @in_nacionalidad		
							,@am_TarifaContado			  = @am_TarifaContado		
							,@am_IvaContado				  = @am_IvaContado			
							,@am_OtrosContado			  = @am_OtrosContado		
							,@am_TarifaCredito			  = @am_TarifaCredito		
							,@am_IvaCredito				  = @am_IvaCredito			
							,@am_OtrosCredito			  = @am_OtrosCredito		
							,@am_Comision				  = @am_Comision			
							,@ds_Observaciones			  = @ds_Observaciones		
							,@ds_ClienteEmail			  = @ds_ClienteEmail		
							,@bl_ClienteActualizar		  = @bl_ClienteActualizar	
							,@bl_NotificacionMPD		  = @bl_NotificacionMPD	
							,@cd_NumeroPoliza			  = @cd_NumeroPoliza		
							,@cd_AnexoPoliza			  = @cd_AnexoPoliza		
							,@am_ValorPoliza			  = @am_ValorPoliza		
							,@cd_FormaPagoTAO			  = @cd_FormaPagoTAO		
							,@cd_TarjetaCreditoTAO		  = @cd_TarjetaCreditoTAO	
							,@cd_NumeroTarjetaTAO		  = @cd_NumeroTarjetaTAO	
							,@cd_VencimientoTarjetaTAO	  = @cd_VencimientoTarjetaTAO
							,@cd_NumeroPolizaTAO		  = @cd_NumeroPolizaTAO	
							,@cd_AnexoPolizaTAO			  = @cd_AnexoPolizaTAO		
							,@am_PorDesFormaPagoTA		  = @am_PorDesFormaPagoTA	
							,@cd_Penalidad				  = @cd_Penalidad			
							,@am_TasaCambio				  = @am_TasaCambio			
							,@ds_cc_vence				  = @ds_cc_vence			
							,@ds_cc_vence2				  = @ds_cc_vence2			
							,@ds_cc_autorizacion		  = @ds_cc_autorizacion	
							,@ds_cc_autorizacion2		  = @ds_cc_autorizacion2	
							,@ds_cc_voucher				  = @ds_cc_voucher			
							,@ds_cc_voucher2			  = @ds_cc_voucher2		
							,@ds_AutorizacionTarjetaTAO	  = @ds_AutorizacionTarjetaTAO
							,@ds_VoucherTarjetaTAO		  = @ds_VoucherTarjetaTAO	
							,@am_fptao					  = @am_fptao				
							,@in_cc_cuotas				  = @in_cc_cuotas			
							,@in_cc_cuotas2				  = @in_cc_cuotas2			
							,@in_cuotasTarjetaTAO		  = @in_cuotasTarjetaTAO	
							,@in_NumTktConj				  = @in_NumTktConj			
							,@cd_TipoTarifaTAO			  = @cd_TipoTarifaTAO		
							,@cd_TipoTiquete			  = @cd_TipoTiquete		
							,@PCC						  = @PCC					
							,@PCC_Emite					  = @PCC_Emite				
							,@bl_ahorro					  = @bl_ahorro				
							,@in_CantidadTarifaTAO		  = @in_CantidadTarifaTAO	
							,@in_CantidadSegmentoTAO	  = @in_CantidadSegmentoTAO
							,@cd_tourcode				  = @cd_tourcode			
							,@ds_contrato				  = @ds_contrato			
							,@cd_tourcode2				  = @cd_tourcode2			
							,@cd_Ahorro					  = @cd_Ahorro
							--Jramirez 2018/11/23 R74520
							,@cd_tipoventa				  = @cd_tipoventa				
							,@cd_licitacion				  = @cd_licitacion				
							,@ds_evento					  = @ds_evento					
							,@ds_campolibre1			  = @ds_campolibre1			
							,@ds_campolibre2			  = @ds_campolibre2			
							,@cd_facturador				  = @cd_facturador				
							,@cd_especialista			  = @cd_especialista			
							,@cd_tipoformapagoproveedor	  = @cd_tipoformapagoproveedor	
							,@cd_medioreservacion		  = @cd_medioreservacion
							,@ds_descripcion			  = @ds_descripcion
							,@am_iva2					  = @am_iva2			
							,@reservaxml				  = @reservaxml

						IF @Error <> 0 OR @@error <> 0
						BEGIN
							RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
							RETURN 1
						END
						Select @id_reserva = Id From BookingGds Where cd_codigo = @cd_codigo
						-- print '05'
						
						IF @ds_tipoitem = 'Tiquete'
						BEGIN
							--Creamos o actualizamos el tkt si ya existe.
							SET @Error = 1
							EXECUTE @Error =[dbo].[spBookingGDS]
								@Op				  			  = 'DetPas'
								,@id_reserva				  = @id_reserva			
								,@iden_gds					  = @iden_gds				
								,@cd_codigo					  = @cd_codigo				
								,@ds_fecha					  = @ds_fecha				
								,@cd_cliente				  = @cd_cliente			
								,@reserva					  = @reserva				
								,@cd_TipoTransaccion		  = @cd_TipoTransaccion	
								,@ds_pax_number				  = @ds_pax_number			
								,@ds_pax_firstnm			  = @ds_pax_firstnm		
								,@ds_pax_lastnm				  = @ds_pax_lastnm			
								,@ds_pax_prefix				  = @ds_pax_prefix			
								,@cd_pax_cedula				  = @cd_pax_cedula			
								,@ds_pax_telefono			  = @ds_pax_telefono		
								,@ds_tkt_number				  = @ds_tkt_number			
								,@ds_tkt_prefix				  = @ds_tkt_prefix			
								,@ds_aero_code				  = @ds_aero_code			
								,@ds_moneda					  = @ds_moneda		
									
								,@am_tarifa					  = @am_tarifa				
								,@am_iva					  = @am_iva				
								,@am_tua					  = @am_tua				
								,@am_vat					  = @am_vat	
								,@am_comb					  = @am_comb

								,@am_highfare				  = @am_highfare			
								,@am_lowfare				  = @am_lowfare			
								,@am_fare					  = @am_fare				
								,@ds_reasoncode				  = @ds_reasoncode			
								,@ds_cliname				  = @ds_cliname			
								,@ds_clidir					  = @ds_clidir				
								,@ds_clicity				  = @ds_clicity			
								,@ds_cliid					  = @ds_cliid				
								,@ds_clirazoncial			  = @ds_clirazoncial		
								,@ds_cliname2				  = @ds_cliname2			
								,@ds_clilastname			  = @ds_clilastname		
								,@ds_clilastname2			  = @ds_clilastname2		
								,@ds_clitel					  = @ds_clitel				
								,@cd_clipais				  = @cd_clipais			
								,@cd_clitipodoc				  = @cd_clitipodoc			
								,@cd_clitipotercero			  = @cd_clitipotercero		
								,@cd_CentroCostoCliente		  = @cd_CentroCostoCliente				
								,@cd_tktrevisado			  = @cd_tktrevisado		
								,@ds_itinerario				  = @ds_itinerario			
								,@ds_clases					  = @ds_clases				
								,@in_nacionalidad			  = @in_nacionalidad			
								,@am_Comision				  = @am_Comision			
								,@ds_Observaciones			  = @ds_Observaciones		
								,@bl_NotificacionMPD		  = @bl_NotificacionMPD	
								,@cd_Penalidad				  = @cd_Penalidad			
								,@am_TasaCambio				  = @am_TasaCambio			
								,@cd_tourcode				  = @cd_tourcode			
								,@cd_Ahorro					  = @cd_Ahorro
								,@ds_cc_code				  = @ds_cc_code
								,@ds_cc_number				  = @ds_cc_number			
								,@am_fp1					  = @am_fp1				
								,@am_fp2					  = @am_fp2	
								,@am_TarifaContado			  = @am_TarifaContado		
								,@am_IvaContado				  = @am_IvaContado			
								,@am_OtrosContado			  = @am_OtrosContado		
								,@am_TarifaCredito			  = @am_TarifaCredito		
								,@am_IvaCredito				  = @am_IvaCredito			
								,@am_OtrosCredito			  = @am_OtrosCredito
								,@ds_descripcion			  = @ds_descripcion
								,@cd_consecutivo			  = @cd_consecutivo
								,@am_iva2					  = @am_iva2
								,@in_NumTktConj				  = @in_NumTktConj
								,@cd_TipoTiquete			  = cd_TipoTiquete
								,@ds_cc_autorizacion		  = @ds_cc_autorizacion	
								,@ds_cc_autorizacion2		  = @ds_cc_autorizacion2	
								,@ds_cc_voucher				  = @ds_cc_voucher			
								,@ds_cc_voucher2			  = @ds_cc_voucher2
								,@cd_FormaPagoTAO			  = @cd_FormaPagoTAO		
								,@cd_TarjetaCreditoTAO		  = @cd_TarjetaCreditoTAO	
								,@cd_NumeroTarjetaTAO		  = @cd_NumeroTarjetaTAO	
								,@cd_VencimientoTarjetaTAO	  = @cd_VencimientoTarjetaTAO
								,@cd_NumeroPolizaTAO		  = @cd_NumeroPolizaTAO	
								,@cd_AnexoPolizaTAO			  = @cd_AnexoPolizaTAO		
								,@am_PorDesFormaPagoTA		  = @am_PorDesFormaPagoTA
								,@ds_AutorizacionTarjetaTAO	  = @ds_AutorizacionTarjetaTAO
								,@ds_VoucherTarjetaTAO		  = @ds_VoucherTarjetaTAO

							IF @Error <> 0 OR @@error <> 0
							BEGIN
								RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
								RETURN 1
							END

							--Informacion del itinerario del tiquete
							SELECT @Id_ReservaGDS_Detalles = Id FROM dbo.ReservaGDS_Detalles r WHERE r.id_reserva = @id_reserva AND r.ds_tkt_number = @ds_tkt_number
							Delete From ReservaGDS_Itinerarios Where Id_Reserva = @id_reserva
							Set @RegistroActualItinerario = 1
							WHILE ( @RegistroActualItinerario <= @TotalRegistrosItinerario )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del itinerario'
								IF exists(Select * From @ReservaGDS_Itinerarios Where ((cd_reserva = @cd_codigo AND @iden_gds=8) OR (cd_consecutivo = @cd_consecutivo AND cd_reserva = @cd_codigo AND @iden_gds IN(6,9))))
								Begin
									Select
										@orden					= orden
										,@cd_aero_salida		= cd_origen
										,@cd_aero_llegada		= cd_destino
										,@cd_clase				= cd_clase
										,@ds_fecha_salida		= fecha_salida
										,@ds_hora_salida		= hora_salida
										,@ds_hora_llegada		= hora_llegada
										,@cd_aero_siglas		= cd_aero_siglas
										,@cd_farebasis			= cd_farebasis
										,@ds_NumVuelo 			= ds_NumVuelo 
										,@ds_TipoVuelo			= ds_TipoVuelo
										,@am_valor				= am_valor
									From @ReservaGDS_Itinerarios
									Where id=@RegistroActualItinerario AND ((cd_reserva = @cd_codigo AND @iden_gds = 8) OR (cd_consecutivo = @cd_consecutivo AND cd_reserva = @cd_codigo AND @iden_gds IN(6,9)))
									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		= 'DetItinerario'
										,@id_reserva			= @id_reserva
										,@Iden_gds				= @iden_gds
										,@orden					= @orden
										,@cd_aero_salida		= @cd_aero_salida
										,@cd_aero_llegada		= @cd_aero_llegada
										,@cd_clase				= @cd_clase
										,@ds_fecha_salida		= @ds_fecha_salida
										,@ds_hora_salida		= @ds_hora_salida
										,@ds_hora_llegada		= @ds_hora_llegada
										,@cd_aero_siglas		= @cd_aero_siglas
										,@cd_farebasis			= @cd_farebasis
										,@ds_NumVuelo 			= @ds_NumVuelo 
										,@ds_TipoVuelo			= @ds_TipoVuelo
										,@am_valor				= @am_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualItinerario = @RegistroActualItinerario + 1
							END

							--Informacion del variables adicionales de tiquetes --inicio rgelis 2018/10/25 req.62804 
							Delete From ReservaGDS_VariableAdicional Where Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
							Set @RegistroActualVarAdicional = 1
							Set @TotalRegistrosVarAdicional = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_VariablesAdicionales),0)-- WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualVarAdicional <= @TotalRegistrosVarAdicional )
							BEGIN
								
								-- print 'Obtenemos la info del variables Adicional'
								IF exists(Select * From @ReservaGDS_VariablesAdicionales Where id = @RegistroActualVarAdicional AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									SET @Error = 0
									Select
										@in_orden= rp.in_orden
									   ,@ds_nombre = rp.ds_nombre 
									   ,@ds_valor = rp.ds_valor 	
									From @ReservaGDS_VariablesAdicionales rp 
									WHERE rp.id = @RegistroActualVarAdicional AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  
									

									-- print 'Antes de insertar la informacion de variables Adicional'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'VarAdicional'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
									    ,@in_orden				 = @in_orden
									    ,@ds_nombre				 = @ds_nombre
									    ,@ds_valor				 = @ds_valor
									
									
									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualVarAdicional = @RegistroActualVarAdicional + 1
							END	--fin rgelis 2018/10/25 req.62804
							
							--Informacion del Cargos e Impuestos de tiquetes --inicio rgelis 2022/05/16 req.227439 
							Delete From ReservaGDS_CargosImpuestos Where Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
							Set @RegistroActualCargosImpuestos = 1
							Set @TotalRegistrosCargosImpuestos = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_CargosImpuestos),0)-- WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualCargosImpuestos <= @TotalRegistrosCargosImpuestos )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Cargos e Impuestos'
								IF exists(Select * From @ReservaGDS_CargosImpuestos Where id = @RegistroActualCargosImpuestos AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										@in_orden= rp.in_orden
									   ,@cd_codigocarg = rp.cd_codigo	
									   ,@ds_nombre = rp.ds_nombre
									   ,@cd_tipo = rp.cd_tipo
									   ,@cd_codigopadre = rp.cd_codigopadre	
									   ,@cd_tipopadre = rp.cd_tipopadre
									   ,@am_porcentaje = rp.am_porcentaje
									   ,@am_contado = rp.am_contado
									   ,@am_credito	= rp.am_credito
									   ,@am_valor = rp.am_valor
									From @ReservaGDS_CargosImpuestos rp 
									WHERE rp.id = @RegistroActualCargosImpuestos AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion de cargod e impuestos'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'CargosImpuestos'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
									    ,@in_orden				 = @in_orden
									    ,@cd_codigocarg			 = @cd_codigocarg
										,@ds_nombre				 = @ds_nombre
										,@cd_tipo				 = @cd_tipo
										,@cd_codigopadre		 = @cd_codigopadre	
										,@cd_tipopadre			 = @cd_tipopadre
										,@am_porcentaje			 = @am_porcentaje
										,@am_contado			 = @am_contado
										,@am_credito			 = @am_credito
									    ,@am_valor				 = @am_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualCargosImpuestos = @RegistroActualCargosImpuestos + 1
							END	--fin rgelis 2022/05/16 req.227439

							--Informacion del Cargos e Impuestos de servicios --inicio rgelis 2022/05/16 req.227439 
							Delete From ReservaGDS_FormasPagos Where Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
							Set @RegistroActualFormasPagos = 1
							Set @TotalRegistrosFormasPagos = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_FormasPagos),0)-- WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualFormasPagos <= @TotalRegistrosFormasPagos )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Cargos e Impuestos'
								IF exists(Select * From @ReservaGDS_FormasPagos Where id = @RegistroActualFormasPagos AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										 @in_orden					= rp.in_orden				
										,@cd_codigofp				= rp.cd_codigo				
										,@ds_nombrefp				= rp.ds_nombre				
										,@cd_tipotarjeta			= rp.cd_tipotarjeta			
										,@ds_numerotarjeta			= rp.ds_numerotarjeta		
										,@ds_vouchertarjeta			= rp.ds_vouchertarjeta		
										,@ds_expiraciontarjeta		= rp.ds_expiraciontarjeta	
										,@ds_autorizaciontarjeta	= rp.ds_autorizaciontarjeta	
										,@in_coutas					= rp.in_coutas		
										,@cd_banco					= rp.cd_banco				
										,@ds_cheque					= rp.ds_cheque			
										,@ds_plaza					= rp.ds_plaza				
										,@ds_referencia				= rp.ds_referencia			
										,@ds_Poliza					= rp.ds_Poliza			
										,@ds_PolizaAnexo			= rp.ds_PolizaAnexo			
										,@am_valor					= rp.am_valor				
									From @ReservaGDS_FormasPagos rp 
									WHERE rp.id = @RegistroActualFormasPagos AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'FormasPagos'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
									    ,@in_orden				 = @in_orden
									    ,@cd_codigofp			 = @cd_codigofp
										,@ds_nombrefp			 = @ds_nombrefp
										,@cd_tipotarjeta		 = @cd_tipotarjeta
										,@ds_numerotarjeta		 = @ds_numerotarjeta
										,@ds_vouchertarjeta		 = @ds_vouchertarjeta
										,@ds_expiraciontarjeta	 = @ds_expiraciontarjeta
										,@ds_autorizaciontarjeta = @ds_autorizaciontarjeta
										,@in_coutas				 = @in_coutas
										,@cd_banco				 = @cd_banco
										,@ds_cheque				 = @ds_cheque
										,@ds_plaza				 = @ds_plaza
										,@ds_referencia			 = @ds_referencia
										,@ds_Poliza				 = @ds_Poliza
										,@ds_PolizaAnexo		 = @ds_PolizaAnexo
									    ,@am_valor				 = @am_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualFormasPagos = @RegistroActualFormasPagos + 1
							END	--fin rgelis 2022/05/16 req.227439


							--Informacion del fee de servicios 
							Delete From ReservaGDS_Fee Where cd_tiquete = @ds_tkt_number 
							Set @RegistroActualFee = 1
							Set @TotalRegistrosFee = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_Fee),0)-- WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualFee <= @TotalRegistrosFee )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Cargos e Impuestos'
								IF exists(Select * From @ReservaGDS_Fee Where id = @RegistroActualFee AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										 @in_orden					= rp.in_orden				
										,@cd_conceptofacturacion 	= rp.cd_conceptofac 				
										,@cd_TipoServicio 			= rp.cd_subcodigo 				
										,@ds_Descrip 				= rp.ds_servicio 					
										,@am_valor					= rp.am_valor				
									From @ReservaGDS_Fee rp 
									WHERE rp.id = @RegistroActualFee AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'Fee'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Detalles = @Id_ReservaGDS_Detalles
										,@ds_tkt_number			 = @ds_tkt_number	
									    ,@in_orden				 = @in_orden
									    ,@cd_conceptofacturacion = @cd_conceptofacturacion
										,@cd_TipoServicio		 = @cd_TipoServicio
										,@ds_Descrip			 = @ds_Descrip
									    ,@am_valor				 = @am_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualFee = @RegistroActualFee + 1
							END	

						END
						
						IF @ds_tipoitem = 'Servicio'
						BEGIN  
							--Creamos o actualizamos el tkt si ya existe.

							--select *  From @ReservaGDS_Pasajeros where cd_consecutivo = @cd_consecutivo
							Select top 1
								@ds_pax_firstnm			  = ds_pax_firstnm		
								,@ds_pax_lastnm				  = ds_pax_lastnm			
								,@ds_pax_prefix				  = ds_pax_prefix			
								,@cd_pax_cedula				  = cd_pax_cedula			
								,@ds_pax_telefono			  = ds_pax_telefono		
							From @ReservaGDS_Pasajeros
							where cd_consecutivo = @cd_consecutivo --and @in_orden=1

							SET @Error = 1
							EXECUTE @Error =[dbo].[spBookingGDS]
								@Op				  			  = 'DetSrv'
								,@id_reserva				  = @id_reserva			
								,@iden_gds					  = @iden_gds				
								,@cd_codigo					  = @cd_codigo				
								,@reserva					  = @reserva				
								,@ds_pax_number				  = @ds_pax_number			
								,@ds_pax_firstnm			  = @ds_pax_firstnm		
								,@ds_pax_lastnm				  = @ds_pax_lastnm			
								,@ds_pax_prefix				  = @ds_pax_prefix			
								,@cd_pax_cedula				  = @cd_pax_cedula			
								,@ds_pax_telefono			  = @ds_pax_telefono		
								,@ds_tkt_number				  = @ds_tkt_number			
								,@ds_tkt_prefix				  = @ds_tkt_prefix			
								,@ds_moneda					  = @ds_moneda				
								,@am_tarifa					  = @am_tarifa				
								,@am_iva					  = @am_iva				
								,@am_tua					  = @am_tua				
								,@am_vat					  = @am_vat				
								,@ds_cc_code				  = @ds_cc_code			
								,@ds_cc_number				  = @ds_cc_number			
								,@am_fp1					  = @am_fp1				
								,@am_fp2					  = @am_fp2			
								,@dt_checkin				  = @dt_checkin			
								,@in_guests					  = @in_guests				
								,@cd_city					  = @cd_city				
								,@cd_htlchain				  = @cd_htlchain			
								,@dt_checkout				  = @dt_checkout			
								,@ds_htlname				  = @ds_htlname			
								,@in_habs					  = @in_habs				
								,@cd_bed					  = @cd_bed				
								,@cd_htlcur					  = @cd_htlcur				
								,@am_htltarifa				  = @am_htltarifa			
								,@cd_agcur					  = @cd_agcur				
								,@am_agtarifa				  = @am_agtarifa			
								,@ds_dir1					  = @ds_dir1				
								,@ds_tel					  = @ds_tel				
								,@ds_fax					  = @ds_fax				
								,@cd_conceptofacturacion	  = @cd_conceptofacturacion
								,@cd_TipoServicio			  = @cd_TipoServicio		
								,@cd_Proveedores			  = @cd_Proveedores		
								,@ds_Descrip				  = @ds_Descrip											
								,@in_nacionalidad			  = @in_nacionalidad		
								,@am_TarifaContado			  = @am_TarifaContado		
								,@am_IvaContado				  = @am_IvaContado			
								,@am_OtrosContado			  = @am_OtrosContado		
								,@am_TarifaCredito			  = @am_TarifaCredito		
								,@am_IvaCredito				  = @am_IvaCredito			
								,@am_OtrosCredito			  = @am_OtrosCredito		
								,@am_Comision				  = @am_Comision			
								,@ds_Observaciones			  = @ds_Observaciones		
								,@bl_NotificacionMPD		  = @bl_NotificacionMPD	
								,@am_TasaCambio				  = @am_TasaCambio			
								,@ds_cc_vence				  = @ds_cc_vence			
								,@ds_cc_vence2				  = @ds_cc_vence2			
								,@ds_cc_autorizacion		  = @ds_cc_autorizacion	
								,@ds_cc_autorizacion2		  = @ds_cc_autorizacion2	
								,@ds_cc_voucher				  = @ds_cc_voucher			
								,@ds_cc_voucher2			  = @ds_cc_voucher2		
								,@in_cc_cuotas				  = @in_cc_cuotas			
								,@in_cc_cuotas2				  = @in_cc_cuotas2			
								,@cd_auxiliar				  = @cd_auxiliar
								,@ds_indice					  = @ds_indice --rgelis 2020/03/24 correcion por interfaz con juniper
								,@cd_tipoproveedor			  = @cd_tipoproveedor
								,@ds_tipoproveedor			  = @ds_tipoproveedor
								,@cd_consecutivo		      = @cd_consecutivo

							IF @Error <> 0 OR @@error <> 0
							BEGIN
								RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
								RETURN 1
							END
							
							--Obtenemos el Id de la reserva creada y complemetamos la reserva con la informacion de hoteles
							SELECT @Id_ReservaGDS_Servicios = Id FROM dbo.ReservaGDS_Servicios r WHERE r.id_reserva = @id_reserva AND r.cd_conceptofacturacion = @cd_conceptofacturacion
						 	
						 	--select @cd_codigo as '@cd_codigo',@dt_checkin as '@dt_checkin', @dt_checkout as '@dt_checkout', @ds_htlname as '@ds_htlname', @in_habs as '@in_habs'
							--Si hay informacion de hoteles, llenamos la info.
							IF @Id_ReservaGDS_Servicios IS NOT NULL
								AND @cd_codigo <> ''
								AND @dt_checkin <> '' AND @dt_checkout <> '' 
								AND @ds_htlname <> '' AND @in_habs > 0
							BEGIN	
							
								SET @Error = 1
								EXECUTE @Error =[dbo].[spBookingGDS]
									@Op				  			  = 'DetHotel'
									,@id_reserva				  = @id_reserva			
									,@iden_gds					  = @iden_gds				
									,@cd_codigo					  = @cd_codigo				
									,@reserva					  = @reserva						
									,@dt_checkin				  = @dt_checkin		
									,@in_guests					  = @in_guests			
									,@cd_confirmation			  = @cd_confirmation	
									,@cd_city					  = @cd_city			
									,@cd_htlchain				  = @cd_htlchain		
									,@dt_checkout				  = @dt_checkout
									,@ds_htlname				  = @ds_htlname
									,@in_habs					  = @in_habs
									,@cd_bed					  = @cd_bed
									,@cd_ratecode				  = @cd_ratecode
									,@cd_htlcur					  = @cd_htlcur		
									,@am_htltarifa				  = @am_htltarifa		
									,@cd_agcur					  = @cd_agcur			
									,@am_agtarifa				  = @am_agtarifa
									,@ds_dir1					  = @ds_dir1		
									,@ds_tel					  = @ds_tel			
									,@ds_fax					  = @ds_fax		
									,@Id_ReservaGDS_Servicios	  = @Id_ReservaGDS_Servicios	
								
								IF @Error <> 0 OR @@error <> 0
								BEGIN
									RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
									RETURN 1
								END	
							END
							
							--Informacion del pasajeros adicionales de servicios --inicio rgelis 2018/01/22 req.46714 
							Delete From ReservaGDS_Servicios_PaxAdicional Where Id_ReservaGDS_Servicios = @Id_ReservaGDS_Servicios
							Set @RegistroActualPaxAdicional = 2
							Set @TotalRegistrosPaxAdicionalServ = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_Pasajeros WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualPaxAdicional <= @TotalRegistrosPaxAdicionalServ )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Pasajero Adicional'
								IF exists(Select * From @ReservaGDS_Pasajeros Where in_orden = @RegistroActualPaxAdicional AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										@ds_pax_lastnm= rp.ds_pax_lastnm
									   ,@ds_pax_firstnm = rp.ds_pax_firstnm
									   ,@ds_pax_prefix = rp.ds_pax_prefix 
									   ,@ds_paxClasificacion = ''
									   ,@cd_voucherpax = ''
									   ,@cd_pax_cedula = rp.cd_pax_cedula
									   ,@in_edad=0		
									From @ReservaGDS_Pasajeros rp 
									WHERE rp.in_orden = @RegistroActualPaxAdicional AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'PaxAdicional'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Servicios= @Id_ReservaGDS_Servicios
									    ,@ds_pax_lastnm			 = @ds_pax_lastnm
									    ,@ds_pax_firstnm		 = @ds_pax_firstnm
									    ,@ds_pax_prefix			 = @ds_pax_prefix
									    ,@ds_paxClasificacion	 = @ds_paxClasificacion
									    ,@cd_voucherpax			 = @cd_voucherpax
									    ,@cd_pax_cedula			 = @cd_pax_cedula
									    ,@in_edad				 = @in_edad
									    ,@ds_tkt_number			 = @ds_tkt_number

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualPaxAdicional = @RegistroActualPaxAdicional + 1
							END	--fin rgelis 2018/01/22 req.46714 
							
							--Informacion del variables adicionales de servicios --inicio rgelis 2018/10/25 req.62804 
							Delete From ReservaGDS_VariableAdicional Where Id_ReservaGDS_Servicios = @Id_ReservaGDS_Servicios
							Set @RegistroActualVarAdicional = 1
							Set @TotalRegistrosVarAdicionalServ = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_VariablesAdicionales),0)-- WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualVarAdicional <= @TotalRegistrosVarAdicionalServ )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Pasajero Adicional'
								IF exists(Select * From @ReservaGDS_VariablesAdicionales Where id = @RegistroActualVarAdicional AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										@in_orden= rp.in_orden
									   ,@ds_nombre = rp.ds_nombre 
									   ,@ds_valor = rp.ds_valor 	
									From @ReservaGDS_VariablesAdicionales rp 
									WHERE rp.id = @RegistroActualVarAdicional AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'VarAdicional'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Servicios= @Id_ReservaGDS_Servicios
									    ,@in_orden				 = @in_orden
									    ,@ds_nombre				 = @ds_nombre
									    ,@ds_valor				 = @ds_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualVarAdicional = @RegistroActualVarAdicional + 1
							END	--fin rgelis 2018/10/25 req.62804 
							
							--Informacion del Cargos e Impuestos de servicios --inicio rgelis 2022/05/16 req.227439 
							Delete From ReservaGDS_CargosImpuestos Where Id_ReservaGDS_Servicios = @Id_ReservaGDS_Servicios
							Set @RegistroActualCargosImpuestos = 1
							Set @TotalRegistrosCargosImpuestosServ = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_CargosImpuestos),0) --WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualCargosImpuestos <= @TotalRegistrosCargosImpuestosServ )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Cargos e Impuestos'
								IF exists(Select * From @ReservaGDS_CargosImpuestos Where id = @RegistroActualCargosImpuestos AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										@in_orden= rp.in_orden
									   ,@cd_codigocarg = rp.cd_codigo	
									   ,@ds_nombre = rp.ds_nombre
									   ,@cd_tipo = rp.cd_tipo
									   ,@cd_codigopadre = rp.cd_codigopadre	
									   ,@cd_tipopadre = rp.cd_tipopadre
									   ,@am_porcentaje = rp.am_porcentaje
									   ,@am_contado = rp.am_contado
									   ,@am_credito	= rp.am_credito
									   ,@am_valor = rp.am_valor
									From @ReservaGDS_CargosImpuestos rp 
									WHERE rp.id = @RegistroActualCargosImpuestos AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'CargosImpuestos'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Servicios= @Id_ReservaGDS_Servicios
									    ,@in_orden				 = @in_orden
									    ,@cd_codigocarg			 = @cd_codigocarg
										,@ds_nombre				 = @ds_nombre
										,@cd_tipo				 = @cd_tipo
										,@cd_codigopadre		 = @cd_codigopadre	
										,@cd_tipopadre			 = @cd_tipopadre
										,@am_porcentaje			 = @am_porcentaje
										,@am_contado			 = @am_contado
										,@am_credito			 = @am_credito
									    ,@am_valor				 = @am_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualCargosImpuestos = @RegistroActualCargosImpuestos + 1
							END	--fin rgelis 2022/05/16 req.227439

							--Informacion del Cargos e Impuestos de servicios --inicio rgelis 2022/05/16 req.227439 
							Delete From ReservaGDS_FormasPagos Where Id_ReservaGDS_Servicios = @Id_ReservaGDS_Servicios
							Set @RegistroActualFormasPagos = 1
							Set @TotalRegistrosFormasPagosServ = ISNULL((SELECT COUNT(1) FROM @ReservaGDS_FormasPagos),0)-- WHERE cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo),0)
							WHILE ( @RegistroActualFormasPagos <= @TotalRegistrosFormasPagosServ )
							BEGIN
								SET @Error = 1
								-- print 'Obtenemos la info del Cargos e Impuestos'
								IF exists(Select * From @ReservaGDS_FormasPagos Where id = @RegistroActualFormasPagos AND cd_reserva = @cd_codigo AND cd_consecutivo=@cd_consecutivo)
								Begin
									Select
										 @in_orden					= rp.in_orden				
										,@cd_codigofp				= rp.cd_codigo				
										,@ds_nombrefp				= rp.ds_nombre				
										,@cd_tipotarjeta			= rp.cd_tipotarjeta			
										,@ds_numerotarjeta			= rp.ds_numerotarjeta		
										,@ds_vouchertarjeta			= rp.ds_vouchertarjeta		
										,@ds_expiraciontarjeta		= rp.ds_expiraciontarjeta	
										,@ds_autorizaciontarjeta	= rp.ds_autorizaciontarjeta	
										,@in_coutas					= rp.in_coutas		
										,@cd_banco					= rp.cd_banco				
										,@ds_cheque					= rp.ds_cheque			
										,@ds_plaza					= rp.ds_plaza				
										,@ds_referencia				= rp.ds_referencia			
										,@ds_Poliza					= rp.ds_Poliza			
										,@ds_PolizaAnexo			= rp.ds_PolizaAnexo			
										,@am_valor					= rp.am_valor				
									From @ReservaGDS_FormasPagos rp 
									WHERE rp.id = @RegistroActualFormasPagos AND rp.cd_reserva = @cd_codigo AND rp.cd_consecutivo=@cd_consecutivo  


									-- print 'Antes de insertar la informacion del itinerario'
																			
									EXECUTE @Error =[dbo].[spBookingGDS]
										@Op				  		 = 'FormasPagos'
										,@id_reserva			 = @id_reserva
										,@Iden_gds				 = @iden_gds
										,@Id_ReservaGDS_Servicios= @Id_ReservaGDS_Servicios
									    ,@in_orden				 = @in_orden
									    ,@cd_codigofp			 = @cd_codigofp
										,@ds_nombrefp			 = @ds_nombrefp
										,@cd_tipotarjeta		 = @cd_tipotarjeta
										,@ds_numerotarjeta		 = @ds_numerotarjeta
										,@ds_vouchertarjeta		 = @ds_vouchertarjeta
										,@ds_expiraciontarjeta	 = @ds_expiraciontarjeta
										,@ds_autorizaciontarjeta = @ds_autorizaciontarjeta
										,@in_coutas				 = @in_coutas
										,@cd_banco				 = @cd_banco
										,@ds_cheque				 = @ds_cheque
										,@ds_plaza				 = @ds_plaza
										,@ds_referencia			 = @ds_referencia
										,@ds_Poliza				 = @ds_Poliza
										,@ds_PolizaAnexo		 = @ds_PolizaAnexo
									    ,@am_valor				 = @am_valor

									IF @Error <> 0 OR @@error <> 0
									BEGIN
										RAISERROR ('Error al ejecuar consulta principal del Maestro de Booking.' , 16, 1)
										RETURN 1
									END
								End
								Set @RegistroActualFormasPagos = @RegistroActualFormasPagos + 1
							END	--fin rgelis 2022/05/16 req.227439
						END 
					End

					If EXISTS(Select * From dbo.BookingGDS_FacAuto Where cd_sucursal = @cd_sucursal and Id_Reserva = @id_reserva )
					Begin
						UPDATE dbo.BookingGDS_FacAuto
						Set cd_sucursal = @cd_sucursal
							, cd_implante = @cd_implante
							, ds_Archivo = 'WebService'
						Where id_reserva = @id_reserva
					End
					Else
					Begin			
						Insert Into dbo.BookingGDS_FacAuto (cd_sucursal,cd_implante,Id_reserva,ds_archivo)
						VALUES(@cd_sucursal,@cd_implante,@id_reserva,'WebService')
					End

					SET @RegistroActual = @RegistroActual + 1
					
					--Aqui debemos setear en null todas las variables.
					Select
						@OpBookingGDS  			  = NULL
						,@ds_tipoitem				  = NULL
						,@cd_sucursal				  = NULL
						,@cd_implante				  = NULL
						,@bl_externo				  = NULL
						,@id_reserva				  = NULL
						,@iden_gds					  = NULL
						,@cd_codigo					  = NULL
						,@ds_fecha					  = NULL
						,@cd_tiqueteador			  = NULL
						,@cd_vendedor				  = NULL
						,@cd_cliente				  = NULL
						,@reserva					  = NULL
						,@cd_TipoTransaccion		  = NULL
						,@ds_pax_number				  = NULL
						,@ds_pax_firstnm			  = NULL
						,@ds_pax_lastnm				  = NULL
						,@ds_pax_prefix				  = NULL
						,@cd_pax_cedula				  = NULL
						,@ds_pax_telefono			  = NULL
						,@ds_tkt_number				  = NULL
						,@ds_tkt_prefix				  = NULL
						,@ds_aero_code				  = NULL
						,@ds_moneda					  = NULL
						,@am_tarifa					  = NULL
						,@am_iva					  = NULL
						,@am_tua					  = NULL
						,@am_vat					  = NULL
						,@ds_cc_code				  = NULL
						,@ds_cc_number				  = NULL
						,@am_highfare				  = NULL
						,@am_lowfare				  = NULL
						,@am_fare					  = NULL
						,@ds_reasoncode				  = NULL
						,@ds_cliname				  = NULL
						,@ds_clidir					  = NULL
						,@ds_clicity				  = NULL
						,@ds_cliid					  = NULL
						,@ds_clirazoncial			  = NULL
						,@ds_cliname2				  = NULL
						,@ds_clilastname			  = NULL
						,@ds_clilastname2			  = NULL
						,@ds_clitel					  = NULL
						,@cd_clipais				  = NULL
						,@cd_clitipodoc				  = NULL
						,@cd_clitipotercero			  = NULL
						,@cd_CentroCostoCliente		  = NULL
						,@am_comb					  = NULL
						,@am_tao					  = NULL
						,@am_ivatao					  = NULL
						,@am_cap					  = NULL
						,@am_ivacap					  = NULL
						,@ds_cc_code2				  = NULL
						,@ds_cc_number2				  = NULL
						,@am_fp1					  = NULL
						,@am_fp2					  = NULL
						,@dt_entrega				  = NULL
						,@in_cars					  = NULL
						,@cd_carcode				  = NULL
						,@cd_confirmation			  = NULL
						,@cd_citysalida				  = NULL
						,@dt_retorno				  = NULL
						,@cd_cartype				  = NULL
						,@cd_currency				  = NULL
						,@cd_bookingsource			  = NULL
						,@cd_ratecode				  = NULL
						,@am_tarifarenta			  = NULL
						,@dt_checkin				  = NULL
						,@in_guests					  = NULL
						,@cd_city					  = NULL
						,@cd_htlchain				  = NULL
						,@dt_checkout				  = NULL
						,@ds_htlname				  = NULL
						,@in_habs					  = NULL
						,@cd_bed					  = NULL
						,@cd_htlcur					  = NULL
						,@am_htltarifa				  = NULL
						,@cd_agcur					  = NULL
						,@am_agtarifa				  = NULL
						,@ds_dir1					  = NULL
						,@ds_tel					  = NULL
						,@ds_fax					  = NULL
						,@cd_conceptofacturacion	  = NULL
						,@cd_TipoServicio			  = NULL
						,@cd_Proveedores			  = NULL
						,@ds_Descrip				  = NULL
						,@cd_tktrevisado			  = NULL
						,@ds_itinerario				  = NULL
						,@ds_clases					  = NULL
						,@in_nacionalidad			  = NULL
						,@am_TarifaContado			  = NULL
						,@am_IvaContado				  = NULL
						,@am_OtrosContado			  = NULL
						,@am_TarifaCredito			  = NULL
						,@am_IvaCredito				  = NULL
						,@am_OtrosCredito			  = NULL
						,@am_Comision				  = NULL
						,@ds_Observaciones			  = NULL
						,@ds_ClienteEmail			  = NULL
						,@bl_ClienteActualizar		  = NULL
						,@bl_NotificacionMPD		  = NULL
						,@cd_NumeroPoliza			  = NULL
						,@cd_AnexoPoliza			  = NULL
						,@am_ValorPoliza			  = NULL
						,@cd_FormaPagoTAO			  = NULL
						,@cd_TarjetaCreditoTAO		  = NULL
						,@cd_NumeroTarjetaTAO		  = NULL
						,@cd_VencimientoTarjetaTAO	  = NULL
						,@cd_NumeroPolizaTAO		  = NULL
						,@cd_AnexoPolizaTAO			  = NULL
						,@am_PorDesFormaPagoTA		  = NULL
						,@cd_Penalidad				  = NULL
						,@am_TasaCambio				  = NULL
						,@ds_cc_vence				  = NULL
						,@ds_cc_vence2				  = NULL
						,@ds_cc_autorizacion		  = NULL
						,@ds_cc_autorizacion2		  = NULL
						,@ds_cc_voucher				  = NULL
						,@ds_cc_voucher2			  = NULL
						,@ds_AutorizacionTarjetaTAO	  = NULL
						,@ds_VoucherTarjetaTAO		  = NULL
						,@am_fptao					  = NULL
						,@in_cc_cuotas				  = NULL
						,@in_cc_cuotas2				  = NULL
						,@in_cuotasTarjetaTAO		  = NULL
						,@in_NumTktConj				  = NULL
						,@cd_TipoTarifaTAO			  = NULL
						,@cd_TipoTiquete			  = NULL
						,@PCC						  = NULL
						,@PCC_Emite					  = NULL
						,@bl_ahorro					  = NULL
						,@in_CantidadTarifaTAO		  = NULL
						,@in_CantidadSegmentoTAO	  = NULL
						,@cd_tourcode				  = NULL
						,@ds_contrato				  = NULL
						,@cd_tourcode2				  = NULL
						,@cd_Ahorro					  = NULL
						,@Id_ReservaGDS_Servicios	  = NULL
						,@ds_descripcion			  = NULL
						,@cd_tipoproveedor			  = NULL
						,@ds_tipoproveedor			  = NULL
						,@reservaxml				  = NULL
				END										
			
			SELECT Resultado = 'SUCCESS', Mensaje='Proceso realizado exitosamente'
			--Select * from @ReservaGDS_Pasajeros
			COMMIT TRANSACTION
		END
		ELSE IF @OpBookingGDS In ('Consultar')
		BEGIN

			DECLARE @Resultado TABLE (Nodos XML)

			SELECT Resultado = @NodoXML

			RETURN 1
		END
	END TRY
	BEGIN CATCH
	
		IF @@trancount >= 1
		BEGIN
			ROLLBACK TRANSACTION
		END
		
		SET @TextoRaiserror = ISNULL ( ERROR_MESSAGE() , '')

		SET @TextoRaiserror =	CHAR(13) + CHAR(10) +
								'Operacion: ' +  @Operacion + CHAR(13) + CHAR(10) + 
								--'Registro: ' +  CONVERT(VARCHAR(10), IsNull(@RegistroActual, 0)) + ' - Cliente: ' + Isnull(@IdCliente,'') + CHAR(13) + CHAR(10) + 
								'Mensaje: ' +  @TextoRaiserror

		RAISERROR ( @TextoRaiserror , 16, 1)

	END CATCH

	RETURN
END
GO
