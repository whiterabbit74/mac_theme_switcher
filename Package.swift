// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ThemeSwitcher",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // Добавим зависимости для работы с Cocoa API
    ],
    targets: [
        .executableTarget(
            name: "ThemeSwitcher",
            dependencies: [],
            path: "Sources/ThemeSwitcher"
        ),
        .testTarget(
            name: "ThemeSwitcherTests",
            dependencies: ["ThemeSwitcher"],
            path: "Tests/ThemeSwitcherTests"
        )
    ]
)
