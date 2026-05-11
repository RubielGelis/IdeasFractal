import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Asegurar que cada BEGIN tenga su END; y cada IF tenga su END IF;
    # El patrón detectado es IF ... THEN BEGIN ... END (sin punto y coma ni END IF)
    
    # Reparar IF ... THEN BEGIN ... END -> IF ... THEN BEGIN ... END; END IF;
    content = re.sub(r"(IF\s+COALESCE\(.*?\).*?THEN\s+BEGIN\s+.*?\s+END)(?!\s+IF)", r"\1; END IF;", content, flags=re.IGNORECASE | re.DOTALL)
    
    # Reparar casos específicos donde falta el punto y coma tras END
    content = content.replace("END\n/*inicio rgelis", "END;\nEND IF;\n/*inicio rgelis")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Anidamiento corregido.")
except Exception as e:
    print(f"Error: {e}")
