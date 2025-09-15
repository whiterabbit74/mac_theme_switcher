#!/bin/bash

# Скрипт настройки прав для ThemeSwitcher
# Запустите этот скрипт если у вас проблемы с доступом к AppleScript

echo "🔑 Настройка прав для ThemeSwitcher..."
echo ""

# Проверяем что приложение существует
if [ ! -f "./.build/release/ThemeSwitcher" ]; then
    echo "❌ Приложение не найдено. Сначала выполните 'make build'"
    exit 1
fi

# Даём права на выполнение
chmod +x ./.build/release/ThemeSwitcher

# Запускаем приложение для запроса прав
echo "🚀 Запуск ThemeSwitcher для запроса прав..."
echo "Когда появится диалог запроса прав, нажмите 'OK' или 'Разрешить'"
echo "После этого закройте приложение (Cmd+Q) и запустите снова"
echo ""

./.build/release/ThemeSwitcher

echo ""
echo "✅ Настройка завершена!"
echo "Теперь перезапустите приложение: make run"
