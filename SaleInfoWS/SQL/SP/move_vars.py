import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Encontrar todas las líneas que parecen declaraciones en el cuerpo
    # Ejemplo: p_var type; o Declare p_var type;
    # (Buscamos después del BEGIN principal)
    
    parts = re.split(r"BEGIN", content, 1, flags=re.IGNORECASE)
    if len(parts) < 2:
        print("No se encontró BEGIN")
        exit(0)
    
    header_plus_declare = parts[0]
    body = parts[1]
    
    # Buscar declaraciones en el cuerpo
    # Patrón: p_[\w\"]+\s+(?:VARCHAR|INTEGER|TEXT|BOOLEAN|DOUBLE PRECISION|SMALLINT)\s*(?:\(\d+\))?\s*;
    # O Declare p_[\w\"]+ ...
    decl_regex = r"(?:Declare\s+)?(p_[\w\"]+\s+(?:VARCHAR|INTEGER|TEXT|BOOLEAN|DOUBLE\s+PRECISION|SMALLINT)\s*(?:\(\d+\))?\s*;)"
    
    found_decls = re.findall(decl_regex, body, flags=re.IGNORECASE)
    
    if found_decls:
        print(f"Encontradas {len(found_decls)} declaraciones en el cuerpo. Moviendo...")
        # Limpiar el cuerpo
        new_body = re.sub(decl_regex, "", body, flags=re.IGNORECASE)
        
        # Añadir al DECLARE
        new_header = header_plus_declare.rstrip() + "\n\t" + "\n\t".join(found_decls) + "\n"
        
        content = new_header + "\nBEGIN" + new_body
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Variables movidas al bloque DECLARE.")
except Exception as e:
    print(f"Error: {e}")
