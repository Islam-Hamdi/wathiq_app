# Wathiq Flutter App - Complete Setup Guide

**Version:** 1.0.0  
**Author:** Manus AI  
**Date:** August 2025  

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Firebase Setup](#firebase-setup)
4. [Flutter Project Setup](#flutter-project-setup)
5. [Configuration](#configuration)
6. [Running the Application](#running-the-application)
7. [Building for Production](#building-for-production)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)
10. [Project Structure](#project-structure)
11. [Features Overview](#features-overview)
12. [Development Guidelines](#development-guidelines)

---

## Project Overview

Wathiq is a trust-based, interest-free lending application built with Flutter and Firebase. The app enables users to borrow and lend money within their social networks using a guarantor system that promotes community trust and Sharia-compliant financial practices.

### Key Features

- **User Authentication**: Secure Firebase Authentication with email/password
- **Trust-Based Lending**: Community-driven loan requests with guarantor system
- **Firestore Integration**: Real-time data synchronization and offline support
- **iOS-Style UI**: Premium, minimal design with trust-focused user experience
- **Multi-language Support**: English and Arabic with RTL support
- **Circle Management**: Create and manage trust circles within communities
- **Dashboard Analytics**: Comprehensive lending and borrowing statistics

### Technology Stack

- **Frontend**: Flutter 3.16.9 with Material Design 3
- **Backend**: Firebase (Firestore, Authentication, Cloud Functions)
- **State Management**: Provider pattern
- **Navigation**: Go Router for declarative routing
- **Localization**: Flutter Intl for multi-language support

---


## Prerequisites

Before setting up the Wathiq application, ensure you have the following tools and accounts configured on your development machine.

### Development Environment Requirements

**Flutter SDK**: Version 3.16.9 or later is required for this project. The application utilizes Material Design 3 features and modern Flutter APIs that require this minimum version. You can download Flutter from the official website at https://flutter.dev/docs/get-started/install.

**Dart SDK**: Comes bundled with Flutter SDK. The project requires Dart 3.2.6 or later for null safety and modern language features.

**IDE Requirements**: While you can use any text editor, we recommend using one of the following for the best development experience:
- **Android Studio**: Provides excellent Flutter support with built-in emulators and debugging tools
- **Visual Studio Code**: Lightweight option with Flutter and Dart extensions
- **IntelliJ IDEA**: Professional IDE with comprehensive Flutter plugin support

**Platform-Specific Requirements**:

For **Android Development**:
- Android Studio with Android SDK 21 or higher
- Android Virtual Device (AVD) or physical Android device for testing
- Java Development Kit (JDK) 8 or later

For **iOS Development** (macOS only):
- Xcode 12.0 or later
- iOS Simulator or physical iOS device for testing
- CocoaPods for dependency management
- Valid Apple Developer account for device testing and App Store deployment

### Firebase Account Setup

A Firebase project is essential for the application's backend services. You'll need:

**Google Account**: Required to access Firebase Console at https://console.firebase.google.com

**Firebase Project**: Create a new project specifically for Wathiq or use an existing one. The project will host:
- Firestore Database for real-time data storage
- Firebase Authentication for user management
- Firebase Storage for file uploads (future feature)
- Firebase Cloud Functions for server-side logic (optional)

**Billing Account**: While Firebase offers a generous free tier, production applications may require the Blaze (pay-as-you-go) plan for:
- Increased Firestore read/write limits
- Cloud Functions execution
- Enhanced security rules
- Advanced analytics

### Development Tools

**Git**: Version control system for code management and collaboration. Install from https://git-scm.com/

**Node.js**: Required for Firebase CLI and various development tools. Install LTS version from https://nodejs.org/

**Firebase CLI**: Command-line interface for Firebase project management:
```bash
npm install -g firebase-tools
```

**Flutter Doctor**: Verify your Flutter installation by running:
```bash
flutter doctor
```

This command checks for any missing dependencies and provides guidance for resolving issues.

---


## Firebase Setup

Firebase configuration is crucial for the Wathiq application's functionality. This section provides detailed steps for setting up Firebase services including Authentication, Firestore Database, and platform-specific configurations.

### Creating a Firebase Project

Navigate to the Firebase Console at https://console.firebase.google.com and sign in with your Google account. Click "Create a project" and follow these steps:

**Project Creation**:
1. Enter "Wathiq" as your project name (or your preferred name)
2. Choose whether to enable Google Analytics (recommended for production)
3. Select or create a Google Analytics account if enabled
4. Click "Create project" and wait for initialization

**Project Settings Configuration**:
Once your project is created, access the project settings by clicking the gear icon next to "Project Overview". Here you'll configure essential project details:

- **Project ID**: Note this identifier as it will be used in configuration files
- **Public Settings**: Configure your project's public-facing name and description
- **Default GCP Resource Location**: Choose a region close to your target users for optimal performance

### Firestore Database Setup

Firestore serves as the primary database for user data, loan requests, circles, and guarantor information. Setting up Firestore requires careful consideration of security rules and data structure.

**Database Creation**:
1. Navigate to "Firestore Database" in the Firebase Console sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development (we'll configure security rules later)
4. Select a database location close to your users for optimal performance
5. Click "Done" to create the database

**Security Rules Configuration**:
The default test mode rules allow unrestricted access, which is unsuitable for production. Replace the default rules with the following secure configuration:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Loan documents - borrowers can create, all authenticated users can read
    match /loans/{loanId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.borrowerId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.borrowerId || 
         request.auth.uid == resource.data.lenderId);
    }
    
    // Circles - members can read, owners can write
    match /circles/{circleId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.ownerId || 
         request.auth.uid in resource.data.memberIds);
      allow write: if request.auth != null && request.auth.uid == resource.data.ownerId;
    }
    
    // Guarantor requests - involved parties can read/write
    match /guarantor_requests/{requestId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.borrowerId || 
         request.auth.uid == resource.data.guarantorId);
    }
  }
}
```

**Database Indexes**:
Firestore requires composite indexes for complex queries. The application will automatically prompt you to create necessary indexes when running queries, or you can pre-create them using the Firebase Console.

### Firebase Authentication Setup

Authentication enables secure user registration and login functionality with email/password and future social login options.

**Authentication Configuration**:
1. Navigate to "Authentication" in the Firebase Console
2. Click "Get started" if this is your first time
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" provider
5. Optionally enable "Email link (passwordless sign-in)" for enhanced user experience

**Advanced Authentication Settings**:
Configure additional security measures in the Authentication settings:

- **Authorized Domains**: Add your production domain(s) for web deployment
- **Password Policy**: Set minimum password requirements (default 6 characters is acceptable)
- **User Actions**: Configure email templates for password reset and email verification
- **Blocking Functions**: Set up Cloud Functions to block suspicious activities (advanced feature)

### Platform-Specific Configuration

Each platform (Android, iOS, Web) requires specific configuration files that connect your Flutter app to Firebase services.

**Android Configuration**:

1. In Firebase Console, click "Add app" and select Android
2. Enter your Android package name (com.wathiq.app by default)
3. Optionally add app nickname and SHA-1 certificate fingerprint
4. Download the `google-services.json` file
5. Place the file in `android/app/` directory of your Flutter project
6. The project is already configured with necessary Gradle plugins

**iOS Configuration**:

1. In Firebase Console, click "Add app" and select iOS
2. Enter your iOS bundle ID (com.wathiq.app by default)
3. Optionally add app nickname and App Store ID
4. Download the `GoogleService-Info.plist` file
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag the plist file into the Runner project in Xcode
7. Ensure the file is added to the Runner target

**Web Configuration** (Optional):

1. In Firebase Console, click "Add app" and select Web
2. Enter your app nickname
3. Copy the Firebase configuration object
4. Create `web/firebase-config.js` with the configuration
5. Add the script tag to `web/index.html`

### Firebase CLI Authentication

Authenticate the Firebase CLI with your Google account to enable deployment and management features:

```bash
firebase login
```

This opens a browser window for Google authentication. After successful login, you can manage your Firebase projects from the command line.

**Project Initialization**:
In your Flutter project directory, initialize Firebase:

```bash
firebase init
```

Select the following features:
- Firestore: Configure security rules and indexes
- Functions: Set up Cloud Functions (optional)
- Hosting: Configure web hosting (if deploying web version)

---


## Flutter Project Setup

This section covers the complete setup process for the Wathiq Flutter application, including dependency installation, configuration, and initial project preparation.

### Project Installation

**Cloning the Repository**:
If you received the project as a zip file, extract it to your desired location. If using version control, clone the repository:

```bash
git clone <repository-url>
cd wathiq_app
```

**Dependency Installation**:
The project uses several Flutter packages for Firebase integration, state management, and UI components. Install all dependencies by running:

```bash
flutter pub get
```

This command reads the `pubspec.yaml` file and downloads all required packages including:

- **firebase_core**: Core Firebase SDK for Flutter
- **cloud_firestore**: Firestore database integration
- **firebase_auth**: Authentication services
- **provider**: State management solution
- **go_router**: Declarative routing system
- **flutter_localizations**: Internationalization support
- **shared_preferences**: Local data persistence
- **uuid**: Unique identifier generation

**Asset Configuration**:
The project includes the Wathiq logo and other assets. Ensure all assets are properly configured in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/localization/
```

**Font Configuration**:
The application uses SF Pro font family for iOS-style typography. If you have the SF Pro font files, place them in `assets/fonts/` directory. Otherwise, the system will fall back to default fonts.

### Code Generation and Build Setup

**Platform-Specific Setup**:

For **Android**:
1. Ensure `android/app/google-services.json` is in place (from Firebase setup)
2. Verify minimum SDK version in `android/app/build.gradle`:
   ```gradle
   minSdkVersion 21
   targetSdkVersion 34
   ```
3. Check that Google Services plugin is applied in `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

For **iOS**:
1. Ensure `ios/Runner/GoogleService-Info.plist` is properly added to Xcode project
2. Open `ios/Runner.xcworkspace` in Xcode (not .xcodeproj)
3. Verify deployment target is iOS 12.0 or later
4. Run `cd ios && pod install` to install CocoaPods dependencies

**Build Configuration**:
The project is configured with different build flavors for development and production:

- **Debug**: Development build with debug symbols and hot reload
- **Profile**: Performance testing build with some optimizations
- **Release**: Production build with full optimizations and obfuscation

### Environment Configuration

**Development Environment**:
Create a `.env` file in the project root for environment-specific configurations:

```env
# Development Configuration
ENVIRONMENT=development
API_BASE_URL=https://your-dev-api.com
ENABLE_LOGGING=true
```

**Firebase Configuration Files**:
Ensure the following Firebase configuration files are in place:

- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)
- `web/firebase-config.js` (Web, if applicable)

**Security Considerations**:
Never commit sensitive configuration files to version control. Add the following to your `.gitignore`:

```gitignore
# Firebase configuration
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
web/firebase-config.js

# Environment files
.env
.env.local
.env.production
```

### Initial Project Verification

**Flutter Doctor Check**:
Verify your Flutter installation and project setup:

```bash
flutter doctor -v
```

This command provides detailed information about your Flutter installation and identifies any issues that need resolution.

**Dependency Analysis**:
Check for dependency conflicts or outdated packages:

```bash
flutter pub deps
flutter pub outdated
```

**Build Verification**:
Perform a test build to ensure everything is configured correctly:

```bash
# Android
flutter build apk --debug

# iOS (macOS only)
flutter build ios --debug --no-codesign
```

### Project Structure Overview

The Wathiq project follows a feature-based architecture with clear separation of concerns:

```
lib/
├── core/                 # Core application configuration
│   ├── theme.dart       # App theme and styling
│   └── constants.dart   # Application constants
├── models/              # Data models
│   ├── user_model.dart
│   ├── loan_model.dart
│   ├── circle_model.dart
│   └── guarantor_model.dart
├── services/            # Business logic and API services
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   └── user_service.dart
├── screens/             # UI screens organized by feature
│   ├── auth/           # Authentication screens
│   ├── home/           # Home and navigation
│   ├── request/        # Loan request functionality
│   ├── circles/        # Circle management
│   ├── guarantor/      # Guarantor features
│   ├── lend/           # Lending functionality
│   ├── dashboard/      # User dashboard
│   └── profile/        # User profile and settings
├── widgets/             # Reusable UI components
│   ├── stat_card.dart
│   ├── loan_card.dart
│   └── circle_card.dart
└── utils/               # Utility functions and helpers
    ├── validators.dart
    └── formatters.dart
```

This structure promotes maintainability, testability, and scalability as the application grows in complexity and features.

---


## Configuration

Proper configuration ensures the Wathiq application functions correctly across different environments and platforms. This section covers essential configuration steps for Firebase integration, app settings, and platform-specific requirements.

### Firebase Configuration Verification

**Connection Testing**:
Before running the application, verify that Firebase is properly configured by checking the connection status. The app includes built-in Firebase initialization that will display connection errors if configuration is incorrect.

**Firestore Rules Deployment**:
Deploy your security rules to Firestore using the Firebase CLI:

```bash
firebase deploy --only firestore:rules
```

**Authentication Settings**:
Verify authentication configuration in the Firebase Console:
1. Ensure Email/Password provider is enabled
2. Configure authorized domains for your deployment environment
3. Set up email templates for password reset and verification

### Application Configuration

**Theme Customization**:
The application uses a comprehensive theme system defined in `lib/core/theme.dart`. You can customize colors, typography, and component styles:

```dart
// Primary color palette
static const Color primaryBlue = Color(0xFF1E3A8A);
static const Color primaryBlueDark = Color(0xFF162B63);
static const Color successGreen = Color(0xFF10B981);
```

**Localization Setup**:
The app supports English and Arabic languages. Localization files should be placed in `assets/localization/` directory:

- `en.json` - English translations
- `ar.json` - Arabic translations

**App Metadata**:
Update application metadata in the following files:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<application
    android:label="Wathiq"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleDisplayName</key>
<string>Wathiq</string>
<key>CFBundleName</key>
<string>Wathiq</string>
```

### Environment-Specific Configuration

**Development Configuration**:
For development builds, enable debug features and logging:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Firebase emulator for local development (optional)
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  
  await FirebaseService.initialize();
  runApp(const WathiqApp());
}
```

**Production Configuration**:
For production builds, ensure all debug features are disabled and security measures are in place:

1. Remove or disable Firebase emulator connections
2. Enable code obfuscation in build commands
3. Configure proper security rules in Firestore
4. Set up proper error reporting and analytics

---

## Running the Application

This section provides comprehensive instructions for running the Wathiq application in different environments and on various platforms.

### Development Environment Setup

**Device Preparation**:

For **Android Testing**:
1. Enable Developer Options on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" seven times
   - Return to Settings and access Developer Options
2. Enable USB Debugging
3. Connect device via USB and authorize debugging when prompted

For **iOS Testing** (macOS only):
1. Connect your iOS device via USB
2. Trust the computer when prompted on the device
3. Ensure your Apple Developer account is configured in Xcode
4. Add your device to your developer account if testing on physical device

**Emulator Setup**:

**Android Emulator**:
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Create new emulator via Android Studio
# Tools > AVD Manager > Create Virtual Device
```

**iOS Simulator** (macOS only):
```bash
# List available simulators
xcrun simctl list devices

# Launch iOS Simulator
open -a Simulator

# Or launch specific simulator
xcrun simctl boot "iPhone 14 Pro"
```

### Running the Application

**Basic Run Commands**:

```bash
# Run on connected device/emulator
flutter run

# Run with hot reload enabled (default in debug mode)
flutter run --hot

# Run in release mode for performance testing
flutter run --release

# Run on specific device
flutter run -d <device_id>

# Run with verbose logging
flutter run -v
```

**Platform-Specific Commands**:

```bash
# Android only
flutter run -d android

# iOS only (macOS)
flutter run -d ios

# Web (if configured)
flutter run -d web-server --web-port 8080
```

**Development Features**:

The application includes several development-friendly features:

- **Hot Reload**: Instantly see changes without losing app state
- **Hot Restart**: Restart the app while maintaining the debugging session
- **Flutter Inspector**: Visual debugging tool for widget hierarchy
- **Performance Overlay**: Monitor app performance in real-time

**Debugging Commands**:
```bash
# Enable performance overlay
flutter run --enable-software-rendering

# Profile mode for performance analysis
flutter run --profile

# Debug with specific build flavor
flutter run --flavor development
```

### Troubleshooting Common Issues

**Firebase Connection Issues**:
If you encounter Firebase connection problems:

1. Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are correctly placed
2. Check that package names match between Firebase Console and app configuration
3. Ensure Firebase project is active and billing is enabled if required
4. Verify internet connectivity and firewall settings

**Build Failures**:
Common build issues and solutions:

**Android Build Issues**:
```bash
# Clean build cache
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get

# Update Gradle wrapper
cd android && ./gradlew wrapper --gradle-version 7.6 && cd ..

# Check for conflicting dependencies
flutter pub deps
```

**iOS Build Issues**:
```bash
# Clean iOS build
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..

# Update CocoaPods
sudo gem install cocoapods
cd ios && pod repo update && pod install && cd ..
```

**Performance Optimization**:
For optimal development experience:

1. Use physical devices for testing when possible
2. Enable multidex for Android if encountering method count limits
3. Use profile builds for performance testing
4. Monitor memory usage with Flutter DevTools

**Hot Reload Issues**:
If hot reload stops working:

1. Save all files and try hot restart (Ctrl+Shift+F5 or Cmd+Shift+F5)
2. Check for syntax errors in recently modified files
3. Restart the debugging session if issues persist
4. Verify that stateful widgets are properly implemented

---


## Building for Production

Production builds require careful preparation to ensure optimal performance, security, and user experience. This section covers the complete process for creating production-ready builds of the Wathiq application.

### Pre-Build Preparation

**Code Review and Testing**:
Before creating production builds, ensure comprehensive testing has been completed:

1. **Unit Tests**: Verify all business logic functions correctly
2. **Widget Tests**: Test UI components and user interactions
3. **Integration Tests**: Validate end-to-end user workflows
4. **Performance Testing**: Profile the app for memory leaks and performance bottlenecks

**Security Audit**:
Conduct a thorough security review:

1. **API Keys**: Ensure no sensitive keys are hardcoded in the application
2. **Firestore Rules**: Verify security rules are properly configured and tested
3. **Authentication**: Test authentication flows and session management
4. **Data Validation**: Ensure all user inputs are properly validated and sanitized

**Asset Optimization**:
Optimize application assets for production:

```bash
# Optimize images
flutter pub run flutter_launcher_icons:main

# Generate app icons for all platforms
flutter pub run flutter_native_splash:create
```

### Android Production Build

**Keystore Generation**:
Create a signing keystore for Android app signing:

```bash
keytool -genkey -v -keystore ~/wathiq-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias wathiq
```

**Keystore Configuration**:
Create `android/key.properties` file:

```properties
storePassword=<your_keystore_password>
keyPassword=<your_key_password>
keyAlias=wathiq
storeFile=<path_to_keystore_file>
```

**Build Configuration**:
Update `android/app/build.gradle` for release signing:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.wathiq.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Production Build Commands**:

```bash
# Build APK for distribution
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build App Bundle for Google Play Store
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Build with specific flavor
flutter build apk --release --flavor production
```

**Build Verification**:
Test the production build thoroughly:

```bash
# Install and test APK
flutter install --release

# Analyze APK size and content
flutter build apk --analyze-size
```

### iOS Production Build

**Apple Developer Account Setup**:
Ensure your Apple Developer account is properly configured:

1. **Certificates**: Create distribution certificates in Apple Developer Portal
2. **Identifiers**: Register your app bundle ID (com.wathiq.app)
3. **Provisioning Profiles**: Create distribution provisioning profiles
4. **App Store Connect**: Set up your app listing in App Store Connect

**Xcode Configuration**:
Configure signing and capabilities in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project and navigate to Signing & Capabilities
3. Configure automatic signing with your Apple Developer account
4. Verify bundle identifier matches your registered app ID
5. Add required capabilities (Push Notifications, Background Modes, etc.)

**Build Configuration**:
Update iOS deployment settings:

```bash
# Set deployment target in ios/Flutter/AppFrameworkInfo.plist
<key>MinimumOSVersion</key>
<string>12.0</string>
```

**Production Build Commands**:

```bash
# Build for iOS device
flutter build ios --release --obfuscate --split-debug-info=build/debug-info

# Build and archive for App Store
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info

# Build with specific configuration
flutter build ios --release --flavor production
```

**App Store Submission**:
Prepare for App Store submission:

1. **Archive**: Create archive in Xcode (Product > Archive)
2. **Validation**: Validate archive before submission
3. **Upload**: Upload to App Store Connect via Xcode Organizer
4. **TestFlight**: Test with internal and external testers
5. **Review**: Submit for App Store review

### Web Production Build (Optional)

If deploying a web version of Wathiq:

**Web Configuration**:
Configure web-specific settings in `web/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Wathiq - Trust-based Lending</title>
  <meta name="description" content="Trust-based, interest-free lending platform">
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

**Web Build Commands**:

```bash
# Build for web deployment
flutter build web --release --web-renderer canvaskit

# Build with base href for subdirectory deployment
flutter build web --base-href /wathiq/
```

### Build Optimization

**Code Obfuscation**:
Enable code obfuscation for enhanced security:

```bash
flutter build apk --obfuscate --split-debug-info=build/debug-info
flutter build ios --obfuscate --split-debug-info=build/debug-info
```

**Tree Shaking**:
Flutter automatically removes unused code, but you can optimize further:

1. **Import Optimization**: Use specific imports instead of library-wide imports
2. **Asset Optimization**: Remove unused assets from pubspec.yaml
3. **Dependency Audit**: Remove unused dependencies

**Performance Optimization**:
Optimize build performance and app size:

```bash
# Analyze bundle size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Profile build performance
flutter build apk --profile
```

---

## Deployment

Deployment strategies for the Wathiq application vary depending on the target platform and distribution method. This section covers comprehensive deployment approaches for mobile app stores, enterprise distribution, and web hosting.

### Google Play Store Deployment

**Play Console Setup**:
Configure your Google Play Console account and app listing:

1. **Developer Account**: Ensure your Google Play Developer account is active and verified
2. **App Creation**: Create a new app in Play Console with the following details:
   - App name: "Wathiq"
   - Default language: English (or your primary market language)
   - App or game: App
   - Free or paid: Free (or paid based on your business model)

**Store Listing Optimization**:
Create compelling store listing content:

**App Description**:
```
Wathiq - Trust-Based Lending

Experience interest-free lending within your trusted community. Wathiq connects borrowers and lenders through a revolutionary guarantor system that promotes financial inclusion while maintaining Sharia compliance.

Key Features:
• Trust-based lending with community guarantors
• Interest-free transactions (Qard Hasan compliant)
• Secure social circles for trusted lending
• Real-time loan tracking and management
• Multi-language support (English/Arabic)
• iOS-style premium user interface

Join thousands of users building financial trust in their communities.
```

**Screenshots and Assets**:
Prepare high-quality screenshots for different device types:
- Phone screenshots (16:9 and 18:9 aspect ratios)
- Tablet screenshots (if supporting tablets)
- Feature graphic (1024 x 500 pixels)
- App icon (512 x 512 pixels)

**Release Management**:
Configure release tracks for staged deployment:

1. **Internal Testing**: Deploy to internal testers for initial validation
2. **Closed Testing**: Limited external testing with selected users
3. **Open Testing**: Public beta testing for broader feedback
4. **Production**: Full public release

**Upload Process**:
```bash
# Build signed App Bundle
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Upload via Play Console or use automated tools
# The generated AAB file will be in build/app/outputs/bundle/release/
```

### Apple App Store Deployment

**App Store Connect Configuration**:
Set up your app in App Store Connect with comprehensive metadata:

**App Information**:
- **Name**: Wathiq
- **Bundle ID**: com.wathiq.app
- **SKU**: WATHIQ_2025 (unique identifier)
- **Primary Language**: English

**Pricing and Availability**:
Configure pricing tiers and geographic availability:
- **Price**: Free (or set appropriate pricing)
- **Availability**: Select target countries/regions
- **App Store Distribution**: Enable for public distribution

**App Store Optimization**:
Create compelling App Store listing:

**App Description**:
```
Wathiq brings trust-based, interest-free lending to your community. Built on Islamic financial principles, our platform enables secure peer-to-peer lending through a innovative guarantor system.

FEATURES:
• Community-driven lending circles
• Sharia-compliant interest-free transactions
• Secure guarantor verification system
• Real-time loan tracking and analytics
• Bilingual support (English/Arabic)
• Premium iOS-native design

SECURITY & TRUST:
• End-to-end encrypted transactions
• Community-verified guarantor system
• Comprehensive user verification
• Transparent lending terms

Join the financial inclusion revolution. Download Wathiq today.
```

**Submission Process**:
```bash
# Build for iOS distribution
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info

# Archive and upload via Xcode
# 1. Open ios/Runner.xcworkspace in Xcode
# 2. Product > Archive
# 3. Upload to App Store Connect
# 4. Submit for review
```

### Enterprise Distribution

**Internal Distribution**:
For enterprise or internal distribution without app stores:

**Android Enterprise**:
```bash
# Build signed APK for enterprise distribution
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Distribute via:
# - Direct APK download with installation instructions
# - Mobile Device Management (MDM) systems
# - Enterprise app stores
```

**iOS Enterprise**:
Requires Apple Developer Enterprise Program:
```bash
# Build with enterprise provisioning profile
flutter build ipa --release --export-options-plist=ios/ExportOptions-Enterprise.plist

# Distribute via:
# - Over-the-air (OTA) installation
# - MDM systems
# - Internal app catalogs
```

### Web Deployment

**Firebase Hosting**:
Deploy web version using Firebase Hosting:

```bash
# Initialize Firebase Hosting
firebase init hosting

# Build web version
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**Custom Web Server**:
Deploy to your own web infrastructure:

```bash
# Build web version
flutter build web --release --base-href /wathiq/

# Upload build/web/ contents to your web server
# Configure web server for single-page application routing
```

**CDN Configuration**:
For optimal performance, configure Content Delivery Network:

1. **Static Assets**: Serve Flutter assets via CDN
2. **Caching**: Configure appropriate cache headers
3. **Compression**: Enable gzip/brotli compression
4. **HTTPS**: Ensure SSL/TLS encryption

### Continuous Integration/Continuous Deployment (CI/CD)

**GitHub Actions Configuration**:
Automate builds and deployments with GitHub Actions:

```yaml
name: Build and Deploy Wathiq

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.9'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk --release
    
  build-ios:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.9'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build ios --release --no-codesign
```

**Deployment Automation**:
Integrate with app store deployment tools:
- **Fastlane**: Automate iOS and Android deployments
- **App Center**: Microsoft's mobile DevOps solution
- **Bitrise**: Mobile-focused CI/CD platform

---


## Troubleshooting

This comprehensive troubleshooting section addresses common issues encountered during development, building, and deployment of the Wathiq application.

### Firebase-Related Issues

**Authentication Problems**:

*Issue*: Users cannot sign in or create accounts
*Solutions*:
1. Verify Firebase Authentication is enabled in Firebase Console
2. Check that Email/Password provider is activated
3. Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) files are correctly placed
4. Verify package name/bundle ID matches Firebase project configuration
5. Check network connectivity and firewall settings

*Issue*: "Firebase project not found" error
*Solutions*:
1. Confirm Firebase project ID in configuration files
2. Verify Firebase CLI is authenticated: `firebase login`
3. Check project permissions in Firebase Console
4. Ensure billing is enabled for production features

**Firestore Database Issues**:

*Issue*: Permission denied errors when accessing Firestore
*Solutions*:
1. Review and update Firestore security rules
2. Ensure user is properly authenticated before database operations
3. Check that document paths and collection names are correct
4. Verify user has appropriate permissions for the requested operation

*Issue*: Slow Firestore queries or timeouts
*Solutions*:
1. Create composite indexes for complex queries
2. Implement proper pagination for large datasets
3. Use offline persistence to improve perceived performance
4. Optimize query structure and reduce unnecessary reads

### Platform-Specific Issues

**Android Build Problems**:

*Issue*: Gradle build failures
*Solutions*:
```bash
# Clean and rebuild
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter build apk

# Update Gradle wrapper
cd android && ./gradlew wrapper --gradle-version 7.6 && cd ..

# Check for dependency conflicts
flutter pub deps
```

*Issue*: "Multidex" errors during build
*Solutions*:
1. Enable multidex in `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

**iOS Build Problems**:

*Issue*: CocoaPods installation failures
*Solutions*:
```bash
# Update CocoaPods
sudo gem install cocoapods

# Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
```

*Issue*: Code signing errors
*Solutions*:
1. Verify Apple Developer account is active
2. Check provisioning profiles in Xcode
3. Ensure bundle ID matches registered app ID
4. Update certificates if expired

### Performance Issues

**App Startup Performance**:

*Issue*: Slow app startup times
*Solutions*:
1. Implement lazy loading for heavy resources
2. Optimize Firebase initialization
3. Use splash screen to mask initialization time
4. Profile app startup with Flutter DevTools

*Issue*: Memory leaks and high memory usage
*Solutions*:
1. Dispose controllers and streams properly
2. Use `const` constructors where possible
3. Implement proper widget lifecycle management
4. Profile memory usage with Flutter Inspector

### Development Environment Issues

**Hot Reload Problems**:

*Issue*: Hot reload not working or causing errors
*Solutions*:
1. Save all files before attempting hot reload
2. Check for syntax errors in recently modified files
3. Restart debugging session: `flutter run`
4. Use hot restart instead: `Ctrl+Shift+F5` or `Cmd+Shift+F5`

*Issue*: Flutter Doctor warnings
*Solutions*:
```bash
# Run comprehensive check
flutter doctor -v

# Common fixes:
# - Update Flutter SDK: flutter upgrade
# - Accept Android licenses: flutter doctor --android-licenses
# - Install Xcode command line tools: xcode-select --install
```

### Network and Connectivity Issues

**API Connection Problems**:

*Issue*: Network requests failing or timing out
*Solutions*:
1. Check internet connectivity on device/emulator
2. Verify Firebase project is active and accessible
3. Test with different network connections (WiFi vs mobile data)
4. Implement proper error handling and retry logic

*Issue*: CORS errors in web deployment
*Solutions*:
1. Configure proper CORS headers on server
2. Use Firebase Hosting for web deployment
3. Implement proxy configuration for development

### Data Synchronization Issues

**Offline Data Problems**:

*Issue*: Data not syncing when back online
*Solutions*:
1. Verify Firestore offline persistence is enabled
2. Check network connectivity detection
3. Implement proper conflict resolution
4. Test offline scenarios thoroughly

*Issue*: Inconsistent data across devices
*Solutions*:
1. Use Firestore real-time listeners
2. Implement proper data validation
3. Handle concurrent modifications appropriately
4. Use transactions for critical operations

---

## Project Structure

Understanding the Wathiq project structure is essential for effective development and maintenance. This section provides a detailed breakdown of the codebase organization and architectural decisions.

### Directory Structure

```
wathiq_app/
├── android/                 # Android-specific configuration
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── res/         # Android resources
│   │   ├── build.gradle     # App-level Gradle configuration
│   │   └── google-services.json  # Firebase configuration
│   ├── gradle/              # Gradle wrapper
│   └── build.gradle         # Project-level Gradle configuration
├── ios/                     # iOS-specific configuration
│   ├── Runner/
│   │   ├── Info.plist       # iOS app configuration
│   │   ├── GoogleService-Info.plist  # Firebase configuration
│   │   └── Assets.xcassets/ # iOS app icons and images
│   ├── Runner.xcodeproj/    # Xcode project file
│   └── Runner.xcworkspace/  # Xcode workspace (use this)
├── lib/                     # Main Flutter application code
│   ├── core/               # Core application configuration
│   ├── models/             # Data models and entities
│   ├── services/           # Business logic and API services
│   ├── screens/            # UI screens organized by feature
│   ├── widgets/            # Reusable UI components
│   ├── utils/              # Utility functions and helpers
│   └── main.dart           # Application entry point
├── assets/                 # Application assets
│   ├── images/             # Image assets
│   ├── fonts/              # Custom fonts
│   └── localization/       # Translation files
├── test/                   # Unit and widget tests
├── integration_test/       # Integration tests
├── web/                    # Web-specific configuration (optional)
├── pubspec.yaml            # Flutter dependencies and configuration
├── README.md               # Project documentation
└── SETUP_GUIDE.md          # This setup guide
```

### Core Architecture

**lib/core/**: Contains fundamental application configuration and shared utilities.

- `theme.dart`: Comprehensive theme configuration including colors, typography, and component styles
- `constants.dart`: Application-wide constants and configuration values
- `app_config.dart`: Environment-specific configuration management

**lib/models/**: Data models representing business entities with proper serialization.

- `user_model.dart`: User entity with authentication and profile information
- `loan_model.dart`: Loan request and transaction data structure
- `circle_model.dart`: Trust circle and community group representation
- `guarantor_model.dart`: Guarantor request and confirmation data

**lib/services/**: Business logic layer handling data operations and external integrations.

- `firebase_service.dart`: Core Firebase configuration and utilities
- `auth_service.dart`: Authentication operations and user management
- `user_service.dart`: User data operations and profile management
- `loan_service.dart`: Loan creation, management, and tracking
- `circle_service.dart`: Circle creation and member management

### Screen Organization

**lib/screens/**: Feature-based screen organization promoting modularity and maintainability.

**Authentication Flow** (`auth/`):
- `auth_wrapper.dart`: Authentication state management and routing
- `login_screen.dart`: User login interface with validation
- `signup_screen.dart`: User registration with comprehensive form validation
- `forgot_password_screen.dart`: Password reset functionality

**Home and Navigation** (`home/`):
- `home_shell.dart`: Main navigation structure with bottom bar
- `home_screen.dart`: Dashboard with quick actions and statistics
- `navigation_service.dart`: Centralized navigation management

**Loan Management** (`request/`, `lend/`):
- `request_loan_screen.dart`: Loan request form with guarantor selection
- `loan_detail_screen.dart`: Detailed loan information and management
- `lend_screen.dart`: Available loan requests for lenders
- `loan_history_screen.dart`: User's lending and borrowing history

**Community Features** (`circles/`, `guarantor/`):
- `circles_screen.dart`: Trust circle management and creation
- `circle_detail_screen.dart`: Individual circle information and members
- `guarantor_screen.dart`: Guarantor requests and confirmations
- `guarantor_detail_screen.dart`: Detailed guarantor request information

### Widget Architecture

**lib/widgets/**: Reusable UI components following atomic design principles.

**Atomic Components**:
- `primary_button.dart`: Consistent primary action buttons
- `secondary_button.dart`: Secondary action buttons with proper styling
- `text_input.dart`: Standardized text input fields with validation
- `loading_indicator.dart`: Consistent loading states across the app

**Molecular Components**:
- `stat_card.dart`: Statistical information display cards
- `loan_card.dart`: Loan request and history display components
- `circle_card.dart`: Trust circle information cards
- `user_avatar.dart`: User profile image with fallback handling

**Organism Components**:
- `loan_request_form.dart`: Complete loan request form with validation
- `circle_member_list.dart`: Circle member management interface
- `dashboard_stats.dart`: Comprehensive dashboard statistics display

### State Management Architecture

The application uses Provider pattern for state management with clear separation of concerns:

**Authentication State**:
```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  
  // Authentication methods and state management
}
```

**Application State**:
```dart
class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  
  // App-wide state management
}
```

**Feature-Specific State**:
Each major feature has its own provider for localized state management:
- `LoanProvider`: Loan-related state and operations
- `CircleProvider`: Circle management state
- `UserProvider`: User profile and preferences state

### Testing Structure

**test/**: Comprehensive testing suite covering different aspects of the application.

**Unit Tests**:
- `models/`: Test data model serialization and business logic
- `services/`: Test service layer operations and API interactions
- `utils/`: Test utility functions and helpers

**Widget Tests**:
- `widgets/`: Test individual widget behavior and rendering
- `screens/`: Test screen-level functionality and user interactions

**Integration Tests**:
- `integration_test/`: End-to-end testing of complete user workflows
- `firebase_test/`: Firebase integration and data flow testing

---

## Features Overview

The Wathiq application implements a comprehensive trust-based lending platform with multiple interconnected features designed to promote financial inclusion and community trust.

### Authentication System

**User Registration and Login**:
The authentication system provides secure user onboarding with comprehensive validation and user experience optimization. New users can create accounts using email and password authentication, with optional invite codes for community-based onboarding. The registration process includes username availability checking, password strength validation, and terms of service acceptance.

**Security Features**:
- Email verification for account activation
- Password reset functionality with secure token generation
- Session management with automatic token refresh
- Multi-factor authentication support (future enhancement)
- Account lockout protection against brute force attacks

### Trust-Based Lending Core

**Loan Request System**:
Users can create detailed loan requests specifying the amount, purpose, repayment terms, and required guarantors. The system supports multiple currencies with QAR as the default, reflecting the Middle Eastern market focus. Each loan request includes comprehensive information about the borrower's needs and repayment capacity.

**Guarantor Network**:
The innovative guarantor system allows users to invite trusted contacts to vouch for their loan requests. Guarantors receive notifications and can review loan details before confirming their support. The system tracks guarantor relationships and builds trust scores based on successful loan completions.

**Lending Marketplace**:
Potential lenders can browse available loan requests filtered by amount, category, trust score, and guarantor confirmation status. The marketplace provides comprehensive information about each borrower, including their trust history and community connections.

### Community Trust Circles

**Circle Creation and Management**:
Users can create trust circles representing different communities such as family, friends, colleagues, or religious groups. Circle creators can invite members, set circle-specific lending terms, and manage member permissions. Each circle maintains its own trust statistics and lending history.

**Member Verification**:
Circle members undergo verification processes appropriate to their community context. This may include identity verification, community vouching, or meeting attendance requirements. Verified members gain access to circle-specific lending opportunities and enhanced trust scores.

### Financial Tracking and Analytics

**Personal Dashboard**:
Each user has access to a comprehensive dashboard displaying their lending activity, borrowing history, trust score, and financial statistics. The dashboard provides insights into repayment patterns, successful transactions, and community engagement metrics.

**Trust Score Algorithm**:
The application calculates dynamic trust scores based on multiple factors including successful loan repayments, guarantor confirmations, community engagement, and peer reviews. Trust scores influence lending opportunities and interest rates within the platform.

### Sharia Compliance Features

**Interest-Free Transactions**:
All lending transactions follow Islamic financial principles, specifically Qard Hasan (benevolent loans) and Kafala (guarantee) structures. The platform ensures no interest charges while maintaining sustainable lending practices through community trust mechanisms.

**Ethical Guidelines**:
The application includes built-in ethical guidelines for lending practices, ensuring transactions align with Islamic values and promote social welfare. Users receive education about responsible lending and borrowing practices.

### Multi-Language and Cultural Support

**Localization**:
The application supports English and Arabic languages with proper right-to-left (RTL) text rendering for Arabic content. All user interface elements, including forms, navigation, and content, adapt to the selected language preference.

**Cultural Adaptation**:
The user interface and user experience design reflect Middle Eastern cultural preferences and expectations. This includes appropriate color schemes, typography choices, and interaction patterns that resonate with the target audience.

---

## Development Guidelines

Effective development of the Wathiq application requires adherence to established coding standards, architectural principles, and best practices that ensure maintainability, scalability, and team collaboration.

### Code Style and Standards

**Dart Code Formatting**:
The project follows official Dart style guidelines with automated formatting using `dart format`. All code should be formatted before committing:

```bash
# Format all Dart files
dart format lib/ test/

# Check formatting without making changes
dart format --set-exit-if-changed lib/ test/
```

**Naming Conventions**:
- **Classes**: PascalCase (e.g., `UserModel`, `AuthService`)
- **Variables and Functions**: camelCase (e.g., `userName`, `getUserData()`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_LOAN_AMOUNT`)
- **Files**: snake_case (e.g., `user_service.dart`, `loan_model.dart`)

**Documentation Standards**:
All public APIs must include comprehensive documentation:

```dart
/// Authenticates user with email and password.
/// 
/// Returns [UserCredential] on successful authentication.
/// Throws [AuthException] if authentication fails.
/// 
/// Example:
/// ```dart
/// final credential = await authService.signIn(
///   email: 'user@example.com',
///   password: 'securePassword',
/// );
/// ```
Future<UserCredential> signIn({
  required String email,
  required String password,
}) async {
  // Implementation
}
```

### Architecture Principles

**Separation of Concerns**:
The application maintains clear separation between presentation, business logic, and data layers:

- **Presentation Layer**: Widgets and screens handle only UI rendering and user interactions
- **Business Logic Layer**: Services contain application logic and state management
- **Data Layer**: Models and repositories handle data persistence and external APIs

**Dependency Injection**:
Use Provider pattern for dependency injection and state management:

```dart
MultiProvider(
  providers: [
    Provider<AuthService>(create: (_) => AuthService()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ProxyProvider<AuthService, LoanService>(
      update: (_, auth, __) => LoanService(auth),
    ),
  ],
  child: MyApp(),
)
```

**Error Handling**:
Implement comprehensive error handling with user-friendly messages:

```dart
try {
  await loanService.createLoan(loanData);
  _showSuccessMessage('Loan request created successfully');
} on NetworkException catch (e) {
  _showErrorMessage('Network error: Please check your connection');
} on ValidationException catch (e) {
  _showErrorMessage('Invalid data: ${e.message}');
} catch (e) {
  _showErrorMessage('An unexpected error occurred');
  logger.error('Loan creation failed', error: e);
}
```

### Testing Strategy

**Unit Testing**:
Write comprehensive unit tests for all business logic:

```dart
group('AuthService', () {
  late AuthService authService;
  
  setUp(() {
    authService = AuthService();
  });
  
  test('should authenticate user with valid credentials', () async {
    // Arrange
    const email = 'test@example.com';
    const password = 'password123';
    
    // Act
    final result = await authService.signIn(
      email: email,
      password: password,
    );
    
    // Assert
    expect(result, isA<UserCredential>());
    expect(result.user?.email, equals(email));
  });
});
```

**Widget Testing**:
Test widget behavior and user interactions:

```dart
testWidgets('LoginScreen should validate email input', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));
  
  // Find email input field
  final emailField = find.byKey(Key('email_field'));
  
  // Enter invalid email
  await tester.enterText(emailField, 'invalid-email');
  await tester.pump();
  
  // Verify validation error appears
  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

**Integration Testing**:
Test complete user workflows:

```dart
void main() {
  group('Loan Request Flow', () {
    testWidgets('should create loan request successfully', (tester) async {
      // Setup test environment
      await tester.pumpWidget(MyApp());
      
      // Navigate to loan request screen
      await tester.tap(find.text('Request Loan'));
      await tester.pumpAndSettle();
      
      // Fill loan request form
      await tester.enterText(find.byKey(Key('amount_field')), '5000');
      await tester.enterText(find.byKey(Key('reason_field')), 'Medical expenses');
      
      // Submit form
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      
      // Verify success message
      expect(find.text('Loan request created'), findsOneWidget);
    });
  });
}
```

### Performance Optimization

**Widget Optimization**:
- Use `const` constructors wherever possible
- Implement `shouldRebuild` methods for complex widgets
- Avoid unnecessary widget rebuilds with proper state management
- Use `ListView.builder` for large lists instead of `ListView`

**Memory Management**:
- Dispose controllers and streams in widget `dispose()` methods
- Use weak references for callback functions
- Implement proper image caching and disposal
- Monitor memory usage with Flutter DevTools

**Network Optimization**:
- Implement request caching for frequently accessed data
- Use pagination for large datasets
- Compress images and assets
- Implement offline-first architecture with Firestore

### Security Best Practices

**Data Validation**:
Validate all user inputs on both client and server sides:

```dart
class LoanValidator {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    
    if (amount > MAX_LOAN_AMOUNT) {
      return 'Amount exceeds maximum limit';
    }
    
    return null;
  }
}
```

**Secure Storage**:
- Never store sensitive data in plain text
- Use Flutter Secure Storage for sensitive information
- Implement proper session management
- Use HTTPS for all network communications

**Authentication Security**:
- Implement proper password policies
- Use secure token storage
- Implement session timeout mechanisms
- Add rate limiting for authentication attempts

This comprehensive setup guide provides all necessary information for successfully developing, building, and deploying the Wathiq trust-based lending application. Following these guidelines ensures a robust, secure, and maintainable codebase that can scale with your community's needs.

---

**Document Information**:
- **Version**: 1.0.0
- **Last Updated**: August 2025
- **Author**: Manus AI
- **License**: Proprietary - Wathiq Application

For additional support or questions regarding the setup process, please refer to the project documentation or contact the development team.

