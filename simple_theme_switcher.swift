#!/usr/bin/env swift
import Foundation
import AppKit

// MARK: - Extensions
extension Notification.Name {
    static let iconStyleChanged = Notification.Name("IconStyleChanged")
}

// MARK: - Icon Style
enum IconStyle: String, CaseIterable {
    case realistic = "Реалистичные"
    case monochrome = "Монохромные"
    case minimal = "Минималистичные"
    case classic = "Классические"

    var description: String { rawValue }
}

// MARK: - Icon Set Manager
class IconSetManager {
    static let shared = IconSetManager()

    private init() {
        loadSettings()
    }

    var currentIconStyle: IconStyle = .realistic {
        didSet {
            saveSettings()
            NotificationCenter.default.post(name: .iconStyleChanged, object: nil)
        }
    }

    private func loadSettings() {
        if let savedStyle = UserDefaults.standard.string(forKey: "ThemeSwitcherIconStyle"),
           let style = IconStyle(rawValue: savedStyle) {
            currentIconStyle = style
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(currentIconStyle.rawValue, forKey: "ThemeSwitcherIconStyle")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Theme Manager
class ThemeManager {
    static let shared = ThemeManager()

    private init() {}

    func getCurrentTheme() -> String {
        if let appearance = NSApp?.effectiveAppearance {
            return appearance.name == .darkAqua ? "dark" : "light"
        }
        return "light"
    }

    func toggleTheme() {
        let script = "tell application \"System Events\" to tell appearance preferences to set dark mode to not dark mode"
        var error: NSDictionary?

        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if error != nil {
                print("❌ Нет прав для переключения темы!")
                print("📝 Чтобы получить права:")
                print("   1. Откройте Системные настройки")
                print("   2. Перейдите в Безопасность → Конфиденциальность → Автоматизация")
                print("   3. Найдите ThemeSwitcher и разрешите доступ к 'System Events'")
                print("   4. Или запустите: tccutil reset AppleEvents")
                showPermissionsHelp()
            } else {
                print("✅ Тема переключена!")
            }
        }
    }

    func showPermissionsHelp() {
        let alert = NSAlert()
        alert.messageText = "Нет прав для переключения темы"
        alert.informativeText = """
        Чтобы ThemeSwitcher мог переключать темы, нужно предоставить права доступа.

        1. Откройте Системные настройки
        2. Перейдите в раздел "Безопасность и конфиденциальность"
        3. Выберите вкладку "Конфиденциальность"
        4. Выберите "Автоматизация" в списке слева
        5. Найдите ThemeSwitcher и поставьте галочку напротив "System Events"

        Или в Terminal выполните:
        tccutil reset AppleEvents

        После этого перезапустите ThemeSwitcher.
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func createIcon(for theme: String, style: IconStyle = IconSetManager.shared.currentIconStyle) -> NSImage? {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()
        NSColor.clear.set()
        NSRect(origin: .zero, size: size).fill()

        switch style {
        case .realistic:
            drawRealisticIcon(theme: theme)
        case .monochrome:
            drawMonochromeIcon(theme: theme)
        case .minimal:
            drawMinimalIcon(theme: theme)
        case .classic:
            drawClassicIcon(theme: theme)
        }

        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    // Реалистичные иконки (оригинальные)
    private func drawRealisticIcon(theme: String) {
        if theme == "dark" {
            drawRealisticMoon()
        } else {
            drawRealisticSun()
        }
    }

    private func drawRealisticMoon() {
        let moonPath = NSBezierPath()
        moonPath.move(to: NSPoint(x: 9, y: 2))
        moonPath.curve(to: NSPoint(x: 9, y: 16),
                      controlPoint1: NSPoint(x: 16, y: 9),
                      controlPoint2: NSPoint(x: 16, y: 9))
        moonPath.curve(to: NSPoint(x: 9, y: 2),
                      controlPoint1: NSPoint(x: 2, y: 9),
                      controlPoint2: NSPoint(x: 2, y: 9))

        if let context = NSGraphicsContext.current?.cgContext {
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [NSColor.white.cgColor,
                                            NSColor.lightGray.cgColor] as CFArray,
                                    locations: [0.0, 1.0])

            context.saveGState()
            moonPath.addClip()
            context.drawLinearGradient(gradient!,
                                     start: CGPoint(x: 9, y: 2),
                                     end: CGPoint(x: 9, y: 16),
                                     options: [])
            context.restoreGState()
        } else {
            NSColor.white.setFill()
            moonPath.fill()
        }
    }

    private func drawRealisticSun() {
        if let context = NSGraphicsContext.current?.cgContext {
            let sunGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: [NSColor.yellow.cgColor,
                                               NSColor.orange.cgColor] as CFArray,
                                       locations: [0.0, 1.0])

            let sunPath = NSBezierPath(ovalIn: NSRect(x: 4, y: 4, width: 10, height: 10))

            context.saveGState()
            sunPath.addClip()
            context.drawRadialGradient(sunGradient!,
                                     startCenter: CGPoint(x: 9, y: 9),
                                     startRadius: 0,
                                     endCenter: CGPoint(x: 9, y: 9),
                                     endRadius: 5,
                                     options: [])
            context.restoreGState()

            // Лучи солнца
            let rayLengths = [3, 2, 3, 2, 3, 2, 3, 2]

            for i in 0..<8 {
                let angle = Double(i) * Double.pi / 4.0
                let rayLength = Double(rayLengths[i])
                let cosAngle = cos(angle)
                let sinAngle = sin(angle)

                let startPoint = NSPoint(x: 9 + cosAngle * 5, y: 9 + sinAngle * 5)
                let endDistance = 5 + rayLength
                let endPoint = NSPoint(x: 9 + cosAngle * endDistance, y: 9 + sinAngle * endDistance)

                let rayPath = NSBezierPath()
                rayPath.move(to: startPoint)
                rayPath.line(to: endPoint)
                rayPath.lineWidth = 1.5

                if let rayGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                              colors: [NSColor.yellow.cgColor,
                                                      NSColor.orange.withAlphaComponent(0.5).cgColor] as CFArray,
                                              locations: [0.0, 1.0]) {
                    context.saveGState()
                    rayPath.addClip()
                    context.drawLinearGradient(rayGradient,
                                             start: startPoint,
                                             end: endPoint,
                                             options: [])
                    context.restoreGState()
                }
            }

            // Яркое ядро солнца
            NSColor.white.setFill()
            let corePath = NSBezierPath(ovalIn: NSRect(x: 7, y: 7, width: 4, height: 4))
            corePath.fill()
        }
    }

    // Монохромные иконки (черно-белые, плоские)
    private func drawMonochromeIcon(theme: String) {
        if theme == "dark" {
            NSColor.black.setFill()
            let moonPath = NSBezierPath()
            moonPath.move(to: NSPoint(x: 9, y: 3))
            moonPath.curve(to: NSPoint(x: 9, y: 15),
                          controlPoint1: NSPoint(x: 15, y: 9),
                          controlPoint2: NSPoint(x: 15, y: 9))
            moonPath.curve(to: NSPoint(x: 9, y: 3),
                          controlPoint1: NSPoint(x: 3, y: 9),
                          controlPoint2: NSPoint(x: 3, y: 9))
            moonPath.fill()
        } else {
            NSColor.black.setFill()
            let sunPath = NSBezierPath(ovalIn: NSRect(x: 5, y: 5, width: 8, height: 8))
            sunPath.fill()

            // Простые лучи
            for i in 0..<8 {
                let angle = Double(i) * Double.pi / 4.0
                let startPoint = NSPoint(x: 9 + cos(angle) * 4, y: 9 + sin(angle) * 4)
                let endPoint = NSPoint(x: 9 + cos(angle) * 6, y: 9 + sin(angle) * 6)

                let rayPath = NSBezierPath()
                rayPath.move(to: startPoint)
                rayPath.line(to: endPoint)
                rayPath.lineWidth = 1.0
                rayPath.stroke()
            }
        }
    }

    // Минималистичные иконки (простые геометрические)
    private func drawMinimalIcon(theme: String) {
        if theme == "dark" {
            NSColor.black.setFill()
            let moonPath = NSBezierPath(ovalIn: NSRect(x: 6, y: 6, width: 6, height: 6))
            moonPath.fill()
            // Маленькая точка для фазы луны
            let phasePath = NSBezierPath(ovalIn: NSRect(x: 8, y: 8, width: 2, height: 2))
            NSColor.white.setFill()
            phasePath.fill()
        } else {
            NSColor.black.setFill()
            let sunPath = NSBezierPath(ovalIn: NSRect(x: 6, y: 6, width: 6, height: 6))
            sunPath.fill()
            // 4 простых луча
            for i in 0..<4 {
                let angle = Double(i) * Double.pi / 2.0
                let startPoint = NSPoint(x: 9 + cos(angle) * 3, y: 9 + sin(angle) * 3)
                let endPoint = NSPoint(x: 9 + cos(angle) * 5, y: 9 + sin(angle) * 5)

                let rayPath = NSBezierPath()
                rayPath.move(to: startPoint)
                rayPath.line(to: endPoint)
                rayPath.lineWidth = 1.0
                rayPath.stroke()
            }
        }
    }

    // Классические иконки (традиционные символы)
    private func drawClassicIcon(theme: String) {
        if theme == "dark" {
            NSColor.black.setFill()
            // Классический символ полумесяца
            let moonPath = NSBezierPath()
            moonPath.appendArc(withCenter: NSPoint(x: 9, y: 9), radius: 6, startAngle: -90, endAngle: 90)
            moonPath.appendArc(withCenter: NSPoint(x: 12, y: 9), radius: 3, startAngle: 90, endAngle: -90, clockwise: true)
            moonPath.fill()
        } else {
            NSColor.black.setFill()
            // Классический символ солнца с кругами
            let sunPath = NSBezierPath(ovalIn: NSRect(x: 6, y: 6, width: 6, height: 6))
            sunPath.fill()

            // Концентрические круги для лучей
            NSColor.black.setStroke()
            for radius in [7, 8] {
                let circlePath = NSBezierPath(ovalIn: NSRect(x: 9 - radius, y: 9 - radius, width: radius * 2, height: radius * 2))
                circlePath.lineWidth = 0.5
                circlePath.stroke()
            }
        }
    }
}

// MARK: - Settings Window
class SettingsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    private var tableView: NSTableView!
    private let iconStyles = IconStyle.allCases

    override func loadWindow() {
        print("🖼️ SettingsWindowController loadWindow() вызван")
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 250),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Настройки ThemeSwitcher"
        window.center()
        print("📏 Окно создано и центрировано")

        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        print("📋 ContentView создан")

        // Заголовок
        let titleLabel = NSTextField(labelWithString: "Выберите стиль иконок:")
        titleLabel.frame = NSRect(x: 20, y: 200, width: 260, height: 20)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(titleLabel)

        // Таблица
        let scrollView = NSScrollView(frame: NSRect(x: 20, y: 50, width: 260, height: 140))
        tableView = NSTableView(frame: scrollView.bounds)

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("IconStyle"))
        column.title = "Стиль иконок"
        column.width = 240
        tableView.addTableColumn(column)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.selectionHighlightStyle = .regular
        tableView.allowsMultipleSelection = false

        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        contentView.addSubview(scrollView)

        // Кнопка OK
        let okButton = NSButton(title: "OK", target: self, action: #selector(okButtonClicked))
        okButton.frame = NSRect(x: 200, y: 10, width: 80, height: 30)
        okButton.bezelStyle = .rounded
        contentView.addSubview(okButton)

        // Выбрать текущий стиль
        let currentStyleIndex = iconStyles.firstIndex(of: IconSetManager.shared.currentIconStyle) ?? 0
        tableView.selectRowIndexes(IndexSet(integer: currentStyleIndex), byExtendingSelection: false)

        window.contentView = contentView
        self.window = window
        print("✅ SettingsWindowController loadWindow() завершен")
    }

    // MARK: - NSTableView DataSource & Delegate
    func numberOfRows(in tableView: NSTableView) -> Int {
        return iconStyles.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let style = iconStyles[row]
        let currentStyle = IconSetManager.shared.currentIconStyle

        let attributedString = NSMutableAttributedString(string: style.description)
        if style == currentStyle {
            attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.font, value: NSFont.systemFont(ofSize: 13, weight: .medium), range: NSRange(location: 0, length: attributedString.length))
        }

        return attributedString
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 && selectedRow < iconStyles.count {
            let selectedStyle = iconStyles[selectedRow]
            IconSetManager.shared.currentIconStyle = selectedStyle
        }
    }

    @objc private func okButtonClicked() {
        window?.close()
    }
}

// MARK: - Status Bar Controller
class StatusBarController {
    private var statusItem: NSStatusItem!
    private let themeManager = ThemeManager.shared
    private var settingsWindowController: SettingsWindowController?
    private var contextMenu: NSMenu!

    init() {
        setupStatusBar()
        setupIconStyleObserver()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = themeManager.createIcon(for: themeManager.getCurrentTheme())
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(leftClickAction)
            button.target = self
            button.toolTip = "Theme Switcher - Left: toggle theme, Cmd+Left: settings, Double-click/Shift+Left/Ctrl+Left: menu"
        }

        setupMenu()
        setupObserver()
        setupRightClickGesture()
        setupIconStyleObserver()
        updateIcon()

        // Не присваиваем меню автоматически, чтобы левая кнопка работала
        // Меню будет показано только по правому клику
    }

    private func setupMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "🎨 Переключить тему", action: #selector(toggleThemeAction), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let currentTheme = themeManager.getCurrentTheme()
        let themeInfo = NSMenuItem(title: "Текущая тема: \(currentTheme == "dark" ? "🌙 Тёмная" : "☀️ Светлая")", action: nil, keyEquivalent: "")
        themeInfo.isEnabled = false
        menu.addItem(themeInfo)

        menu.addItem(NSMenuItem.separator())

        let permissionsItem = NSMenuItem(title: "🔑 Проверить права", action: #selector(checkPermissionsAction), keyEquivalent: "")
        permissionsItem.target = self
        menu.addItem(permissionsItem)

        let helpItem = NSMenuItem(title: "❓ Помощь с правами", action: #selector(showHelpAction), keyEquivalent: "")
        helpItem.target = self
        menu.addItem(helpItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "⚙️ Настройки", action: #selector(showSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Альтернативный пункт для открытия настроек
        let settingsAltItem = NSMenuItem(title: "🎨 Стили иконок", action: #selector(showSettingsAction), keyEquivalent: "")
        settingsAltItem.target = self
        menu.addItem(settingsAltItem)

        let quitItem = NSMenuItem(title: "🚪 Выход", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        // Сохраняем меню для показа по правому клику
        contextMenu = menu
    }

    private func setupObserver() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(themeChanged),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    private func setupRightClickGesture() {
        // Поскольку NSClickGestureRecognizer с buttonMask 0x2 не работает в статус баре,
        // используем альтернативные способы: двойной клик и Shift+клик
        print("🎛️ Настраиваю альтернативные способы открытия меню...")

        // Двойной клик для открытия меню
        let doubleClickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(rightClickAction(_:)))
        doubleClickRecognizer.buttonMask = 0x1 // Левая кнопка
        doubleClickRecognizer.numberOfClicksRequired = 2 // Двойной клик
        statusItem.button?.addGestureRecognizer(doubleClickRecognizer)
        print("✅ Двойной клик настроен")

        // Shift + клик для открытия меню
        let shiftClickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(rightClickAction(_:)))
        shiftClickRecognizer.buttonMask = 0x1 // Левая кнопка
        shiftClickRecognizer.numberOfClicksRequired = 1 // Одиночный клик
        statusItem.button?.addGestureRecognizer(shiftClickRecognizer)
        print("✅ Shift + клик настроен")
    }

    @objc private func leftClickAction() {
        print("🖱️ leftClickAction вызван")
        // Левая кнопка - только переключение темы
        // Если зажать Cmd, открываем настройки
        // Если зажать Ctrl, открываем меню
        // Если зажать Shift, открываем меню
        let event = NSApp.currentEvent
        let modifierFlags = event?.modifierFlags ?? []
        print("🔑 Модификаторы: \(modifierFlags)")

        if modifierFlags.contains(.command) {
            print("⌘ Cmd нажат - открываю настройки")
            showSettingsAction()
        } else if modifierFlags.contains(.control) {
            print("⌃ Ctrl нажат - открываю меню")
            rightClickAction(NSClickGestureRecognizer())
        } else if modifierFlags.contains(.shift) {
            print("⇧ Shift нажат - открываю меню")
            rightClickAction(NSClickGestureRecognizer())
        } else {
            print("🔄 Обычный клик - переключаю тему")
            themeManager.toggleTheme()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateMenu()
            }
        }
    }

    @objc private func rightClickAction(_ sender: NSClickGestureRecognizer) {
        // Правая кнопка или альтернативные способы - показываем меню
        updateMenu()
        // Показываем меню в позиции курсора
        let event = NSApp.currentEvent
        let point = statusItem.button?.convert(event?.locationInWindow ?? .zero, from: nil) ?? .zero

        // Пробуем несколько способов показа меню
        if let button = statusItem.button {
            // Способ 1: Через NSMenu.popUp
            contextMenu.popUp(positioning: nil, at: point, in: button)
        }
    }

    @objc private func toggleThemeAction() {
        // Для пункта меню "Переключить тему"
        themeManager.toggleTheme()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateMenu()
        }
    }

    @objc private func checkPermissionsAction() {
        let script = "tell application \"System Events\" to tell appearance preferences to get dark mode"
        var error: NSDictionary?

        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if error != nil {
                showPermissionsAlert("❌ Нет прав доступа", "ThemeSwitcher не имеет прав для изменения системных настроек.")
            } else {
                showPermissionsAlert("✅ Права есть", "ThemeSwitcher имеет все необходимые права для работы.")
            }
        }
    }

    @objc private func showHelpAction() {
        themeManager.showPermissionsHelp()
    }

    @objc private func showSettingsAction() {
        print("🎛️ showSettingsAction вызван")

        DispatchQueue.main.async {
            if self.settingsWindowController == nil {
                print("📂 Создаю новый SettingsWindowController")
                self.settingsWindowController = SettingsWindowController()
                print("📂 SettingsWindowController создан")
            }

            print("🖼️ Показываю окно настроек")
            self.settingsWindowController?.showWindow(nil)

            // Делаем окно ключевым и активируем приложение
            if let window = self.settingsWindowController?.window {
                print("🔑 Делаю окно ключевым")
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                print("✅ Окно должно быть показано")
            } else {
                print("❌ Ошибка: окно не создано")
            }
        }
    }

    private func setupIconStyleObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iconStyleChanged),
            name: .iconStyleChanged,
            object: nil
        )
    }

    @objc private func iconStyleChanged() {
        updateIcon()
    }

    func showPermissionsAlert(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func themeChanged() {
        updateIcon()
        updateMenu()
    }

    private func updateIcon() {
        let currentTheme = themeManager.getCurrentTheme()
        let currentStyle = IconSetManager.shared.currentIconStyle
        if let button = statusItem.button {
            button.image = themeManager.createIcon(for: currentTheme, style: currentStyle)
        }
        updateMenu()
    }

    private func updateMenu() {
        let currentTheme = themeManager.getCurrentTheme()
        let currentStyle = IconSetManager.shared.currentIconStyle
        let themeInfoTitle = "Текущая тема: \(currentTheme == "dark" ? "🌙 Тёмная" : "☀️ Светлая") (\(currentStyle.description))"

        for menuItem in contextMenu.items {
            if menuItem.isEnabled == false && menuItem.title.contains("Текущая тема") {
                menuItem.title = themeInfoTitle
                break
            }
        }
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusBarController = StatusBarController()
        print("ThemeSwitcher запущен! Иконка в меню баре.")
    }
}

// MARK: - Main
func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}

main()
