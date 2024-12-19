#!/bin/bash

# Параметры
REPO_URL="https://github.com/VN351/shvirtd-example-python.git" # URL репозитория
TARGET_DIR="/opt/project"                                      # Каталог для загрузки репозитория
BRANCH="main"                                                  # Ветка репозитория

# Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами суперпользователя (sudo)."
  exit 1
fi

# Установка необходимых пакетов
echo "Устанавливаем необходимые пакеты..."
apt-get update && apt-get install -y git docker || {
  echo "Не удалось установить зависимости."
  exit 1
}

# Запуск Docker службы
echo "Запускаем службу Docker..."
systemctl start docker || {
  echo "Не удалось запустить службу Docker."
  exit 1
}

# Клонирование репозитория
echo "Клонируем репозиторий $REPO_URL в $TARGET_DIR..."
rm -rf "$TARGET_DIR" # Удаляем старую версию, если она существует
git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" || {
  echo "Ошибка при клонировании репозитория."
  exit 1
}

# Переход в каталог проекта
cd "$TARGET_DIR" || {
  echo "Не удалось перейти в каталог $TARGET_DIR."
  exit 1
}

# Запуск проекта
echo "Запускаем проект..."
if [ -f "docker-compose.yml" ] || [ -f "compose.yml" ]; then
  echo "Обнаружен файл docker-compose.yml. Запускаем проект с помощью Docker Compose..."
  docker compose -f compose.yaml up --build || {
    echo "Ошибка при запуске Docker Compose."
    exit 1
  }
elif [ -f "Dockerfile" ]; then
  echo "Обнаружен файл Dockerfile. Собираем Docker-образ и запускаем контейнер..."
  # Сборка Docker-образа
  docker build -t myapp:latest . || {
    echo "Ошибка при сборке Docker-образа."
    exit 1
  }
  # Запуск контейнера
  docker run -d -p 8000:8000 myapp:latest || {
    echo "Ошибка при запуске Docker-контейнера."
    exit 1
  }
else
  echo "Не удалось определить способ запуска проекта. Проверьте документацию вашего репозитория."
  exit 1
fi

echo "Проект успешно запущен!"