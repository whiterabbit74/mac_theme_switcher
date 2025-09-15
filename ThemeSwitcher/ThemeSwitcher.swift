//
//  ThemeSwitcher.swift
//  ThemeSwitcher
//
//  Created by ThemeSwitcher on 2024
//

import Cocoa

enum Theme: String {
    case light = "light"
    case dark = "dark"

    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var appearanceName: String {
        switch self {
        case .light: return "NSAppearanceNameAqua"
        case .dark: return "NSAppearanceNameDarkAqua"
        }
    }
}

class ThemeSwitcher {

    private let statusBarItem: NSStatusItem
    private let notificationCenter = DistributedNotificationCenter.default()
    private var currentTheme: Theme = .light

    init(statusBarItem: NSStatusItem) {
        self.statusBarItem = statusBarItem
        setupCurrentTheme()
        updateIcon()

        // Подписываемся на системные изменения темы
        notificationCenter.addObserver(
            self,
            selector: #selector(themeChanged(_:)),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    func toggleTheme() {
        let newTheme = currentTheme == .light ? Theme.dark : Theme.light

        // Переключаем системную тему через AppleScript
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
                updateIcon()
            } else {
                print("Failed to toggle theme")
                showErrorAlert()
            }
        } catch {
            print("Error running AppleScript: \(error)")
            showErrorAlert()
        }
    }

    func cleanup() {
        notificationCenter.removeObserver(self)
    }

    @objc private func themeChanged(_ notification: Notification) {
        setupCurrentTheme()
        updateIcon()
    }

    private func setupCurrentTheme() {
        // Определяем текущую тему через NSAppearance
        if let appearance = NSApp.effectiveAppearance.name {
            currentTheme = appearance == .darkAqua ? .dark : .light
        } else {
            // Fallback: проверяем через defaults
            currentTheme = isDarkModeEnabled() ? .dark : .light
        }
    }

    private func isDarkModeEnabled() -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", "-g", "AppleInterfaceStyle"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                return output == "Dark"
            }
        } catch {
            print("Error checking dark mode: \(error)")
        }

        return false
    }

    private func updateIcon() {
        DispatchQueue.main.async {
            let image = NSImage(systemSymbolName: self.currentTheme.iconName,
                              accessibilityDescription: self.currentTheme.rawValue)
            image?.isTemplate = true
            self.statusBarItem.button?.image = image
        }
    }

    private func showErrorAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Ошибка переключения темы"
            alert.informativeText = "Не удалось изменить системную тему. Проверьте права доступа к системным настройкам."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
