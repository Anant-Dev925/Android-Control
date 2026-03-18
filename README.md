# Android Control

AI-powered Android file control app.

## Setup

1. Install Flutter dependencies:
```bash
cd android_control
flutter pub get
```

2. Connect Android device via ADB:
```bash
adb connect 100.125.170.26:5555
```

3. Start server on PC:
```bash
cd D:\StudyMaterial\Notes\10th Semester\Project
node server.js
```

4. Build and run:
```bash
flutter run
```

## Usage

- Type natural language commands like "List files in /sdcard/Download"
- Use quick action buttons for common operations
- Connection status shown in app bar

## Server IP

Change `SERVER_URL` in `lib/main.dart` to your PC's IP address:
```dart
static const String SERVER_URL = "http://YOUR_PC_IP:3000";
```
