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
    v_dummy_out INTEGER;
    v_processed_count INTEGER := 0;
    v_err_context text;
    v_interface_id INTEGER;
BEGIN
    -- Intentamos parsear el XML
    BEGIN
        v_xml := XMLPARSE(DOCUMENT p_xml);
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_err_context = PG_EXCEPTION_CONTEXT;
        p_result := json_build_object('status', 'error', 'message', 'Error parseando el XML: ' || SQLERRM || ' [Contexto: ' || v_err_context || ']');
        RETURN;
    END;
	--RAISE NOTICE 'xml: %', v_xml;
    -- Obtener ID de la interfaz para la equivalencia de códigos
    SELECT id INTO v_interface_id FROM public."Interfaces" WHERE code = 'IdeasFractal' LIMIT 1;
    IF v_interface_id IS NULL THEN
        v_interface_id := 3;
    END IF;

    -- 1. Crear Tablas Temporales (ON COMMIT DROP asegura limpieza al finalizar la transacción)
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_head (
        cd_codigo VARCHAR,
        branch VARCHAR,
        implant VARCHAR,
        seller VARCHAR,
        client VARCHAR,
        booking_date VARCHAR,
        gds INTEGER,
        interfaces INTEGER,
        type_trans VARCHAR,
        consecutivo VARCHAR,
        currency VARCHAR,
        exchange_rate DOUBLE PRECISION,
        booking TEXT,
        iata VARCHAR,
        description TEXT,
        observation TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_products (
        consecutivo VARCHAR,
        cd_codigo VARCHAR,
        parent_locator VARCHAR,
        op_type VARCHAR,
        ds_tipoitem VARCHAR,
        amount DOUBLE PRECISION,
        tax DOUBLE PRECISION,
        vat DOUBLE PRECISION,
        fee DOUBLE PRECISION,
        provider VARCHAR,
        status VARCHAR,
        product_type VARCHAR,
        product_description TEXT,
        prestadora_code VARCHAR,
        nights INTEGER,
        pax_adults INTEGER,
        pax_children INTEGER,
        quantity INTEGER,
        cost DOUBLE PRECISION,
        check_in_date VARCHAR,
        check_out_date VARCHAR,
        city VARCHAR,
        tiquet_printer VARCHAR,
        revised VARCHAR,
        penalty VARCHAR,
        billing_concept TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_itinerary (
        product_consecutivo VARCHAR,
        orden INTEGER,
        origin VARCHAR,
        destination VARCHAR,
        class VARCHAR,
        check_in_date VARCHAR,
        check_out_date VARCHAR,
        terminal VARCHAR,
        prestadora VARCHAR,
        farebasis VARCHAR,
        num_flight VARCHAR,
        type_flight VARCHAR
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_passengers (
        product_consecutivo VARCHAR,
        first_name VARCHAR,
        last_name VARCHAR,
        doc_type VARCHAR,
        identification VARCHAR,
        email VARCHAR,
        phone VARCHAR,
        pax_type VARCHAR,
        consecutivo VARCHAR
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_variables (
        product_consecutivo VARCHAR,
        var_name TEXT,
        var_value TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_payments (
        product_consecutivo VARCHAR,
        pay_code VARCHAR,
        pay_name VARCHAR,
        pay_amount DOUBLE PRECISION,
        cc_type VARCHAR,
        cc_number VARCHAR,
        exp_date VARCHAR,
        auth VARCHAR,
        voucher VARCHAR,
        bank VARCHAR,
        quotas INTEGER
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_fees (
        product_consecutivo VARCHAR,
        fee_code VARCHAR,
        fee_name VARCHAR,
        fee_amount DOUBLE PRECISION,
        fee_description TEXT
    ) ON COMMIT DROP;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_taxes (
        product_consecutivo VARCHAR,
        tax_code VARCHAR,
        tax_name VARCHAR,
        tax_amount DOUBLE PRECISION,
        tax_type VARCHAR,
        is_main BOOLEAN
    ) ON COMMIT DROP;

    -- 2. Limpiar tablas (por si acaso se reutilizan en la misma sesión)
    TRUNCATE temp_head, temp_products, temp_itinerary, temp_passengers, temp_variables, temp_payments, temp_fees, temp_taxes;

    -- 3. Poblar Tablas Temporales (Basado en el ejemplo booksReserva.xml)

    -- Cabecera
    INSERT INTO temp_head (
        cd_codigo, branch, implant, seller, client, booking_date, gds, interfaces, type_trans, consecutivo,
        currency, exchange_rate, booking, iata, description, observation
    )
    SELECT 
        InternalLocator, AgencyCountry, codeEntity, loginBook, AgencyCodeClient, dateLocator, 1, 1, '1', InternalLocator,
        COALESCE(flight_currency, hotel_currency, car_currency, insurance_currency, 'COP'),
        COALESCE(NULLIF(flight_exrate, '')::DOUBLE PRECISION, NULLIF(hotel_exrate, '')::DOUBLE PRECISION, NULLIF(car_exrate, '')::DOUBLE PRECISION, NULLIF(insurance_exrate, '')::DOUBLE PRECISION, 1.0),
        p_xml,
        flight_iata,
        'Reserva de GDS ' || InternalLocator,
        COALESCE(observation, '')
    FROM XMLTABLE('//Books/Book' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR PATH 'InternalLocator',
            dateLocator VARCHAR PATH 'dateLocator',
            codeEntity VARCHAR PATH 'EntityBook/codeEntity',
            AgencyCountry VARCHAR PATH 'EntityBook/AgencyCountry',
            AgencyCodeClient VARCHAR PATH 'EntityBook/AgencyCodeClient',
            loginBook VARCHAR PATH 'UserBook/loginBook',
            observation VARCHAR PATH 'observation',
            
            flight_currency VARCHAR PATH 'BookInfoFlights/BookInfoFlight[1]/Paxes/Pax[1]/fare/currencyFare',
            hotel_currency VARCHAR PATH 'bookInfoHotels/bookInfoHotel[1]/InfoBook/fareHotel/currency',
            car_currency VARCHAR PATH 'bookCars/bookCar[1]/fareCar/currency',
            insurance_currency VARCHAR PATH 'Insurances/Insurance[1]/fareInsurance/currency',
            
            flight_exrate VARCHAR PATH 'BookInfoFlights/BookInfoFlight[1]/Paxes/Pax[1]/fare/ExchangeRate',
            hotel_exrate VARCHAR PATH 'bookInfoHotels/bookInfoHotel[1]/InfoBook/fareHotel/ExchangeRate',
            car_exrate VARCHAR PATH 'bookCars/bookCar[1]/fareCar/ExchangeRate',
            insurance_exrate VARCHAR PATH 'Insurances/Insurance[1]/fareInsurance/ExchangeRate',
            
            flight_iata VARCHAR PATH 'BookInfoFlights/BookInfoFlight[1]/airCompanyIssue/iataCode'
    );

    -- Productos: Vuelos
    INSERT INTO temp_products (consecutivo, cd_codigo, parent_locator, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, prestadora_code, nights, quantity, cost)
    SELECT locSource, COALESCE(NULLIF(ticketNumber, ''), InternalLocator), InternalLocator, 'flight', 'flight', 
           NULLIF(totalTicket, '')::DOUBLE PRECISION, 
           NULLIF(TotalTax, '')::DOUBLE PRECISION, 
           0, 
           NULLIF(totalAncillary, '')::DOUBLE PRECISION, 
           iataCode, 'NUEVO', 'flight', route, iataCode, 0, 1, 
           NULLIF(totalTicket, '')::DOUBLE PRECISION
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR PATH '../../InternalLocator',
            locSource VARCHAR PATH 'locSource',
            ticketNumber VARCHAR PATH 'Paxes/Pax[1]/ticketNumber',
            totalTicket VARCHAR PATH 'fare/totalTicket',
            TotalTax VARCHAR PATH 'fare/TotalTax',
            totalAncillary VARCHAR PATH 'fare/totalAncillary',
            iataCode VARCHAR PATH 'airCompanyIssue/iataCode',
            route TEXT PATH 'route'
    );

    -- Productos: Hoteles
    INSERT INTO temp_products (consecutivo, cd_codigo, parent_locator, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, nights, quantity, cost, check_in_date, check_out_date, city)
    SELECT locSource, InternalLocator, InternalLocator, 'hotel', 'Hotel', 
           NULLIF(totalSellFare, '')::DOUBLE PRECISION, 
           NULLIF(totalTax, '')::DOUBLE PRECISION, 
           0, 
           NULLIF(feeValue, '')::DOUBLE PRECISION, 
           sourceName, status, 'Hotel', hotelName, 
           NULLIF(numberNigths, '')::INTEGER, 
           1, 
           NULLIF(totalNetfare, '')::DOUBLE PRECISION, 
           dateCheckin, dateCheckout, Hotelcity
    FROM XMLTABLE('//Books/Book/bookInfoHotels/bookInfoHotel' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR PATH '../../InternalLocator',
            locSource VARCHAR PATH 'locSource',
            status VARCHAR PATH 'status',
            sourceName VARCHAR PATH 'sourceName',
            totalSellFare VARCHAR PATH 'InfoBook/fareHotel/totalSellFare',
            totalTax VARCHAR PATH 'InfoBook/fareHotel/totalTax',
            totalNetfare VARCHAR PATH 'InfoBook/fareHotel/totalNetfare',
            feeValue VARCHAR PATH 'InfoBook/fareHotel/feeValue',
            numberNigths VARCHAR PATH 'InfoBook/numberNigths',
            dateCheckin VARCHAR PATH 'InfoBook/dateCheckin',
            dateCheckout VARCHAR PATH 'InfoBook/dateCheckout',
            Hotelcity VARCHAR PATH 'InfoBook/Hotelcity',
            hotelName TEXT PATH 'InfoBook/hotelInfo/hotelName'
    );

    -- Productos: Autos
    INSERT INTO temp_products (consecutivo, cd_codigo, parent_locator, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, nights, quantity, cost, check_in_date, check_out_date, city)
    SELECT locSource, InternalLocator, InternalLocator, 'car', 'Auto', 
           NULLIF(totalSellFare, '')::DOUBLE PRECISION, 
           NULLIF(totalTax, '')::DOUBLE PRECISION, 
           0, 
           NULLIF(feeValue, '')::DOUBLE PRECISION, 
           nameRentaCar, status, 'Auto', vehiculeType, 0, 1, 
           NULLIF(totalNetfare, '')::DOUBLE PRECISION, 
           pickUpDate, DropOffDate, iataCodePickup
    FROM XMLTABLE('//Books/Book/bookCars/bookCar' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR PATH '../../InternalLocator',
            locSource VARCHAR PATH 'locSource',
            status VARCHAR PATH 'status',
            nameRentaCar VARCHAR PATH 'nameRentaCar',
            totalSellFare VARCHAR PATH 'fareCar/totalSellFare',
            totalTax VARCHAR PATH 'fareCar/totalTax',
            totalNetfare VARCHAR PATH 'fareCar/totalNetfare',
            feeValue VARCHAR PATH 'fareCar/feeValue',
            pickUpDate VARCHAR PATH 'pickUpDate',
            DropOffDate VARCHAR PATH 'DropOffDate',
            iataCodePickup VARCHAR PATH 'pickupLocation/iataCodePickup',
            vehiculeType TEXT PATH 'fareCar/vehiculeType'
    );

    -- Productos: Seguros
    INSERT INTO temp_products (consecutivo, cd_codigo, parent_locator, op_type, ds_tipoitem, amount, tax, vat, fee, provider, status, product_type, product_description, nights, quantity, cost, check_in_date, check_out_date)
    SELECT locSource, InternalLocator, InternalLocator, 'insurance', 'Seguro', 
           NULLIF(totaSellFare, '')::DOUBLE PRECISION, 
           0, 0, 0, sourceName, status, 'Seguro', 'Seguro de Viaje', 0, 1, 
           NULLIF(totaNetFare, '')::DOUBLE PRECISION, 
           dateStarService, dateFinalService
    FROM XMLTABLE('//Books/Book/Insurances/Insurance' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR PATH '../../InternalLocator',
            locSource VARCHAR PATH 'locSource',
            status VARCHAR PATH 'status',
            sourceName VARCHAR PATH 'sourceName',
            totaSellFare VARCHAR PATH 'fareInsurance/totaSellFare',
            totaNetFare VARCHAR PATH 'fareInsurance/totaNetFare',
            dateStarService VARCHAR PATH 'dateStarService',
            dateFinalService VARCHAR PATH 'dateFinalService'
    );

    -- Itinerario (Vuelos)
    INSERT INTO temp_itinerary (product_consecutivo, orden, origin, destination, class, check_in_date, check_out_date, terminal, prestadora, farebasis, num_flight, type_flight)
    SELECT locSource, NULLIF(segmentNumber, '')::INTEGER, DepartureIata, ArrivalIata, Class, DepartureDate, ArrivalDate, terminalDeparture, airlineOperator, fareBase, Record, 'D'
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight/segments/segment' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH '../../locSource',
            segmentNumber VARCHAR PATH 'segmentNumber',
            DepartureIata VARCHAR PATH 'DepartureIata',
            ArrivalIata VARCHAR PATH 'ArrivalIata',
            Class VARCHAR PATH 'Class',
            DepartureDate VARCHAR PATH 'DepartureDate',
            ArrivalDate VARCHAR PATH 'ArrivalDate',
            terminalDeparture VARCHAR PATH 'terminalDeparture',
            airlineOperator VARCHAR PATH 'airlineOperator',
            fareBase VARCHAR PATH 'fareBase',
            Record VARCHAR PATH 'Record'
    );

    -- Pasajeros (Vuelos)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, identification, email, pax_type, consecutivo)
    SELECT locSource, name, lastName, identification, email, paxtype, identification
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight/Paxes/Pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH '../../locSource',
            name VARCHAR PATH 'name',
            lastName VARCHAR PATH 'lastName',
            identification VARCHAR PATH 'identification',
            email VARCHAR PATH 'email',
            paxtype VARCHAR PATH 'paxtype'
    );

    -- Pasajeros (Hoteles)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, identification, email, pax_type, consecutivo)
    SELECT locSource, name, lastName, identification, mailPax, typePax, identification
    FROM XMLTABLE('//Books/Book/bookInfoHotels/bookInfoHotel/InfoBook/rooms/room/paxes/pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH '../../../../locSource',
            name VARCHAR PATH 'name',
            lastName VARCHAR PATH 'lastName',
            identification VARCHAR PATH 'identification',
            mailPax VARCHAR PATH 'mailPax',
            typePax VARCHAR PATH 'typePax'
    );

    -- Pasajeros (Autos)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, email, consecutivo)
    SELECT locSource, name, lastName, mailPax, name || lastName
    FROM XMLTABLE('//Books/Book/bookCars/bookCar/pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH '../locSource',
            name VARCHAR PATH 'name',
            lastName VARCHAR PATH 'lastName',
            mailPax VARCHAR PATH 'mailPax'
    );

    -- Pasajeros (Seguros)
    INSERT INTO temp_passengers (product_consecutivo, first_name, last_name, identification, email, pax_type, consecutivo)
    SELECT locSource, name, lastName, identification, mailPax, typePax, identification
    FROM XMLTABLE('//Books/Book/Insurances/Insurance/fareInsurance/Paxes/Pax' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH '../../../locSource',
            name VARCHAR PATH 'name',
            lastName VARCHAR PATH 'lastName',
            identification VARCHAR PATH 'identification',
            mailPax VARCHAR PATH 'mailPax',
            typePax VARCHAR PATH 'typePax'
    );

    -- Variables (UDIDS)
    INSERT INTO temp_variables (product_consecutivo, var_name, var_value)
    SELECT InternalLocator, name, value
    FROM XMLTABLE('//Books/Book/CorporateInfo/UDIDS/udid' PASSING v_xml
        COLUMNS 
            InternalLocator VARCHAR PATH '../../../../InternalLocator',
            name TEXT PATH 'name',
            value TEXT PATH 'value'
    );

    -- Cargo Tarifa (TAR) de Vuelos (extraído de fare/localfare) con equivalencia
    INSERT INTO temp_taxes (product_consecutivo, tax_code, tax_name, tax_amount, tax_type, is_main)
    SELECT locSource, 
           public."fnEquivalenceInterface"(v_interface_id, 10, 'TAR'), 
           'Tarifa', 
           SUM(NULLIF(localfare, '')::DOUBLE PRECISION), 
           'TAR', 
           true
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH 'locSource',
            paxes_xml XML PATH 'Paxes'
    ) f,
    XMLTABLE('//Paxes/Pax' PASSING f.paxes_xml
        COLUMNS
            localfare VARCHAR PATH 'fare/localfare'
    ) p
    WHERE localfare IS NOT NULL AND localfare != ''
    GROUP BY locSource;

    -- Impuestos (Taxes) de Vuelos con equivalencia
    INSERT INTO temp_taxes (product_consecutivo, tax_code, tax_name, tax_amount, tax_type, is_main)
    SELECT locSource, 
           public."fnEquivalenceInterface"(v_interface_id, 10, codeTax), 
           'Impuesto ' || public."fnEquivalenceInterface"(v_interface_id, 10, codeTax), 
           SUM(NULLIF(valtax, '')::DOUBLE PRECISION), 
           'TAX', 
           false
    FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight' PASSING v_xml
        COLUMNS 
            locSource VARCHAR PATH 'locSource',
            taxes_xml XML PATH 'Paxes/Pax/fare/taxes'
    ) f,
    XMLTABLE('//taxes/tax' PASSING f.taxes_xml
        COLUMNS
            codeTax VARCHAR PATH 'codeTax',
            valtax VARCHAR PATH 'valtax'
    ) t
    WHERE valtax IS NOT NULL AND valtax != ''
    GROUP BY locSource, codeTax;

    -- Cargo Otros (OTR) de Vuelos (TotalTax - suma de los demás impuestos) con equivalencia
    INSERT INTO temp_taxes (product_consecutivo, tax_code, tax_name, tax_amount, tax_type, is_main)
    SELECT 
        f.locSource,
        public."fnEquivalenceInterface"(v_interface_id, 10, 'OTR'),
        'Otros',
        COALESCE(f.TotalTax, 0) - COALESCE(t.sum_detailed_taxes, 0),
        'OTR',
        false
    FROM (
        SELECT locSource, SUM(NULLIF(TotalTax, '')::DOUBLE PRECISION) AS TotalTax
        FROM XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight' PASSING v_xml
            COLUMNS 
                locSource VARCHAR PATH 'locSource',
                paxes_xml XML PATH 'Paxes'
        ) f_inner,
        XMLTABLE('//Paxes/Pax' PASSING f_inner.paxes_xml
            COLUMNS
                TotalTax VARCHAR PATH 'fare/TotalTax'
        ) p_inner
        GROUP BY locSource
    ) f
    LEFT JOIN (
        SELECT product_consecutivo, SUM(tax_amount) AS sum_detailed_taxes
        FROM temp_taxes
        WHERE tax_type = 'TAX'
        GROUP BY product_consecutivo
    ) t ON t.product_consecutivo = f.locSource
    WHERE (COALESCE(f.TotalTax, 0) - COALESCE(t.sum_detailed_taxes, 0)) > 0;

    -- Eliminar reserva existente y sus dependencias si ya existe para evitar duplicación
    DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head)));
    DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head)));
    DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head)));
    DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head)));
    DELETE FROM public."BookingProductVariableGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head)));
    DELETE FROM public."BookingProductFEEGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head)));
    DELETE FROM public."BookingsGDSInvoiceAuto" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head));
    DELETE FROM public."BookingGDSInvoiceAutoLog" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head));
    DELETE FROM public."BookingProductGDS" WHERE "bookingId" IN (SELECT id FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head));
    DELETE FROM public."BookingGDS" WHERE code IN (SELECT cd_codigo FROM temp_head);

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
                p_currency := r_head.currency,
                p_exchangeRate := r_head.exchange_rate,
                p_booking := r_head.booking,
                p_iata := r_head.iata,
                p_description := r_head.description,
                p_observation := r_head.observation,
                p_id_out := v_bookingId
            );
        EXCEPTION WHEN OTHERS THEN
            RAISE;
        END;

        -- Paso 2: Procesar Productos
        FOR r_product IN (SELECT * FROM temp_products WHERE parent_locator = r_head.cd_codigo) LOOP
            DECLARE
                v_temp_product_id INTEGER;
            BEGIN
                CALL public."spBookingGDS"(
                    p_Op := r_product.op_type,
                    p_bookingId := v_bookingId,
                    p_code := r_product.cd_codigo,
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
                    p_id_out := v_temp_product_id
                );
                v_bookingProductId := v_temp_product_id;
            EXCEPTION WHEN OTHERS THEN
                RAISE;
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
                    p_type := r_passenger.pax_type,
                    p_id_out := v_dummy_out
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
                    p_Typeflight := r_itinerary.type_flight,
                    p_id_out := v_dummy_out
                );
            END LOOP;

            -- Variables (ligadas a la cabecera en este caso)
            FOR r_var IN (SELECT * FROM temp_variables WHERE product_consecutivo = r_head.cd_codigo) LOOP
                CALL public."spBookingGDS"(
                    p_Op := 'var',
                    p_bookingId := v_bookingId,
                    p_bookingProductId := v_bookingProductId,
                    p_varName := r_var.var_name,
                    p_varValue := r_var.var_value,
                    p_id_out := v_dummy_out
                );
            END LOOP;

            -- Impuestos (Taxes)
            FOR r_tax IN (SELECT * FROM temp_taxes WHERE product_consecutivo = r_product.consecutivo) LOOP
                CALL public."spBookingGDS"(
                    p_Op := 'tax',
                    p_bookingId := v_bookingId,
                    p_bookingProductId := v_bookingProductId,
                    p_taxCode := r_tax.tax_code,
                    p_taxName := r_tax.tax_name,
                    p_taxType := r_tax.tax_type,
                    p_taxismain := r_tax.is_main,
                    p_tax := r_tax.tax_amount,
                    p_id_out := v_dummy_out
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
