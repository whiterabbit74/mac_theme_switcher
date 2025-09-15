//
//  AppDelegate.swift
//  ThemeSwitcher
//
//  Created by ThemeSwitcher on 2024
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarItem: NSStatusItem!
    private var themeSwitcher: ThemeSwitcher!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Скрываем главное окно приложения (menu bar app)
        NSApp.setActivationPolicy(.accessory)

        // Создаем статус-бар элемент
        setupStatusBarItem()

        // Инициализируем переключатель тем
        themeSwitcher = ThemeSwitcher(statusBarItem: statusBarItem)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Очистка ресурсов
        themeSwitcher?.cleanup()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Theme Switcher")
        statusBarItem.button?.action = #selector(toggleTheme)
        statusBarItem.button?.target = self
    }

    @objc private func toggleTheme() {
        themeSwitcher?.toggleTheme()
    }
}
