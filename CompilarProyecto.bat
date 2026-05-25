@echo off
echo ========================================================
echo  Compilador del Proyecto Ideas Fractal (SaleInfoWS)
echo ========================================================
echo.

SET "SLN_FILE=%~dp0SaleInfoWS\SaleInfoWS.sln"
SET "MSBUILD_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
SET "NUGET_EXE=%~dp0nuget.exe"

REM 1. Comprobar si existe el archivo sln
if not exist "%SLN_FILE%" (
    echo [ERROR] No se encontro el archivo %SLN_FILE%
    pause
    exit /b 1
)

REM 2. Descargar NuGet.exe si no existe
if not exist "%NUGET_EXE%" (
    echo [INFO] Descargando nuget.exe necesario para restaurar los paquetes de C#...
    powershell -Command "Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile '%NUGET_EXE%'"
)

REM 3. Restaurar paquetes NuGet
echo.
echo [INFO] Restaurando paquetes NuGet (librerias)...
"%NUGET_EXE%" restore "%SLN_FILE%"

REM 4. Verificar existencia de MSBuild nativo
if not exist "%MSBUILD_PATH%" (
    echo [ERROR] No se encontro el compilador de Windows en %MSBUILD_PATH%
    pause
    exit /b 1
)

REM 5. Ejecutar la compilacion
echo.
echo [INFO] Compilando la solucion...
"%MSBUILD_PATH%" "%SLN_FILE%" /p:Configuration=Release /nologo /v:m

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  [EXITO] El proyecto se compilo correctamente.
    echo  Los archivos generados estaran en la carpeta bin/Release
    echo ========================================================
) else (
    echo.
    echo ========================================================
    echo  [ERROR] Hubo fallos en la compilacion. 
    echo  Revisa los mensajes de arriba.
    echo ========================================================
)

echo.
pause
