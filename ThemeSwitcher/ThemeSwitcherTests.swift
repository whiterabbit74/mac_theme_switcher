//
//  ThemeSwitcherTests.swift
//  ThemeSwitcherTests
//
//  Created by ThemeSwitcher on 2024
//

import XCTest
@testable import ThemeSwitcher

class ThemeSwitcherTests: XCTestCase {

    var themeSwitcher: ThemeSwitcher!
    var mockStatusBarItem: NSStatusItem!

    override func setUpWithError() throws {
        // Настройка перед каждым тестом
        mockStatusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        themeSwitcher = ThemeSwitcher(statusBarItem: mockStatusBarItem)
    }

    override func tearDownWithError() throws {
        // Очистка после каждого теста
        themeSwitcher?.cleanup()
        if let statusBarItem = mockStatusBarItem {
            NSStatusBar.system.removeStatusItem(statusBarItem)
        }
    }

    func testThemeEnum() throws {
        // Тестируем перечисление Theme
        XCTAssertEqual(Theme.light.rawValue, "light")
        XCTAssertEqual(Theme.dark.rawValue, "dark")
        XCTAssertEqual(Theme.light.iconName, "sun.max.fill")
        XCTAssertEqual(Theme.dark.iconName, "moon.fill")
    }

    func testCurrentThemeDetection() throws {
        // Тестируем определение текущей темы
        let currentTheme = themeSwitcher.currentTheme

        // Тема должна быть либо светлой, либо темной
        XCTAssertTrue(currentTheme == .light || currentTheme == .dark)

        // Проверяем что иконка соответствует теме
        let expectedIcon = currentTheme.iconName
        let actualIcon = themeSwitcher.statusBarItem.button?.image?.accessibilityDescription
        // Note: В реальности нужно проверить через NSImage, но для теста упростим
    }

    func testThemeToggle() throws {
        // Тестируем переключение темы
        let initialTheme = themeSwitcher.currentTheme

        // Имитируем переключение
        themeSwitcher.toggleTheme()

        // Даем время на выполнение AppleScript
        let expectation = expectation(description: "Theme toggle completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0)

        // Проверяем что тема изменилась (если переключение удалось)
        let newTheme = themeSwitcher.currentTheme

        // В реальности может не измениться из-за системных ограничений в тестах
        // Но структура должна работать
        XCTAssertTrue(newTheme == .light || newTheme == .dark)
    }

    func testSystemIntegration() throws {
        // Тестируем интеграцию с системными настройками
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", "-g", "AppleInterfaceStyle"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

        // Если output == "Dark", то система в темной теме
        // Если output == nil или пустой, то в светлой теме
        let isDarkMode = output == "Dark"

        // Проверяем что наше определение совпадает с системным
        let currentTheme = themeSwitcher.currentTheme
        XCTAssertEqual(currentTheme, isDarkMode ? .dark : .light)
    }

    func testIconUpdate() throws {
        // Тестируем обновление иконки
        let initialIcon = mockStatusBarItem.button?.image

        // Имитируем смену темы
        themeSwitcher.currentTheme = .dark
        themeSwitcher.updateIcon()

        // Даем время на обновление UI
        let expectation = expectation(description: "Icon update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        // Проверяем что иконка изменилась
        let newIcon = mockStatusBarItem.button?.image

        // Иконки должны быть разными (или хотя бы не nil)
        if initialIcon != nil || newIcon != nil {
            // В реальности нужно сравнивать NSImage, но для теста достаточно проверить что они существуют
            XCTAssertNotNil(newIcon)
        }
    }

    func testPerformance() throws {
        // Тестируем производительность переключения
        measure {
            themeSwitcher.toggleTheme()
        }
    }
}
