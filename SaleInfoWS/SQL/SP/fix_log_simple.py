import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Reemplazo directo del nombre
    content = content.replace('PERFORM public."spzaAuditoria_Insertar"', 'PERFORM public."spRegistrarLog"')

    # 2. Corregir llamadas PERFORM (agregar paréntesis y =>)
    def fix_perform(match):
        full_match = match.group(0)
        # Extraer nombre de la función y parámetros
        m = re.match(r'(PERFORM\s+[\w\"\.]+)\s+(.*?);', full_match, re.IGNORECASE | re.DOTALL)
        if m:
            func = m.group(1)
            params = m.group(2).strip()
            if not params.startswith("("):
                params_fixed = re.sub(r"([\w\"]+)\s*=\s*", r"\1 => ", params)
                return f"{func}({params_fixed});"
        return full_match

    content = re.sub(r'PERFORM\s+public\.\"spRegistrarLog\".*?;', fix_perform, content, flags=re.IGNORECASE | re.DOTALL)

    # 3. Corregir el bloque SELECT * INTO
    content = re.sub(r'SELECT\s+\*\s+INTO\s+p_RetVal\s+FROM\s+([\w\"\.]+)\s+([^;]+);', 
                     r'SELECT * INTO p_RetVal FROM \1(\2);', content, flags=re.IGNORECASE)
    
    # 4. Limpiar OUTPUT y => en SELECT * INTO
    content = content.replace("OUTPUT", "")
    content = re.sub(r"([\w\"]+)\s*=\s*", r"\1 => ", content) # Aplicar a todo el archivo para uniformidad de parámetros

    # 5. Fix p_state = p."state" typo
    content = content.replace('p_state => p."state"', 'p_state := p."state"')

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Reemplazo de log y corrección de llamadas completada.")
except Exception as e:
    print(f"Error: {e}")
