# MindCaht

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

# 🚀 Setup del progetto Flutter

Questa guida spiega tutti i passaggi necessari per avviare il progetto dopo averlo scaricato da GitHub.

---

## 📌 Requisiti

Assicurati di avere installato:

- **Flutter SDK** (versione consigliata: stable)
- **Android Studio** o **VS Code** con plugin Flutter/Dart
- **Android SDK** + ADB
- Un dispositivo fisico o emulatore Android

Verifica l’installazione:

```bash
flutter doctor
```
1. Clona il repository

```bash
git clone https://github.com/TUO-USERNAME/TUO-REPO.git
cd TUO-REPO
```

2. Installa le dipendenze

```bash
flutter pub get

# Se vuoi pulire eventuali build precedenti:
flutter clean
flutter pub get
```

3. Collega un dispositivo o avvia un emulatore

Lista dispositivi disponibili:

```bash
flutter devices
```

4. Avvia l’app

```bash
flutter run
```

5. (Opzionale) Ricreare il database locale

Se ottieni errori relativi alle tabelle SQLite, disinstalla l’app dal dispositivo:

```bash
adb uninstall com.example.todo_app
```

Poi avvia nuovamente l'app

