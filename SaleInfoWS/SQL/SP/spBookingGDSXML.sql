CREATE OR REPLACE PROCEDURE public."spBookingGDSXML"(
	p_xml TEXT,
	INOUT p_result JSON DEFAULT NULL
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    v_xml XML;
    r_head RECORD;
    r_product RECORD;
    r_itinerary RECORD;
    r_passenger RECORD;
    r_var RECORD;
    r_fee RECORD;
    r_tax RECORD;
    r_payment RECORD;
    
    v_bookingId INTEGER;
    v_bookingProductId INTEGER;
    v_processed_count INTEGER := 0;
BEGIN
    -- Intentamos parsear el XML
    BEGIN
        v_xml := XMLPARSE(DOCUMENT p_xml);
    EXCEPTION WHEN OTHERS THEN
        p_result := json_build_object('status', 'error', 'message', 'Error parseando el XML: ' || SQLERRM);
        RETURN;
    END;

    -- 1. Crear Tablas Temporales (ON COMMIT DROP asegura limpieza al finalizar la transacción)
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_head (
        cd_codigo VARCHAR(12),
        branch VARCHAR(5),
        implant VARCHAR(5),
        seller VARCHAR(3),
        client VARCHAR(25),
        booking_date VARCHAR(10),
        gds INTEGER,
        interfaces INTEGER,
        type_trans VARCHAR(1),
        consecutivo VARCHAR(25)
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_products (
        consecutivo VARCHAR(25),
        cd_codigo VARCHAR(12),
        op_type VARCHAR(15),
        ds_tipoitem VARCHAR(25),
        amount DOUBLE PRECISION,
        tax DOUBLE PRECISION,
        vat DOUBLE PRECISION,
        fee DOUBLE PRECISION,
        provider VARCHAR(25),
        status VARCHAR(25),
        product_type VARCHAR(25),
        product_description TEXT,
        prestadora_code VARCHAR(3),
        nights INTEGER,
        pax_adults INTEGER,
        pax_children INTEGER,
        quantity INTEGER,
        cost DOUBLE PRECISION,
        check_in_date VARCHAR(10),
        check_out_date VARCHAR(10),
        city VARCHAR(3),
        tiquet_printer VARCHAR(6),
        revised VARCHAR(25),
        penalty VARCHAR(25),
        billing_concept TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_itinerary (
        product_consecutivo VARCHAR(25),
        orden INTEGER,
        origin VARCHAR(3),
        destination VARCHAR(3),
        class VARCHAR(2),
        check_in_date VARCHAR(20),
        check_out_date VARCHAR(20),
        terminal VARCHAR(25),
        prestadora VARCHAR(3),
        farebasis VARCHAR(25),
        num_flight VARCHAR(25),
        type_flight VARCHAR(1)
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_passengers (
        product_consecutivo VARCHAR(25),
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        doc_type VARCHAR(25),
        identification VARCHAR(25),
        email VARCHAR(100),
        phone VARCHAR(25),
        pax_type VARCHAR(25),
        consecutivo VARCHAR(25)
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_variables (
        product_consecutivo VARCHAR(25),
        var_name TEXT,
        var_value TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_payments (
        product_consecutivo VARCHAR(25),
        pay_code VARCHAR(50),
        pay_name VARCHAR(50),
        pay_amount DOUBLE PRECISION,
        cc_type VARCHAR(2),
        cc_number VARCHAR(16),
        exp_date VARCHAR(5),
        auth VARCHAR(25),
        voucher VARCHAR(25),
        bank VARCHAR(25),
        quotas INTEGER
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_fees (
        product_consecutivo VARCHAR(25),
        fee_code VARCHAR(25),
        fee_name VARCHAR(50),
        fee_amount DOUBLE PRECISION,
        fee_description TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_taxes (
        product_consecutivo VARCHAR(25),
        tax_code VARCHAR(25),
        tax_name VARCHAR(50),
        tax_amount DOUBLE PRECISION,
        tax_type VARCHAR(25),
        is_main BOOLEAN
    ) ON COMMIT DROP;

    -- 2. Limpiar tablas (por si acaso se reutilizan en la misma sesión)
    TRUNCATE temp_head, temp_products, temp_itinerary, temp_passengers, temp_variables, temp_payments, temp_fees, temp_taxes;

    -- 3. Poblar Tablas Temporales (Basado en el ejemplo booksReserva.xml)

    -- Cabecera
    INSERT INTO temp_head (cd_codigo, branch, implant, seller, client, booking_date, gds, interfaces, type_trans, consecutivo)
    SELECT InternalLocator, AgencyCountry, codeEntity, loginBook, AgencyCodeClient, dateLocator, 1, 1, '1', InternalLocator
    FROM XMLTABLE('//Books/Book' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR(12) PATH 'InternalLocator',
            dateLocator VARCHAR(10) PATH 'dateLocator',
            codeEntity VARCHAR(5) PATH 'EntityBook/codeEntity',
            AgencyCountry VARCHAR(5) PATH 'EntityBook/AgencyCountry',
            AgencyCodeClient VARCHAR(25) PATH 'EntityBook/AgencyCodeClient',
            loginBook VARCHAR(3) PATH 'UserBook/loginBook'
    );

    -- Productos: Vuelos
    INSERT INTO temp_products (consecutivo, cd_codigo, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, prestadora_code, nights, quantity, cost)
    SELECT locSource, InternalLocator, 'flight', 'Vuelo', totalTicket, TotalTax, 0, totalAncillary, iataCode, 'OK', 'Vuelo', route, iataCode, 0, 1, totalTicket
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR(12) PATH '../../InternalLocator',
            locSource VARCHAR(25) PATH 'locSource',
            totalTicket DOUBLE PRECISION PATH 'fare/totalTicket',
            TotalTax DOUBLE PRECISION PATH 'fare/TotalTax',
            totalAncillary DOUBLE PRECISION PATH 'fare/totalAncillary',
            iataCode VARCHAR(25) PATH 'airCompanyIssue/iataCode',
            route TEXT PATH 'route'
    );

    -- Productos: Hoteles
    INSERT INTO temp_products (consecutivo, cd_codigo, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, nights, quantity, cost, check_in_date, check_out_date, city)
    SELECT locSource, InternalLocator, 'hotel', 'Hotel', totalSellFare, totalTax, 0, feeValue, sourceName, status, 'Hotel', hotelName, numberNigths, 1, totalNetfare, dateCheckin, dateCheckout, Hotelcity
    FROM XMLTABLE('//Books/Book/bookInfoHotels/bookInfoHotel' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR(12) PATH '../../InternalLocator',
            locSource VARCHAR(25) PATH 'locSource',
            status VARCHAR(25) PATH 'status',
            sourceName VARCHAR(25) PATH 'sourceName',
            totalSellFare DOUBLE PRECISION PATH 'InfoBook/fareHotel/totalSellFare',
            totalTax DOUBLE PRECISION PATH 'InfoBook/fareHotel/totalTax',
            totalNetfare DOUBLE PRECISION PATH 'InfoBook/fareHotel/totalNetfare',
            feeValue DOUBLE PRECISION PATH 'InfoBook/fareHotel/feeValue',
            numberNigths INTEGER PATH 'InfoBook/numberNigths',
            dateCheckin VARCHAR(10) PATH 'InfoBook/dateCheckin',
            dateCheckout VARCHAR(10) PATH 'InfoBook/dateCheckout',
            Hotelcity VARCHAR(3) PATH 'InfoBook/Hotelcity',
            hotelName TEXT PATH 'InfoBook/hotelInfo/hotelName'
    );

    -- Productos: Autos
    INSERT INTO temp_products (consecutivo, cd_codigo, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, nights, quantity, cost, check_in_date, check_out_date, city)
    SELECT locSource, InternalLocator, 'car', 'Auto', totalSellFare, totalTax, 0, feeValue, nameRentaCar, status, 'Auto', vehiculeType, 0, 1, totalNetfare, pickUpDate, DropOffDate, iataCodePickup
    FROM XMLTABLE('//Books/Book/bookCars/bookCar' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR(12) PATH '../../InternalLocator',
            locSource VARCHAR(25) PATH 'locSource',
            status VARCHAR(25) PATH 'status',
            nameRentaCar VARCHAR(25) PATH 'nameRentaCar',
            totalSellFare DOUBLE PRECISION PATH 'fareCar/totalSellFare',
            totalTax DOUBLE PRECISION PATH 'fareCar/totalTax',
            totalNetfare DOUBLE PRECISION PATH 'fareCar/totalNetfare',
            feeValue DOUBLE PRECISION PATH 'fareCar/feeValue',
            pickUpDate VARCHAR(10) PATH 'pickUpDate',
            DropOffDate VARCHAR(10) PATH 'DropOffDate',
            iataCodePickup VARCHAR(3) PATH 'pickupLocation/iataCodePickup',
            vehiculeType TEXT PATH 'fareCar/vehiculeType'
    );

    -- Productos: Seguros
    INSERT INTO temp_products (consecutivo, cd_codigo, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, nights, quantity, cost, check_in_date, check_out_date)
    SELECT locSource, InternalLocator, 'insurance', 'Seguro', totaSellFare, 0, 0, 0, sourceName, status, 'Seguro', 'Seguro de Viaje', 0, 1, totaNetFare, dateStarService, dateFinalService
    FROM XMLTABLE('//Books/Book/Insurances/Insurance' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR(12) PATH '../../InternalLocator',
            locSource VARCHAR(25) PATH 'locSource',
            status VARCHAR(25) PATH 'status',
            sourceName VARCHAR(25) PATH 'sourceName',
            totaSellFare DOUBLE PRECISION PATH 'fareInsurance/totaSellFare',
            totaNetFare DOUBLE PRECISION PATH 'fareInsurance/totaNetFare',
            dateStarService VARCHAR(10) PATH 'dateStarService',
            dateFinalService VARCHAR(10) PATH 'dateFinalService'
    );

    -- Itinerario (Vuelos)
    INSERT INTO temp_itinerary (product_consecutivo, orden, origin, destination, class, check_in_date, check_out_date, terminal, prestadora, farebasis, num_flight, type_flight)
    SELECT locSource, segmentNumber, DepartureIata, ArrivalIata, Class, DepartureDate, ArrivalDate, terminalDeparture, airlineOperator, fareBase, Record, 'D'
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight/segments/segment' PASSING v_xml
        COLUMNS 
            locSource VARCHAR(25) PATH '../../locSource',
            segmentNumber INTEGER PATH 'segmentNumber',
            DepartureIata VARCHAR(3) PATH 'DepartureIata',
            ArrivalIata VARCHAR(3) PATH 'ArrivalIata',
            Class VARCHAR(2) PATH 'Class',
            DepartureDate VARCHAR(20) PATH 'DepartureDate',
            ArrivalDate VARCHAR(20) PATH 'ArrivalDate',
            terminalDeparture VARCHAR(25) PATH 'terminalDeparture',
            airlineOperator VARCHAR(3) PATH 'airlineOperator',
            fareBase VARCHAR(25) PATH 'fareBase',
            Record VARCHAR(25) PATH 'Record'
    );

    -- Pasajeros (Vuelos)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, identification, email, pax_type, consecutivo)
    SELECT locSource, name, lastName, identification, email, paxtype, identification
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR(25) PATH '../../locSource',
            name VARCHAR(50) PATH 'name',
            lastName VARCHAR(50) PATH 'lastName',
            identification VARCHAR(25) PATH 'identification',
            email VARCHAR(100) PATH 'email',
            paxtype VARCHAR(25) PATH 'paxtype'
    );

    -- Pasajeros (Hoteles)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, identification, email, pax_type, consecutivo)
    SELECT locSource, name, lastName, identification, mailPax, typePax, identification
    FROM XMLTABLE('//Books/Book/bookInfoHotels/bookInfoHotel/InfoBook/rooms/room/paxes/pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR(25) PATH '../../../../locSource',
            name VARCHAR(50) PATH 'name',
            lastName VARCHAR(50) PATH 'lastName',
            identification VARCHAR(25) PATH 'identification',
            mailPax VARCHAR(100) PATH 'mailPax',
            typePax VARCHAR(25) PATH 'typePax'
    );

    -- Pasajeros (Autos)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, email, consecutivo)
    SELECT locSource, name, lastName, mailPax, name || lastName
    FROM XMLTABLE('//Books/Book/bookCars/bookCar/pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR(25) PATH '../locSource',
            name VARCHAR(50) PATH 'name',
            lastName VARCHAR(50) PATH 'lastName',
            mailPax VARCHAR(100) PATH 'mailPax'
    );

    -- Pasajeros (Seguros)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, identification, email, pax_type, consecutivo)
    SELECT locSource, name, lastName, identification, mailPax, typePax, identification
    FROM XMLTABLE('//Books/Book/Insurances/Insurance/fareInsurance/Paxes/pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR(25) PATH '../../../locSource',
            name VARCHAR(50) PATH 'name',
            lastName VARCHAR(50) PATH 'lastName',
            identification VARCHAR(25) PATH 'identification',
            mailPax VARCHAR(100) PATH 'mailPax',
            typePax VARCHAR(25) PATH 'typePax'
    );

    -- Variables (UDIDS)
    INSERT INTO temp_variables (product_consecutivo, var_name, var_value)
    SELECT InternalLocator, name, value
    FROM XMLTABLE('//Books/Book/CorporateInfo/UDIDS/udid' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR(12) PATH '../../../../InternalLocator',
            name TEXT PATH 'name',
            value TEXT PATH 'value'
    );

    -- 4. Procesamiento mediante ciclos
    
    FOR r_head IN (SELECT * FROM temp_head) LOOP
        -- Paso 1: Crear Cabecera
        BEGIN
            CALL public."spBookingGDS"(
                p_Op := 'head',
                p_code := r_head.cd_codigo,
                p_branch := r_head.branch,
                p_implant := r_head.implant,
                p_seller := r_head.seller,
                p_client := r_head.client,
                p_date := r_head.booking_date,
                p_gds := r_head.gds,
                p_interfaces := r_head.interfaces,
                p_typetransaction := r_head.type_trans,
                p_id_out := v_bookingId
            );
        EXCEPTION WHEN OTHERS THEN
            CONTINUE;
        END;

        -- Paso 2: Procesar Productos
        FOR r_product IN (SELECT * FROM temp_products WHERE cd_codigo = r_head.cd_codigo) LOOP
            BEGIN
                CALL public."spBookingGDS"(
                    p_Op := r_product.op_type,
                    p_bookingId := v_bookingId,
                    p_amount := r_product.amount,
                    p_tax := r_product.tax,
                    p_vat := r_product.vat,
                    p_fee := r_product.fee,
                    p_provider := r_product.provider,
                    p_productType := r_product.product_type,
                    p_productDescription := r_product.product_description,
                    p_prestadoraCode := r_product.prestadora_code,
                    p_nights := r_product.nights,
                    p_paxAdults := r_product.pax_adults,
                    p_quantity := r_product.quantity,
                    p_cost := r_product.cost,
                    p_tiquetPrinter := r_product.tiquet_printer,
                    p_revised := r_product.revised,
                    p_penalty := r_product.penalty,
                    p_billingConcept := r_product.billing_concept,
                    p_id_out := v_bookingProductId
                );
            EXCEPTION WHEN OTHERS THEN
                CONTINUE;
            END;

            -- Paso 3: Sub-ítems
            
            -- Pasajeros
            FOR r_passenger IN (SELECT * FROM temp_passengers WHERE product_consecutivo = r_product.consecutivo) LOOP
                CALL public."spBookingGDS"(
                    p_Op := 'passanger',
                    p_bookingId := v_bookingId,
                    p_bookingProductId := v_bookingProductId,
                    p_firstName := r_passenger.first_name,
                    p_lastName := r_passenger.last_name,
                    p_documentType := r_passenger.doc_type,
                    p_identification := r_passenger.identification,
                    p_email := r_passenger.email,
                    p_phone := r_passenger.phone,
                    p_type := r_passenger.pax_type
                );
            END LOOP;

            -- Itinerario
            FOR r_itinerary IN (SELECT * FROM temp_itinerary WHERE product_consecutivo = r_product.consecutivo) LOOP
                CALL public."spBookingGDS"(
                    p_Op := 'itinerary',
                    p_bookingId := v_bookingId,
                    p_bookingProductId := v_bookingProductId,
                    p_orden := r_itinerary.orden,
                    p_origin := r_itinerary.origin,
                    p_destination := r_itinerary.destination,
                    p_class := r_itinerary.class,
                    p_checkInDate := r_itinerary.check_in_date::TIMESTAMP,
                    p_checkOutDate := r_itinerary.check_out_date::TIMESTAMP,
                    p_terminal := r_itinerary.terminal,
                    p_prestadoraCode := r_itinerary.prestadora,
                    p_farebasis := r_itinerary.farebasis,
                    p_Numflight := r_itinerary.num_flight,
                    p_Typeflight := r_itinerary.type_flight
                );
            END LOOP;

            -- Variables (ligadas a la cabecera en este caso)
            FOR r_var IN (SELECT * FROM temp_variables WHERE product_consecutivo = r_head.cd_codigo) LOOP
                CALL public."spBookingGDS"(
                    p_Op := 'var',
                    p_bookingId := v_bookingId,
                    p_bookingProductId := v_bookingProductId,
                    p_varName := r_var.var_name,
                    p_varValue := r_var.var_value
                );
            END LOOP;

        END LOOP;
        
        v_processed_count := v_processed_count + 1;
    END LOOP;

    p_result := json_build_object(
        'status', 'success',
        'processed_bookings', v_processed_count,
        'last_booking_id', v_bookingId
    );
END;
$BODY$;

ALTER PROCEDURE public."spBookingGDSXML"(text, json) OWNER TO postgres;
