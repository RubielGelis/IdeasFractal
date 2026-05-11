import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Reparar el IF EXISTS con RTRIM
    content = content.replace("RTRIM(value) THEN\n\t='S')", "RTRIM(value) = 'S') THEN")
    content = content.replace("RTRIM(value) THEN ='S')", "RTRIM(value) = 'S') THEN")

    # 2. Reparar el IF EXISTS con OR
    # Buscamos el bloque que tiene un OR EXISTS y le falta el THEN
    content = re.sub(r"(IF\s+\(EXISTS\s*\(.*?\)\s*OR\s*EXISTS\s*\(.*?\)\))\s*(?!THEN)", r"\1 THEN\n\t", content, flags=re.IGNORECASE | re.DOTALL)
    # Eliminar posibles paréntesis extra
    content = content.replace("p_bl_CotizacionFacAuto=1))", "p_bl_CotizacionFacAuto=1)")

    # 3. Corregir IF con variables T-SQL (@p_error)
    content = content.replace("@p_error", "p_error")
    # Asegurar el THEN para p_error
    content = re.sub(r"(IF\s+p_error\s*<>\s*0)\s*(?!THEN)", r"\1 THEN\n\t", content, flags=re.IGNORECASE)

    # 4. Corregir IF p_gds = 1
    content = re.sub(r"(IF\s+p_gds\s*=\s*1)\s*(?!THEN)", r"\1 THEN\n\t", content, flags=re.IGNORECASE)

    # 5. Corregir el INSERT con coma extra
    content = content.replace("p_code,,p_Id_BookingsGDS", "p_code, p_Id_BookingsGDS")

    # 6. Corregir SELECT ... INTO duplicados o mal formados
    # Ya hicimos SELECT ... INTO p_state, pero si quedó algo mal lo arreglamos
    
    # 7. Asegurar que los IF terminen en END IF;
    # (Esto ya lo intentamos antes, pero aseguramos coherencia)
    
    # 8. Limpiar BEGIN/End innecesarios si causan problemas de anidamiento
    # En PL/pgSQL, IF ... THEN ... END IF; no necesita BEGIN...END a menos que haya DECLARE locales.
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Reparación de sintaxis completada.")
except Exception as e:
    print(f"Error: {e}")
