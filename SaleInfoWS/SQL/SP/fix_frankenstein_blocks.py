import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Reparar "END IF COALESCE" -> "END IF; IF COALESCE(...) THEN"
    content = re.sub(r"END\s+IF\s+(COALESCE\(.*?\)<>''|COALESCE\(.*?\)<>0)", r"END IF;\n\tIF \1 THEN", content, flags=re.IGNORECASE)

    # 2. Reparar "END IF IF" -> "END IF; IF" (si quedó pegado)
    content = re.sub(r"END\s+IF\s+IF", r"END IF;\n\tIF", content, flags=re.IGNORECASE)

    # 3. Reparar el doble "THEN" o "THEN THEN"
    content = re.sub(r"THEN\s*\n\s*THEN", r"THEN", content, flags=re.IGNORECASE)
    content = re.sub(r"THEN\s+THEN", r"THEN", content, flags=re.IGNORECASE)

    # 4. Corregir BEGIN que quedaron sin IF ... THEN previo (debido a limpieza de T-SQL)
    # Por ejemplo: IF cond THEN BEGIN ... END; END IF;
    # (Ya debería estar bien, pero revisamos casos como el del snapshot)
    
    # 5. Específico para el bloque de tarjeta de crédito visto en el snapshot:
    content = content.replace("END IF COALESCE(p_cd_NumeroTarjeta,'')<>''", "END IF;\n\tIF COALESCE(p_cd_NumeroTarjeta,'')<>'' THEN")
    content = content.replace("END IF COALESCE(p_cd_VencimientoTarjeta,'')<>''", "END IF;\n\tIF COALESCE(p_cd_VencimientoTarjeta,'')<>'' THEN")
    content = content.replace("END IF COALESCE(p_in_CuotasTarjeta,0)<>0", "END IF;\n\tIF COALESCE(p_in_CuotasTarjeta,0)<>0 THEN")

    # 6. Eliminar el "THEN" huérfano en la línea 424 (aproximadamente)
    # IF EXISTS (...) THEN THEN 
    content = re.sub(r"(IF\s+EXISTS\s*\(.*?\)\s*THEN)\s*\n\s*THEN", r"\1", content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Bloques Frankenstein reparados.")
except Exception as e:
    print(f"Error: {e}")
