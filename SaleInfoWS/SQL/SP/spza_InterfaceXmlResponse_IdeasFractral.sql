CREATE OR REPLACE PROCEDURE public."spza_InterfaceXmlResponse_IdeasFractral"(
    p_Op VARCHAR(50) DEFAULT NULL,
    p_XML text DEFAULT NULL,
    p_Codigo VARCHAR(25) DEFAULT NULL,
    p_MensajeError text DEFAULT NULL,
    INOUT p_Respuesta text DEFAULT NULL
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    v_LocsXml xml;
    v_Status VARCHAR(10);
    v_Message text;
BEGIN
    -- Determinar el estado y el mensaje principal
    IF p_MensajeError IS NULL OR p_MensajeError = '' THEN
        v_Status := 'OK';
        v_Message := 'Mensaje de exito';
        
        -- Obtener los productos asociados a la booking
        WITH numbered_products AS (
            SELECT 
                p.id,
                p.type,
                COALESCE(p."reservationCode", p_Codigo) AS reservation_code,
                ROW_NUMBER() OVER (ORDER BY p.id) as rn
            FROM public."BookingProductGDS" p
            INNER JOIN public."BookingGDS" b ON b.id = p."bookingId"
            WHERE b.code = p_Codigo
        )
        SELECT xmlagg(
            XMLELEMENT(NAME "loc",
                CASE WHEN rn = 1 THEN
                    XMLFOREST(
                        CASE 
                            WHEN LOWER(type) LIKE '%flight%' OR LOWER(type) LIKE '%flight%' THEN 'Flight'
                            WHEN LOWER(type) LIKE '%hotel%' OR LOWER(type) LIKE '%hotel%' THEN 'Hotel'
                            WHEN LOWER(type) LIKE '%car%' OR LOWER(type) LIKE '%car%' OR LOWER(type) LIKE '%renta%' THEN 'Car'
                            WHEN LOWER(type) LIKE '%insurance%' OR LOWER(type) LIKE '%insurance%' THEN 'Insurance'
                            ELSE type
                        END AS "productType",
                        reservation_code AS "locProvider",
                        'OK' AS "statusIntegracion",
                        'Todo ok' AS "messageIntegration"
                    )
                ELSE
                    XMLFOREST(
                        CASE 
                            WHEN LOWER(type) LIKE '%flight%' OR LOWER(type) LIKE '%flight%' THEN 'Flight'
                            WHEN LOWER(type) LIKE '%hotel%' OR LOWER(type) LIKE '%hotel%' THEN 'Hotel'
                            WHEN LOWER(type) LIKE '%car%' OR LOWER(type) LIKE '%car%' OR LOWER(type) LIKE '%car%' THEN 'Car'
                            WHEN LOWER(type) LIKE '%insurance%' OR LOWER(type) LIKE '%insurance%' THEN 'Insurance'
                            ELSE type
                        END AS "productTypeField",
                        reservation_code AS "locProviderField",
                        'OK' AS "statusIntegracionField",
                        'Todo ok' AS "messageIntegrationField"
                    )
                END
            )
        ) INTO v_LocsXml
        FROM numbered_products;
    ELSE
        v_Status := 'Error';
        v_Message := p_MensajeError;
        v_LocsXml := NULL;
    END IF;

    -- Generar el XML final
    p_Respuesta := (
        SELECT XMLELEMENT(NAME "SaleInfoRS",
            XMLELEMENT(NAME "locField", COALESCE(p_Codigo, '')),
            XMLELEMENT(NAME "codeIntegrationBackofficeField", COALESCE(p_Codigo, '')),
            XMLELEMENT(NAME "statusIntegracionField", v_Status),
            XMLELEMENT(NAME "messageIntegrationField", v_Message),
            XMLELEMENT(NAME "locsField", COALESCE(v_LocsXml, ''::xml))
        )::text
    );

    -- Si el estado es OK, inyectamos la marca de éxito para que el C# la reconozca
    IF v_Status = 'OK' THEN
        p_Respuesta := '<!-- <Status>Success</Status> -->' || p_Respuesta;
    END IF;
END;
$BODY$;

ALTER PROCEDURE public."spza_InterfaceXmlResponse_IdeasFractral"(varchar, text, varchar, text, inout text) OWNER TO postgres;
