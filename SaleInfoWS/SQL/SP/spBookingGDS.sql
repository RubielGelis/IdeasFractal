CREATE OR REPLACE PROCEDURE public."spBookingGDS"(
	p_Op varchar(15),
	p_branch VARCHAR(5) = 'OFP',
	p_implant VARCHAR(5) = NULL, 
	p_external BOOLEAN = false,
	p_bookingId INTEGER = NULL ,
	p_gds INTEGER=1,
	p_interfaces INTEGER=1,
	p_code VARCHAR(12) = null,
	p_date VARCHAR(8)  = null,
	p_tiquetPrinter VARCHAR(6) = null,
	p_seller VARCHAR(3) = null,
	p_client VARCHAR(25) = null,
	p_booking text = null,
	p_typetransaction VARCHAR(1) = '1',
	-- Parametros de Productos (BookingProductGDS)
	p_amount DOUBLE PRECISION = null,
	p_tax DOUBLE PRECISION = null,
	p_perTax DOUBLE PRECISION = null,
	p_fee DOUBLE PRECISION = null,
	p_vat DOUBLE PRECISION = null,
	p_provider VARCHAR(25) = null,
	p_status VARCHAR(25) = null,
	-- Parametros de Tipificacion Adicional
	p_productType VARCHAR(25) = null,
	p_productService TEXT = null,
	p_productDescription TEXT = null,
	p_taxCode VARCHAR(25) = null,
	p_taxName VARCHAR(50) = null,
	p_taxType VARCHAR(25) = null,
	p_taxismain  BOOLEAN = false,	
	p_feeCode VARCHAR(25) = null,
	p_feeName VARCHAR(50) = null,
	p_feeType VARCHAR(25) = null,
	p_feeDescription TEXT = null,
	p_feeBillingConcept TEXT = null,
	p_feeServiceType TEXT = null,
	-- Parametros Adicionales (Pagos, Variables, etc)
	p_bookingProductId INTEGER = null,
	p_paymentCode VARCHAR(50) = null,
	p_paymentName VARCHAR(50) = null,
	p_paymentType VARCHAR(50) = null,
	p_creditCardType VARCHAR(25) = null,
	p_quotas INTEGER = null,
	p_square VARCHAR(30) = null,
	p_policy VARCHAR(25) = null,
	p_policyAnnex VARCHAR(25) = null,
	p_varName TEXT = null,
	p_varValue TEXT = null,

	-- Parametros de Itinerario (BookingProductItineraryGDS)
	p_orden INTEGER = null,
	p_origin VARCHAR(3) = null,
	p_destination VARCHAR(3) = null,
	p_class VARCHAR(2) = null,
	p_checkInDate TIMESTAMP = null,
	p_checkOutDate TIMESTAMP = null,
	p_terminal VARCHAR(25) = null,
	p_prestadoraCode VARCHAR(3) = null,
	p_farebasis VARCHAR(25) = null,
	p_Numflight VARCHAR(25) = null,
	p_Typeflight VARCHAR(1) = null,

	-- Parametros de Pasajeros (BookingProductPassangerGDS)
	p_firstName VARCHAR(50) = null,
	p_lastName VARCHAR(50) = null,
	p_documentType VARCHAR(25) = null,
	p_identification VARCHAR(25) = null,
	p_email VARCHAR(100) = null,
	p_phone VARCHAR(25) = null,
	p_type VARCHAR(25) = null,

	-- Parametros de Pagos (BookingProductPaymentGDS)
	p_creditCard VARCHAR(2) = null,
	p_creditCardNumber VARCHAR(16) = null,
	p_expirationDate VARCHAR(5) = null,
	p_feeNumber INTEGER = null,
	p_bank VARCHAR(25) = null,
	p_check VARCHAR(25) = null,
	p_authorization VARCHAR(25) = null,
	p_voucher VARCHAR(25) = null,
	p_reference VARCHAR(50) = null,
	
	-- Parametros de Productos (BookingProductGDS)
	p_quantity INTEGER = 1,
	p_cost DOUBLE PRECISION = 0,
	p_prestadoraInitials VARCHAR(25) = NULL,
	p_prestadoraDist VARCHAR(25) = NULL,
	p_nights INTEGER = NULL,
	p_paxAdults INTEGER = NULL,
	p_paxChildren INTEGER = NULL,
	p_billingConcept TEXT = NULL,
	p_sellerCom DOUBLE PRECISION = NULL,
	p_ticketPrinterCom DOUBLE PRECISION = NULL,
	p_inNationality INTEGER = NULL,
	p_conjunction INTEGER = 0,
	p_revised VARCHAR(25) = NULL,
	p_typeproduct VARCHAR(25) = NULL,
	p_penalty VARCHAR(25) = NULL,
	
	-- Extra (necesario para la firma pero obsoleto para la logica limpia)
	p_Bookingxml TEXT = null,
	INOUT p_id_out INTEGER DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE
--Variable. ;
-- Obtiene el id de la Booking
p_Id_BookingGDS INTEGER;
	p_codeador_aux VARCHAR(6);
	p_iata VARCHAR(25);
	p_Bookingaux TEXT;
p_AerolineaExterna VARCHAR(3);
	p_CodAerolineaExterna VARCHAR(2);
	p_bl_cliente BOOLEAN;
	p_bl_tomarpccsucimp VARCHAR(1);
	p_bl_IncluirCombaTarifa VARCHAR(1);
p_bl_SumarCombustibleTarifaTkt VARCHAR(1);
	p_AerolineasNoAceptanTcBSP Varchar(250);
p_bl_usarimplanteFullFilment INTEGER;
	p_Id_implanteFullFilment INTEGER;
	p_state VARCHAR(25);
	p_bl_CotizacionFacAuto BOOLEAN;
p_retval	INTEGER; -- Valor de retorno de este procedimiento: 0:Exito; 1:Error(Bloque Catch)
p_id_FormasPago INTEGER;
	p_id_TarjetasCredito INTEGER;
p_RESPETARVALOR INTEGER;
p_msgValoresGDS TEXT;
	p_BookingsSabreUnicaNacionalidad Varchar(50);
	p_cd_FormaPago VARCHAR(3);
	p_in_nacionalidad INTEGER;
	p_am_tarifa DOUBLE PRECISION := 0;
	p_am_comb DOUBLE PRECISION := 0;
	p_am_vat DOUBLE PRECISION := 0;
	p_am_TarifaContado DOUBLE PRECISION := 0;
	p_am_TarifaCredito DOUBLE PRECISION := 0;
	p_am_OtrosContado DOUBLE PRECISION := 0;
	p_am_OtrosCredito DOUBLE PRECISION := 0;
	p_ds_cc_code VARCHAR(2);
	p_PCC VARCHAR(10);
	p_PCC_Emite VARCHAR(10);
	p_ds_cliid VARCHAR(25);
	p_ds_clidir VARCHAR(100);
	p_ds_clicity VARCHAR(50);
	p_ds_clirazoncial VARCHAR(250);
	p_ds_clitel VARCHAR(25);
	p_cd_clipais VARCHAR(25);
	p_cd_CentroCostoCliente VARCHAR(50);
	p_ds_ClienteEmail VARCHAR(100);
	p_ds_contrato VARCHAR(50);
	p_cd_tourcode VARCHAR(25);
	p_cd_tourcode2 VARCHAR(25);
	p_exchangeRate DOUBLE PRECISION := 1;
	p_ds_cc_autorizacion VARCHAR(25);
	p_ds_cc_voucher VARCHAR(25);
	p_ds_cc_autorizacion2 VARCHAR(25);
	p_ds_cc_voucher2 VARCHAR(25);
	p_ds_AutorizacionTarjetaTAO VARCHAR(25);
	p_ds_VoucherTarjetaTAO VARCHAR(25);
	p_in_cantpax INTEGER;
	p_cd_Pseudo VARCHAR(10);
	p_cd_conceptofacturacion VARCHAR(10);
	p_cd_TipoServicio VARCHAR(10);
	p_cd_Proveedores VARCHAR(25);
	p_ds_Descrip TEXT;
	p_ds_pax_firstnm VARCHAR(50);
	p_ds_pax_lastnm VARCHAR(50);
	p_cd_pax_cedula VARCHAR(25);
	p_cd_licitacion VARCHAR(25);
	p_cd_FormaPagoTAO VARCHAR(3);
	p_cd_TarjetaCreditoTAO VARCHAR(2);
	p_cd_NumeroTarjetaTAO VARCHAR(16);
	p_cd_VencimientoTarjetaTAO VARCHAR(5);
	p_in_cuotasTarjetaTAO INTEGER;
	p_observation TEXT;
	p_cd_TarjetaCredito VARCHAR(2);
	p_cd_NumeroTarjeta VARCHAR(16);
	p_cd_VencimientoTarjeta VARCHAR(5);
	p_in_CuotasTarjeta INTEGER;
	p_codefp VARCHAR(10);
	p_cd_tipotarjeta VARCHAR(2);
	p_ds_numerotarjeta VARCHAR(16);
	p_ds_cc_number VARCHAR(16);
	p_ds_expiraciontarjeta VARCHAR(5);
	p_in_coutas INTEGER;
	p_in_cc_cuotas INTEGER;
	p_description TEXT;
	p_currency VARCHAR(3) := 'COP';
	p_bl_usada INTEGER := 0;
	p_bl_NotificacionMPD INTEGER := 0;
	p_error INTEGER := 0;
	p_bl_usado INTEGER := 0;
	p_in_cc_cuotas2 INTEGER;
	p_ds_cc_vence VARCHAR(5);
	p_ds_cc_vence2 VARCHAR(5);
	p_ds_cc_autorizacion_aux VARCHAR(25);
	p_ds_cc_voucher_aux VARCHAR(25);
	p_cd_citysalida VARCHAR(3);
	p_cd_city VARCHAR(3);
	p_ds_fecha_salida VARCHAR(8);
	p_ds_hora_salida VARCHAR(5);
	p_ds_hora_llegada VARCHAR(5);
	p_cd_aero_salida VARCHAR(3);
	p_cd_aero_llegada VARCHAR(3);
	p_cd_aero_siglas VARCHAR(3);
	p_am_tarifa_aux DOUBLE PRECISION;
	v_BookingProductId INTEGER;
	v_Id_BookingProductItineraryGDS INTEGER;
	v_ItineraryCount INTEGER;
	v_checkIn TIMESTAMP;
	v_checkOut TIMESTAMP;
	v_bookingCode VARCHAR(25);
	v_fecha_salida TEXT;
	v_Y TEXT; v_M TEXT; v_D TEXT;
	v_Mr INTEGER; v_YAr INTEGER;
	v_Yr INTEGER;
	v_inNationality INTEGER;
	v_id_master_branch INTEGER;
	v_id_master_implant INTEGER;
	v_id_master_client INTEGER;
	v_id_master_seller INTEGER;
	v_id_master_provider INTEGER;
	v_id_master_product INTEGER;
	v_id_master_ticketprinter INTEGER;
	v_id_master_prestadora INTEGER;

BEGIN

	-- Obtención de IDs de Maestros para equivalencias en un solo query
	SELECT 
		MAX(CASE WHEN code = 'Branch' THEN id END),
		MAX(CASE WHEN code = 'Implant' THEN id END),
		MAX(CASE WHEN code = 'Client' THEN id END),
		MAX(CASE WHEN code = 'Seller' THEN id END),
		MAX(CASE WHEN code = 'Provider' THEN id END),
		MAX(CASE WHEN code = 'Product' THEN id END),
		MAX(CASE WHEN code = 'TicketPrinter' THEN id END),
		MAX(CASE WHEN code = 'Prestadora' THEN id END)
	INTO 
		v_id_master_branch, v_id_master_implant, v_id_master_client, 
		v_id_master_seller, v_id_master_provider, v_id_master_product,
		v_id_master_ticketprinter, v_id_master_prestadora
	FROM public."Master"
	WHERE code IN ('Branch', 'Implant', 'Client', 'Seller', 'Provider', 'Product', 'TicketPrinter', 'Prestadora');

	-- Aplicar equivalencias iniciales a los parámetros recibidos
	p_branch := public."fnEquivalenceInterface"(p_interfaces, v_id_master_branch, p_branch);
	p_implant := public."fnEquivalenceInterface"(p_interfaces, v_id_master_implant, p_implant);
	p_client := public."fnEquivalenceInterface"(p_interfaces, v_id_master_client, p_client);
	p_seller := public."fnEquivalenceInterface"(p_interfaces, v_id_master_seller, p_seller);
	p_provider := public."fnEquivalenceInterface"(p_interfaces, v_id_master_provider, p_provider);
	p_tiquetPrinter := public."fnEquivalenceInterface"(p_interfaces, v_id_master_ticketprinter, p_tiquetPrinter);
	p_productType := public."fnEquivalenceInterface"(p_interfaces, v_id_master_product, p_productType);
	p_prestadoraCode := public."fnEquivalenceInterface"(p_interfaces, v_id_master_prestadora, p_prestadoraCode);

	p_RESPETARVALOR := 0;
--SELECT (CASE WHEN value='S' THEN 1 ELSE 0 END) INTO p_bl_CotizacionFacAuto FROM public."SystemParameter" Where  code = '526' ;

	--IF EXISTS (Select * From public."BookingGDS" Where id = p_bookingId AND Booking LIKE '%RESPETARVALOR%') OR EXISTS (Select * From public."SystemParameter" Where code = '506' And value = 'S') THEN
	--p_RESPETARVALOR := 1;
	--END IF;

	p_msgValoresGDS := '';

	--IF p_external = true THEN
	----Obtenemos la aerolinea externa
		--SELECT value INTO p_AerolineaExterna FROM public."SystemParameter" WHERE code = '239';
		--SELECT initials INTO p_CodAerolineaExterna FROM public."Prestadora" WHERE code = p_AerolineaExterna;
	--END IF;
	--SELECT value INTO p_bl_tomarpccsucimp From public."SystemParameter" Where code = '373';
	--SELECT value INTO p_bl_IncluirCombaTarifa From public."SystemParameter" Where code = '419' ;
	--SELECT value INTO p_bl_SumarCombustibleTarifaTkt From public."SystemParameter" Where code = '568' ;


	--SELECT value INTO p_BookingsSabreUnicaNacionalidad From public."SystemParameter" Where code = '501';
	--IF p_BookingsSabreUnicaNacionalidad = 'Internacional' THEN
		--p_in_nacionalidad := 2;
	--END IF;
		--IF p_BookingsSabreUnicaNacionalidad = 'Nacional' THEN
		--p_in_nacionalidad := 1;
	--END IF;
	--IF p_bl_IncluirCombaTarifa = 'S' THEN
	 --p_am_tarifa := p_am_tarifa+p_am_comb;
	 --if p_am_TarifaContado>0 and p_am_TarifaCredito = 0 THEN
		--p_am_TarifaContado := p_am_TarifaContado+p_am_comb;
	 --END IF;
	--IF p_am_TarifaCredito>0 and p_am_TarifaContado = 0 THEN
		--p_am_TarifaCredito := p_am_TarifaCredito+p_am_comb;
	 --end IF;
	 
	 --p_am_vat := p_am_vat-p_am_comb;
	 --if p_am_OtrosContado>0 and p_am_OtrosCredito = 0 THEN
		--p_am_OtrosContado := p_am_OtrosContado - p_am_comb;
	 --END IF;
	--IF p_am_OtrosCredito>0 and p_am_OtrosContado = 0 THEN
		--p_am_OtrosCredito := p_am_OtrosCredito - p_am_comb;
	 --END IF;
	--IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')='' THEN
		--p_am_TarifaContado := p_am_TarifaContado+p_am_comb;
	 --END IF;
	--IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')<>'' THEN
		--p_am_TarifaCredito := p_am_TarifaCredito+p_am_comb;
	 --end IF;

	 --p_am_comb := 0;
	--END IF;

	--IF p_bl_SumarCombustibleTarifaTkt = 'S' THEN
		 --p_am_tarifa := p_am_tarifa-p_am_comb;
		 --if p_am_TarifaContado>0 and p_am_TarifaCredito = 0 THEN
			--p_am_TarifaContado := p_am_TarifaContado-p_am_comb;
		 --END IF;
		--IF p_am_TarifaCredito>0 and p_am_TarifaContado = 0 THEN
			--p_am_TarifaCredito := p_am_TarifaCredito-p_am_comb;
		 --end IF;
		 --p_am_vat := p_am_vat-p_am_comb;
		 --if p_am_OtrosContado>0 and p_am_OtrosCredito = 0 THEN
			--p_am_OtrosContado := p_am_OtrosContado - p_am_comb;
		 --END IF;
		--IF p_am_OtrosCredito>0 and p_am_OtrosContado = 0 THEN
			--p_am_OtrosCredito := p_am_OtrosCredito - p_am_comb;
		 --END IF;
		--IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')='' THEN
			--p_am_TarifaContado := p_am_TarifaContado+p_am_comb;
		 --END IF;
		--IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')<>'' THEN
			--p_am_TarifaCredito := p_am_TarifaCredito+p_am_comb;
		 --end IF;
	
		 --p_am_comb := 0;
	--END IF;

--Ubicacion	
	IF COALESCE(p_PCC,'') <> '' AND p_bl_tomarpccsucimp = 'S' THEN
		p_branch := NULL;
		p_implant := NULL;
	
		SELECT code INTO p_branch
		FROM public."Branch" b WHERE b.code = p_PCC;  --AND b."Inactive" = false);

		--Si el pcc que emite es el mismo que factura, quiere decir que el emisor no es una sucursal
		IF COALESCE(p_PCC,'') <> COALESCE(p_PCC_Emite,'') THEN
			SELECT i.code INTO p_implant
				--p_bl_usarimplanteFullFilment = bl_usarimplanteFullFilment,
				--p_Id_implanteFullFilment = Id_implanteFullFilment
			FROM public."Implant" i
			WHERE (i.code = p_PCC_Emite OR i.code = p_PCC_Emite);

			IF p_bl_usarimplanteFullFilment = 1 AND p_Id_implanteFullFilment IS NOT NULL THEN
				SELECT s.code INTO p_branch
				FROM public."Branch" s
				INNER JOIN public."Implant" i ON i."branchId" = s.id
				WHERE i.id = p_Id_implanteFullFilment;
			END IF; 
		END IF;
		--Si el PCC que emite es igual al que factura y no existe como sucursal, entonces es un implante 
		IF COALESCE(p_PCC,'') = COALESCE(p_PCC_Emite,'') AND p_branch IS NULL THEN
			SELECT b.code, i.code INTO p_branch, p_implant
			FROM public."Implant" i
			INNER JOIN public."Branch" b ON b.id = i."branchId"
			WHERE (i.code = p_PCC_Emite OR i.code = p_PCC_Emite);
		END IF; 
	ELSE
		--Validamos la sucursal
		If Not Exists(Select * From public."Branch" Where code = p_branch) THEN
			p_branch := 'OFP';
		END IF;
	END IF;
	--Validamos el implante
	If Not Exists(Select * From public."Implant" Where code = p_implant) THEN
		p_implant := NULL;
	END IF;

	/*inicio rgelis 2013/07/06 req.15175*/
	IF (COALESCE(p_cd_FormaPagoTAO,'')='CA') THEN
		p_cd_FormaPagoTAO := 'EFE';
	END IF;
		IF (COALESCE(p_cd_FormaPagoTAO,'')='PO') THEN
		p_cd_FormaPagoTAO := 'POL';
	END IF;
	--IF (COALESCE(p_cd_fp1,'')='CA') THEN
	--	p_cd_fp1 := 'EFE';
	--END IF;
	--	IF (COALESCE(p_cd_fp2,'')='CA') THEN
	--	p_cd_fp2 := 'EFE';
	--END IF;
	--	IF (COALESCE(p_cd_fp3,'')='CA') THEN
	--	p_cd_fp3 := 'EFE';
	--END;	

	--IF EXISTS (SELECT * FROM public."SystemParameter" where code = '432' and value = 'S') THEN
	--	p_codeador_aux := SUBSTRING(p_booking,136,2);
	--	p_tiquetPrinter := p_codeador_aux;
	--END IF;

	--Obtenemos el codigo IATA - JARG - 2015/10/16
	IF p_gds IN (6,8,9) THEN
		p_iata := '';
	ELSE
		p_iata := replace(SUBSTRING(p_booking,46,10),' ','');
	END IF;

	/*CREATE TABLE #CamposGDSValores	(Tiqueteador VARCHAR(6)
									,Vendedor VARCHAR(3)
									,Cliente VARCHAR(25)
									,RazonSocialCliente VARCHAR(250)
									,DireccionCliente VARCHAR(50)
									,PaisCliente VARCHAR(25)
									,TelefonoCliente VARCHAR(25)
									,EmailCliente VARCHAR(100)
									,CiudadCliente VARCHAR(50)
									,CodigoIata VARCHAR(25)
									,PasaportePax VARCHAR(25)
									,over VARCHAR(25)
									,tourcodeBooking VARCHAR(25)
									,tourcodetiquete VARCHAR(25)
									,contrato VARCHAR(25)
									,Evento VARCHAR(250)
									,Categoria VARCHAR(25)
									,centrocosto VARCHAR(50)
									,sucursal VARCHAR(5)
									,implante VARCHAR(5)
									,TasaCambio DOUBLE PRECISION
									,Autorizacion VARCHAR(25) --inicio rgelis 2017/06/05 req.48084
									,Voucher VARCHAR(25)
									,Autorizacion2 VARCHAR(25)
									,Voucher2 VARCHAR(25)
									,AutorizacionTAO VARCHAR(25)
									,VoucherTAO VARCHAR(25)	  --fin rgelis 2017/06/05 req.48084
									,CantidadPasajero INTEGER 
									,Pseudo VARCHAR(5) 
									,Proveedor VARCHAR(25) --ini rgelis 2019/09/26 req.103173
									,Conceptofacturacion VARCHAR(3)
									,Tiposervicio VARCHAR(3)
									,DescripcionProduct VARCHAR(500)
									,Pasajeros VARCHAR(100)
									,PasajerosNombres VARCHAR(50)
									,PasajerosApellidos VARCHAR(50) --fin rgelis 2019/09/26 req.103173
									,PasajerosCedula VARCHAR(15)
									,Licitacion VARCHAR(25)
									,FormaPagoTAO VARCHAR(3)
									,TarjetaCreditoTAO VARCHAR(2)
									,NumeroTarjetaTAO VARCHAR(16)
									,VencimientoTarjetaTAO VARCHAR(5)
									,CuotasTarjetaTAO INTEGER
									,ds_Observaciones VARCHAR(8000)
									,FormaPago VARCHAR(3)
									,TarjetaCredito VARCHAR(2)
									,NumeroTarjeta VARCHAR(16)
									,VencimientoTarjeta VARCHAR(5)
									,CuotasTarjeta INTEGER
									)
	
	 
			,p_cd_TarjetaCredito VARCHAR(2)
			,p_cd_NumeroTarjeta VARCHAR(16)
			,p_cd_VencimientoTarjeta VARCHAR(5)
			,p_in_CuotasTarjeta INTEGER
	
	IF p_gds IN (1,2,6,8,9) THEN
		p_Bookingaux := (CASE ... END)
		
		PERFORM public."spza_ConfiguracionCamposGDS_ObtenerValores" p_id_usuario = 1, p_bookingId AS p_bookingIds, p_Bookingaux AS p_GDS, p_gds AS p_gds
		
		--inicio rgelis 2017/03/10 req.48084
		p_branch := (CASE ... END)
		p_implant := CASE WHEN COALESCE(F.implante,'')<>''			THEN F.implante				ELSE p_implant 				END IF;
		p_tiquetPrinter := CASE WHEN COALESCE(F.Tiqueteador,'')<>''		THEN F.Tiqueteador			ELSE p_tiquetPrinter			END IF;
		p_seller := CASE WHEN COALESCE(F.Vendedor,'')<>''			THEN F.Vendedor				ELSE p_seller 				END IF;
		p_client := CASE WHEN COALESCE(F.Cliente,'')<>''			THEN F.Cliente				ELSE p_client 				END IF;
		p_ds_clidir := CASE WHEN COALESCE(F.DireccionCliente,'')<>''	THEN F.DireccionCliente		ELSE p_ds_clidir					END IF;
		p_ds_clicity := CASE WHEN COALESCE(F.CiudadCliente,'')<>''		THEN F.CiudadCliente		ELSE p_ds_clicity 				END IF;
		p_ds_cliid := CASE WHEN COALESCE(F.Cliente,'')<>''			THEN F.Cliente				ELSE p_ds_cliid 					END IF;
		p_ds_clirazoncial := CASE WHEN COALESCE(F.RazonSocialCliente,'')<>'' THEN F.RazonSocialCliente	ELSE p_ds_clirazoncial 			END IF;
		p_ds_clitel := CASE WHEN COALESCE(F.TelefonoCliente,'')<>''	THEN F.TelefonoCliente		ELSE p_ds_clitel					END IF;
		p_cd_clipais := CASE WHEN COALESCE(F.PaisCliente,'')<>''		THEN F.PaisCliente			ELSE p_cd_clipais				END IF;
		p_cd_CentroCostoCliente := CASE WHEN COALESCE(F.centrocosto,'')<>''		THEN F.centrocosto			ELSE p_cd_CentroCostoCliente		END IF;
		p_ds_ClienteEmail := CASE WHEN COALESCE(F.EmailCliente,'')<>''		THEN F.EmailCliente			ELSE p_ds_ClienteEmail 			END IF;
		p_ds_contrato := CASE WHEN COALESCE(F.contrato,'')<>''			THEN F.contrato				ELSE p_ds_contrato				END IF;
		p_cd_tourcode := CASE WHEN COALESCE(F.tourcodeBooking,'')<>''	THEN F.tourcodeBooking		ELSE p_cd_tourcode				END IF;
		p_cd_tourcode2 := CASE WHEN COALESCE(F.tourcodetiquete,'')<>''	THEN F.tourcodetiquete		ELSE p_cd_tourcode2				END IF;
		p_iata := CASE WHEN COALESCE(F.CodigoIata,'')<>''			THEN F.CodigoIata			ELSE p_iata					END IF;
		p_exchangeRate := CASE WHEN COALESCE(F.TasaCambio,0)>0			THEN F.TasaCambio			ELSE p_exchangeRate				END IF;
		p_ds_cc_autorizacion := CASE WHEN COALESCE(F.Autorizacion,'')<>''		THEN F.Autorizacion			ELSE p_ds_cc_autorizacion		END --inicio rgelis 2017/06/05 req.48084;
		p_ds_cc_voucher := CASE WHEN COALESCE(F.Voucher,'')<>''			THEN F.Voucher				ELSE p_ds_cc_voucher				END IF;
		p_ds_cc_autorizacion2 := CASE WHEN COALESCE(F.Autorizacion2,'')<>''		THEN F.Autorizacion2		ELSE p_ds_cc_autorizacion2		END IF;
		p_ds_cc_voucher2 := CASE WHEN COALESCE(F.Voucher2,'')<>''			THEN F.Voucher2				ELSE p_ds_cc_voucher2			END IF;
		p_ds_AutorizacionTarjetaTAO := CASE WHEN COALESCE(F.AutorizacionTAO,'')<>''	THEN F.AutorizacionTAO		ELSE p_ds_AutorizacionTarjetaTAO	END IF;
		p_ds_VoucherTarjetaTAO := CASE WHEN COALESCE(F.VoucherTAO,'')<>''			THEN F.VoucherTAO			ELSE p_ds_VoucherTarjetaTAO		END --fin rgelis 2017/06/05 req.48084;
		p_in_cantpax := CASE WHEN COALESCE(F.CantidadPasajero,0)>0		THEN F.implante				ELSE p_in_cantpax				END ;
		p_cd_Pseudo := CASE WHEN COALESCE(F.Pseudo,'')<>''				THEN F.Pseudo				ELSE p_cd_Pseudo					END ;
		p_cd_Pseudo := CASE WHEN COALESCE(F.Pseudo,'')<>''				THEN F.Pseudo				ELSE p_cd_Pseudo					END ;
		p_cd_conceptofacturacion := CASE WHEN COALESCE(F.conceptofacturacion,'')<>'' THEN F.conceptofacturacion	ELSE p_cd_conceptofacturacion	END --ini rgelis 2019/09/26 req.103173;
		p_cd_TipoServicio := CASE WHEN COALESCE(F.Tiposervicio,'')<>''		THEN F.Tiposervicio			ELSE p_cd_TipoServicio			END ;
		p_cd_Proveedores := CASE WHEN COALESCE(F.Proveedor,'')<>''			THEN F.Proveedor			ELSE p_cd_Proveedores			END ;
		p_ds_Descrip := CASE WHEN COALESCE(F.DescripcionProduct,'')<>'' THEN F.DescripcionProduct ELSE p_ds_Descrip				END IF;
		p_ds_pax_firstnm := CASE WHEN COALESCE(F.PasajerosNombres,'')<>''	THEN F.PasajerosNombres		ELSE p_ds_pax_firstnm			END ;
		p_ds_pax_lastnm := CASE WHEN COALESCE(F.PasajerosApellidos,'')<>''	THEN F.PasajerosApellidos	ELSE p_ds_pax_lastnm				END ;
		p_ds_pax_lastnm := CASE WHEN COALESCE(F.Pasajeros,'')<>''			THEN F.Pasajeros			ELSE p_ds_pax_lastnm				END --fin rgelis 2019/09/26 req.103173;
		p_cd_pax_cedula := CASE WHEN COALESCE(F.PasajerosCedula,'')<>''	THEN F.PasajerosCedula		ELSE p_cd_pax_cedula				END IF;
		p_cd_licitacion := CASE WHEN COALESCE(F.Licitacion,'')<>''			THEN F.Licitacion			ELSE p_cd_licitacion				END IF;
		p_cd_FormaPagoTAO := CASE WHEN COALESCE(F.FormaPagoTAO,'')<>''		THEN F.FormaPagoTAO			ELSE p_cd_FormaPagoTAO			END IF;
		p_cd_TarjetaCreditoTAO := CASE WHEN COALESCE(F.TarjetaCreditoTAO,'')<>''	THEN F.TarjetaCreditoTAO	ELSE p_cd_TarjetaCreditoTAO		END IF;
		p_cd_NumeroTarjetaTAO := CASE WHEN COALESCE(F.NumeroTarjetaTAO,'')<>''	THEN F.NumeroTarjetaTAO		ELSE p_cd_NumeroTarjetaTAO		END IF;
		p_cd_VencimientoTarjetaTAO := CASE WHEN COALESCE(F.VencimientoTarjetaTAO,'')<>''	THEN F.VencimientoTarjetaTAO	ELSE p_cd_VencimientoTarjetaTAO	END IF;
		p_in_cuotasTarjetaTAO := CASE WHEN COALESCE(F.CuotasTarjetaTAO,0)<>0		THEN F.CuotasTarjetaTAO		ELSE p_in_cuotasTarjetaTAO		END IF;
		p_observation := CASE WHEN COALESCE(F.ds_Observaciones,'')<>''   THEN F.ds_Observaciones     ELSE p_observation			END IF;
		p_cd_FormaPago := CASE WHEN COALESCE(F.FormaPago,'')<>''			THEN F.FormaPago			ELSE p_cd_FormaPago				END IF;
		p_cd_TarjetaCredito := CASE WHEN COALESCE(F.TarjetaCredito,'')<>''		THEN F.TarjetaCredito		ELSE p_cd_TarjetaCredito			END IF;
		p_cd_NumeroTarjeta := CASE WHEN COALESCE(F.NumeroTarjeta,'')<>''		THEN F.NumeroTarjeta		ELSE p_cd_NumeroTarjeta			END IF;
		p_cd_VencimientoTarjeta := CASE WHEN COALESCE(F.VencimientoTarjeta,'')<>''	THEN F.VencimientoTarjeta	ELSE p_cd_VencimientoTarjeta		END IF;
		p_in_cuotasTarjeta := CASE WHEN COALESCE(F.CuotasTarjeta,0)<>0		THEN F.CuotasTarjeta		ELSE p_in_cuotasTarjetaTAO		END IF;
				--,PasaportePax
				--,over
				--,Evento
				--,Categoria
		--FROM public."fnza_ConfiguracionCamposGDS_ObtenerValores_Table"(p_bookingId,p_booking,p_gds) AS F
		FROM #CamposGDSValores AS F
		--fin rgelis 2017/03/10 req.48084
	END IF;
	DROP TABLE #CamposGDSValores
	*/
	--IF (COALESCE(p_cd_FormaPago,'')='CA') THEN
	--	p_cd_FormaPago := 'EFE';
	--END IF;
	--IF (COALESCE(p_cd_FormaPago,'')='PO') THEN
	--	p_cd_FormaPago := 'POL';
	--END IF;
	--IF COALESCE(p_cd_FormaPago,'')<>'' THEN
	--	p_codefp := p_cd_FormaPago;
	--END IF;
	--IF COALESCE(p_cd_TarjetaCredito,'')<>'' THEN
	--	p_cd_tipotarjeta := p_cd_TarjetaCredito;
	--	p_ds_cc_code := p_cd_TarjetaCredito;
	--END IF;
	--IF COALESCE(p_cd_NumeroTarjeta,'')<>'' THEN
	--	p_ds_numerotarjeta := p_cd_NumeroTarjeta;
	--	p_ds_cc_number := p_cd_NumeroTarjeta;
	--END IF;
	--IF COALESCE(p_cd_VencimientoTarjeta,'')<>'' THEN
	--	p_ds_expiraciontarjeta := p_cd_VencimientoTarjeta;
	--END IF;
	--IF COALESCE(p_in_CuotasTarjeta,0)<>0 THEN
	--	p_in_coutas := p_in_CuotasTarjeta;
	--	p_in_cc_cuotas := p_in_CuotasTarjeta;
	--END IF;

	IF p_Op = 'head' THEN
		IF EXISTS (SELECT 1 FROM public."BookingGDS" r WHERE r.code = p_code) THEN 
			--Modificacion de Booking existente:
			--Se actualiza la cabecera original apuntando a la nueva estructura en ingles
			UPDATE public."BookingGDS" SET 
				gds = p_gds, 
				"date" = CAST(p_date AS TIMESTAMP), 
				"tiquetPrinter" = p_tiquetPrinter, 
				seller = p_seller, 
				client = p_client, 
				booking = p_booking, 
				blanch = p_branch, 
				implant = p_implant, 
				typetransaction = p_typetransaction, 
				observation = p_observation, 
				"exchangeRate" = p_exchangeRate, 
				iata = p_iata, 
				description = p_description
			WHERE code = p_code; 
	
			-----------------------------------------------------------------------------------------
			--Obtenemos el id de la Booking actualizada
			SELECT id INTO p_Id_BookingGDS 
			FROM public."BookingGDS"
			WHERE code = p_code; --AND gds = 1;
	
			-----------------------------------------------------------------------------------------
			--IF (NOT EXISTS(SELECT id FROM public."ConfiguracionClientesFacAuto" WHERE code = p_client OR code = p_ds_cliid)
			--    AND EXISTS(SELECT id FROM public."SystemParameter" WHERE code = '525' AND TRIM(value) = 'S')
			--   ) THEN
			--	p_bl_cliente := 0;
			--ELSIF EXISTS (SELECT * FROM public."SystemParameter" WHERE code = '366' AND RTRIM(value) = 'S') THEN
			--	p_bl_cliente := 1;
			--ELSE
			--	p_bl_cliente := (CASE WHEN COALESCE(p_ds_cliid,'')<>'' OR COALESCE(p_client,'')<>'' THEN 1 ELSE 0 END);
			--END IF;
			-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
			IF (EXISTS(SELECT * FROM public."Branch" S
					  INNER JOIN public."BranchGDSFacAuto" SG ON SG.id_Sucursal = S.id   
					  WHERE S.code = p_branch and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) and p_bl_NotificacionMPD = 0 AND p_bl_cliente = 1) 
			  OR EXISTS( SELECT * FROM public."BookingGDS" r 
					     INNER JOIN public."BookingProductGDS" s ON s."bookingId" = r.id
						 WHERE r.code = p_code AND p_bl_CotizacionFacAuto = 1)) THEN
				p_state := 'USADA';
				SELECT d."state" INTO p_state
				FROM public."BookingProductGDS" p
				INNER JOIN public."BookingGDS"  b on b.id = p."bookingId"
				WHERE b.id = p_Id_BookingGDS
				AND p.state = 'NUEVO';
	
				IF ((p_state = 'NUEVO' AND NOT EXISTS (SELECT * FROM public."BookingsGDSFacAuto" where "bookingId" = p_Id_BookingGDS))
					OR NOT EXISTS (SELECT *
									FROM public."BookingProductGDS" p
									INNER JOIN public."BookingGDS" b on b.id = p."bookingId"
									WHERE b."id" = p_Id_BookingGDS))
					AND p_gds = 1 THEN
					INSERT INTO public."BookingsGDSInvoiceAuto" (Branch,implant,"bookingCode","bookingId") 
					VALUES(p_branch,p_implant,p_code,p_Id_BookingGDS);
				END IF;
			END IF;
			-----------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			--IF EXISTS (Select * From public."BookingProductItineraryGDS" Where "bookingId" = p_Id_BookingGDS) THEN
			--	   Delete From public."BookingProductItineraryGDS" Where "bookingId" = p_Id_BookingGDS;
			--	END IF;
			--------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			--IF EXISTS (Select * From public."BookingGDSProductPaymantGDS" Where "bookingId" = p_Id_BookingGDS) THEN
			--	   Delete From public."BookingGDSProductPaymantGDS" Where "bookingId" = p_Id_BookingGDS;
			--	END IF;
			--------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			--IF EXISTS (Select * From public."BookingGDS" Where ID = p_Id_BookingGDS AND Booking LIKE '%CAMBIOFACTURA%') THEN
			--	   Delete From public."BookingProductGDS" WHERE "bookingId" = p_Id_BookingGDS;
			--	END IF;
			
			--------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			
			If p_error<>0 THEN
				RAISE EXCEPTION 'Error al Guardar los Datos de Cabecera de la Booking GDS';
				-- -- SELECT -1;
				Return -1;
			END IF;
	
			INSERT INTO public."BookingsGDSLog" (blanch,implant,"message",file,codebooking, booking,error)
			SELECT 
				p_branch
				,p_implant
				,'Log Booking'
				,p_code
				,p_code
				,p_booking
				,0;
	
			IF p_gds <> 6 THEN
				SELECT * INTO p_RetVal FROM spBookingsGDS_ObtenerEMDResiduales(p_Id_BookingGDS, p_booking, p_msgValoresGDS);
				IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
					PERFORM public."spRegistrarLog"(696, 1, 0, p_msgValoresGDS);
				END IF;
			END IF;
			
				SELECT * INTO p_RetVal FROM spBookingsGDS_ValoresGDS(p_Id_BookingGDS, p_msgValoresGDS);
				IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
					PERFORM public."spRegistrarLog"(696, 1, 0, p_msgValoresGDS);
				END IF;
				p_msgValoresGDS := '';
				SELECT * INTO p_RetVal FROM spBookingsGDS_Remarks(p_Id_BookingGDS, p_msgValoresGDS);
				IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
					PERFORM public."spRegistrarLog"(696, 1, 0, p_msgValoresGDS);
				END IF;
			END IF;
		ELSE
			INSERT INTO public."BookingGDS" (
	            code,
	            type,
	            blanch,
	            implant,
	            "external",
	            gds,
	            "date",
	            currency,
	            "exchangeRate",
	            "tiquetPrinter",
	            seller,
	            client,
	            booking,
	            typetransaction,
	            iata,
	            description,
	            observation,
	            state
	        )
	        VALUES (
	            p_code,
	            'Reserva',
	            COALESCE(p_branch, 'OFP'),
	            p_implant,
	            p_external,
	            p_gds,
	            CURRENT_TIMESTAMP,
	            COALESCE(p_currency, 'COP'),
	            COALESCE(p_exchangeRate, 1),
	            COALESCE(p_PCC_Emite, p_tiquetPrinter),
	            p_seller,
	            p_client,
	            p_booking,
	            p_typetransaction,
	            p_iata,
	            p_description,
	            p_observation,
	            'NUEVO'
	        )
			RETURNING id INTO p_Id_BookingGDS;
	
			--IF p_gds <> 6 THEN
			--	SELECT * INTO p_RetVal FROM spBookingsGDS_ObtenerEMDResiduales(p_Id_BookingGDS, p_booking, p_msgValoresGDS);
			--	IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
			--		PERFORM public."spRegistrarLog"(696, 1, 0, p_msgValoresGDS);
			--	END IF;
			--END IF;
	
			--	SELECT * INTO p_RetVal FROM spBookingsGDS_ValoresGDS(p_Id_BookingGDS, p_msgValoresGDS);
			--	IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
			--		PERFORM public."spRegistrarLog"(696, 1, 0, p_msgValoresGDS);
			--	END IF;
			--
			--	p_msgValoresGDS := '';
			--	SELECT * INTO p_RetVal FROM spBookingsGDS_Remarks(p_Id_BookingGDS, p_msgValoresGDS);
			--	IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
			--		PERFORM public."spRegistrarLog"(696, 1, 0, p_msgValoresGDS);
			--	END IF;
			--END IF;
			-----------------------------------------------------------------------------------------
			-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
			--IF (NOT EXISTS(SELECT id FROM public."ConfiguracionClientesFacAuto" WHERE code = p_client OR code = p_ds_cliid)
			--    AND EXISTS(SELECT id FROM public."SystemParameter" WHERE id = 525 AND TRIM(value) = 'S')) THEN
			--	p_bl_cliente := 0;
			--ELSIF EXISTS (SELECT * FROM public."SystemParameter" WHERE code = '366' AND RTRIM(value) = 'S') THEN
			--	p_bl_cliente := 1;
			--ELSE
			--	p_bl_cliente := (CASE WHEN COALESCE(p_ds_cliid,'')<>'' OR COALESCE(p_client,'')<>'' THEN 1 ELSE 0 END);
			--END IF;
		IF EXISTS(
						SELECT * 
						FROM public."Branch" b
						inner join public."BranchGDSInvoiceAuto" a ON a."branchId" = b.id  and id_GDS = 1 and bl_FacAuto = 1
						WHERE code = p_branch 
					) 
					OR EXISTS( SELECT * FROM public."BookingGDS" r 
								INNER JOIN public."BookingProductGDS" s ON s."bookingId" = r.id
								WHERE r.code = p_code AND p_bl_CotizacionFacAuto = 1) THEN
				p_state := 'USADA' ;
				SELECT p."state" INTO p_state
				FROM public."BookingProductGDS" p
				INNER JOIN public."BookingGDS" b on b.id = p."bookingId"
				WHERE b.id = p_Id_BookingGDS
				AND p.state = 'NUEVO';
	
				IF ((p_bl_usada = 0 AND NOT EXISTS (SELECT * FROM public."BookingsGDSEnvoiceAuto" where "bookingId" = p_Id_BookingGDS))
					OR NOT EXISTS (SELECT *
									FROM public."BookingProductGDS" p
									INNER JOIN public."BookingGDS" b on b.id = p."bookingId"
									WHERE b.id = p_Id_BookingGDS))
					AND p_gds = 1 THEN
					INSERT INTO public."BookingsGDSEnvoiceAuto" (branch,implant,"bookingCode" ,"bookingId") 
					VALUES(p_branch,p_implant,p_code, p_Id_BookingGDS);
				END IF;
			-----------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			IF EXISTS (Select * From public."BookingProductItineraryGDS" Where "bookingId" = p_Id_BookingGDS) THEN
				   Delete From public."BookingProductItineraryGDS" WHERE "bookingId" = p_Id_BookingGDS;
				END IF;
			--------------------------------------------------------------------------------------------
	
			If p_error<>0 THEN
				RAISE EXCEPTION 'Error al Guardar los Datos de Cabecera de la Booking GDS';
				-- -- SELECT -1;
				Return -1;
			END IF;
			
			------------------------------------------------------------------------------------------
			-- Log de Bookings -----------------------------------------------------------------------
			------------------------------------------------------------------------------------------
			INSERT INTO public."BookingsGDS_log" (branch,implant,menssage,"file","codebooking", "booking","error")
			SELECT 
				p_branch
				,p_implant
				,'Log Booking'
				,p_code
				,p_code
				,p_booking
				,0;
	
			IF p_gds NOT IN (6,8,9) THEN
				p_id_out := p_Id_BookingGDS;
				RETURN;
			END IF;
		
		--IF EXISTS (SELECT * FROM public."SystemParameter" Where code = '565' AND LTRIM(RTRIM(value)) = 'S') THEN
		--	UPDATE public."BookingGDS" SET cd_formapago_cliente = (SELECT c.code_fp 
		--								  FROM public."Configuracion_remisiones_FPago" c
		--								  INNER JOIN public."Configuracion_remisiones" e ON e.id_cliente = c.id_cliente
		--								  WHERE (c.id_cliente = p_client OR c.id_cliente = p_ds_cliid)
		--									AND e.bl_forma_pago = 1
		--									AND c.bl_defecto = 1
		--								  LIMIT 1)
		--	WHERE id = p_Id_BookingGDS;
		--END IF; 
	
		p_id_out := p_Id_BookingGDS;
		RETURN;
	END IF;

	IF p_Op IN ('flight', 'car', 'hotel', 'insurance', 'product') THEN
		-- Determinamos la nacionalidad si no viene por parametro
		IF p_inNationality IS NULL THEN
			v_inNationality := 1;
			IF EXISTS (SELECT A.id FROM public."Airports" A 
			  INNER JOIN public."Cities" C ON C.id = A."citiesId"
			  INNER JOIN public."Countries" P ON P.id = C."countriesId"
			  INNER JOIN public."SystemParameter" PR ON PR.code = 'Pais' AND PR.value<>P.name 
			  WHERE A.code = COALESCE(p_cd_citysalida, p_origin, p_cd_city, ''))
			THEN
				v_inNationality := 2;
			ELSE
				v_inNationality := 1;
			END IF;
		ELSE
			v_inNationality := p_inNationality;
		END IF;

		-- 1. Insertamos el Producto
		INSERT INTO public."BookingProductGDS" (
			"bookingId", code, type, "service", "description", 
			"prestadoracode", "prestadorainitials", "prestadoradist", "provider", 
			"quantity", price, cost, "checkInDate", "checkOutDate", 
			"nights", "paxAdults", "paxChildren", "serviceType", "billingConcept", 
			"destination", "reservationCode", "sellerCom", "ticketPrinterCom", 
			"inNationality", "state", "conjunction", "revised", "typeproduct", "penalty"
		) VALUES (
			p_bookingId, 
			COALESCE(p_code, ''), 
			COALESCE(p_productType, CASE WHEN p_Op = 'flight' THEN 'Tiquete' WHEN p_Op = 'car' THEN 'car' WHEN p_Op = 'hotel' THEN 'hotel' WHEN p_Op = 'insurance' THEN 'insurance' ELSE '' END), 
			COALESCE(p_productService, CASE WHEN p_Op = 'flight' THEN 'Tiquete Aereo' WHEN p_Op = 'car' THEN 'Renta de Auto' WHEN p_Op = 'hotel' THEN 'Alojamiento' WHEN p_Op = 'insurance' THEN 'Seguros' ELSE '' END), 
			COALESCE(p_productDescription, CASE WHEN p_Op = 'flight' THEN 'Emision de Tiquete' WHEN p_Op = 'car' THEN 'Servicio de Renta de Auto' WHEN p_Op = 'hotel' THEN 'Reserva de Hotel' WHEN p_Op = 'insurance' THEN 'Servicio de seguros' ELSE '' END),
			p_prestadoraCode, 
			p_prestadoraInitials, 
			p_prestadoraDist, 
			p_provider,
			COALESCE(p_quantity, 1), 
			COALESCE(p_amount, 0), 
			COALESCE(p_cost, 0), 
			p_checkInDate, 
			p_checkOutDate, 
			p_nights, 
			p_paxAdults, 
			p_paxChildren, 
			p_serviceType, 
			p_billingConcept, 
			p_destination, 
			COALESCE(p_reservationCode, p_code), 
			p_sellerCom, 
			p_ticketPrinterCom, 
			v_inNationality, 
			COALESCE(p_status, 'NUEVO'), 
			p_conjunction, 
			p_revised, 
			p_typeproduct, 
			p_penalty
		) RETURNING id INTO v_BookingProductId;

		-- 2. Insertamos el Pasajero (Solo si viene en el mismo llamado)
		--IF COALESCE(p_firstName, '') <> '' THEN
		--	INSERT INTO public."BookingProductPassangerGDS" (
		--		"bookingProductId", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
		--	) VALUES (
		--		v_BookingProductId, p_firstName, p_lastName, p_documentType, p_identification, p_phone, p_email
		--	);
		--END IF;

		p_id_out := v_BookingProductId;
		RETURN;
	END IF;


	IF p_Op = 'itinerary' THEN
		v_fecha_salida := p_ds_fecha_salida;
		-- Lógica de ajuste de año (legacy)
		IF LENGTH(v_fecha_salida) >= 8 THEN
			v_Y := SUBSTRING(v_fecha_salida, 1, 4);
			v_M := SUBSTRING(v_fecha_salida, 5, 2);
			v_D := SUBSTRING(v_fecha_salida, 7, 2);
			SELECT EXTRACT(MONTH FROM "date")::INTEGER, EXTRACT(YEAR FROM "date")::INTEGER 
			INTO v_Mr, v_YAr
			FROM public."BookingGDS" WHERE id = p_bookingId;

			IF (v_Mr > v_M::INTEGER AND v_YAr >= v_Y::INTEGER) THEN
				v_Yr := v_Y::INTEGER + 1;
				v_Y := v_Yr::TEXT;
			END IF;

			v_fecha_salida := v_Y || LPAD(v_M, 2, '0') || LPAD(v_D, 2, '0');
		END IF;

		-- Construir Timestamps
		v_checkIn := TO_TIMESTAMP(v_fecha_salida || ' ' || COALESCE(p_ds_hora_salida, '00:00'), 'YYYYMMDD HH24:MI');
		v_checkOut := TO_TIMESTAMP(v_fecha_salida || ' ' || COALESCE(p_ds_hora_llegada, '00:00'), 'YYYYMMDD HH24:MI');
		INSERT INTO public."BookingProductItineraryGDS" (
			"bookingProductId",
			"orden",
			"origin",
			"destination",
			"class",
			"checkInDate",
			"checkOutDate",
			"terminal",
			"prestadoraCode",
			"farebasis",
			"Numflight",
			"Typeflight",
			"amount"
		) VALUES (
			COALESCE(p_bookingProductId, (SELECT MAX(id) FROM public."BookingProductGDS" WHERE "bookingId" = p_bookingId)),
			p_orden,
			COALESCE(p_cd_aero_salida, p_origin),
			p_cd_aero_llegada,
			LEFT(p_class, 1),
			v_checkIn,
			v_checkOut,
			p_cd_aero_llegada, -- terminal (mapeo legacy)
			COALESCE(p_cd_aero_siglas, ''),
			COALESCE(p_farebasis, ''),
			p_Numflight,
			p_Typeflight,
			COALESCE(p_amount, 0)
		);
		
		p_id_out := p_bookingId;
		RETURN;
	END IF;


	--IF p_Op = 'Poliza' THEN
	--	INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
	--	VALUES (p_bookingProductId, 'POLIZA', 'Poliza', COALESCE(p_policy, ''));
	--END IF;

	IF p_Op IN ('passanger') THEN
		INSERT INTO public."BookingProductPassangerGDS"("bookingProductId", "firstnm", "lastnm", "prefix", "identification", "phone", "email")
		VALUES (COALESCE(p_bookingProductId, (SELECT MAX(id) FROM public."BookingProductGDS" WHERE "bookingId" = p_bookingId)), p_firstName, p_lastName, p_documentType, p_identification, p_phone, p_email);
		
		p_id_out := p_bookingId;
		RETURN;
	END IF;

	IF p_Op = 'var' THEN 
		INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
		VALUES (p_bookingProductId, COALESCE(p_varName, 'VAR'), p_varName, p_varValue);
	END IF;
	
	IF p_Op = 'tax' THEN
		INSERT INTO public."BookingProductTaxGDS"("bookingProductId", code, name, type, ismain, percentage, amount)
		VALUES (p_bookingProductId, COALESCE(p_taxCode, 'TAX'), COALESCE(p_taxName, 'Impuesto'), COALESCE(p_taxType, 'IMP'), p_taxismain, COALESCE(p_perTax, 0), p_tax);
	END IF;

	IF p_Op = 'payment' THEN
		INSERT INTO public."BookingProductPaymentGDS"(
			"bookingProductId", code, name, type, "typecreditcard", "numbercreditcard", 
			"vouchercreditcard", "expiredcreditcard", "authcreditcard", "quotas", 
			"bank", "square", "reference", "policy", "policyannex", amount
		)
		VALUES (
			p_bookingProductId, COALESCE(p_paymentCode, 'PAG'), COALESCE(p_paymentName, 'Pago'), COALESCE(p_paymentType, 'EFECTIVO'), p_creditCardType, p_creditCardNumber, 
			p_voucher, p_expirationDate, p_authorization, p_quotas, 
			p_bank, p_square, p_reference, p_policy, p_policyAnnex, p_amount
		);
	END IF;

	IF p_Op = 'FEE' THEN
		INSERT INTO public."BookingProductFEEGDS"(
			"bookingProductId", code, name, type, "description", "billigconcept", "servicetype", amount, tax, other, total
		)
		VALUES (
			p_bookingProductId, COALESCE(p_feeCode, 'FEE'), COALESCE(p_feeName, 'Fee'), COALESCE(p_feeType, 'FEE'), COALESCE(p_feeDescription, ''), 
			COALESCE(p_feeBillingConcept, '1'), COALESCE(p_feeServiceType, '1'), p_amount, 0, 0, p_amount
		);
	END IF;

	p_id_out := NULL;
	RETURN;
END;
$$;
