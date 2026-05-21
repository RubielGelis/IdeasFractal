CREATE OR REPLACE PROCEDURE public."spInterfaceReadXMLBookingIdeasFractal"(
    p_Op VARCHAR(50) DEFAULT NULL,
    p_XML text DEFAULT NULL,
    INOUT p_XMLOutput text DEFAULT NULL,
    p_BlSelect boolean DEFAULT false
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    v_xml_data XML;
BEGIN
    -- Intentar parsear el XML de entrada
    BEGIN
        v_xml_data := p_XML::xml;
    EXCEPTION WHEN OTHERS THEN
        p_XMLOutput := NULL;
        RETURN;
    END;

    -- En esta migración, transformamos el XML de entrada (JSON convertido) 
    -- al formato que spBookingGDSXML espera (basado en booksReserva.xml).
    
    -- Usamos XMLELEMENT y XMLAGG para construir la estructura jerárquica
    
    WITH head_data AS (
        SELECT * FROM XMLTABLE('//Books/Book' PASSING v_xml_data
            COLUMNS 
                InternalLocator VARCHAR PATH 'InternalLocator',
                dateLocator VARCHAR PATH 'dateLocator',
                AgencyCodeClient VARCHAR PATH 'EntityBook/AgencyCodeClient',
                AgencyCountry VARCHAR PATH 'EntityBook/AgencyCountry',
                codeEntity VARCHAR PATH 'EntityBook/codeEntity',
                loginBook VARCHAR PATH 'UserBook/loginBook',
                transactionCode VARCHAR PATH 'transactionCode'
        )
    ),
    flights AS (
        SELECT f.*, h.InternalLocator as parent_locator
        FROM head_data h,
        XMLTABLE('//Books/Book/BookInfoFlights/BookInfoFlight' PASSING v_xml_data
            COLUMNS 
                locSource VARCHAR PATH 'locSource',
                totalTicket DOUBLE PRECISION PATH 'fare/totalTicket',
                TotalTax DOUBLE PRECISION PATH 'fare/TotalTax',
                totalAncillary DOUBLE PRECISION PATH 'fare/totalAncillary',
                iataCode VARCHAR PATH 'airCompanyIssue/iataCode',
                route TEXT PATH 'route',
                segments_xml XML PATH 'segments',
                paxes_xml XML PATH 'Paxes'
        ) f
    ),
    hotels AS (
        SELECT hot.*, h.InternalLocator as parent_locator
        FROM head_data h,
        XMLTABLE('//Books/Book/bookInfoHotels/bookInfoHotel' PASSING v_xml_data
            COLUMNS 
                locSource VARCHAR PATH 'locSource',
                status VARCHAR PATH 'status',
                sourceName VARCHAR PATH 'sourceName',
                totalSellFare DOUBLE PRECISION PATH 'InfoBook/fareHotel/totalSellFare',
                totalTax DOUBLE PRECISION PATH 'InfoBook/fareHotel/totalTax',
                totalNetfare DOUBLE PRECISION PATH 'InfoBook/fareHotel/totalNetfare',
                feeValue DOUBLE PRECISION PATH 'InfoBook/fareHotel/feeValue',
                numberNigths INTEGER PATH 'InfoBook/numberNigths',
                dateCheckin VARCHAR PATH 'InfoBook/dateCheckin',
                dateCheckout VARCHAR PATH 'InfoBook/dateCheckout',
                Hotelcity VARCHAR PATH 'InfoBook/Hotelcity',
                hotelName TEXT PATH 'InfoBook/hotelInfo/hotelName',
                paxes_xml XML PATH 'InfoBook/rooms/room/paxes'
        ) hot
    )
    SELECT 
        XMLELEMENT(NAME "Books",
            XMLAGG(
                XMLELEMENT(NAME "Book",
                    XMLELEMENT(NAME "InternalLocator", h.InternalLocator),
                    XMLELEMENT(NAME "dateLocator", h.dateLocator),
                    XMLELEMENT(NAME "EntityBook",
                        XMLELEMENT(NAME "AgencyCodeClient", h.AgencyCodeClient),
                        XMLELEMENT(NAME "AgencyCountry", h.AgencyCountry),
                        XMLELEMENT(NAME "codeEntity", h.codeEntity)
                    ),
                    XMLELEMENT(NAME "UserBook",
                        XMLELEMENT(NAME "loginBook", h.loginBook)
                    ),
                    -- Vuelos
                    XMLELEMENT(NAME "BookInfoFlights",
                        (SELECT XMLAGG(
                            XMLELEMENT(NAME "BookInfoFlight",
                                XMLELEMENT(NAME "locSource", f.locSource),
                                XMLELEMENT(NAME "fare",
                                    XMLELEMENT(NAME "totalTicket", f.totalTicket),
                                    XMLELEMENT(NAME "TotalTax", f.TotalTax),
                                    XMLELEMENT(NAME "totalAncillary", f.totalAncillary)
                                ),
                                XMLELEMENT(NAME "airCompanyIssue",
                                    XMLELEMENT(NAME "iataCode", f.iataCode)
                                ),
                                XMLELEMENT(NAME "route", f.route),
                                f.segments_xml,
                                f.paxes_xml
                            )
                        ) FROM flights f WHERE f.parent_locator = h.InternalLocator)
                    ),
                    -- Hoteles
                    XMLELEMENT(NAME "bookInfoHotels",
                        (SELECT XMLAGG(
                            XMLELEMENT(NAME "bookInfoHotel",
                                XMLELEMENT(NAME "locSource", hot.locSource),
                                XMLELEMENT(NAME "status", hot.status),
                                XMLELEMENT(NAME "sourceName", hot.sourceName),
                                XMLELEMENT(NAME "InfoBook",
                                    XMLELEMENT(NAME "numberNigths", hot.numberNigths),
                                    XMLELEMENT(NAME "dateCheckin", hot.dateCheckin),
                                    XMLELEMENT(NAME "dateCheckout", hot.dateCheckout),
                                    XMLELEMENT(NAME "Hotelcity", hot.Hotelcity),
                                    XMLELEMENT(NAME "hotelInfo",
                                        XMLELEMENT(NAME "hotelName", hot.hotelName)
                                    ),
                                    XMLELEMENT(NAME "fareHotel",
                                        XMLELEMENT(NAME "totalSellFare", hot.totalSellFare),
                                        XMLELEMENT(NAME "totalTax", hot.totalTax),
                                        XMLELEMENT(NAME "totalNetfare", hot.totalNetfare),
                                        XMLELEMENT(NAME "feeValue", hot.feeValue)
                                    ),
                                    XMLELEMENT(NAME "rooms",
                                        XMLELEMENT(NAME "room",
                                            hot.paxes_xml
                                        )
                                    )
                                )
                            )
                        ) FROM hotels hot WHERE hot.parent_locator = h.InternalLocator)
                    )
                    -- (Nota: Se pueden agregar Autos y Seguros siguiendo el mismo patrón)
                )
            )
        )::text INTO p_XMLOutput
    FROM head_data h;

    -- Si se solicita el select directo
    IF p_BlSelect THEN
        -- PostgreSQL procedures don't easily return result sets like this unless using refcursors
        -- Pero podemos hacer un RAISE NOTICE o simplemente confiar en el INOUT
        NULL;
    END IF;

END;
$BODY$;

ALTER PROCEDURE public."spInterfaceReadXMLBookingIdeasFractal"(varchar, text, inout text, boolean) OWNER TO postgres;
