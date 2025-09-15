import XCTest
@testable import ThemeSwitcher

final class ThemeSwitcherTests: XCTestCase {
    func testThemeManagerCreation() {
        let themeManager = ThemeManager.shared
        XCTAssertNotNil(themeManager)
    }

    func testGetCurrentTheme() {
        let themeManager = ThemeManager.shared
        let currentTheme = themeManager.getCurrentTheme()

        // Тема должна быть либо "light", либо "dark"
        XCTAssertTrue(currentTheme == "light" || currentTheme == "dark",
                     "Current theme should be either 'light' or 'dark', got: \(currentTheme)")
    }

    func testCreateIcon() {
        let themeManager = ThemeManager.shared

        let lightIcon = themeManager.createIcon(for: "light")
        XCTAssertNotNil(lightIcon, "Light theme icon should not be nil")

        let darkIcon = themeManager.createIcon(for: "dark")
        XCTAssertNotNil(darkIcon, "Dark theme icon should not be nil")

        // Проверяем размеры иконок
        XCTAssertEqual(lightIcon?.size.width, 18, "Icon width should be 18")
        XCTAssertEqual(lightIcon?.size.height, 18, "Icon height should be 18")
    }

    func testToggleTheme() {
        let themeManager = ThemeManager.shared
        let initialTheme = themeManager.getCurrentTheme()

        // Переключаем тему
        themeManager.toggleTheme()

        // Ждём немного для применения изменений
        Thread.sleep(forTimeInterval: 0.5)

        let newTheme = themeManager.getCurrentTheme()

        // Тема должна измениться
        XCTAssertNotEqual(initialTheme, newTheme,
                         "Theme should change after toggle. Initial: \(initialTheme), New: \(newTheme)")

        // Возвращаем тему обратно
        themeManager.toggleTheme()
        Thread.sleep(forTimeInterval: 0.5)

        let finalTheme = themeManager.getCurrentTheme()
        XCTAssertEqual(initialTheme, finalTheme,
                      "Theme should be restored to initial state")
    }

    func testIconCreation() {
        let themeManager = ThemeManager.shared

        // Проверяем создание иконок для разных тем
        let lightIcon = themeManager.createIcon(for: "light")
        XCTAssertNotNil(lightIcon, "Light theme icon should not be nil")
        XCTAssertEqual(lightIcon?.size.width, 18, "Icon width should be 18")
        XCTAssertEqual(lightIcon?.size.height, 18, "Icon height should be 18")

        let darkIcon = themeManager.createIcon(for: "dark")
        XCTAssertNotNil(darkIcon, "Dark theme icon should not be nil")
        XCTAssertEqual(darkIcon?.size.width, 18, "Icon width should be 18")
        XCTAssertEqual(darkIcon?.size.height, 18, "Icon height should be 18")

        // Иконки должны быть разными
        XCTAssertNotEqual(lightIcon?.tiffRepresentation, darkIcon?.tiffRepresentation,
                         "Light and dark icons should be different")
    }
}
