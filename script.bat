Да, так даже проще! Давай сделаем так, чтобы тебе нужно было вставить **только ссылку на репозиторий**.

Вот максимально упрощенный скрипт.

### Инструкция:
1.  Открой страницу своего репозитория на GitHub.
2.  Скопируй ссылку из адресной строки браузера (она должна выглядеть как `https://github.com/Ник/Название`).
3.  Вставь её в скрипт ниже в поле `REPO_URL`.

**Важное условие:** Твоя основная ветка на GitHub должна называться `main`. Если она называется `master`, поменяй значение во второй строчке.

### Код (update_v3.bat)

```batch
@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ================================================================
:: ВСТАВЬ СЮДА ССЫЛКУ НА РЕПОЗИТОРИЙ:
set "REPO_URL=https://github.com/elkaofficial1/mods-minecraft"

:: Если ветка называется master, замени main на master
set "BRANCH=main"
:: ================================================================

:: Формируем правильную ссылку на скачивание
:: Удаляем слеш в конце ссылки, если он есть, чтобы не было двойных слешей
if "%REPO_URL:~-1%"=="/" set "REPO_URL=%REPO_URL:~0,-1%"
set "DOWNLOAD_URL=%REPO_URL%/archive/refs/heads/%BRANCH%.zip"

set "ZIP_FILE=update_pkg.zip"
set "TEMP_DIR=temp_update_folder"

echo.
echo [INFO] Обновление сборки...
echo [INFO] Источник: %REPO_URL%

:: 1. СКАЧИВАНИЕ
echo.
echo [1/3] Скачивание файлов...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' } catch { exit 1 }"

if not exist %ZIP_FILE% (
    echo.
    echo [ERROR] Не удалось скачать файл!
    echo Проверьте:
    echo 1. Ссылка верная? (она не должна вести на конкретный файл, только на главную)
    echo 2. Репозиторий Публичный? (Public)
    echo 3. Ветка называется '%BRANCH%'?
    pause
    exit /b
)

:: Проверка на "битый" файл (ошибка 404)
for %%F in (%ZIP_FILE%) do set size=%%~zF
if %size% LSS 1000 (
    echo.
    echo [ERROR] Файл скачался, но он слишком маленький.
    echo Скорее всего ссылка неверная или репоз��торий закрыт.
    del %ZIP_FILE%
    pause
    exit /b
)

:: 2. РАСПАКОВКА И ПОИСК
echo.
echo [2/3] Распаковка...
if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_DIR%' -Force"

:: Магия: ищем папку внутри архива (GitHub всегда создает папку вида Repo-main)
cd %TEMP_DIR%
set "FOUND_DIR="
for /d %%D in (*) do (
    set "FOUND_DIR=%%~fD"
    goto :Found
)
:Found
cd ..

if "!FOUND_DIR!"=="" (
    echo [ERROR] Архив пустой или ошибка распаковки.
    pause
    exit /b
)

:: 3. УСТАНОВКА
echo.
echo [3/3] Замена файлов...

:: --- MODS ---
if exist "!FOUND_DIR!\mods" (
    echo    - Обновляем моды...
    if exist "mods" rmdir /s /q "mods"
    xcopy "!FOUND_DIR!\mods" "mods\" /E /I /Y /Q > nul
) else (
    echo    [!] Папка mods не найдена в репозитории. Пропускаем.
)

:: --- CONFIG ---
if exist "!FOUND_DIR!\config" (
    echo    - Обновляем конфиги...
    if exist "config" rmdir /s /q "config"
    xcopy "!FOUND_DIR!\config" "config\" /E /I /Y /Q > nul
) else (
    echo    [!] Папка config не найдена в репозитории. Пропускаем.
)

:: ОЧИСТКА
del %ZIP_FILE%
rmdir /s /q %TEMP_DIR%

echo.
echo [OK] Готово! Можно играть.
pause
```

### Если всё равно не работает:
1.  Убедись, что репозиторий **Public** (в настройках репо -> General -> внизу Danger Zone -> Change visibility -> должно быть Public).
2.  Посмотри, как называется ветка слева сверху на сайте GitHub (написано `main` или `master`?). Если `master`, поменяй в скрипте `set "BRANCH=main"` на `set "BRANCH=master"`.