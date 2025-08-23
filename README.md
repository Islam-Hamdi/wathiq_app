# Wathiq - Trust-Based P2P Lending Platform

<p align="center">
  <img src="assets/images/wathiq_logo.png" alt="Wathiq Logo" width="500"/>
</p>

Wathiq is a Flutter-based mobile application designed to facilitate trust-based lending within communities, adhering to Islamic finance principles such as Qard Hasan (interest-free loans) and Kafala (guarantee).

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Setup](#firebase-setup)
  - [Running the Application](#running-the-application)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)

## Features

Wathiq provides a comprehensive platform for managing personal loans and guarantees within a trusted network. Key features include:

-   **User Authentication:** Secure sign-up, sign-in, and profile management.
-   **Loan Requests:** Users can request loans, specifying amount, currency, reason, and due date.
-   **Guarantor Network:** Borrowers can invite trusted individuals from their network to act as guarantors.
-   **Guarantor Confirmation:** Guarantors can review and confirm/decline loan requests.
-   **Lending Opportunities:** Users can browse and fund open loan requests from their community.
-   **Trust Circles:** (Conceptual, can be expanded) Facilitate lending within defined trusted groups.
-   **Dashboard:** Personalized overview of borrowed, lent, and guaranteed loans, along with a trust score.
-   **Multi-language Support:** Designed for easy integration of multiple languages (e.g., English and Arabic).
-   **Firestore Integration:** Real-time data synchronization and secure data storage using Google Cloud Firestore.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Before you begin, ensure you have the following installed:

-   **Flutter SDK:** [Install Flutter](https://flutter.dev/docs/get-started/install)
-   **Firebase CLI:** [Install Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
-   **Node.js and npm:** Required for Firebase CLI.
-   **IDE:** Visual Studio Code with Flutter and Dart extensions, or Android Studio with Flutter plugin.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/wathiq.git
    cd wathiq
    ```
    *(Note: Replace `YOUR_USERNAME/wathiq.git` with the actual repository URL once it's hosted on GitHub.)*

2.  **Get Flutter packages:**
    ```bash
    flutter pub get
    ```

### Firebase Setup

Wathiq uses Firebase for authentication and database. You need to set up your own Firebase project.

1.  **Create a Firebase Project:**
    -   Go to the [Firebase Console](https://console.firebase.google.com/).
    -   Click "Add project" and follow the on-screen instructions. Remember your Project ID.

2.  **Register your app(s) with Firebase:**
    -   In your Firebase project, add an iOS, Android, and/or Web app.
    -   Follow the instructions to download `GoogleService-Info.plist` (for iOS), `google-services.json` (for Android), and/or get your Firebase config (for Web).
    -   Place `GoogleService-Info.plist` in `ios/Runner/`.
    -   Place `google-services.json` in `android/app/`.

3.  **Enable Firebase Services:**
    -   In the Firebase Console, navigate to:
        -   **Authentication:** Enable "Email/Password" provider.
        -   **Firestore Database:** Create a new database in production mode. Start in locked mode and then add security rules.

4.  **Firestore Security Rules (Example - adjust as needed for production):**
    ```firestore
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Allow read/write access to authenticated users for their own data
        match /users/{userId} {
          allow read, write: if request.auth.uid == userId;
        }

        // Allow read/re...(truncated)```

### Running the Application

1.  **Connect a device or start an emulator.**

2.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

```
wathiq_app/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   └── theme.dart        # Application theme and color palette
│   ├── models/
│   │   ├── user_model.dart     # Data model for users
│   │   ├── loan_model.dart     # Data model for loans
│   │   ├── circle_model.dart   # Data model for trust circles
│   │   └── guarantor_model.dart # Data model for guarantor requests
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── auth_wrapper.dart # Handles authentication state changes
│   │   │   ├── login_screen.dart   # User login interface
│   │   │   └── signup_screen.dart  # User registration interface
│   │   ├── circles/
│   │   │   └── circles_screen.dart # Screen for managing trust circles
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart # User dashboard with stats and history
│   │   ├── guarantor/
│   │   │   └── guarantor_screen.dart # Screen for guarantor requests
│   │   ├── home/
│   │   │   ├── home_screen.dart    # Main home screen
│   │   │   └── home_shell.dart     # Bottom navigation shell
│   │   ├── lend/
│   │   │   └── lend_screen.dart      # Screen for browsing loan requests to lend
│   │   ├── profile/
│   │   │   └── profile_screen.dart   # User profile management
│   │   └── request/
│   │       └── request_loan_screen.dart # Screen for requesting a loan
│   ├── services/
│   │   ├── auth_service.dart     # Handles Firebase Authentication logic
│   │   ├── firebase_service.dart   # Firebase initialization and common utilities
│   │   ├── user_service.dart     # Manages user data in Firestore
│   │   ├── loan_service.dart     # Manages loan data in Firestore
│   │   ├── circle_service.dart   # Manages trust circle data in Firestore
│   │   └── guarantor_service.dart # Manages guarantor request data in Firestore
│   └── widgets/
│       ├── stat_card.dart        # Reusable widget for displaying statistics
│       └── how_it_works_card.dart # Reusable widget for displaying how-it-works steps
```

## Technologies Used

-   **Flutter:** UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
-   **Dart:** Programming language optimized for UI.
-   **Firebase:** Google's mobile platform that helps you quickly develop high-quality apps.
    -   **Firebase Authentication:** For user authentication.
    -   **Cloud Firestore:** NoSQL document database for storing and syncing data.
-   **Provider:** State management solution for Flutter.

## Contributing

Contributions are welcome! If you have suggestions for improvements or find issues, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.


