import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Eliminar todos los puntos y coma duplicados (;;+)
    content = re.sub(r";\s*;", ";", content)
    content = re.sub(r";\s*;", ";", content) # Segunda pasada por si acaso

    # 2. Asegurar punto y coma en SELECT ... INTO
    # Solo si no tiene ya uno (limpiamos espacios antes)
    content = re.sub(r"(SELECT\s+.*?\s+INTO\s+.*?\s+FROM\s+.*?\s+WHERE\s+[^;]*?)(?=\n|$)", r"\1;", content, flags=re.IGNORECASE)

    # 3. Asegurar punto y coma en asignaciones
    content = re.sub(r"(p_[\w\"]+\s*:=\s*[^;]*?)(?=\n|$)", r"\1;", content, flags=re.IGNORECASE)

    # 4. Corregir bloques IF/BEGIN/END que pudieran haber quedado mal
    content = content.replace("END; ;", "END;")
    content = content.replace("; ;", ";")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Limpieza final completada.")
except Exception as e:
    print(f"Error: {e}")
