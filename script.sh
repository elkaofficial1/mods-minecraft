#!/bin/bash

# ================= НАСТРОЙКИ =================
# Вставь ссылку на репозиторий (без .git в конце)
REPO_URL="https://github.com/elkaofficial1/mods-minecraft"

# Ветка (обычно main или master)
BRANCH="main"
# =============================================

# Цвета для красоты вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[INFO] Начинаем обновление сборки...${NC}"

# Проверка наличия unzip и curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}[ERROR] curl не установлен. Установите его (sudo apt install curl)${NC}"
    exit 1
fi
if ! command -v unzip &> /dev/null; then
    echo -e "${RED}[ERROR] unzip не установлен. Установите его (sudo apt install unzip)${NC}"
    exit 1
fi

# Подготовка ссылок и имен
# Убираем слеш в конце, если есть
REPO_URL=${REPO_URL%/}
DOWNLOAD_URL="$REPO_URL/archive/refs/heads/$BRANCH.zip"
ZIP_FILE="update_pkg.zip"
TEMP_DIR="temp_update_folder"

# 1. СКАЧИВАНИЕ
echo "[1/3] Скачивание архива..."
# -L нужен чтобы следовать по редиректам GitHub, -f чтобы падать при ошибках (404)
curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL" --fail

if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}[ERROR] Не удалось скачать файл. Проверьте ссылку и интернет.${NC}"
    exit 1
fi

# Проверка размера (защита от пустых файлов или ошибок html)
FILESIZE=$(stat -c%s "$ZIP_FILE")
if [ "$FILESIZE" -lt 1000 ]; then
    echo -e "${RED}[ERROR] Файл слишком маленький. Вероятно, ошибка в ссылке или приватный репозиторий.${NC}"
    rm "$ZIP_FILE"
    exit 1
fi

# 2. РАСПАКОВКА
echo "[2/3] Распаковка..."
# Удаляем временную папку если она осталась с прошлого раза
rm -rf "$TEMP_DIR"
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

# Находим папку внутри (обычно RepoName-main)
FOUND_DIR=$(ls "$TEMP_DIR" | head -n 1)
FULL_PATH="$TEMP_DIR/$FOUND_DIR"

if [ -z "$FOUND_DIR" ]; then
    echo -e "${RED}[ERROR] Архив пуст или ошибка распаковки.${NC}"
    exit 1
fi

# 3. УСТАНОВКА
echo "[3/3] Замена файлов..."

# --- MODS ---
if [ -d "$FULL_PATH/mods" ]; then
    echo " -> Обновляем mods..."
    rm -rf mods
    cp -r "$FULL_PATH/mods" .
else
    echo " [!] Папка mods не найдена в репозитории."
fi

# --- CONFIG ---
if [ -d "$FULL_PATH/config" ]; then
    echo " -> Обновляем config..."
    rm -rf config
    cp -r "$FULL_PATH/config" .
else
    echo " [!] Папка config не найдена в репозитории."
fi

# Очистка мусора
rm "$ZIP_FILE"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}[SUCCESS] Обновление завершено!${NC}"