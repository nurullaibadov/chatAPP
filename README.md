# ChatApp - Real-Time Flutter Chat Application 💬

A production-ready, full-featured real-time chat application built with **Flutter**, **Riverpod** state management, and **Firebase** (Authentication, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging).

---

## 🌟 Key Features

- 🔐 **Authentication**: Email/Password Sign Up & Sign In, Google Sign-In, Password Reset flow.
- 👤 **Profile Management**: Profile picture upload to Firebase Storage, custom status message, online/offline status, and "last seen" timestamp.
- 💬 **Real-Time Messaging**:
  - 1-on-1 private chats & Group chat creation/management.
  - Real-time text, photo image, and voice audio message recording/playback.
  - Message delivery & read receipts (check marks: sent ✔, delivered ✔✔, read ✔✔ blue).
  - "Typing..." indicators.
  - Reply to specific messages, edit text messages, emoji reactions (❤️, 👍, 😂, 😮, 😢, 🔥).
  - Delete for self or delete for everyone.
  - Unread message count badges.
- 🔔 **Push Notifications**: Firebase Cloud Messaging (FCM) integration for foreground & background message popups via `flutter_local_notifications`.
- 🎨 **Theme & Customization**: Dynamic Light Mode and Dark Mode toggle.
- 🚫 **Privacy**: Block & Unblock users, Delete Account flow.

---

## 📁 Clean Architecture Folder Structure

```
lib/
 ├── main.dart                      # Entry point, ProviderScope & Firebase initialization
 ├── firebase_options.dart          # Firebase project configuration options
 ├── core/                          # Design system, theme, constants & shared widgets
 │    ├── constants/                # App & Firestore constants
 │    ├── theme/                    # Light/Dark themes, colors & text styles
 │    ├── utils/                    # Date formatters, snackbars & input validators
 │    └── widgets/                  # Reusable avatar, custom text fields & buttons
 ├── data/                          # Data layer (Models, Repositories & Services)
 │    ├── models/                   # UserModel, MessageModel & ChatModel
 │    ├── repositories/             # AuthRepository, UserRepository & ChatRepository
 │    └── services/                 # AuthService, FirestoreService, StorageService, NotificationService
 ├── domain/                        # State management layer
 │    └── providers/                # Riverpod Providers & Notifiers
 └── presentation/                  # UI Presentation layer
      ├── router/                   # GoRouter navigation configuration
      ├── auth/                     # Login, Register, Forgot Password, Profile Setup
      ├── home/                     # Real-time Chat List Screen
      ├── chat/                     # Real-time Chat Screen, Bubbles, Input & Audio Player
      ├── profile/                  # View & Edit Profile Screens
      ├── contacts/                 # User Search & Group Creation Screens
      └── settings/                 # Settings, Dark Mode, Blocked Users & Logout
```

---

## 🚀 Setup & Firebase Configuration Instructions

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (v3.0.0+).
- Node.js installed (for Firebase CLI).
- A Firebase Project created in the [Firebase Console](https://console.firebase.google.com/).

### 2. Firebase Configuration Setup

#### Android (`google-services.json`)
1. In the Firebase Console, navigate to **Project Settings** -> **General** -> **Your apps**.
2. Click **Add App** -> select **Android**.
3. Set your Android package name (e.g. `com.chatapp.flutter`).
4. Download the generated `google-services.json` file.
5. Place `google-services.json` inside `android/app/`.

#### iOS (`GoogleService-Info.plist`)
1. Click **Add App** -> select **iOS**.
2. Set your iOS Bundle ID (e.g. `com.chatapp.flutter`).
3. Download `GoogleService-Info.plist`.
4. Place `GoogleService-Info.plist` inside `ios/Runner/`.

#### FlutterFire CLI (Alternative automatic config)
Run:
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. Firebase Console Enablements

1. **Firebase Authentication**:
   - Enable **Email/Password** sign-in provider.
   - Enable **Google** sign-in provider.

2. **Cloud Firestore**:
   - Create a Firestore Database in production mode.
   - Update Firestore Security Rules:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if request.auth != null;
         }
       }
     }
     ```

3. **Firebase Storage**:
   - Enable Storage bucket and set security rules:
     ```javascript
     rules_version = '2';
     service firebase.storage {
       match /b/{bucket}/o {
         match /{allPaths=**} {
           allow read, write: if request.auth != null;
         }
       }
     }
     ```

---

## 🏃 Running the Application

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on Emulator / Device**:
   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios
   ```

---

## 🧪 Verification & Code Quality

- Fully compliant with **Dart Null-Safety**.
- Fully structured with **Riverpod StateNotifiers & StreamProviders**.
- All asynchronous Firebase operations wrapped in robust error handlers with user-friendly error banners.
