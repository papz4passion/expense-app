# Expense Tracker - Modern Flutter App

**A comprehensive expense tracking application built with Flutter**

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-green.svg)](https://flutter.dev/multi-platform)
[![Status](https://img.shields.io/badge/Phase%201-Complete-brightgreen.svg)](PROGRESS.md)

---

## 🎯 Project Overview

A modern, offline-first expense tracking application featuring:
- **Banking app-inspired UI** with Material 3 design system
- **Cross-platform support** (iOS, Android, Web, Desktop)
- **Offline-first architecture** with SQLite and localStorage
- **Smart automation features** (planned in future phases)
- **Modern state management** using Provider pattern

---

## 📋 Documentation

| Document | Description |
|----------|-------------|
| **[SETUP.md](SETUP.md)** | 🔧 Complete development setup guide |
| **[PROGRESS.md](PROGRESS.md)** | 📊 Development progress and current status |
| **[Requirements.md](Requirements.md)** | 📋 Complete feature requirements |
| **[Development-Phases.md](Development-Phases.md)** | 🗺️ Detailed phase breakdown |

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.x SDK
- Dart 3.x
- Platform-specific tools (Xcode for iOS, Android Studio for Android)

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd expense-app

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome      # Web
flutter run -d ios         # iOS Simulator
flutter run -d android     # Android Emulator
```

**📖 For detailed setup instructions, see [SETUP.md](SETUP.md)**

---

## ✨ Current Features (Phase 1 Complete)

### 💰 Core Functionality
- ✅ Add, edit, and delete transactions
- ✅ Income and expense tracking
- ✅ 10 predefined categories with icons
- ✅ Real-time balance calculations
- ✅ Transaction search and filtering

### 🎨 Modern UI/UX
- ✅ Banking app-inspired design
- ✅ Light and dark theme support
- ✅ Responsive layout for all screen sizes
- ✅ Smooth animations and transitions
- ✅ Material 3 design system

### 💾 Data Management
- ✅ SQLite database for mobile platforms
- ✅ localStorage for web platform
- ✅ Offline-first architecture
- ✅ Cross-platform data compatibility

### 📊 Dashboard & Analytics
- ✅ Real-time financial overview
- ✅ Monthly income/expense summaries
- ✅ Recent transactions display
- ✅ Quick action buttons

---

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management
├── screens/                  # UI screens
├── widgets/                  # Reusable components
├── database/                 # Data persistence
├── theme/                    # UI theming
└── utils/                    # Utility functions
```

---

## 🔮 Roadmap

| Phase | Status | Features |
|-------|--------|----------|
| **Phase 1** | ✅ Complete | MVP Core Functionality |
| **Phase 2** | 📋 Planned | Enhanced UI & Analytics |
| **Phase 3** | 📋 Planned | User Auth & Cloud Sync |
| **Phase 4** | 📋 Planned | Investment Tracking |
| **Phase 5** | 📋 Planned | SMS Integration |
| **Phase 6+** | 📋 Planned | Advanced Features |

**📈 For detailed roadmap, see [PROGRESS.md](PROGRESS.md)**

---

## 🧪 Testing

### Platforms Tested
- ✅ **Web**: Chrome, Safari, Firefox
- ✅ **iOS**: iPhone Simulator
- ✅ **Android**: Emulator (planned)
- ✅ **macOS**: Desktop app

### Test the App
```bash
# Run tests
flutter test

# Test on specific platform
flutter run -d chrome     # Web
flutter run -d ios        # iOS
flutter run -d android    # Android
```

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **UI**: Material 3 Design System
- **State Management**: Provider Pattern

### Backend & Storage
- **Local Database**: SQLite (mobile), localStorage (web)
- **Future**: Firebase Firestore (Phase 3+)

### Development
- **IDE**: VS Code with Flutter/Dart extensions
- **Version Control**: Git
- **Testing**: Flutter Test Framework

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **iOS** | ✅ Supported | iOS 12+ |
| **Android** | ✅ Supported | API 21+ |
| **Web** | ✅ Supported | Modern browsers |
| **macOS** | ✅ Supported | macOS 10.14+ |
| **Windows** | ✅ Supported | Windows 10+ |
| **Linux** | ✅ Supported | 64-bit |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- 📖 **Setup Guide**: [SETUP.md](SETUP.md)
- 📊 **Progress Tracking**: [PROGRESS.md](PROGRESS.md)
- 📋 **Requirements**: [Requirements.md](Requirements.md)
- 🗺️ **Development Phases**: [Development-Phases.md](Development-Phases.md)

---

**Last Updated**: June 15, 2025  
**Current Status**: Phase 1 Complete ✅  
**Next Milestone**: Phase 2 - Enhanced UI & Analytics
