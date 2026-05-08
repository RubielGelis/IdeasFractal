CREATE OR REPLACE PROCEDURE spInterfaceReadXMLBookingIdeasFractal(
	p_Op VARCHAR(50) DEFAULT NULL,
	p_XML text DEFAULT NULL,
	INOUT p_XMLOutput text DEFAULT NULL,
	p_BlSelect boolean DEFAULT false
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
	v_NodoXML XML;
	v_RegistroActual BIGINT;
	v_TotalRegistros BIGINT;
	v_TextoRaiserror text;
	v_Error INT;
	v_Operacion VARCHAR(50);
	v_Pais VARCHAR(25);
	v_cd_interfaces VARCHAR(50);
	v_id_interfaces INT;
	v_cd_sucursal VARCHAR(5);
	v_cd_implante VARCHAR(5);
	v_cd_tc VARCHAR(2);
	v_ds_numerotc VARCHAR(16);
	v_cd_concepto VARCHAR(5);
	v_cd_tiposrv VARCHAR(5);
	v_ds_descripcion VARCHAR(500);
	v_cd_conceptoutl VARCHAR(5);
	v_cd_tiposrvutl VARCHAR(5);
	v_ds_descripcionutl VARCHAR(500);
	v_in_refecliente VARCHAR(2);
	v_in_refevendedor VARCHAR(2);
	v_am_poriva NUMERIC(8,4);
	v_cd_conceptohotel VARCHAR(5);
	v_cd_conceptocarrental VARCHAR(5);
	v_cd_conceptoseguro VARCHAR(5);
	v_cd_tiposrhotel VARCHAR(5);
	v_cd_tiposrcarrental VARCHAR(5);
	v_cd_tiposrseguro VARCHAR(5);
	v_bl_IncluirCombaTarifa CHAR(1);
	v_bl_SumarCombustibleTarifaTkt CHAR(1);
BEGIN
    -- Crear tablas temporales
    CREATE TEMP TABLE tmp_Booking (
		id INT GENERATED ALWAYS AS IDENTITY , OpBookingGDS VARCHAR(15), ds_tipoitem VARCHAR(15), cd_tipoitem VARCHAR(25),
		cd_sucursal CHAR(25), cd_implante CHAR(25), bl_externo boolean, id_booking INT, iden_gds INT,
		cd_codigo CHAR(12), ds_fecha CHAR(8), cd_tiqueteador CHAR(6), cd_vendedor CHAR(3), cd_cliente VARCHAR(25),
		booking text, cd_TipoTransaccion CHAR(1), ds_pax_number smallint, ds_pax_firstnm VARCHAR(30),
		ds_pax_lastnm VARCHAR(30), ds_pax_prefix CHAR(3), cd_pax_cedula CHAR(15), ds_pax_telefono CHAR(15),
		ds_tkt_number CHAR(10), ds_tkt_prefix CHAR(3), ds_aero_code CHAR(3), ds_moneda CHAR(3),
		am_tarifa numeric(18,2), am_iva numeric(18,2), am_tua numeric(18,2), am_vat numeric(18,2),
		ds_cc_code CHAR(2), ds_cc_number CHAR(16), cd_farebasis VARCHAR(25), cd_aero_siglas CHAR(3),
		cd_aero_salida CHAR(3), cd_aero_llegada CHAR(3), orden INT, ds_fecha_salida CHAR(8),
		ds_hora_salida CHAR(5), ds_hora_llegada CHAR(5), cd_clase CHAR(2), am_highfare numeric(18,2),
		am_lowfare numeric(18,2), am_fare numeric(18,2), ds_reasoncode CHAR(2), ds_cliname VARCHAR (50),
		ds_clidir VARCHAR (50), ds_clicity VARCHAR (50), ds_cliid CHAR (25), ds_clirazoncial VARCHAR (250),
		ds_cliname2 VARCHAR (60), ds_clilastname VARCHAR (60), ds_clilastname2 VARCHAR (60), ds_clitel VARCHAR (25),
		cd_clipais VARCHAR (25), cd_clitipodoc VARCHAR (100), cd_clitipotercero CHAR (1), cd_CentroCostoCliente VARCHAR(50),
		am_comb numeric(18,2), am_tao numeric(18,2), am_ivatao numeric(18,2), am_cap numeric(18,2),
		am_ivacap numeric(18,2), ds_cc_code2 CHAR(2), ds_cc_number2 VARCHAR(16), am_fp1 numeric(18,2),
		am_fp2 numeric(18,2), dt_entrega CHAR(17), in_cars smallint, cd_carcode CHAR(2), cd_confirmation VARCHAR(16),
		cd_citysalida CHAR(3), dt_retorno CHAR(17), cd_cartype VARCHAR(20), cd_currency CHAR(3), cd_bookingsource VARCHAR(20),
		cd_ratecode VARCHAR(10), am_tarifarenta numeric(18,2), dt_checkin CHAR(8), in_guests smallint, cd_city CHAR(3),
		cd_htlchain CHAR(2), dt_checkout CHAR(8), ds_htlname VARCHAR(32), in_habs smallint, cd_bed CHAR(3),
		cd_htlcur CHAR(3), am_htltarifa numeric(18,2), cd_agcur CHAR(3), am_agtarifa numeric(18,2), ds_dir1 VARCHAR(50),
		ds_tel VARCHAR(12), ds_fax VARCHAR(12), cd_conceptofacturacion CHAR(25), cd_TipoServicio CHAR(3), cd_Proveedores VARCHAR(25),
		ds_Descrip VARCHAR(500), cd_tktrevisado CHAR(14), ds_itinerario VARCHAR(64), ds_clases VARCHAR(36), in_nacionalidad smallint,
		am_TarifaContado numeric(18,2), am_IvaContado numeric(18,2), am_OtrosContado numeric(18,2), am_TarifaCredito numeric(18,2),
		am_IvaCredito numeric(18,2), am_OtrosCredito numeric(18,2), am_Comision numeric(18,2), ds_Observaciones VARCHAR(8000),
		ds_ClienteEmail VARCHAR(100), bl_ClienteActualizar boolean, bl_NotificacionMPD boolean, cd_NumeroPoliza VARCHAR(50),
		cd_AnexoPoliza VARCHAR(50), am_ValorPoliza numeric(18,2), cd_FormaPagoTAO CHAR(3), cd_TarjetaCreditoTAO CHAR(2),
		cd_NumeroTarjetaTAO CHAR(16), cd_VencimientoTarjetaTAO CHAR(5), cd_NumeroPolizaTAO VARCHAR(50), cd_AnexoPolizaTAO VARCHAR(50),
		am_PorDesFormaPagoTA NUMERIC(8,4), ds_NumVuelo VARCHAR(25), ds_TipoVuelo CHAR(1), cd_Penalidad CHAR(14),
		am_TasaCambio numeric(18,2), ds_cc_vence CHAR(5), ds_cc_vence2 CHAR(5), ds_cc_autorizacion VARCHAR(25),
		ds_cc_autorizacion2 VARCHAR(25), ds_cc_voucher VARCHAR(10), ds_cc_voucher2 VARCHAR(10), ds_AutorizacionTarjetaTAO VARCHAR(25),
		ds_VoucherTarjetaTAO VARCHAR(10), am_fptao numeric(18,2), in_cc_cuotas INT, in_cc_cuotas2 INT, in_cuotasTarjetaTAO INT,
		in_NumTktConj INT, cd_TipoTarifaTAO VARCHAR(25), cd_TipoTiquete CHAR(3), PCC VARCHAR(5), PCC_Emite VARCHAR(5),
		bl_ahorro boolean, in_CantidadTarifaTAO INT, in_CantidadSegmentoTAO INT, cd_tourcode VARCHAR(25), ds_contrato VARCHAR(25),
		am_valor numeric(18,2), cd_tourcode2 VARCHAR(25), cd_Ahorro VARCHAR(25), cd_consecutivo VARCHAR(25), cd_auxiliar VARCHAR(16),
		cd_tipoventa VARCHAR(16), cd_licitacion VARCHAR(25), ds_evento VARCHAR(250), ds_campolibre1 VARCHAR(500), ds_campolibre2 VARCHAR(500),
		cd_facturador VARCHAR(3), cd_especialista VARCHAR(25), cd_tipoformapagoproveedor VARCHAR(25), cd_medioreservacion VARCHAR(25),
		itinerarios text, pasajeros text, Variables text, am_utl numeric(18,2), am_TasaCambioutl numeric(18,2),
		cd_conceptofacturacionutl CHAR(25), cd_TipoServicioutl CHAR(3), ds_Descriputl VARCHAR(500), ancillari INT,
		bookingxml text
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_Itinerarios (
		id INT GENERATED ALWAYS AS IDENTITY, cd_booking VARCHAR(12) NOT NULL, ds_tkt_number VARCHAR(10) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		orden smallint NULL, cd_origen CHAR (3) NULL, cd_destino CHAR (3) NULL, cd_clase CHAR (1) NULL, fecha_salida VARCHAR(8) NULL,
		hora_salida VARCHAR (5) NULL, hora_llegada VARCHAR (5) NULL, terminal VARCHAR (50) NULL, cd_aero_siglas CHAR (2) NULL,
		cd_farebasis VARCHAR (25) NULL, ds_NumVuelo VARCHAR (25) NULL, ds_TipoVuelo CHAR (1) NULL, am_valor numeric(18,2) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_Pasajeros (
		id INT GENERATED ALWAYS AS IDENTITY, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, ds_tkt_number VARCHAR(10) NOT NULL, ds_pax_firstnm CHAR (30) NULL, ds_pax_lastnm CHAR (30) NULL,
		ds_pax_prefix CHAR (3) NULL, cd_pax_cedula VARCHAR (15) NULL, ds_pax_telefono VARCHAR (15) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_FEE (
		id INT GENERATED ALWAYS AS IDENTITY, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_conceptofac VARCHAR(13) NOT NULL, cd_subcodigo VARCHAR(13) NULL, am_valor numeric(18,2) NOT NULL, ds_servicio VARCHAR(8000) NULL 
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_VariablesAdicionales (
		id INT GENERATED ALWAYS AS IDENTITY, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, ds_nombre VARCHAR(20) NOT NULL, ds_valor VARCHAR(8000) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_CargosImpuestos (
		id INT GENERATED ALWAYS AS IDENTITY, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, cd_codigo VARCHAR(3) NOT NULL, ds_nombre VARCHAR(50) NOT NULL, cd_tipo VARCHAR(1) NOT NULL,
		cd_codigopadre VARCHAR(3) NULL, cd_tipopadre VARCHAR(1) NULL, am_porcentaje numeric(18,2) NULL, am_contado numeric(18,2) NOT NULL,
		am_credito numeric(18,2) NOT NULL, am_valor numeric(18,2) NOT NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_ValoresItems (
		id INT GENERATED ALWAYS AS IDENTITY, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL, cd_tipoitem VARCHAR(25) NULL,
		am_tarifa numeric(18,2) NOT NULL, am_iva numeric(18,2) NOT NULL, am_cmb numeric(18,2) NOT NULL, am_tua numeric(18,2) NOT NULL,
		am_otros numeric(18,2) NOT NULL, am_total numeric(18,2) NOT NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_FormasPagos (
		id INT GENERATED ALWAYS AS IDENTITY, in_orden INT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, cd_codigo VARCHAR(50) NOT NULL, ds_nombre VARCHAR(50) NOT NULL, cd_tipotarjeta VARCHAR(2) NULL,
		ds_numerotarjeta VARCHAR(16) NULL, ds_vouchertarjeta VARCHAR(25) NULL, ds_expiraciontarjeta VARCHAR(5) NULL, ds_autorizaciontarjeta VARCHAR(25) NULL,
		in_coutas INT NULL, cd_banco VARCHAR(3) NULL, ds_cheque VARCHAR(30) NULL, ds_plaza VARCHAR(30) NULL, ds_referencia VARCHAR(50) NULL,
		ds_Poliza VARCHAR(20) NULL, ds_PolizaAnexo VARCHAR(20) NULL, am_valor numeric(18,2) NOT NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_Valores (
		id INT GENERATED ALWAYS AS IDENTITY, in_orden INT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, ds_segmento VARCHAR(20) NOT NULL, ds_nombre VARCHAR(20) NOT NULL, am_valor numeric(18,2) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_EntidadesNOGDS(
		id INT GENERATED ALWAYS AS IDENTITY, id_entidad INT NOT NULL, cd_entidad VARCHAR(3) NOT NULL, cd_siglas VARCHAR(4) NOT NULL, ds_Alias VARCHAR(128)
	) ON COMMIT DROP;

	v_cd_interfaces = 'IdeasFractal'
			SELECT v_id_interfaces = id FROM public."Interfaces" WHERE code = v_cd_interfaces
			SELECT v_am_poriva = COALESCE(value,1) FROM public."ChargeAndTax" WHERE code = 'IVA'
			SELECT v_Pais = COALESCE(value,'Colombia') FROM public."SystemParameter" WHERE code='Pais'
			SELECT v_cd_conceptohotel='SOP'--COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			SELECT v_cd_conceptocarrental='RTA'--COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			SELECT v_cd_conceptoseguro=''--COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			SELECT v_cd_tiposrhotel='HTL'--COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			SELECT v_cd_tiposrcarrental=''--COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			SELECT v_cd_tiposrseguro=''--COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			--SELECT v_cd_conceptohotel = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			--SELECT v_cd_conceptocarrental = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			--SELECT v_cd_tiposrhotel = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			--SELECT v_cd_tiposrcarrental = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			/*SELECT v_cd_sucursal = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_cd_implante = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_cd_concepto = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_cd_tiposrv = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_cd_conceptoutl = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_cd_tiposrvutl = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_in_refecliente = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
				  ,v_in_refevendedor = COALESCE(value,'') FROM public."SystemParameter" WHERE code=''
			*/
			SELECT v_cd_sucursal=REPLACE(REPLACE(R.Booking.value('(EntityBook/codeEntity)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),'')
				  ,v_cd_implante=REPLACE(REPLACE(R.Booking.value('(EntityBook/codeEntity)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),'') 	
			FROM @NodoXML.nodes('//Books/Book') As R(Booking)
			
			SELECT v_bl_IncluirCombaTarifa =rtrim(Valor) From dbo.Parametros Where Id = 419 
			SELECT v_bl_SumarCombustibleTarifaTkt =rtrim(Valor) From dbo.Parametros Where Id = 568 

			INSERT INTO tmp_EntidadesNOGDS(id_entidad,	cd_entidad,	cd_siglas, ds_Alias)
			SELECT id_entidad=id, cd_entidad=cd_codigo, cd_siglas=cd_siglas, ds_Alias=ds_Alias 
			FROM dbo.Entidades WITH(NOLOCK) WHERE bl_nogds=1
			
			INSERT INTO tmp_Booking (OpBookingGDS, ds_tipoitem, cd_tipoitem, cd_sucursal, cd_implante, bl_externo, id_reserva, iden_gds, cd_codigo, ds_fecha, cd_tiqueteador, cd_vendedor, cd_cliente, booking, cd_TipoTransaccion, ds_pax_number, ds_pax_firstnm, ds_pax_lastnm, ds_pax_prefix, cd_pax_cedula, ds_pax_telefono, ds_tkt_number, ds_tkt_prefix, ds_aero_code, ds_moneda, am_tarifa, am_iva, am_tua, am_vat, ds_cc_code, ds_cc_number, cd_farebasis, cd_aero_siglas, cd_aero_salida, cd_aero_llegada, orden, ds_fecha_salida, ds_hora_salida, ds_hora_llegada, cd_clase, am_highfare, am_lowfare, am_fare, ds_reasoncode, ds_cliname, ds_clidir, ds_clicity, ds_cliid, ds_clirazoncial, ds_cliname2, ds_clilastname, ds_clilastname2, ds_clitel, cd_clipais, cd_clitipodoc, cd_clitipotercero, cd_CentroCostoCliente, am_comb, am_tao, am_ivatao, am_cap, am_ivacap, ds_cc_code2, ds_cc_number2, am_fp1, am_fp2, dt_entrega, in_cars, cd_carcode, cd_confirmation, cd_citysalida, dt_retorno, cd_cartype, cd_currency, cd_bookingsource, cd_ratecode, am_tarifarenta, dt_checkin, in_guests, cd_city, cd_htlchain, dt_checkout, ds_htlname, in_habs, cd_bed, cd_htlcur, am_htltarifa, cd_agcur, am_agtarifa, ds_dir1, ds_tel, ds_fax, cd_conceptofacturacion, cd_TipoServicio, cd_Proveedores, ds_Descrip, cd_tktrevisado, ds_itinerario, ds_clases, in_nacionalidad, am_TarifaContado, am_IvaContado, am_OtrosContado, am_TarifaCredito, am_IvaCredito, am_OtrosCredito, am_Comision, ds_Observaciones, ds_ClienteEmail, bl_ClienteActualizar, bl_NotificacionMPD, cd_NumeroPoliza, cd_AnexoPoliza, am_ValorPoliza, cd_FormaPagoTAO, cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, cd_VencimientoTarjetaTAO, cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, am_PorDesFormaPagoTA, ds_NumVuelo, ds_TipoVuelo, cd_Penalidad, am_TasaCambio, ds_cc_vence, ds_cc_vence2, ds_cc_autorizacion, ds_cc_autorizacion2, ds_cc_voucher, ds_cc_voucher2, ds_AutorizacionTarjetaTAO, ds_VoucherTarjetaTAO, am_fptao, in_cc_cuotas, in_cc_cuotas2, in_cuotasTarjetaTAO, in_NumTktConj, cd_TipoTarifaTAO, cd_TipoTiquete, PCC, PCC_Emite, bl_ahorro, in_CantidadTarifaTAO, in_CantidadSegmentoTAO, cd_tourcode, ds_contrato, am_valor, cd_tourcode2, cd_Ahorro, cd_consecutivo, cd_auxiliar, cd_tipoventa, cd_licitacion, ds_evento, ds_campolibre1, ds_campolibre2, cd_facturador, cd_especialista, cd_tipoformapagoproveedor, cd_medioreservacion, pasajeros, am_utl, am_TasaCambioutl, cd_conceptofacturacionutl, cd_TipoServicioutl, ds_Descriputl, reservaxml)
			SELECT	 OpBookingGDS				='Crear'--VARCHAR(15)
					,ds_tipoitem				='Tiquete'--VARCHAR(15)
					,cd_tipoitem				='Flight'--VARCHAR(25)
					,cd_sucursal				= v_cd_sucursal--CHAR(5) 
					,cd_implante				= v_cd_implante--CHAR(5) 
					,bl_externo					=0--boolean
					,id_reserva					=REPLACE(REPLACE(R.Bookings.value('(../../transactionCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--INT 
					,iden_gds					=8--INT
					,cd_codigo					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --CHAR(6)
					,ds_fecha					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateBook)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,cd_tiqueteador				='KT'--REPLACE(REPLACE(R.Bookings.value('(userOrigin)[1]','VARCHAR(6)'),CHR(9),''),CHR(10),'')--CHAR(6)
					,cd_vendedor				=REPLACE(REPLACE(R.Bookings.value('(../../UserBook/codeUser)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --CHAR(3)
					,cd_cliente					=REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/AgencyCodeClient)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --VARCHAR(25)
					,booking					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--'<![CDATA['+p_XML+']]>'--VARCHAR(MAX)
					,cd_TipoTransaccion			='1'--CHAR(1) 
					,ds_pax_number				=1--COALESCE(R.Bookings.value('(Paxes/Paxe/paxtype)[1]','INT'),0) -- --smallint
					,ds_pax_firstnm				=pasajeros.ds_pax_firstnm--REPLACE(REPLACE(p.Pasajeros.value('(name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_lastnm				=pasajeros.ds_pax_lastnm--REPLACE(REPLACE(p.Pasajeros.value('(lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_prefix				=pasajeros.ds_pax_prefix--REPLACE(REPLACE(p.Pasajeros.value('(paxtype)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_pax_cedula				=pasajeros.cd_pax_cedula--REPLACE(REPLACE(p.Pasajeros.value('(identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_pax_telefono			=pasajeros.ds_pax_telefono--REPLACE(REPLACE(p.Pasajeros.value('(phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_tkt_number				=pasajeros.ds_tkt_number--RIGHT(REPLACE(REPLACE(p.Pasajeros.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
					,ds_tkt_prefix				=pasajeros.ds_tkt_prefix--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/numericalCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--LEFT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Paxe/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),3)--CHAR(3)
					,ds_aero_code				=pasajeros.ds_aero_code--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,ds_moneda					=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/fare/localCurrency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,am_tarifa					=COALESCE(R.Bookings.value('(Paxes/Pax/fare/localfare)[1]','NUMERIC(18,2)'),0)--NUMERIC(18,2)
					,am_iva						=0--NUMERIC(18,2)
					,am_tua						=0--NUMERIC(18,2)
					,am_vat						=0--NUMERIC(18,2)
					,ds_cc_code					=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),'') ELSE '' END--CHAR(2) --no se sabe
					,ds_cc_number				=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),CHR(9),''),CHR(10),'') ELSE '' END --CHAR(16) --no se sabe
					--Fare Basis (M4)
					,cd_farebasis				=''--VARCHAR(25)
					--detalle itinerario
					,cd_aero_siglas				=pasajeros.cd_aero_siglas--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_aero_salida				=LEFT(REPLACE(REPLACE(R.Bookings.value('(route)[1]','VARCHAR(64)'),CHR(9),''),CHR(10),''),3)--CHAR(3)
					,cd_aero_llegada			=RIGHT(REPLACE(REPLACE(R.Bookings.value('(route)[1]','VARCHAR(64)'),CHR(9),''),CHR(10),''),3)--CHAR(3)
					,orden						=0--INT
					,ds_fecha_salida			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(segments/segment/DepartureDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8)
					,ds_hora_salida				=RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(segments/segment/DepartureDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,ds_hora_llegada			=RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(segments/segment/ArrivalDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,cd_clase					=''--CHAR(2)
					--Informacion de ahorro
					,am_highfare				=COALESCE(R.Bookings.value('(Paxes/Pax/fare/maxfare)[1]','numeric(18,2)'),0)--numeric(18,2)
					,am_lowfare					=COALESCE(R.Bookings.value('(Paxes/Pax/fare/minFare)[1]','numeric(18,2)'),0)--numeric(18,2)
					,am_fare					=COALESCE(R.Bookings.value('(Paxes/Pax/fare/publicfare)[1]','numeric(18,2)'),0)--numeric(18,2)
					,ds_reasoncode				=''--CHAR(2)
					--Informacion de nuevo cliente
					,ds_cliname					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clidir					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/address)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clicity					='' --VARCHAR (50)
					,ds_cliid					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --CHAR (25)
					,ds_clirazoncial			=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),''),'')--VARCHAR (250)
					,ds_cliname2				=''--VARCHAR (60)
					,ds_clilastname				=''--VARCHAR (60)
					,ds_clilastname2			=''--VARCHAR (60)
					,ds_clitel					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/phone)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')--VARCHAR (25)
					,cd_clipais					=''--VARCHAR (25)
					,cd_clitipodoc				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentType)[1]','VARCHAR(100)'),CHR(9),''),CHR(10),''),'')--VARCHAR (100)
					,cd_clitipotercero			=''--CHAR (1)
					,cd_CentroCostoCliente		=''--VARCHAR(50)
					--Inormacion adicional del tiquete
					,am_comb					=0--numeric(18,2)
					,am_tao						=0--numeric(18,2)
					,am_ivatao					=0--numeric(18,2) 
					,am_cap						=0--numeric(18,2)
					,am_ivacap					=0--numeric(18,2)
					,ds_cc_code2				=''--CHAR(2) 
					,ds_cc_number2				=''--VARCHAR(16) 
					,am_fp1						=pasajeros.am_tkt_total--COALESCE(R.Bookings.value('(Paxes/Pax/fare/totalTicket)[1]','numeric(18,2)'),0)--numeric(18,2)
					,am_fp2						=0--numeric(18,2)
					--Informacion  de renta de Autos
					,dt_entrega					=''--LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkOut)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(17)
					,in_cars					=0--smallint 
					,cd_carcode					=''--CHAR(2)
					,cd_confirmation			=''--VARCHAR(16)
					,cd_citysalida				=''--CHAR(3) 
					,dt_retorno					=''--CHAR(17)  
					,cd_cartype					=''--VARCHAR(20)
					,cd_currency				=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/fare/localCurrency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_bookingsource			=''--VARCHAR(20) 
					,cd_ratecode				=''--VARCHR(10) 
					,am_tarifarenta				=0--numeric(18,2) 
					--Informaciion de hotel
					,dt_checkin					=''--LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkIn)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8) --CHAR(8)
					,in_guests					=0--COALESCE(R.Bookings.value('(rooms/adults)[1]','INT'),0)+COALESCE(R.Bookings.value('(rooms/children)[1]','INT'),0)--smallint 
					,cd_city					=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(city/id)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,cd_htlchain				=''--CHAR(2)
					,dt_checkout				=''--LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkOut)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,ds_htlname					=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(product/supplier/name)[1]','VARCHAR(32)'),CHR(9),''),CHR(10),''),'')--VARCHAR(32) 
					,in_habs					=0--COALESCE(R.Bookings.value('(rooms/id)[1]','INT'),0)--smallint 
					,cd_bed						=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(product/supplier/code)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,cd_htlcur					=''--REPLACE(REPLACE(R.Bookings.value('(price/currency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3) 
					,am_htltarifa				=0--COALESCE(R.Bookings.value('(rooms/price/sale)[1]','NUMERIC(18,2)'),0)--numeric(18,2) 
					,cd_agcur					=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(price/currency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,am_agtarifa				=0--numeric(18,2) 
					,ds_dir1					=''--VARCHAR(50) 
					,ds_tel						=''--VARCHAR(12) 
					,ds_fax						=''--VAR+CHAR(12)
					--Informacion de servicios de terceros
					,cd_conceptofacturacion		=''--REPLACE(REPLACE(R.Bookings.value('(type)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--CHAR(3) 
					,cd_TipoServicio			=''--LEFT(REPLACE(REPLACE(R.Bookings.value('(rooms/code)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),3)--CHAR(3) 
					,cd_Proveedores				=''--CASE WHEN REPLACE(REPLACE(R.Bookings.value('(product/supplier/code)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')<>'' THEN REPLACE(REPLACE(R.Bookings.value('(product/supplier/code)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  WHEN REPLACE(REPLACE(R.Bookings.value('(product/code)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')='' THEN REPLACE(REPLACE(R.Bookings.value('(product/supplier/product)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') ELSE REPLACE(REPLACE(R.Bookings.value('(product/code)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') END--VARCHAR(25)  --rgelis req.227718
					,ds_Descrip					=''--REPLACE(REPLACE(R.Bookings.value('(product/name)[1]','VARCHAR(500)'),CHR(9),''),CHR(10),'')--VARCHAR(500)
					--+' desde: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkIn)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--+' hasta: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkOut)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--Tkt revisado
					,cd_tktrevisado				=''--CHAR(14)
					--Itinerario y clases
					,ds_itinerario				=REPLACE(REPLACE(R.Bookings.value('(route)[1]','VARCHAR(64)'),CHR(9),''),CHR(10),'')--VARCHAR(64)
					,ds_clases					=''--VARCHAR(36)
					,in_nacionalidad			=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(inter)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),''),'')='SI' THEN 2 ELSE 1 END--CASE WHEN REPLACE(REPLACE(R.Bookings.value('(city/countryName)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'') <> v_Pais THEN 2 ELSE 1 END --smallint
					--Valores a credito y de contado
					,am_TarifaContado			=0--COALESCE(R.Bookings.value('(price/sale)[1]','numeric(18,2)'),0) --REPLACE(REPLACE(R.Bookings.value('(price/sale)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --numeric(18,2)
					,am_IvaContado				=0--numeric(18,2)
					,am_OtrosContado			=0--numeric(18,2)
					,am_TarifaCredito			=0--numeric(18,2)
					,am_IvaCredito				=0--numeric(18,2)
					,am_OtrosCredito			=0--numeric(18,2)
					--Comision del tiquete
					,am_Comision				=0--numeric(18,2)
					,ds_Observaciones			=''--VARCHAR(8000)
					,ds_ClienteEmail			=''--VARCHAR(100)
					,bl_ClienteActualizar		=0--boolean
					,bl_NotificacionMPD			=0--boolean
					,cd_NumeroPoliza			=''--VARCHAR(50)
					,cd_AnexoPoliza				=''--VARCHAR(50)
					,am_ValorPoliza				=0--numeric(18,2)
					,cd_FormaPagoTAO			=''--CHAR(3)
					,cd_TarjetaCreditoTAO		=''--CHAR(2)
					,cd_NumeroTarjetaTAO		=''--CHAR(16)
					,cd_VencimientoTarjetaTAO	=''--CHAR(5)
					,cd_NumeroPolizaTAO			=''--VARCHAR(50)
					,cd_AnexoPolizaTAO			=''--VARCHAR(50)
					,am_PorDesFormaPagoTA		=0--NUMERIC(8,4) 
					,ds_NumVuelo				=''--VARCHAR(25) 
					,ds_TipoVuelo				=''--CHAR(1) 
					,cd_Penalidad				=''--CHAR(14)
					,am_TasaCambio				= COALESCE(R.Bookings.value('(Paxes/Pax/fare/ExchangeRate)[1]','numeric(18,2)'),0)--numeric(18,2)  -- falta no se sabe donde esta 
					,ds_cc_vence				=''--CHAR(5) 
					,ds_cc_vence2				=''--CHAR(5) 
					,ds_cc_autorizacion			=''--VARCHAR(25)
					,ds_cc_autorizacion2		=''--VARCHAR(25)
					,ds_cc_voucher				=''--VARCHR(10)
					,ds_cc_voucher2				=''--VARCHR(10)
					,ds_AutorizacionTarjetaTAO	=''--VARCHAR(25)
					,ds_VoucherTarjetaTAO		=''--VARCHR(10)
					,am_fptao					=0--numeric(18,2) 
					,in_cc_cuotas				=0--INT 
					,in_cc_cuotas2				=0--INT 
					,in_cuotasTarjetaTAO		=0--INT 
					,in_NumTktConj				=0--INT  
					,cd_TipoTarifaTAO			=''--VARCHAR(25) 
					,cd_TipoTiquete				=''--CHAR(3) 
					,PCC						=''--VARCHAR(5) 
					,PCC_Emite					=''--VARCHAR(5) 
					,bl_ahorro					=0--boolean 
					,in_CantidadTarifaTAO		=0--INT 
					,in_CantidadSegmentoTAO		=0--INT 
					,cd_tourcode				=REPLACE(REPLACE(R.Bookings.value('(tourcode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25) 
					,ds_contrato				=''--VARCHAR(25) 
					,am_valor					=0--numeric(18,2) 
					,cd_tourcode2				=''--VARCHAR(25) 
					,cd_Ahorro					=''--VARCHAR(25) 
					,cd_consecutivo				= pasajeros.ds_tkt_number --REPLACE(REPLACE(R.Bookings.value('(locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25)
					,cd_auxiliar				=''--VARCHAR(16)
					--Variables Nuevas para la cabecera del documento.
					,cd_tipoventa				=''--Varchar(16)
					,cd_licitacion				=''--Varchar(25)
					,ds_evento					=''--Varchar(250)
					,ds_campolibre1				=''--Varchar(500)
					,ds_campolibre2				=''--Varchar(500)
					,cd_facturador				=''--Varchar(3)
					,cd_especialista			=''--Varchar(25)
					,cd_tipoformapagoproveedor	=''--Varchar(25)
					,cd_medioreservacion		=''--Varchar(25)
					,pasajeros					=''--varchar(max)
					,am_utl						= 0--COALESCE(R.Bookings.value('(liquidation/segment/fields/value)[1]','numeric(18,2)'),0) --numeric(18,2)
					,am_TasaCambioutl			= 1 --numeric(18,2)
					,cd_conceptofacturacionutl	= ''--v_cd_conceptoutl --REPLACE(REPLACE(R.Bookings.value('(configuration/fields/type)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --CHAR(3) 
					,cd_TipoServicioutl			= ''--v_cd_tiposrvutl--CHAR(3)
					,ds_Descriputl				=''--REPLACE(REPLACE(R.Bookings.value('(configuration/label)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(500)  
					,reservaxml					= '<![CDATA['+p_XML+']]>'
			FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight') As R(Bookings) 
				cross JOIN (SELECT	 in_orden			= COALESCE(R.Bookings.value('(ticketNumber)[1]','BIGINT'),0) --BIGINT 
							,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
							,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
							,cd_tipoitem		= 'Flight'--VARCHAR(25)
							,ds_tkt_number		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
							,ds_pax_firstnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
							,ds_pax_lastnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
							,ds_pax_prefix		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(paxtype)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
							,cd_pax_cedula		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')--VARCHAR(15) 
							,ds_pax_telefono	= COALESCE(REPLACE(REPLACE(R.Bookings.value('(phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')
							,am_tkt_total		= COALESCE(R.Bookings.value('(fare/totalTicket)[1]','numeric(18,2)'),0)
							,cd_aero_siglas		=REPLACE(REPLACE(R.Bookings.value('(../../airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
							,ds_tkt_prefix		=REPLACE(REPLACE(R.Bookings.value('(../../airCompanyIssue/numericalCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')
							,ds_aero_code		=REPLACE(REPLACE(R.Bookings.value('(../../airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHA
					FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax') As R(Bookings)
				) As pasajeros
			UNION ALL

			SELECT	 OpBookingGDS				='Crear'--VARCHAR(15)
					,ds_tipoitem				='Servicio'--VARCHAR(15)
					,cd_tipoitem				='Hotel'--VARCHAR(25)
					,cd_sucursal				= v_cd_sucursal--CHAR(5) 
					,cd_implante				= v_cd_implante--CHAR(5) 
					,bl_externo					=0--boolean
					,id_reserva					=REPLACE(REPLACE(R.Bookings.value('(../../transactionCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--INT 
					,iden_gds					=8--INT
					,cd_codigo					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --CHAR(6)
					,ds_fecha					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateBook)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,cd_tiqueteador				=REPLACE(REPLACE(R.Bookings.value('(CodProvideBackoffice)[1]','VARCHAR(6)'),CHR(9),''),CHR(10),'')--CHAR(6)
					,cd_vendedor				=REPLACE(REPLACE(R.Bookings.value('(../../UserBook/codeUser)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --CHAR(3)
					,cd_cliente					=REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --VARCHAR(25)
					,booking					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--'<![CDATA['+p_XML+']]>'--VARCHAR(MAX)
					,cd_TipoTransaccion			='1'--CHAR(1) 
					,ds_pax_number				=COALESCE(R.Bookings.value('(rooms/rooms/totalPax)[1]','INT'),0) -- --smallint
					,ds_pax_firstnm				=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_lastnm				=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_prefix				=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/paxtype)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_pax_cedula				=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_pax_telefono			=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_tkt_number				=RIGHT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
					,ds_tkt_prefix				=REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/numericalCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--LEFT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Paxe/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),3)--CHAR(3)
					,ds_aero_code				=REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,ds_moneda					=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/fare/localCurrency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,am_tarifa					=COALESCE(R.Bookings.value('(Paxes/Pax/fare/localfare)[1]','NUMERIC(18,2)'),0)--NUMERIC(18,2)
					,am_iva						=0--NUMERIC(18,2)
					,am_tua						=0--NUMERIC(18,2)
					,am_vat						=0--NUMERIC(18,2)
					,ds_cc_code					=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Payments/Payment/creditCardInfoflag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),'') ELSE '' END--CHAR(2) --no se sabe
					,ds_cc_number				=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Payments/Payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),CHR(9),''),CHR(10),'') ELSE '' END --CHAR(16) --no se sabe
					--Fare Basis (M4)
					,cd_farebasis				=''--VARCHAR(25)
					--detalle itinerario
					,cd_aero_siglas				=''--CHAR(3)
					,cd_aero_salida				=''--CHAR(3)
					,cd_aero_llegada			=''--CHAR(3)
					,orden						=0--INT
					,ds_fecha_salida			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/dateCheckout)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8)
					,ds_hora_salida				=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/timeCheckout)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,ds_hora_llegada			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/timeCheckin)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,cd_clase					=''--CHAR(2)
					--Informacion de ahorro
					,am_highfare				=0--numeric(18,2)
					,am_lowfare					=0--numeric(18,2)
					,am_fare					=0--numeric(18,2)
					,ds_reasoncode				=''--CHAR(2)
					--Informacion de nuevo cliente
					,ds_cliname					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clidir					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/address)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clicity					='' --VARCHAR (50)
					,ds_cliid					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --CHAR (25)
					,ds_clirazoncial			=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),''),'')--VARCHAR (250)
					,ds_cliname2				=''--VARCHAR (60)
					,ds_clilastname				=''--VARCHAR (60)
					,ds_clilastname2			=''--VARCHAR (60)
					,ds_clitel					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/phone)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')--VARCHAR (25)
					,cd_clipais					=''--VARCHAR (25)
					,cd_clitipodoc				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentType)[1]','VARCHAR(100)'),CHR(9),''),CHR(10),''),'')--VARCHAR (100)
					,cd_clitipotercero			=''--CHAR (1)
					,cd_CentroCostoCliente		=''--VARCHAR(50)
					--Inormacion adicional del tiquete
					,am_comb					=0--numeric(18,2)
					,am_tao						=0--numeric(18,2)
					,am_ivatao					=0--numeric(18,2) 
					,am_cap						=0--numeric(18,2)
					,am_ivacap					=0--numeric(18,2)
					,ds_cc_code2				=''--CHAR(2) 
					,ds_cc_number2				=''--VARCHAR(16) 
					,am_fp1						=0--COALESCE(R.Bookings.value('(price/sale)[1]','numeric(18,2)'),0)--numeric(18,2)
					,am_fp2						=0--numeric(18,2)
					--Informacion  de renta de Autos
					,dt_entrega					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/dateCheckout)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(17)
					,in_cars					=0--smallint 
					,cd_carcode					=''--CHAR(2)
					,cd_confirmation			=''--VARCHAR(16)
					,cd_citysalida				=''--CHAR(3) 
					,dt_retorno					=''--CHAR(17)  
					,cd_cartype					=''--VARCHAR(20)
					,cd_currency				=REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/fare/localCurrency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_bookingsource			=''--VARCHAR(20) 
					,cd_ratecode				=''--VARCHR(10) 
					,am_tarifarenta				=0--numeric(18,2) 
					--Informaciion de hotel
					,dt_checkin					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/dateCheckin)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8) --CHAR(8)
					,in_guests					=COALESCE(R.Bookings.value('(InfoBook/rooms/room/numAdt)[1]','INT'),0)+COALESCE(R.Bookings.value('(InfoBook/rooms/room/numCHD)[1]','INT'),0)--smallint 
					,cd_city					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/Hotelcity)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,cd_htlchain				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/codeIataChain)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')--CHAR(2)
					,dt_checkout				=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/dateCheckout)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,ds_htlname					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/hotelName)[1]','VARCHAR(32)'),CHR(9),''),CHR(10),''),'')--VARCHAR(32) 
					,in_habs					=COALESCE(R.Bookings.value('(InfoBook/rooms/room//numAdt/numCHD)[1]','INT'),0)--smallint 
					,cd_bed						=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/rooms/room/roomType)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,cd_htlcur					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/fareHotel/totalSellFare/OriginalCurrency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,am_htltarifa				=COALESCE(R.Bookings.value('(InfoBook/rooms/room/fareRoom/totalSellFare)[1]','NUMERIC(18,2)'),0)--numeric(18,2) 
					,cd_agcur					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/fareHotel/totalSellFare/OriginalCurrency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,am_agtarifa				=0--numeric(18,2) 
					,ds_dir1					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/addressHotel)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),''),'')--VARCHAR(50) 
					,ds_tel						=COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/phoneHotel)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),''),'')--VARCHAR(12) 
					,ds_fax						=''--VAR+CHAR(12)
					--Informacion de servicios de terceros
					,cd_conceptofacturacion		=v_cd_conceptohotel--REPLACE(REPLACE(R.Bookings.value('(AgreementCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--CHAR(3) 
					,cd_TipoServicio			=v_cd_tiposrhotel--LEFT(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/codeHotel)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),3)--CHAR(3) 
					,cd_Proveedores				=CASE WHEN REPLACE(REPLACE(R.Bookings.value('(CodProvideBackoffice)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')<>'' THEN REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/fiscalID)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  WHEN REPLACE(REPLACE(R.Bookings.value('(bookInfoHotels/bookInfoHotel/AditionalLoc)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')='' THEN REPLACE(REPLACE(R.Bookings.value('(product/supplier/product)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') ELSE REPLACE(REPLACE(R.Bookings.value('(bookInfoHotels/bookInfoHotel/CodProvideBackoffice)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') END--VARCHAR(25)  --rgelis req.227718
					,ds_Descrip					=REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/facilities)[1]','VARCHAR(500)'),CHR(9),''),CHR(10),'')--VARCHAR(500)
					--+' desde: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkIn)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--+' hasta: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkOut)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--Tkt revisado
					,cd_tktrevisado				=''--CHAR(14)
					--Itinerario y clases
					,ds_itinerario				=''--VARCHAR(64)
					,ds_clases					=''--VARCHAR(36)
					,in_nacionalidad			=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(InfoBook/CountryHotel)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')<>'CO' THEN 2 ELSE 1 END--CASE WHEN REPLACE(REPLACE(R.Bookings.value('(city/countryName)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'') <> v_Pais THEN 2 ELSE 1 END --smallint
					--Valores a credito y de contado
					,am_TarifaContado			=0--COALESCE(R.Bookings.value('(price/sale)[1]','numeric(18,2)'),0) --REPLACE(REPLACE(R.Bookings.value('(price/sale)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --numeric(18,2)
					,am_IvaContado				=0--numeric(18,2)
					,am_OtrosContado			=0--numeric(18,2)
					,am_TarifaCredito			=0--numeric(18,2)
					,am_IvaCredito				=0--numeric(18,2)
					,am_OtrosCredito			=0--numeric(18,2)
					--Comision del tiquete
					,am_Comision				=0--numeric(18,2)
					,ds_Observaciones			=''--VARCHAR(8000)
					,ds_ClienteEmail			=''--VARCHAR(100)
					,bl_ClienteActualizar		=0--boolean
					,bl_NotificacionMPD			=0--boolean
					,cd_NumeroPoliza			=''--VARCHAR(50)
					,cd_AnexoPoliza				=''--VARCHAR(50)
					,am_ValorPoliza				=0--numeric(18,2)
					,cd_FormaPagoTAO			=''--CHAR(3)
					,cd_TarjetaCreditoTAO		=''--CHAR(2)
					,cd_NumeroTarjetaTAO		=''--CHAR(16)
					,cd_VencimientoTarjetaTAO	=''--CHAR(5)
					,cd_NumeroPolizaTAO			=''--VARCHAR(50)
					,cd_AnexoPolizaTAO			=''--VARCHAR(50)
					,am_PorDesFormaPagoTA		=0--NUMERIC(8,4) 
					,ds_NumVuelo				=''--VARCHAR(25) 
					,ds_TipoVuelo				=''--CHAR(1) 
					,cd_Penalidad				=''--CHAR(14)
					,am_TasaCambio				= COALESCE(R.Bookings.value('(InfoBook/fareHotel/ExchangeRate)[1]','numeric(18,2)'),0)--numeric(18,2)  -- falta no se sabe donde esta 
					,ds_cc_vence				=''--CHAR(5) 
					,ds_cc_vence2				=''--CHAR(5) 
					,ds_cc_autorizacion			=''--VARCHAR(25)
					,ds_cc_autorizacion2		=''--VARCHAR(25)
					,ds_cc_voucher				=''--VARCHR(10)
					,ds_cc_voucher2				=''--VARCHR(10)
					,ds_AutorizacionTarjetaTAO	=''--VARCHAR(25)
					,ds_VoucherTarjetaTAO		=''--VARCHR(10)
					,am_fptao					=0--numeric(18,2) 
					,in_cc_cuotas				=0--INT 
					,in_cc_cuotas2				=0--INT 
					,in_cuotasTarjetaTAO		=0--INT 
					,in_NumTktConj				=0--INT  
					,cd_TipoTarifaTAO			=''--VARCHAR(25) 
					,cd_TipoTiquete				=''--CHAR(3) 
					,PCC						=''--VARCHAR(5) 
					,PCC_Emite					=''--VARCHAR(5) 
					,bl_ahorro					=0--boolean 
					,in_CantidadTarifaTAO		=0--INT 
					,in_CantidadSegmentoTAO		=0--INT 
					,cd_tourcode				=REPLACE(REPLACE(R.Bookings.value('(tourcode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25) 
					,ds_contrato				=''--VARCHAR(25) 
					,am_valor					=0--numeric(18,2) 
					,cd_tourcode2				=''--VARCHAR(25) 
					,cd_Ahorro					=''--VARCHAR(25) 
					,cd_consecutivo				=REPLACE(REPLACE(R.Bookings.value('(locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25)
					,cd_auxiliar				=''--VARCHAR(16)
					--Variables Nuevas para la cabecera del documento.
					,cd_tipoventa				=''--Varchar(16)
					,cd_licitacion				=''--Varchar(25)
					,ds_evento					=''--Varchar(250)
					,ds_campolibre1				=''--Varchar(500)
					,ds_campolibre2				=''--Varchar(500)
					,cd_facturador				=''--Varchar(3)
					,cd_especialista			=''--Varchar(25)
					,cd_tipoformapagoproveedor	=''--Varchar(25)
					,cd_medioreservacion		=''--Varchar(25)
					,pasajeros					=''--varchar(max)
					,am_utl						= 0--COALESCE(R.Bookings.value('(liquidation/segment/fields/value)[1]','numeric(18,2)'),0) --numeric(18,2)
					,am_TasaCambioutl			= 1 --numeric(18,2)
					,cd_conceptofacturacionutl	= ''--v_cd_conceptoutl --REPLACE(REPLACE(R.Bookings.value('(configuration/fields/type)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --CHAR(3) 
					,cd_TipoServicioutl			= ''--v_cd_tiposrvutl--CHAR(3)
					,ds_Descriputl				=''--REPLACE(REPLACE(R.Bookings.value('(configuration/label)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(500)  
					,reservaxml					= '<![CDATA['+p_XML+']]>'
			FROM @NodoXML.nodes('//Books/Book/bookInfoHotels/bookInfoHotel') As R(Bookings)

			UNION ALL

			SELECT	 OpBookingGDS				='Crear'--VARCHAR(15)
					,ds_tipoitem				='Servicio'--VARCHAR(15)
					,cd_tipoitem				='Car'--VARCHAR(25)
					,cd_sucursal				= v_cd_sucursal--CHAR(5) 
					,cd_implante				= v_cd_implante--CHAR(5) 
					,bl_externo					=0--boolean
					,id_reserva					=REPLACE(REPLACE(R.Bookings.value('(../../transactionCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--INT 
					,iden_gds					=8--INT
					,cd_codigo					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --CHAR(6)
					,ds_fecha					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateBook)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,cd_tiqueteador				=REPLACE(REPLACE(R.Bookings.value('(CodProvideBackoffice)[1]','VARCHAR(6)'),CHR(9),''),CHR(10),'')--CHAR(6)
					,cd_vendedor				=REPLACE(REPLACE(R.Bookings.value('(../../UserBook/codeUser)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --CHAR(3)
					,cd_cliente					=REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --VARCHAR(25)
					,booking					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--'<![CDATA['+p_XML+']]>'--VARCHAR(MAX)
					,cd_TipoTransaccion			='1'--CHAR(1) 
					,ds_pax_number				=1--COALESCE(R.Bookings.value('(Paxes/Paxe/totalPax)[1]','INT'),0) -- --smallint
					,ds_pax_firstnm				=REPLACE(REPLACE(R.Bookings.value('(pax/name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_lastnm				=REPLACE(REPLACE(R.Bookings.value('(pax/lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_prefix				=''--REPLACE(REPLACE(R.Bookings.value('(pax/paxtype)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_pax_cedula				=''--REPLACE(REPLACE(R.Bookings.value('(pax/identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_pax_telefono			=REPLACE(REPLACE(R.Bookings.value('(pax/phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_tkt_number				=''--RIGHT(REPLACE(REPLACE(R.Bookings.value('(Pax/Pax/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
					,ds_tkt_prefix				=''--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/numericalCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--LEFT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Paxe/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),3)--CHAR(3)
					,ds_aero_code				=''--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,ds_moneda					=REPLACE(REPLACE(R.Bookings.value('(fareCar/currencyFare)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,am_tarifa					=COALESCE(R.Bookings.value('(fareCar/totalSellFare)[1]','NUMERIC(18,2)'),0)--NUMERIC(18,2)
					,am_iva						=0--NUMERIC(18,2)
					,am_tua						=0--NUMERIC(18,2)
					,am_vat						=0--NUMERIC(18,2)
					,ds_cc_code					=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Payments/Payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),'') ELSE '' END--CHAR(2) --no se sabe
					,ds_cc_number				=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Payments/Payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),CHR(9),''),CHR(10),'') ELSE '' END --CHAR(16) --no se sabe
					--Fare Basis (M4)
					,cd_farebasis				=''--VARCHAR(25)
					--detalle itinerario
					,cd_aero_siglas				=''--CHAR(3)
					,cd_aero_salida				=''--CHAR(3)
					,cd_aero_llegada			=''--CHAR(3)
					,orden						=0--INT
					,ds_fecha_salida			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(pickUpDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8)
					,ds_hora_salida				=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(pickupTime)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,ds_hora_llegada			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(ReturnTime)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,cd_clase					=''--CHAR(2)
					--Informacion de ahorro
					,am_highfare				=0--numeric(18,2)
					,am_lowfare					=0--numeric(18,2)
					,am_fare					=0--numeric(18,2)
					,ds_reasoncode				=''--CHAR(2)
					--Informacion de nuevo cliente
					,ds_cliname					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clidir					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/address)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clicity					='' --VARCHAR (50)
					,ds_cliid					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --CHAR (25)
					,ds_clirazoncial			=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),''),'')--VARCHAR (250)
					,ds_cliname2				=''--VARCHAR (60)
					,ds_clilastname				=''--VARCHAR (60)
					,ds_clilastname2			=''--VARCHAR (60)
					,ds_clitel					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/phone)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')--VARCHAR (25)
					,cd_clipais					=''--VARCHAR (25)
					,cd_clitipodoc				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentType)[1]','VARCHAR(100)'),CHR(9),''),CHR(10),''),'')--VARCHAR (100)
					,cd_clitipotercero			=''--CHAR (1)
					,cd_CentroCostoCliente		=''--VARCHAR(50)
					--Inormacion adicional del tiquete
					,am_comb					=0--numeric(18,2)
					,am_tao						=0--numeric(18,2)
					,am_ivatao					=0--numeric(18,2) 
					,am_cap						=0--numeric(18,2)
					,am_ivacap					=0--numeric(18,2)
					,ds_cc_code2				=''--CHAR(2) 
					,ds_cc_number2				=''--VARCHAR(16) 
					,am_fp1						=COALESCE(R.Bookings.value('(fareCar/totalSellFare)[1]','numeric(18,2)'),0)--numeric(18,2)
					,am_fp2						=0--numeric(18,2)
					--Informacion  de renta de Autos
					,dt_entrega					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(pickUpDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)+' '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(pickupTime)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(17)
					,in_cars					=1--smallint 
					,cd_carcode					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(IatarentalCar)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')--CHAR(2)
					,cd_confirmation			=REPLACE(REPLACE(R.Bookings.value('(fareCar/paidType)[1]','VARCHAR(16)'),CHR(9),''),CHR(10),'')--VARCHAR(16)
					,cd_citysalida				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(pickupLocation/iataCodePickup)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,dt_retorno					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(DropOffDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)+' '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(ReturnTime)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(17)  
					,cd_cartype					=REPLACE(REPLACE(R.Bookings.value('(fareCar/vehiculeType)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),'')--VARCHAR(20)
					,cd_currency				=REPLACE(REPLACE(R.Bookings.value('(fareCar/currencyFare)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_bookingsource			=''--VARCHAR(20) 
					,cd_ratecode				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(fareCar/rateCode)[1]','VARCHR(10)'),CHR(9),''),CHR(10),''),'')--VARCHR(10) 
					,am_tarifarenta				=COALESCE(R.Bookings.value('(fareCar/totalSellFare)[1]','numeric(18,2)'),0)--numeric(18,2) 
					--Informaciion de hotel
					,dt_checkin					='' --CHAR(8)
					,in_guests					=0--smallint 
					,cd_city					=''--CHAR(3) 
					,cd_htlchain				=''--CHAR(2)
					,dt_checkout				=''--CHAR(8) 
					,ds_htlname					=''--VARCHAR(32) 
					,in_habs					=''--smallint 
					,cd_bed						=''--CHAR(3) 
					,cd_htlcur					=''--CHAR(3) 
					,am_htltarifa				=0--numeric(18,2) 
					,cd_agcur					=''--CHAR(3) 
					,am_agtarifa				=0--numeric(18,2) 
					,ds_dir1					=''--VARCHAR(50) 
					,ds_tel						=''--VARCHAR(12) 
					,ds_fax						=''--VAR+CHAR(12)
					--Informacion de servicios de terceros
					,cd_conceptofacturacion		=v_cd_conceptocarrental--REPLACE(REPLACE(R.Bookings.value('(AgreementCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--CHAR(3) 
					,cd_TipoServicio			=v_cd_tiposrcarrental--LEFT(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/codeHotel)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),3)--CHAR(3) 
					,cd_Proveedores				=CASE WHEN REPLACE(REPLACE(R.Bookings.value('(CodProvideBackoffice)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')<>'' THEN REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/fiscalID)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  WHEN REPLACE(REPLACE(R.Bookings.value('(bookInfoHotels/bookInfoHotel/AditionalLoc)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')='' THEN REPLACE(REPLACE(R.Bookings.value('(product/supplier/product)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') ELSE REPLACE(REPLACE(R.Bookings.value('(bookInfoHotels/bookInfoHotel/CodProvideBackoffice)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') END--VARCHAR(25)  --rgelis req.227718
					,ds_Descrip					=REPLACE(REPLACE(R.Bookings.value('(fareCar/rules)[1]','VARCHAR(500)'),CHR(9),''),CHR(10),'')--VARCHAR(500)
					--+' desde: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkIn)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--+' hasta: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkOut)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--Tkt revisado
					,cd_tktrevisado				=''--CHAR(14)
					--Itinerario y clases
					,ds_itinerario				=''--VARCHAR(64)
					,ds_clases					=''--VARCHAR(36)
					,in_nacionalidad			=2--CASE WHEN REPLACE(REPLACE(R.Bookings.value('(city/countryName)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'') <> v_Pais THEN 2 ELSE 1 END --smallint
					--Valores a credito y de contado
					,am_TarifaContado			=0--COALESCE(R.Bookings.value('(fareCar/totalSellFare)[1]','numeric(18,2)'),0) --REPLACE(REPLACE(R.Bookings.value('(price/sale)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --numeric(18,2)
					,am_IvaContado				=0--numeric(18,2)
					,am_OtrosContado			=0--numeric(18,2)
					,am_TarifaCredito			=0--numeric(18,2)
					,am_IvaCredito				=0--numeric(18,2)
					,am_OtrosCredito			=0--numeric(18,2)
					--Comision del tiquete
					,am_Comision				=0--numeric(18,2)
					,ds_Observaciones			=''--VARCHAR(8000)
					,ds_ClienteEmail			=''--VARCHAR(100)
					,bl_ClienteActualizar		=0--boolean
					,bl_NotificacionMPD			=0--boolean
					,cd_NumeroPoliza			=''--VARCHAR(50)
					,cd_AnexoPoliza				=''--VARCHAR(50)
					,am_ValorPoliza				=0--numeric(18,2)
					,cd_FormaPagoTAO			=''--CHAR(3)
					,cd_TarjetaCreditoTAO		=''--CHAR(2)
					,cd_NumeroTarjetaTAO		=''--CHAR(16)
					,cd_VencimientoTarjetaTAO	=''--CHAR(5)
					,cd_NumeroPolizaTAO			=''--VARCHAR(50)
					,cd_AnexoPolizaTAO			=''--VARCHAR(50)
					,am_PorDesFormaPagoTA		=0--NUMERIC(8,4) 
					,ds_NumVuelo				=''--VARCHAR(25) 
					,ds_TipoVuelo				=''--CHAR(1) 
					,cd_Penalidad				=''--CHAR(14)
					,am_TasaCambio				= COALESCE(R.Bookings.value('(fareCar/ExchangeRate)[1]','numeric(18,2)'),0)--numeric(18,2)  -- falta no se sabe donde esta 
					,ds_cc_vence				=''--CHAR(5) 
					,ds_cc_vence2				=''--CHAR(5) 
					,ds_cc_autorizacion			=''--VARCHAR(25)
					,ds_cc_autorizacion2		=''--VARCHAR(25)
					,ds_cc_voucher				=''--VARCHR(10)
					,ds_cc_voucher2				=''--VARCHR(10)
					,ds_AutorizacionTarjetaTAO	=''--VARCHAR(25)
					,ds_VoucherTarjetaTAO		=''--VARCHR(10)
					,am_fptao					=0--numeric(18,2) 
					,in_cc_cuotas				=0--INT 
					,in_cc_cuotas2				=0--INT 
					,in_cuotasTarjetaTAO		=0--INT 
					,in_NumTktConj				=0--INT  
					,cd_TipoTarifaTAO			=''--VARCHAR(25) 
					,cd_TipoTiquete				=''--CHAR(3) 
					,PCC						=''--VARCHAR(5) 
					,PCC_Emite					=''--VARCHAR(5) 
					,bl_ahorro					=0--boolean 
					,in_CantidadTarifaTAO		=0--INT 
					,in_CantidadSegmentoTAO		=0--INT 
					,cd_tourcode				=REPLACE(REPLACE(R.Bookings.value('(tourcode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25) 
					,ds_contrato				=''--VARCHAR(25) 
					,am_valor					=0--numeric(18,2) 
					,cd_tourcode2				=''--VARCHAR(25) 
					,cd_Ahorro					=''--VARCHAR(25) 
					,cd_consecutivo				=REPLACE(REPLACE(R.Bookings.value('(locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25)
					,cd_auxiliar				=''--VARCHAR(16)
					--Variables Nuevas para la cabecera del documento.
					,cd_tipoventa				=''--Varchar(16)
					,cd_licitacion				=''--Varchar(25)
					,ds_evento					=''--Varchar(250)
					,ds_campolibre1				=''--Varchar(500)
					,ds_campolibre2				=''--Varchar(500)
					,cd_facturador				=''--Varchar(3)
					,cd_especialista			=''--Varchar(25)
					,cd_tipoformapagoproveedor	=''--Varchar(25)
					,cd_medioreservacion		=''--Varchar(25)
					,pasajeros					=''--varchar(max)
					,am_utl						= 0--COALESCE(R.Bookings.value('(liquidation/segment/fields/value)[1]','numeric(18,2)'),0) --numeric(18,2)
					,am_TasaCambioutl			= 1 --numeric(18,2)
					,cd_conceptofacturacionutl	= ''--v_cd_conceptoutl --REPLACE(REPLACE(R.Bookings.value('(configuration/fields/type)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --CHAR(3) 
					,cd_TipoServicioutl			= ''--v_cd_tiposrvutl--CHAR(3)
					,ds_Descriputl				=''--REPLACE(REPLACE(R.Bookings.value('(configuration/label)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(500)  
					,reservaxml					= '<![CDATA['+p_XML+']]>'
			FROM @NodoXML.nodes('//Books/Book/bookCars/bookCar') As R(Bookings)
			
			UNION ALL

			SELECT	 OpBookingGDS				='Crear'--VARCHAR(15)
					,ds_tipoitem				='Servicio'--VARCHAR(15)
					,cd_tipoitem				='Insurance'--VARCHAR(25)
					,cd_sucursal				= v_cd_sucursal--CHAR(5) 
					,cd_implante				= v_cd_implante--CHAR(5) 
					,bl_externo					=0--boolean
					,id_reserva					=REPLACE(REPLACE(R.Bookings.value('(../../transactionCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--INT 
					,iden_gds					=8--INT
					,cd_codigo					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --CHAR(6)
					,ds_fecha					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateBook)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,cd_tiqueteador				=REPLACE(REPLACE(R.Bookings.value('(userOrigin)[1]','VARCHAR(6)'),CHR(9),''),CHR(10),'')--CHAR(6)
					,cd_vendedor				=REPLACE(REPLACE(R.Bookings.value('(../../UserBook/codeUser)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --CHAR(3)
					,cd_cliente					=REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --VARCHAR(25)
					,booking					=REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--'<![CDATA['+p_XML+']]>'--VARCHAR(MAX)
					,cd_TipoTransaccion			='1'--CHAR(1) 
					,ds_pax_number				=1--COALESCE(R.Bookings.value('(Paxes/Paxe/totalPax)[1]','INT'),0) -- --smallint
					,ds_pax_firstnm				=REPLACE(REPLACE(R.Bookings.value('(pax/name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_lastnm				=REPLACE(REPLACE(R.Bookings.value('(pax/lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--VARCHAR(30)
					,ds_pax_prefix				=''--REPLACE(REPLACE(R.Bookings.value('(pax/paxtype)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_pax_cedula				=''--REPLACE(REPLACE(R.Bookings.value('(pax/identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_pax_telefono			=REPLACE(REPLACE(R.Bookings.value('(pax/phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),'')--CHAR(15)
					,ds_tkt_number				=''--RIGHT(REPLACE(REPLACE(R.Bookings.value('(Pax/Pax/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
					,ds_tkt_prefix				=''--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/numericalCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--LEFT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Paxe/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),3)--CHAR(3)
					,ds_aero_code				=''--REPLACE(REPLACE(R.Bookings.value('(airCompanyIssue/iataCode)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,ds_moneda					=REPLACE(REPLACE(R.Bookings.value('(fareInsurance/currency)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,am_tarifa					=COALESCE(R.Bookings.value('(fareInsurance/totalSellFare)[1]','NUMERIC(18,2)'),0)--NUMERIC(18,2)
					,am_iva						=0--NUMERIC(18,2)
					,am_tua						=0--NUMERIC(18,2)
					,am_vat						=0--NUMERIC(18,2)
					,ds_cc_code					=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Payments/Payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/flag)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),'') ELSE '' END--CHAR(2) --no se sabe
					,ds_cc_number				=CASE WHEN COALESCE(REPLACE(REPLACE(R.Bookings.value('(Payments/Payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')='TC' THEN REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/payments/payment/creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),CHR(9),''),CHR(10),'') ELSE '' END --CHAR(16) --no se sabe
					--Fare Basis (M4)
					,cd_farebasis				=''--VARCHAR(25)
					--detalle itinerario
					,cd_aero_siglas				=''--CHAR(3)
					,cd_aero_salida				=''--CHAR(3)
					,cd_aero_llegada			=''--CHAR(3)
					,orden						=0--INT
					,ds_fecha_salida			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateStarService)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8)
					,ds_hora_salida				=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(DeadlineBroker)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,ds_hora_llegada			=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(DeadlineBroker)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(5)
					,cd_clase					=''--CHAR(2)
					--Informacion de ahorro
					,am_highfare				=0--numeric(18,2)
					,am_lowfare					=0--numeric(18,2)
					,am_fare					=0--numeric(18,2)
					,ds_reasoncode				=''--CHAR(2)
					--Informacion de nuevo cliente
					,ds_cliname					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clidir					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/address)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --VARCHAR (50)
					,ds_clicity					='' --VARCHAR (50)
					,ds_cliid					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'') --CHAR (25)
					,ds_clirazoncial			=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/name)[1]','VARCHAR(5)'),CHR(9),''),CHR(10),''),'')+COALESCE(' '+REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/lastname)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),''),'')--VARCHAR (250)
					,ds_cliname2				=''--VARCHAR (60)
					,ds_clilastname				=''--VARCHAR (60)
					,ds_clilastname2			=''--VARCHAR (60)
					,ds_clitel					=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/phone)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),'')--VARCHAR (25)
					,cd_clipais					=''--VARCHAR (25)
					,cd_clitipodoc				=COALESCE(REPLACE(REPLACE(R.Bookings.value('(../../EntityBook/invoiceInfoClient/documentType)[1]','VARCHAR(100)'),CHR(9),''),CHR(10),''),'')--VARCHAR (100)
					,cd_clitipotercero			=''--CHAR (1)
					,cd_CentroCostoCliente		=''--VARCHAR(50)
					--Inormacion adicional del tiquete
					,am_comb					=0--numeric(18,2)
					,am_tao						=0--numeric(18,2)
					,am_ivatao					=0--numeric(18,2) 
					,am_cap						=0--numeric(18,2)
					,am_ivacap					=0--numeric(18,2)
					,ds_cc_code2				=''--CHAR(2) 
					,ds_cc_number2				=''--VARCHAR(16) 
					,am_fp1						=COALESCE(R.Bookings.value('(fareInsurance/totalSellFare)[1]','numeric(18,2)'),0)--numeric(18,2)
					,am_fp2						=0--numeric(18,2)
					--Informacion  de renta de Autos
					,dt_entrega					=''--LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(pickUpDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)+' '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(pickupTime)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(17)
					,in_cars					=0--smallint 
					,cd_carcode					=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(IatarentalInsurance)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),'')--CHAR(2)
					,cd_confirmation			=''--REPLACE(REPLACE(R.Bookings.value('(fareInsurance/paidType)[1]','VARCHAR(16)'),CHR(9),''),CHR(10),'')--VARCHAR(16)
					,cd_citysalida				=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(pickupLocation/iataCodePickup)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
					,dt_retorno					=''--LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(DropOffDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)+' '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(ReturnTime)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),5)--CHAR(17)  
					,cd_cartype					=''--REPLACE(REPLACE(R.Bookings.value('(fareInsurance/vehiculeType)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),'')--VARCHAR(20)
					,cd_currency				=REPLACE(REPLACE(R.Bookings.value('(fareInsurance/currencyFare)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')--CHAR(3)
					,cd_bookingsource			=''--VARCHAR(20) 
					,cd_ratecode				=''--COALESCE(REPLACE(REPLACE(R.Bookings.value('(fareInsurance/rateCode)[1]','VARCHR(10)'),CHR(9),''),CHR(10),''),'')--VARCHR(10) 
					,am_tarifarenta				=0--numeric(18,2) 
					--Informaciion de hotel
					,dt_checkin					=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateStarService)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8) --CHAR(8)
					,in_guests					=0--smallint 
					,cd_city					=''--CHAR(3) 
					,cd_htlchain				=''--CHAR(2)
					,dt_checkout				=LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(dateFinalService)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8)--CHAR(8) 
					,ds_htlname					=''--VARCHAR(32) 
					,in_habs					=''--smallint 
					,cd_bed						=''--CHAR(3) 
					,cd_htlcur					=''--CHAR(3) 
					,am_htltarifa				=0--numeric(18,2) 
					,cd_agcur					=''--CHAR(3) 
					,am_agtarifa				=0--numeric(18,2) 
					,ds_dir1					=''--VARCHAR(50) 
					,ds_tel						=''--VARCHAR(12) 
					,ds_fax						=''--VAR+CHAR(12)
					--Informacion de servicios de terceros
					,cd_conceptofacturacion		=v_cd_conceptoseguro--REPLACE(REPLACE(R.Bookings.value('(AgreementCode)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--CHAR(3) 
					,cd_TipoServicio			=v_cd_tiposrseguro--LEFT(REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/codeHotel)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),3)--CHAR(3) 
					,cd_Proveedores				=CASE WHEN REPLACE(REPLACE(R.Bookings.value('(CodProvideBackoffice)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')<>'' THEN REPLACE(REPLACE(R.Bookings.value('(InfoBook/hotelInfo/fiscalID)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  WHEN REPLACE(REPLACE(R.Bookings.value('(bookInfoHotels/bookInfoHotel/AditionalLoc)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')='' THEN REPLACE(REPLACE(R.Bookings.value('(product/supplier/product)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') ELSE REPLACE(REPLACE(R.Bookings.value('(bookInfoHotels/bookInfoHotel/CodProvideBackoffice)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') END--VARCHAR(25)  --rgelis req.227718
					,ds_Descrip					=REPLACE(REPLACE(R.Bookings.value('(sourceName)[1]','VARCHAR(500)'),CHR(9),''),CHR(10),'')--VARCHAR(500)
					--+' desde: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkIn)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--+' hasta: '+LEFT(REPLACE(REPLACE(REPLACE(REPLACE(R.Bookings.value('(checkOut)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-','/'),10)
					--Tkt revisado
					,cd_tktrevisado				=''--CHAR(14)
					--Itinerario y clases
					,ds_itinerario				=''--VARCHAR(64)
					,ds_clases					=''--VARCHAR(36)
					,in_nacionalidad			=2--CASE WHEN REPLACE(REPLACE(R.Bookings.value('(city/countryName)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'') <> v_Pais THEN 2 ELSE 1 END --smallint
					--Valores a credito y de contado
					,am_TarifaContado			=0--COALESCE(R.Bookings.value('(fareInsurance/totalSellFare)[1]','numeric(18,2)'),0) --REPLACE(REPLACE(R.Bookings.value('(price/sale)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'') --numeric(18,2)
					,am_IvaContado				=0--numeric(18,2)
					,am_OtrosContado			=0--numeric(18,2)
					,am_TarifaCredito			=0--numeric(18,2)
					,am_IvaCredito				=0--numeric(18,2)
					,am_OtrosCredito			=0--numeric(18,2)
					--Comision del tiquete
					,am_Comision				=0--numeric(18,2)
					,ds_Observaciones			=''--VARCHAR(8000)
					,ds_ClienteEmail			=''--VARCHAR(100)
					,bl_ClienteActualizar		=0--boolean
					,bl_NotificacionMPD			=0--boolean
					,cd_NumeroPoliza			=''--VARCHAR(50)
					,cd_AnexoPoliza				=''--VARCHAR(50)
					,am_ValorPoliza				=0--numeric(18,2)
					,cd_FormaPagoTAO			=''--CHAR(3)
					,cd_TarjetaCreditoTAO		=''--CHAR(2)
					,cd_NumeroTarjetaTAO		=''--CHAR(16)
					,cd_VencimientoTarjetaTAO	=''--CHAR(5)
					,cd_NumeroPolizaTAO			=''--VARCHAR(50)
					,cd_AnexoPolizaTAO			=''--VARCHAR(50)
					,am_PorDesFormaPagoTA		=0--NUMERIC(8,4) 
					,ds_NumVuelo				=''--VARCHAR(25) 
					,ds_TipoVuelo				=''--CHAR(1) 
					,cd_Penalidad				=''--CHAR(14)
					,am_TasaCambio				= COALESCE(R.Bookings.value('(fareInsurance/ExchangeRate)[1]','numeric(18,2)'),0)--numeric(18,2)  -- falta no se sabe donde esta 
					,ds_cc_vence				=''--CHAR(5) 
					,ds_cc_vence2				=''--CHAR(5) 
					,ds_cc_autorizacion			=''--VARCHAR(25)
					,ds_cc_autorizacion2		=''--VARCHAR(25)
					,ds_cc_voucher				=''--VARCHR(10)
					,ds_cc_voucher2				=''--VARCHR(10)
					,ds_AutorizacionTarjetaTAO	=''--VARCHAR(25)
					,ds_VoucherTarjetaTAO		=''--VARCHR(10)
					,am_fptao					=0--numeric(18,2) 
					,in_cc_cuotas				=0--INT 
					,in_cc_cuotas2				=0--INT 
					,in_cuotasTarjetaTAO		=0--INT 
					,in_NumTktConj				=0--INT  
					,cd_TipoTarifaTAO			=''--VARCHAR(25) 
					,cd_TipoTiquete				=''--CHAR(3) 
					,PCC						=''--VARCHAR(5) 
					,PCC_Emite					=''--VARCHAR(5) 
					,bl_ahorro					=0--boolean 
					,in_CantidadTarifaTAO		=0--INT 
					,in_CantidadSegmentoTAO		=0--INT 
					,cd_tourcode				=''--VARCHAR(25) 
					,ds_contrato				=''--VARCHAR(25) 
					,am_valor					=0--numeric(18,2) 
					,cd_tourcode2				=''--VARCHAR(25) 
					,cd_Ahorro					=''--VARCHAR(25) 
					,cd_consecutivo				=REPLACE(REPLACE(R.Bookings.value('(locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(25)
					,cd_auxiliar				=''--VARCHAR(16)
					--Variables Nuevas para la cabecera del documento.
					,cd_tipoventa				=''--Varchar(16)
					,cd_licitacion				=''--Varchar(25)
					,ds_evento					=''--Varchar(250)
					,ds_campolibre1				=''--Varchar(500)
					,ds_campolibre2				=''--Varchar(500)
					,cd_facturador				=''--Varchar(3)
					,cd_especialista			=''--Varchar(25)
					,cd_tipoformapagoproveedor	=''--Varchar(25)
					,cd_medioreservacion		=''--Varchar(25)
					,pasajeros					=''--varchar(max)
					,am_utl						= 0--COALESCE(R.Bookings.value('(liquidation/segment/fields/value)[1]','numeric(18,2)'),0) --numeric(18,2)
					,am_TasaCambioutl			= 1 --numeric(18,2)
					,cd_conceptofacturacionutl	= ''--v_cd_conceptoutl --REPLACE(REPLACE(R.Bookings.value('(configuration/fields/type)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --CHAR(3) 
					,cd_TipoServicioutl			= ''--v_cd_tiposrvutl--CHAR(3)
					,ds_Descriputl				=''--REPLACE(REPLACE(R.Bookings.value('(configuration/label)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')--VARCHAR(500)  
					,reservaxml					= '<![CDATA['+p_XML+']]>'
			FROM @NodoXML.nodes('//Books/Book/Insurances/Insurance') As R(Bookings)
			

						--Select 
						--	,tkt = RIGHT(REPLACE(REPLACE(R.Bookings.value('(../../../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						--	,nameAncillary					=REPLACE(REPLACE(R.Bookings.value('(nameAncillary)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'')--CHAR(3)
						--	,valAncillary					=REPLACE(REPLACE(R.Bookings.value('(valAncillary)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'')--CHAR(3)
						--	,codeAncillary					=REPLACE(REPLACE(R.Bookings.value('(codeAncillary)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'')--CHAR(3)
						--	,numDocument					=REPLACE(REPLACE(R.Bookings.value('(numDocument)[1]','VARCHR(10)'),CHR(9),''),CHR(10),'')--CHAR(3)
						--FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax/fare/ancillaries/ancillari') As R(Bookings)

			INSERT INTO tmp_Booking (OpBookingGDS, ds_tipoitem, cd_tipoitem, cd_sucursal, cd_implante, bl_externo, id_reserva, iden_gds, cd_codigo, ds_fecha, cd_tiqueteador, cd_vendedor, cd_cliente, booking, cd_TipoTransaccion, ds_pax_number, ds_pax_firstnm, ds_pax_lastnm, ds_pax_prefix, cd_pax_cedula, ds_pax_telefono, ds_tkt_number, ds_tkt_prefix, ds_aero_code, ds_moneda, am_tarifa, am_iva, am_tua, am_vat, ds_cc_code, ds_cc_number, cd_farebasis, cd_aero_siglas, cd_aero_salida, cd_aero_llegada, orden, ds_fecha_salida, ds_hora_salida, ds_hora_llegada, cd_clase, am_highfare, am_lowfare, am_fare, ds_reasoncode, ds_cliname, ds_clidir, ds_clicity, ds_cliid, ds_clirazoncial, ds_cliname2, ds_clilastname, ds_clilastname2, ds_clitel, cd_clipais, cd_clitipodoc, cd_clitipotercero, cd_CentroCostoCliente, am_comb, am_tao, am_ivatao, am_cap, am_ivacap, ds_cc_code2, ds_cc_number2, am_fp1, am_fp2, dt_entrega, in_cars, cd_carcode, cd_confirmation, cd_citysalida, dt_retorno, cd_cartype, cd_currency, cd_bookingsource, cd_ratecode, am_tarifarenta, dt_checkin, in_guests, cd_city, cd_htlchain, dt_checkout, ds_htlname, in_habs, cd_bed, cd_htlcur, am_htltarifa, cd_agcur, am_agtarifa, ds_dir1, ds_tel, ds_fax, cd_conceptofacturacion, cd_TipoServicio, cd_Proveedores, ds_Descrip, cd_tktrevisado, ds_itinerario, ds_clases, in_nacionalidad, am_TarifaContado, am_IvaContado, am_OtrosContado, am_TarifaCredito, am_IvaCredito, am_OtrosCredito, am_Comision, ds_Observaciones, ds_ClienteEmail, bl_ClienteActualizar, bl_NotificacionMPD, cd_NumeroPoliza, cd_AnexoPoliza, am_ValorPoliza, cd_FormaPagoTAO, cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, cd_VencimientoTarjetaTAO, cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, am_PorDesFormaPagoTA, ds_NumVuelo, ds_TipoVuelo, cd_Penalidad, am_TasaCambio, ds_cc_vence, ds_cc_vence2, ds_cc_autorizacion, ds_cc_autorizacion2, ds_cc_voucher, ds_cc_voucher2, ds_AutorizacionTarjetaTAO, ds_VoucherTarjetaTAO, am_fptao, in_cc_cuotas, in_cc_cuotas2, in_cuotasTarjetaTAO, in_NumTktConj, cd_TipoTarifaTAO, cd_TipoTiquete, PCC, PCC_Emite, bl_ahorro, in_CantidadTarifaTAO, in_CantidadSegmentoTAO, cd_tourcode, ds_contrato, am_valor, cd_tourcode2, cd_Ahorro, cd_consecutivo, cd_auxiliar, cd_tipoventa, cd_licitacion, ds_evento, ds_campolibre1, ds_campolibre2, cd_facturador, cd_especialista, cd_tipoformapagoproveedor, cd_medioreservacion, pasajeros, am_utl, am_TasaCambioutl, cd_conceptofacturacionutl, cd_TipoServicioutl, ds_Descriputl, ancillari, reservaxml)
			select 
				OpBookingGDS, ds_tipoitem, cd_tipoitem, cd_sucursal, cd_implante, bl_externo, id_reserva, iden_gds, cd_codigo, ds_fecha, cd_tiqueteador, cd_vendedor, cd_cliente, booking, cd_TipoTransaccion
				, ds_pax_number, ds_pax_firstnm, ds_pax_lastnm, ds_pax_prefix, cd_pax_cedula, ds_pax_telefono, ds_tkt_number=ancillari.numDocument, ds_tkt_prefix, ds_aero_code, ds_moneda
				, ancillari.valAncillary, am_iva = ancillari.valIvaAncillary, am_tua, am_vat, ds_cc_code, ds_cc_number, cd_farebasis, cd_aero_siglas, cd_aero_salida, cd_aero_llegada, orden, ds_fecha_salida, ds_hora_salida, ds_hora_llegada, cd_clase, am_highfare, am_lowfare, am_fare, ds_reasoncode, ds_cliname, ds_clidir, ds_clicity, ds_cliid, ds_clirazoncial, ds_cliname2, ds_clilastname, ds_clilastname2, ds_clitel, cd_clipais, cd_clitipodoc, cd_clitipotercero, cd_CentroCostoCliente, am_comb, am_tao, am_ivatao, am_cap, am_ivacap, ds_cc_code2, ds_cc_number2, am_fp1, am_fp2, dt_entrega, in_cars, cd_carcode, cd_confirmation, cd_citysalida, dt_retorno, cd_cartype, cd_currency, cd_bookingsource, cd_ratecode, am_tarifarenta, dt_checkin, in_guests, cd_city, cd_htlchain, dt_checkout, ds_htlname, in_habs, cd_bed, cd_htlcur, am_htltarifa, cd_agcur, am_agtarifa, ds_dir1, ds_tel, ds_fax, cd_conceptofacturacion, cd_TipoServicio, cd_Proveedores, ds_Descrip, cd_tktrevisado, ds_itinerario, ds_clases, in_nacionalidad, am_TarifaContado, am_IvaContado, am_OtrosContado, am_TarifaCredito, am_IvaCredito, am_OtrosCredito, am_Comision, ds_Observaciones, ds_ClienteEmail, bl_ClienteActualizar, bl_NotificacionMPD, cd_NumeroPoliza, cd_AnexoPoliza, am_ValorPoliza, cd_FormaPagoTAO, cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, cd_VencimientoTarjetaTAO, cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, am_PorDesFormaPagoTA, ds_NumVuelo, ds_TipoVuelo, cd_Penalidad, am_TasaCambio, ds_cc_vence, ds_cc_vence2, ds_cc_autorizacion, ds_cc_autorizacion2, ds_cc_voucher, ds_cc_voucher2, ds_AutorizacionTarjetaTAO, ds_VoucherTarjetaTAO, am_fptao, in_cc_cuotas, in_cc_cuotas2, in_cuotasTarjetaTAO, in_NumTktConj, cd_TipoTarifaTAO, cd_TipoTiquete='EMD', PCC, PCC_Emite, bl_ahorro, in_CantidadTarifaTAO, in_CantidadSegmentoTAO, cd_tourcode, ds_contrato, am_valor, cd_tourcode2, cd_Ahorro, cd_consecutivo, cd_auxiliar, cd_tipoventa, cd_licitacion, ds_evento, ds_campolibre1, ds_campolibre2, cd_facturador, cd_especialista, cd_tipoformapagoproveedor, cd_medioreservacion, pasajeros, am_utl, am_TasaCambioutl, cd_conceptofacturacionutl, cd_TipoServicioutl, ds_Descriputl
				, ancillari = 1,reservaxml= '<![CDATA['+p_XML+']]>'
			from tmp_Booking r
			Inner Join (
						Select 
							tkt								=RIGHT(REPLACE(REPLACE(R.Bookings.value('(../../../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
							,nameAncillary					=REPLACE(REPLACE(R.Bookings.value('(nameAncillary)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'')--CHAR(3)
							,valAncillary					=REPLACE(REPLACE(R.Bookings.value('(valAncillary)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'')--CHAR(3)
							,codeAncillary					=REPLACE(REPLACE(R.Bookings.value('(codeAncillary)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'')--CHAR(3)
							,numDocument					=RIGHT(REPLACE(REPLACE(R.Bookings.value('(numDocument)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
							,valIvaAncillary				=CASE WHEN REPLACE(REPLACE(R.Bookings.value('(taxes/tax/codeTax)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),'')='YS' THEN REPLACE(REPLACE(R.Bookings.value('(taxes/tax/valtax)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),'') ELSE '0' END
						FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax/fare/ancillaries/ancillari') As R(Bookings)
						) AS ancillari ON ancillari.tkt = r.ds_tkt_number
			Where numDocument is not null
			--
			
			--select * from tmp_Booking

			INSERT INTO tmp_BookingGDS_Pasajeros (in_orden, cd_reserva, cd_consecutivo, cd_tipoitem,ds_tkt_number, ds_pax_firstnm, ds_pax_lastnm, ds_pax_prefix, cd_pax_cedula, ds_pax_telefono)
			SELECT  in_orden		= ROW_NUMBER() OVER(PARTITION BY cd_reserva,cd_consecutivo ORDER BY cd_reserva,cd_consecutivo,in_orden)			
					,cd_reserva		= P.cd_reserva			
					,cd_consecutivo	= P.cd_consecutivo
					,cd_tipoitem	= P.cd_tipoitem
					,ds_tkt_number
					,ds_pax_firstnm	= P.ds_pax_firstnm		
					,ds_pax_lastnm	= P.ds_pax_lastnm		
					,ds_pax_prefix	= P.ds_pax_prefix		
					,cd_pax_cedula	= P.cd_pax_cedula		
					,ds_pax_telefono	= P.ds_pax_telefono	
			FROM(
				SELECT	 in_orden			= COALESCE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(25)'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--REPLACE(REPLACE(R.Bookings.value('(../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_tipoitem		= 'Flight'--VARCHAR(25)
						,ds_tkt_number		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,ds_pax_firstnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_lastnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_prefix		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(paxtype)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
						,cd_pax_cedula		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')--VARCHAR(15) 
						,ds_pax_telefono	= COALESCE(REPLACE(REPLACE(R.Bookings.value('(phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')
				FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax') As R(Bookings)
					
				UNION ALL
				
				SELECT	 in_orden			= COALESCE(R.Bookings.value('(frecuentGuest)[1]','VARCHAR(25)'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../../../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_tipoitem		= 'Hotel'--VARCHAR(25)
						,ds_tkt_number		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,ds_pax_firstnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_lastnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_prefix		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(typePax)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
						,cd_pax_cedula		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')--VARCHAR(15) 
						,ds_pax_telefono	= COALESCE(REPLACE(REPLACE(R.Bookings.value('(phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')
				FROM @NodoXML.nodes('//Books/Book/bookInfoHotels/bookInfoHotel/InfoBook/rooms/room/Paxes/Pax') As R(Bookings)
				
				UNION ALL
				
				SELECT	 in_orden			= COALESCE(R.Bookings.value('(frecuentGuest)[1]','VARCHAR(25)'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_tipoitem		='Car'--VARCHAR(25)
						,ds_tkt_number		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,ds_pax_firstnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_lastnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_prefix		= ''--CHAR(3) 
						,cd_pax_cedula		= ''--VARCHAR(15) 
						,ds_pax_telefono	= ''--VARCHAR(15) 
				FROM @NodoXML.nodes('//Books/Book/bookCars/bookCar/Pax') As R(Bookings)
				
				UNION ALL
				
				SELECT	 in_orden			= COALESCE(R.Bookings.value('(voucher)[1]','VARCHAR(25)'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_tipoitem		='Insurance'--VARCHAR(25)
						,ds_tkt_number		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,ds_pax_firstnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(name)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_lastnm		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(lastName)[1]','VARCHAR(30)'),CHR(9),''),CHR(10),''),'')--CHAR(30) 
						,ds_pax_prefix		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(typePax)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),'')--CHAR(3) 
						,cd_pax_cedula		= COALESCE(REPLACE(REPLACE(R.Bookings.value('(identification)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'')--VARCHAR(15) 
						,ds_pax_telefono	= COALESCE(REPLACE(REPLACE(R.Bookings.value('(phonePax)[1]','VARCHAR(15)'),CHR(9),''),CHR(10),''),'') 
				FROM @NodoXML.nodes('//Books/Book/Insurances/Insurance/fareInsurance/Paxes/Pax') As R(Bookings)
			) AS P
			ORDER BY cd_reserva,cd_consecutivo,in_orden ASC
			
			
			INSERT INTO tmp_BookingGDS_FEE (in_orden, cd_reserva, cd_consecutivo, cd_conceptofac,cd_subcodigo, am_valor)
			SELECT  in_orden		= ROW_NUMBER() OVER(PARTITION BY cd_reserva,cd_consecutivo ORDER BY cd_reserva,cd_consecutivo,in_orden)			
					,cd_reserva		= P.cd_reserva			
					,cd_consecutivo	= P.cd_consecutivo
					,cd_conceptofac	= COALESCE(dbo.[fnza_Get_ValorInterfazCodigoMaestro]('IdeasFractral',8,'CONCEPTOSFACTURACION',cd_conceptofac),cd_conceptofac)
					,cd_subcodigo   = COALESCE(dbo.[fnza_Get_ValorInterfazCodigoMaestro]('IdeasFractral',8,'CONCEPTOSFACTURACION',cd_conceptofac),cd_conceptofac)
					,am_valor
			FROM(
				SELECT	 in_orden			= 1--CONVERT(BIGINT,(RIGHT(REPLACE(REPLACE(R.Bookings.value('(../../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)))--CHR(10))
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(../../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--REPLACE(REPLACE(R.Bookings.value('(../../../../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_conceptofac		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,cd_subcodigo		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,am_valor			= COALESCE(R.Bookings.value('(valueFee)[1]','numeric(18,2)'),0)--numeric(18,2)
				FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax/fees/fee') As R(Bookings)
					
				UNION ALL
				
				SELECT	 in_orden			= 1--COALESCE(R.Bookings.value('(ticketNumber)[1]','BIGINT'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../../../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_conceptofac		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,cd_subcodigo		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,am_valor		= COALESCE(R.Bookings.value('(valueFee)[1]','numeric(18,2)'),0)--numeric(18,2)
				FROM @NodoXML.nodes('//Books/Book/bookInfoHotels/bookInfoHotel/InfoBook/rooms/room/Paxes/Pax/fees/fee') As R(Bookings)
				
				UNION ALL
				
				SELECT	 in_orden			= 1--COALESCE(R.Bookings.value('(ticketNumber)[1]','BIGINT'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_conceptofac		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,cd_subcodigo		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,am_valor			= COALESCE(R.Bookings.value('(valueFee)[1]','numeric(18,2)'),0)--numeric(18,2)
				FROM @NodoXML.nodes('//Books/Book/bookCars/bookCar/Paxes/Pax/fees/fee') As R(Bookings)
				
				UNION ALL
				
				SELECT	 in_orden			= 1--COALESCE(R.Bookings.value('(ticketNumber)[1]','BIGINT'),0) --BIGINT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../../../../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../locSource)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_conceptofac		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,cd_subcodigo		= RIGHT(REPLACE(REPLACE(R.Bookings.value('(typeFee)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--CHR(10)
						,am_valor			= COALESCE(R.Bookings.value('(valueFee)[1]','numeric(18,2)'),0)--numeric(18,2)
				FROM @NodoXML.nodes('//Books/Book/Insurances/Insurance/fareInsurance/Paxes/Pax/fees/fee') As R(Bookings)

			) AS P
			ORDER BY cd_reserva,cd_consecutivo,in_orden ASC
			
			
			/*
			INSERT INTO tmp_BookingGDS_Valores (in_orden, cd_reserva, cd_consecutivo, cd_tipoitem, ds_segmento, ds_nombre, am_valor)
			SELECT  in_orden		= ROW_NUMBER() OVER(PARTITION BY cd_reserva,cd_consecutivo ORDER BY cd_reserva,cd_consecutivo,in_orden)			
					,cd_reserva		= P.cd_reserva			
					,cd_consecutivo	= P.cd_consecutivo
					,,cd_tipoitem	= P.cd_tipoitem
					,ds_segmento	= P.ds_segmento			
					,ds_nombre		= P.ds_nombre		
					,am_valor		= P.am_valor
			FROM(
				SELECT	 in_orden			= R.Bookings.value('(../../../file)[1]','INT') --INT 
						,cd_reserva			= REPLACE(REPLACE(R.Bookings.value('(../../../file)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'') --VARCHAR(6)
						,cd_consecutivo		= REPLACE(REPLACE(R.Bookings.value('(../../../file)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')  --VARCHAR(25)
						,cd_tipoitem		='Flight'--VARCHAR(25)
						,ds_segmento		= COALESCE(RTRIM(REPLACE(REPLACE(R.Bookings.value('(../name)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),'')),'')--VARCHAR(20) 
						,ds_nombre		= COALESCE(RTRIM(REPLACE(REPLACE(R.Bookings.value('(label)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),'')),'')--VARCHAR(20) 
						,am_valor		= COALESCE(R.Bookings.value('(value)[1]','numeric(18,2)'),0)--numeric(18,2)
				FROM @NodoXML.nodes('//bookings/response/liquidation/segment/fields') As R(Bookings) 
			) AS P
			ORDER BY cd_reserva,cd_consecutivo,in_orden ASC
			*/
			
			
			INSERT INTO tmp_BookingGDS_Itinerarios (cd_reserva,ds_tkt_number,cd_consecutivo,orden,cd_origen,cd_destino,cd_clase,fecha_salida,hora_salida,hora_llegada,terminal,cd_aero_siglas,cd_farebasis,ds_NumVuelo,ds_TipoVuelo,am_valor)
			SELECT cd_reserva			= cd_codigo,
				  ds_tkt_number			= COALESCE(ds_tkt_number,''),
				  cd_consecutivo		= cd_consecutivo,
				  orden					= I.Itinerario.value('(segmentNumber)[1]','INT'),
				  cd_origen				= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(DepartureIata)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),''), --CHAR(3),    
				  cd_destino			= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(ArrivalIata)[1]','VARCHAR(3)'),CHR(9),''),CHR(10),''),''), --CHAR(3),   
				  cd_clase				= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(Class)[1]','VARCHAR(1)'),CHR(9),''),CHR(10),''),''), --CHAR(2),       
				  fecha_salida			= COALESCE(LEFT(REPLACE(REPLACE(REPLACE(REPLACE(I.Itinerario.value('(DepartureDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),8),''),   
				  hora_salida			= COALESCE(RIGHT(LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(I.Itinerario.value('(DepartureDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),':',''),13),4),''),    
				  hora_llegada			= COALESCE(RIGHT(LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(I.Itinerario.value('(ArrivalDate)[1]','VARCHAR(20)'),CHR(9),''),CHR(10),''),'T',' '),'-',''),':',''),13),4),''),       
				  terminal				= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(terminal)[1]','VARCHAR(50)'),CHR(9),''),CHR(10),''),''),       
				  cd_aero_siglas		= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(airlineOperator)[1]','VARCHAR(2)'),CHR(9),''),CHR(10),''),''), 
				  cd_farebasis			= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(fareBase)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),''),   
				  ds_NumVuelo			= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(FlightNumber)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),''),''),    
				  ds_TipoVuelo			= COALESCE(REPLACE(REPLACE(I.Itinerario.value('(FlightNumber)[1]','VARCHAR(1)'),CHR(9),''),CHR(10),''),''),   
				  am_valor				= '0'
			FROM(
				SELECT
					 cd_codigo		= REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'')
					,ds_tkt_number	= ''--RIGHT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)
					,cd_consecutivo	= REPLACE(REPLACE(R.Bookings.value('(../../InternalLocator)[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'') --RIGHT(REPLACE(REPLACE(R.Bookings.value('(Paxes/Pax/ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)
					,itinerario		= R.Bookings.query('./segments/segment') 
				FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight') As R(Bookings)
			) AS booking
			CROSS APPLY booking.itinerario.nodes('segment') I(Itinerario)
			
			--select * from tmp_Booking
			--select * from tmp_BookingGDS_Itinerarios
			
			INSERT INTO tmp_BookingGDS_VariablesAdicionales (in_orden,cd_reserva,cd_consecutivo,cd_tipoitem,ds_nombre,ds_valor)
			SELECT in_orden			= ROW_NUMBER() OVER(PARTITION BY cd_consecutivo ORDER BY cd_consecutivo ASC)
				  ,cd_codigo		= cd_codigo
				  ,cd_consecutivo	= cd_consecutivo
				  ,cd_tipoitem		='Todos'--VARCHAR(25)
				  ,ds_nombre		= COALESCE(V.Variable.value('name[1]','VARCHAR(20)'),'')
				  ,ds_valor			= COALESCE(V.Variable.value('value[1]','VARCHAR(8000)'),'')
			FROM(
				Select
					 cd_codigo		= R.Bookings.value('(../InternalLocator)[1]','CHAR(6)')
					,cd_consecutivo	= R.Bookings.value('(../InternalLocator)[1]','VARCHAR(25)')
					,Variable		= R.Bookings.query('./UDIDS/UDID')
				FROM @NodoXML.nodes('//Books/Book/CorporateInfo') As R(Bookings)
			) AS booking
			CROSS APPLY booking.Variable.nodes('UDID') V(Variable)
			
			Insert Into tmp_BookingGDS_CargosImpuestos (in_orden,cd_reserva,cd_consecutivo, cd_tipoitem, cd_codigo,ds_nombre,cd_tipo,cd_codigopadre,cd_tipopadre,am_porcentaje,am_contado,am_credito,am_valor)
			SELECT in_orden			= ROW_NUMBER() OVER(PARTITION BY cd_tipoitem ORDER BY cd_reserva,cd_consecutivo,cd_tipoitem) 
				  ,cd_reserva		= cd_reserva 
				  ,cd_consecutivo	= cd_consecutivo
				  ,cd_tipoitem		= cd_tipoitem
				  ,cd_codigo		= cd_codigo 
				  ,ds_nombre		= ds_nombre
				  ,cd_tipo			= cd_tipo
				  ,cd_codigopadre	= cd_codigopadre
				  ,cd_tipopadre		= cd_tipopadre
				  ,am_porcentaje	= MAX(am_porcentaje)
				  ,am_contado		= SUM(am_contado)
				  ,am_credito		= SUM(am_credito)
				  ,am_valor			= SUM(am_valor)
			FROM(
				SELECT in_orden			= 0--ROW_NUMBER() OVER(ORDER BY cd_reserva,cd_consecutivo) --INT
					  ,cd_reserva		= cd_reserva --VARCHAR(12)
					  ,cd_consecutivo	= cd_consecutivo --VARCHAR(25)
					  ,cd_tipoitem		= 'Flight'--VARCHAR(25)
					  ,cd_codigo		= CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(3)')='YS' THEN 'IVA'
											   WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(3)') IN('YR','YQ') THEN 'CMB'
											   WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(3)')='CO' THEN 'TUA'
											   ELSE 'OTR' END --VARCHAR(3)
					  ,ds_nombre		= CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(3)')='YS' THEN 'IVA'
											   WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(3)') IN('YR','YQ') THEN 'Combustible'
											   WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(3)')='CO' THEN 'Tasa Aeroporturia'
											   ELSE 'Otros' END --VARCHAR(20)
					  ,cd_tipo			= CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(1)')='YS' THEN '3' ELSE '1' END --VARCHAR(1)
					  ,cd_codigopadre	= CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(1)')='YS' THEN 'TAR' ELSE '' END --VARCHAR(3)
					  ,cd_tipopadre		= CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(1)')='YS' THEN '1' ELSE '' END --VARCHAR(1)
					  ,am_porcentaje	= CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(1)')='YS' THEN v_am_poriva ELSE 0 END --numeric(18,2)
					  ,am_contado		= COALESCE(C.CargosImpuestos.value('valtax[1]','numeric(18,2)'),0) --numeric(18,2)
					  ,am_credito		= 0 --numeric(18,2)
					  ,am_valor			= COALESCE(C.CargosImpuestos.value('valtax[1]','numeric(18,2)'),0) --numeric(18,2)
				FROM(
					SELECT
						 cd_reserva		= REPLACE(REPLACE(R.Bookings.value('../../../../../InternalLocator[1]','VARCHAR(12)'),CHR(9),''),CHR(10),'')
						,cd_consecutivo	= RIGHT(REPLACE(REPLACE(R.Bookings.value('(../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--REPLACE(REPLACE(R.Bookings.value('../../../locSource[1]','VARCHAR(25)'),CHR(9),''),CHR(10),'')
						,CargosImpuestos		= R.Bookings.query('./taxes/tax')
					FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax/fare') As R(Bookings)
				) AS booking
				CROSS APPLY booking.CargosImpuestos.nodes('tax') C(CargosImpuestos)
			) AS RES
			GROUP BY cd_reserva,cd_consecutivo,cd_tipoitem,cd_codigo,ds_nombre,cd_tipo,cd_codigopadre,cd_tipopadre
			
			UPDATE R 
			SET R.am_contado=R.am_contado+COALESCE((SELECT C.am_contado FROM tmp_BookingGDS_CargosImpuestos C WHERE C.cd_codigo='TUA' AND C.cd_consecutivo=R.cd_consecutivo),0)
				,R.am_valor=R.am_valor+COALESCE((SELECT C.am_valor FROM tmp_BookingGDS_CargosImpuestos C WHERE C.cd_codigo='TUA' AND C.cd_consecutivo=R.cd_consecutivo),0)
			FROM tmp_BookingGDS_CargosImpuestos R
			WHERE R.cd_codigo ='OTR'

			--select * from tmp_BookingGDS_CargosImpuestos	  
			Insert Into tmp_BookingGDS_ValoresItems(cd_reserva,cd_consecutivo,cd_tipoitem,am_tarifa,am_iva,am_cmb,am_tua,am_otros,am_total)
			SELECT cd_reserva		 = cd_reserva
				   ,cd_consecutivo	 = cd_consecutivo
				   ,cd_tipoitem		 = cd_tipoitem
				   ,am_tarifa		 = Tarifa
				   ,am_iva			 = max(Iva)	
				   ,am_cmb			 = SUM(CMB)	
				   ,am_tua			 = max(TUA)	
				   ,am_otros		 = MAx(Otros)-max(Iva)-SUM(CMB)-max(TUA)	
				   ,am_total		 = MAX(Total)
			FROM(
				SELECT
						 cd_reserva		 = cd_reserva
						,cd_consecutivo	 = cd_consecutivo
						,cd_tipoitem	 = cd_tipoitem
						,Tarifa			 = Tarifa
						,Iva			 = CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(2)')='YS' THEN C.CargosImpuestos.value('valtax[1]','numeric(18,2)') ELSE 0 END
						,CMB			 = CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(2)') IN ('YR','YQ') THEN C.CargosImpuestos.value('valtax[1]','numeric(18,2)') ELSE 0 END
						,TUA			 = CASE WHEN C.CargosImpuestos.value('codeTax[1]','VARCHAR(2)')='CO' THEN C.CargosImpuestos.value('valtax[1]','numeric(18,2)') ELSE 0 END
						,Otros			 = Otros
						,Total			 = Total
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../../../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = RIGHT(REPLACE(REPLACE(R.Bookings.value('(../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--R.Bookings.value('../../../locSource[1]','VARCHAR(25)')
						,cd_tipoitem	 = 'Flight'--VARCHAR(25)
						,Tarifa			 = R.Bookings.value('localfare[1]','numeric(18,2)')
						,Otros			 = COALESCE(R.Bookings.value('TotalTax[1]','numeric(18,2)'),0)
						,Total			 = COALESCE(R.Bookings.value('totalTicket[1]','numeric(18,2)'),0)
						,CargosImpuestos = R.Bookings.query('./taxes/tax')
					FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax/fare') As R(Bookings)
				) AS booking
				CROSS APPLY booking.CargosImpuestos.nodes('tax') C(CargosImpuestos)

				UNION ALL

				SELECT
						 cd_reserva		 = cd_reserva
						,cd_consecutivo	 = cd_consecutivo
						,cd_tipoitem	 = cd_tipoitem	 
						,Tarifa			 = Tarifa
						,Iva			 = 0
						,CMB			 = 0
						,TUA			 = 0
						,Otros			 = CASE WHEN Tarifa+Otros<>Total THEN Total-Tarifa ELSE Otros END 
						,Total			 = Total
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = R.Bookings.value('../../locSource[1]','VARCHAR(25)')
						,cd_tipoitem	 = 'Hotel'--VARCHAR(25)
						,Tarifa			 = R.Bookings.value('totalNetfare[1]','numeric(18,2)')
						,Otros			 = COALESCE(R.Bookings.value('totalTax[1]','numeric(18,2)'),0)
						,Total			 = COALESCE(R.Bookings.value('totalSellFare[1]','numeric(18,2)'),0)
						,CargosImpuestos = ''
					FROM @NodoXML.nodes('//Books/Book/bookInfoHotels/bookInfoHotel/InfoBook/fareHotel') As R(Bookings)
				) AS booking

				UNION ALL

				SELECT
						 cd_reserva		 = cd_reserva
						,cd_consecutivo	 = cd_consecutivo
						,cd_tipoitem	 = cd_tipoitem
						,Tarifa			 = Tarifa
						,Iva			 = 0
						,CMB			 = 0
						,TUA			 = 0
						,Otros			 = CASE WHEN Tarifa+Otros<>Total THEN Total-Tarifa ELSE Otros END 
						,Total			 = Total
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = R.Bookings.value('../locSource[1]','VARCHAR(25)')
						,cd_tipoitem	 = 'Car'--VARCHAR(25)
						,Tarifa			 = R.Bookings.value('totalNetfare[1]','numeric(18,2)')
						,Otros			 = COALESCE(R.Bookings.value('totalTax[1]','numeric(18,2)'),0)
						,Total			 = COALESCE(R.Bookings.value('totalSellFare[1]','numeric(18,2)'),0)
						,CargosImpuestos = ''
					FROM @NodoXML.nodes('//Books/Book/bookCars/bookCar/fareCar') As R(Bookings)
				) AS booking

				UNION ALL

				SELECT
						 cd_reserva		 = cd_reserva
						,cd_consecutivo	 = cd_consecutivo
						,cd_tipoitem	 = cd_tipoitem
						,Tarifa			 = Tarifa
						,Iva			 = 0
						,CMB			 = 0
						,TUA			 = 0
						,Otros			 = CASE WHEN Tarifa+Otros<>Total THEN Total-Tarifa ELSE Otros END 
						,Total			 = Total
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = R.Bookings.value('../locSource[1]','VARCHAR(25)')
						,cd_tipoitem	 = 'Insurance'--VARCHAR(25)
						,Tarifa			 = R.Bookings.value('totaNetFare[1]','numeric(18,2)')
						,Otros			 = COALESCE(R.Bookings.value('totaTax[1]','numeric(18,2)'),0)
						,Total			 = COALESCE(R.Bookings.value('totaSellFare[1]','numeric(18,2)'),0)
						,CargosImpuestos = ''
					FROM @NodoXML.nodes('//Books/Book/Insurances/Insurance/fareInsurance') As R(Bookings)
				) AS booking
			) AS res
			GROUP BY cd_reserva		 
				   ,cd_consecutivo
				   ,cd_tipoitem
				   ,Tarifa			 
				   --,Otros			 
				   --,Total

			--select * from tmp_BookingGDS_ValoresItems
			
			Insert Into tmp_BookingGDS_FormasPagos (in_orden,cd_reserva,cd_consecutivo,cd_tipoitem,cd_codigo,ds_nombre,cd_tipotarjeta,ds_numerotarjeta,ds_vouchertarjeta,ds_expiraciontarjeta,ds_autorizaciontarjeta,in_coutas,cd_banco,ds_cheque,ds_plaza,ds_referencia,ds_Poliza,ds_PolizaAnexo,am_valor)
			SELECT  in_orden				= DENSE_RANK() OVER(PARTITION BY cd_reserva,cd_consecutivo,cd_tipoitem ORDER BY cd_reserva,cd_consecutivo,cd_tipoitem,cd_codigo)
					,cd_reserva				= cd_reserva				
					,cd_consecutivo			= cd_consecutivo			
					,cd_tipoitem			= cd_tipoitem
					,cd_codigo				= cd_codigo				
					,ds_nombre				= ds_nombre				
					,cd_tipotarjeta			= cd_tipotarjeta			
					,ds_numerotarjeta		= ds_numerotarjeta		
					,ds_vouchertarjeta		= ds_vouchertarjeta		
					,ds_expiraciontarjeta	= ds_expiraciontarjeta	
					,ds_autorizaciontarjeta	= ds_autorizaciontarjeta	
					,in_coutas				= in_coutas				
					,cd_banco				= cd_banco				
					,ds_cheque				= ds_cheque				
					,ds_plaza				= ds_plaza				
					,ds_referencia			= ds_referencia			
					,ds_Poliza				= ds_Poliza				
					,ds_PolizaAnexo			= ds_PolizaAnexo			
					,am_valor				= am_valor				
			FROM(
				SELECT in_orden					= 0
					  ,cd_reserva				= cd_reserva
					  ,cd_consecutivo			= cd_consecutivo
					  ,cd_tipoitem				= 'Flight'
					  ,cd_codigo				= CASE WHEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)')='TC' THEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)') ELSE 'EFE' END
					  ,ds_nombre				= COALESCE(F.FormasPagos.value('(fop)[1]','VARCHAR(50)'),'')
					  ,cd_tipotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/flag)[1]','VARCHAR(2)'),'')
					  ,ds_numerotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),'')
					  ,ds_vouchertarjeta		= COALESCE(F.FormasPagos.value('(creditCardInfo/AdditionalCode)[1]','VARCHAR(25)'),'')
					  ,ds_expiraciontarjeta		= '__/__'
					  ,ds_autorizaciontarjeta	= COALESCE(F.FormasPagos.value('(creditCardInfo/approvalCode)[1]','VARCHAR(25)'),'')
					  ,in_coutas				= 0
					  ,cd_banco					= '' 
					  ,ds_cheque				= '' 
					  ,ds_plaza					= '' 
					  ,ds_referencia			= '' 
					  ,ds_Poliza				= '' 
					  ,ds_PolizaAnexo			= '' 
					  ,am_valor					= COALESCE(F.FormasPagos.value('valuePay[1]','numeric(18,2)'),0)
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = RIGHT(REPLACE(REPLACE(R.Bookings.value('(ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--R.Bookings.value('../../locSource[1]','VARCHAR(25)')
						,FormasPagos = R.Bookings.query('./payments/payment')
					FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax') As R(Bookings)
				) AS booking
				CROSS APPLY booking.FormasPagos.nodes('payment') F(FormasPagos)
				
				UNION ALL

				SELECT in_orden					= 0
					  ,cd_reserva				= cd_reserva
					  ,cd_consecutivo			= cd_consecutivo
					  ,cd_tipoitem				= 'Hotel'
					  ,cd_codigo				= CASE WHEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)')='TC' THEN F.FormasPagos.value('fop[1]','VARCHAR(2)') ELSE 'EFE' END
					  ,ds_nombre				= COALESCE(F.FormasPagos.value('(fop)[1]','VARCHAR(50)'),'')
					  ,cd_tipotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/flag)[1]','VARCHAR(2)'),'')
					  ,ds_numerotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),'')
					  ,ds_vouchertarjeta		= COALESCE(F.FormasPagos.value('(creditCardInfo/AdditionalCode)[1]','VARCHAR(25)'),'')
					  ,ds_expiraciontarjeta		= '__/__'
					  ,ds_autorizaciontarjeta	= COALESCE(F.FormasPagos.value('(creditCardInfo/approvalCode)[1]','VARCHAR(25)'),'')
					  ,in_coutas				= 0
					  ,cd_banco					= '' 
					  ,ds_cheque				= '' 
					  ,ds_plaza					= '' 
					  ,ds_referencia			= '' 
					  ,ds_Poliza				= '' 
					  ,ds_PolizaAnexo			= '' 
					  ,am_valor					= COALESCE(F.FormasPagos.value('valuePay[1]','numeric(18,2)'),0)
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = R.Bookings.value('locSource[1]','VARCHAR(25)')
						,FormasPagos = R.Bookings.query('./payments/payment')
					FROM @NodoXML.nodes('//Books/Book/bookInfoHotels/bookInfoHotel') As R(Bookings)
				) AS booking
				CROSS APPLY booking.FormasPagos.nodes('payment') F(FormasPagos)
				
				UNION ALL

				SELECT in_orden					= 0
					  ,cd_reserva				= cd_reserva
					  ,cd_consecutivo			= cd_consecutivo
					  ,cd_tipoitem				= 'Car'
					  ,cd_codigo				= CASE WHEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)')='TC' THEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)') ELSE 'EFE' END
					  ,ds_nombre				= COALESCE(F.FormasPagos.value('(fop)[1]','VARCHAR(50)'),'')
					  ,cd_tipotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/flag)[1]','VARCHAR(2)'),'')
					  ,ds_numerotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),'')
					  ,ds_vouchertarjeta		= COALESCE(F.FormasPagos.value('(creditCardInfo/AdditionalCode)[1]','VARCHAR(25)'),'')
					  ,ds_expiraciontarjeta		= '__/__'
					  ,ds_autorizaciontarjeta	= COALESCE(F.FormasPagos.value('(creditCardInfo/approvalCode)[1]','VARCHAR(25)'),'')
					  ,in_coutas				= 0
					  ,cd_banco					= '' 
					  ,ds_cheque				= '' 
					  ,ds_plaza					= '' 
					  ,ds_referencia			= '' 
					  ,ds_Poliza				= '' 
					  ,ds_PolizaAnexo			= '' 
					  ,am_valor					= COALESCE(F.FormasPagos.value('valuePay[1]','numeric(18,2)'),0)
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = R.Bookings.value('locSource[1]','VARCHAR(25)')
						,FormasPagos = R.Bookings.query('./payments/payment')
					FROM @NodoXML.nodes('//Books/Book/bookCars/bookCar') As R(Bookings)
				) AS booking
				CROSS APPLY booking.FormasPagos.nodes('payment') F(FormasPagos)
				
				UNION ALL

				SELECT in_orden					= 0
					  ,cd_reserva				= cd_reserva
					  ,cd_consecutivo			= cd_consecutivo
					  ,cd_tipoitem				= 'Insurance'
					  ,cd_codigo				= CASE WHEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)')='TC' THEN F.FormasPagos.value('fop[1]','VARCHAR(2)') ELSE 'EFE' END
					  ,ds_nombre				= COALESCE(F.FormasPagos.value('(fop)[1]','VARCHAR(50)'),'')
					  ,cd_tipotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/flag)[1]','VARCHAR(2)'),'')
					  ,ds_numerotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),'')
					  ,ds_vouchertarjeta		= COALESCE(F.FormasPagos.value('(creditCardInfo/AdditionalCode)[1]','VARCHAR(25)'),'')
					  ,ds_expiraciontarjeta		= '__/__'
					  ,ds_autorizaciontarjeta	= COALESCE(F.FormasPagos.value('(creditCardInfo/approvalCode)[1]','VARCHAR(25)'),'')
					  ,in_coutas				= 0
					  ,cd_banco					= '' 
					  ,ds_cheque				= '' 
					  ,ds_plaza					= '' 
					  ,ds_referencia			= '' 
					  ,ds_Poliza				= '' 
					  ,ds_PolizaAnexo			= '' 
					  ,am_valor					= COALESCE(F.FormasPagos.value('valuePay[1]','numeric(18,2)'),0)
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = R.Bookings.value('locSource[1]','VARCHAR(25)')
						,FormasPagos = R.Bookings.query('./payments/payment')
					FROM @NodoXML.nodes('//Books/Book/Insurances/Insurance') As R(Bookings)
				) AS booking
				CROSS APPLY booking.FormasPagos.nodes('payment') F(FormasPagos)

				UNION ALL

				SELECT in_orden					= 0
					  ,cd_reserva				= cd_reserva
					  ,cd_consecutivo			= cd_consecutivo
					  ,cd_tipoitem				= 'Fee'
					  ,cd_codigo				= CASE WHEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)')='TC' THEN F.FormasPagos.value('(fop)[1]','VARCHAR(2)') ELSE 'EFE' END
					  ,ds_nombre				= COALESCE(F.FormasPagos.value('(fop)[1]','VARCHAR(50)'),'')
					  ,cd_tipotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/flag)[1]','VARCHAR(2)'),'')
					  ,ds_numerotarjeta			= COALESCE(F.FormasPagos.value('(creditCardInfo/lastCreditDigit)[1]','VARCHAR(16)'),'')
					  ,ds_vouchertarjeta		= COALESCE(F.FormasPagos.value('(creditCardInfo/AdditionalCode)[1]','VARCHAR(25)'),'')
					  ,ds_expiraciontarjeta		= '__/__'
					  ,ds_autorizaciontarjeta	= COALESCE(F.FormasPagos.value('(creditCardInfo/approvalCode)[1]','VARCHAR(25)'),'')
					  ,in_coutas				= 0
					  ,cd_banco					= '' 
					  ,ds_cheque				= '' 
					  ,ds_plaza					= '' 
					  ,ds_referencia			= '' 
					  ,ds_Poliza				= '' 
					  ,ds_PolizaAnexo			= '' 
					  ,am_valor					= COALESCE(F.FormasPagos.value('valuePay[1]','numeric(18,2)'),0)
				FROM(
					Select
						 cd_reserva		 = R.Bookings.value('../../../../../InternalLocator[1]','CHAR(6)')
						,cd_consecutivo	 = RIGHT(REPLACE(REPLACE(R.Bookings.value('(../ticketNumber)[1]','VARCHAR(13)'),CHR(9),''),CHR(10),''),10)--R.Bookings.value('../../locSource[1]','VARCHAR(25)')
						,FormasPagos = R.Bookings.query('./payment')
					FROM @NodoXML.nodes('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax/fees') As R(Bookings)
				) AS booking
				CROSS APPLY booking.FormasPagos.nodes('payment') F(FormasPagos)

			) AS FP
			ORDER BY cd_reserva,cd_consecutivo,cd_tipoitem,cd_codigo
			
			UPDATE tmp_Booking SET pasajeros=cd_consecutivo
			
			-- TEMP TABLE tmp_xmlpasajerosstable moved to BEGIN block ,xmlpasajero VARCHAR(max),xmlpasajero_ancillari VARCHAR(max),Cedula varchar(25))
			INSERT INTO v_xmlpasajerosstable(cd_consecutivo,Cedula)
			SELECT DISTINCT cd_consecutivo, cd_pax_cedula 
			FROM tmp_BookingGDS_Pasajeros ORDER BY cd_consecutivo 

			--v_xmlFee text;
			--select v_xmlFee = convert(varchar(max),(
			--SELECT	 in_orden, cd_reserva, cd_consecutivo, cd_conceptofac,cd_subcodigo, am_valor
			--FROM tmp_BookingGDS_FEE fee
			--FOR XML AUTO, ELEMENTS, ROOT('fees')))

		
			UPDATE x
			SET xmlpasajero = CONVERT(VARCHAR(MAX)
										, (SELECT	 ds_pax_firstnm		=	rtrim(ds_pax_firstnm) 
												,ds_pax_lastnm		=	rtrim(ds_pax_lastnm)
												,ds_pax_prefix		=	rtrim(ds_pax_prefix)
												,cd_pax_cedula		=	rtrim(cd_pax_cedula)
												,ds_pax_telefono	=	rtrim(ds_pax_telefono)
												,ds_tkt_number		=	rtrim(ds_tkt_number)
												,(convert(varchar(max),(
																	SELECT	 in_orden, cd_reserva, cd_consecutivo, cd_conceptofac,cd_subcodigo, am_valor
																	FROM tmp_BookingGDS_FEE fee
																	WHERE FEE.cd_consecutivo = Pasajero.ds_tkt_number
																	FOR XML AUTO, ELEMENTS, ROOT('fees')))
																	)	
										FROM tmp_BookingGDS_Pasajeros pasajero
										WHERE Pasajero.cd_consecutivo = x.cd_consecutivo and Pasajero.cd_pax_cedula = x.Cedula
										FOR XML AUTO, ELEMENTS, ROOT('pasajeros')
										)
									)
				,xmlpasajero_ancillari = CONVERT(VARCHAR(MAX)
										, (SELECT	 ds_pax_firstnm		=	rtrim(ds_pax_firstnm) 
												,ds_pax_lastnm		=	rtrim(ds_pax_lastnm)
												,ds_pax_prefix		=	rtrim(ds_pax_prefix)
												,cd_pax_cedula		=	rtrim(cd_pax_cedula)
												,ds_pax_telefono	=	rtrim(ds_pax_telefono)
												,ds_tkt_number		=	rtrim(ds_tkt_number)
										FROM tmp_BookingGDS_Pasajeros pasajero
										WHERE Pasajero.cd_consecutivo = x.cd_consecutivo and Pasajero.cd_pax_cedula = x.Cedula
										FOR XML AUTO, ELEMENTS, ROOT('pasajeros')
										)
									)
			FROM v_xmlpasajerosstable x
	

			UPDATE r
			SET r.pasajeros = case when r.ancillari = 1 then  REPLACE(REPLACE(p.xmlpasajero_ancillari,'&lt;','<'),'&gt;','>') else REPLACE(REPLACE(p.xmlpasajero,'&lt;','<'),'&gt;','>') end
				,ds_pax_number = (SELECT COUNT(*)
									FROM tmp_BookingGDS_Pasajeros p
									WHERE p.cd_consecutivo = r.cd_consecutivo and p.cd_pax_cedula = r.cd_pax_cedula
										
									)
			
			FROM tmp_Bookings r
			INNER JOIN v_xmlpasajerosstable p on p.cd_consecutivo = r.cd_consecutivo and r.cd_pax_cedula = p.Cedula
			
			
			UPDATE r
			SET r.itinerarios = CONVERT(VARCHAR(MAX)
										, (SELECT orden				=   itinerario.orden	
												,cd_aero_salida		=	rtrim(itinerario.cd_origen)	
												,cd_clase			=	rtrim(itinerario.cd_clase)
												,ds_fecha_salida	=	rtrim(itinerario.fecha_salida)
												,ds_hora_salida		=	rtrim(itinerario.hora_salida)
												,ds_hora_llegada	=	rtrim(itinerario.hora_llegada)
												,cd_aero_llegada	=	rtrim(itinerario.cd_destino)
												,cd_aero_siglas		=	rtrim(itinerario.cd_aero_siglas)
												,cd_farebasis		=	rtrim(itinerario.cd_farebasis)
												,ds_NumVuelo		=	rtrim(itinerario.ds_NumVuelo)
												,ds_TipoVuelo		=	rtrim(itinerario.ds_TipoVuelo)
												,am_valor			=	COALESCE(itinerario.am_valor,0)		
										FROM tmp_BookingGDS_Itinerarios itinerario
										WHERE Itinerario.cd_consecutivo = r.cd_codigo 
										FOR XML AUTO, ELEMENTS, ROOT('itinerarios')
										)
									)
				,r.ds_itinerario=CASE WHEN COALESCE(r.ds_itinerario,'')='' THEN (SELECT cd_itinerario = COALESCE(CASE WHEN LENGTH(cd_itinerario)>1 THEN LEFT(cd_itinerario,LENGTH(cd_itinerario)-1) ELSE cd_itinerario END,'')
									FROM( SELECT CONVERT(VARCHAR(MAX),(SELECT CASE WHEN Itinerario.orden=1 THEN COALESCE(rtrim(Itinerario.cd_origen),'')+'/'+COALESCE(rtrim(Itinerario.cd_destino),'')+'/' ELSE COALESCE(rtrim(Itinerario.cd_destino),'')+'/' END
										  FROM tmp_BookingGDS_Itinerarios Itinerario
										  WHERE Itinerario.cd_consecutivo = r.cd_codigo  
										  FOR XML PATH(''),TYPE)) AS 'cd_itinerario'
										) AS C
								  )
								ELSE r.ds_itinerario END   
				,r.ds_clases = (SELECT cd_clase = COALESCE(CASE WHEN LENGTH(cd_clase)>1 THEN LEFT(cd_clase,LENGTH(cd_clase)-1) ELSE cd_clase END,'')
								FROM( SELECT CONVERT(VARCHAR(MAX),(SELECT COALESCE(rtrim(Itinerario.cd_clase),'')+'/' 
									  FROM tmp_BookingGDS_Itinerarios Itinerario
									  WHERE Itinerario.cd_consecutivo = r.cd_codigo 
									  FOR XML PATH(''),TYPE)) AS 'cd_clase'
									) AS C
							  ) 
			FROM tmp_Bookings r
	
			
			UPDATE r
			SET r.Variables = CONVERT(VARCHAR(MAX)
										, (SELECT nombre		=   Variables.ds_nombre	
												 ,valor			=	COALESCE(Variables.ds_valor,'')		
										FROM tmp_BookingGDS_VariablesAdicionales Variables
										WHERE Variables.cd_consecutivo = r.cd_codigo 
										FOR XML AUTO, ELEMENTS, ROOT('Variables')
										)
									)
			FROM tmp_Bookings r
			
			UPDATE r
			SET r.am_tarifa	= v.am_tarifa 	
			   ,r.am_iva	= v.am_iva 
			   ,r.am_comb   = v.am_cmb 
			   ,r.am_tua    = v.am_tua 
			   ,r.am_vat    = v.am_otros
			   ,r.am_fp1	= v.am_total
			   ,r.am_valor  = v.am_total
			FROM tmp_Bookings r
			INNER JOIN tmp_BookingGDS_ValoresItems v ON v.cd_consecutivo = r.cd_consecutivo
			Where COALESCE(r.ancillari,0) = 0
			--select * from tmp_Bookings
			--UPDATE r	 
			--SET r.ds_pax_firstnm		=	rtrim(p.ds_pax_firstnm) 
			--	,r.ds_pax_lastnm		=	rtrim(p.ds_pax_lastnm)
			--	,r.ds_pax_prefix		=	rtrim(p.ds_pax_prefix)
			--	,r.cd_pax_cedula		=	rtrim(p.cd_pax_cedula)
			--	,r.ds_pax_telefono	=	rtrim(p.ds_pax_telefono)
			--FROM tmp_Bookings r 
			--INNER JOIN tmp_BookingGDS_Pasajeros p ON p.cd_consecutivo = r.cd_consecutivo AND p.id = 1
					 
			UPDATE r
			SET r.am_fp1				= CASE WHEN f.in_orden=1 AND COALESCE(f.am_valor,0)<>0 AND COALESCE(r.am_fp1,0)=0 THEN f.am_valor ELSE r.am_fp1 END
				,r.ds_cc_code			= CASE WHEN f.in_orden=1 THEN f.cd_tipotarjeta ELSE r.ds_cc_code END				
				,r.ds_cc_number			= CASE WHEN f.in_orden=1 THEN f.ds_numerotarjeta ELSE r.ds_cc_number END
				,r.in_cc_cuotas			= CASE WHEN f.in_orden=1 THEN f.in_coutas ELSE r.in_cc_cuotas END
				,r.ds_cc_vence			= CASE WHEN f.in_orden=1 THEN f.ds_expiraciontarjeta ELSE r.ds_cc_vence END							
				,r.ds_cc_autorizacion	= CASE WHEN f.in_orden=1 THEN f.ds_autorizaciontarjeta ELSE r.ds_cc_autorizacion END			
				,r.ds_cc_voucher		= CASE WHEN f.in_orden=1 THEN f.ds_vouchertarjeta ELSE r.ds_cc_voucher END 			
				,r.am_fp2				= CASE WHEN f.in_orden=2 THEN f.am_valor ELSE r.am_fp2 END
				,r.ds_cc_code2			= CASE WHEN f.in_orden=2 THEN f.cd_tipotarjeta ELSE r.ds_cc_code2 END					
				,r.ds_cc_number2		= CASE WHEN f.in_orden=2 THEN f.ds_numerotarjeta ELSE r.ds_cc_number2 END
				,r.in_cc_cuotas2		= CASE WHEN f.in_orden=2 THEN f.in_coutas ELSE r.in_cc_cuotas2 END
				,r.ds_cc_vence2			= CASE WHEN f.in_orden=2 THEN f.ds_expiraciontarjeta ELSE r.ds_cc_vence2 END
				,r.ds_cc_autorizacion2	= CASE WHEN f.in_orden=2 THEN f.ds_autorizaciontarjeta ELSE r.ds_cc_autorizacion2 END
				,r.ds_cc_voucher2		= CASE WHEN f.in_orden=2 THEN f.ds_vouchertarjeta ELSE r.ds_cc_voucher2 END
				,r.am_TarifaContado		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')=''  THEN r.am_Tarifa ELSE r.am_TarifaContado END 
				,r.am_IvaContado		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')=''  THEN r.am_Iva ELSE r.am_IvaContado END
				,r.am_OtrosContado		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')=''  THEN r.am_vat ELSE r.am_OtrosContado END + CASE WHEN (v_bl_IncluirCombaTarifa = 'S' OR v_bl_SumarCombustibleTarifaTkt='S') AND COALESCE(f.cd_tipotarjeta,'')='' THEN r.am_comb ELSE 0 END
				,r.am_TarifaCredito		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_Tarifa ELSE r.am_TarifaCredito END
				,r.am_IvaCredito		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_Iva ELSE r.am_IvaCredito END
				,r.am_OtrosCredito		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_vat+r.am_tua ELSE r.am_OtrosCredito END + CASE WHEN (v_bl_IncluirCombaTarifa = 'S' OR v_bl_SumarCombustibleTarifaTkt='S') AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_comb ELSE 0 END
				,r.am_vat				= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_vat+r.am_tua ELSE r.am_vat END + CASE WHEN v_bl_IncluirCombaTarifa = 'S' OR v_bl_SumarCombustibleTarifaTkt='S' THEN r.am_comb ELSE 0 END
			FROM tmp_Bookings r
			INNER JOIN tmp_BookingGDS_FormasPagos f ON f.cd_consecutivo = r.cd_consecutivo AND f.cd_tipoitem = R.cd_tipoitem  
			Where COALESCE(r.ancillari,0) = 0


			UPDATE r
			SET r.ds_cc_code			= CASE WHEN f.in_orden=1 THEN f.cd_tipotarjeta ELSE r.ds_cc_code END				
				,r.ds_cc_number			= CASE WHEN f.in_orden=1 THEN f.ds_numerotarjeta ELSE r.ds_cc_number END
				,r.in_cc_cuotas			= CASE WHEN f.in_orden=1 THEN f.in_coutas ELSE r.in_cc_cuotas END
				,r.ds_cc_vence			= CASE WHEN f.in_orden=1 THEN f.ds_expiraciontarjeta ELSE r.ds_cc_vence END							
				,r.ds_cc_autorizacion	= CASE WHEN f.in_orden=1 THEN f.ds_autorizaciontarjeta ELSE r.ds_cc_autorizacion END			
				,r.ds_cc_voucher		= CASE WHEN f.in_orden=1 THEN f.ds_vouchertarjeta ELSE r.ds_cc_voucher END 			
				,r.am_fp1				= CASE WHEN f.in_orden=1 AND COALESCE(f.am_valor,0)<>0 THEN r.am_tarifa+r.am_iva ELSE 0 END
				,r.am_TarifaContado		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')=''  THEN r.am_Tarifa ELSE r.am_TarifaContado END 
				,r.am_TarifaCredito		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_Tarifa ELSE r.am_TarifaCredito END
				,r.am_valor				= r.am_Tarifa + r.am_iva
				,r.am_IvaContado		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')=''  THEN r.am_Iva ELSE r.am_IvaContado END 
				,r.am_IvaCredito		= CASE WHEN f.in_orden=1 AND COALESCE(f.cd_tipotarjeta,'')<>'' THEN r.am_Iva ELSE r.am_IvaCredito END
			FROM tmp_Bookings r
			INNER JOIN tmp_BookingGDS_FormasPagos f ON f.cd_consecutivo = r.cd_consecutivo AND f.cd_tipoitem = R.cd_tipoitem  
			Where COALESCE(r.ancillari,0) = 1

			UPDATE r
			SET r.cd_FormaPagoTAO			= 	COALESCE(f.cd_codigo,'')
			   ,r.cd_TarjetaCreditoTAO		= 	COALESCE(f.cd_tipotarjeta,'')
			   ,r.cd_NumeroTarjetaTAO		=	COALESCE(f.ds_numerotarjeta,'')
			   ,r.cd_VencimientoTarjetaTAO	=	COALESCE(f. ds_expiraciontarjeta,'')
			   ,r.cd_NumeroPolizaTAO		=	COALESCE(f.ds_Poliza,'')
			   ,r.cd_AnexoPolizaTAO			=	COALESCE(f.ds_PolizaAnexo,'')
			   ,r.ds_AutorizacionTarjetaTAO	=	COALESCE(f.ds_autorizaciontarjeta,'')
			   ,r.ds_VoucherTarjetaTAO		=	COALESCE(f.ds_vouchertarjeta,'')
			   ,r.am_fptao					=	0--COALESCE(f.am_valor,0)
			FROM tmp_Bookings r
			INNER JOIN tmp_BookingGDS_FormasPagos f ON f.cd_consecutivo = r.cd_consecutivo AND f.cd_tipoitem = 'Fee'  
			Where COALESCE(r.ancillari,0) = 0 AND r.cd_tipoitem = 'Flight'
	--select * from tmp_BookingGDS_FormasPagos
	--select * from tmp_Bookings
			UPDATE r
			SET r.cd_TipoTransaccion='2'
			FROM tmp_Bookings r
			INNER JOIN tmp_EntidadesNOGDS e ON (e.cd_entidad=r.ds_tkt_prefix) or (e.cd_siglas = r.ds_aero_code)
			WHERE r.ds_tipoitem = 'Tiquete'

			v_XmlBooking text;

			SET v_XmlBooking = CONVERT(VARCHAR(MAX)
										,(SELECT OpBookingGDS				
												,ds_tipoitem				
												,cd_sucursal				
												,cd_implante				
												,bl_externo					
												,id_reserva					
												,iden_gds					
												,cd_codigo					
												,ds_fecha					
												,cd_tiqueteador				
												,cd_vendedor				
												,cd_cliente					
												,booking					
												,cd_TipoTransaccion			
												,ds_pax_number				
												,ds_pax_firstnm				
												,ds_pax_lastnm				
												,ds_pax_prefix				
												,cd_pax_cedula				
												,ds_pax_telefono			
												,ds_tkt_number				
												,ds_tkt_prefix				
												,ds_aero_code				
												,ds_moneda					
												,am_tarifa					
												,am_iva						
												,am_tua						
												,am_vat						
												,ds_cc_code					
												,ds_cc_number				
												,cd_farebasis				
												,cd_aero_siglas				
												,cd_aero_salida				
												,cd_aero_llegada			
												,orden						
												,ds_fecha_salida			
												,ds_hora_salida				
												,ds_hora_llegada			
												,cd_clase					
												,am_highfare				
												,am_lowfare					
												,am_fare					
												,ds_reasoncode				
												,ds_cliname					
												,ds_clidir					
												,ds_clicity					
												,ds_cliid					
												,ds_clirazoncial			
												,ds_cliname2				
												,ds_clilastname				
												,ds_clilastname2			
												,ds_clitel					
												,cd_clipais					
												,cd_clitipodoc				
												,cd_clitipotercero			
												,cd_CentroCostoCliente		
												,am_comb					
												,am_tao						
												,am_ivatao					
												,am_cap						
												,am_ivacap					
												,ds_cc_code2				
												,ds_cc_number2				
												,am_fp1						
												,am_fp2						
												,dt_entrega					
												,in_cars					
												,cd_carcode					
												,cd_confirmation			
												,cd_citysalida				
												,dt_retorno					
												,cd_cartype					
												,cd_currency				
												,cd_bookingsource			
												,cd_ratecode				
												,am_tarifarenta				
												,dt_checkin					
												,in_guests					
												,cd_city					
												,cd_htlchain				
												,dt_checkout				
												,ds_htlname					
												,in_habs					
												,cd_bed						
												,cd_htlcur					
												,am_htltarifa				
												,cd_agcur					
												,am_agtarifa				
												,ds_dir1					
												,ds_tel						
												,ds_fax						
												,cd_conceptofacturacion		
												,cd_TipoServicio = CASE WHEN COALESCE(cd_TipoServicio,'') ='' THEN (
																												SELECT TOP 1 TiposServicios.CD_CODIGO 
																												FROM ConceptoFacturacion
																												INNER JOIN tiposServicio_asignados ON tiposServicio_asignados.id_ConceptoFacturacion = ConceptoFacturacion.id
																												INNER JOIN TiposServicios ON TiposServicios.ID = tiposServicio_asignados.id_TipoServicio
																												WHERE ConceptoFacturacion.cd_codigo=cd_conceptofacturacion AND tiposServicio_asignados.bl_Valdeft=1 ) 
																										ELSE cd_TipoServicio END			
												,cd_Proveedores				
												,ds_Descrip					
												,cd_tktrevisado				
												,ds_itinerario				
												,ds_clases					
												,in_nacionalidad			
												,am_TarifaContado			
												,am_IvaContado				
												,am_OtrosContado			
												,am_TarifaCredito			
												,am_IvaCredito				
												,am_OtrosCredito			
												,am_Comision				
												,ds_Observaciones			
												,ds_ClienteEmail			
												,bl_ClienteActualizar		
												,bl_NotificacionMPD			
												,cd_NumeroPoliza			
												,cd_AnexoPoliza				
												,am_ValorPoliza				
												,cd_FormaPagoTAO			
												,cd_TarjetaCreditoTAO		
												,cd_NumeroTarjetaTAO		
												,cd_VencimientoTarjetaTAO	
												,cd_NumeroPolizaTAO			
												,cd_AnexoPolizaTAO			
												,am_PorDesFormaPagoTA		
												,ds_NumVuelo				
												,ds_TipoVuelo				
												,cd_Penalidad				
												,am_TasaCambio				
												,ds_cc_vence				
												,ds_cc_vence2				
												,ds_cc_autorizacion			
												,ds_cc_autorizacion2		
												,ds_cc_voucher				
												,ds_cc_voucher2				
												,ds_AutorizacionTarjetaTAO	
												,ds_VoucherTarjetaTAO		
												,am_fptao					
												,in_cc_cuotas				
												,in_cc_cuotas2				
												,in_cuotasTarjetaTAO		
												,in_NumTktConj				
												,cd_TipoTarifaTAO			
												,cd_TipoTiquete				
												,PCC						
												,PCC_Emite					
												,bl_ahorro					
												,in_CantidadTarifaTAO		
												,in_CantidadSegmentoTAO		
												,cd_tourcode				
												,ds_contrato				
												,am_valor					
												,cd_tourcode2				
												,cd_Ahorro					
												,cd_consecutivo				
												,cd_auxiliar				
												,cd_tipoventa				
												,cd_licitacion				
												,ds_evento					
												,ds_campolibre1				
												,ds_campolibre2				
												,cd_facturador				
												,cd_especialista			
												,cd_tipoformapagoproveedor	
												,cd_medioreservacion
												,itinerarios
												,pasajeros
												,reservaxml
											FROM (SELECT	 OpBookingGDS				= RTRIM(OpBookingGDS)
														,ds_tipoitem				= RTRIM(ds_tipoitem)
														,cd_sucursal				= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,13,'SUCURSALES',COALESCE(LTRIM(RTRIM(cd_sucursal)),'')),COALESCE(LTRIM(RTRIM(cd_sucursal)),''))
														,cd_implante				= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,14,'IMPLAMTES',COALESCE(LTRIM(RTRIM(cd_implante)),'')),'')
														,bl_externo					= bl_externo
														,id_reserva					= id_reserva
														,iden_gds					= iden_gds
														,cd_codigo					= RTRIM(booking.cd_codigo)
														,ds_fecha					= RTRIM(ds_fecha)
														,cd_tiqueteador				= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,4,'TIQUETEADORES',COALESCE(RTRIM(cd_tiqueteador),'')),COALESCE(RTRIM(cd_tiqueteador),''))
														,cd_vendedor				= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,44,'VENDEDORES',COALESCE(RTRIM(cd_vendedor),'')),COALESCE(RTRIM(cd_vendedor),''))
														,cd_cliente					= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,45,'CLIENTES',COALESCE(RTRIM(cd_cliente),'')),COALESCE(RTRIM(cd_cliente),''))
														--CASE WHEN C.Id IS NOT NULL THEN COALESCE(C.cd_codigo,'') ELSE COALESCE(RTRIM(cd_cliente),'') END
														,booking					= RTRIM(booking.booking)
														,cd_TipoTransaccion			= RTRIM(cd_TipoTransaccion)
														,ds_pax_number				= ds_pax_number
														,ds_pax_firstnm				= RTRIM(ds_pax_firstnm)
														,ds_pax_lastnm				= RTRIM(ds_pax_lastnm)
														,ds_pax_prefix				= RTRIM(ds_pax_prefix)
														,cd_pax_cedula				= RTRIM(cd_pax_cedula)
														,ds_pax_telefono			= RTRIM(ds_pax_telefono)
														,ds_tkt_number				= RTRIM(ds_tkt_number)
														,ds_tkt_prefix				= RTRIM(ds_tkt_prefix)
														,ds_aero_code				= RTRIM(ds_aero_code)
														,ds_moneda					= RTRIM(ds_moneda)
														,am_tarifa					= am_tarifa
														,am_iva						= am_iva
														,am_tua						= am_tua 
														,am_vat						= am_vat
														,ds_cc_code					= RTRIM(ds_cc_code)
														,ds_cc_number				= RTRIM(ds_cc_number)
														,cd_farebasis				= RTRIM(cd_farebasis)
														,cd_aero_siglas				= RTRIM(cd_aero_siglas)
														,cd_aero_salida				= RTRIM(cd_aero_salida)
														,cd_aero_llegada			= RTRIM(cd_aero_llegada)
														,orden						= orden
														,ds_fecha_salida			= RTRIM(ds_fecha_salida)
														,ds_hora_salida				= RTRIM(ds_hora_salida)
														,ds_hora_llegada			= RTRIM(ds_hora_llegada)
														,cd_clase					= RTRIM(cd_clase)
														,am_highfare				= am_highfare
														,am_lowfare					= am_lowfare
														,am_fare					= am_fare
														,ds_reasoncode				= RTRIM(ds_reasoncode)
														,ds_cliname					= RTRIM(ds_cliname)
														,ds_clidir					= RTRIM(ds_clidir)
														,ds_clicity					= RTRIM(ds_clicity)
														,ds_cliid					= RTRIM(ds_cliid)
														,ds_clirazoncial			= RTRIM(ds_clirazoncial)
														,ds_cliname2				= RTRIM(ds_cliname2)
														,ds_clilastname				= RTRIM(ds_clilastname)
														,ds_clilastname2			= RTRIM(ds_clilastname2)
														,ds_clitel					= RTRIM(ds_clitel)
														,cd_clipais					= RTRIM(cd_clipais)
														,cd_clitipodoc				= RTRIM(cd_clitipodoc)
														,cd_clitipotercero			= RTRIM(cd_clitipotercero)
														,cd_CentroCostoCliente		= RTRIM(cd_CentroCostoCliente)
														,am_comb					= am_comb
														,am_tao						= am_tao
														,am_ivatao					= am_ivatao
														,am_cap						= am_cap
														,am_ivacap					= am_ivacap
														,ds_cc_code2				= RTRIM(ds_cc_code2)
														,ds_cc_number2				= RTRIM(ds_cc_number2)
														,am_fp1						= am_fp1	
														,am_fp2						= am_fp2
														,dt_entrega					= RTRIM(dt_entrega)
														,in_cars					= in_cars
														,cd_carcode					= RTRIM(cd_carcode)
														,cd_confirmation			= RTRIM(cd_confirmation)
														,cd_citysalida				= RTRIM(cd_citysalida)
														,dt_retorno					= RTRIM(dt_retorno)
														,cd_cartype					= RTRIM(cd_cartype)
														,cd_currency				= RTRIM(cd_currency)
														,cd_bookingsource			= RTRIM(cd_bookingsource)
														,cd_ratecode				= RTRIM(cd_ratecode)
														,am_tarifarenta				= am_tarifarenta
														,dt_checkin					= RTRIM(dt_checkin)
														,in_guests					= in_guests
														,cd_city					= RTRIM(cd_city)
														,cd_htlchain				= RTRIM(cd_htlchain)
														,dt_checkout				= RTRIM(dt_checkout)
														,ds_htlname					= RTRIM(ds_htlname)
														,in_habs					= in_habs
														,cd_bed						= RTRIM(cd_bed)
														,cd_htlcur					= RTRIM(cd_htlcur)
														,am_htltarifa				= am_htltarifa
														,cd_agcur					= RTRIM(cd_agcur)
														,am_agtarifa				= am_agtarifa
														,ds_dir1					= RTRIM(ds_dir1)
														,ds_tel						= RTRIM(ds_tel)
														,ds_fax						= RTRIM(ds_fax)
														,cd_conceptofacturacion		= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,8,'CONCEPTOSFACTURACION',COALESCE(RTRIM(cd_conceptofacturacion),'')),COALESCE(RTRIM(cd_conceptofacturacion),''))
														,cd_TipoServicio			= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,5,'TIPOSERVICIO',COALESCE(RTRIM(cd_TipoServicio),'')),COALESCE(RTRIM(cd_TipoServicio),''))
														,cd_Proveedores				= COALESCE(dbo.fnza_Get_ValorMaestroInterfazVariable(v_cd_interfaces,33,'PROVEEDORES',COALESCE(RTRIM(cd_Proveedores),'')),COALESCE(RTRIM(cd_Proveedores),''))
														--CASE WHEN P.id IS NOT NULL THEN COALESCE(P.cd_codigo,'') ELSE COALESCE(RTRIM(cd_Proveedores),'') END
														,ds_Descrip					= RTRIM(ds_Descrip)
														,cd_tktrevisado				= RTRIM(cd_tktrevisado)
														,ds_itinerario				= RTRIM(ds_itinerario)
														,ds_clases					= RTRIM(ds_clases)
														,in_nacionalidad			= in_nacionalidad
														,am_TarifaContado			= am_TarifaContado
														,am_IvaContado				= am_IvaContado
														,am_OtrosContado			= am_OtrosContado
														,am_TarifaCredito			= am_TarifaCredito
														,am_IvaCredito				= am_IvaCredito
														,am_OtrosCredito			= am_OtrosCredito
														,am_Comision				= am_Comision
														,ds_Observaciones			= RTRIM(ds_Observaciones)
														,ds_ClienteEmail			= RTRIM(ds_ClienteEmail)
														,bl_ClienteActualizar		= bl_ClienteActualizar
														,bl_NotificacionMPD			= bl_NotificacionMPD
														,cd_NumeroPoliza			= RTRIM(cd_NumeroPoliza)
														,cd_AnexoPoliza				= RTRIM(cd_AnexoPoliza)
														,am_ValorPoliza				= am_ValorPoliza
														,cd_FormaPagoTAO			= RTRIM(cd_FormaPagoTAO)
														,cd_TarjetaCreditoTAO		= RTRIM(cd_TarjetaCreditoTAO)
														,cd_NumeroTarjetaTAO		= RTRIM(cd_NumeroTarjetaTAO)
														,cd_VencimientoTarjetaTAO	= RTRIM(cd_VencimientoTarjetaTAO)
														,cd_NumeroPolizaTAO			= RTRIM(cd_NumeroPolizaTAO)
														,cd_AnexoPolizaTAO			= RTRIM(cd_AnexoPolizaTAO)
														,am_PorDesFormaPagoTA		= am_PorDesFormaPagoTA
														,ds_NumVuelo				= RTRIM(ds_NumVuelo)
														,ds_TipoVuelo				= RTRIM(ds_TipoVuelo)
														,cd_Penalidad				= RTRIM(cd_Penalidad)
														,am_TasaCambio				= am_TasaCambio
														,ds_cc_vence				= RTRIM(ds_cc_vence)
														,ds_cc_vence2				= RTRIM(ds_cc_vence2)
														,ds_cc_autorizacion			= RTRIM(ds_cc_autorizacion)
														,ds_cc_autorizacion2		= RTRIM(ds_cc_autorizacion2)
														,ds_cc_voucher				= RTRIM(ds_cc_voucher)
														,ds_cc_voucher2				= RTRIM(ds_cc_voucher2)
														,ds_AutorizacionTarjetaTAO	= RTRIM(ds_AutorizacionTarjetaTAO)
														,ds_VoucherTarjetaTAO		= RTRIM(ds_VoucherTarjetaTAO)
														,am_fptao					= am_fptao
														,in_cc_cuotas				= in_cc_cuotas
														,in_cc_cuotas2				= in_cc_cuotas2
														,in_cuotasTarjetaTAO		= in_cuotasTarjetaTAO
														,in_NumTktConj				= in_NumTktConj
														,cd_TipoTarifaTAO			= RTRIM(cd_TipoTarifaTAO)
														,cd_TipoTiquete				= RTRIM(cd_TipoTiquete)
														,PCC						= RTRIM(PCC)
														,PCC_Emite					= RTRIM(PCC_Emite)
														,bl_ahorro					= bl_ahorro
														,in_CantidadTarifaTAO		= in_CantidadTarifaTAO
														,in_CantidadSegmentoTAO		= in_CantidadSegmentoTAO
														,cd_tourcode				= RTRIM(cd_tourcode)
														,ds_contrato				= RTRIM(ds_contrato)
														,am_valor					= am_valor
														,cd_tourcode2				= RTRIM(cd_tourcode2)
														,cd_Ahorro					= RTRIM(cd_Ahorro)
														,cd_consecutivo				= RTRIM(cd_consecutivo)
														,cd_auxiliar				= RTRIM(cd_auxiliar)
														,cd_tipoventa				= RTRIM(cd_tipoventa)
														,cd_licitacion				= RTRIM(cd_licitacion)
														,ds_evento					= RTRIM(ds_evento)
														,ds_campolibre1				= RTRIM(ds_campolibre1)
														,ds_campolibre2				= RTRIM(ds_campolibre2)
														,cd_facturador				= RTRIM(cd_facturador)
														,cd_especialista			= RTRIM(cd_especialista)
														,cd_tipoformapagoproveedor	= RTRIM(cd_tipoformapagoproveedor)
														,cd_medioreservacion		= RTRIM(cd_medioreservacion)
														,itinerarios				= REPLACE(REPLACE(RTRIM(CONVERT(VARCHAR(MAX),itinerarios)),'<itinerarios>',''),'</itinerarios>','')
														,pasajeros					= REPLACE(REPLACE(RTRIM(CONVERT(VARCHAR(MAX),pasajeros)),'<pasajeros>',''),'</pasajeros>','')
														,Variables					= REPLACE(REPLACE(RTRIM(CONVERT(VARCHAR(MAX),Variables)),'<variables>',''),'</variables>','')
														,reservaxml					= reservaxml
												FROM tmp_Bookings booking
												LEFT JOIN dbo.EquivalenciasInterfaces C ON C.cd_codigoInte = booking.cd_cliente AND C.Id_Interfaces = v_id_interfaces AND C.cd_maestro = 'CLIENTES' 
												LEFT JOIN dbo.EquivalenciasInterfaces P ON P.cd_codigoInte = booking.cd_Proveedores AND P.Id_Interfaces = v_id_interfaces AND P.cd_maestro = 'PROVEEDORES'
												WHERE (booking.am_tarifa <> 0 OR COALESCE(booking.cd_consecutivo,'')<>'') 
								) AS booking
								FOR XML AUTO, ELEMENTS, ROOT('bookings')
							)
				)
			
			IF p_BlSelect = 0
			BEGIN 
					SELECT XmlBooking=REPLACE(REPLACE(v_XmlBooking,'&lt;','<'),'&gt;','>')
				
			END
			ELSE 
			BEGIN 
					SELECT p_XMLOutput =REPLACE(REPLACE(v_XmlBooking,'&lt;','<'),'&gt;','>')
			END 
			--SELECT XmlBooking=CONVERT(XML,REPLACE(REPLACE(v_XmlBooking,'&lt;','<'),'&gt;','>'))  
			----select cd_consecutivo,convert(xml,xmlpasajero) from v_xmlpasajerosstable
			--SELECT * FROM tmp_Bookings
			--SELECT * FROM tmp_BookingGDS_Pasajeros
		
	
	EXCEPTION WHEN OTHERS THEN
	
		
		SET v_TextoRaiserror = ISNULL ( ERROR_MESSAGE() , '')
	
		SET v_TextoRaiserror =	CHAR(13) + CHR(10) +
								--'Operacion: ' +  v_Operacion + CHAR(13) + CHR(10) + 
								--'Registro: ' +  CONVERT(VARCHR(10), COALESCE(v_RegistroActual, 0)) + --' - Cliente: ' + COALESCE(v_IdCliente,'') + CHAR(13) + CHR(10) + 
								'Ha ocurrido un error. Información para soporte tecnico:'			+ CHAR(13)+ CHR(10) + CHAR(13)+ CHR(10) +
							    'Numero: ' + COALESCE(CAST(ERROR_NUMBER()   AS VARCHR(10)),'') 		+ CHAR(13)+ CHR(10) + CHAR(13)+ CHR(10) +
								'Mensaje: ' + v_TextoRaiserror 					   		+ CHAR(13)+ CHR(10) + CHAR(13)+ CHR(10) +
							 	'Severidad: ' + COALESCE(CAST(ERROR_SEVERITY() AS VARCHR(10)),'') 	+ CHAR(13)+ CHR(10) + CHAR(13)+ CHR(10) +
							 	'Estado: ' + COALESCE(CAST(ERROR_STATE()    AS VARCHR(10)),'') 		+ CHAR(13)+ CHR(10) + CHAR(13)+ CHR(10) +
								'Procedimiento: ' + COALESCE(ERROR_PROCEDURE(),'')					+ CHAR(13)+ CHR(10) + CHAR(13)+ CHR(10) +
								'Linea: ' + COALESCE(CAST(ERROR_LINE() 	   AS VARCHR(10)),'');
	
	RAISERROR ( v_TextoRaiserror , 16, 1)
	
	

	RETURN
END;
$procedure$;

