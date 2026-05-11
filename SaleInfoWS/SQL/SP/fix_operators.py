import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Revertir => a = en WHERE, IF, AND, OR, CASE
    # Buscamos => que NO esté dentro de un paréntesis de llamada a función (aunque es difícil)
    # Por ahora, revertimos => a = en general y luego arreglamos las funciones si es necesario
    content = content.replace(" => ", " = ")
    
    # 2. Corregir asignaciones: = debe ser := en la mayoría de los casos de PL/pgSQL
    # Pero no en los SELECT ... INTO o UPDATE SET col = val
    # Vamos a usar una lógica más específica
    
    # Asignaciones directas en líneas solas
    content = re.sub(r"([\w\"]+)\s*=\s*([^;=]+);", r"\1 := \2;", content)
    
    # Pero en UPDATE SET debe ser =
    content = re.sub(r"SET\s+([\w\"]+)\s*:=\s*", r"SET \1 = ", content, flags=re.IGNORECASE)

    # 3. Corregir llamadas a funciones: Estas SÍ pueden usar => para parámetros nombrados en PG
    # Pero para no fallar, podemos usar la posición o :=
    # Vamos a dejar = para comparaciones y := para asignaciones.
    # PG soporta := en llamadas a funciones para parámetros nombrados en algunas versiones, 
    # pero => es lo más seguro para PG 9.5+.
    
    # Si queremos usar => en funciones:
    # PERFORM public."spRegistrarLog"(p_id => 1, ...)
    # Vamos a buscar PERFORM y SELECT * FROM func( y cambiar = por => dentro
    def fix_args(match):
        func_part = match.group(1)
        args = match.group(2)
        # Cambiar = por => solo aquí
        args_fixed = args.replace(" = ", " => ")
        return f"{func_part}({args_fixed})"

    content = re.sub(r"(PERFORM\s+[\w\"\.]+\()([^\)]+)\)", fix_args, content, flags=re.IGNORECASE)
    content = re.sub(r"(public\.\"spRegistrarLog\"\()([^\)]+)\)", fix_args, content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Operadores corregidos: comparaciones (=) y asignaciones (:=) restauradas.")
except Exception as e:
    print(f"Error: {e}")
