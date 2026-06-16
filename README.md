# 🏋️ Gym Genius

<p align="center">
  <img src="https://raw.githubusercontent.com/yashkoolwal27/Gym-Genius/main/docs/banner.png" alt="Gym Genius Banner" width="100%" onerror="this.src='https://placehold.co/1200x400/1e1e24/5AFD9A?text=Gym+Genius'" />
</p>

<p align="center">
  <b>Your AI-Powered Fitness Companion — Generate Workout Plans, Track Nutrition, and Stay Consistent</b>
</p>

<p align="center">
  <a href="https://gym-genius-chi.vercel.app"><img src="https://img.shields.io/badge/Web%20App-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white" /></a>
  <a href="https://github.com/yashkoolwal27/Gym-Genius/raw/main/gym-genius-app.apk"><img src="https://img.shields.io/badge/Android-Download%20Release-3DDC84?style=for-the-badge&logo=android&logoColor=white" /></a>
  <a href="https://github.com/yashkoolwal27/Gym-Genius/releases/download/v2.0.0/gym-genius-app-debug.apk"><img src="https://img.shields.io/badge/Android-Download%20Debug-orange?style=for-the-badge&logo=android&logoColor=white" /></a>
  <a href="#-ios-installation"><img src="https://img.shields.io/badge/iOS-Xcode%20Build-000000?style=for-the-badge&logo=apple&logoColor=white" /></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Next.js%2015-Framework-000000?style=flat-square&logo=nextdotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter%203-Mobile-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=flat-square&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Genkit%20AI-Powered-purple?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" />
</p>

---

## 📖 Table of Contents
- [📱 Platform Links](#-platform-links)
- [🧠 About the Project](#-about-the-project)
- [✨ Core Features](#-core-features)
- [📁 Repository Structure](#-repository-structure)
- [🚀 Quick Start Guide](#-quick-start-guide)
  - [Web Version (Next.js)](#1-web-version-nextjs)
  - [App Version (Flutter)](#2-app-version-flutter)
- [🔥 Firebase Infrastructure](#-firebase-infrastructure)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 📱 Platform Links

| Platform | Build Status | Access / Download |
|:---|:---|:---|
| **🌐 Web (Next.js)** | ![Vercel Deploy](https://img.shields.io/badge/Vercel-Deployed-brightgreen?style=flat-square) | [Launch Live Site](https://gym-genius-chi.vercel.app) |
| **🤖 Android App** | ![APK Release](https://img.shields.io/badge/APK-Available-blue?style=flat-square) | [Download Release APK (59MB)](https://github.com/yashkoolwal27/Gym-Genius/raw/main/gym-genius-app.apk) <br> [Download Debug APK (181MB)](https://github.com/yashkoolwal27/Gym-Genius/releases/download/v2.0.0/gym-genius-app-debug.apk) |
| **🍎 iOS App** | ![Xcode Compilation](https://img.shields.io/badge/Xcode-Build%20Ready-lightgrey?style=flat-square) | [iOS Instructions](#-ios-installation) |

---

## 🧠 About the Project

**Gym Genius** is a state-of-the-art fitness companion designed as a **monorepo** housing both a **Next.js web portal** and a **Flutter mobile app**. It provides users with automated workout scheduling, AI-powered nutritional recommendations, and smart local/cloud logging of daily physical progress.

The project utilizes a cohesive design system centered around a premium **Dark Slate & Neon Accent theme** to deliver an engaging, modern interface across both mobile screens and web layouts.

---

## ✨ Core Features

### 🌟 Sequential Food Search Pipeline
Our smart 4-tier fallback search ensures users can always find or log what they eat:
1. **Local Database (`foods_master`)** — Instant lookups with pre-mapped micronutrients.
2. **User Custom Foods (`custom_foods`)** — Personal items saved securely in Firestore.
3. **USDA API Fallback** — Millions of standard ingredients.
4. **OpenFoodFacts API** — International barcode and packaged item fallback.
*If all else fails, users can create custom foods instantly.*

### 🛠️ Admin Overrides
Admins (`isAdmin: true`) have special overlays on food details cards to instantly update/override food banner images globally, saving edits directly to Firestore to improve database quality for all users in real-time.

### 🧘 Onboarding & Profile Health Check
- **60-Second Onboarding:** A fast, friction-free profile configuration that skips secondary details (like usernames) during sign-up to boost completion rates.
- **Completion Tracker:** Gives weighted completion scores based on critical health inputs (e.g., Body Fat % and body metrics).
- **Interactive Body Visualizer:** A premium silhouette widget highlighting active/missing logs (calves, thighs, chest, shoulders, arms).

---

## 📁 Repository Structure

We organize our codebase inside two primary subfolders:

```
Gym-Genius/ (Root)
├── app/                  # 📱 Flutter Mobile Application (iOS & Android)
│   ├── lib/              # Dart sources (screens, models, widgets, services)
│   ├── assets/           # Audio, animation, and image assets
│   ├── android/          # Native Android configuration
│   └── ios/              # Native iOS configuration
├── web/                  # 🌐 Next.js 15 Web Portal (Vercel Deployed)
│   ├── src/              # Next.js page components, Genkit AI flows, and action hooks
│   ├── public/           # Static assets
│   └── tsconfig.json     # TypeScript config
├── docs/                 # 📂 Architecture blueprints, plans, and assets
├── firebase.json         # Firebase Configuration
├── firestore.rules       # Cloud Firestore Security Rules
└── package.json          # Root helper command orchestrator
```

---

## 🚀 Quick Start Guide

### 1. Web Version (Next.js)

```bash
# Navigate to the web folder
cd web

# Install dependencies
npm install

# Run dev server locally (port 9002 default)
npm run dev
```

*Note: You can also use root-level proxy commands without navigating: `npm run web:dev`, `npm run web:build`.*

---

### 2. App Version (Flutter)

#### Prerequisites
- Flutter SDK (v3.0.0+)
- Android Studio / Xcode

#### Setup
```bash
# Navigate to the app directory
cd app

# Fetch packages
flutter pub get

# Run on emulator/connected device
flutter run
```

*Note: You can also clean and fetch packages from the workspace root: `npm run app:clean`, `npm run app:pubget`.*

#### 🍏 iOS Installation
To run the iOS version on a simulator or device:
1. Open terminal in `/app/ios`.
2. Run `pod install`.
3. Open `Runner.xcworkspace` in Xcode.
4. Configure your Development Team signing profiles.
5. Select a target iOS simulator and click **Run** (or run `flutter run` inside `/app`).

---

## 🔥 Firebase Infrastructure

Our backend runs entirely on Firebase serverless architectures:
- **Authentication:** Email/password-based profiles.
- **Firestore Database:** Configured via custom rules ([firestore.rules](firestore.rules)) to isolate private user profiles while keeping global assets open read-only.
- **App Hosting & Emulators:** Fully integrates with Firebase CLI. To initialize, set up a project in the Firebase console and download the configuration keys to:
  - Android: `app/android/app/google-services.json`
  - iOS: `app/ios/Runner/GoogleService-Info.plist`

---

## 🤝 Contributing
1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m "feat: add AmazingFeature"`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](app/LICENSE) file for details.

---

<p align="center">
  Made with ❤️ and 💪 by <a href="https://github.com/yashkoolwal27">Yash Koolwal</a>
</p>
