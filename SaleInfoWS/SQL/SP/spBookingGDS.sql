CREATE OR REPLACE FUNCTION public."spBookingGDS"(
	p_Op varchar(15),
	p_branch VARCHAR(5) = 'OFP',
	p_implant VARCHAR(5) = NULL, 
	p_external BOOLEAN = false,
	p_bookingId INTEGER = NULL ,
	p_gds INTEGER=1,
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
	
	-- Extra (necesario para la firma pero obsoleto para la logica limpia)
	p_Bookingxml TEXT = null
) RETURNS INTEGER AS $$
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
BEGIN

p_RESPETARVALOR := 0;
SELECT (CASE WHEN value='S' THEN 1 ELSE 0 END) INTO p_bl_CotizacionFacAuto FROM public."SystemParameter" Where  code = '526' ;

IF EXISTS (Select * From public."BookingGDS" Where id = p_bookingId AND Booking LIKE '%RESPETARVALOR%') OR EXISTS (Select * From public."SystemParameter" Where code = '506' And value = 'S') THEN
	Begin
	p_RESPETARVALOR := 1;
End



p_msgValoresGDS Varchar(8000);
p_msgValoresGDS := '';

IF p_external = true THEN
	BEGIN 
	--Obtenemos la aerolinea externa
	SELECT value INTO p_AerolineaExterna From public."SystemParameter" Where code = '239'
	SELECT initials INTO p_CodAerolineaExterna From public."Prestadora" Where code = p_AerolineaExterna
	
END 
SELECT value INTO p_bl_tomarpccsucimp From public."SystemParameter" Where code = '373'
SELECT value INTO p_bl_IncluirCombaTarifa From public."SystemParameter" Where code = '419' 
SELECT value INTO p_bl_SumarCombustibleTarifaTkt From public."SystemParameter" Where code = '568' 

p_BookingsSabreUnicaNacionalidad Varchar(50);
SELECT value INTO p_BookingsSabreUnicaNacionalidad From public."SystemParameter" Where code = '501'
IF p_BookingsSabreUnicaNacionalidad = 'Internacional' THEN
	BEGIN
	p_in_nacionalidad := 2;
END IF;
	IF p_BookingsSabreUnicaNacionalidad = 'Nacional' THEN THEN
	BEGIN
	p_in_nacionalidad := 1;
END IF;
	IF p_bl_IncluirCombaTarifa = 'S' --AND p_in_nacionalidad = 2 THEN THEN
	BEGIN
	 p_am_tarifa := p_am_tarifa+p_am_comb;
	 if p_am_TarifaContado>0 and p_am_TarifaCredito = 0 THEN
	BEGIN
		p_am_TarifaContado := p_am_TarifaContado+p_am_comb;
	 END IF;
	IF p_am_TarifaCredito>0 and p_am_TarifaContado = 0 THEN THEN
	BEGIN
		p_am_TarifaCredito := p_am_TarifaCredito+p_am_comb;
	 end
	 
	 p_am_vat := p_am_vat-p_am_comb;
	 if p_am_OtrosContado>0 and p_am_OtrosCredito = 0 THEN
	BEGIN
		p_am_OtrosContado := p_am_OtrosContado - p_am_comb;
	 END IF;
	IF p_am_OtrosCredito>0 and p_am_OtrosContado = 0 THEN THEN
	BEGIN
		p_am_OtrosCredito := p_am_OtrosCredito - p_am_comb;
	 END IF;
	IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')='' THEN THEN
	BEGIN
		p_am_TarifaContado := p_am_TarifaContado+p_am_comb;
	 END IF;
	IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')<>'' THEN THEN
	BEGIN
		p_am_TarifaCredito := p_am_TarifaCredito+p_am_comb;
	 end

	 p_am_comb := 0;
END	/*fin rgelis 2015/07/06 suma de combustible a la tarifa*/		

IF p_bl_SumarCombustibleTarifaTkt = 'S' THEN
	BEGIN
	 p_am_tarifa := p_am_tarifa-p_am_comb;
	 if p_am_TarifaContado>0 and p_am_TarifaCredito = 0 THEN
	BEGIN
		p_am_TarifaContado := p_am_TarifaContado-p_am_comb;
	 END IF;
	IF p_am_TarifaCredito>0 and p_am_TarifaContado = 0 THEN THEN
	BEGIN
		p_am_TarifaCredito := p_am_TarifaCredito-p_am_comb;
	 end
	 p_am_vat := p_am_vat-p_am_comb;
	 if p_am_OtrosContado>0 and p_am_OtrosCredito = 0 THEN
	BEGIN
		p_am_OtrosContado := p_am_OtrosContado - p_am_comb;
	 END IF;
	IF p_am_OtrosCredito>0 and p_am_OtrosContado = 0 THEN THEN
	BEGIN
		p_am_OtrosCredito := p_am_OtrosCredito - p_am_comb;
	 END IF;
	IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')='' THEN THEN
	BEGIN
		p_am_TarifaContado := p_am_TarifaContado+p_am_comb;
	 END IF;
	IF p_am_TarifaCredito = 0 and p_am_TarifaContado = 0 AND COALESCE(p_ds_cc_code,'')<>'' THEN THEN
	BEGIN
		p_am_TarifaCredito := p_am_TarifaCredito+p_am_comb;
	 end

	 p_am_comb := 0;
END		

--Ubicacion	
IF COALESCE(p_PCC,'') <> '' AND p_bl_tomarpccsucimp = 'S' THEN
	BEGIN 

	SELECT NULL  INTO p_branch
		, NULL AS p_implant
	
	SELECT code INTO p_branch
		, NULL AS p_implant
	FROM public."Sucursales" WHERE ((Sucursales.code = p_PCC OR Sucursales.cd_alterno = p_PCC) AND bl_inactivo = 0) 

	--Si el pcc que emite es el mismo que factura, quiere decir que el emisor no es una sucursal
	IF COALESCE(p_PCC,'') <> COALESCE(p_PCC_Emite,'') THEN
	BEGIN 
		SELECT i.code INTO p_implant
			--p_bl_usarimplanteFullFilment = bl_usarimplanteFullFilment,
			--p_Id_implanteFullFilment = Id_implanteFullFilment
		FROM public."Implant" i
		WHERE (i.code = p_PCC_Emite OR i.code = p_PCC_Emite) 

		IF p_bl_usarimplanteFullFilment = 1 AND p_Id_implanteFullFilment IS NOT NULL THEN
	BEGIN
			SELECT s.code INTO p_branch
			FROM public."Branch" s
			INNER JOIN public."Implantes" i ON i."branchId" = s.id
			WHERE i.id = p_Id_implanteFullFilment
		END 
	END
	--Si el PCC que emite es igual al que factura y no existe como sucursal, entonces es un implante 
	IF COALESCE(p_PCC,'') = COALESCE(p_PCC_Emite,'') AND p_branch IS NULL THEN
	BEGIN 
		SELECT Sucursales.code INTO p_branch INTO p_branch
			, Implantes.code AS p_implant
		FROM public."Implant" i
		INNER JOIN public."Branch" b ON b.id = i."branchId"
		WHERE (i.code = p_PCC_Emite OR i.code = p_PCC_Emite)
	END 
END 
ELSE
BEGIN  
	--Validamos la sucursal
	If Not Exists(Select * From public."Branch" Where code = p_branch THEN
	BEGIN
		p_branch := 'OFP';
	End
	--Validamos el implante
	If Not Exists(Select * From public."Implant" Where code = p_implant) THEN
	BEGIN
		p_implant := NULL;
	END
END 

/*inicio rgelis 2013/07/06 req.15175*/
IF (COALESCE(p_cd_FormaPagoTAO,'')='CA') THEN
	BEGIN
	p_cd_FormaPagoTAO := 'EFE';
END IF;
	IF (COALESCE(p_cd_FormaPagoTAO,'')='PO') THEN THEN
	BEGIN
	p_cd_FormaPagoTAO := 'POL';
END
/*IF (COALESCE(p_cd_fp1,'')='CA') THEN
	BEGIN
	p_cd_fp1 := 'EFE';
END IF;
	IF (COALESCE(p_cd_fp2,'')='CA') THEN THEN
	BEGIN
	p_cd_fp2 := 'EFE';
END IF;
	IF (COALESCE(p_cd_fp3,'')='CA') THEN THEN
	BEGIN
	p_cd_fp3 := 'EFE';
END	*/

IF EXISTS (SELECT * FROM public."SystemParameter" where code = '432' and value = 'S') THEN THEN
	BEGIN 
	SELECT p_codeador_aux = SUBSTRING(p_booking,136,2)
	
	IF EXISTS (SELECT * FROM public."TicketPrinter" WHERE code = p_codeador_aux or code = p_codeador_aux) THEN
	p_tiquetPrinter := p_codeador_aux;
END; END IF;; END IF;

--Obtenemos el codigo IATA - JARG - 2015/10/16
IF p_gds IN (6,8,9)
	SELECT p_iata = ''
ELSE
	SELECT p_iata = replace(SUBSTRING(p_booking,46,10),' ','')

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

 p_cd_FormaPago VARCHAR(3);
		,p_cd_TarjetaCredito VARCHAR(2)
		,p_cd_NumeroTarjeta VARCHAR(16)
		,p_cd_VencimientoTarjeta VARCHAR(5)
		,p_in_CuotasTarjeta INTEGER

IF p_gds IN (1,2,6,8,9) THEN
	BEGIN 
	p_Bookingaux := (CASE WHEN p_Op<>'Cab' THEN NULL WHEN COALESCE(p_Bookingxml,'')<>'' THEN p_Bookingxml ELSE p_booking END);
	
	PERFORM public."spza_ConfiguracionCamposGDS_ObtenerValores" p_id_usuario = 1, p_"bookingId" AS p_"bookingId"s, p_Bookingaux AS p_GDS, p_gds AS p_gds
	
	--inicio rgelis 2017/03/10 req.48084
	p_branch := (CASE WHEN COALESCE(F.sucursal,'')<>''			THEN F.sucursal				ELSE p_branch				END);
			, CASE AS p_implant WHEN COALESCE(F.implante,'')<>''			THEN F.implante				ELSE p_implant 				END
			, CASE AS p_tiquetPrinter WHEN COALESCE(F.Tiqueteador,'')<>''		THEN F.Tiqueteador			ELSE p_tiquetPrinter			END
			, CASE AS p_seller WHEN COALESCE(F.Vendedor,'')<>''			THEN F.Vendedor				ELSE p_seller 				END
			, CASE AS p_client WHEN COALESCE(F.Cliente,'')<>''			THEN F.Cliente				ELSE p_client 				END
			, CASE AS p_ds_clidir WHEN COALESCE(F.DireccionCliente,'')<>''	THEN F.DireccionCliente		ELSE p_ds_clidir					END
			, CASE AS p_ds_clicity WHEN COALESCE(F.CiudadCliente,'')<>''		THEN F.CiudadCliente		ELSE p_ds_clicity 				END
			, CASE AS p_ds_cliid WHEN COALESCE(F.Cliente,'')<>''			THEN F.Cliente				ELSE p_ds_cliid 					END
			, CASE AS p_ds_clirazoncial WHEN COALESCE(F.RazonSocialCliente,'')<>'' THEN F.RazonSocialCliente	ELSE p_ds_clirazoncial 			END
			, CASE AS p_ds_clitel WHEN COALESCE(F.TelefonoCliente,'')<>''	THEN F.TelefonoCliente		ELSE p_ds_clitel					END
			, CASE AS p_cd_clipais WHEN COALESCE(F.PaisCliente,'')<>''		THEN F.PaisCliente			ELSE p_cd_clipais				END
			, CASE AS p_cd_CentroCostoCliente WHEN COALESCE(F.centrocosto,'')<>''		THEN F.centrocosto			ELSE p_cd_CentroCostoCliente		END
			, CASE AS p_ds_ClienteEmail WHEN COALESCE(F.EmailCliente,'')<>''		THEN F.EmailCliente			ELSE p_ds_ClienteEmail 			END
			, CASE AS p_ds_contrato WHEN COALESCE(F.contrato,'')<>''			THEN F.contrato				ELSE p_ds_contrato				END
			, CASE AS p_cd_tourcode WHEN COALESCE(F.tourcodeBooking,'')<>''	THEN F.tourcodeBooking		ELSE p_cd_tourcode				END
			, CASE AS p_cd_tourcode2 WHEN COALESCE(F.tourcodetiquete,'')<>''	THEN F.tourcodetiquete		ELSE p_cd_tourcode2				END
			, CASE AS p_iata WHEN COALESCE(F.CodigoIata,'')<>''			THEN F.CodigoIata			ELSE p_iata					END
			, CASE AS p_exchangeRate WHEN COALESCE(F.TasaCambio,0)>0			THEN F.TasaCambio			ELSE p_exchangeRate				END
			, CASE AS p_ds_cc_autorizacion WHEN COALESCE(F.Autorizacion,'')<>''		THEN F.Autorizacion			ELSE p_ds_cc_autorizacion		END --inicio rgelis 2017/06/05 req.48084
			, CASE AS p_ds_cc_voucher WHEN COALESCE(F.Voucher,'')<>''			THEN F.Voucher				ELSE p_ds_cc_voucher				END
			, CASE AS p_ds_cc_autorizacion2 WHEN COALESCE(F.Autorizacion2,'')<>''		THEN F.Autorizacion2		ELSE p_ds_cc_autorizacion2		END
			, CASE AS p_ds_cc_voucher2 WHEN COALESCE(F.Voucher2,'')<>''			THEN F.Voucher2				ELSE p_ds_cc_voucher2			END
			, CASE AS p_ds_AutorizacionTarjetaTAO WHEN COALESCE(F.AutorizacionTAO,'')<>''	THEN F.AutorizacionTAO		ELSE p_ds_AutorizacionTarjetaTAO	END
			, CASE AS p_ds_VoucherTarjetaTAO WHEN COALESCE(F.VoucherTAO,'')<>''			THEN F.VoucherTAO			ELSE p_ds_VoucherTarjetaTAO		END --fin rgelis 2017/06/05 req.48084
			, CASE AS p_in_cantpax WHEN COALESCE(F.CantidadPasajero,0)>0		THEN F.implante				ELSE p_in_cantpax				END 
			, CASE AS p_cd_Pseudo WHEN COALESCE(F.Pseudo,'')<>''				THEN F.Pseudo				ELSE p_cd_Pseudo					END 
			, CASE AS p_cd_Pseudo WHEN COALESCE(F.Pseudo,'')<>''				THEN F.Pseudo				ELSE p_cd_Pseudo					END 
			, CASE AS p_cd_conceptofacturacion WHEN COALESCE(F.conceptofacturacion,'')<>'' THEN F.conceptofacturacion	ELSE p_cd_conceptofacturacion	END --ini rgelis 2019/09/26 req.103173
			, CASE AS p_cd_TipoServicio WHEN COALESCE(F.Tiposervicio,'')<>''		THEN F.Tiposervicio			ELSE p_cd_TipoServicio			END 
			, CASE AS p_cd_Proveedores WHEN COALESCE(F.Proveedor,'')<>''			THEN F.Proveedor			ELSE p_cd_Proveedores			END 
			, CASE AS p_ds_Descrip WHEN COALESCE(F.DescripcionProduct,'')<>'' THEN F.DescripcionProduct ELSE p_ds_Descrip				END
			, CASE AS p_ds_pax_firstnm WHEN COALESCE(F.PasajerosNombres,'')<>''	THEN F.PasajerosNombres		ELSE p_ds_pax_firstnm			END 
			, CASE AS p_ds_pax_lastnm WHEN COALESCE(F.PasajerosApellidos,'')<>''	THEN F.PasajerosApellidos	ELSE p_ds_pax_lastnm				END 
			, CASE AS p_ds_pax_lastnm WHEN COALESCE(F.Pasajeros,'')<>''			THEN F.Pasajeros			ELSE p_ds_pax_lastnm				END --fin rgelis 2019/09/26 req.103173
			, CASE AS p_cd_pax_cedula WHEN COALESCE(F.PasajerosCedula,'')<>''	THEN F.PasajerosCedula		ELSE p_cd_pax_cedula				END
			, CASE AS p_cd_licitacion WHEN COALESCE(F.Licitacion,'')<>''			THEN F.Licitacion			ELSE p_cd_licitacion				END
			, CASE AS p_cd_FormaPagoTAO WHEN COALESCE(F.FormaPagoTAO,'')<>''		THEN F.FormaPagoTAO			ELSE p_cd_FormaPagoTAO			END
			, CASE AS p_cd_TarjetaCreditoTAO WHEN COALESCE(F.TarjetaCreditoTAO,'')<>''	THEN F.TarjetaCreditoTAO	ELSE p_cd_TarjetaCreditoTAO		END
			, CASE AS p_cd_NumeroTarjetaTAO WHEN COALESCE(F.NumeroTarjetaTAO,'')<>''	THEN F.NumeroTarjetaTAO		ELSE p_cd_NumeroTarjetaTAO		END
			, CASE AS p_cd_VencimientoTarjetaTAO WHEN COALESCE(F.VencimientoTarjetaTAO,'')<>''	THEN F.VencimientoTarjetaTAO	ELSE p_cd_VencimientoTarjetaTAO	END
			, CASE AS p_in_cuotasTarjetaTAO WHEN COALESCE(F.CuotasTarjetaTAO,0)<>0		THEN F.CuotasTarjetaTAO		ELSE p_in_cuotasTarjetaTAO		END
			, CASE AS p_observation WHEN COALESCE(F.ds_Observaciones,'')<>''   THEN F.ds_Observaciones     ELSE p_observation			END
			, CASE AS p_cd_FormaPago WHEN COALESCE(F.FormaPago,'')<>''			THEN F.FormaPago			ELSE p_cd_FormaPago				END
			, CASE AS p_cd_TarjetaCredito WHEN COALESCE(F.TarjetaCredito,'')<>''		THEN F.TarjetaCredito		ELSE p_cd_TarjetaCredito			END
			, CASE AS p_cd_NumeroTarjeta WHEN COALESCE(F.NumeroTarjeta,'')<>''		THEN F.NumeroTarjeta		ELSE p_cd_NumeroTarjeta			END
			, CASE AS p_cd_VencimientoTarjeta WHEN COALESCE(F.VencimientoTarjeta,'')<>''	THEN F.VencimientoTarjeta	ELSE p_cd_VencimientoTarjeta		END
			, CASE AS p_in_cuotasTarjeta WHEN COALESCE(F.CuotasTarjeta,0)<>0		THEN F.CuotasTarjeta		ELSE p_in_cuotasTarjetaTAO		END
			--,PasaportePax
			--,over
			--,Evento
			--,Categoria
	--FROM public."fnza_ConfiguracionCamposGDS_ObtenerValores_Table"(p_"bookingId",p_booking,p_gds) AS F
	FROM #CamposGDSValores AS F
	--fin rgelis 2017/03/10 req.48084
END
DROP TABLE #CamposGDSValores
*/
IF (COALESCE(p_cd_FormaPago,'')='CA') THEN
	BEGIN
	p_cd_FormaPago := 'EFE';
END IF;
	IF (COALESCE(p_cd_FormaPago,'')='PO') THEN THEN
	BEGIN
	p_cd_FormaPago := 'POL';
END IF;
	IF COALESCE(p_cd_FormaPago,'')<>'' THEN THEN
	BEGIN
	p_codefp := p_cd_FormaPago;
END IF;
	IF COALESCE(p_cd_TarjetaCredito,'')<>'' THEN THEN
	BEGIN
	p_cd_tipotarjeta := p_cd_TarjetaCredito;
	p_ds_cc_code := p_cd_TarjetaCredito;
END IF;
	IF COALESCE(p_cd_NumeroTarjeta,'')<>'' THEN THEN
	BEGIN
	p_ds_numerotarjeta := p_cd_NumeroTarjeta;
	p_ds_cc_number := p_cd_NumeroTarjeta;
END IF;
	IF COALESCE(p_cd_VencimientoTarjeta,'')<>'' THEN THEN
	BEGIN
	p_ds_expiraciontarjeta := p_cd_VencimientoTarjeta;
END IF;
	IF COALESCE(p_in_CuotasTarjeta,0)<>0 THEN THEN
	BEGIN
	p_in_coutas := p_in_CuotasTarjeta;
	p_in_cc_cuotas := p_in_CuotasTarjeta;
END; END IF;; END IF;
/*inicio rgelis 2013/07/06 req.15175*/
IF p_Op = 'Cab' THEN THEN
	BEGIN	

	IF EXISTS (SELECT 1 FROM public."BookingGDS" r WHERE r.code = p_code) THEN 
		--Modificacion de Booking existente:
		--Se actualiza la cabecera original apuntando a la nueva estructura en ingles
		UPDATE public."BookingGDS" SET gds = p_gds, CAST AS "date"(p_date AS TIMESTAMP), p_tiquetPrinter AS "tiquetPrinter", p_seller AS seller, p_client AS client, p_booking AS booking, p_branch AS blanch, p_implant AS implant, p_typetransaction AS typetransaction, p_observation AS observation, p_exchangeRate AS "exchangeRate", p_iata AS iata, p_description AS description
			WHERE code := p_code; 

		-----------------------------------------------------------------------------------------
		--Obtenemos el id de la Booking actualizada
		SELECT id INTO v_Id_public."BookingGDS" 
		FROM public."BookingGDS"
		WHERE code := p_code; --AND gds := 1;

		-----------------------------------------------------------------------------------------
		IF (NOT EXISTS(SELECT id FROM public."ConfiguracionClientesFacAuto" WHERE code = p_client OR code = p_ds_cliid)
		    AND EXISTS(SELECT id FROM public."SystemParameter" WHERE code = '525' AND TRIM(value) = 'S')
		   )
		BEGIN
			p_bl_cliente := 0;
		END
		ELSE IF EXISTS (SELECT * FROM public."SystemParameter" WHERE code = '366' AND RTRIM(value) = 'S') THEN THEN
	BEGIN
			p_bl_cliente := 1;
		END
		ELSE
		BEGIN
			p_bl_cliente := (CASE WHEN COALESCE(p_ds_cliid,'')<>'' OR COALESCE(p_client,'')<>'' THEN 1 ELSE 0 END);
		END
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (EXISTS(SELECT * FROM public."Branch" S
				  INNER JOIN public."BranchGDSFacAuto" SG ON SG.id_Sucursal = S.id   
				  WHERE S.code = p_branch and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) and p_bl_NotificacionMPD = 0 AND p_bl_cliente = 1) 
		  OR EXISTS( SELECT * FROM public."BookingGDS" r 
				     INNER JOIN public."BookingProductGDS" s ON s."bookingId" = r.id
					 WHERE r.code = p_code AND p_bl_CotizacionFacAuto = 1) THEN
	 THEN
	BEGIN
			p_state := 'USADA';
			SELECT d."state" INTO p_state
			FROM public."BookingProductGDS" p
			INNER JOIN public."BookingGDS"  b on b.id = p."bookingId"
			WHERE b.id = p_Id_BookingGDS
			AND p.state = 'NUEVO'

			IF ((p_state = 'NUEVO' and NOT EXISTS (SELECT * FROM public."BookingsGDSFacAuto" where "bookingId" = p_Id_BookingGDS)	)
				or NOT EXISTS (SELECT *
								FROM public."BookingProductGDS" p
								INNER JOIN public."BookingGDS" b on b.id = p."bookingId"
								WHERE b."id" = p_Id_BookingGDS))
				AND p_gds = 1
				INSERT INTO public."BookingsGDSInvoiceAuto" (Branch,implant,"bookingCode","bookingId") 
				VALUES(p_branch,p_implant,p_code,p_Id_BookingGDS) 
		END
		-----------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio rgelis 2013/01/24 se elimina los itinerarios de las Bookings para que no se dupliquen*/
		IF EXISTS (Select * From public."BookingProductItineraryGDS" Where "bookingId" = p_Id_BookingGDS) THEN THEN
	BEGIN
			   Delete From public."BookingProductItineraryGDS" Where "bookingId" = p_Id_BookingGDS
			End
		/*fin rgelis 2013/01/24 se elimina los itinerarios de las Bookings para que no se dupliquen*/
		--------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio rgelis 2013/07/02 Req.15175 se elimina las Polizas de las Bookings para que no se dupliquen*/
		IF EXISTS (Select * From public."BookingGDSProductPaymantGDS" Where "bookingId" = p_Id_BookingGDS) THEN THEN
	BEGIN
			   Delete From public."BookingGDSProductPaymantGDS" Where "bookingId" = p_Id_BookingGDS
			End
		/*fin rgelis 2013/07/02 Req.15175 se elimina las Polizas de las Bookings para que no se dupliquen*/
		--------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/
		IF EXISTS (Select * From public."BookingGDS" Where ID = p_Id_BookingGDS AND Booking LIKE '%CAMBIOFACTURA%') THEN THEN
	BEGIN
			   Delete From public."BookingProductGDS" Where "bookingId" := p_Id_BookingGDS
			End
		/*Fin JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/

		--------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		
		If p_error<>0 THEN THEN
	BEGIN
			RAISE EXCEPTION 'Error al Guardar los Datos de Cabecera de la Booking GDS'
			SELECT -1;
			Return -1
		END

		INSERT INTO public."BookingsGDSLog" (blanch,implant,"message",file,codebooking, booking,error)
		SELECT 
			p_branch
			,p_implant
			,'Log Booking'
			,p_code
			,p_code
			,p_booking
			,0

		IF p_gds <> 6 THEN
	BEGIN
			SELECT * INTO p_RetVal FROM spBookingsGDS_ObtenerEMDResiduales(p_"bookingId"s = p_Id_BookingGDS, p_booking AS p_GDS, p_msgValoresGDS AS p_msg 
			IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
	BEGIN
				--Agregamos el Msj de error al log.
				PERFORM public."spRegistrarLog"(((p_id_proceso => > 696, p_id_usuario => > 1, p_cd_status => > 0, p_admsg := > p_msgValoresGDS));
			END IF p_gds NOT IN (6,8,9)
					SELECT id FROM public."BookingGDS" r WHERE r.code := p_code; 
  			--RETURN 0; 	
		
			PERFORM p_RetVal = spBookingsGDS_ValoresGDS p_Id_Booking = p_Id_BookingGDS, p_msgValoresGDS AS p_msg 
			IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
	BEGIN
				--Agregamos el Msj de error al log.
				PERFORM public."spRegistrarLog"(((p_id_proceso => > 696, p_id_usuario => > 1, p_cd_status => > 0, p_admsg := > p_msgValoresGDS);
			END
			p_msgValoresGDS := '';
			SELECT * INTO p_RetVal FROM spBookingsGDS_Remarks(p_Id_Booking = p_Id_BookingGDS, p_msgValoresGDS AS p_msg 
			IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
	BEGIN
				--Agregamos el Msj de error al log.
				PERFORM public."spRegistrarLog"(((p_id_proceso => > 696, p_id_usuario => > 1, p_cd_status => > 0, p_admsg := > p_msgValoresGDS));
			END
		END			
	END 
	ELSE
	BEGIN 
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

		IF p_gds <> 6 THEN
	BEGIN
			SELECT * INTO p_RetVal FROM spBookingsGDS_ObtenerEMDResiduales(p_"bookingId"s = p_Id_BookingGDS, p_booking AS p_GDS, p_msgValoresGDS AS p_msg 
			IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
	BEGIN
				--Agregamos el Msj de error al log.
				PERFORM public."spRegistrarLog"(((p_id_proceso => > 696, p_id_usuario => > 1, p_cd_status => > 0, p_admsg := > p_msgValoresGDS));
			END

			PERFORM p_RetVal = spBookingsGDS_ValoresGDS p_Id_Booking = p_Id_BookingGDS, p_msgValoresGDS AS p_msg 
			IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
	BEGIN
				--Agregamos el Msj de error al log.
				PERFORM public."spRegistrarLog"(((p_id_proceso => > 696, p_id_usuario => > 1, p_cd_status => > 0, p_admsg := > p_msgValoresGDS);
			END
		
			p_msgValoresGDS := '';
			SELECT * INTO p_RetVal FROM spBookingsGDS_Remarks(p_Id_Booking = p_Id_BookingGDS, p_msgValoresGDS AS p_msg 
			IF p_RetVal <>  0 AND p_msgValoresGDS <> '' THEN
	BEGIN
				--Agregamos el Msj de error al log.
				PERFORM public."spRegistrarLog"(((p_id_proceso => > 696, p_id_usuario => > 1, p_cd_status => > 0, p_admsg := > p_msgValoresGDS));
			END
		END
		-----------------------------------------------------------------------------------------
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (NOT EXISTS(SELECT id FROM public."ConfiguracionClientesFacAuto" WHERE code = p_client OR code = p_ds_cliid)
		    AND EXISTS(SELECT id FROM public."SystemParameter" WHERE id = 525 AND TRIM(Valor) = 'S')
		   )
		BEGIN
			p_bl_cliente := 0;
		END
		ELSE IF EXISTS (SELECT * FROM public."SystemParameter" WHERE code = '366' AND RTRIM(value) = 'S') THEN THEN
	BEGIN
			p_bl_cliente := 1;
		END
		ELSE
		BEGIN
			p_bl_cliente := (CASE WHEN COALESCE(p_ds_cliid,'')<>'' OR COALESCE(p_client,'')<>'' THEN 1 ELSE 0 END);
		END IF;
	IF EXISTS(
					SELECT * 
					FROM public."Branch" b
					inner join BranchGDSInvoiceAuto a ON a."branchId" = b.id  and id_GDS = 1 and bl_FacAuto = 1
					WHERE code = p_branch 
					--AND p_bl_NotificacionMPD = 0 
					--AND p_bl_cliente = 1
				) 
				OR EXISTS( SELECT * FROM public."BookingGDS" r 
							INNER JOIN public."BookingProductGDS" s ON s."bookingId" = r.id
							WHERE r.code = p_code AND p_bl_CotizacionFacAuto = 1) THEN
	BEGIN
			p_state := 'USADA' ;
			SELECT p."state" INTO p_state
			FROM public."BookingProductGDS" p
			INNER JOIN public."BookingGDS" b on b.id = p."bookingId"
			WHERE public."BookingGDS".id = p_Id_BookingGDS
			AND p.state = 'NUEVO'

			IF ((p_bl_usada = 0 and NOT EXISTS (SELECT * FROM public."BookingsGDSEnvoiceAuto" where "bookingId" = p_Id_BookingGDS)	)
				or NOT EXISTS (SELECT *
								FROM public."BookingProductGDS"
								INNER JOIN public."BookingGDS" on public."BookingGDS".id = public."BookingProductGDS"."bookingId"
								WHERE public."BookingGDS".id = p_Id_BookingGDS))
				AND p_gds = 1
				INSERT INTO public."BookingsGDSEnvoiceAuto" (branch,implant,"bookingCode" ,"bookingId") 
				VALUES(p_branch,p_implant,p_code, p_Id_BookingGDS)
		END
		-----------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		IF EXISTS (Select * From public."BookingProductItineraryGDS" Where "bookingId" = p_Id_BookingGDS) THEN THEN
	BEGIN
			   Delete From public."BookingProductItineraryGDS" Where "bookingId" := p_Id_BookingGDS
			End
		--------------------------------------------------------------------------------------------

		If p_error<>0 THEN THEN
	BEGIN
			RAISE EXCEPTION 'Error al Guardar los Datos de Cabecera de la Booking GDS'
			SELECT -1;
			Return -1
		END
		
		------------------------------------------------------------------------------------------
		-- Log de Bookings -----------------------------------------------------------------------
		------------------------------------------------------------------------------------------
		INSERT INTO public."BookingsGDS_log" (cd_sucursal,cd_implante,ds_mensaje,ds_archivo,cd_Booking, ds_Booking,bl_error)
		SELECT 
			p_branch
			,p_implant
			,'Log Booking'
			,p_code
			,p_code
			,p_booking
			,0
		IF p_gds NOT IN (6,8,9)
			SELECT p_Id_BookingGDS AS 'id';
		--Return 0;
	END 
	--inicio rgelis 2019/01/24 req.75925
	IF EXISTS (SELECT * FROM public."SystemParameter" Where code = '565' AND LTRIM(RTRIM(value) THEN
	) = 'S')  
	BEGIN 
		UPDATE public."BookingGDS" SET cd_formapago_cliente = (SELECT c.code_fp 
									  FROM public."Configuracion_remisiones_FPago" c
									  INNER JOIN public."Configuracion_remisiones" e ON e.id_cliente = c.id_cliente
									  WHERE (c.id_cliente = client OR c.id_cliente = ds_cliid)
										AND e.bl_forma_pago = 1
										AND c.bl_defecto = 1
									  LIMIT 1)
		WHERE id := p_Id_BookingGDS;
	END 
	Return 0;
	--fin rgelis 2019/01/24 req.75925
	RETURN p_Id_BookingGDS;
	END IF;

	IF p_Op = 'DetPas' THEN THEN
	BEGIN
		v_BookingProductId INTEGER;;
		BEGIN
			-- 1. Insertamos el Producto Principal (Tiquete)
			INSERT INTO public."BookingProductGDS" (
				"bookingId",
				code,
				type,
				"service",
				"description",
				"provider",
				"quantity",
				price,
				cost,
				"reservationcode",
				"state"
			) VALUES (
				p_"bookingId",
				COALESCE(p_code, ''),
				COALESCE(p_productType, 'Tiquete'),
				COALESCE(p_productService, 'Tiquete Aereo'),
				COALESCE(p_productDescription, 'Emision de Tiquete'),
				p_provider,
				1,
				COALESCE(p_amount, 0),
				0,
				p_code,
				'NUEVO'
			) RETURNING id INTO v_BookingProductId;

			-- 2. Insertamos el Pasajero
			IF COALESCE(p_firstName, '') <> '' THEN
				INSERT INTO public."BookingProductPassangerGDS" (
					"bookingProductId",
					"firstName",
					"lastName",
					"documentType",
					"identification",
					"email",
					"phone",
					"type"
				) VALUES (
					v_BookingProductId,
					p_firstName,
					p_lastName,
					p_documentType,
					p_identification,
					p_email,
					p_phone,
					p_type
				);
			END IF;

			-- 3. Insertamos el Itinerario
			IF COALESCE(p_origin, '') <> '' THEN
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
					v_BookingProductId,
					COALESCE(p_orden, 1),
					p_origin,
					p_destination,
					p_class,
					p_checkInDate,
					p_checkOutDate,
					p_terminal,
					p_prestadoraCode,
					p_farebasis,
					p_Numflight,
					p_Typeflight,
					COALESCE(p_amount, 0)
				);
			END IF;

			-- 4. Insertamos los Impuestos (si los hay)
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId",
					code,
					name,
					type,
					ismain, percentage, amount) VALUES (
					v_BookingProductId,
					COALESCE(p_taxCode, 'IVA'),
					COALESCE(p_taxName, 'IVA Tiquete'),
					COALESCE(p_taxType, 'IMP'), p_taxismain,
					COALESCE(p_perTax, 0),
					p_tax
				);
			END IF;
			
			IF COALESCE(p_fee, 0) > 0 THEN
				INSERT INTO public."BookingProductFEEGDS" (
					"bookingProductId",
					code,
					name,
					type,
					description,
					billigconcept,
					servicetype,
					amount,
					tax,
					other,
					total
				) VALUES (
					v_BookingProductId,
					COALESCE(p_feeCode, 'FEE'),
					COALESCE(p_feeName, 'Fee de Emision'),
					COALESCE(p_feeType, 'TAO'),
					COALESCE(p_feeDescription, 'Cargo Administrativo'),
					COALESCE(p_feeBillingConcept, '1'),
					COALESCE(p_feeServiceType, '1'),
					p_fee,
					0,
					0,
					p_fee
				);
			END IF;

			RETURN;
			RETURN v_BookingProductId;
	END;
	END IF;

		IF p_Op = 'DetItinerario' THEN THEN
	BEGIN
		v_checkIn TIMESTAMP;;
			v_checkOut TIMESTAMP;
			v_fecha_salida TEXT := p_ds_fecha_salida;
			v_Y TEXT; v_M TEXT; v_D TEXT;
			v_Mr INTEGER; v_YAr INTEGER;
			v_Yr INTEGER;
		BEGIN
			-- Lógica de ajuste de año (legacy)
			IF LENGTH(v_fecha_salida) >= 8 THEN
				v_Y := SUBSTRING(v_fecha_salida, 1, 4);
				v_M := SUBSTRING(v_fecha_salida, 5, 2);
				v_D := SUBSTRING(v_fecha_salida, 7, 2);
;
				SELECT EXTRACT(MONTH FROM "date")::INTEGER, EXTRACT(YEAR FROM "date")::INTEGER 
				INTO v_Mr, v_YAr
				FROM public."BookingGDS" WHERE id := p_"bookingId";

				IF (v_Mr > v_M::INTEGER AND v_YAr >= v_Y::INTEGER) THEN
					v_Yr := v_Y::INTEGER + 1;
					v_Y := v_Yr::TEXT;
				END IF;

				v_fecha_salida := v_Y || LPAD(v_M, 2, '0') || LPAD(v_D, 2, '0');
			END IF;

			-- Construir Timestamps
			v_checkIn := TO_TIMESTAMP(v_fecha_salida || ' ' || COALESCE(p_ds_hora_salida, '00:00'), 'YYYYMMDD HH24:MI');
			v_checkOut := TO_TIMESTAMP(v_fecha_salida || ' ' || COALESCE(p_ds_hora_llegada, '00:00'), 'YYYYMMDD HH24:MI');
;
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
				COALESCE(p_bookingProductId, (SELECT MAX(id) FROM public."BookingProductGDS" WHERE "bookingId" := p_"bookingId")),
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
			
			RETURN p_"bookingId"; -- O v_BookingProductId si tuviéramos uno
		END; END IF;; END IF;;
	END IF;
	IF p_Op = 'DetCar' THEN
		v_BookingProductId INTEGER;;
			v_inNationality INTEGER := 1;
		BEGIN
			
			-- Validar Nacionalidad (Nacional = 1, 2 AS Internacional)
			IF EXISTS (SELECT A.id FROM public."Airports" A
			  INNER JOIN public."Cities" C ON C.id = A."citiesId"
			  INNER JOIN public."Countries" P ON P.id = C."countriesId"
			  INNER JOIN public."SystemParameter" PR ON PR.code = 'Pais' AND PR.value<>P.name 
			  WHERE A.code = COALESCE(p_cd_citysalida, p_origin) THEN
	)
			THEN
				v_inNationality := 2;
			ELSE
				v_inNationality := 1;
			END IF;

			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_"bookingId", COALESCE(p_code, ''), COALESCE(p_productType, 'Auto'),
				COALESCE(p_productService, 'Renta de Auto'), COALESCE(p_productDescription, 'Servicio de Renta de Auto'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, ismain, percentage, amount) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Auto'),
					COALESCE(p_taxType, 'IMP'), p_taxismain, COALESCE(p_perTax, 0), p_tax
				);
			END IF;
			RETURN v_BookingProductId;
	END;
	END IF;

	IF p_Op = 'DetHotel' THEN
		v_BookingProductId INTEGER;;
			v_inNationality INTEGER := 1;
		BEGIN
			
			-- Validar Nacionalidad (Nacional = 1, 2 AS Internacional)
			IF EXISTS (SELECT A.id FROM public."Airports" A
			  INNER JOIN public."Cities" C ON C.id = A."citiesId"
			  INNER JOIN public."Countries" P ON P.id = C."countriesId"
			  INNER JOIN public."SystemParameter" PR ON PR.code = 'Pais' AND PR.value<>P.name 
			  WHERE A.code = COALESCE(p_cd_city, p_origin) THEN
	)
			THEN
				v_inNationality := 2;
			ELSE
				v_inNationality := 1;
			END IF;

			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_"bookingId", COALESCE(p_code, ''), COALESCE(p_productType, 'Hotel'),
				COALESCE(p_productService, 'Alojamiento'), COALESCE(p_productDescription, 'Reserva de Hotel'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, ismain, percentage, amount) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Hotel'),
					COALESCE(p_taxType, 'IMP'), p_taxismain, COALESCE(p_perTax, 0), p_tax
				);
			END IF;
			RETURN v_BookingProductId;
	END;
	END IF;

	IF p_Op = 'DetSrv' THEN
		v_BookingProductId INTEGER;;
			v_inNationality INTEGER := 1;
		BEGIN
			
			-- Validar Nacionalidad (Nacional = 1, 2 AS Internacional)
			IF EXISTS (SELECT A.id FROM public."Airports" A
			  INNER JOIN public."Cities" C ON C.id = A."citiesId"
			  INNER JOIN public."Countries" P ON P.id = C."countriesId"
			  INNER JOIN public."SystemParameter" PR ON PR.code = 'Pais' AND PR.value<>P.name 
			  WHERE A.code = COALESCE(p_origin, '') THEN
	)
			THEN
				v_inNationality := 2;
			ELSE
				v_inNationality := 1;
			END IF;

			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_"bookingId", COALESCE(p_code, ''), COALESCE(p_productType, 'Servicio'),
				COALESCE(p_productService, 'Servicio Adicional'), COALESCE(p_productDescription, 'Servicio de Terceros'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, ismain, percentage, amount) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Servicio'),
					COALESCE(p_taxType, 'IMP'), p_taxismain, COALESCE(p_perTax, 0), p_tax
				);
			END IF;
			RETURN v_BookingProductId;
	END;
	END IF;

	--IF p_Op = 'Poliza' THEN
	--	INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
	--	VALUES (p_bookingProductId, 'POLIZA', 'Poliza', COALESCE(p_policy, ''));
	--END IF;

	IF p_Op = 'PaxAdicional' THEN
		INSERT INTO public."BookingProductPassangerGDS"("bookingProductId", "firstName", "lastName", "identification", "type")
		VALUES (p_bookingProductId, p_firstName, p_lastName, p_identification, p_type);
	END IF;

	IF p_Op = 'VarAdicional' THEN 
		INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
		VALUES (p_bookingProductId, COALESCE(p_varName, 'VAR'), p_varName, p_varValue);
	END IF;
	
	IF p_Op = 'CargosImpuestos' THEN
		INSERT INTO public."BookingProductTaxGDS"("bookingProductId", code, name, type, ismain, percentage, amount)
		VALUES (p_bookingProductId, COALESCE(p_taxCode, 'TAX'), COALESCE(p_taxName, 'Impuesto'), COALESCE(p_taxType, 'IMP'), p_taxismain, COALESCE(p_perTax, 0), p_tax);
	END IF;

	IF p_Op = 'FormasPagos' THEN
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

RETURN NULL;
END;
$$
LANGUAGE plpgsql;