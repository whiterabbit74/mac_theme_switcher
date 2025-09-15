# ThemeSwitcher 🌙☀️

Native macOS menu bar application for instant theme switching between light and dark modes.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **Left Click**: Instantly toggle between light/dark theme
- **Right Click**: Access settings menu and options
- **Auto-Updates**: Icon automatically reflects current system theme
- **Permissions**: Smart AppleScript permission handling
- **Error Handling**: User-friendly error messages and guidance
- **Memory Safe**: Proper cleanup and resource management

## 🚀 Quick Start

### Installation

1. **Download latest release** from [GitHub Releases](https://github.com/whiterabbit74/mac_theme_switcher/releases)
2. **Extract** the downloaded archive
3. **Run** the application:
   ```bash
   ./ThemeSwitcher
   ```

### Building from Source

```bash
# Clone the repository
git clone https://github.com/whiterabbit74/mac_theme_switcher.git
cd mac_theme_switcher

# Build and run
make run
```

## 📋 Requirements

- macOS 12.0 or later
- Swift 5.9+ (for building from source)
- Xcode Command Line Tools

## 🔧 Available Commands

```bash
make build        # Build the application
make run          # Build and run
make run-debug    # Run in development mode
make test         # Run tests
make clean        # Clean build artifacts
make permissions  # Reset AppleScript permissions
make install      # Full installation
make help         # Show help
```

## 🎯 How to Use

1. **Launch** the application - icon appears in menu bar
2. **Left click** the icon to instantly toggle theme
3. **Right click** for settings menu:
   - Current theme display
   - Manual theme toggle
   - Settings window
   - About information
   - Quit option

## 🔐 Permissions

On first run, macOS will request AppleScript permissions. The app will guide you through:

1. **Automatic prompt** - Grant access when requested
2. **Manual setup** - If needed, go to:
   - System Preferences → Security & Privacy → Privacy → Automation
   - Enable access to "System Events" for ThemeSwitcher

### Permission Scripts

```bash
# Reset permissions (if having issues)
./scripts/fix_permissions.sh

# Setup permissions
./scripts/setup_permissions.sh
```

## 🏗️ Architecture

- **Swift Package Manager** - Modern Swift project structure
- **AppKit** - Native macOS UI components
- **AppleScript** - System theme switching via System Events
- **NSStatusBar** - Menu bar integration
- **DistributedNotificationCenter** - System theme change detection

## 📁 Project Structure

```
mac_theme_switcher/
├── Sources/ThemeSwitcher/     # Main application code
│   └── main.swift            # Complete application implementation
├── Tests/ThemeSwitcherTests/  # Unit tests
├── scripts/                  # Utility scripts
│   ├── fix_permissions.sh    # Permission troubleshooting
│   └── setup_permissions.sh  # Permission setup
├── Package.swift             # Swift Package Manager config
├── Makefile                  # Build commands
├── CLAUDE.md                 # Development guidance
└── README.md                 # This file
```

## 🐛 Troubleshooting

### App doesn't start
- Check macOS version (requires 12.0+)
- Verify Swift installation: `swift --version`
- Grant permissions when prompted

### Theme doesn't switch
- Check AppleScript permissions in System Preferences
- Run `make permissions` to reset permissions
- Restart the application

### Icon doesn't appear
- Check menu bar isn't hidden
- Restart the application
- Check system resources

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/whiterabbit74/mac_theme_switcher/issues)
- **Discussions**: [GitHub Discussions](https://github.com/whiterabbit74/mac_theme_switcher/discussions)

---

**🎉 Made with ❤️ for macOS users who love instant theme switching!**