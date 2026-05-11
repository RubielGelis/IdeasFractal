import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Asegurar punto y coma en SELECT ... INTO
    content = re.sub(r"(SELECT\s+.*?\s+INTO\s+.*?\s+FROM\s+.*?\s+WHERE\s+.*?)(?!\s*;)(\n|$)", r"\1;\2", content, flags=re.IGNORECASE)

    # 2. Asegurar punto y coma en asignaciones
    content = re.sub(r"(p_[\w\"]+\s*:=\s*.*?)(?!\s*;)(\n|$)", r"\1;\2", content, flags=re.IGNORECASE)

    # 3. Corregir bloques IF/BEGIN/END
    # Buscamos BEGIN que NO tengan un END; antes del END IF;
    # (Hacemos un reemplazo de patrones comunes en este archivo)
    
    # Patrón: BEGIN \n p_var := val; \n END IF; -> BEGIN \n p_var := val; \n END; END IF;
    content = re.sub(r"(BEGIN\s+.*?\s+)(END\s+IF;)", r"\1END;\n\2", content, flags=re.IGNORECASE | re.DOTALL)
    
    # Pero no si ya tiene END;
    content = content.replace("END;\nEND;", "END;") # Evitar duplicados si ya existía
    
    # 4. Corregir SELECT sin INTO (que deberían ser INTO)
    # Ejemplo: SELECT initials From public."Prestadora" Where code = p_AerolineaExterna
    # (Ya lo hicimos en la mayoría, pero revisamos)
    
    # 5. Limpiar espacios extras y saltos de línea
    # content = re.sub(r"\n\s*\n\s*\n", r"\n\n", content)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Limpieza profunda completada.")
except Exception as e:
    print(f"Error: {e}")
