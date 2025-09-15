# Makefile для сборки ThemeSwitcher без Xcode

.PHONY: build run run-debug test clean permissions setup install help

# Компиляция проекта
build:
	@echo "🔨 Сборка ThemeSwitcher..."
	swift build --configuration release

# Запуск приложения
run: build
	@echo "🚀 Запуск ThemeSwitcher..."
	./.build/release/ThemeSwitcher

# Запуск в режиме разработки
run-debug:
	@echo "🐛 Запуск ThemeSwitcher в режиме разработки..."
	swift run

# Запуск тестов
test:
	@echo "🧪 Запуск тестов..."
	swift test

# Очистка
clean:
	@echo "🧹 Очистка..."
	swift package clean
	rm -rf .build

# Установка прав для AppleScript
permissions:
	@echo "🔑 Сброс прав для AppleScript..."
	tccutil reset AppleEvents
	@echo "Права сброшены. При следующем запуске будет запрошено разрешение."

# Настройка прав через скрипт
setup:
	@echo "🔧 Запуск скрипта настройки прав..."
	./setup_permissions.sh

# Полная установка
install: clean build
	@echo "✅ ThemeSwitcher готов к использованию!"
	@echo "Запустите 'make run' для запуска приложения"

# Справка
help:
	@echo "ThemeSwitcher - Makefile команды:"
	@echo "  build      - Собрать приложение"
	@echo "  run        - Собрать и запустить приложение"
	@echo "  run-debug  - Запустить в режиме разработки"
	@echo "  test       - Запустить тесты"
	@echo "  clean      - Очистить сборку"
	@echo "  permissions- Сбросить права AppleScript"
	@echo "  setup      - Настройка прав через скрипт"
	@echo "  install    - Полная установка"
	@echo "  help       - Показать эту справку"
