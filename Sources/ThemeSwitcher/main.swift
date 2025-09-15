import Foundation
import AppKit

// MARK: - Theme Manager
class ThemeManager {
    static let shared = ThemeManager()

    private init() {}

    func getCurrentTheme() -> String {
        // Используем NSAppearance для определения текущей темы
        if let appearance = NSApp?.effectiveAppearance {
            return appearance.name == .darkAqua ? "dark" : "light"
        }

        // Fallback для тестового окружения или когда NSApp недоступен
        if #available(macOS 10.14, *) {
            return NSAppearance.currentDrawing().name == .darkAqua ? "dark" : "light"
        }

        return "light" // fallback по умолчанию
    }

    func toggleTheme() {
        let script = "tell application \"System Events\" to tell appearance preferences to set dark mode to not dark mode"
        var error: NSDictionary?

        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if error != nil {
                print("Error toggling theme: \(error!)")
            } else {
                print("Theme toggled successfully")
            }
        } else {
            print("Failed to create AppleScript")
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
            NSColor.white.set()
            let moonPath = NSBezierPath()
            moonPath.appendArc(withCenter: NSPoint(x: 9, y: 9), radius: 7, startAngle: -90, endAngle: 270)
            moonPath.appendArc(withCenter: NSPoint(x: 12, y: 6), radius: 4, startAngle: 90, endAngle: 270, clockwise: true)
            moonPath.fill()
        } else {
            // Солнце для светлой темы
            NSColor.yellow.set()
            let sunPath = NSBezierPath()
            sunPath.appendArc(withCenter: NSPoint(x: 9, y: 9), radius: 6, startAngle: 0, endAngle: 360)

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
        image.isTemplate = false
        return image
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
        contentView.addSubview(themeLabel)

        // Кнопка переключения темы
        let toggleButton = NSButton(frame: NSRect(x: 150, y: 90, width: 100, height: 30))
        toggleButton.title = "Переключить"
        toggleButton.bezelStyle = .rounded
        toggleButton.target = self
        toggleButton.action = #selector(toggleThemeFromSettings)
        contentView.addSubview(toggleButton)

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
        ThemeManager.shared.toggleTheme()
        // Обновляем отображение темы в окне настроек
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateThemeDisplay()
        }
    }

    private func updateThemeDisplay() {
        guard let contentView = window?.contentView else { return }

        // Находим label с текущей темой и обновляем его
        for subview in contentView.subviews {
            if let label = subview as? NSTextField,
               label.stringValue.contains("Текущая тема:") {
                let currentTheme = ThemeManager.shared.getCurrentTheme()
                label.stringValue = "Текущая тема: \(currentTheme == "dark" ? "🌙 Тёмная" : "☀️ Светлая")"
                break
            }
        }
    }
}

// MARK: - Status Bar Controller
class StatusBarController {
    private var statusItem: NSStatusItem!
    private let themeManager = ThemeManager.shared
    private var settingsWindowController: SettingsWindowController?

    init() {
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = themeManager.createIcon(for: themeManager.getCurrentTheme())
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(leftClickAction)
            button.target = self
            button.toolTip = "ThemeSwitcher - Левый клик: переключить тему, Правый клик: настройки"

            // Настройка отправки действий для разных типов кликов
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Добавляем обработку правого клика
        let rightClickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(rightClickAction(_:)))
        rightClickRecognizer.buttonMask = 0x2 // Правый клик
        rightClickRecognizer.numberOfClicksRequired = 1
        statusItem.button?.addGestureRecognizer(rightClickRecognizer)

        // Наблюдатель за изменением темы
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(themeChanged),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )

        updateIcon()
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

    @objc private func leftClickAction() {
        // Левый клик - переключаем тему
        let event = NSApp.currentEvent
        if event?.type == .leftMouseUp {
            print("Левый клик - переключение темы")
            themeManager.toggleTheme()
            // Обновляем иконку после переключения
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updateIcon()
            }
        }
    }

    @objc private func toggleThemeAction() {
        themeManager.toggleTheme()
        // Обновляем иконку после переключения темы
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateIcon()
        }
    }

    @objc private func themeChanged() {
        updateIcon()
    }

    private func updateIcon() {
        let currentTheme = themeManager.getCurrentTheme()
        if let button = statusItem.button {
            button.image = themeManager.createIcon(for: currentTheme)
        }
    }


    @objc private func rightClickAction(_ sender: NSClickGestureRecognizer) {
        print("Правый клик - показ меню")
        // Создаём меню для правого клика
        let menu = createRightClickMenu()

        // Показываем меню в позиции статус айтема
        let event = NSApp.currentEvent
        let point = statusItem.button?.convert(event?.locationInWindow ?? .zero, from: nil) ?? .zero
        menu.popUp(positioning: nil, at: point, in: statusItem.button)
    }

    @objc private func showSettingsAction() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }

        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAboutAction() {
        let alert = NSAlert()
        alert.messageText = "ThemeSwitcher"
        alert.informativeText = "Простое приложение для переключения темы macOS\n\nВерсия: 1.0\n\nЛевый клик - переключение темы\nПравый клик - меню настроек"
        alert.alertStyle = .informational
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
