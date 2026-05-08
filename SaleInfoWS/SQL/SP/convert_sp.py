import re

with open('spInterfaceReadXMLBookingIdeasFractal.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

# Remove ENCRYPTION and SET NOCOUNT
sql = re.sub(r'WITH ENCRYPTION', '', sql, flags=re.IGNORECASE)
sql = re.sub(r'SET NOCOUNT ON', '', sql, flags=re.IGNORECASE)

# Replace Procedure Header
sql = re.sub(r'CREATE PROCEDURE dbo\.\[?(\w+)\]?\s*(.*?)\s*AS\s*BEGIN', 
    r'CREATE OR REPLACE FUNCTION \1(\2)\nRETURNS void\nLANGUAGE plpgsql\nAS function\nDECLARE', 
    sql, flags=re.IGNORECASE|re.DOTALL)

# Fix parameters in function header
def fix_params(match):
    header = match.group(0)
    header = re.sub(r'@(\w+)', r'p_\1', header)
    header = re.sub(r'VARCHAR\(MAX\)', 'text', header, flags=re.IGNORECASE)
    header = re.sub(r' output', '', header, flags=re.IGNORECASE)
    return header

sql = re.sub(r'CREATE OR REPLACE FUNCTION \w+\(.*?\)\nRETURNS void', fix_params, sql, flags=re.IGNORECASE|re.DOTALL)

# Extract and convert DECLARE @Table TABLE to CREATE TEMP TABLE
table_decl_pattern = re.compile(r'DECLARE\s+@(\w+)\s+TABLE\s*\((.*?)\)', re.IGNORECASE | re.DOTALL)
temp_tables = []
def replace_table_decl(m):
    table_name = m.group(1)
    columns = m.group(2)
    # Remove IDENTITY
    columns = re.sub(r'IDENTITY\(\d+,\d+\)|IDENTITY', 'SERIAL', columns, flags=re.IGNORECASE)
    columns = re.sub(r'VARCHAR\(MAX\)', 'text', columns, flags=re.IGNORECASE)
    columns = re.sub(r'MONEY', 'numeric(18,2)', columns, flags=re.IGNORECASE)
    temp_tables.append(f"CREATE TEMP TABLE tmp_{table_name} ({columns}) ON COMMIT DROP;")
    return f"-- TEMP TABLE tmp_{table_name} moved to BEGIN block"

sql = table_decl_pattern.sub(replace_table_decl, sql)

# Convert other DECLARE @var TYPE
sql = re.sub(r'DECLARE\s+@(\w+)\s+VARCHAR\(MAX\)', r'v_\1 text;', sql, flags=re.IGNORECASE)
sql = re.sub(r'DECLARE\s+@(\w+)\s+(.*?)(?=\n|;)', r'v_\1 \2;', sql, flags=re.IGNORECASE)
sql = re.sub(r'MONEY', 'numeric(18,2)', sql, flags=re.IGNORECASE)
sql = re.sub(r'TINYINT', 'smallint', sql, flags=re.IGNORECASE)
sql = re.sub(r'BIT', 'boolean', sql, flags=re.IGNORECASE)

# Insert TEMP TABLES after BEGIN
begin_pos = sql.find('BEGIN', sql.find('function'))
if begin_pos != -1:
    tables_sql = '\n    '.join(temp_tables)
    sql = sql[:begin_pos+5] + '\n    ' + tables_sql + '\n' + sql[begin_pos+5:]

# Replace variable usage @var with v_var
sql = re.sub(r'@(?!NodoXML)(\w+)', r'v_\1', sql)
# Parameters use p_
sql = re.sub(r'v_(Op|XML|XMLOutput|BlSelect)\b', r'p_\1', sql, flags=re.IGNORECASE)

# Basic function replacements
sql = re.sub(r'ISNULL\(', 'COALESCE(', sql, flags=re.IGNORECASE)
sql = re.sub(r'CHARINDEX\(', 'STRPOS(', sql, flags=re.IGNORECASE)
sql = re.sub(r'LEN\(', 'LENGTH(', sql, flags=re.IGNORECASE)
sql = re.sub(r'CHAR\(9\)', 'CHR(9)', sql, flags=re.IGNORECASE)
sql = re.sub(r'CHAR\(10\)', 'CHR(10)', sql, flags=re.IGNORECASE)

# Replace table references from @table to tmp_table
sql = re.sub(r'v_(Reservas|ReservaGDS_Itinerarios|ReservaGDS_Pasajeros|ReservaGDS_FEE|ReservaGDS_VariablesAdicionales|ReservaGDS_CargosImpuestos|ReservaGDS_ValoresItems|ReservaGDS_FormasPagos|ReservaGDS_Valores|EntidadesNOGDS)', r'tmp_\1', sql, flags=re.IGNORECASE)

# End function
sql = re.sub(r'END\s*$', 'END;\nfunction;', sql, flags=re.IGNORECASE)

with open('spInterfaceReadXMLBookingIdeasFractal_pg.sql', 'w', encoding='utf-8') as f:
    f.write(sql)
