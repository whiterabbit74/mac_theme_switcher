# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ThemeSwitcher is a native macOS application written in Swift that provides a menu bar utility for toggling between light and dark system themes. The project includes both a Swift Package Manager version and a standalone Xcode project.

## Build and Development Commands

### Swift Package Manager (Primary)
```bash
# Build the application
make build
# or
swift build --configuration release

# Run the application
make run
# or
./.build/release/ThemeSwitcher

# Run in development mode
make run-debug
# or
swift run

# Run tests
make test
# or
swift test

# Clean build artifacts
make clean
# or
swift package clean
```

### Xcode Project (Alternative)
The Xcode project is located in `ThemeSwitcher.xcodeproj/` and can be used for development with full IDE support.

### Permission Setup
```bash
# Reset AppleScript permissions
make permissions

# Setup permissions via script
./setup_permissions.sh

# Fix permissions if needed
./fix_permissions.sh
```

## Code Architecture

### Core Components

1. **ThemeManager (Sources/ThemeSwitcher/main.swift:5-93)**
   - Singleton class managing theme detection and switching
   - Uses NSAppearance API for theme detection
   - Executes AppleScript for system theme changes
   - Creates custom vector icons for different themes

2. **StatusBarController (Sources/ThemeSwitcher/main.swift:96-240)**
   - Manages NSStatusItem in the menu bar
   - Handles left/right click interactions
   - Creates dynamic menus with theme information
   - Listens for system theme change notifications

3. **AppDelegate (Sources/ThemeSwitcher/main.swift:243-260)**
   - Sets up application as accessory (no dock icon)
   - Initializes status bar controller
   - Handles application lifecycle

### Dual Implementation Structure

The project contains two main implementations:

1. **Swift Package Manager Version** (`Sources/ThemeSwitcher/main.swift`)
   - Single-file implementation with all classes
   - Custom vector icon generation
   - Comprehensive menu system with both left and right-click support

2. **Xcode Project Version** (`ThemeSwitcher/`)
   - Modular structure with separate Swift files
   - Uses SF Symbols for icons
   - Process-based AppleScript execution

### Theme Detection Methods

The application uses multiple fallback methods for theme detection:
- NSAppearance.effectiveAppearance (primary)
- NSAppearance.currentDrawing() (fallback)
- `defaults read -g AppleInterfaceStyle` command (ultimate fallback)

### AppleScript Integration

Theme switching is accomplished via AppleScript:
```applescript
tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
```

### Menu System

- **Left Click**: Main menu with toggle, theme info, and quit options
- **Right Click**: Context menu with quick toggle and theme status
- Dynamic menu updates based on current system theme

## Testing

Tests are located in `Tests/ThemeSwitcherTests/ThemeSwitcherTests.swift` and cover:
- ThemeManager singleton functionality
- Theme detection accuracy
- Icon creation for both themes
- Theme toggle operations with state verification

## Platform Requirements

- macOS 12.0+ (specified in Package.swift:7)
- Swift 5.9+ (specified in Package.swift:1)
- Apple Silicon optimized (M1/M-series)

## Security and Permissions

The application requires:
- AppleScript access to System Events
- Automation permissions for theme switching
- Privacy settings configuration for system modification

Permission issues can be resolved using the provided scripts or the `make permissions` command.