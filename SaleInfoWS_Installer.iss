[Setup]
; Información general de la aplicación
AppName=SaleinfoWS
AppVersion=1.0
AppPublisher=Tu Empresa
; Ruta por defecto sugerida (típicamente en IIS es C:\inetpub\wwwroot\...)
DefaultDirName={sd}\inetpub\SaleInfoWS
DefaultGroupName=SaleInfoWS
; Carpeta y nombre del ejecutable que se va a generar
OutputDir=.
OutputBaseFilename=Instalador_SaleInfoWS
Compression=lzma
SolidCompression=yes
; Estilo moderno (siguiente, siguiente y barra de progreso)
WizardStyle=modern
; Privilegios de administrador necesarios para copiar a IIS y otras configuraciones
PrivilegesRequired=admin

[Files]
; ==============================================================================
; AQUÍ SE INCLUYEN LOS ARCHIVOS NECESARIOS PARA EL FUNCIONAMIENTO EN IIS
; ==============================================================================
Source: "SaleInfoWS\SaleInfoWS\SaleInfoWS\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "SaleInfoWS\SaleInfoWS\SaleInfoWS\Global.asax"; DestDir: "{app}"; Flags: ignoreversion
Source: "SaleInfoWS\SaleInfoWS\SaleInfoWS\Web.config"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; Crear un Application Pool en IIS
Filename: "{sys}\inetsrv\appcmd.exe"; Parameters: "add apppool /name:""SaleinfoWSAppPool"" /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated"; Flags: runhidden skipifdoesntexist

; Crear la Aplicación en IIS bajo "Default Web Site"
Filename: "{sys}\inetsrv\appcmd.exe"; Parameters: "add app /site.name:""Default Web Site"" /path:""/SaleinfoWS"" /physicalPath:""{app}"" /applicationPool:""SaleinfoWSAppPool"""; Flags: runhidden skipifdoesntexist

[Code]
var
  DBPage: TInputQueryWizardPage;

procedure InitializeWizard;
begin
  // Creamos una nueva página en el asistente que aparecerá después de elegir el directorio (wpSelectDir)
  DBPage := CreateInputQueryPage(wpSelectDir,
    'Configuración de la Base de Datos', 'Conexión a PostgreSQL',
    'Por favor ingrese los datos de conexión para la base de datos PostgreSQL de SaleinfoWS.');

  // Agregamos los campos de texto
  DBPage.Add('Servidor (Host):', False);
  DBPage.Add('Puerto:', False);
  DBPage.Add('Base de Datos:', False);
  DBPage.Add('Usuario:', False);
  DBPage.Add('Contraseña:', True); // True indica que es un campo de contraseña (se ocultan los caracteres)

  // Valores por defecto
  DBPage.Values[0] := 'localhost';
  DBPage.Values[1] := '5432';
  DBPage.Values[2] := 'agencias_new';
  DBPage.Values[3] := 'postgres';
  DBPage.Values[4] := '';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConnectionString: String;
  ConfigFile: String;
  FileContentAnsi: AnsiString;
  FileContentStr: String;
begin
  // ssPostInstall ocurre justo después de que la barra de progreso termina de copiar los archivos
  if CurStep = ssPostInstall then
  begin
    // Construimos la cadena de conexión basada en lo que el usuario ingresó
    ConnectionString := 'Host=' + DBPage.Values[0] + ';' +
                        'Port=' + DBPage.Values[1] + ';' +
                        'Database=' + DBPage.Values[2] + ';' +
                        'Username=' + DBPage.Values[3] + ';' +
                        'Password=' + DBPage.Values[4] + ';';
                        
    // Guardamos la cadena de conexión en el Web.config
    ConfigFile := ExpandConstant('{app}\Web.config');
    if LoadStringFromFile(ConfigFile, FileContentAnsi) then
    begin
      FileContentStr := String(FileContentAnsi);
      StringChange(FileContentStr, 'Host=localhost;Port=5432;Database=agencias_new;Username=postgres;Password=111985;', ConnectionString);
      FileContentAnsi := AnsiString(FileContentStr);
      SaveStringToFile(ConfigFile, FileContentAnsi, False);
    end;
    
    // Mensaje de confirmación (opcional, puedes quitarlo)
    MsgBox('Los archivos se han copiado exitosamente en: ' + ExpandConstant('{app}') + #13#10 + #13#10 +
           'Los datos de la base de datos se han procesado correctamente.', mbInformation, MB_OK);
  end;
end;
