# 🏋️ Gym Genius

<p align="center">
  <img src="docs/banner.png" alt="Gym Genius Banner" width="100%" />
</p>

<p align="center">
  <b>Your Smart Fitness Companion — Track Workouts, Manage Goals & Stay Consistent</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" />
</p>

---

## 📖 Table of Contents

- [About the Project](#-about-the-project)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Firebase Setup](#-firebase-setup)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🧠 About the Project

**Gym Genius** is a modern fitness web/mobile application built with **Flutter** and powered by **Firebase**. It helps gym-goers and fitness enthusiasts track their workouts, monitor progress, and stay on top of their fitness goals — all in one clean, intuitive interface.

Whether you're a beginner starting your fitness journey or a seasoned athlete optimizing your training, Gym Genius provides the tools you need to stay consistent and motivated.

---

## ✨ Features

- 🔐 **User Authentication** — Secure sign up & login via Firebase Auth
- 📋 **Workout Tracking** — Log daily workouts with sets, reps, and weights
- 📈 **Progress Monitoring** — Visualize your fitness journey over time
- 🎯 **Goal Setting** — Set and track personal fitness goals
- 🔔 **Notifications** — Stay reminded of your workout schedule
- 📱 **Responsive Design** — Works seamlessly on web and mobile
- ☁️ **Cloud Sync** — Data synced in real-time via Firebase Firestore

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Frontend UI Framework |
| **Firebase Auth** | User Authentication |
| **Cloud Firestore** | Real-time Database |
| **Firebase Hosting** | Web Deployment |
| **Firebase Rules** | Database Security |

---

## 📁 Project Structure

```
Gym-Genius/
├── src/                    # Main source code
│   ├── components/         # Reusable UI components
│   ├── pages/              # App screens/pages
│   └── services/           # Firebase & API services
├── docs/                   # Documentation & assets
├── .vscode/                # VS Code workspace settings
├── .gitignore              # Git ignored files
├── apphosting.yaml         # Firebase App Hosting config
├── components.json         # Component configuration
├── firestore.rules         # Firestore security rules
└── README.md               # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0 or above)
- [Dart](https://dart.dev/get-dart)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Google account for Firebase

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yashkoolwal27/Gym-Genius.git
   cd Gym-Genius
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** *(see section below)*

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build for web**
   ```bash
   flutter build web
   ```

---

## 🔥 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project
2. Enable **Authentication** (Email/Password)
3. Create a **Firestore Database** in production mode
4. Enable **Firebase Hosting**
5. Download your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) and place them in the correct directories
6. Update `firestore.rules` with your security rules
7. Deploy with:
   ```bash
   firebase deploy
   ```

---

## 📸 Screenshots

> *(Add your app screenshots here)*

| Home Screen | Workout Log | Progress |
|---|---|---|
| ![Home](docs/home.png) | ![Workout](docs/workout.png) | ![Progress](docs/progress.png) |

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add some AmazingFeature"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a **Pull Request**

Please make sure your code follows the existing style and includes relevant comments.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

**Yash Koolwal**

- GitHub: [@yashkoolwal27](https://github.com/yashkoolwal27)
- Project Link: [https://github.com/yashkoolwal27/Gym-Genius](https://github.com/yashkoolwal27/Gym-Genius)

---

<p align="center">
  Made with ❤️ and 💪 by Yash Koolwal
</p>
