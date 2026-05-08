

CREATE Procedure [dbo].[spBookingGDS]
	@Op varchar(15),
	@cd_sucursal CHAR(5) = 'OFP',
	@cd_implante CHAR(5) = NULL, /*rgelis 2012/10/16 req.10813*/
	@bl_externo bit = 0,
	@id_Booking INT = NULL ,
	@iden_gds int,
	@cd_codigo char(12) = null,
	@ds_fecha CHAR(8)  = null,
	@codeador char(6) = null,
	@cd_vendedor char(3) = null,
	@cd_cliente char(25) = null,
	@Booking text = null,
	@cd_TipoTransaccion CHAR(1) = '1',
	@ds_pax_number int = null,
	@ds_pax_firstnm varchar(30) = null,
	@ds_pax_lastnm varchar(30) = null,
	@ds_pax_prefix char(3) = null,
	@cd_pax_cedula char(15) = null,
	@ds_pax_telefono char(15) = null,
	@ds_tkt_number char(10) = null,
	@ds_tkt_prefix char(3) = null,
	@ds_aero_code char(3) = null,
	@ds_moneda char(3) = null,
	@am_tarifa numeric(18,2) = null,
	@am_iva numeric(18,2) = null,
	@am_tua numeric(18,2) = null,
	@am_vat numeric(18,2) = null,
	@ds_cc_code char(2) = null,
	@ds_cc_number char(16) = null,
	--Fare Basis (M4)
	@cd_farebasis Varchar(25)=null,
	--detalle itinerario
	@cd_aero_siglas char(3) = null,
	@cd_aero_salida char(3) = null,
	@cd_aero_llegada char(3) = null,
	@orden int = null,
	@ds_fecha_salida CHAR(8) = null,
	@ds_hora_salida char(5) = null,
	@ds_hora_llegada char(5) = null,
	@cd_clase char(2) = NULL,
	--Informacion de ahorro
	@am_highfare MONEY = null,
	@am_lowfare MONEY = null,
	@am_fare MONEY = null,
	@ds_reasoncode CHAR(2) = null,
	--Informacion de nuevo cliente
	@ds_cliname VARCHAR (50) = NULL,
	@ds_clidir VARCHAR (50) = NULL,
	@ds_clicity VARCHAR (50) = NULL,
	@ds_cliid CHAR (25) = NULL,
	@ds_clirazoncial VARCHAR (250) = NULL,
	@ds_cliname2 VARCHAR (60) = NULL,
	@ds_clilastname VARCHAR (60) = NULL,
	@ds_clilastname2 VARCHAR (60) = NULL,
	@ds_clitel VARCHAR (25) = NULL,
	@cd_clipais VARCHAR (25) = NULL,
	@cd_clitipodoc VARCHAR (100) = NULL,
	@cd_clitipotercero CHAR (1) = NULL,
	@cd_CentroCostoCliente VARCHAR(50) = NULL,
	--Inormacion adicional del tiquete
	@am_comb MONEY = 0,
	@am_tao MONEY = 0,
	@am_ivatao MONEY = 0 ,
	@am_cap MONEY = 0,
	@am_ivacap MONEY = 0,
	@ds_cc_code2 CHAR(2) = NULL ,
	@ds_cc_number2 VARCHAR(16) = NULL ,
	@am_fp1 MONEY = 0,
	@am_fp2 MONEY = NULL,
	--Informacion  de renta de Autos
	@dt_entrega CHAR(17)= NULL ,
	@in_cars TINYINT  = null,
	@cd_carcode CHAR(2) = null,
	@cd_confirmation VARCHAR(16) = null,
	@cd_citysalida CHAR(3) = NULL ,
	@dt_retorno CHAR(17)  = NULL ,
	@cd_cartype VARCHAR(20) = null,
	@cd_currency CHAR(3) = null,
	@cd_bookingsource VARCHAR(20) = NULL ,
	@cd_ratecode VARCHAR(10) = NULL ,
	@am_tarifarenta MONEY = NULL ,
	--Informaciion de hotel
	@dt_checkin CHAR(8) = NULL ,
	@in_guests INT = NULL ,
	@cd_city CHAR(3) = NULL ,
	@cd_htlchain CHAR(2) = NULL,
	@dt_checkout CHAR(8) = NULL ,
	@ds_htlname VARCHAR(32) = NULL ,
	@in_habs INT = NULL ,
	@cd_bed CHAR(3) = NULL ,
	@cd_htlcur CHAR(3) = NULL ,
	@am_htltarifa MONEY = NULL ,
	@cd_agcur CHAR(3) = NULL ,
	@am_agtarifa MONEY = NULL ,
	@ds_dir1 VARCHAR(50) = NULL ,
	@ds_tel VARCHAR(12) = NULL ,
	@ds_fax VARCHAR(12) = NULL,
	--Informaciion de Product de terceros
	@cd_conceptofacturacion CHAR(3) = NULL ,
	@cd_TipoServicio CHAR(3) = NULL ,
	@cd_Proveedores VARCHAR(25) = NULL ,
	@ds_Descrip varCHAR(500) = NULL,
	--Tkt revisado
	@cd_tktrevisado CHAR(14) = NULL,
	--Itinerario y clases
	@ds_itinerario VARCHAR(64) = NULL,
	@ds_clases VARCHAR(36) = NULL,
	@in_nacionalidad TINYINT = NULL,
	--Valores a credito y de contado
	@am_TarifaContado MONEY = 0,
	@am_IvaContado    MONEY = 0,
	@am_OtrosContado  MONEY = 0,
	@am_TarifaCredito MONEY = 0,
	@am_IvaCredito	  MONEY = 0,
	@am_OtrosCredito  MONEY = 0,
	--Comision del tiquete
	@am_Comision MONEY = 0,
	/*inicio rgelis 2013/06/28 req.15175*/
	@ds_Observaciones VARCHAR(8000) = NULL,
	@ds_ClienteEmail VARCHAR(100) = NULL,
	@bl_ClienteActualizar BIT = 0,
	@bl_NotificacionMPD BIT = 0,
	@cd_NumeroPoliza VARCHAR(50)= NULL,
	@cd_AnexoPoliza VARCHAR(50)= NULL,
	@am_ValorPoliza MONEY = 0,
	@cd_FormaPagoTAO CHAR(3) = NULL,
	@cd_TarjetaCreditoTAO CHAR(2) = NULL,
	@cd_NumeroTarjetaTAO CHAR(16) = NULL,
	@cd_VencimientoTarjetaTAO CHAR(5) = NULL,
	@cd_NumeroPolizaTAO VARCHAR(50) = NULL,
	@cd_AnexoPolizaTAO VARCHAR(50) = NULL,
	@am_PorDesFormaPagoTA NUMERIC(8,4) = 0
	/*@cd_fp1 VARCHAR(50) = NULL,
	@cd_fp2 VARCHAR(50) = NULL,
	@cd_fp3 VARCHAR(50) = NULL, 
	@am_fp3 MONEY = 0,
	@ds_cc_code3 CHAR(2) = NULL,
	@ds_cc_number3 VARCHAR(16) = NULL,
	@ds_cc_vence3 CHAR(5) = NULL,
	@ds_ch_number VARCHAR(15) = NULL,
	@ds_ch_number2 VARCHAR(15) = NULL,
	@ds_ch_number3 VARCHAR(15) = NULL,
	@ds_ch_banco CHAR(3) = NULL,
	@ds_ch_banco2 CHAR(3) = NULL,
	@ds_ch_banco3 CHAR(3) = NULL,
	@ds_ch_plaza CHAR(3) = NULL,
	@ds_ch_plaza2 CHAR(3) = NULL,
	@ds_ch_plaza3 CHAR(3) = NULL*/
	/*fin rgelis 2013/06/28 req.15175*/
	,@ds_NumVuelo VARCHAR(25) = NULL /*rgelis 2014/01/31 req.17473*/
	,@ds_TipoVuelo CHAR(1) = NULL /*rgelis 2014/01/31 req.17473*/
	,@cd_Penalidad CHAR(14) = NULL /*rgelis 2014/11/08 req.22120*/
	,@am_TasaCambio MONEY = NULL /*rgelis 2014/11/08 req.22124*/
	,@ds_cc_vence CHAR(5) = NULL
	,@ds_cc_vence2 CHAR(5) = NULL
	,@ds_cc_autorizacion VARCHAR(25)=NULL
	,@ds_cc_autorizacion2 VARCHAR(25)=NULL
	,@ds_cc_voucher	VARCHAR(25)=NULL
	,@ds_cc_voucher2 VARCHAR(25)=NULL
	,@ds_AutorizacionTarjetaTAO	VARCHAR(25)=NULL
	,@ds_VoucherTarjetaTAO VARCHAR(25)=NULL
	,@am_fptao MONEY = 0
	,@in_cc_cuotas INT = 0
	,@in_cc_cuotas2 INT = 0
	,@in_cuotasTarjetaTAO INT = 0
	,@in_NumTktConj INT = 0 /*rgelis 2014/12/22 req..... para que registre el numero de Product en conjuncion EVT*/ 
    ,@cd_TipoTarifaTAO VARCHAR(25) = NULL
	,@cd_TipoTiquete CHAR(3) = NULL
	,@PCC VARCHAR(5) = NULL
	,@PCC_Emite VARCHAR(5) = NULL
	,@bl_ahorro BIT = 0
	,@in_CantidadTarifaTAO INT = 0
	,@in_CantidadSegmentoTAO INT = 0
	,@cd_tourcode VARCHAR(25) = NULL
	,@ds_contrato VARCHAR(25) = NULL
	,@am_valor MONEY = 0
	,@cd_tourcode2 VARCHAR(25) = NULL
	,@cd_Ahorro VARCHAR(25) = NULL
	,@Id_BookingGDS_Product INT = NULL
	,@in_cantpax INT = 0 --rgelis 2017/08/24 req.35871
	,@cd_Pseudo VARCHAR(5) = NULL --rgelis 2017/08/30 req.52081
	,@ds_indice VARCHAR(5) = NULL --rgelis 2017/09/26 req.51843
	,@cd_auxiliar Varchar(16)  = NULL
	,@cd_htl VARCHAR(25) = NULL --rgelis 2017/11/15 req.54118
	,@ds_paxClasificacion CHAR(7)= NULL 
	,@cd_voucherpax VARCHAR(25)= NULL
	,@in_edad INT=NULL
	,@Id_BookingGDS_Product INT = NULL  --rgelis 2018/10/25 req.62804
	,@in_orden INT = NULL  --rgelis 2018/10/25 req.62804
	,@ds_nombre VARCHAR(20) = NULL  --rgelis 2018/10/25 req.62804
	,@ds_valor VARCHAR(8000) = NULL  --rgelis 2018/10/25 req.62804
	
	--Jramirez 2018/11/23 R74520
	,@cd_tipoventa				Varchar(16)  = NULL 
	,@cd_licitacion				Varchar(25)	 = NULL 
	--,@cd_contratolicitacion		Varchar(25)	 = NULL 
	,@ds_evento					Varchar(250) = NULL 
	,@ds_campolibre1			Varchar(500) = NULL 
	,@ds_campolibre2			Varchar(500) = NULL 
	,@cd_facturador				Varchar(3)	 = NULL 
	,@cd_especialista			Varchar(25)	 = NULL 
	,@cd_tipoformapagoproveedor	Varchar(25)	 = NULL 
	,@cd_medioBookingcion		Varchar(25)	 = NULL
	,@am_Iva2					MONEY		 = 0  --rgelis 2019/07/23 req.90597
	,@cd_tipoproveedor			VARCHAR(3)	 = NULL
	,@ds_tipoproveedor			VARCHAR(60)	 = NULL
	,@ds_descripcion			VARCHAR(500) = NULL
	,@cd_codigocarg				VARCHAR(3)	 = NULL
	,@cd_tipo					VARCHAR(1)	 = NULL
	,@cd_codigopadre			VARCHAR(3)	 = NULL
	,@cd_tipopadre				VARCHAR(1)	 = NULL
	,@am_porcentaje				MONEY		 = 0
	,@am_contado				MONEY		 = 0
	,@am_credito				MONEY		 = 0
	,@cd_codigofp				VARCHAR(50)	 = NULL
	,@ds_nombrefp				VARCHAR(50)	 = NULL
	,@cd_tipotarjeta			VARCHAR(2) 	 = NULL
	,@ds_numerotarjeta			VARCHAR(16)	 = NULL
	,@ds_vouchertarjeta			VARCHAR(25)	 = NULL
	,@ds_expiraciontarjeta		VARCHAR(5) 	 = NULL
	,@ds_autorizaciontarjeta	VARCHAR(25)	 = NULL
	,@in_coutas					INT			 = 0 
	,@cd_banco					VARCHAR(3)	 = NULL 
	,@ds_cheque					VARCHAR(30)	 = NULL
	,@ds_plaza					VARCHAR(30)	 = NULL
	,@ds_referencia				VARCHAR(50)	 = NULL
	,@ds_Poliza					VARCHAR(20)	 = NULL
	,@ds_PolizaAnexo			VARCHAR(20)	 = NULL
	,@cd_consecutivo			VARCHAR(25)  = NULL
	,@Bookingxml				VARCHAR(MAX) = NULL
WITH Encryption
As Set Nocount On
--Variable.  
-- Obtiene el id de la Booking
DECLARE @Id_BookingsGDS INT, @codeador_aux VARCHAR(6), @Cd_IATA VARCHAR(25), @Bookingaux VARCHAR(MAX)
Declare @AerolineaExterna CHAR(3),@CodAerolineaExterna CHAR(2),@bl_cliente BIT,@bl_tomarpccsucimp CHAR(1),@bl_IncluirCombaTarifa CHAR(1)  /*rgelis 2015/07/06 suma de combustible a la tarifa*/
,@bl_SumarCombustibleTarifaTkt CHAR(1), @AerolineasNoAceptanTcBSP Varchar(250)
DECLARE @bl_usarimplanteFullFilment INT, @Id_implanteFullFilment INT, @bl_usada INT, @bl_CotizacionFacAuto BIT
Declare @retval	TINYINT -- Valor de retorno de este procedimiento: 0:Exito ; 1:Error(Bloque Catch)
DECLARE @id_FormasPago INT, @id_TarjetasCredito INT --rgelis 2018/11/19 req.74409 
Declare @RESPETARVALOR INT
SET @RESPETARVALOR = 0
SELECT @bl_CotizacionFacAuto = CASE WHEN rtrim(Valor)='S' THEN 1 ELSE 0 END FROM dbo.Parametros Where  Id = 526 
/*inicio JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/
If Exists(Select * From dbo.BookingsGDS Where ID=@id_Booking AND Booking LIKE '%RESPETARVALOR%') 
OR Exists (Select * From dbo.parametros Where Id=506 And Valor='S')
Begin
	set @RESPETARVALOR = 1
End
/*Fin JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/


--R52083 -JRamirez 20170831
Declare @msgValoresGDS Varchar(8000)
Set @msgValoresGDS = ''

IF @bl_externo = 1
BEGIN 
	--Obtenemos la aerolinea externa
	Select @AerolineaExterna = rtrim(Valor) From dbo.Parametros Where Id = 239
	Select @CodAerolineaExterna = cd_siglas From dbo.Entidades Where cd_codigo = @AerolineaExterna
	
END 
SELECT @bl_tomarpccsucimp =rtrim(Valor) From dbo.Parametros Where Id = 373
SELECT @bl_IncluirCombaTarifa =rtrim(Valor) From dbo.Parametros Where Id = 419 /*inicio rgelis 2015/07/06 suma de combustible a la tarifa*/
SELECT @bl_SumarCombustibleTarifaTkt =rtrim(Valor) From dbo.Parametros Where Id = 568 /*inicio jramirez 2019/06/18 resta el combustible a la tarifa*/

/*Jramirez 20171018 - */
Declare @BookingsSabreUnicaNacionalidad Varchar(50)
Select @BookingsSabreUnicaNacionalidad = rtrim(Valor) From dbo.Parametros Where Id = 501
IF @BookingsSabreUnicaNacionalidad  = 'Internacional'
Begin
	Set @in_nacionalidad = 2
End
IF @BookingsSabreUnicaNacionalidad  = 'Nacional'
Begin
	Set @in_nacionalidad = 1
End

IF @bl_IncluirCombaTarifa = 'S' --AND @in_nacionalidad=2
BEGIN
	 SET @am_tarifa=@am_tarifa+@am_comb
	 if @am_TarifaContado>0 and @am_TarifaCredito=0
	 begin
		SET @am_TarifaContado=@am_TarifaContado+@am_comb
	 end 

	 if @am_TarifaCredito>0 and @am_TarifaContado=0
	 begin
		SET @am_TarifaCredito=@am_TarifaCredito+@am_comb
	 end
	 
	 SET @am_vat= @am_vat-@am_comb
	 if @am_OtrosContado>0 and @am_OtrosCredito=0
	 begin
		SET @am_OtrosContado = @am_OtrosContado - @am_comb
	 end

	 if @am_OtrosCredito>0 and @am_OtrosContado=0
	 begin
		SET @am_OtrosCredito = @am_OtrosCredito - @am_comb
	 end

	 if @am_TarifaCredito=0 and @am_TarifaContado=0 AND ISNULL(@ds_cc_code,'')='' 
	 begin
		SET @am_TarifaContado=@am_TarifaContado+@am_comb
	 end

	 if @am_TarifaCredito=0 and @am_TarifaContado=0 AND ISNULL(@ds_cc_code,'')<>'' 
	 begin
		SET @am_TarifaCredito=@am_TarifaCredito+@am_comb
	 end

	 SET @am_comb = 0
END	/*fin rgelis 2015/07/06 suma de combustible a la tarifa*/		


IF @bl_SumarCombustibleTarifaTkt = 'S'
BEGIN
	 SET @am_tarifa=@am_tarifa-@am_comb
	 if @am_TarifaContado>0 and @am_TarifaCredito=0
	 begin
		SET @am_TarifaContado=@am_TarifaContado-@am_comb
	 end 

	 if @am_TarifaCredito>0 and @am_TarifaContado=0
	 begin
		SET @am_TarifaCredito=@am_TarifaCredito-@am_comb
	 end
	 SET @am_vat= @am_vat-@am_comb
	 if @am_OtrosContado>0 and @am_OtrosCredito=0
	 begin
		SET @am_OtrosContado = @am_OtrosContado - @am_comb
	 end

	 if @am_OtrosCredito>0 and @am_OtrosContado=0
	 begin
		SET @am_OtrosCredito = @am_OtrosCredito - @am_comb
	 end

	 if @am_TarifaCredito=0 and @am_TarifaContado=0 AND ISNULL(@ds_cc_code,'')='' 
	 begin
		SET @am_TarifaContado=@am_TarifaContado+@am_comb
	 end

	 if @am_TarifaCredito=0 and @am_TarifaContado=0 AND ISNULL(@ds_cc_code,'')<>'' 
	 begin
		SET @am_TarifaCredito=@am_TarifaCredito+@am_comb
	 end

	 SET @am_comb = 0
END		

--Ubicacion	
IF ISNULL(@PCC,'') <> '' AND @bl_tomarpccsucimp = 'S'
BEGIN 

	SELECT 
		@cd_sucursal = NULL 
		, @cd_implante=NULL
	
	SELECT 
		@cd_sucursal = cd_codigo
		, @cd_implante=NULL
	FROM dbo.Sucursales WHERE ((Sucursales.cd_codigo = @PCC OR Sucursales.cd_alterno = @PCC) AND bl_inactivo=0) --rgelis 2018/03/13 req.52081

	--Si el pcc que emite es el mismo que factura, quiere decir que el emisor no es una sucursal
	IF ISNULL(@PCC,'') <> ISNULL(@PCC_Emite,'')
	BEGIN 
		SELECT 
			@cd_implante= Implantes.cd_codigo,
			@bl_usarimplanteFullFilment = bl_usarimplanteFullFilment,
			@Id_implanteFullFilment = Id_implanteFullFilment
		FROM dbo.Implantes
		WHERE (Implantes.cd_codigo = @PCC_Emite OR Implantes.cd_alterno = @PCC_Emite) --rgelis 2018/03/13 req.52081

		IF @bl_usarimplanteFullFilment = 1 AND @Id_implanteFullFilment IS NOT NULL 
		BEGIN
			SELECT 
				@cd_sucursal = s.cd_codigo
			FROM dbo.Sucursales s
			INNER JOIN dbo.Implantes i ON i.id_sucursal = s.id
			WHERE i.id = @Id_implanteFullFilment
		END 
	END
	--Si el PCC que emite es igual al que factura y no existe como sucursal, entonces es un implante 
	IF ISNULL(@PCC,'') = ISNULL(@PCC_Emite,'') AND @cd_sucursal IS NULL 
	BEGIN 
		SELECT 
			@cd_sucursal = Sucursales.cd_codigo
			,@cd_implante= Implantes.cd_codigo
		FROM dbo.Implantes
		INNER JOIN dbo.Sucursales ON Sucursales.id = Implantes.id_sucursal
		WHERE (Implantes.cd_codigo = @PCC_Emite OR Implantes.cd_alterno = @PCC_Emite)--rgelis 2018/03/13 req.52081
	END 
END 
ELSE
BEGIN  
	--Validamos la sucursal
	If Not Exists(Select * From dbo.Sucursales Where cd_codigo=@cd_sucursal)
	Begin
		Set @cd_sucursal='OFP'
	End
	--Validamos el implante
	If Not Exists(Select * From dbo.Implantes Where cd_codigo=@cd_implante)
	Begin
		Set @cd_implante=NULL
	END
END 

/*inicio rgelis 2013/07/06 req.15175*/
IF (ISNULL(@cd_FormaPagoTAO,'')='CA')
BEGIN
	SET @cd_FormaPagoTAO='EFE'
END
IF (ISNULL(@cd_FormaPagoTAO,'')='PO')
BEGIN
	SET @cd_FormaPagoTAO='POL'
END
/*IF (ISNULL(@cd_fp1,'')='CA')
BEGIN
	SET @cd_fp1='EFE'
END
IF (ISNULL(@cd_fp2,'')='CA')
BEGIN
	SET @cd_fp2='EFE'
END
IF (ISNULL(@cd_fp3,'')='CA')
BEGIN
	SET @cd_fp3='EFE'
END	*/

/*JARG - 2015/09/07 - Tiqueteador del emisor de la Booking*/	
IF EXISTS (SELECT * FROM dbo.Parametros where Id=432 and Valor='S')
BEGIN 
	SELECT @codeador_aux = SUBSTRING(@Booking,136,2)
	
	IF EXISTS(SELECT * FROM Tiqueteadores WHERE cd_codigo = @codeador_aux or cd_alterno = @codeador_aux)
		SET @codeador = @codeador_aux
END

--Obtenemos el codigo IATA - JARG - 2015/10/16
IF @iden_gds IN (6,8,9)
	SELECT @Cd_IATA=''
ELSE
	SELECT @Cd_IATA= replace(SUBSTRING(@Booking,46,10),' ','')

CREATE TABLE #CamposGDSValores	(Tiqueteador VARCHAR(6)
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
								,[over] VARCHAR(25)
								,tourcodeBooking VARCHAR(25)
								,tourcodetiquete VARCHAR(25)
								,contrato VARCHAR(25)
								,Evento VARCHAR(250)
								,Categoria VARCHAR(25)
								,centrocosto VARCHAR(50)
								,sucursal VARCHAR(5)
								,implante VARCHAR(5)
								,TasaCambio MONEY
								,Autorizacion VARCHAR(25) --inicio rgelis 2017/06/05 req.48084
								,Voucher VARCHAR(25)
								,Autorizacion2 VARCHAR(25)
								,Voucher2 VARCHAR(25)
								,AutorizacionTAO VARCHAR(25)
								,VoucherTAO VARCHAR(25)	  --fin rgelis 2017/06/05 req.48084
								,CantidadPasajero INT --rgelis 2017/08/24 req.35871
								,Pseudo VARCHAR(5) --rgelis 2017/08/30 req.52081
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
								,CuotasTarjetaTAO INT
								,ds_Observaciones VARCHAR(8000)
								,FormaPago VARCHAR(3)
								,TarjetaCredito VARCHAR(2)
								,NumeroTarjeta VARCHAR(16)
								,VencimientoTarjeta VARCHAR(5)
								,CuotasTarjeta INT
								)

 DECLARE @cd_FormaPago VARCHAR(3)
		,@cd_TarjetaCredito VARCHAR(2)
		,@cd_NumeroTarjeta VARCHAR(16)
		,@cd_VencimientoTarjeta VARCHAR(5)
		,@in_CuotasTarjeta INT

IF @iden_gds IN (1,2,6,8,9)
BEGIN 
	select @Bookingaux=CASE WHEN @Op<>'Cab' THEN NULL WHEN ISNULL(@Bookingxml,'')<>'' THEN @Bookingxml ELSE @Booking END
	
	EXEC dbo.spza_ConfiguracionCamposGDS_ObtenerValores @id_usuario = 1,@id_Bookings=@id_Booking,@GDS=@Bookingaux,@iden_gds=@iden_gds
	
	--inicio rgelis 2017/03/10 req.48084
	SELECT	 @cd_sucursal				= CASE WHEN ISNULL(F.sucursal,'')<>''			THEN F.sucursal				ELSE @cd_sucursal				END
			,@cd_implante 				= CASE WHEN ISNULL(F.implante,'')<>''			THEN F.implante				ELSE @cd_implante 				END
			,@codeador 			= CASE WHEN ISNULL(F.Tiqueteador,'')<>''		THEN F.Tiqueteador			ELSE @codeador			END
			,@cd_vendedor 				= CASE WHEN ISNULL(F.Vendedor,'')<>''			THEN F.Vendedor				ELSE @cd_vendedor 				END
			,@cd_cliente 				= CASE WHEN ISNULL(F.Cliente,'')<>''			THEN F.Cliente				ELSE @cd_cliente 				END
			,@ds_clidir 				= CASE WHEN ISNULL(F.DireccionCliente,'')<>''	THEN F.DireccionCliente		ELSE @ds_clidir					END
			,@ds_clicity 				= CASE WHEN ISNULL(F.CiudadCliente,'')<>''		THEN F.CiudadCliente		ELSE @ds_clicity 				END
			,@ds_cliid 					= CASE WHEN ISNULL(F.Cliente,'')<>''			THEN F.Cliente				ELSE @ds_cliid 					END
			,@ds_clirazoncial 			= CASE WHEN ISNULL(F.RazonSocialCliente,'')<>'' THEN F.RazonSocialCliente	ELSE @ds_clirazoncial 			END
			,@ds_clitel					= CASE WHEN ISNULL(F.TelefonoCliente,'')<>''	THEN F.TelefonoCliente		ELSE @ds_clitel					END
			,@cd_clipais				= CASE WHEN ISNULL(F.PaisCliente,'')<>''		THEN F.PaisCliente			ELSE @cd_clipais				END
			,@cd_CentroCostoCliente		= CASE WHEN ISNULL(F.centrocosto,'')<>''		THEN F.centrocosto			ELSE @cd_CentroCostoCliente		END
			,@ds_ClienteEmail 			= CASE WHEN ISNULL(F.EmailCliente,'')<>''		THEN F.EmailCliente			ELSE @ds_ClienteEmail 			END
			,@ds_contrato				= CASE WHEN ISNULL(F.contrato,'')<>''			THEN F.contrato				ELSE @ds_contrato				END
			,@cd_tourcode				= CASE WHEN ISNULL(F.tourcodeBooking,'')<>''	THEN F.tourcodeBooking		ELSE @cd_tourcode				END
			,@cd_tourcode2				= CASE WHEN ISNULL(F.tourcodetiquete,'')<>''	THEN F.tourcodetiquete		ELSE @cd_tourcode2				END
			,@Cd_IATA					= CASE WHEN ISNULL(F.CodigoIata,'')<>''			THEN F.CodigoIata			ELSE @Cd_IATA					END
			,@am_TasaCambio				= CASE WHEN ISNULL(F.TasaCambio,0)>0			THEN F.TasaCambio			ELSE @am_TasaCambio				END
			,@ds_cc_autorizacion		= CASE WHEN ISNULL(F.Autorizacion,'')<>''		THEN F.Autorizacion			ELSE @ds_cc_autorizacion		END --inicio rgelis 2017/06/05 req.48084
			,@ds_cc_voucher				= CASE WHEN ISNULL(F.Voucher,'')<>''			THEN F.Voucher				ELSE @ds_cc_voucher				END
			,@ds_cc_autorizacion2		= CASE WHEN ISNULL(F.Autorizacion2,'')<>''		THEN F.Autorizacion2		ELSE @ds_cc_autorizacion2		END
			,@ds_cc_voucher2			= CASE WHEN ISNULL(F.Voucher2,'')<>''			THEN F.Voucher2				ELSE @ds_cc_voucher2			END
			,@ds_AutorizacionTarjetaTAO	= CASE WHEN ISNULL(F.AutorizacionTAO,'')<>''	THEN F.AutorizacionTAO		ELSE @ds_AutorizacionTarjetaTAO	END
			,@ds_VoucherTarjetaTAO		= CASE WHEN ISNULL(F.VoucherTAO,'')<>''			THEN F.VoucherTAO			ELSE @ds_VoucherTarjetaTAO		END --fin rgelis 2017/06/05 req.48084
			,@in_cantpax				= CASE WHEN ISNULL(F.CantidadPasajero,0)>0		THEN F.implante				ELSE @in_cantpax				END --rgelis 2017/08/24 req.35871
			,@cd_Pseudo					= CASE WHEN ISNULL(F.Pseudo,'')<>''				THEN F.Pseudo				ELSE @cd_Pseudo					END --rgelis 2017/08/30 req.52081
			,@cd_Pseudo					= CASE WHEN ISNULL(F.Pseudo,'')<>''				THEN F.Pseudo				ELSE @cd_Pseudo					END --rgelis 2017/08/30 req.52081
			,@cd_conceptofacturacion	= CASE WHEN ISNULL(F.conceptofacturacion,'')<>'' THEN F.conceptofacturacion	ELSE @cd_conceptofacturacion	END --ini rgelis 2019/09/26 req.103173
			,@cd_TipoServicio			= CASE WHEN ISNULL(F.Tiposervicio,'')<>''		THEN F.Tiposervicio			ELSE @cd_TipoServicio			END 
			,@cd_Proveedores			= CASE WHEN ISNULL(F.Proveedor,'')<>''			THEN F.Proveedor			ELSE @cd_Proveedores			END 
			,@ds_Descrip				= CASE WHEN ISNULL(F.DescripcionProduct,'')<>'' THEN F.DescripcionProduct ELSE @ds_Descrip				END
			,@ds_pax_firstnm			= CASE WHEN ISNULL(F.PasajerosNombres,'')<>''	THEN F.PasajerosNombres		ELSE @ds_pax_firstnm			END 
			,@ds_pax_lastnm				= CASE WHEN ISNULL(F.PasajerosApellidos,'')<>''	THEN F.PasajerosApellidos	ELSE @ds_pax_lastnm				END 
			,@ds_pax_lastnm				= CASE WHEN ISNULL(F.Pasajeros,'')<>''			THEN F.Pasajeros			ELSE @ds_pax_lastnm				END --fin rgelis 2019/09/26 req.103173
			,@cd_pax_cedula				= CASE WHEN ISNULL(F.PasajerosCedula,'')<>''	THEN F.PasajerosCedula		ELSE @cd_pax_cedula				END
			,@cd_licitacion				= CASE WHEN ISNULL(F.Licitacion,'')<>''			THEN F.Licitacion			ELSE @cd_licitacion				END
			,@cd_FormaPagoTAO			= CASE WHEN ISNULL(F.FormaPagoTAO,'')<>''		THEN F.FormaPagoTAO			ELSE @cd_FormaPagoTAO			END
			,@cd_TarjetaCreditoTAO		= CASE WHEN ISNULL(F.TarjetaCreditoTAO,'')<>''	THEN F.TarjetaCreditoTAO	ELSE @cd_TarjetaCreditoTAO		END
			,@cd_NumeroTarjetaTAO		= CASE WHEN ISNULL(F.NumeroTarjetaTAO,'')<>''	THEN F.NumeroTarjetaTAO		ELSE @cd_NumeroTarjetaTAO		END
			,@cd_VencimientoTarjetaTAO	= CASE WHEN ISNULL(F.VencimientoTarjetaTAO,'')<>''	THEN F.VencimientoTarjetaTAO	ELSE @cd_VencimientoTarjetaTAO	END
			,@in_cuotasTarjetaTAO		= CASE WHEN ISNULL(F.CuotasTarjetaTAO,0)<>0		THEN F.CuotasTarjetaTAO		ELSE @in_cuotasTarjetaTAO		END
			,@ds_Observaciones          = CASE WHEN ISNULL(F.ds_Observaciones,'')<>''   THEN F.ds_Observaciones     ELSE @ds_Observaciones			END
			,@cd_FormaPago				= CASE WHEN ISNULL(F.FormaPago,'')<>''			THEN F.FormaPago			ELSE @cd_FormaPago				END
			,@cd_TarjetaCredito			= CASE WHEN ISNULL(F.TarjetaCredito,'')<>''		THEN F.TarjetaCredito		ELSE @cd_TarjetaCredito			END
			,@cd_NumeroTarjeta			= CASE WHEN ISNULL(F.NumeroTarjeta,'')<>''		THEN F.NumeroTarjeta		ELSE @cd_NumeroTarjeta			END
			,@cd_VencimientoTarjeta		= CASE WHEN ISNULL(F.VencimientoTarjeta,'')<>''	THEN F.VencimientoTarjeta	ELSE @cd_VencimientoTarjeta		END
			,@in_cuotasTarjeta			= CASE WHEN ISNULL(F.CuotasTarjeta,0)<>0		THEN F.CuotasTarjeta		ELSE @in_cuotasTarjetaTAO		END
			--,PasaportePax
			--,over
			--,Evento
			--,Categoria
	--FROM dbo.fnza_ConfiguracionCamposGDS_ObtenerValores_Table(@id_Booking,@Booking,@iden_gds) AS F
	FROM #CamposGDSValores AS F
	--fin rgelis 2017/03/10 req.48084
END
DROP TABLE #CamposGDSValores
IF (ISNULL(@cd_FormaPago,'')='CA')
BEGIN
	SET @cd_FormaPago='EFE'
END
IF (ISNULL(@cd_FormaPago,'')='PO')
BEGIN
	SET @cd_FormaPago='POL'
END
IF ISNULL(@cd_FormaPago,'')<>''
BEGIN
	SET @cd_codigofp=@cd_FormaPago
END
IF ISNULL(@cd_TarjetaCredito,'')<>''
BEGIN
	SET @cd_tipotarjeta=@cd_TarjetaCredito
	SET @ds_cc_code = @cd_TarjetaCredito
END
IF ISNULL(@cd_NumeroTarjeta,'')<>''
BEGIN
	SET @ds_numerotarjeta=@cd_NumeroTarjeta
	SET @ds_cc_number = @cd_NumeroTarjeta
END
IF ISNULL(@cd_VencimientoTarjeta,'')<>''
BEGIN
	SET @ds_expiraciontarjeta=@cd_VencimientoTarjeta
END
IF ISNULL(@in_CuotasTarjeta,0)<>0
BEGIN
	SET @in_coutas=@in_CuotasTarjeta
	SET @in_cc_cuotas=@in_CuotasTarjeta
END
/*inicio rgelis 2013/07/06 req.15175*/
If(@Op='Cab')
Begin	

	IF EXISTS(SELECT * FROM dbo.BookingsGDS r WHERE r.cd_codigo = @cd_codigo)
	BEGIN 
		--Modificacion de Booking existente:
		--Se actualiza la cabecera original 
		UPDATE dbo.BookingsGDS SET 	
				iden_gds = @iden_gds,
				ds_fecha = @ds_fecha,
				codeador = @codeador,
				cd_vendedor = @cd_vendedor,
				cd_cliente = @cd_cliente ,
				Booking = @Booking,
				am_highfare = @am_highfare,
				am_lowfare = @am_lowfare,
				am_fare = @am_fare,
				ds_reasoncode = @ds_reasoncode,		
				ds_itinerario = @ds_itinerario,
				ds_clases = @ds_clases,
				in_nacionalidad = @in_nacionalidad,
				cd_sucursal	= @cd_sucursal,
				cd_implante	= @cd_implante,/*rgelis 2012/10/16 req.10813*/
				ds_cliid = ds_cliid,
				cd_clitipodoc = cd_clitipodoc,
				cd_clitipotercero = cd_clitipotercero,
				ds_clirazoncial = ds_clirazoncial,
				ds_cliname = ds_cliname,
				ds_cliname2 = ds_cliname2,
				ds_clilastname = ds_clilastname,
				ds_clilastname2 = ds_clilastname2,
				cd_clipais = cd_clipais,
				ds_clicity = ds_clicity,
				ds_clidir = ds_clidir,
				ds_clitel = ds_clitel,
				cd_CentroCosto=@cd_CentroCostoCliente,
				cd_TipoTransaccion = @cd_TipoTransaccion,
				ds_Observaciones = @ds_Observaciones, /*inicio rgelis 2013/06/28 req.15175*/
				ds_ClienteEmail=@ds_ClienteEmail,
				bl_ClienteActualizar=@bl_ClienteActualizar, /*fin rgelis 2013/06/28 req.15175*/
				am_TasaCambio=@am_TasaCambio, /*rgelis 2014/11/08 req.22124*/
				bl_ahorro=@bl_ahorro,
				cd_tourcode = @cd_tourcode,
				ds_contrato = @ds_contrato,
				Cd_IATA = @Cd_IATA,
				cd_Ahorro = @cd_Ahorro,
				--Jramirez 2018/11/23 R74520
				cd_tipoventa			  = @cd_tipoventa,
				cd_licitacion			  = @cd_licitacion,		
				--cd_contratolicitacion	  = @cd_contratolicitacion,
				ds_evento				  = @ds_evento,			
				ds_campolibre1			  = @ds_campolibre1,		
				ds_campolibre2			  = @ds_campolibre2,		
				cd_facturador			  = @cd_facturador,		
				cd_especialista			  = @cd_especialista,		
				cd_tipoformapagoproveedor = @cd_tipoformapagoproveedor,
				cd_medioBookingcion		  = @cd_medioBookingcion	

			WHERE cd_codigo = @cd_codigo; 
		-----------------------------------------------------------------------------------------
		--Obtenemos el id de la Booking actualizada
		SELECT @Id_BookingsGDS = id 
		FROM dbo.BookingsGDS
		WHERE cd_codigo = @cd_codigo AND iden_gds=1

		-----------------------------------------------------------------------------------------
		IF (NOT EXISTS(SELECT id FROM dbo.ConfiguracionClientesFacAuto WHERE cd_codigo = @cd_cliente OR cd_codigo=@ds_cliid)
		    AND EXISTS(SELECT id FROM dbo.Parametros WHERE id = 525 AND RTRIM(LTRIM(Valor)) = 'S')
		   )
		BEGIN
			SET @bl_cliente = 0;
		END
		ELSE IF EXISTS(SELECT * FROM Parametros WHERE Id = 366 AND RTRIM(Valor) ='S') /*rgelis 2014/12/10 si el parametro esta activo se agregan Bookings sin clientes*/
		BEGIN
			SET @bl_cliente= 1;
		END
		ELSE
		BEGIN
			SELECT @bl_cliente = CASE WHEN ISNULL(@ds_cliid,'')<>'' OR ISNULL(@cd_cliente,'')<>'' THEN 1 ELSE 0 END
		END
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (EXISTS(SELECT * FROM sucursales S
				  INNER JOIN Sucursal_GDSFacAuto SG ON SG.id_Sucursal = S.id  /*rgelis 2015/08/24 req.27386*/	 
				  WHERE S.cd_codigo=@cd_sucursal and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) /*bl_facauto_sabre=1*/ and @bl_NotificacionMPD=0 AND @bl_cliente = 1) /*rgelis 2013/07/05 req.15175*/
		  OR EXISTS( SELECT * FROM dbo.BookingsGDS r 
				     INNER JOIN dbo.BookingGDS_Product s ON s.id_Booking = r.id
					 WHERE r.cd_codigo = @cd_codigo AND @bl_CotizacionFacAuto=1))	
		BEGIN
			SET @bl_usada = 1
			SELECT @bl_usada = bl_usada
			FROM dbo.BookingGDS_Product
			INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
			WHERE BookingsGDS.id = @Id_BookingsGDS
			AND BookingGDS_Product.bl_usada = 0

			IF ((@bl_usada = 0 and NOT EXISTS (SELECT * FROM BookingsGDS_FacAuto where id_Booking = @Id_BookingsGDS)	)
				or NOT EXISTS (SELECT *
								FROM dbo.BookingGDS_Product
								INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
								WHERE BookingsGDS.id = @Id_BookingsGDS))
				AND @iden_gds = 1
				INSERT INTO BookingsGDS_FacAuto (cd_sucursal,cd_implante,Id_Booking) /*rgelis 2014/03/28 req.15175*/
				VALUES(@cd_sucursal,@cd_implante,@Id_BookingsGDS) /*rgelis 2014/03/28 req.15175*/
		END
		-----------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio rgelis 2013/01/24 se elimina los itinerarios de las Bookings para que no se dupliquen*/
		If Exists(Select * From dbo.BookingGDS_Itinerarios Where id_Booking=@Id_BookingsGDS)
			Begin
			   Delete From dbo.BookingGDS_Itinerarios Where id_Booking=@Id_BookingsGDS
			End
		/*fin rgelis 2013/01/24 se elimina los itinerarios de las Bookings para que no se dupliquen*/
		--------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio rgelis 2013/07/02 Req.15175 se elimina las Polizas de las Bookings para que no se dupliquen*/
		If Exists(Select * From dbo.BookingGDS_Polizas Where id_Booking=@Id_BookingsGDS)
			Begin
			   Delete From dbo.BookingGDS_Polizas Where id_Booking=@Id_BookingsGDS
			End
		/*fin rgelis 2013/07/02 Req.15175 se elimina las Polizas de las Bookings para que no se dupliquen*/
		--------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/
		If Exists(Select * From dbo.BookingsGDS Where ID=@Id_BookingsGDS AND Booking LIKE '%CAMBIOFACTURA%')
			Begin
			   Delete From dbo.BookingGDS_Product Where id_Booking=@Id_BookingsGDS
			End
		/*Fin JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/

		--------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		
		If @@error<>0
		Begin
			Raiserror('Error al Guardar los Datos de Cabecera de la Booking GDS',16,1)
			SELECT -1;
			Return -1
		END

		INSERT INTO dbo.BookingsGDS_log (cd_sucursal,cd_implante,ds_mensaje,ds_archivo,cd_Booking, ds_Booking,bl_error)
		SELECT 
			@cd_sucursal
			,@cd_implante
			,'Log Booking SABRE'
			,@cd_codigo
			,@cd_codigo
			,@Booking
			,0

		IF @iden_gds <> 6
		BEGIN
			Exec @RetVal = spBookingsGDS_ObtenerEMDResiduales @id_Bookings = @Id_BookingsGDS, @GDS=@Booking, @msg = @msgValoresGDS OUTPUT
			IF @RetVal <>  0 AND @msgValoresGDS <> ''
			BEGIN
				--Agregamos el Msj de error al log.
				EXEC dbo.spzaAuditoria_Insertar  @id_proceso = 696, @id_usuario = 1, @cd_status = 0, @admsg = @msgValoresGDS;
			END

  			IF @Iden_gds NOT IN (6,8,9)
					SELECT id FROM dbo.BookingsGDS r WHERE r.cd_codigo = @cd_codigo; 
  			--RETURN 0; 	
		
			Exec @RetVal = [spBookingsGDS_ValoresGDS] @Id_Booking = @Id_BookingsGDS, @msg = @msgValoresGDS OUTPUT
			IF @RetVal <>  0 AND @msgValoresGDS <> ''
			BEGIN
				--Agregamos el Msj de error al log.
				EXEC dbo.spzaAuditoria_Insertar  @id_proceso = 696, @id_usuario = 1, @cd_status = 0, @admsg = @msgValoresGDS;
			END
			Set @msgValoresGDS = ''
			Exec @RetVal = spBookingsGDS_Remarks @Id_Booking = @Id_BookingsGDS, @msg = @msgValoresGDS OUTPUT
			IF @RetVal <>  0 AND @msgValoresGDS <> ''
			BEGIN
				--Agregamos el Msj de error al log.
				EXEC dbo.spzaAuditoria_Insertar  @id_proceso = 696, @id_usuario = 1, @cd_status = 0, @admsg = @msgValoresGDS;
			END
		END			
	END 
	ELSE
	BEGIN 
		INSERT INTO dbo.BookingsGDS
			(
			iden_gds,
			cd_sucursal,
			cd_implante,/*rgelis 2012/10/16 req.10813*/
			cd_codigo,
			ds_fecha,
			codeador,
			cd_vendedor,
			cd_cliente,
			Booking,
			am_highfare,
			am_lowfare,
			am_fare,
			ds_reasoncode,
			ds_itinerario,
			ds_clases,
			in_nacionalidad,
			ds_cliid, 
			cd_clitipodoc, 
			cd_clitipotercero, 
			ds_clirazoncial, 
			ds_cliname, 
			ds_cliname2, 
			ds_clilastname, 
			ds_clilastname2, 
			cd_clipais, 
			ds_clicity, 
			ds_clidir, 
			ds_clitel,
			cd_CentroCosto,
			cd_TipoTransaccion,
			ds_Observaciones, /*inicio rgelis 2013/06/28 req.15175*/
			ds_ClienteEmail,
			bl_ClienteActualizar,
			am_TasaCambio, /*rgelis 2014/11/08 req.22124*/
			PCC,
			PCC_Emite,
			bl_ahorro,
			cd_tourcode,
			ds_contrato,
			Cd_IATA,
			cd_Ahorro,
			cd_tipoventa,				
			cd_licitacion,				
			--cd_contratolicitacion,		
			ds_evento,					
			ds_campolibre1,			
			ds_campolibre2,			
			cd_facturador,				
			cd_especialista,			
			cd_tipoformapagoproveedor,	
			cd_medioBookingcion,
			ds_descripcion
			)
		VALUES 
			(
			@iden_gds,
			@cd_sucursal,
			@cd_implante,/*rgelis 2012/10/16 req.10813*/
			@cd_codigo,
			@ds_fecha,
			@codeador,
			@cd_vendedor,
			@cd_cliente,
			@Booking,
			@am_highfare,
			@am_lowfare,
			@am_fare,
			@ds_reasoncode,
			@ds_itinerario,
			@ds_clases,
			@in_nacionalidad,
			@ds_cliid, 
			@cd_clitipodoc, 
			@cd_clitipotercero, 
			@ds_clirazoncial, 
			@ds_cliname, 
			@ds_cliname2, 
			@ds_clilastname, 
			@ds_clilastname2, 
			@cd_clipais, 
			@ds_clicity, 
			@ds_clidir, 
			@ds_clitel,
			@cd_CentroCostoCliente,
			@cd_TipoTransaccion,
			@ds_Observaciones, /*inicio rgelis 2013/06/28 req.15175*/
			@ds_ClienteEmail,
			@bl_ClienteActualizar,
			@am_TasaCambio, /*rgelis 2014/11/08 req.22124*/
			@PCC,
			@PCC_Emite,
			@bl_ahorro,
			@cd_tourcode,
			@ds_contrato,
			@Cd_IATA,
			@cd_Ahorro,
			@cd_tipoventa,
			@cd_licitacion,				
			--@cd_contratolicitacion,
			@ds_evento,					
			@ds_campolibre1,
			@ds_campolibre2,		
			@cd_facturador,			
			@cd_especialista,
			@cd_tipoformapagoproveedor,
			@cd_medioBookingcion,
			@ds_descripcion
			)
									
		SET @Id_BookingsGDS = scope_identity()

		IF @iden_gds <> 6
		BEGIN
			Exec @RetVal = spBookingsGDS_ObtenerEMDResiduales @id_Bookings = @Id_BookingsGDS, @GDS=@Booking, @msg = @msgValoresGDS OUTPUT
			IF @RetVal <>  0 AND @msgValoresGDS <> ''
			BEGIN
				--Agregamos el Msj de error al log.
				EXEC dbo.spzaAuditoria_Insertar  @id_proceso = 696, @id_usuario = 1, @cd_status = 0, @admsg = @msgValoresGDS;
			END

			Exec @RetVal = [spBookingsGDS_ValoresGDS] @Id_Booking = @Id_BookingsGDS, @msg = @msgValoresGDS OUTPUT
			IF @RetVal <>  0 AND @msgValoresGDS <> ''
			BEGIN
				--Agregamos el Msj de error al log.
				EXEC dbo.spzaAuditoria_Insertar  @id_proceso = 696, @id_usuario = 1, @cd_status = 0, @admsg = @msgValoresGDS;
			END
		
			Set @msgValoresGDS = ''
			Exec @RetVal = spBookingsGDS_Remarks @Id_Booking = @Id_BookingsGDS, @msg = @msgValoresGDS OUTPUT
			IF @RetVal <>  0 AND @msgValoresGDS <> ''
			BEGIN
				--Agregamos el Msj de error al log.
				EXEC dbo.spzaAuditoria_Insertar  @id_proceso = 696, @id_usuario = 1, @cd_status = 0, @admsg = @msgValoresGDS;
			END
		END
		-----------------------------------------------------------------------------------------
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (NOT EXISTS(SELECT id FROM dbo.ConfiguracionClientesFacAuto WHERE cd_codigo = @cd_cliente OR cd_codigo=@ds_cliid)
		    AND EXISTS(SELECT id FROM dbo.Parametros WHERE id = 525 AND RTRIM(LTRIM(Valor)) = 'S')
		   )
		BEGIN
			SET @bl_cliente = 0;
		END
		ELSE IF EXISTS(SELECT * FROM Parametros WHERE Id = 366 AND RTRIM(Valor) ='S')  /*rgelis 2014/12/10 si el parametro esta activo se agregan Bookings sin clientes*/
		BEGIN
			SET @bl_cliente= 1;
		END
		ELSE
		BEGIN
			SELECT @bl_cliente=CASE WHEN ISNULL(@ds_cliid,'')<>'' OR ISNULL(@cd_cliente,'')<>'' THEN 1 ELSE 0 END;
		END
		IF (EXISTS(
					SELECT * 
					FROM sucursales 
					inner join Sucursal_GDSFacAuto ON Sucursal_GDSFacAuto.id_Sucursal = sucursales.id  and id_GDS = 1 and bl_FacAuto = 1
					WHERE cd_codigo=@cd_sucursal 
					AND @bl_NotificacionMPD=0 
					AND @bl_cliente=1
				) /*rgelis 2013/07/05 req.15175*/
				OR EXISTS( SELECT * FROM dbo.BookingsGDS r 
							INNER JOIN dbo.BookingGDS_Product s ON s.id_Booking = r.id
							WHERE r.cd_codigo = @cd_codigo AND @bl_CotizacionFacAuto=1))
		BEGIN
			SET @bl_usada = 1 --rgelis 2018/12/12 req.74918
			SELECT @bl_usada = bl_usada
			FROM dbo.BookingGDS_Product
			INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
			WHERE BookingsGDS.id = @Id_BookingsGDS
			AND BookingGDS_Product.bl_usada = 0

			IF ((@bl_usada = 0 and NOT EXISTS (SELECT * FROM BookingsGDS_FacAuto where id_Booking = @Id_BookingsGDS)	)
				or NOT EXISTS (SELECT *
								FROM dbo.BookingGDS_Product
								INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
								WHERE BookingsGDS.id = @Id_BookingsGDS))
				AND @iden_gds =1
				INSERT INTO BookingsGDS_FacAuto (cd_sucursal,cd_implante,Id_Booking) /*rgelis 2014/03/28 req.15175*/
				VALUES(@cd_sucursal,@cd_implante,@Id_BookingsGDS)/*rgelis 2014/03/28 req.15175*/
		END
		-----------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------
		/*inicio rgelis 2013/01/24 se elimina los itinerarios de las Bookings para que no se dupliquen*/
		If Exists(Select * From dbo.BookingGDS_Itinerarios Where id_Booking=@Id_BookingsGDS)
			Begin
			   Delete From dbo.BookingGDS_Itinerarios Where id_Booking=@Id_BookingsGDS
			End
		/*fin rgelis 2013/01/24 se elimina los itinerarios de las Bookings para que no se dupliquen*/
		--------------------------------------------------------------------------------------------
		
		
			
		If @@error<>0
		Begin
			Raiserror('Error al Guardar los Datos de Cabecera de la Booking GDS',16,1)
			SELECT -1;
			Return -1
		END
		
		------------------------------------------------------------------------------------------
		-- Log de Bookings -----------------------------------------------------------------------
		------------------------------------------------------------------------------------------
		INSERT INTO dbo.BookingsGDS_log (cd_sucursal,cd_implante,ds_mensaje,ds_archivo,cd_Booking, ds_Booking,bl_error)
		SELECT 
			@cd_sucursal
			,@cd_implante
			,'Log Booking SABRE'
			,@cd_codigo
			,@cd_codigo
			,@Booking
			,0
		IF @Iden_gds NOT IN (6,8,9)
			SELECT @Id_BookingsGDS AS 'id';
		--Return 0;
	END 
	--inicio rgelis 2019/01/24 req.75925
	IF EXISTS(SELECT * FROM dbo.Parametros Where id=565 AND LTRIM(RTRIM(Valor)) = 'S')  
	BEGIN 
		UPDATE r
		SET r.cd_formapago_cliente = (SELECT TOP(1) cd_formapago_cliente=c.cd_codigo_fp 
									  FROM dbo.Configuracion_remisiones_FPago c
									  INNER JOIN dbo.Configuracion_remisiones e ON e.id_cliente = c.id_cliente
									  WHERE (c.id_cliente = r.cd_cliente OR c.id_cliente = r.ds_cliid)
										AND e.bl_forma_pago=1
										AND c.bl_defecto = 1)
										
		FROM dbo.BookingsGDS r
		WHERE r.id = @Id_BookingsGDS 
	END 
	Return 0;
	--fin rgelis 2019/01/24 req.75925
End

If(@Op='DetPas')
Begin
	
	DECLARE @ds_itinerarioAux VARCHAR(64), @ds_clasesAux VARCHAR(36), @Count INT, @bl_usar_airplus_aerolinea_no_airplus INT, @cd_tarjeta_airplus varchar(250), @cd_codigo_tc_airplus varchar(16)

	/*inicio JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/
	If Exists(Select * From dbo.BookingsGDS Where ID=@id_Booking AND Booking LIKE '%RESPETARVALOR%')
	Begin
		set @RESPETARVALOR = 1
	End
	/*Fin JARG 2015/03/14 se elimina las Bookings cuando es cambio de factura*/

	IF EXISTS (
	SELECT e.cd_siglas FROM dbo.fnSplit( (SELECT  VALOR FROM Parametros WHERE id = 571 ),',',0,1) T
	INNER JOIN Entidades E ON E.cd_codigo = T.Codigo and  e.cd_siglas = @ds_aero_code)
	BEGIN
		Select 
			@bl_usar_airplus_aerolinea_no_airplus	= bl_usar_airplus_aerolinea_no_airplus
			,@cd_tarjeta_airplus					= cd_tarjeta_airplus
			,@cd_codigo_tc_airplus					= cd_codigo_tc_airplus
		From Configuracion_remisiones C
		INNER JOIN BookingsGDS R ON (R.ds_cliid = C.id_cliente OR R.cd_cliente = C.id_cliente)
		where R.Id = @id_Booking and bl_usar_airplus_aerolinea_no_airplus = 1
		--IF EXISTS(
		--			Select * 
		--			From Configuracion_remisiones C
		--			INNER JOIN BookingsGDS R ON (R.ds_cliid = C.id_cliente OR R.cd_cliente = C.id_cliente)
		--			where R.Id = @id_Booking and bl_usar_airplus_aerolinea_no_airplus = 1)
		--BEGIN

		--END
	END
		

	SET @Count = 1
	IF @in_CantidadSegmentoTAO > 0
	BEGIN
		
		WHILE @Count <= @in_CantidadSegmentoTAO
		BEGIN
			Insert Into [dbo].[BookingGDS_Itinerarios]
				([id_Booking]
				,[orden]
				,[cd_origen]
				,[cd_destino]
				,[cd_clase]
				,[fecha_salida]
				,[hora_salida]
				,[hora_llegada]
				,[terminal]
				,[cd_aero_siglas]
				,[cd_farebasis]
				,[ds_NumVuelo] 
				,[ds_TipoVuelo]
				,[am_valor]) 
			SELECT
				r.id AS 'id_Booking'
				,@Count AS 'orden'
				,'XXX' AS 'cd_origen'
				,'XXX' AS 'cd_destino'
				,'X' AS 'cd_clase'
				,r.ds_fecha AS 'fecha_salida'
				,REPLACE(CONVERT(VARCHAR(5),r.ds_fecha,108),':','') AS 'hora_salida'
				,REPLACE(CONVERT(VARCHAR(5),r.ds_fecha,108),':','') AS 'hora_llegada'
				,'XXX' AS 'terminal'
				,Case When @bl_externo = 1 Then @CodAerolineaExterna Else @ds_aero_code End	AS 'cd_aero_siglas'
				,'' AS 'cd_farebasis'
				,'' AS 'ds_NumVuelo'
				,'' AS 'ds_TipoVuelo'
				,0 AS 'am_valor'
			 FROM dbo.BookingsGDS r
			 WHERE r.id = @id_Booking

			SET @Count=@Count+1	 
		END

		
		SET @ds_itinerarioAux='' 
		SET @ds_clasesAux=''
		
		SELECT @ds_itinerarioAux = @ds_itinerarioAux + cd_origen + '/'
			   ,@ds_clasesAux = @ds_clasesAux + r.cd_clase + '/'
		FROM dbo.BookingGDS_Itinerarios r
		WHERE r.id_Booking = @id_Booking
		AND r.cd_aero_siglas = Case When @bl_externo = 1 Then @CodAerolineaExterna Else @ds_aero_code End
		
		SELECT TOP(1) @ds_itinerarioAux = @ds_itinerarioAux + r.cd_destino 
		FROM dbo.BookingGDS_Itinerarios r
		WHERE r.id_Booking = @id_Booking
		AND r.cd_aero_siglas = Case When @bl_externo = 1 Then @CodAerolineaExterna Else @ds_aero_code End
		ORDER BY ORDEN DESC

		SELECT @ds_clasesAux = CASE WHEN SUBSTRING(@ds_clasesAux,LEN(@ds_clasesAux),1)='/' THEN RTRIM(LEFT(@ds_clasesAux,LEN(@ds_clasesAux)-1)) ELSE @ds_clasesAux END

		IF ISNULL(@ds_itinerario,'')=''
		BEGIN
			SET @ds_itinerario = @ds_itinerarioAux 
		END
		UPDATE dbo.BookingsGDS
		SET ds_clases=@ds_clasesAux 
		WHERE id = @id_Booking
		AND RTRIM(ISNULL(@ds_clasesAux,''))<>'' 
	END
	--rgelis 2018/11/19 req.74409
	SELECT @id_FormasPago = cfp.id_FormasPago 
		  ,@id_TarjetasCredito = cfp.id_TarjetasCredito 
	FROM BookingsGDS r
	LEFT JOIN dbo.Sucursales s ON s.cd_codigo = r.cd_sucursal
	LEFT JOIN dbo.Implantes i ON s.cd_codigo = r.cd_implante
	OUTER APPLY dbo.fnza_BookingsGdsFormasPago_Table(r.cd_codigo,@ds_tkt_number) AS tc
	LEFT JOIN dbo.ConfiguracioFacturaTarjetasPropias_NumerosTC cfp ON (CFP.ds_NumeroTarjetasCredito = tc.ds_tcnumber AND CFP.id_Sucursal = s.id AND ISNULL(cfp.id_implante,0) = ISNULL(i.id,0)) 
	WHERE r.id = @id_Booking
	--rgelis 2018/11/19 req.74409  	 	
	IF EXISTS ( 
				SELECT * FROM dbo.BookingGDS_Product r 
					WHERE r.id_Booking = @id_Booking
						AND r.ds_tkt_number = @ds_tkt_number
			  )
	BEGIN 
		UPDATE dbo.BookingGDS_Product	SET  				
				ds_pax_number=@ds_pax_number,
				ds_pax_firstnm =@ds_pax_firstnm,
				ds_pax_lastnm=@ds_pax_lastnm,
				ds_pax_prefix=@ds_pax_prefix, 
				ds_tkt_prefix=Case When @bl_externo = 1 Then @AerolineaExterna Else @ds_tkt_prefix End,
				ds_aero_code=Case When @bl_externo = 1 Then @CodAerolineaExterna Else @ds_aero_code End,
--				ds_tkt_prefix=@ds_tkt_prefix,
--				ds_aero_code=@ds_aero_code,
				ds_moneda=@ds_moneda,
				am_tarifa			= CASE WHEN isnull(am_tarifa,0)> 0 AND @RESPETARVALOR = 1 THEN am_tarifa ELSE @am_tarifa END ,
				am_iva				= CASE WHEN isnull(am_iva,0)> 0 AND @RESPETARVALOR = 1 THEN am_iva ELSE @am_iva END ,
				am_tua				= CASE WHEN isnull(am_tua,0)> 0 AND @RESPETARVALOR = 1 THEN am_tua ELSE @am_tua END ,
				am_comb				= CASE WHEN isnull(am_comb,0)> 0 AND @RESPETARVALOR = 1 THEN am_comb ELSE @am_comb END ,
				am_vat				= CASE WHEN (isnull(am_iva,0)+isnull(am_tua,0)+isnull(am_comb,0)+isnull(am_vat,0))> 0 AND @RESPETARVALOR = 1 THEN am_vat ELSE @am_vat END ,
				
				ds_cc_code			= CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @cd_codigo_tc_airplus ELSE @ds_cc_code END, /*AirPlus*/
				ds_cc_number		= CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @cd_tarjeta_airplus ELSE @ds_cc_number END, /*AirPlus*/

				am_tao				= @am_tao,
				am_ivatao			= @am_ivatao,
				am_cap				= @am_cap,
				ds_itinerario=@ds_itinerario,
				--estabam comentadas revisar por q?
				am_ivacap=@am_ivacap,
				ds_cc_code2=@ds_cc_code2,
				ds_cc_number2=@ds_cc_number2,
				am_fp1=CASE WHEN isnull(am_tarifa,0)> 0 AND @RESPETARVALOR = 1 THEN am_fp1 ELSE @am_fp1 END,
				am_fp2=CASE WHEN isnull(am_tarifa,0)> 0 AND @RESPETARVALOR = 1 THEN am_fp2 ELSE @am_fp2 END,
				cd_tktrevisado=@cd_tktrevisado,
				
				am_TarifaContado		= CASE  WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN 0 WHEN isnull(am_TarifaContado,0)> 0 AND @RESPETARVALOR = 1 THEN am_TarifaContado ELSE @am_TarifaContado END, /*AirPlus*/
				am_IvaContado			= CASE  WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN 0 WHEN isnull(am_IvaContado,0)> 0 AND @RESPETARVALOR = 1 THEN am_IvaContado ELSE @am_IvaContado end , /*AirPlus*/
				am_OtrosContado			= CASE  WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN 0 WHEN (isnull(am_OtrosContado,0)+isnull(am_IvaContado,0))> 0 AND @RESPETARVALOR = 1 THEN am_OtrosContado ELSE @am_OtrosContado END, /*AirPlus*/
				am_TarifaCredito		= CASE  WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @am_TarifaContado WHEN isnull(am_TarifaCredito,0)> 0 AND @RESPETARVALOR = 1 THEN am_TarifaCredito ELSE @am_TarifaCredito END, /*AirPlus*/
				am_IvaCredito			= CASE  WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @am_IvaContado WHEN isnull(am_IvaCredito,0)> 0 AND @RESPETARVALOR = 1 THEN am_IvaCredito ELSE @am_IvaCredito END, /*AirPlus*/
				am_OtrosCredito			= CASE  WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN am_OtrosContado WHEN (isnull(am_IvaCredito,0)+isnull(am_OtrosCredito,0))> 0 AND @RESPETARVALOR = 1 THEN am_OtrosCredito ELSE @am_OtrosCredito END, /*AirPlus*/

				am_Comision = @am_Comision,
				ds_tkt_prefixIata= Case When @bl_externo = 1 Then  @ds_tkt_prefix  Else NULL End,
				ds_aero_codeIata=Case When @bl_externo = 1 Then @ds_aero_code Else NULL End,
				bl_NotificacionMPD=@bl_NotificacionMPD, /*inicio rgelis 2013/06/28 req.15175*/
				cd_FormaPagoTAO=@cd_FormaPagoTAO,
				cd_TarjetaCreditoTAO=@cd_TarjetaCreditoTAO,
				cd_NumeroTarjetaTAO=@cd_NumeroTarjetaTAO,
				cd_VencimientoTarjetaTAO=@cd_VencimientoTarjetaTAO,
				cd_NumeroPolizaTAO=@cd_NumeroPolizaTAO,
				cd_AnexoPolizaTAO=@cd_AnexoPolizaTAO,
				am_PorDesFormaPagoTA=@am_PorDesFormaPagoTA,
				cd_Penalidad=@cd_Penalidad, /*rgelis 2014/11/08 req.22120*/
				ds_cc_vence=case when isnull(ds_cc_vence,'') = '' then @ds_cc_vence else ds_cc_vence end, /*AirPlus*/
				ds_cc_vence2=@ds_cc_vence2,
				ds_cc_autorizacion=@ds_cc_autorizacion,
				ds_cc_autorizacion2=@ds_cc_autorizacion2,
				ds_cc_voucher=@ds_cc_voucher,
				ds_cc_voucher2=@ds_cc_voucher2,
				ds_AutorizacionTarjetaTAO=@ds_AutorizacionTarjetaTAO,
				ds_VoucherTarjetaTAO=@ds_VoucherTarjetaTAO,
				am_fptao=@am_fptao,
				in_cc_cuotas=@in_cc_cuotas,
				in_cc_cuotas2=@in_cc_cuotas2,
				in_cuotasTarjetaTAO=@in_cuotasTarjetaTAO,
				NumTktConj=@in_NumTktConj, /*rgelis 2014/12/22 req..... para que registre el numero de Product en conjuncion EVT*/
				cd_TipoTarifaTAO=@cd_TipoTarifaTAO,
				cd_TipoTiquete=@cd_TipoTiquete,
				in_CantidadTarifaTAO=@in_CantidadTarifaTAO,
				in_CantidadSegmentoTAO=@in_CantidadSegmentoTAO,
				cd_tourcode=@cd_tourcode2,
				in_cantpax = @in_cantpax, --rgelis 2017/08/24 req.35871
				cd_Pseudo = @cd_Pseudo, --rgelis 2017/08/30 req.52081
				id_FormasPago = @id_FormasPago, --rgelis 2018/11/19 req.74409
				id_TarjetasCredito = @id_TarjetasCredito, --rgelis 2018/11/19 req.74409
				am_iva2 = CASE WHEN ISNULL(am_iva2,0) > 0 AND @RESPETARVALOR = 1 THEN am_iva2 ELSE @am_iva2 END, --rgelis 2019/07/23 req.90597  --rgelis 2019/08/14 req.92111
				in_nacionalidad = @in_nacionalidad,
				cd_Pax_CC =@cd_pax_cedula,
				cd_consecutivo=@cd_consecutivo
				/*cd_fp1 = @cd_fp1,
				cd_fp2 = @cd_fp2,
				cd_fp3 = @cd_fp3, 
				am_fp3 = @am_fp3,
				ds_cc_code3 = @ds_cc_code3,
				ds_cc_number3 = @ds_cc_number3,
				ds_cc_vence3 = @ds_cc_vence3,
				ds_ch_number = @ds_ch_number,
				ds_ch_number2 = @ds_ch_number2,
				ds_ch_number3 = @ds_ch_number3,
				ds_ch_banco = @ds_ch_banco,
				ds_ch_banco2 = @ds_ch_banco2,
				ds_ch_banco3 = @ds_ch_banco3,
				ds_ch_plaza = @ds_ch_plaza,
				ds_ch_plaza2 = @ds_ch_plaza2,
				ds_ch_plaza3 = @ds_ch_plaza3*/ /*fin rgelis 2014/03/20 req.15175*/
			WHERE  	id_Booking = @id_Booking
				AND ds_tkt_number = @ds_tkt_number;
		If @@error<>0
			Begin
				Raiserror('Error al Guardar los Datos de Detalle de la Booking GDS',16,1)
				Select -1;
				RETURN;
			End
		Return
	END 
	ELSE 
	BEGIN 
		INSERT INTO dbo.BookingGDS_Product
			(
				id_Booking,
				ds_pax_number,
				ds_pax_firstnm,
				ds_pax_lastnm,
				ds_pax_prefix,
				ds_tkt_number,
				ds_tkt_prefix,
				ds_aero_code,
				ds_moneda,
				am_tarifa,
				am_iva,
				am_tua,
				am_comb,
				am_vat,
				ds_cc_code,
				ds_cc_number,
				am_tao,
				am_ivatao,
				am_cap,
				am_ivacap,
				ds_cc_code2,
				ds_cc_number2,
				am_fp1,
				am_fp2,
				cd_tktrevisado,
				am_TarifaContado,
				am_IvaContado,
				am_OtrosContado,
				am_TarifaCredito,
				am_IvaCredito,
				am_OtrosCredito,
				am_Comision,
				ds_itinerario,
				ds_tkt_prefixIata,
				ds_aero_codeIata,
				bl_NotificacionMPD, /*inicio rgelis 2013/06/28 req.15175*/
				cd_FormaPagoTAO,
				cd_TarjetaCreditoTAO,
				cd_NumeroTarjetaTAO,
				cd_VencimientoTarjetaTAO,
				cd_NumeroPolizaTAO,
				cd_AnexoPolizaTAO,
				am_PorDesFormaPagoTA,
				cd_Penalidad, /*rgelis 2014/11/08 req.22120*/
				ds_cc_vence,
				ds_cc_vence2,
				ds_cc_autorizacion,
				ds_cc_autorizacion2,
				ds_cc_voucher,
				ds_cc_voucher2,
				ds_AutorizacionTarjetaTAO,
				ds_VoucherTarjetaTAO,
				am_fptao,
				in_cc_cuotas,
				in_cc_cuotas2,
				in_cuotasTarjetaTAO,
				NumTktConj, /*rgelis 2014/12/22 req..... para que registre el numero de Product en conjuncion EVT*/
				cd_TipoTarifaTAO,
				cd_TipoTiquete,
				in_CantidadTarifaTAO,
				in_CantidadSegmentoTAO,
				cd_tourcode,
				in_cantpax, --rgelis 2017/08/24 req.35871
				cd_Pseudo, --rgelis 2017/08/30 req.52081
				id_FormasPago, --rgelis 2018/11/19 req.74409
				id_TarjetasCredito, --rgelis 2018/11/19 req.74409
				am_iva2, --rgelis 2019/07/23 req.90597
				in_nacionalidad,
				cd_Pax_CC,
				cd_consecutivo
				/*cd_fp1,
				cd_fp2,
				cd_fp3, 
				am_fp3,
				ds_cc_code3,
				ds_cc_number3,
				ds_cc_vence3,
				ds_ch_number,
				ds_ch_number2,
				ds_ch_number3,
				ds_ch_banco,
				ds_ch_banco2,
				ds_ch_banco3,
				ds_ch_plaza,
				ds_ch_plaza2,
				ds_ch_plaza3*/ /*fin rgelis 2014/03/20 req.15175*/				
			)
		VALUES 
			(
				@id_Booking,
				@ds_pax_number,
				@ds_pax_firstnm,
				@ds_pax_lastnm,
				@ds_pax_prefix,
				@ds_tkt_number,
				Case When @bl_externo = 1 Then @AerolineaExterna Else @ds_tkt_prefix End,
				Case When @bl_externo = 1 Then @CodAerolineaExterna Else @ds_aero_code End,									
--				@ds_tkt_prefix,
--				@ds_aero_code,
				@ds_moneda,
				@am_tarifa,
				@am_iva,
				@am_tua,
				@am_comb,
				@am_vat,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @cd_codigo_tc_airplus ELSE @ds_cc_code END,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @cd_tarjeta_airplus ELSE @ds_cc_number END,
				@am_tao,
				@am_ivatao,
				@am_cap,
				@am_ivacap,
				@ds_cc_code2,
				@ds_cc_number2,
				@am_fp1,
				@am_fp2,
				@cd_tktrevisado,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN 0 ELSE @am_TarifaContado END,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN 0 ELSE @am_IvaContado END,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN 0 ELSE @am_OtrosContado END,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @am_TarifaContado ELSE @am_TarifaCredito END,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @am_IvaContado ELSE @am_IvaCredito END,
				CASE WHEN @bl_usar_airplus_aerolinea_no_airplus = 1 THEN @am_OtrosContado ELSE @am_OtrosCredito END,
				@am_Comision,
				@ds_itinerario,
				Case When @bl_externo = 1 Then @ds_tkt_prefix  Else NULL End,
				Case When @bl_externo = 1 Then @ds_aero_code Else NULL End,
				@bl_NotificacionMPD, /*inicio rgelis 2013/06/28 req.15175*/
				@cd_FormaPagoTAO,
				@cd_TarjetaCreditoTAO,
				@cd_NumeroTarjetaTAO,
				@cd_VencimientoTarjetaTAO,
				@cd_NumeroPolizaTAO,
				@cd_AnexoPolizaTAO,
				@am_PorDesFormaPagoTA,
				@cd_Penalidad, /*rgelis 2014/11/08 req.22120*/
				@ds_cc_vence,
				@ds_cc_vence2,
				@ds_cc_autorizacion,
				@ds_cc_autorizacion2,
				@ds_cc_voucher,
				@ds_cc_voucher2,
				@ds_AutorizacionTarjetaTAO,
				@ds_VoucherTarjetaTAO,
				@am_fptao,
				@in_cc_cuotas,
				@in_cc_cuotas2,
				@in_cuotasTarjetaTAO,
				@in_NumTktConj, /*rgelis 2014/12/22 req..... para que registre el numero de Product en conjuncion EVT*/
				@cd_TipoTarifaTAO,
				@cd_TipoTiquete,
				@in_CantidadTarifaTAO,
				@in_CantidadSegmentoTAO,
				@cd_tourcode2,
				@in_cantpax, --rgelis 2017/08/24 req.35871
				@cd_Pseudo, --rgelis 2017/08/30 req.52081
				@id_FormasPago, --rgelis 2018/11/19 req.74409
				@id_TarjetasCredito, --rgelis 2018/11/19 req.74409
				@am_iva2, --rgelis 2019/07/23 req.90597
				@in_nacionalidad,
				@cd_pax_cedula,
				@cd_consecutivo
				/*@cd_fp1,
				@cd_fp2,
				@cd_fp3, 
				@am_fp3,
				@ds_cc_code3,
				@ds_cc_number3,
				@ds_cc_vence3,
				@ds_ch_number,
				@ds_ch_number2,
				@ds_ch_number3,
				@ds_ch_banco,
				@ds_ch_banco2,
				@ds_ch_banco3,
				@ds_ch_plaza,
				@ds_ch_plaza2,
				@ds_ch_plaza3*/ /*fin rgelis 2014/03/20 req.15175*/								
			)
	END
	

	Update rd
	set rd.bl_anulado = 1
	From BookingGDS_Product rd
	Inner Join Product T on T.code = rd.ds_tkt_number and am_valor_residual>0
	Where rd.ds_tkt_number =  @ds_tkt_number

	If @@error<>0
		Begin
			Raiserror('Error al Guardar los Datos de Detalle de la Booking GDS',16,1)
			Select -1;
			RETURN;
		END
	/*inicio rgelis 2014/02/24 req.18784*/			
	UPDATE rd
	SET rd.bl_usada=1
	FROM dbo.BookingGDS_Product rd 
	 INNER JOIN dbo.Product t on t.code = rd.ds_tkt_number
	WHERE (t.id_invoices is not null Or t.id_referral is not null)
		  AND rd.bl_usada=0
		  AND rd.id_Booking = @id_Booking
	/*fin rgelis 2014/02/24 req.18784*/

		/**/
	SELECT  @cd_cliente =cd_cliente,@ds_cliid = ds_cliid, @cd_sucursal = cd_sucursal
	FROM BookingsGDS 
	WHERE id = @id_Booking
	
	IF (NOT EXISTS(SELECT id FROM dbo.ConfiguracionClientesFacAuto WHERE cd_codigo = @cd_cliente OR cd_codigo=@ds_cliid)
 	    AND EXISTS(SELECT id FROM dbo.Parametros WHERE id = 525 AND RTRIM(LTRIM(Valor)) = 'S')
	   )
	BEGIN
		SET @bl_cliente = 0;
	END
	ELSE IF EXISTS(SELECT * FROM Parametros WHERE Id = 366 AND RTRIM(Valor) ='S') /*rgelis 2014/12/10 si el parametro esta activo se agregan Bookings sin clientes*/
	BEGIN
		SET @bl_cliente= 1;
	END
	ELSE
	BEGIN
		SELECT @bl_cliente = CASE WHEN ISNULL(@ds_cliid,'')<>'' OR ISNULL(@cd_cliente,'')<>'' THEN 1 ELSE 0 END
	END
	-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
	IF EXISTS(SELECT * FROM sucursales S
			  INNER JOIN Sucursal_GDSFacAuto SG ON SG.id_Sucursal = S.id  /*rgelis 2015/08/24 req.27386*/	 
			  WHERE S.cd_codigo=@cd_sucursal and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) /*bl_facauto_sabre=1*/ and @bl_NotificacionMPD=0 AND @bl_cliente = 1) /*rgelis 2013/07/05 req.15175*/
	BEGIN
		SET @bl_usada = 1
		SELECT @bl_usada = bl_usada
		FROM dbo.BookingGDS_Product
		INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
		WHERE BookingsGDS.id = @id_Booking
		AND BookingGDS_Product.bl_usada = 0

		IF ((@bl_usada = 0 and NOT EXISTS (SELECT * FROM BookingsGDS_FacAuto where id_Booking = @Id_BookingsGDS)	)
			or NOT EXISTS (SELECT *
							FROM dbo.BookingGDS_Product
							INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
							WHERE BookingsGDS.id = @id_Booking))
			AND @iden_gds =1
			INSERT INTO BookingsGDS_FacAuto (cd_sucursal,cd_implante,Id_Booking) /*rgelis 2014/03/28 req.15175*/
			VALUES(@cd_sucursal,@cd_implante,@id_Booking) /*rgelis 2014/03/28 req.15175*/
	END
		
	RETURN 0;
End	

If(@Op='DetItinerario')
	Begin
		DECLARE @Y VARCHAR(4), @M VARCHAR(2), @D VARCHAR(2)
		DECLARE @Yr INT, @Mr VARCHAR(2),@YAr VARCHAR(4)

		IF LEN(@ds_fecha_salida)>=8
		BEGIN
			SELECT 	@Y = SUBSTRING(@ds_fecha_salida,1,4),
					@M = SUBSTRING(@ds_fecha_salida,5,2),
					@D = SUBSTRING(@ds_fecha_salida,7,2)
				
			SELECT @Mr = datepart(month,ds_fecha),
				   @YAr = datepart(year,ds_fecha)
			FROM dbo.BookingsGDS WHERE id=@id_Booking

			IF ((CONVERT(INT,@Mr) > CONVERT(INT,@M)) AND (CONVERT(INT,@YAr) >= CONVERT(INT,@Y)))
			BEGIN
				SET @Yr = CONVERT(INT,@Y)
				SET @Yr = @Yr + 1
				SET @Y=CONVERT(VARCHAR(4),@Yr)
			END
			 
			SET @ds_fecha_salida = @Y + RIGHT('00'+@M,2) + RIGHT('00'+@D,2)
		END
									
		Insert Into [dbo].[BookingGDS_Itinerarios]
			([id_Booking]
			,[orden]
			,[cd_origen]
			,[cd_destino]
			,[cd_clase]
			,[fecha_salida]
			,[hora_salida]
			,[hora_llegada]
			,[terminal]
			,[cd_aero_siglas]
			,[cd_farebasis]
			,[ds_NumVuelo] /*rgelis 2014/01/30 req.17473*/
			,[ds_TipoVuelo]
			,[am_valor]) /*rgelis 2014/01/31 req.17473*/
		Values
			(@id_Booking
			,@orden
			,@cd_aero_salida
			,@cd_aero_llegada
			,LEFT(@cd_clase,1)
			,@ds_fecha_salida
			,@ds_hora_salida
			,@ds_hora_llegada
			,@cd_aero_llegada
			,@cd_aero_siglas
			,@cd_farebasis
			,@ds_NumVuelo /*rgelis 2014/01/30 req.17473*/
			,@ds_TipoVuelo
			,@am_valor) /*rgelis 2014/01/31 req.17473*/

	END


If(@Op='DetCar')
	Begin	
		IF EXISTS ( 
					SELECT * FROM dbo.BookingGDS_CAR r 
						WHERE r.id_Booking = @id_Booking
							AND  ds_indice = @ds_indice
				  )
		BEGIN 
			UPDATE dbo.BookingGDS_CAR
			SET
				id_Booking = @id_Booking,
				dt_entrega = @dt_entrega,
				in_cars = @in_cars,
				cd_carcode = @cd_carcode,
				cd_confirmation = @cd_confirmation,
				cd_citysalida = @cd_citysalida,
				dt_retorno = @dt_retorno,
				cd_cartype = @cd_cartype,
				cd_currency = @cd_currency,
				am_tarifa = @am_tarifarenta,
				cd_bookingsource = @cd_bookingsource,
				cd_ratecode = @cd_ratecode,
				ds_indice =	@ds_indice
			WHERE id_Booking = @id_Booking AND  ds_indice = @ds_indice
				
		END
		ELSE
		BEGIN
			INSERT INTO dbo.BookingGDS_CAR
				(		
				id_Booking,
				dt_entrega,
				in_cars,
				cd_carcode,
				cd_confirmation,
				cd_citysalida,
				dt_retorno,
				cd_cartype,
				cd_currency,
				am_tarifa,
				cd_bookingsource,
				cd_ratecode,
				ds_indice --rgelis 2017/09/27 req.51843
				)
			VALUES 
				(
				@id_Booking,
				@dt_entrega,
				@in_cars,
				@cd_carcode,
				@cd_confirmation,
				@cd_citysalida,
				@dt_retorno,
				@cd_cartype,
				@cd_currency,
				@am_tarifarenta,
				@cd_bookingsource,
				@cd_ratecode,
				@ds_indice --rgelis 2017/09/27 req.51843
				)
		END

		IF EXISTS(SELECT A.id FROM Aeropuertos A
		  INNER JOIN Ciudades C ON C.id = A.id_ciudades
		  INNER JOIN Paises P ON P.id = C.id_paises
		  INNER JOIN Parametros PR ON PR.id=240 AND RTRIM(PR.Valor)<>RTRIM(P.ds_nombre) 
		  WHERE A.cd_codigo = @cd_citysalida)
		BEGIN
			SET @in_nacionalidad=2
		END
		ELSE
		BEGIN
			SET @in_nacionalidad=1
		END

		UPDATE dbo.BookingGDS_Product
		SET in_nacionalidad = @in_nacionalidad 
		WHERE id_Booking = @id_Booking
			  AND ds_indice = @ds_indice

		IF (NOT EXISTS(SELECT id FROM dbo.ConfiguracionClientesFacAuto WHERE cd_codigo = @cd_cliente OR cd_codigo=@ds_cliid)
		    AND EXISTS(SELECT id FROM dbo.Parametros WHERE id = 525 AND RTRIM(LTRIM(Valor)) = 'S')
		   )
		BEGIN
			SET @bl_cliente = 0;
		END
		ELSE IF EXISTS(SELECT * FROM Parametros WHERE Id = 366 AND RTRIM(Valor) ='S') -- si el parametro esta activo se agregan Bookings sin clientes
		BEGIN
			SET @bl_cliente= 1;
		END
		ELSE
		BEGIN
			SELECT @bl_cliente = CASE WHEN ISNULL(@ds_cliid,'')<>'' OR ISNULL(@cd_cliente,'')<>'' THEN 1 ELSE 0 END
		END
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (EXISTS(SELECT * FROM sucursales S
				  INNER JOIN Sucursal_GDSFacAuto SG ON SG.id_Sucursal = S.id  
				  WHERE S.cd_codigo=@cd_sucursal and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) /*bl_facauto_sabre=1*/ and @bl_NotificacionMPD=0 AND @bl_cliente = 1) 
		  OR EXISTS( SELECT * FROM dbo.BookingsGDS r 
				     INNER JOIN dbo.BookingGDS_Product s ON s.id_Booking = r.id
					 WHERE r.cd_codigo = @cd_codigo AND @bl_CotizacionFacAuto=1))	
		BEGIN
			SET @bl_usada = 1
			SELECT @bl_usada = bl_usada
			FROM dbo.BookingGDS_Product
			INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
			WHERE BookingsGDS.id = @Id_BookingsGDS
			AND BookingGDS_Product.bl_usada = 0

			IF ((@bl_usada = 0 AND NOT EXISTS (SELECT * FROM BookingsGDS_FacAuto where id_Booking = @Id_BookingsGDS)	)
				OR NOT EXISTS (SELECT *
								FROM dbo.BookingGDS_Product
								INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
								WHERE BookingsGDS.id = @Id_BookingsGDS))
				AND @iden_gds =1
				INSERT INTO BookingsGDS_FacAuto (cd_sucursal,cd_implante,Id_Booking) 
				VALUES(@cd_sucursal,@cd_implante,@Id_BookingsGDS) 
		END
	END

If(@Op='DetHotel')
	Begin	
		IF EXISTS ( 
					SELECT * FROM dbo.BookingGDS_HTL r 
						WHERE r.id_Booking = @id_Booking
							AND (r.Id_BookingGDS_Product = @Id_BookingGDS_Product OR ds_indice = @ds_indice)
				  )
		BEGIN 
			UPDATE dbo.BookingGDS_HTL
			SET
				dt_checkin		= @dt_checkin,
				in_guests		= @in_guests,
				cd_confirmation	= @cd_confirmation,
				cd_city			= @cd_city,
				cd_htlchain		= @cd_htlchain,
				dt_checkout		= @dt_checkout,
				ds_htlname		= @ds_htlname,
				in_habs			= @in_habs,
				cd_bed			= @cd_bed,
				cd_ratecode		= @cd_ratecode,
				cd_htlcur		= @cd_htlcur,
				am_htltarifa	= @am_htltarifa,
				cd_agcur		= @cd_agcur,
				am_agtarifa		= @am_agtarifa,
				ds_dir1			= @ds_dir1,
				ds_tel			= @ds_tel,
				ds_fax			= @ds_fax,
				ds_indice		= @ds_indice, --rgelis 2017/09/26 req.51843
				cd_htl			= @cd_htl --rgelis 2017/09/26 req.51843
			WHERE id_Booking = @id_Booking
				AND (Id_BookingGDS_Product = @Id_BookingGDS_Product OR ds_indice = @ds_indice)
				
		END
		ELSE
		BEGIN
			INSERT INTO dbo.BookingGDS_HTL
				(
				id_Booking,
				dt_checkin,
				in_guests,
				cd_confirmation,
				cd_city,
				cd_htlchain,
				dt_checkout,
				ds_htlname,
				in_habs,
				cd_bed,
				cd_ratecode,
				cd_htlcur,
				am_htltarifa,
				cd_agcur,
				am_agtarifa,
				ds_dir1,
				ds_tel,
				ds_fax,
				Id_BookingGDS_Product,
				ds_indice, --rgelis 2017/09/26 req.51843
				cd_htl --rgelis 2017/09/26 req.51843
				)
			VALUES 
				(
				@id_Booking,
				@dt_checkin,
				@in_guests,
				@cd_confirmation,
				@cd_city,
				@cd_htlchain,
				@dt_checkout,
				@ds_htlname,
				@in_habs,
				@cd_bed,
				@cd_ratecode,
				@cd_htlcur,
				@am_htltarifa,
				@cd_agcur,
				@am_agtarifa,
				@ds_dir1,
				@ds_tel,
				@ds_fax,
				@Id_BookingGDS_Product,
				@ds_indice, --rgelis 2017/09/26 req.51843
				@cd_htl --rgelis 2017/09/26 req.51843
				)
		END

		IF EXISTS(SELECT A.id FROM Aeropuertos A
			  INNER JOIN Ciudades C ON C.id = A.id_ciudades
			  INNER JOIN Paises P ON P.id = C.id_paises
			  INNER JOIN Parametros PR ON PR.id=240 AND RTRIM(PR.Valor)<>RTRIM(P.ds_nombre) 
			  WHERE A.cd_codigo = @cd_city)
		BEGIN
			SET @in_nacionalidad=2
		END
		ELSE
		BEGIN
			SET @in_nacionalidad=1
		END

		UPDATE dbo.BookingGDS_Product
		SET in_nacionalidad = @in_nacionalidad 
		WHERE id_Booking = @id_Booking
				AND ds_indice = @ds_indice	

			--inicio rgelis 2017/09/26 req.51843
			IF (NOT EXISTS(SELECT id FROM dbo.Hoteles WHERE cd_codigo = @cd_htl) AND ISNULL(@cd_htl,'')<>'') --rgelis 2017/12/26 req.55692
			BEGIN
				DECLARE @cd_codigo_cadhotelera VARCHAR(25),@id_codigo_cadhotelera INT,@id_Ciudades INT

				SELECT @id_Ciudades=id FROM dbo.Ciudades WHERE cd_Iata = @cd_city
				SELECT @cd_codigo_cadhotelera=cd_codigo,@id_codigo_cadhotelera=id FROM dbo.Cadena_Hotelera WHERE cd_codigo_gds = @cd_htlchain

				IF (ISNULL(@cd_htlchain,'')<>'' AND ISNULL(@cd_codigo_cadhotelera,'')='')
				BEGIN
					EXEC dbo.spza_CadenaHotelera_Crear @id_usuario=1, @cd_codigo=@cd_htlchain, @ds_nombre=@cd_htlchain, @ds_observaciones='', @cd_codigo_gds=@cd_htlchain
					SELECT @cd_codigo_cadhotelera=cd_codigo,@id_codigo_cadhotelera=id FROM dbo.Cadena_Hotelera WHERE cd_codigo_gds = @cd_htlchain
				END
				 
				Exec dbo.spza_Hotel_Crear @id_usuario=1
										 ,@cd_codigo=@cd_htl
										 ,@ds_nombre=@ds_htlname
										 ,@ds_descrip=@ds_htlname
										 ,@cd_codigo_cadhotelera=@cd_codigo_cadhotelera
										 ,@cd_codigo_gds=@cd_htl
										 ,@cd_proveedor=NULL 
										 ,@IATA=NULL
										 ,@ds_Direccion=@ds_dir1
										 ,@ds_Telefono=@ds_tel
										 ,@ds_Email=NULL
										 ,@ds_Ciudad=@cd_city
										 ,@bl_inactivo=0
										 ,@id_cadhotelera=@id_codigo_cadhotelera
										 ,@id_Ciudades= @id_Ciudades
										 ,@in_nacionalidad=@in_nacionalidad
										 ,@ds_movil=NULL
										 ,@ds_provincia=NULL
										 ,@ds_contacto=NULL
										 ,@ds_fax=@ds_fax
										 ,@ds_comentarios=NULL
										 ,@am_porcomision=NULL
										 ,@bl_facturacomision=0
										 ,@SqlTipoPlan=NULL

			END
			--fin rgelis 2017/09/26 req.51843
			IF (NOT EXISTS(SELECT id FROM dbo.ConfiguracionClientesFacAuto WHERE cd_codigo = @cd_cliente OR cd_codigo=@ds_cliid)
		    AND EXISTS(SELECT id FROM dbo.Parametros WHERE id = 525 AND RTRIM(LTRIM(Valor)) = 'S')
		   )
		BEGIN
			SET @bl_cliente = 0;
		END
		ELSE IF EXISTS(SELECT * FROM Parametros WHERE Id = 366 AND RTRIM(Valor) ='S') -- si el parametro esta activo se agregan Bookings sin clientes
		BEGIN
			SET @bl_cliente= 1;
		END
		ELSE
		BEGIN
			SELECT @bl_cliente = CASE WHEN ISNULL(@ds_cliid,'')<>'' OR ISNULL(@cd_cliente,'')<>'' THEN 1 ELSE 0 END
		END
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (EXISTS(SELECT * FROM sucursales S
				  INNER JOIN Sucursal_GDSFacAuto SG ON SG.id_Sucursal = S.id  
				  WHERE S.cd_codigo=@cd_sucursal and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) /*bl_facauto_sabre=1*/ and @bl_NotificacionMPD=0 AND @bl_cliente = 1) 
		  OR EXISTS( SELECT * FROM dbo.BookingsGDS r 
				     INNER JOIN dbo.BookingGDS_Product s ON s.id_Booking = r.id
					 WHERE r.cd_codigo = @cd_codigo AND @bl_CotizacionFacAuto=1))	
		BEGIN
			SET @bl_usada = 1
			SELECT @bl_usada = bl_usada
			FROM dbo.BookingGDS_Product
			INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
			WHERE BookingsGDS.id = @Id_BookingsGDS
			AND BookingGDS_Product.bl_usada = 0

			IF ((@bl_usada = 0 AND NOT EXISTS (SELECT * FROM BookingsGDS_FacAuto where id_Booking = @Id_BookingsGDS)	)
				OR NOT EXISTS (SELECT *
								FROM dbo.BookingGDS_Product
								INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
								WHERE BookingsGDS.id = @Id_BookingsGDS))
				AND @iden_gds = 1
				INSERT INTO BookingsGDS_FacAuto (cd_sucursal,cd_implante,Id_Booking) 
				VALUES(@cd_sucursal,@cd_implante,@Id_BookingsGDS) 
		END
		 
		 
	END
	If(@Op='DetSrv')
	BEGIN
		/*inicio rgelis 2013/07/03 se Modifica para que se guarden los Product de terceros*/
		IF EXISTS ( 
				SELECT * FROM dbo.BookingGDS_Product r 
					WHERE r.id_Booking = @id_Booking
						AND ds_indice = @ds_indice
			  )
		BEGIN 
			UPDATE dbo.BookingGDS_Product
			SET	id_Booking = @id_Booking,
				cd_conceptofacturacion = @cd_conceptofacturacion,
				cd_tiposervicio = @cd_tiposervicio,
				cd_proveedores = @cd_proveedores,
				ds_descrip = @ds_descrip,
				ds_pax_number = @ds_pax_number,
				ds_pax_firstnm = @ds_pax_firstnm,
				ds_pax_lastnm = @ds_pax_lastnm,
				ds_pax_prefix = @ds_pax_prefix,
				ds_moneda = @ds_moneda,
				am_tarifa = @am_tarifa,
				am_iva = @am_iva,
				am_vat = @am_vat,
				ds_cc_code = @ds_cc_code,
				ds_cc_number = @ds_cc_number,
				ds_cc_code2 = @ds_cc_code2,
				ds_cc_number2 = @ds_cc_number2,
				am_fp1 = @am_fp1,
				am_fp2 = @am_fp2,
				am_TarifaContado = @am_tarifacontado,
				am_IvaContado = @am_ivacontado,
				am_OtrosContado = @am_otroscontado,
				am_TarifaCredito = @am_tarifacredito,
				am_IvaCredito = @am_ivacredito,
				am_OtrosCredito = @am_otroscredito,
				am_Comision = @am_comision,
				bl_anulado = 0,
				cd_auxiliar = @cd_auxiliar,
				in_nacionalidad = @in_nacionalidad,
				cd_paxidentificacion = @cd_pax_cedula,
				cd_tipoproveedor=@cd_tipoproveedor,
				ds_tipoproveedor=@ds_tipoproveedor,
				dt_checkin = @dt_checkin,
				dt_checkout = @dt_checkout,
				cd_consecutivo=@cd_consecutivo
			WHERE id_Booking = @id_Booking
				AND ds_indice = @ds_indice --rgelis 2018/04/10 req.56942
				--AND cd_conceptofacturacion = @cd_conceptofacturacion	
					
			If @@error<>0
			Begin
				Raiserror('Error al Guardar los Datos de Product de la Booking GDS',16,1)
				Select -1;
				RETURN;
			End
			Return	
		END
		ELSE
		BEGIN
			INSERT INTO dbo.BookingGDS_Product
			(id_Booking,
				cd_conceptofacturacion,
				cd_tiposervicio,
				cd_proveedores,
				ds_descrip,
				ds_pax_number,
				ds_pax_firstnm,
				ds_pax_lastnm,
				ds_pax_prefix,
				ds_moneda,
				am_tarifa,
				am_iva,
				am_vat,
				ds_cc_code,
				ds_cc_number,
				ds_cc_code2,
				ds_cc_number2,
				am_fp1,
				am_fp2,
				am_TarifaContado,
				am_IvaContado,
				am_OtrosContado,
				am_TarifaCredito,
				am_IvaCredito,
				am_OtrosCredito,
				am_Comision,
				bl_anulado,
				ds_indice, --rgelis 2017/09/26 req.51843
				cd_auxiliar,
				in_nacionalidad,
				cd_paxidentificacion,
				cd_tipoproveedor,
				ds_tipoproveedor,
				dt_checkin, 
				dt_checkout,
				cd_consecutivo
				)
			VALUES
				(@id_Booking,
				@cd_conceptofacturacion,
				@cd_tiposervicio,
				@cd_proveedores,
				@ds_descrip,
				@ds_pax_number,
				@ds_pax_firstnm,
				@ds_pax_lastnm,
				@ds_pax_prefix,
				@ds_moneda,
				@am_tarifa,
				@am_iva,
				@am_vat,
				@ds_cc_code,
				@ds_cc_number,
				@ds_cc_code2,
				@ds_cc_number2,
				@am_fp1,
				@am_fp2,
				@am_tarifacontado,
				@am_ivacontado,
				@am_otroscontado,
				@am_tarifacredito,
				@am_ivacredito,
				@am_otroscredito,
				@am_comision,
				0,
				@ds_indice, --rgelis 2017/09/26 req.51843
				@cd_auxiliar,
				@in_nacionalidad,
				@cd_pax_cedula,
				@cd_tipoproveedor,
				@ds_tipoproveedor,
				@dt_checkin,
				@dt_checkout,
				@cd_consecutivo
				)
				If @@error<>0
				Begin
					Raiserror('Error al Guardar los Datos de Product de la Booking GDS',16,1)
					Select -1;
					RETURN;
				End
				Return
		END		
		/*fin rgelis 2013/07/03 se Modifica para que se guarden los Product de terceros*/
		IF (NOT EXISTS(SELECT id FROM dbo.ConfiguracionClientesFacAuto WHERE cd_codigo = @cd_cliente OR cd_codigo=@ds_cliid)
		    AND EXISTS(SELECT id FROM dbo.Parametros WHERE id = 525 AND RTRIM(LTRIM(Valor)) = 'S')
		   )
		BEGIN
			SET @bl_cliente = 0;
		END
		ELSE IF EXISTS(SELECT * FROM Parametros WHERE Id = 366 AND RTRIM(Valor) ='S') -- si el parametro esta activo se agregan Bookings sin clientes
		BEGIN
			SET @bl_cliente= 1;
		END
		ELSE
		BEGIN
			SELECT @bl_cliente = CASE WHEN ISNULL(@ds_cliid,'')<>'' OR ISNULL(@cd_cliente,'')<>'' THEN 1 ELSE 0 END
		END
		-- Si la facturacion automatica de SABRE esta habilitada, insertamos el registro
		IF (EXISTS(SELECT * FROM sucursales S
				  INNER JOIN Sucursal_GDSFacAuto SG ON SG.id_Sucursal = S.id  
				  WHERE S.cd_codigo=@cd_sucursal and (SG.id_GDS = 1 and SG.bl_FacAuto = 1) /*bl_facauto_sabre=1*/ and @bl_NotificacionMPD=0 AND @bl_cliente = 1) 
		  OR EXISTS( SELECT * FROM dbo.BookingsGDS r 
				     INNER JOIN dbo.BookingGDS_Product s ON s.id_Booking = r.id
					 WHERE r.cd_codigo = @cd_codigo AND @bl_CotizacionFacAuto=1))	
		BEGIN
			SET @bl_usada = 1
			SELECT @bl_usada = bl_usada
			FROM dbo.BookingGDS_Product
			INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
			WHERE BookingsGDS.id = @Id_BookingsGDS
			AND BookingGDS_Product.bl_usada = 0

			IF ((@bl_usada = 0 AND NOT EXISTS (SELECT * FROM BookingsGDS_FacAuto where id_Booking = @Id_BookingsGDS)	)
				OR NOT EXISTS (SELECT *
								FROM dbo.BookingGDS_Product
								INNER JOIN dbo.BookingsGDS on BookingsGDS.id = BookingGDS_Product.id_Booking
								WHERE BookingsGDS.id = @Id_BookingsGDS))
				AND @iden_gds = 1	
				INSERT INTO BookingsGDS_FacAuto (cd_sucursal,cd_implante,Id_Booking) 
				VALUES(@cd_sucursal,@cd_implante,@Id_BookingsGDS) 
		END
	END

	/*inicio rgelis 2013/07/02 req.15175*/	
	If(@Op='Poliza')
	BEGIN
		INSERT INTO dbo.BookingGDS_Polizas(id_Booking,cd_Numero,cd_Anexo,am_Valor)
		VALUES (@id_Booking,@cd_NumeroPoliza,@cd_AnexoPoliza,@am_ValorPoliza)
	END
	/*fin rgelis 2013/07/02 req.15175*/
	--inicio rgelis 2018/01/22 req.46714
	If(@Op='PaxAdicional')
	BEGIN
		INSERT INTO dbo.BookingGDS_Product_PaxAdicional(id_Booking,Id_BookingGDS_Product,ds_paxape,ds_paxname,ds_paxprefix,ds_paxClasificacion,cd_voucherpax,cd_paxidentificacion,in_edad,code)
		VALUES (@id_Booking,@Id_BookingGDS_Product,@ds_pax_lastnm,@ds_pax_firstnm,@ds_pax_prefix,@ds_paxClasificacion,@cd_voucherpax,@cd_pax_cedula,@in_edad,@ds_tkt_number)
	END
	--fin rgelis 2018/01/22 req.46714
	
	--inicio rgelis 2018/10/25 req.62804
	If(@Op='VarAdicional')
	BEGIN 
		INSERT INTO dbo.BookingGDS_VariableAdicional(id_Booking,Id_BookingGDS_Product,Id_BookingGDS_Product,in_orden,ds_nombre,ds_valor)
		VALUES (@id_Booking,@Id_BookingGDS_Product,@Id_BookingGDS_Product,@in_orden,@ds_nombre,@ds_valor)
	END
	--fin rgelis 2018/10/25 req.62804
	
	--inicio rgelis 2022/05/16 req.227439 
	If(@Op='CargosImpuestos')
	BEGIN
		INSERT INTO dbo.BookingGDS_CargosImpuestos(id_Booking,Id_BookingGDS_Product,Id_BookingGDS_Product,in_orden,cd_codigo,ds_nombre,cd_tipo,cd_codigopadre,cd_tipopadre,am_porcentaje,am_contado,am_credito,am_valor)
		VALUES (@id_Booking,@Id_BookingGDS_Product,@Id_BookingGDS_Product,@in_orden,@cd_codigocarg,@ds_nombre,@cd_tipo,@cd_codigopadre,@cd_tipopadre,@am_porcentaje,@am_contado,@am_credito,@am_valor)
	END

	If(@Op='FormasPagos')
	BEGIN
		INSERT INTO dbo.BookingGDS_FormasPagos(id_Booking,id_BookingGDS_Product,id_BookingGDS_Product,in_orden,cd_codigo,ds_nombre,cd_tipotarjeta,ds_numerotarjeta,ds_vouchertarjeta,ds_expiraciontarjeta,ds_autorizaciontarjeta,in_coutas,cd_banco,ds_cheque,ds_plaza,ds_referencia,ds_Poliza,ds_PolizaAnexo,am_valor)
		VALUES (@id_Booking,@id_BookingGDS_Product,@id_BookingGDS_Product,@in_orden,@cd_codigofp,@ds_nombrefp,@cd_tipotarjeta,@ds_numerotarjeta,@ds_vouchertarjeta,@ds_expiraciontarjeta,@ds_autorizaciontarjeta,@in_coutas,@cd_banco,@ds_cheque,@ds_plaza,@ds_referencia,@ds_Poliza,@ds_PolizaAnexo,@am_valor)
	END
--fin rgelis 2022/05/16 req.227439 

	If(@Op='FEE')
	BEGIN
		INSERT INTO dbo.BookingGDS_Fee(id_Booking,code,in_orden,cd_conceptofac,cd_subcodigo,am_valor,ds_servicio)
		VALUES (@id_Booking,@ds_tkt_number,@in_orden,@cd_conceptofacturacion,@cd_TipoServicio,@am_valor,@ds_Descrip)
	END
	
GO
