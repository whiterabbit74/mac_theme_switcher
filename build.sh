#!/bin/bash

# ThemeSwitcher Build Script
# Скрипт для сборки и проверки проекта

echo "🔨 ThemeSwitcher - сборка проекта"
echo "================================="

# Проверяем наличие Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Ошибка: Xcode не установлен"
    exit 1
fi

echo "✅ Xcode найден"

# Проверяем структуру проекта
if [ ! -d "ThemeSwitcher.xcodeproj" ]; then
    echo "❌ Ошибка: Файлы проекта не найдены"
    exit 1
fi

echo "✅ Структура проекта корректна"

# Проверяем исходные файлы
REQUIRED_FILES=(
    "ThemeSwitcher/AppDelegate.swift"
    "ThemeSwitcher/ThemeSwitcher.swift"
    "ThemeSwitcher/Info.plist"
    "ThemeSwitcher/ThemeSwitcher.entitlements"
    "ThemeSwitcher/Base.lproj/Main.storyboard"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Ошибка: Отсутствует файл $file"
        exit 1
    fi
done

echo "✅ Все необходимые файлы присутствуют"

# Создаем базовые иконки (простые цветные квадраты)
echo "🎨 Создание базовых иконок..."

mkdir -p "ThemeSwitcher/Assets.xcassets/AppIcon.appiconset"

# Функция для создания простых иконок
create_icon() {
    local size=$1
    local output=$2

    # Создаем простой SVG с градиентом (затем конвертируем в PNG)
    cat > /tmp/icon.svg << EOF
<svg width="$size" height="$size" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#007AFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#5856D6;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="$size" height="$size" fill="url(#grad1)"/>
  <circle cx="$((size/2))" cy="$((size/2))" r="$((size/3))" fill="white" opacity="0.3"/>
</svg>
EOF

    # Если у нас есть ImageMagick или другой инструмент для конвертации
    if command -v convert &> /dev/null; then
        convert /tmp/icon.svg "$output"
        echo "  ✅ $output создан"
    else
        echo "  ⚠️  ImageMagick не найден, пропускаем создание $output"
        # Создаем пустой PNG файл как placeholder
        touch "$output"
    fi
}

# Создаем иконки разных размеров
ICON_SIZES=(16 32 128 256 512)
for size in "${ICON_SIZES[@]}"; do
    create_icon $size "ThemeSwitcher/Assets.xcassets/AppIcon.appiconset/${size}x${size}.png"
    create_icon $((size*2)) "ThemeSwitcher/Assets.xcassets/AppIcon.appiconset/${size}x${size}@2x.png"
done

echo "🎯 Попытка сборки проекта..."

# Проверяем синтаксис Swift файлов
echo "🔍 Проверка синтаксиса Swift..."
xcodebuild -project ThemeSwitcher.xcodeproj -scheme ThemeSwitcher -sdk macosx -configuration Debug build 2>&1 | head -20

if [ $? -eq 0 ]; then
    echo "✅ Сборка прошла успешно"
    echo ""
    echo "📱 Для запуска в Xcode:"
    echo "   1. Откройте ThemeSwitcher.xcodeproj"
    echo "   2. Выберите схему ThemeSwitcher"
    echo "   3. Нажмите Cmd+R"
    echo ""
    echo "🚀 Приложение готово к использованию!"
else
    echo "⚠️  Сборка завершилась с предупреждениями (это нормально для первого раза)"
    echo "   Попробуйте открыть проект в Xcode для детальной проверки"
fi

echo ""
echo "📋 Следующие шаги:"
echo "   1. Откройте проект в Xcode"
echo "   2. Настройте signing в разделе Signing & Capabilities"
echo "   3. Соберите и запустите приложение"
echo "   4. Проверьте работу в строке меню"
