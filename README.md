<div align="center">

# 🚀 GoJobs

### A Flutter job-finding platform built for the Jordanian market

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=android)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-brightgreen)](LICENSE)

*Graduation Project — Computer Science, Jordan University of Science and Technology, 2025–2026*

</div>

---

## 📖 About

GoJobs is a mobile job marketplace targeting the Jordanian employment market. The app connects **three types of applicants** (Job Seekers, Freelancers, and Students) with **hiring companies** — each user type getting a fully tailored experience, dedicated screens, and role-specific features.

Jordan has a fragmented job market with most listings scattered across social media or outdated portals. GoJobs aims to fix that with a clean, modern mobile-first experience built entirely in Flutter and powered by Firebase.

---

## ✨ Features

### 👤 For Applicants (Job Seekers / Freelancers / Students)
- Browse and search job listings with real-time Firestore updates
- Build a profile with skills, experience, and education
- Apply to jobs directly through the app
- In-app chat with companies
- Real-time notifications via FCM
- Role-specific home screens and navigation flows

### 🏢 For Companies
- Distinct branded dashboard (dark navy gradient, gold accents)
- Post, edit, and manage job listings
- Review applicant profiles and manage applications
- In-app chat with candidates
- Company logo and profile management via Firebase Storage

### 🔐 Auth & Routing
- Firebase Email/Password authentication
- Role-based routing on login via Firestore `userType` field
- Persistent auth state — splash screen checks session on cold start
- Forgot password flow with Firebase email reset

---

## 🛠️ Tech Stack

| Layer | Tech |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Provider |
| Navigation | go_router |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| Fonts | Google Fonts — Poppins |

---


## 🗂️ Project Structure
lib/
├── main.dart
├── app_router.dart
├── theme/
│   └── app_colors.dart
├── providers/
│   └── auth_provider.dart
├── services/
│   └── auth_service.dart
└── screens/
├── shared/        # Splash, onboarding, auth screens
├── jobseeker/     # Job seeker flow (~30 screens)
├── freelancer/    # Freelancer-specific screens
├── student/       # Student-specific screens

---

## 🚀 Getting Started

```bash
git clone https://github.com/smadizaid15/GoJobs-gp.git
cd GoJobs-gp
flutter pub get
flutter run
```

### Firebase Setup
1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password** Authentication
3. Set up **Firestore** and **Storage**
4. Run `flutterfire configure` to generate `firebase_options.dart`

> ⚠️ `firebase_options.dart` and `google-services.json` are gitignored. You must connect your own Firebase project.

---

## 👥 User Roles

| `userType` | Destination |
|---|---|
| `jobSeeker` | Job Seeker Home |
| `freelancer` | Freelancer Home |
| `student` | Student Home |
| `company` | Company Dashboard |

---

## 🎨 Design Tokens

| Token | Value |
|---|---|
| Primary Navy | `#2D2B6B` |
| Primary Orange | `#F5A623` |
| Company Gold | `#E6A817` |
| Background | `#F0F0F5` |
| Font | Poppins |

---

## 🔮 Roadmap
- [ ] AI-powered job recommendations
- [ ] Arabic / RTL support
- [ ] Resume upload and parsing
- [ ] Advanced search filters

---

<div align="center">Made with ❤️ in Jordan </div>
