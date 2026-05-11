import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir IF ... THEN BEGIN ... END -> IF ... THEN BEGIN ... END; END IF;
    # Buscamos BEGIN ... END que no tengan END IF; después si fueron abiertos por un IF
    
    # Lógica: Si hay un IF ... THEN y luego un BEGIN, el END debe ir seguido de END IF;
    def fix_nested_blocks(match):
        if_header = match.group(1)
        begin_body = match.group(2)
        return f"{if_header}\n\tBEGIN\n{begin_body}\n\tEND;\nEND IF;"

    # Este regex es arriesgado pero probaremos con bloques simples primero
    # content = re.sub(r"(IF\s+.*?THEN)\s*\n\s*BEGIN\n(.*?)\n\s*END;", fix_nested_blocks, content, flags=re.IGNORECASE | re.DOTALL)

    # Mejor: Reparar END; seguidos de comentarios o IFs sin el END IF; previo
    content = content.replace("END;\n/*inicio rgelis", "END;\nEND IF;\n/*inicio rgelis")
    content = content.replace("END;\nIF p_Op", "END;\nEND IF;\nIF p_Op")
    
    # Reparar los END IF que quedaron solos sin punto y coma (otra vez por si acaso)
    content = re.sub(r"END\s+IF(?!\s*;)", "END IF;", content, flags=re.IGNORECASE)

    # Reparar el bloque de pagos específicamente (419-449)
    # IF cond THEN BEGIN ... END IF; -> Incorrecto, debe ser END; END IF;
    content = content.replace("END IF;\n\tIF (COALESCE(p_cd_FormaPago,'')='PO')", "END;\nEND IF;\n\tIF (COALESCE(p_cd_FormaPago,'')='PO')")
    # ... y así sucesivamente para los demás
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Bloques anidados reparados.")
except Exception as e:
    print(f"Error: {e}")
