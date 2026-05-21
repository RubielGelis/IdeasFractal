CREATE OR REPLACE PROCEDURE public."spInterfaceIdeasFractal"(
    p_Op VARCHAR(50) DEFAULT NULL,
    p_Codigo VARCHAR(25) DEFAULT NULL,
    p_XML text DEFAULT NULL,
    p_PET text DEFAULT NULL,
    INOUT p_Respuesta text DEFAULT NULL
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    v_id_Interfaces INTEGER;
    v_cd_interfaces VARCHAR(50);
    v_oper VARCHAR(25);
    v_Error INTEGER := 0;
    v_NombreServicio text;
    v_Respuesta text := '';
    v_Resultado text := '';
    v_ResultadoError text := '';
    v_XMLI text := '';
    v_XMLR text := '';
    v_CodigoBooking VARCHAR(12);
    v_msg text;
    v_archivo VARCHAR(250);
    v_ResultadoJSON JSON;
    v_err_context text;
BEGIN
    v_cd_interfaces := 'IdeasFractal';
    SELECT id INTO v_id_Interfaces FROM public."Interfaces" WHERE code = v_cd_interfaces;

    IF p_Op = 'Booking' THEN
        v_oper := 'Insertar';
        v_NombreServicio := 'Creacion de Booking';

        -- Convertir JSON a XML si es necesario (asumiendo que viene en formato JSON si empieza con {)
        IF p_XML LIKE '{%' THEN
			BEGIN
                v_XMLI := public."fnjsonaxml"(p_XML);
            EXCEPTION WHEN OTHERS THEN
                v_XMLI := p_XML;
            END;
		ELSE
            v_XMLI := p_XML;
        END IF;
		--RAISE NOTICE 'XML: %', v_XMLI;
        -- 1. Llamar a spInterfaceReadXMLBookingIdeasFractal para transformar el XML al formato interno
		BEGIN
            CALL public."spInterfaceReadXMLBookingIdeasFractal"(p_Op, v_XMLI, v_XMLR);
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_err_context = PG_EXCEPTION_CONTEXT;
            v_ResultadoError := 'Error al transformar el XML: ' || SQLERRM || ' [Contexto: ' || v_err_context || ']';
            v_Error := 1;
        END;
		--RAISE NOTICE 'XML: %', v_XMLR;
        -- 2. Validar que la transformación generó contenido
        IF v_Error = 0 AND (v_XMLR IS NULL OR v_XMLR = '') THEN
            v_ResultadoError := 'Error: La transformación del XML devolvió un resultado vacío.';
            v_Error := 1;
        END IF;

        -- 3. Procesar el XML resultante con el motor de Booking GDS
        IF v_Error = 0 THEN
			BEGIN
                BEGIN
                    v_CodigoBooking := (xpath('//InternalLocator/text()', v_XMLR::xml))[1]::text;
                EXCEPTION WHEN OTHERS THEN
                    v_CodigoBooking := 'UNK';
                END;
                
                v_archivo := v_CodigoBooking;
                v_msg := 'Booking xml procesado exitosamente';

                INSERT INTO public."BookingsGDS_log" (message, file, codebooking, booking, error)
                VALUES (v_msg, v_archivo, v_CodigoBooking, v_XMLI, 0);

                -- Llamada al procedimiento central de procesamiento
				
                CALL public."spBookingGDSXML"(v_XMLR, v_ResultadoJSON);
                v_Resultado := v_ResultadoJSON::text;
				
            EXCEPTION WHEN OTHERS THEN
                GET STACKED DIAGNOSTICS v_err_context = PG_EXCEPTION_CONTEXT;
                v_ResultadoError := 'Error en spBookingGDSXML: ' || SQLERRM || ' [Contexto: ' || v_err_context || ']';
                v_Error := 1;
            END;
        END IF;

        -- 4. Generar la respuesta XML final
		BEGIN
            CALL public."spza_InterfaceXmlResponse_IdeasFractral"(p_Op, v_XMLI, p_Codigo, v_ResultadoError, v_Respuesta);
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_err_context = PG_EXCEPTION_CONTEXT;
            v_Respuesta := '<Response><Status>Error</Status><Message>' || SQLERRM || ' [Contexto: ' || v_err_context || ']</Message></Response>';
        END;

        -- 5. Registrar el log de la transacción de la interfaz
        INSERT INTO public."EquivalenciasInterfaces_Log" (
            "Id_Interfaces", cd_maestro, cd_codigo, "cd_codigoInte", cd_operacion, 
            ds_xmlpeticion, ds_xmlrespuesta, ds_xmlorg, "ds_Logpeticion"
        )
        VALUES (
            v_id_Interfaces, p_Op, p_Codigo, p_Codigo, v_oper, 
            v_XMLR, COALESCE(v_Resultado, '') || v_Respuesta, v_XMLI, p_PET
        );

        p_Respuesta := v_Respuesta;
        RETURN;
    END IF;

    p_Respuesta := '';
    RETURN;
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err_context = PG_EXCEPTION_CONTEXT;
    v_ResultadoError := 'Error inesperado en spInterfaceIdeasFractal: ' || SQLERRM || ' [Contexto: ' || v_err_context || ']';
    BEGIN
        INSERT INTO public."EquivalenciasInterfaces_Log" (
            "Id_Interfaces", cd_maestro, cd_codigo, "cd_codigoInte", cd_operacion, 
            ds_xmlpeticion, ds_xmlrespuesta, ds_xmlorg, "ds_Logpeticion"
        )
        VALUES (
            v_id_Interfaces, p_Op, p_Codigo, p_Codigo, 'ERROR', 
            COALESCE(v_XMLR, ''), v_ResultadoError, COALESCE(v_XMLI, ''), p_PET
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    p_Respuesta := v_ResultadoError;
END;
$BODY$;

ALTER PROCEDURE public."spInterfaceIdeasFractal"(varchar, varchar, text, text, inout text) OWNER TO postgres;
