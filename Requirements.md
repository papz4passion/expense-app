# Expenditure Tracking App Requirements (Flutter + Firebase)

**Last Updated**: June 15, 2025

---

## 📋 Documentation Navigation

| Document | Description |
|----------|-------------|
| **[README.md](README.md)** | 📖 Project overview and quick start guide |
| **[SETUP.md](SETUP.md)** | 🔧 Complete development setup instructions |
| **[PROGRESS.md](PROGRESS.md)** | 📊 Current development progress and status |
| **[Development-Phases.md](Development-Phases.md)** | 🗺️ Complete phase breakdown and timeline |

---

## Overview
Develop a modern expenditure tracking app using Flutter with Firebase as the backend. The app should provide seamless expense management, online data storage, and smart features inspired by new-generation banking apps.

## Core Features

### 1. User Authentication
- Platform-specific authentication for seamless user experience:
  - **iOS/macOS**: Sign in with Apple ID for iCloud integration and data access
  - **Android**: Sign in with Google Account for Google Drive integration and data access
- Support for biometric authentication (Face ID/Touch ID/Fingerprint) for app access
- Secure local authentication with option to skip cloud features for privacy-focused users

### 2. Dashboard
- Home screen with expense summary and financial insights at a glance.
- Visual representation of spending patterns (daily/weekly/monthly).
- Quick actions for adding transactions and viewing detailed reports.
- Customizable widgets to display most relevant financial information.

### 3. Expense Tracking
- Add, edit, and delete expenses and income entries.
- Categorize transactions (e.g., Food, Travel, Shopping, Bills, etc.).
- Intelligent receipt handling with on-device processing:
  - Capture receipt images through camera or import from gallery
  - On-device OCR processing to extract transaction data (merchant, items, prices, date)
  - Store only extracted text data for cloud sync (not raw images) to conserve storage
  - Retain receipt images locally with option to delete after processing
  - **iOS/macOS**: Use Vision API for on-device text recognition
  - **Android**: Use ML Kit Text Recognition for on-device processing
- View transaction history with filters (date, category, amount).
- Support for recurring expenses with customizable frequency (daily, weekly, monthly, yearly).

### 4. Investment Tracking
- Track fixed deposits (FD), recurring deposits (RD), and other investments.
- Record investment details (amount, interest rate, maturity date, institution).
- Set up recurring investments with automatic reminders.
- Calculate expected returns and maturity values.
- Visualize investment portfolio distribution and growth.

### 5. Offline-First Data Storage
- All user data (transactions, categories, settings) stored locally first using SQLite/Hive.
- Platform-specific cloud synchronization for data backup and multi-device access:
  - **iOS/macOS**: Synchronizes with iCloud when internet connection is available
  - **Android**: Synchronizes with Google Drive when internet connection is available
- Background sync mechanism that automatically retries failed uploads.
- Sync status indicators to show pending uploads.
- Conflict resolution strategy for simultaneous edits across devices.
- Retry mechanism for failed uploads with exponential backoff (retries after few hours).

### 6. Platform-Specific Cloud Backup
- **iOS/macOS**: Automatic data backup to iCloud for seamless device migration and data recovery.
  - Utilize iCloud Documents & Data API for encrypted backup of transaction data.
  - Backup includes structured data only (transactions, categories, settings, extracted receipt text).
  - Exclude raw images and large media files from cloud sync to conserve storage.
  - Store only OCR-extracted receipt data as searchable text files, not original images.
  - Automatic restoration when user signs in to iCloud on a new device.
  - Option to manually trigger backup/restore operations.
  - Respect user's iCloud storage settings and provide storage usage information.
  - Handle iCloud availability gracefully (offline mode when iCloud is unavailable).

- **Android**: Automatic data backup to Google Drive for data preservation and device migration.
  - Use Google Drive API with app-specific folder for secure data storage.
  - Encrypted backup of structured data only (transactions, extracted receipt text).
  - Minimize storage footprint by syncing only processed text data from receipts.
  - Automatic backup scheduling (daily/weekly) with user-configurable options.
  - One-tap restore functionality when signing in with Google account on new device.
  - Backup compression to minimize storage usage and upload time.
  - Progress indicators for backup/restore operations with ability to cancel.

- **Cross-Platform Considerations**:
  - Maintain data format compatibility between platforms for potential future migration.
  - Optimize cloud storage usage by syncing only essential text data, never raw receipt images.
  - Store standardized receipt text data in a cross-platform format for interoperability.
  - Provide export functionality as fallback for users switching between iOS and Android.
  - Clear user communication about which cloud service is being used for backup.
  - Privacy-first approach: all data encrypted before cloud upload, encryption keys managed locally.
  - Present clear storage usage analytics showing space saved by not syncing images.

### 7. Theming
- Default theme automatically follows system theme (light/dark).
- Option to override system theme with user preference.
- UI/UX inspired by new-gen banking apps (e.g., Monzo, Revolut, NiyoX, Fi).
- Smooth transitions, modern color palettes, and rounded UI elements.
- Adaptive layouts that work well in both light and dark modes.

### 8. SMS Parsing for Debits/Credits
- Read SMS messages (with user permission) to detect debit/credit alerts from banks.
- Prompt user to classify or add detected transactions.
- Pre-fill transaction details from SMS (amount, merchant, date).
- Implement duplicate detection using transaction fingerprinting (amount + date + merchant hash) to prevent duplicate entries from SMS parsing.

### 9. Daily Expense Reminder
- Send a daily notification/reminder at user-configurable time to enter expenses.
- Option to snooze or dismiss reminders.

### 10. QR Code Payment & Tracking
- Scan QR codes (UPI/Bharat QR) to initiate payments.
- Extract payee details from QR code.
- Prompt user to enter payment amount.
- Invoke UPI apps for payment (using platform-specific intents).
- Automatically add the payment as an expense entry after successful transaction.

### 11. Gmail Integration for Transaction Parsing
- Read transactional emails from Gmail (with user permission and OAuth authentication).
- Detect debit/credit alerts from banks and financial institutions in the user's inbox.
- Automatically extract transaction details (amount, merchant, date, type) from email content.
- Add detected transactions as expenses or income entries, with user confirmation and option to edit.
- Support for major Indian banks and standard email formats (similar to CRED app functionality).
- Ensure privacy and security: process emails on-device where possible, request only necessary permissions, and provide clear consent flows.
- Perform mail parsing in background threads to avoid blocking the UI and maintain app responsiveness.
- Implement stage-based completion with checkpoint saving - store partial parsing state in local database.
- Resume parsing from last saved checkpoint if app is quit or interrupted during the process.
- Progress indicators to show parsing status and allow users to monitor background email processing.
- Implement duplicate detection using transaction fingerprinting (amount + date + merchant/description hash) to prevent duplicate entries from email parsing.

### 12. Bank Statement Upload & Parsing
- Upload bank statements in PDF or Excel format directly into the app.
- Parse PDF and Excel files locally within the app to ensure user data privacy and security.
- Extract transaction details (date, amount, description, balance) from various bank statement formats.
- Support for major Indian bank statement formats (SBI, HDFC, ICICI, Axis, etc.).
- Automatic categorization of transactions based on merchant names and descriptions.
- Allow users to review and edit parsed transactions before adding them to their expense records.
- Progress indicators for file parsing with ability to cancel ongoing operations.
- Store parsing templates and rules locally to improve accuracy over time.
- Handle large statement files efficiently with chunked processing to maintain app responsiveness.
- Implement duplicate detection using transaction fingerprinting (amount + date + description hash) to prevent duplicate entries from statement parsing.

### 13. Analytics & Insights
- Show daily, weekly, and monthly spending summaries.
- Visualize expenses by category (pie/bar charts).
- Set monthly budgets and track progress.
- Track investment performance and portfolio growth over time.

### 14. Security & Privacy
- Secure local data storage (encrypted preferences).
- Option to enable biometric authentication (Face ID/Touch ID).
- Clear privacy policy and permission explanations.

### 15. Duplicate Transaction Prevention
- Implement a comprehensive duplicate detection system across all transaction input methods (manual entry, SMS, email, bank statements).
- Use transaction fingerprinting algorithm combining: transaction amount, date, merchant/description text, and account information.
- Maintain a local duplicate detection database with transaction hashes for fast lookup.
- When potential duplicates are detected, show user-friendly confirmation dialogs with transaction details for manual review.
- Allow users to merge similar transactions or mark them as separate legitimate entries.
- Configurable duplicate detection sensitivity settings (strict, moderate, lenient) based on user preference.
- Cross-reference transactions across different data sources (SMS vs Email vs Statement) to identify and resolve conflicts.

### 15. On-Device AI Enhancement
- **Receipt OCR & Processing:**
  - iOS/macOS: Use Vision framework for advanced receipt scanning and text extraction
  - Android: Use ML Kit for receipt OCR and structured data extraction
  - Automatic extraction of merchant name, transaction date, line items, and total amount
  - Receipt classification by expense category based on recognized merchant and items
  - Convert unstructured receipt data into structured, searchable transaction records
  - Store processed data for cloud sync instead of raw images to conserve space

- **Intelligent Processing:**
  - Leverage iOS Core ML and Create ML frameworks for intelligent expense categorization
  - Implement Natural Language framework for parsing transaction descriptions
  - Deploy on-device machine learning models for personalized spending pattern recognition
  - Use Speech framework for voice-based expense entry with natural language processing
  - Implement predictive analytics to forecast spending trends and budget recommendations
  - Smart merchant recognition using on-device models trained on user's transaction history
  - Automated expense categorization that learns from user's manual corrections
  - Intelligent duplicate detection using ML models that understand transaction context
  - Privacy-first AI processing - all ML inference happens on-device without data sharing

## Technical Stack
- **Frontend:** Flutter (Dart)
- **Local Storage:** SQLite/Hive for offline-first data persistence
- **Authentication:** 
  - iOS/macOS: Sign in with Apple ID integration
  - Android: Google Sign-In integration
- **Cloud Storage & Sync:** 
  - iOS/macOS: iCloud Documents & Data API for backup/sync (text data only)
  - Android: Google Drive API for backup/sync (text data only)
- **Receipt Processing:**
  - iOS/macOS: Vision framework for OCR and text recognition
  - Android: ML Kit Text Recognition for receipt parsing
  - Local image storage with automatic cleanup options
- **Sync Management:** Custom synchronization service with queue management and retry logic
- **Connectivity:** Network connectivity monitoring for automatic sync triggering
- **Notifications:** Local notifications, platform-specific push notifications
- **QR/UPI:** Platform channels for QR scanning and UPI intent invocation
- **SMS Parsing:** Platform channels for SMS read access (Android only)
- **Gmail Integration:** OAuth for Gmail API access, on-device processing for transaction parsing
- **Statement Parsing:** Local PDF and Excel parsing libraries for bank statement processing
- **On-Device AI (iOS):** Core ML, Vision, Natural Language, Speech frameworks for intelligent processing

## Stretch Goals
- Export data to CSV/Excel
- Multi-currency support
- Shared/group expenses

---

## 📚 Related Documentation

- **[PROGRESS.md](PROGRESS.md)** - Track current implementation status of these requirements
- **[Development-Phases.md](Development-Phases.md)** - See how these requirements are broken down into phases
- **[SETUP.md](SETUP.md)** - Set up your development environment to implement these features
- **[README.md](README.md)** - Project overview and quick start guide

---

**Note:**
- All features must comply with app store policies and user privacy best practices.
- The app should be responsive and accessible.

**Last Updated**: June 15, 2025
