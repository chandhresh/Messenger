
# Messenger Clone (Flutter + Firebase)

A real-time chat application built using **Flutter** and **Firebase**, featuring a clean Messenger-style interface with authentication, typing indicators, and online/offline status.

---

## 🔹 Features

- Firebase Authentication (sign up & login)
- Real-time Firestore chat
- Typing indicator
- Online and last seen status
- Smooth animations and Material 3 design
- Works on Android and Web

---
| Login | Signup | Firebase |
|--------|---------|-----------|
| ![](login.png) | ![](singup1.png) | ![](firebase.png) |

| User List | Online Users | Chat |
|------------|---------------|------|
| ![](userlist.png) | ![](onlineuser.png) | ![](chat.png) |

| Typing Indicator |
|------------------|
| ![](typing.png) |

### 🎬 Demo Video
You can view the working demo here:

[▶️ Watch Demo](demo.mp4)

---

## 🔹 APK Download

Download the working release APK:  
📦 [messenger_clone.apk](https://github.com/chandhresh/Messenger/raw/main/apk/messenger_clone.apk)

---

## 🔹 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a project (example: `Typing`)
3. Add an **Android app**
   - Package name: `com.example.typing_chat_fixed`
   - Download and place `google-services.json` in `android/app/`
4. Enable:
   - **Email/Password Authentication**
   - **Cloud Firestore**
5. Configure Firebase in your Flutter project:
   ```bash
   flutterfire configure
   flutter pub get
````

---

## 🔹 How to Run

### Run on Web

```bash
flutter run -d chrome
```

### Run on Emulator

```bash
flutter run -d emulator-5554
```

### Build APK

```bash
flutter build apk --release
```

Find the APK in:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔹 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.2.1
  firebase_auth: ^5.3.0
  cloud_firestore: ^6.1.0
  intl: ^0.18.1
```

---

## 🔹 Folder Structure

```
Messenger/
│
├── lib/
│   ├── main.dart
│   └── firebase_options.dart
│
├── screenshorts/
│   ├── login.png
│   ├── signup.png
│   ├── userlist.png
│   ├── chat.png
│   ├── typing.jpg
│   ├── firebase.png
│   └── demo.mp4
│
├── apk/
│   └── messenger_clone.apk
│
└── README.md
```

---

## 🔹 Notes

* Use **two accounts** on different devices to test chatting and typing indicators.
* Make sure your emulator has **internet access** for Firebase.
* Works perfectly on **Flutter Web**.

---

## 🔹 Author

**Project:** Messenger Clone
**Developer:** Chandhresh
**Tech:** Flutter + Firebase
**Version:** 1.0.0
