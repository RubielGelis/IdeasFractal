import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir el final de la función
    content = content.replace("DECLARE LANGUAGE plpgsql;", "LANGUAGE plpgsql;")
    
    # 2. Corregir comparaciones mal convertidas a := en bloques IF
    content = re.sub(r"IF\s+([\w\"]+)\s*:=\s*", r"IF \1 = ", content, flags=re.IGNORECASE)

    # 3. Corregir el BEGIN/END del cuerpo de la función
    # Debe haber un BEGIN después de DECLARE y antes de la lógica
    if "DECLARE\nBEGIN" not in content and "DECLARE" in content:
        # Buscamos el final del bloque DECLARE (donde empiezan las sentencias)
        # Una forma es buscar la primera asignación o IF
        content = re.sub(r"(p_RESPETARVALOR\s*:=\s*0;)", r"BEGIN\n\n\1", content, count=1)

    # 4. Asegurar que los IF terminen en END IF; (mantenimiento)
    
    # 5. Corregir declaraciones de variables que pudieron quedar sin DECLARE si se borró el global
    # Pero ya pusimos uno en fix_assignments.py
    
    # 6. Eliminar el punto y coma extra en comentarios que causan ruido
    content = content.replace("Exito;;", "Exito;")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Corrección final de sintaxis completada.")
except Exception as e:
    print(f"Error: {e}")
