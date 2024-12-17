#!/bin/bash

# Параметры
REPO_URL="https://github.com/VN351/shvirtd-example-python.git" # Укажите URL вашего форк-репозитория
TARGET_DIR="/opt"                               # Каталог для загрузки репозитория
BRANCH="main"                                             # Ветка репозитория (например, main или master)

# Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами суперпользователя (sudo)."
  exit 1
fi

# Установка необходимых пакетов (если не установлены)
#echo "Устанавливаем необходимые пакеты..."
#apt-get update
#apt-get install -y git docker || { echo "Не удалось установить зависимости."; exit 1; }

# Клонирование репозитория
echo "Клонируем репозиторий $REPO_URL в $TARGET_DIR..."
if [ -d "$TARGET_DIR" ]; then
  echo "Каталог $TARGET_DIR уже существует. Удаляем старую версию..."
  rm -rf "$TARGET_DIR"
fi

git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" || { echo "Ошибка при клонировании репозитория."; exit 1; }

# Переход в каталог проекта
cd "$TARGET_DIR" || { echo "Не удалось перейти в каталог $TARGET_DIR."; exit 1; }

# Запуск проекта
echo "Запускаем проект..."
if [ -f "compose.yml" ]; then
  echo "Обнаружен файл docker-compose.yml. Запускаем проект с помощью Docker Compose..."
   docker compose up --build || { echo "Ошибка при запуске Docker Compose."; exit 1; }
elif [ -f "package.json" ]; then
  echo "Обнаружен файл package.json. Устанавливаем зависимости и запускаем проект через npm..."
  npm install && npm start || { echo "Ошибка при запуске проекта через npm."; exit 1; }
elif [ -f "Makefile" ]; then
  echo "Обнаружен Makefile. Запускаем проект через make..."
  make || { echo "Ошибка при запуске проекта через make."; exit 1; }
else
  echo "Не удалось определить способ запуска проекта. Проверьте документацию вашего репозитория."
  exit 1
fi

echo "Проект успешно запущен!"
