import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Asegurar un único DECLARE al inicio del cuerpo de la función
    # (Ya tenemos RETURNS INTEGER AS $$)
    if "$$\nDECLARE" not in content:
        content = content.replace("$$", "$$\nDECLARE")

    # 2. Corregir asignaciones de SELECT que quedaron como :=
    # Ejemplo: p_var := (CASE ...) FROM table -> SELECT (CASE ...) INTO p_var FROM table
    content = re.sub(r"([\w\"]+)\s*:=\s*(\(CASE.*?END\))\s*FROM\s+(.*?);", r"SELECT \2 INTO \1 FROM \3;", content, flags=re.IGNORECASE | re.DOTALL)
    
    # 3. Corregir SELECT INTO con múltiples variables (style p_var = col)
    # p_branch = Sucursales.code
    content = re.sub(r"p_branch\s*=\s*Sucursales\.code", r"Sucursales.code", content)
    content = re.sub(r"p_implant\s*=\s*Implantes\.code", r"Implantes.code", content)
    # Y asegurar el INTO
    content = content.replace("SELECT Sucursales.code", "SELECT Sucursales.code INTO p_branch")
    
    # 4. Corregir el IF con OR que quedó mal
    content = content.replace("THEN\n\tOR Exists", "OR EXISTS")

    # 5. Corregir el bloque de tarjeta de crédito (p_implant = Implantes.code)
    content = content.replace(",p_implant = Implantes.code", ", Implantes.code")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Correcciones de asignaciones y bloques completadas.")
except Exception as e:
    print(f"Error: {e}")
