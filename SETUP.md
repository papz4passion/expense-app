# Development Setup Guide

**Project**: Modern Expense Tracking App with Flutter + Firebase  
**Last Updated**: June 15, 2025  
**Flutter Version**: 3.x  
**Dart Version**: 3.x

---

## 📋 Quick Navigation

- [PROGRESS.md](PROGRESS.md) - Development progress and current status
- [Requirements.md](Requirements.md) - Complete feature requirements
- [Development-Phases.md](Development-Phases.md) - Detailed phase breakdown
- [README.md](README.md) - Project overview and basic information

---

## 🎯 Prerequisites

### System Requirements
- **macOS**: 10.14 or later (for iOS development)
- **Windows**: 10 or later (64-bit)
- **Linux**: 64-bit distribution
- **RAM**: 8GB minimum (16GB recommended)
- **Storage**: 15GB free space

### Required Software

#### 1. Flutter SDK
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Or use Flutter Version Manager (FVM)
dart pub global activate fvm
fvm install stable
fvm use stable
```

#### 2. Platform-Specific Tools

**For iOS Development (macOS only):**
```bash
# Install Xcode from App Store (14.0 or later)
sudo xcode-select --install
sudo xcodebuild -runFirstLaunch

# Install CocoaPods
sudo gem install cocoapods
```

**For Android Development:**
```bash
# Install Android Studio with SDK
# Install Android SDK Tools
# Configure Android SDK path in Flutter
flutter config --android-sdk /path/to/android/sdk
```

**For Web Development:**
```bash
# Chrome browser for testing
# Web development is enabled by default in Flutter 3.x
```

#### 3. Development Tools
- **VS Code** (recommended) with Flutter/Dart extensions
- **Android Studio** (alternative IDE)
- **Git** for version control

---

## 🚀 Quick Start

### 1. Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd expense-app

# Install dependencies
flutter pub get

# Verify Flutter installation
flutter doctor -v
```

### 2. Run the Application

**Web (Chrome):**
```bash
flutter run -d chrome
```

**iOS Simulator:**
```bash
# List available simulators
flutter emulators

# Run on iOS simulator
flutter run -d ios
```

**Android Emulator:**
```bash
# List available emulators
flutter emulators

# Run on Android emulator
flutter run -d android
```

**macOS Desktop:**
```bash
flutter run -d macos
```

### 3. Development Mode
```bash
# Run with hot reload (development)
flutter run --debug

# Run with release optimizations
flutter run --release

# Run with profile mode (performance testing)
flutter run --profile
```

---

## 🏗️ Project Structure

```
expense-app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── transaction.dart      # Transaction model
│   │   └── category.dart         # Category model
│   ├── providers/                # State management
│   │   └── transaction_provider.dart
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Main dashboard
│   │   ├── add_transaction_screen.dart
│   │   └── transactions_screen.dart
│   ├── widgets/                  # Reusable UI components
│   │   ├── dashboard_summary.dart
│   │   ├── transaction_list.dart
│   │   └── quick_actions.dart
│   ├── database/                 # Data persistence
│   │   ├── database_helper.dart  # SQLite operations
│   │   ├── web_storage.dart      # Web localStorage
│   │   └── web_storage_stub.dart # Platform abstraction
│   ├── theme/                    # UI theming
│   │   └── app_theme.dart
│   └── utils/                    # Utility functions
├── test/                         # Unit and widget tests
├── android/                      # Android-specific files
├── ios/                         # iOS-specific files
├── web/                         # Web platform files
├── macos/                       # macOS desktop files
├── windows/                     # Windows desktop files
├── linux/                       # Linux desktop files
├── pubspec.yaml                 # Dependencies and metadata
└── analysis_options.yaml       # Dart analysis configuration
```

---

## 📱 Platform Configuration

### iOS Setup
```bash
# Navigate to iOS directory
cd ios

# Install CocoaPods dependencies
pod install

# Open in Xcode (if needed)
open Runner.xcworkspace
```

**iOS Simulator Network Permissions:**
If you encounter network permission warnings:
1. Open iOS Simulator
2. Go to Device > Privacy & Security Settings
3. Enable "Local Network" for your Flutter app
4. Restart the simulator

### Android Setup
```bash
# Check Android configuration
flutter config --android-sdk

# Create Android emulator (if needed)
flutter emulators --create --name pixel_7 --platform android

# Run on Android
flutter run -d android
```

### Web Setup
```bash
# Enable web support (if not already enabled)
flutter config --enable-web

# Run on web
flutter run -d chrome --web-renderer html
```

---

## 🔧 Development Commands

### Common Flutter Commands
```bash
# Check Flutter installation and dependencies
flutter doctor

# Get dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Build for release
flutter build apk        # Android APK
flutter build ios        # iOS
flutter build web        # Web
flutter build macos      # macOS

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### Database Management
```bash
# The app uses SQLite for mobile platforms
# Database file location (simulator/emulator):
# iOS: ~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/expense_tracker.db
# Android: /data/data/com.example.expense_tracker/databases/expense_tracker.db

# For web: localStorage in browser developer tools
```

---

## 🧪 Testing Guide

### Manual Testing Checklist

#### Phase 1 Features (Current)
- [ ] **Add Transaction**: Tap FAB, fill form, save
- [ ] **View Transactions**: Navigate to Transactions tab
- [ ] **Edit Transaction**: Long press transaction, edit details
- [ ] **Delete Transaction**: Long press transaction, confirm deletion
- [ ] **Search**: Use search bar in Transactions tab
- [ ] **Filter**: Test category and type filters
- [ ] **Dashboard**: Verify balance calculations and summaries
- [ ] **Navigation**: Test bottom navigation tabs
- [ ] **Theme**: Verify light/dark mode switching

#### Platform-Specific Testing
```bash
# Web testing
flutter run -d chrome
# Test localStorage persistence, responsive design

# iOS testing
flutter run -d ios
# Test SQLite database, native UI components

# Android testing
flutter run -d android
# Test material design, back button navigation
```

### Automated Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0           # SQLite database
  provider: ^6.1.1          # State management
  path: ^1.8.3              # File path utilities
  intl: ^0.18.1             # Internationalization
  shared_preferences: ^2.2.2 # Simple key-value storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0     # Linting rules
```

### Adding New Dependencies
```bash
# Add a new dependency
flutter pub add package_name

# Add a dev dependency
flutter pub add -d package_name

# Update dependencies
flutter pub upgrade
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. iOS Simulator Network Permission Warning
```
[ERROR:flutter/shell/platform/darwin/ios/framework/Source/FlutterDartVMServicePublisher.mm(129)] 
Could not register as server for FlutterDartVMServicePublisher, permission denied.
```
**Solution**: Enable "Local Network" permissions in iOS Simulator settings (non-critical for app functionality).

#### 2. Web Platform Database Errors
```
Error: Unsupported operation: Platform._operatingSystem
```
**Solution**: The app automatically uses localStorage for web platforms. This is handled by the platform abstraction layer.

#### 3. Build Errors After Clean
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
```

#### 4. Android Gradle Issues
```bash
# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.3
```

#### 5. iOS CocoaPods Issues
```bash
# Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

---

## 🔄 Git Workflow

### Branch Strategy
```bash
# Main development branch
git checkout main

# Feature branches
git checkout -b feature/phase-2-analytics
git checkout -b feature/receipt-attachments
git checkout -b fix/ios-permission-warning

# Commit conventions
git commit -m "feat: add receipt attachment functionality"
git commit -m "fix: resolve iOS simulator network permission warning"
git commit -m "docs: update setup guide with new dependencies"
```

### Useful Git Commands
```bash
# Check status
git status

# Add changes
git add .

# Commit with message
git commit -m "description"

# Push to remote
git push origin branch-name

# Pull latest changes
git pull origin main
```

---

## 📊 Performance Monitoring

### Development Performance
```bash
# Run with performance profiling
flutter run --profile

# Generate performance timeline
flutter run --trace-startup --profile

# Analyze app size
flutter build apk --analyze-size
```

### Memory Usage
```bash
# Monitor memory usage during development
flutter run --enable-profiler

# Debug memory leaks
flutter run --debug --dart-define=FLUTTER_MEMORY_ALLOCATIONS=true
```

---

## 🚀 Next Phase Setup

### Phase 2 Preparation (Enhanced UI & Analytics)
```bash
# Dependencies for charts and analytics
flutter pub add fl_chart          # Chart library
flutter pub add image_picker      # Camera/gallery access
flutter pub add path_provider     # File system access
```

### Phase 3 Preparation (Firebase Integration)
```bash
# Firebase setup (when ready)
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_storage
```

---

## 📞 Support & Resources

### Documentation Links
- [PROGRESS.md](PROGRESS.md) - Current development status
- [Requirements.md](Requirements.md) - Complete feature specifications
- [Development-Phases.md](Development-Phases.md) - Detailed phase breakdown
- [README.md](README.md) - Project overview

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Community](https://flutter.dev/community)

### Getting Help
1. Check the troubleshooting section above
2. Review the [Flutter documentation](https://flutter.dev/docs)
3. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
4. Check [GitHub Issues](https://github.com/flutter/flutter/issues)

---

**Last Updated**: June 15, 2025  
**Next Update**: Start of Phase 2
