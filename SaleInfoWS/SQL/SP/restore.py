import re
import sys

def restore_and_fix():
    try:
        with open('spInterfaceReadXMLBookingIdeasFractal.sql', 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print("Error reading:", e)
        return

    # Find the start of SELECT OpReservasGDS ='Crear'
    # Wait, let's find the start of the first INSERT INTO @Reservas
    # Since I messed it up, let's find 'INSERT INTO tmp_Reservas'
    idx_insert = content.find('INSERT INTO tmp_Reservas')
    if idx_insert == -1:
        idx_insert = content.find('INSERT INTO tmp_Reservas')
    
    # Actually, let's just find the exact text where the logic starts:
    idx_logic = content.find("SET v_TextoRaiserror='';")
    if idx_logic == -1:
        idx_logic = content.find("v_TextoRaiserror='';")
    if idx_logic == -1:
        idx_logic = content.find("v_cd_interfaces = 'IdeasFractral'")
        
    # We will reconstruct everything before idx_logic
    header = """CREATE OR REPLACE PROCEDURE spInterfaceReadXMLBookingIdeasFractal(
	p_Op VARCHAR(50) DEFAULT NULL,
	p_XML text DEFAULT NULL,
	INOUT p_XMLOutput text DEFAULT NULL,
	p_BlSelect boolean DEFAULT false
)
LANGUAGE plpgsql
AS procedure
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
    CREATE TEMP TABLE tmp_Bookings (
		Id SERIAL, OpBookingsGDS VARCHAR(15), ds_tipoitem VARCHAR(15), cd_tipoitem VARCHAR(25),
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
		id INT SERIAL NOT NULL, cd_booking VARCHAR(12) NOT NULL, ds_tkt_number VARCHAR(10) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		orden smallint NULL, cd_origen CHAR (3) NULL, cd_destino CHAR (3) NULL, cd_clase CHAR (1) NULL, fecha_salida VARCHAR(8) NULL,
		hora_salida VARCHAR (5) NULL, hora_llegada VARCHAR (5) NULL, terminal VARCHAR (50) NULL, cd_aero_siglas CHAR (2) NULL,
		cd_farebasis VARCHAR (25) NULL, ds_NumVuelo VARCHAR (25) NULL, ds_TipoVuelo CHAR (1) NULL, am_valor numeric(18,2) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_Pasajeros (
		id INT SERIAL NOT NULL, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, ds_tkt_number VARCHAR(10) NOT NULL, ds_pax_firstnm CHAR (30) NULL, ds_pax_lastnm CHAR (30) NULL,
		ds_pax_prefix CHAR (3) NULL, cd_pax_cedula VARCHAR (15) NULL, ds_pax_telefono VARCHAR (15) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_FEE (
		id INT SERIAL NOT NULL, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_conceptofac VARCHAR(13) NOT NULL, cd_subcodigo VARCHAR(13) NULL, am_valor numeric(18,2) NOT NULL, ds_servicio VARCHAR(8000) NULL 
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_VariablesAdicionales (
		id INT SERIAL NOT NULL, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, ds_nombre VARCHAR(20) NOT NULL, ds_valor VARCHAR(8000) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_CargosImpuestos (
		id INT SERIAL NOT NULL, in_orden BIGINT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, cd_codigo VARCHAR(3) NOT NULL, ds_nombre VARCHAR(50) NOT NULL, cd_tipo VARCHAR(1) NOT NULL,
		cd_codigopadre VARCHAR(3) NULL, cd_tipopadre VARCHAR(1) NULL, am_porcentaje numeric(18,2) NULL, am_contado numeric(18,2) NOT NULL,
		am_credito numeric(18,2) NOT NULL, am_valor numeric(18,2) NOT NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_ValoresItems (
		id INT SERIAL NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL, cd_tipoitem VARCHAR(25) NULL,
		am_tarifa numeric(18,2) NOT NULL, am_iva numeric(18,2) NOT NULL, am_cmb numeric(18,2) NOT NULL, am_tua numeric(18,2) NOT NULL,
		am_otros numeric(18,2) NOT NULL, am_total numeric(18,2) NOT NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_FormasPagos (
		id INT SERIAL NOT NULL, in_orden INT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, cd_codigo VARCHAR(50) NOT NULL, ds_nombre VARCHAR(50) NOT NULL, cd_tipotarjeta VARCHAR(2) NULL,
		ds_numerotarjeta VARCHAR(16) NULL, ds_vouchertarjeta VARCHAR(25) NULL, ds_expiraciontarjeta VARCHAR(5) NULL, ds_autorizaciontarjeta VARCHAR(25) NULL,
		in_coutas INT NULL, cd_banco VARCHAR(3) NULL, ds_cheque VARCHAR(30) NULL, ds_plaza VARCHAR(30) NULL, ds_referencia VARCHAR(50) NULL,
		ds_Poliza VARCHAR(20) NULL, ds_PolizaAnexo VARCHAR(20) NULL, am_valor numeric(18,2) NOT NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_BookingGDS_Valores (
		id INT SERIAL NOT NULL, in_orden INT NOT NULL, cd_booking VARCHAR(12) NOT NULL, cd_consecutivo VARCHAR(25) NOT NULL,
		cd_tipoitem VARCHAR(25) NULL, ds_segmento VARCHAR(20) NOT NULL, ds_nombre VARCHAR(20) NOT NULL, am_valor numeric(18,2) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp_EntidadesNOGDS(
		id INT SERIAL NOT NULL, id_entidad INT NOT NULL, cd_entidad VARCHAR(3) NOT NULL, cd_siglas VARCHAR(4) NOT NULL, ds_Alias VARCHAR(128)
	) ON COMMIT DROP;
"""
    
    # We find where v_cd_interfaces starts and append the rest
    logic_start = content.find("v_cd_interfaces = 'IdeasFractral'")
    if logic_start == -1:
        logic_start = content.find("v_cd_interfaces = 'IdeasFractral'")
        
    rest_of_file = content[logic_start:]
    
    # Rename variables in rest_of_file
    # Reserva -> Booking, reserva -> booking, Reservas -> Bookings, reservas -> bookings
    rest_of_file = re.sub(r'\bReservas\b', 'Bookings', rest_of_file)
    rest_of_file = re.sub(r'\breservas\b', 'bookings', rest_of_file)
    rest_of_file = re.sub(r'\bReserva\b', 'Booking', rest_of_file)
    rest_of_file = re.sub(r'\breserva\b', 'booking', rest_of_file)
    
    # Also fix 'tmp_Reservas' to 'tmp_Bookings' and so on
    rest_of_file = rest_of_file.replace('tmp_Reservas', 'tmp_Bookings')
    rest_of_file = rest_of_file.replace('tmp_Reserva', 'tmp_Booking')
    
    # Fix EXCEPTION WHEN OTHERS THEN
    rest_of_file = rest_of_file.replace('BEGIN TRY', '')
    rest_of_file = rest_of_file.replace('END CATCH', '')
    rest_of_file = rest_of_file.replace('BEGIN CATCH', 'EXCEPTION WHEN OTHERS THEN')
    rest_of_file = rest_of_file.replace('END TRY', '')

    final_content = header + "\n\t" + rest_of_file
    
    with open('spInterfaceReadXMLBookingIdeasFractal.sql', 'w', encoding='utf-8') as f:
        f.write(final_content)

restore_and_fix()
