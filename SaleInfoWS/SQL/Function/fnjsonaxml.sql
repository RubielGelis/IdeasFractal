CREATE OR REPLACE FUNCTION fnjsonaxml(p_json text, p_level int DEFAULT 0)
RETURNS xml
LANGUAGE plpgsql
AS $function$
DECLARE
    v_json jsonb;
    k text;
    v jsonb;
    keyAux text;
    res text := '';
    elem text;
    i int;
    tab text := E'\t';
    crlf text := E'\r\n';
BEGIN
    -- Intentar parsear a JSON y validar que sea un objeto en la raíz
    IF p_level = 0 THEN
        BEGIN
            v_json := p_json::jsonb;
            IF jsonb_typeof(v_json) != 'object' THEN
                RETURN ''::xml;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RETURN ''::xml;
        END;
    ELSE
        v_json := p_json::jsonb;
    END IF;

    -- Iterar sobre el objeto json
    FOR k, v IN SELECT * FROM jsonb_each(v_json) LOOP
        -- Nueva linea y tabulaciones iniciales para la key
        res := res || crlf || repeat(tab, p_level);
        
        IF jsonb_typeof(v) = 'array' THEN
            -- Lógica original de T-SQL para encontrar el singular
            IF RIGHT(k, 2) = 'es' AND RIGHT(k, 3) <> 'ces' THEN
                keyAux := LEFT(k, LENGTH(k) - 2);
            ELSIF RIGHT(k, 1) = 's' THEN
                keyAux := LEFT(k, LENGTH(k) - 1);
            ELSE
                keyAux := NULL;
            END IF;
            
            elem := '';
            IF jsonb_array_length(v) > 0 THEN
                FOR i IN 0 .. jsonb_array_length(v) - 1 LOOP
                    IF keyAux IS NOT NULL THEN
                        -- Array con nombre en plural (ej. locs -> loc)
                        elem := elem || crlf || repeat(tab, p_level + 1) || '<' || keyAux || '>';
                        
                        IF jsonb_typeof(v->i) = 'object' THEN
                            elem := elem || (fnjsonaxml((v->i)::text, p_level + 2))::text || crlf || repeat(tab, p_level + 1);
                        ELSE
                            elem := elem || (v->>i);
                        END IF;
                        
                        elem := elem || '</' || keyAux || '>';
                    ELSE
                        -- Array sin singular (se concatena dentro del mismo padre)
                        IF jsonb_typeof(v->i) = 'object' THEN
                            elem := elem || (fnjsonaxml((v->i)::text, p_level + 1))::text;
                        ELSE
                            elem := elem || (v->>i);
                        END IF;
                    END IF;
                END LOOP;
            END IF;
            
            IF keyAux IS NOT NULL THEN
                res := res || '<' || k || '>' || elem || crlf || repeat(tab, p_level) || '</' || k || '>';
            ELSE
                res := res || '<' || k || '>' || elem || '</' || k || '>';
            END IF;

        ELSIF jsonb_typeof(v) = 'object' THEN
            res := res || '<' || k || '>' || (fnjsonaxml(v::text, p_level + 1))::text || crlf || repeat(tab, p_level) || '</' || k || '>';
        
        ELSE
            IF jsonb_typeof(v) = 'null' THEN
                res := res || '<' || k || '></' || k || '>';
            ELSE
                res := res || '<' || k || '>' || (v#>>'{}') || '</' || k || '>';
            END IF;
        END IF;
    END LOOP;

    RETURN res::xml;
END;
$function$;
