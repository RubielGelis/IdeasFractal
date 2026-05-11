import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir asignaciones SET p_var = ... a p_var := ...
    content = re.sub(r"SET\s+([\w\"]+)\s*=\s*", r"\1 := ", content, flags=re.IGNORECASE)
    
    # 2. Corregir IFs (T-SQL style) a PL/pgSQL style
    # If(p_Op='...') -> IF p_Op = '...' THEN
    content = re.sub(r"If\s*\((p_Op\s*=\s*'[^']+')\)", r"IF \1 THEN", content, flags=re.IGNORECASE)
    
    # 3. Corregir Begin/End de los bloques IF
    # No podemos hacer un simple regex para End -> END IF porque hay Begins anidados.
    # Pero los bloques de Op suelen ser: IF ... THEN Begin ... End
    # Vamos a limpiar el bloque DetSrv específicamente y el desastre de las líneas 1045-1051.
    
    # Limpiar el bloque DetSrv y lo que esté arriba que esté mal
    # Buscamos el final de DetHotel y el inicio de DetSrv
    # El usuario mostró: 
    # 1045: RETURN; 1046: END; 1047: End IF; 1048: 1049: RETURN; 1050: END; 1051: End
    
    pattern_mess = r"RETURN;\s*END;\s*End\s+IF;.*?IF\s+p_Op\s*=\s*'DetSrv'\s+THEN"
    def fix_mess(match):
        return "RETURN;\n\t\tEND;\n\tEND IF;\n\n\tIF p_Op = 'DetSrv' THEN"
    
    content = re.sub(pattern_mess, fix_mess, content, flags=re.IGNORECASE | re.DOTALL)

    # 4. Asegurarnos que todos los IF p_Op terminen en END IF;
    # Como los bloques están bien delimitados por el siguiente IF p_Op, podemos intentar cerrarlos.
    ops = ['Cab', 'DetPas', 'DetItinerario', 'DetCar', 'DetHotel', 'DetSrv', 'Poliza', 'PaxAdicional', 'VarAdicional', 'CargosImpuestos', 'FormasPagos', 'FEE']
    
    for i in range(len(ops)-1):
        # Buscar desde IF p_Op = 'ops[i]' hasta IF p_Op = 'ops[i+1]'
        pattern = r"(IF\s+p_Op\s*=\s*'" + ops[i] + r"'\s+THEN.*?)(?=IF\s+p_Op\s*=\s*'" + ops[i+1] + r"')"
        def close_if(match):
            block = match.group(1).strip()
            if not block.endswith("END IF;"):
                # Si termina en End, cambiarlo por END IF;
                if block.endswith("End"):
                    block = block[:-3] + "END IF;"
                elif block.endswith("END;"):
                    block = block + "\n\tEND IF;"
            return block + "\n\n\t"
        content = re.sub(pattern, close_if, content, flags=re.IGNORECASE | re.DOTALL)

    # El último bloque (FEE)
    pattern_fee = r"(IF\s+p_Op\s*=\s*'FEE'\s+THEN.*?)END;?\s*\$\$\s*LANGUAGE"
    def close_fee(match):
        block = match.group(1).strip()
        if not block.endswith("END IF;"):
             block = block + "\n\tEND IF;"
        return block + "\nEND;\n$$ LANGUAGE"
    content = re.sub(pattern_fee, close_fee, content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Sintaxis PL/pgSQL corregida y bloque DetSrv arreglado.")
except Exception as e:
    print(f"Error: {e}")
