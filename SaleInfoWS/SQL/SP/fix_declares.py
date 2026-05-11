import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir DECLARE: PL/pgSQL no soporta comas para múltiples variables
    # Ejemplo: DECLARE var1 type, var2 type -> var1 type; var2 type;
    def fix_declare(match):
        vars_part = match.group(1)
        # Dividir por comas y reconstruir con punto y coma
        vars_list = vars_part.split(",")
        fixed_vars = []
        last_type = ""
        
        # Intentar inferir tipos si faltan (ej: var1, var2 INTEGER)
        # Pero es mejor ir de atrás hacia adelante o buscar el tipo al final de cada segmento
        for v in vars_list:
            v = v.strip()
            if not v: continue
            # Si tiene tipo (ej: var INTEGER)
            if " " in v:
                fixed_vars.append(v + ";")
                last_type = v.split()[-1]
            else:
                # Si no tiene tipo, usa el último tipo conocido
                fixed_vars.append(v + " " + last_type + ";")
        
        return "\n\t".join(fixed_vars)

    content = re.sub(r"DECLARE\s+([^;\n]+)(?=;|\n|$)", fix_declare, content, flags=re.IGNORECASE)
    
    # También corregir DECLARE repetidos dentro del bloque DECLARE
    content = content.replace("DECLARE DECLARE", "DECLARE")

    # 2. Corregir asignaciones en SELECT INTO (p_implant = Implantes.code)
    content = re.sub(r",\s*([\w\"]+)\s*=\s*([\w\"\.]+)", r", \2 AS \1", content) # En SELECT para múltiples INTO
    # O mejor: SELECT col1, col2 INTO var1, var2
    
    # 3. Corregir IF EXISTS y IF conditions (THEN)
    content = re.sub(r"(IF\s+.*?)(?!\s+THEN)\s*\n\s*BEGIN", r"\1 THEN\n\tBEGIN", content, flags=re.IGNORECASE)
    content = re.sub(r"END\s+IF\s+(.*?)\s+BEGIN", r"END IF;\n\tIF \1 THEN\n\tBEGIN", content, flags=re.IGNORECASE)

    # 4. Corregir comparaciones booleanas (p_external = 1 -> p_external = true)
    content = content.replace("p_external = 1", "p_external = true")
    content = content.replace("p_external = 0", "p_external = false")

    # 5. Corregir variables T-SQL que quedaron (p_Id_public."BookingGDS" -> p_Id_BookingGDS)
    content = content.replace('p_Id_public."BookingGDS"', "p_Id_BookingGDS")
    content = content.replace('p_Id_BookingsGDS', "p_Id_BookingGDS")

    # 6. Corregir SELECT ... INTO mal formados (p_implant = Implantes.code)
    # SELECT Sucursales.code INTO p_branch ,p_implant = Implantes.code
    # -> SELECT Sucursales.code, Implantes.code INTO p_branch, p_implant
    def fix_select_multi_into(match):
        fields = match.group(1)
        vars = match.group(2)
        # Si vars tiene un "=", es T-SQL style
        if "=" in vars:
            # Reestructurar
            # SELECT f1, f2 INTO v1, v2
            return match.group(0) # Complejo para regex simple, lo haremos manual si falla
        return match.group(0)

    # 7. Asegurar que los IF terminen en END IF;
    # (Ya lo hicimos antes, pero por si acaso)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Corrección de declaraciones y sintaxis completada.")
except Exception as e:
    print(f"Error: {e}")
