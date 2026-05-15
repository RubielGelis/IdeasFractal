CREATE OR REPLACE PROCEDURE public."spza_InterfaceXmlResponse_IdeasFractral"(
    p_Op VARCHAR(50) DEFAULT NULL,
    p_XML text DEFAULT NULL,
    p_Codigo VARCHAR(25) DEFAULT NULL,
    p_MensajeError text DEFAULT NULL,
    INOUT p_Respuesta text DEFAULT NULL
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Este procedimiento genera la respuesta XML para la interfaz de IdeasFractal
    -- Si p_MensajeError está vacío, se asume éxito.
    
    p_Respuesta := (
        SELECT XMLELEMENT(NAME "Response",
            XMLELEMENT(NAME "Code", COALESCE(p_Codigo, '')),
            XMLELEMENT(NAME "Status", CASE WHEN p_MensajeError IS NULL OR p_MensajeError = '' THEN 'Success' ELSE 'Error' END),
            XMLELEMENT(NAME "Message", COALESCE(p_MensajeError, 'Proceso completado exitosamente')),
            XMLELEMENT(NAME "Timestamp", now()::text)
        )::text
    );
END;
$BODY$;

ALTER PROCEDURE public."spza_InterfaceXmlResponse_IdeasFractral"(varchar, text, varchar, text, inout text) OWNER TO postgres;
