<div align="center">
  <img src="https://img.icons8.com/color/144/000000/city-buildings.png" alt="MyCityConnect Logo" height="120" />
  
  # 🏙️ MyCityConnect
  
  **Your All-in-One City Services App**
  
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

  <br>
  <p>
    <b>A modern Flutter application that directly connects you with essential city service providers (Plumbing, Cleaning, Repairs, etc.) in your area.</b>
  </p>
</div>

---

## ✨ Key Features

- 🔐 **Secure Authentication:** Fast and secure Login/Signup using Firebase Authentication.
- 🗂️ **Service Discovery:** Explore various city services listed on a clean, modern dashboard.
- 📅 **Easy Booking System:** Book any service with a single click and seamlessly track your active and past bookings.
- 👤 **Profile Management:** Easily update your personal details and set a custom profile picture.
- 🎨 **Modern Aesthetics:** A beautiful UI built with smooth animations using `lottie` and `flutter_animate`.

---

## 🛠️ Tech Stack & Dependencies

<details>
<summary><b>Click to expand and see the full tech stack</b></summary>
<br>

### 📱 Frontend
- **Framework:** Flutter SDK
- **Language:** Dart
- **UI/UX:** `flutter_animate` for micro-animations, `lottie` for complex vector animations.

### ⚙️ Backend (Firebase)
- **Firebase Auth:** Secure user authentication (`firebase_auth`).
- **Cloud Firestore / Realtime DB:** Live data synchronization and scalable database solutions (`cloud_firestore`, `firebase_database`).
- **Firebase Storage:** Cloud storage for profile pictures and media assets (`firebase_storage`).

### 🔧 Utilities
- `shared_preferences`: Local device storage for maintaining login states and preferences.
- `http`: Handles REST API network calls.
- `intl`: Handles date and time formatting.
- `image_picker`: Access to the device camera and gallery for uploads.
- `url_launcher`: In-app deep linking for phone calls, emails, and external URLs.

</details>

---

## 📂 Project Structure

```text
lib/
├── main.dart               # Entry point of the application
├── models/                 # Data Models (booking_model, service_model)
├── screen/                 # UI Screens (home, login, profile, service_detail)
├── services/               # Backend Logic & APIs (api_service, user_profile)
└── widgets/                # Reusable UI Components (drawer, bottom_sheets)
```

---

## 📥 Download APK

Pre-compiled, architecture-specific release binaries are available for direct download below:

| Architecture | Description | Download |
| :--- | :--- | :---: |
| 📱 **ARM64** | Optimized for modern 64-bit devices (most current phones). | [📥 Download APK](https://github.com/krishflutter993/Advanced-App-Development--MyCityConnect/releases/latest/download/app-arm64-v8a-release.apk) |
| 📱 **ARMv7** | Compatible with older 32-bit Android smartphones. | [📥 Download APK](https://github.com/krishflutter993/Advanced-App-Development--MyCityConnect/releases/latest/download/app-armeabi-v7a-release.apk) |
| 💻 **x86_64** | Tailored for emulator runs and x86_64 compatible architectures. | [📥 Download APK](https://github.com/krishflutter993/Advanced-App-Development--MyCityConnect/releases/latest/download/app-x86_64-release.apk)|
| 🍎 **iOS IPA** | Installable iOS application package for testing and distribution. | [📥 Download IPA](https://github.com/krishflutter993/Advanced-App-Development--MyCityConnect/releases/latest/download/app.ipa) |


---
## 🚀 Getting Started

Follow these steps to run the application locally on your machine:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Android Studio / VS Code with Flutter extensions.

### Installation

1. **Get dependencies:**
   Open your terminal in the project directory and run:
   ```bash
   flutter pub get
   ```

2. **Run the App:**
   Connect an emulator or a physical device and run:
   ```bash
   flutter run
   ```

---
<div align="center">
  <i>Developed with ❤️ using Flutter.</i>
</div>
