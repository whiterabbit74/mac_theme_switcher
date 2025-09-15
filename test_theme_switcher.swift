#!/usr/bin/env swift

import Foundation

// Тестовая версия переключателя тем
enum Theme: String {
    case light = "light"
    case dark = "dark"

    var iconName: String {
        switch self {
        case .light: return "🌞"
        case .dark: return "🌙"
        }
    }
}

class ThemeSwitcher {
    private var currentTheme: Theme = .light

    init() {
        setupCurrentTheme()
    }

    func setupCurrentTheme() {
        // Проверяем текущую тему через defaults
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", "-g", "AppleInterfaceStyle"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            currentTheme = output == "Dark" ? .dark : .light
            print("Текущая тема: \(currentTheme.rawValue) \(currentTheme.iconName)")
        } catch {
            print("Ошибка при определении темы: \(error)")
        }
    }

    func toggleTheme() {
        let newTheme = currentTheme == .light ? Theme.dark : Theme.light
        print("Переключаю на: \(newTheme.rawValue) \(newTheme.iconName)")

        // Переключаем тему через AppleScript
        let script = """
        tell application "System Events"
            tell appearance preferences
                set dark mode to \(newTheme == .dark ? "true" : "false")
            end tell
        end tell
        """

        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                currentTheme = newTheme
                print("✅ Тема успешно переключена!")
            } else {
                print("❌ Ошибка переключения темы")
                showHelp()
            }
        } catch {
            print("❌ Ошибка выполнения AppleScript: \(error)")
            showHelp()
        }
    }

    func showHelp() {
        print("\n🔧 Для исправления:")
        print("1. Системные настройки → Безопасность → Доступность")
        print("2. Найдите ThemeSwitcher и дайте разрешение")
        print("3. Или используйте: tccutil reset AppleEvents com.example.ThemeSwitcher")
    }
}

// Основная логика
let switcher = ThemeSwitcher()

print("🎨 ThemeSwitcher - тестовая версия")
print("===================================")
print("Команды:")
print("  t - переключить тему")
print("  s - показать текущую тему")
print("  h - помощь")
print("  q - выход")
print("")

while true {
    print("> ", terminator: "")
    guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
        continue
    }

    switch input {
    case "t", "toggle":
        switcher.toggleTheme()
    case "s", "status":
        switcher.setupCurrentTheme()
    case "h", "help":
        print("🎯 Доступные команды:")
        print("  t - переключить тему")
        print("  s - показать текущую тему")
        print("  q - выход")
    case "q", "quit", "exit":
        print("👋 До свидания!")
        exit(0)
    default:
        print("❓ Неизвестная команда. Введите 'h' для помощи")
    }

    print("")
}
