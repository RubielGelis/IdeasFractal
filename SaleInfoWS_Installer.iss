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
  DBTypePage: TInputOptionWizardPage;
  DBPage: TInputQueryWizardPage;

procedure InitializeWizard;
begin
  // Página para seleccionar el tipo de base de datos
  DBTypePage := CreateInputOptionPage(wpSelectDir,
    'Tipo de Base de Datos', 'Seleccione el motor de base de datos',
    'Seleccione el motor de base de datos al cual se conectará el servicio:',
    True, False);
  DBTypePage.Add('PostgreSQL');
  DBTypePage.Add('SQL Server');
  DBTypePage.SelectedValueIndex := 0;

  // Página para los datos de conexión
  DBPage := CreateInputQueryPage(DBTypePage.ID,
    'Configuración de la Base de Datos', 'Conexión a la Base de Datos',
    'Por favor ingrese los datos de conexión.');

  DBPage.Add('Servidor / Host:', False);
  DBPage.Add('Puerto (dejar vacío si no aplica):', False);
  DBPage.Add('Base de Datos:', False);
  DBPage.Add('Usuario:', False);
  DBPage.Add('Contraseña:', True);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = DBPage.ID then
  begin
    if DBTypePage.SelectedValueIndex = 0 then
    begin
      // Configuración PostgreSQL
      DBPage.Caption := 'Conexión a PostgreSQL';
      DBPage.Description := 'Por favor ingrese los datos de conexión para la base de datos PostgreSQL.';
      if (DBPage.Values[0] = '') or (DBPage.Values[0] = 'RUBIEL-PC\SQLEXPRESS') then
      begin
        DBPage.Values[0] := 'localhost';
        DBPage.Values[1] := '5432';
        DBPage.Values[2] := 'agencias_new';
        DBPage.Values[3] := 'postgres';
        DBPage.Values[4] := '';
      end;
    end
    else
    begin
      // Configuración SQL Server
      DBPage.Caption := 'Conexión a SQL Server';
      DBPage.Description := 'Por favor ingrese los datos de conexión para la base de datos SQL Server.';
      if (DBPage.Values[0] = '') or (DBPage.Values[0] = 'localhost') then
      begin
        DBPage.Values[0] := 'RUBIEL-PC\SQLEXPRESS';
        DBPage.Values[1] := '';
        DBPage.Values[2] := 'Agencias';
        DBPage.Values[3] := 'sa';
        DBPage.Values[4] := '111985';
      end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConnectionString: String;
  ProviderName: String;
  DatabaseType: String;
  ConfigFile: String;
  FileContentAnsi: AnsiString;
  FileContentStr: String;
begin
  if CurStep = ssPostInstall then
  begin
    if DBTypePage.SelectedValueIndex = 0 then
    begin
      DatabaseType := 'PostgreSQL';
      ProviderName := 'Npgsql';
      ConnectionString := 'Host=' + DBPage.Values[0] + ';' +
                          'Port=' + DBPage.Values[1] + ';' +
                          'Database=' + DBPage.Values[2] + ';' +
                          'Username=' + DBPage.Values[3] + ';' +
                          'Password=' + DBPage.Values[4] + ';';
    end
    else
    begin
      DatabaseType := 'SqlServer';
      ProviderName := 'System.Data.SqlClient';
      ConnectionString := 'Server=' + DBPage.Values[0] + ';' +
                          'Database=' + DBPage.Values[2] + ';' +
                          'User Id=' + DBPage.Values[3] + ';' +
                          'Password=' + DBPage.Values[4] + ';';
    end;
                        
    ConfigFile := ExpandConstant('{app}\Web.config');
    if LoadStringFromFile(ConfigFile, FileContentAnsi) then
    begin
      FileContentStr := String(FileContentAnsi);
      StringChange(FileContentStr, 'DB_TYPE_PLACEHOLDER', DatabaseType);
      StringChange(FileContentStr, 'DB_PROVIDER_PLACEHOLDER', ProviderName);
      StringChange(FileContentStr, 'DB_CONNECTION_STRING_PLACEHOLDER', ConnectionString);
      FileContentAnsi := AnsiString(FileContentStr);
      SaveStringToFile(ConfigFile, FileContentAnsi, False);
    end;
    
    MsgBox('Los archivos se han copiado exitosamente en: ' + ExpandConstant('{app}') + #13#10 + #13#10 +
           'La base de datos se ha configurado como ' + DatabaseType + '.', mbInformation, MB_OK);
  end;
end;
