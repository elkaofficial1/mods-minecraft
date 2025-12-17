@echo off
setlocal

:: ==========================================
:: ВСТАВЬТЕ ССЫЛКУ НИЖЕ (БЕЗ ПРОБЕЛОВ):
set REPO_URL=https://github.com/elkaofficial1/mods-minecraft

:: УКАЖИТЕ ВЕТКУ (main или master):
set BRANCH=main
:: ==========================================

echo.
echo [INFO] Starting Minecraft update...
echo [INFO] URL: %REPO_URL%

:: Очистка URL от лишних слешей
if "%REPO_URL:~-1%"=="/" set "REPO_URL=%REPO_URL:~0,-1%"
set "DOWNLOAD_URL=%REPO_URL%/archive/refs/heads/%BRANCH%.zip"
set "ZIP_FILE=update.zip"
set "TEMP_DIR=temp_update"

:: 1. СКАЧИВАНИЕ (Downloading)
echo.
echo [1/3] Downloading...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' } catch { exit 1 }"

if not exist %ZIP_FILE% (
    echo.
    echo [ERROR] Download failed!
    echo Check your link and internet connection.
    pause
    exit /b
)

:: Проверка размера файла
for %%F in (%ZIP_FILE%) do set size=%%~zF
if %size% LSS 1000 (
    echo.
    echo [ERROR] File is too small. Probably wrong link or Private repository.
    del %ZIP_FILE%
    pause
    exit /b
)

:: 2. РАСПАКОВКА (Unzipping)
echo [2/3] Unzipping...
if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_DIR%' -Force"

:: Поиск папки внутри
cd %TEMP_DIR%
set "FOUND_DIR="
for /d %%D in (*) do (
    set "FOUND_DIR=%%~fD"
    goto :Found
)
:Found
cd ..

if "%FOUND_DIR%"=="" (
    echo [ERROR] Zip file is empty or corrupted.
    pause
    exit /b
)

:: 3. УСТАНОВКА (Installing)
echo [3/3] Installing mods and configs...

:: Удаляем старые папки и ставим новые
if exist "%FOUND_DIR%\mods" (
    if exist "mods" rmdir /s /q "mods"
    xcopy "%FOUND_DIR%\mods" "mods\" /E /I /Y /Q > nul
    echo - Mods updated.
)

if exist "%FOUND_DIR%\config" (
    if exist "config" rmdir /s /q "config"
    xcopy "%FOUND_DIR%\config" "config\" /E /I /Y /Q > nul
    echo - Configs updated.
)

:: Очистка мусора
del %ZIP_FILE%
rmdir /s /q %TEMP_DIR%

echo.
echo [SUCCESS] Update finished!
pause