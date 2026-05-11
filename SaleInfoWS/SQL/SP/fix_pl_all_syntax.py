import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir IF ... THEN THEN -> IF ... THEN
    content = re.sub(r"THEN\s+THEN", r"THEN", content, flags=re.IGNORECASE)

    # 2. Corregir END IF missing ;
    content = re.sub(r"END\s+IF(?!\s*;)", r"END IF;", content, flags=re.IGNORECASE)

    # 3. Corregir double semicolons ;;
    content = content.replace(";;", ";")

    # 4. Corregir END missing ; (si está solo en una línea y no es el final del CASE)
    # Buscamos END seguido de salto de línea que no tenga punto y coma
    content = re.sub(r"(\n\s*)END(?!\s*;|\s+IF|\s+CASE|\s+LOOP|\s+\$\$)", r"\1END;", content, flags=re.IGNORECASE)

    # 5. Corregir CASE AS p_var -> p_var := CASE
    def fix_case_as(match):
        var_name = match.group(1)
        rest = match.group(2)
        return f"{var_name} := CASE {rest}"

    content = re.sub(r",\s*CASE\s+AS\s+([\w\"]+)\s+", r", \1 := CASE ", content, flags=re.IGNORECASE)
    # Caso especial para la primera línea del SELECT o fuera de SELECT
    content = re.sub(r"([\w\"]+)\s*:=\s*CASE\s+AS\s+([\w\"]+)\s+", r"\2 := CASE ", content, flags=re.IGNORECASE)

    # 6. Corregir el bloque Frankenstein de pagos visto en el snapshot
    # END; END IF; END IF; -> Limpiar
    content = content.replace("END; END IF; END IF;", "END;") # Ajustar según anidamiento real

    # 7. Corregir BEGIN que quedaron sin IF ... THEN
    content = re.sub(r"(IF\s+.*?THEN)\s*\n\s*BEGIN", r"\1\n\tBEGIN", content, flags=re.IGNORECASE)

    # 8. Reparar SELECT variables que quedaron como , var := CASE
    # En Postgres no se puede asignar variables así dentro de un SELECT normal.
    # Si es un SELECT INTO, debe ser SELECT col1, col2 INTO var1, var2
    
    # 9. Corregir p_gds NOT IN (6,8,9) que no tenía THEN
    content = re.sub(r"IF\s+p_gds\s+NOT\s+IN\s*\(6,8,9\)\s*(?!THEN)", r"IF p_gds NOT IN (6,8,9) THEN\n\t", content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Sintaxis reparada.")
except Exception as e:
    print(f"Error: {e}")
