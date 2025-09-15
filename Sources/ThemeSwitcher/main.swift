import Foundation
import AppKit

// MARK: - Theme Manager
class ThemeManager {
    static let shared = ThemeManager()

    private init() {}

    // MARK: - Permission Checking
    private func checkAppleScriptPermission() -> Bool {
        let script = "tell application \"System Events\" to get dark mode of appearance preferences"
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?

        let result = appleScript?.executeAndReturnError(&error)
        return error == nil && result != nil
    }

    private func requestAppleScriptPermission() {
        let alert = NSAlert()
        alert.messageText = "Нужны разрешения"
        alert.informativeText = "ThemeSwitcher требует доступ к System Events для переключения темы.\n\nПерейдите в:\nСистемные настройки → Безопасность → Конфиденциальность → Автоматизация\n\nИ разрешите доступ к \"System Events\""
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Понятно")
        alert.addButton(withTitle: "Открыть настройки")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            // Открываем настройки безопасности
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
            NSWorkspace.shared.open(url)
        }
    }

    func getCurrentTheme() -> String {
        // Используем NSAppearance для определения текущей темы
        if let appearance = NSApp?.effectiveAppearance {
            return appearance.name == .darkAqua ? "dark" : "light"
        }

        // Fallback через AppleScript
        let script = "tell application \"System Events\" to get dark mode of appearance preferences"
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            let result = appleScript.executeAndReturnError(&error)
            if error == nil {
                return result.booleanValue ? "dark" : "light"
            }
        }

        return "light" // fallback по умолчанию
    }

    func toggleTheme(completion: @escaping (Bool, String?) -> Void) {
        // Проверяем разрешения сначала
        if !checkAppleScriptPermission() {
            DispatchQueue.main.async {
                self.requestAppleScriptPermission()
                completion(false, "Отсутствуют разрешения AppleScript")
            }
            return
        }

        // Выполняем переключение в фоновом потоке
        DispatchQueue.global(qos: .userInitiated).async {
            let script = "tell application \"System Events\" to tell appearance preferences to set dark mode to not dark mode"
            var error: NSDictionary?

            if let appleScript = NSAppleScript(source: script) {
                appleScript.executeAndReturnError(&error)

                DispatchQueue.main.async {
                    if let error = error {
                        let errorMessage = error["NSAppleScriptErrorMessage"] as? String ?? "Неизвестная ошибка"
                        print("Error toggling theme: \(errorMessage)")
                        completion(false, errorMessage)
                    } else {
                        print("Theme toggled successfully")
                        completion(true, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, "Не удалось создать AppleScript")
                }
            }
        }
    }

    func createIcon(for theme: String) -> NSImage? {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()

        // Очищаем фон
        NSColor.clear.set()
        NSRect(origin: .zero, size: size).fill()

        // Рисуем иконку
        let context = NSGraphicsContext.current?.cgContext
        context?.setLineWidth(2.0)
        context?.setLineCap(.round)

        if theme == "dark" {
            // Луна для тёмной темы
            NSColor.controlAccentColor.set()
            let moonPath = NSBezierPath()
            moonPath.appendArc(withCenter: NSPoint(x: 9, y: 9), radius: 7, startAngle: -90, endAngle: 270)
            moonPath.appendArc(withCenter: NSPoint(x: 12, y: 6), radius: 4, startAngle: 90, endAngle: 270, clockwise: true)
            moonPath.fill()
        } else {
            // Солнце для светлой темы
            NSColor.controlAccentColor.set()
            let sunPath = NSBezierPath()
            sunPath.appendArc(withCenter: NSPoint(x: 9, y: 9), radius: 5, startAngle: 0, endAngle: 360)

            // Лучи солнца
            for i in 0..<8 {
                let angle = Double(i) * Double.pi / 4.0
                let startPoint = NSPoint(
                    x: 9 + cos(angle) * 7,
                    y: 9 + sin(angle) * 7
                )
                let endPoint = NSPoint(
                    x: 9 + cos(angle) * 9,
                    y: 9 + sin(angle) * 9
                )

                let rayPath = NSBezierPath()
                rayPath.move(to: startPoint)
                rayPath.line(to: endPoint)
                rayPath.stroke()
            }

            sunPath.fill()
        }

        image.unlockFocus()
        image.isTemplate = true // Делаем шаблонной для правильного отображения в menu bar
        return image
    }
}

// MARK: - Autostart Manager
class AutostartManager {
    static let shared = AutostartManager()

    private let launchAgentsPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents")
    private let plistFileName = "com.themeswitcher.app.plist"

    private init() {}

    var isEnabled: Bool {
        return FileManager.default.fileExists(atPath: plistFilePath.path)
    }

    private var plistFilePath: URL {
        return launchAgentsPath.appendingPathComponent(plistFileName)
    }

    private var applicationPath: String {
        return Bundle.main.executablePath ?? ""
    }

    func enable() -> Bool {
        do {
            // Создаем директорию если не существует
            try FileManager.default.createDirectory(at: launchAgentsPath, withIntermediateDirectories: true)

            // Создаем plist для автозапуска
            let plistContent = createPlistContent()
            let plistData = try PropertyListSerialization.data(fromPropertyList: plistContent, format: .xml, options: 0)

            try plistData.write(to: plistFilePath)

            print("Autostart enabled: \(plistFilePath.path)")
            return true
        } catch {
            print("Failed to enable autostart: \(error)")
            return false
        }
    }

    func disable() -> Bool {
        do {
            if FileManager.default.fileExists(atPath: plistFilePath.path) {
                try FileManager.default.removeItem(at: plistFilePath)
                print("Autostart disabled")
                return true
            }
            return true
        } catch {
            print("Failed to disable autostart: \(error)")
            return false
        }
    }

    private func createPlistContent() -> [String: Any] {
        return [
            "Label": "com.themeswitcher.app",
            "ProgramArguments": [applicationPath],
            "RunAtLoad": true,
            "KeepAlive": false,
            "ProcessType": "Interactive"
        ]
    }
}

// MARK: - Settings Window Controller
class SettingsWindowController: NSWindowController {

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Настройки ThemeSwitcher"
        window.center()
        window.isReleasedWhenClosed = false

        self.init(window: window)
        setupSettingsView()
    }

    private func setupSettingsView() {
        guard let window = window else { return }

        let contentView = NSView(frame: window.contentView?.bounds ?? NSRect.zero)
        contentView.wantsLayer = true

        // Заголовок
        let titleLabel = NSTextField(labelWithString: "ThemeSwitcher Настройки")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 240, width: 360, height: 30)
        contentView.addSubview(titleLabel)

        // Описание функций
        let descriptionLabel = NSTextField(wrappingLabelWithString: "Левый клик по иконке в меню - переключение темы\nПравый клик по иконке - открытие этого меню")
        descriptionLabel.font = NSFont.systemFont(ofSize: 12)
        descriptionLabel.alignment = .center
        descriptionLabel.frame = NSRect(x: 20, y: 180, width: 360, height: 40)
        contentView.addSubview(descriptionLabel)

        // Текущая тема
        let currentTheme = ThemeManager.shared.getCurrentTheme()
        let themeLabel = NSTextField(labelWithString: "Текущая тема: \(currentTheme == "dark" ? "🌙 Тёмная" : "☀️ Светлая")")
        themeLabel.font = NSFont.systemFont(ofSize: 14)
        themeLabel.alignment = .center
        themeLabel.frame = NSRect(x: 20, y: 130, width: 360, height: 25)
        themeLabel.tag = 100 // Для поиска при обновлении
        contentView.addSubview(themeLabel)

        // Кнопка переключения темы
        let toggleButton = NSButton(frame: NSRect(x: 150, y: 110, width: 100, height: 30))
        toggleButton.title = "Переключить"
        toggleButton.bezelStyle = .rounded
        toggleButton.target = self
        toggleButton.action = #selector(toggleThemeFromSettings)
        contentView.addSubview(toggleButton)

        // Checkbox для автозапуска
        let autostartCheckbox = NSButton(frame: NSRect(x: 50, y: 80, width: 300, height: 18))
        autostartCheckbox.setButtonType(.switch)
        autostartCheckbox.title = "Запускать автоматически при входе в систему"
        autostartCheckbox.state = AutostartManager.shared.isEnabled ? .on : .off
        autostartCheckbox.target = self
        autostartCheckbox.action = #selector(toggleAutostart(_:))
        autostartCheckbox.tag = 200 // Для поиска при обновлении
        contentView.addSubview(autostartCheckbox)

        // Информация о версии
        let versionLabel = NSTextField(labelWithString: "ThemeSwitcher v1.0")
        versionLabel.font = NSFont.systemFont(ofSize: 10)
        versionLabel.textColor = .secondaryLabelColor
        versionLabel.alignment = .center
        versionLabel.frame = NSRect(x: 20, y: 20, width: 360, height: 15)
        contentView.addSubview(versionLabel)

        window.contentView = contentView
    }

    @objc private func toggleThemeFromSettings() {
        ThemeManager.shared.toggleTheme { [weak self] success, error in
            if success {
                self?.updateThemeDisplay()
            } else if let error = error {
                self?.showError(error)
            }
        }
    }

    private func updateThemeDisplay() {
        guard let contentView = window?.contentView else { return }

        // Находим label с текущей темой по tag
        if let label = contentView.viewWithTag(100) as? NSTextField {
            let currentTheme = ThemeManager.shared.getCurrentTheme()
            label.stringValue = "Текущая тема: \(currentTheme == "dark" ? "🌙 Тёмная" : "☀️ Светлая")"
        }
    }

    @objc private func toggleAutostart(_ sender: NSButton) {
        let success: Bool
        if sender.state == .on {
            success = AutostartManager.shared.enable()
            if !success {
                sender.state = .off
                showError("Не удалось включить автозапуск")
            }
        } else {
            success = AutostartManager.shared.disable()
            if !success {
                sender.state = .on
                showError("Не удалось отключить автозапуск")
            }
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Ошибка переключения темы"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Status Bar Controller
class StatusBarController {
    private var statusItem: NSStatusItem!
    private let themeManager = ThemeManager.shared
    private var settingsWindowController: SettingsWindowController?
    private var themeObserver: NSObjectProtocol?

    init() {
        setupStatusBar()
    }

    deinit {
        // Proper cleanup
        if let observer = themeObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
        }
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateIcon()
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.toolTip = "ThemeSwitcher - Левый клик: переключить тему, Правый клик: настройки"

            // Настройка отправки действий для всех типов кликов
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Наблюдатель за изменением темы с proper cleanup
        themeObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.themeChanged()
        }

        print("ThemeSwitcher запущен! Иконка в меню баре.")
    }

    private func createRightClickMenu() -> NSMenu {
        let menu = NSMenu()

        // Информация о текущей теме
        let currentTheme = themeManager.getCurrentTheme()
        let themeInfo = NSMenuItem(title: "Текущая тема: \(currentTheme == "dark" ? "🌙 Тёмная" : "☀️ Светлая")", action: nil, keyEquivalent: "")
        themeInfo.isEnabled = false
        menu.addItem(themeInfo)

        // Разделитель
        menu.addItem(NSMenuItem.separator())

        // Переключить тему
        let toggleItem = NSMenuItem(title: "🎨 Переключить тему", action: #selector(toggleThemeAction), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        // Автозапуск
        let autostartItem = NSMenuItem(title: "🚀 Автозапуск", action: #selector(toggleAutostartAction), keyEquivalent: "")
        autostartItem.target = self
        autostartItem.state = AutostartManager.shared.isEnabled ? .on : .off
        menu.addItem(autostartItem)

        // Настройки
        let settingsItem = NSMenuItem(title: "⚙️ Настройки...", action: #selector(showSettingsAction), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Разделитель
        menu.addItem(NSMenuItem.separator())

        // О программе
        let aboutItem = NSMenuItem(title: "ℹ️ О программе", action: #selector(showAboutAction), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        // Разделитель
        menu.addItem(NSMenuItem.separator())

        // Выход
        let quitItem = NSMenuItem(title: "❌ Выход", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        switch event.type {
        case .leftMouseUp:
            print("Левый клик - переключение темы")
            handleLeftClick()

        case .rightMouseUp:
            print("Правый клик - показ меню")
            handleRightClick()

        default:
            break
        }
    }

    private func handleLeftClick() {
        // Показываем индикатор загрузки
        if let button = statusItem.button {
            button.isEnabled = false
        }

        themeManager.toggleTheme { [weak self] success, error in
            // Восстанавливаем кнопку
            if let button = self?.statusItem.button {
                button.isEnabled = true
            }

            if success {
                // Обновляем иконку только после успешного переключения
                self?.updateIcon()
            } else if let error = error {
                self?.showError("Ошибка переключения темы", error)
            }
        }
    }

    private func handleRightClick() {
        let menu = createRightClickMenu()
        // Используем современный способ показа меню
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func toggleThemeAction() {
        handleLeftClick() // Используем ту же логику
    }

    @objc private func themeChanged() {
        // Обновляем иконку при системном изменении темы
        updateIcon()
    }

    private func updateIcon() {
        let currentTheme = themeManager.getCurrentTheme()
        if let button = statusItem.button {
            button.image = themeManager.createIcon(for: currentTheme)
        }
    }

    @objc private func showSettingsAction() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }

        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func toggleAutostartAction() {
        let success: Bool
        if AutostartManager.shared.isEnabled {
            success = AutostartManager.shared.disable()
            if success {
                showNotification("Автозапуск отключен")
            } else {
                showError("Ошибка автозапуска", "Не удалось отключить автозапуск")
            }
        } else {
            success = AutostartManager.shared.enable()
            if success {
                showNotification("Автозапуск включен")
            } else {
                showError("Ошибка автозапуска", "Не удалось включить автозапуск")
            }
        }
    }

    @objc private func showAboutAction() {
        let alert = NSAlert()
        alert.messageText = "ThemeSwitcher"
        alert.informativeText = "Простое приложение для переключения темы macOS\n\nВерсия: 1.0\n\nЛевый клик - переключение темы\nПравый клик - меню настроек"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showNotification(_ message: String) {
        // Простое уведомление через tooltip
        if let button = statusItem.button {
            let originalTooltip = button.toolTip
            button.toolTip = message

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                button.toolTip = originalTooltip
            }
        }
    }

    private func showError(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Убираем приложение из Dock
        NSApp.setActivationPolicy(.accessory)

        // Создаём контроллер статус бара
        statusBarController = StatusBarController()

        print("ThemeSwitcher запущен! Иконка в меню баре.")
        print("Нажмите Cmd+Q для выхода или используйте меню.")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("ThemeSwitcher завершён.")
    }
}

// MARK: - Main Function
func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate

    // Запуск приложения
    app.run()
}

// Запуск приложения
main()