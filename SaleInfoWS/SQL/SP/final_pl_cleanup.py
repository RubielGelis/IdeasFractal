import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir asignaciones en SELECT: SELECT var = val -> SELECT val INTO var
    # O mejor: var := val; si es un CASE
    content = re.sub(r"SELECT\s+([\w\"]+)\s*=\s*(CASE.*?END)", r"\1 := (\2)", content, flags=re.IGNORECASE | re.DOTALL)
    content = re.sub(r"SELECT\s+([\w\"]+)\s*=\s*([\w\"\(\) \.\+\-]+)(?=\s+FROM|;|\n)", r"SELECT \2 INTO \1", content, flags=re.IGNORECASE)

    # 2. Corregir IF EXISTS: If Exists(Select ...) -> IF EXISTS (SELECT ...) THEN
    content = re.sub(r"If\s+Exists\s*\(", r"IF EXISTS (", content, flags=re.IGNORECASE)
    # Asegurar el THEN
    content = re.sub(r"(IF\s+EXISTS\s*\(.*?\))\s*(?!THEN)", r"\1 THEN\n\t", content, flags=re.IGNORECASE | re.DOTALL)

    # 3. Corregir RAISERROR -> RAISE EXCEPTION
    content = re.sub(r"Raiserror\s*\(([^,]+),[^,]+,[^,]+\)", r"RAISE EXCEPTION \1", content, flags=re.IGNORECASE)

    # 4. Corregir Exec -> PERFORM (para funciones void) o SELECT ... INTO
    # Para simplificar, convertimos Exec a -- EXEC y avisamos
    content = re.sub(r"Exec\s+p_RetVal\s*=\s*([\w]+)", r"SELECT * INTO p_RetVal FROM \1", content, flags=re.IGNORECASE)
    content = re.sub(r"Exec\s+([\w]+)", r"PERFORM \1", content, flags=re.IGNORECASE)

    # 5. Corregir RTRIM(LTRIM(x)) -> TRIM(x)
    content = re.sub(r"RTRIM\s*\(\s*LTRIM\s*\((.*?)\)\s*\)", r"TRIM(\1)", content, flags=re.IGNORECASE)

    # 6. Corregir la sintaxis rota de END IF (EXISTS...
    content = re.sub(r"END\s+IF\s+\(EXISTS", r"END IF;\n\tIF EXISTS", content, flags=re.IGNORECASE)

    # 7. Corregir UPDATE con asignación incorrecta: UPDATE ... SET col := val -> col = val
    content = re.sub(r"UPDATE\s+([\w\"\.]+)\s+(?:SET\s+)?([\w\"]+)\s*:=\s*", r"UPDATE \1 SET \2 = ", content, flags=re.IGNORECASE)

    # 8. Corregir nombres de tablas legacy (BookingsGDS -> public."BookingGDS")
    content = content.replace("BookingsGDS.", "public.\"BookingGDS\".")
    content = content.replace("BookingsGDS ", "public.\"BookingGDS\" ")
    content = content.replace("BookingGDS_Product", "public.\"BookingProductGDS\"")
    content = content.replace("id_Booking", "\"bookingId\"") # Cuidado con este, pero en el nuevo esquema es bookingId

    # 9. Asegurar punto y coma al final de las sentencias
    # Este es difícil con regex, pero haremos lo básico
    content = re.sub(r"(:=.*?[^;])\n", r"\1;\n", content)

    # 10. Corregir SELECT p_state = p."state" -> p_state := p."state"
    content = re.sub(r"SELECT\s+([\w\"]+)\s*=\s*([\w\"\.]+)(?=\n|\s+FROM)", r"\1 := \2", content, flags=re.IGNORECASE)

    # 11. Corregir el bloque final de Cab que tiene un error de UPDATE
    # Buscamos: UPDATE public."BookingGDS" cd_formapago_cliente :=
    content = re.sub(r"UPDATE\s+public\.\"BookingGDS\"\s+cd_formapago_cliente\s*:=\s*", r"UPDATE public.\"BookingGDS\" SET cd_formapago_cliente = ", content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Limpieza final de patrones T-SQL completada.")
except Exception as e:
    print(f"Error: {e}")
