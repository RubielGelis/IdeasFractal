import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Cambiar RETURNS void a RETURNS INTEGER
    content = content.replace(") RETURNS void AS $$", ") RETURNS INTEGER AS $$")

    # 2. Corregir el error de sintaxis en el inicio de los bloques IF (si existe)
    # Por ejemplo: END IF IF p_Op = 'DetCar' THEN
    content = re.sub(r"END\s+IF\s+IF", "END IF;\n\tIF", content, flags=re.IGNORECASE)
    # También el que vimos en el snapshot: 922: END IF p_Op = 'DetCar' THEN
    content = re.sub(r"END\s+IF\s+(p_Op\s*=\s*'DetCar')", r"END IF;\n\tIF \1", content, flags=re.IGNORECASE)

    # 3. Agregar RETURNS en cada bloque principal
    
    # Bloque Cab: retornar p_Id_BookingsGDS
    # Buscamos el final del bloque Cab (antes del inicio de DetPas o fin de Cab)
    # En Cab, al final hay un Return 0; o similar.
    content = content.replace("Return 0; -- fin de Cab", "RETURN p_Id_BookingsGDS;")
    # Si no tiene ese marcador, lo buscamos por el END IF de Cab
    content = re.sub(r"(IF\s+p_Op\s*=\s*'Cab'.*?)(END IF;)", r"\1\tRETURN p_Id_BookingsGDS;\n\t\2", content, flags=re.IGNORECASE | re.DOTALL)

    # Bloques DetPas, DetCar, DetHotel, DetSrv: retornar v_BookingProductId
    # Estos bloques terminan en END; END IF;
    content = re.sub(r"(IF\s+p_Op\s*=\s*'(DetPas|DetCar|DetHotel|DetSrv)'.*?RETURNING\s+id\s+INTO\s+v_BookingProductId;.*?)(END;?\s*END IF;)", 
                     r"\1\tRETURN v_BookingProductId;\n\t\3", content, flags=re.IGNORECASE | re.DOTALL)

    # Otros bloques: Poliza, PaxAdicional, etc. pueden retornar NULL o 0
    # Pero generalmente se prefiere retornar algo útil.
    # Por ahora, aseguramos que la función siempre termine con un RETURN NULL si nada coincide.
    if not content.strip().endswith("RETURN NULL;\nEND;\n$$ LANGUAGE plpgsql;"):
        content = re.sub(r"END;\s*\$\$\s*LANGUAGE plpgsql;", "RETURN NULL;\nEND;\n$$ LANGUAGE plpgsql;", content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("spBookingGDS actualizado para retornar IDs.")
except Exception as e:
    print(f"Error: {e}")
