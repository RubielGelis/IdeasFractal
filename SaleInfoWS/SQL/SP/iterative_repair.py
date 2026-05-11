import re
import os
import subprocess

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"
psql_path = r"C:\Program Files\PostgreSQL\18\bin\psql.exe"
env = os.environ.copy()
env["PGPASSWORD"] = "111985"

def run_psql():
    cmd = [psql_path, "-h", "localhost", "-U", "postgres", "-d", "agencias_new", "-f", file_path]
    result = subprocess.run(cmd, env=env, capture_output=True, text=True)
    return result.stderr

for i in range(10): # Máximo 10 iteraciones de reparación
    error = run_psql()
    if not error or "ERROR" not in error:
        print("No se encontraron más errores de sintaxis.")
        break
    
    print(f"Error detectado: {error}")
    
    # Intentar reparar el error basado en el mensaje
    # Ejemplo: ERROR: syntax error at or near "IF" LINE 117: End IF;
    m = re.search(r"LINE (\d+):", error)
    if m:
        line_no = int(m.group(1))
        with open(file_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        
        target_line = lines[line_no - 1]
        
        # Caso 1: End IF; sin END; previo si hay un BEGIN abierto
        if "End IF;" in target_line or "END IF;" in target_line:
            # Buscar hacia atrás el BEGIN
            found_begin = False
            for j in range(line_no - 2, max(0, line_no - 50), -1):
                if "BEGIN" in lines[j].upper():
                    found_begin = True
                    break
                if "END;" in lines[j].upper(): # Ya tiene cierre
                    break
            if found_begin:
                lines[line_no - 1] = target_line.replace("IF;", "; END IF;").replace("if;", "; end if;")
                if "END;" not in lines[line_no - 1].upper():
                    lines[line_no - 1] = "END; " + lines[line_no - 1]
        
        # Caso 2: Error cerca de una sentencia sin punto y coma
        elif "syntax error at or near" in error:
            # Intentar poner punto y coma en la línea anterior
            if line_no > 1:
                prev_line = lines[line_no - 2].strip()
                if prev_line and not prev_line.endswith(";") and not prev_line.endswith("BEGIN") and not prev_line.endswith("THEN") and not prev_line.endswith("ELSE"):
                    lines[line_no - 2] = lines[line_no - 2].rstrip() + ";\n"

        with open(file_path, "w", encoding="utf-8") as f:
            f.writelines(lines)
    else:
        break

print("Reparación iterativa finalizada.")
