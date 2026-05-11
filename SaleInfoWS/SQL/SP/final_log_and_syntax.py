import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Reemplazar spzaAuditoria_Insertar por spRegistrarLog
    # Y corregir la sintaxis de llamada a función (usar paréntesis)
    def fix_function_call(match):
        func_name = match.group(1)
        params_str = match.group(2)
        # Convertir "param = val, param2 = val2" a "param := val, param2 := val2"
        # O simplemente limpiar para que sea p1, p2...
        # En PL/pgSQL named parameters usan => o := 
        # Vamos a usar => que es estándar en versiones modernas de Postgres para llamadas
        params_fixed = re.sub(r"([\w\"]+)\s*=\s*", r"\1 => ", params_str)
        return f'PERFORM public."spRegistrarLog"({params_fixed})'

    content = re.sub(r"PERFORM\s+public\.\"spzaAuditoria_Insertar\"\s+(.*?);", fix_function_call, content, flags=re.IGNORECASE | re.DOTALL)

    # 2. Corregir otras llamadas PERFORM que no tienen paréntesis
    def add_parens(match):
        call_part = match.group(0)
        if "(" not in call_part:
            # Intentar adivinar dónde terminan los parámetros
            # Buscamos hasta el punto y coma
            m = re.match(r"(PERFORM\s+[\w\"\.]+)\s+(.*?);", call_part, flags=re.IGNORECASE | re.DOTALL)
            if m:
                func = m.group(1)
                args = m.group(2).strip()
                args_fixed = re.sub(r"([\w\"]+)\s*=\s*", r"\1 => ", args)
                return f"{func}({args_fixed});"
        return call_part

    content = re.sub(r"PERFORM\s+[\w\"\.]+\s+[^;]+;", add_parens, content, flags=re.IGNORECASE | re.DOTALL)

    # 3. Corregir SELECT * INTO p_RetVal FROM func ... (quitar el FROM si es una llamada a función)
    def fix_select_into(match):
        var = match.group(1)
        func = match.group(2)
        args = match.group(3).strip()
        args_fixed = re.sub(r"([\w\"]+)\s*=\s*", r"\1 => ", args)
        # Quitar "OUTPUT" que es de T-SQL
        args_fixed = args_fixed.replace("OUTPUT", "").strip().rstrip(",")
        return f"SELECT * INTO {var} FROM {func}({args_fixed});"

    content = re.sub(r"SELECT\s+\*\s+INTO\s+([\w\"]+)\s+FROM\s+([\w\"\.]+)\s+([^;]+);", fix_select_into, content, flags=re.IGNORECASE | re.DOTALL)

    # 4. Limpiar los IF p_gds NOT IN (6,8,9) que quedaron sin THEN o con basura
    content = re.sub(r"IF\s+p_gds\s+NOT\s+IN\s*\(6,8,9\)\s*(?!THEN)", r"IF p_gds NOT IN (6,8,9) THEN\n\t", content, flags=re.IGNORECASE)

    # 5. Asegurar que los IF de sucursales tengan su bloque bien cerrado
    # (Esto ya debería estar bien pero pulimos)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Reemplazo de log y corrección de llamadas completada.")
except Exception as e:
    print(f"Error: {e}")
