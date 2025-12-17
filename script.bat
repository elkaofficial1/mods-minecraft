@echo off
chcp 65001 > nul
setlocal

:: ================= НАСТРОЙКИ =================
:: Укажите имя пользователя GitHub
set GITHUB_USER=elkaofficial1
:: Укажите название репозитория
set REPO_NAME=mods-minecraft
:: Укажите ветку (обычно main или master)
set BRANCH=main
:: =============================================

echo [INFO] Начинаем обновление сборки...
echo [INFO] Источник: github.com/%GITHUB_USER%/%REPO_NAME%

:: 1. Ссылка на скачивание ZIP-архива
set DOWNLOAD_URL=https://github.com/%GITHUB_USER%/%REPO_NAME%/archive/refs/heads/%BRANCH%.zip
set ZIP_FILE=update.zip
set TEMP_DIR=temp_update

:: 2. Скачивание архива
echo [STEP 1/4] Скачивание файлов...
powershell -Command "Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%'"
if not exist %ZIP_FILE% (
    echo [ERROR] Не удалось скачать файл. Проверьте настройки скрипта и интернет.
    pause
    exit /b
)

:: 3. Распаковкаб
echo [STEP 2/4] Распаковка архива...
if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_DIR%' -Force"

:: Вычисляем имя папки внутри архива (обычно RepoName-branch)
set EXTRACTED_FOLDER=%TEMP_DIR%\%REPO_NAME%-%BRANCH%

:: 4. Установка файлов (Удаление старых и копирование новых)
echo [STEP 3/4] Обновление файлов...

:: --- Оработка папки MODS ---
if exist "mods" (
    echo [INFO] Очистка старой папки mods...
    rmdir /s /q "mods"
)
if exist "%EXTRACTED_FOLDER%\mods" (
    echo [INFO] Копирование новых модов...
    xcopy "%EXTRACTED_FOLDER%\mods" "mods\" /E /I /Y /Q
) else (
    echo [WARNING] Папка mods не найдена в репозитории!
)

:: --- Обработка папки CONFIG ---
if exist "config" (
    echo [INFO] Очистка старой папки config...
    rmdir /s /q "config"
)
if exist "%EXTRACTED_FOLDER%\config" (
    echo [INFO] Копирование новых конфигов...
    xcopy "%EXTRACTED_FOLDER%\config" "config\" /E /I /Y /Q
) else (
    echo [WARNING] Папка config не найдена в репозитории!
)

:: 5. Очистка мусора
echo [STEP 4/4] Удаление временных файлов...
del %ZIP_FILE%
rmdir /s /q %TEMP_DIR%

echo.
echo [SUCCESS] Сборка успешно обновлена!
pause